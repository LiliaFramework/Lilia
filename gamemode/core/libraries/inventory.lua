--[[
# Inventory Library

This page documents the functions for working with inventory systems and item management.

---

## Overview

The inventory library provides a flexible system for managing item storage and retrieval within the Lilia framework. It supports multiple inventory types, item stacking, grid-based layouts, and provides utilities for inventory operations such as adding, removing, and syncing items. The library handles both client and server-side inventory management with proper networking.

The library features include:
- **Multi-Inventory Support**: Support for different inventory types (backpack, storage, vendor, etc.) with custom behaviors
- **Grid-Based Layout**: Flexible grid system for organizing items in visual inventory interfaces
- **Item Stacking**: Automatic stacking of compatible items with quantity management
- **Real-Time Synchronization**: Efficient client-server synchronization of inventory changes
- **Type Validation**: Strict type checking and validation for inventory structures and operations
- **Hook System**: Extensive hook system for custom inventory logic and item interactions
- **Performance Optimization**: Optimized inventory operations with caching and efficient data structures
- **Error Handling**: Robust error handling for inventory operations with rollback capabilities
- **Cross-Realm Support**: Seamless operation on both client and server sides
- **Plugin Integration**: Easy integration with external inventory and item management systems
- **Storage Management**: Automatic storage allocation and deallocation for inventory instances
- **Item Compatibility**: Built-in compatibility checking for item placement and stacking
- **Inventory Persistence**: Automatic saving and loading of inventory data to/from database
- **UI Integration**: Built-in support for inventory user interfaces and visual representations
- **Access Control**: Permission-based access to inventory operations and modifications
- **Backup Systems**: Automatic backup and recovery mechanisms for inventory data

The inventory system provides the foundation for all item management and storage functionality in Lilia, supporting complex inventory interactions, item trading, and storage solutions. It ensures data integrity and provides a flexible framework for custom inventory implementations.
]]
lia.inventory = lia.inventory or {}
lia.inventory.types = lia.inventory.types or {}
lia.inventory.instances = lia.inventory.instances or {}
local function serverOnly(value)
    return SERVER and value or nil
end

local InvTypeStructType = {
    __index = "table",
    add = serverOnly("function"),
    remove = serverOnly("function"),
    sync = serverOnly("function"),
    typeID = "string",
    className = "string"
}

local function checkType(typeID, struct, expected, prefix)
    prefix = prefix or ""
    for key, expectedType in pairs(expected) do
        local actualValue = struct[key]
        local expectedTypeString = isstring(expectedType) and expectedType or type(expectedType)
        local fieldName = prefix .. key
        assert(type(actualValue) == expectedTypeString, L("invTypeMismatch", fieldName, expectedTypeString, typeID, type(actualValue)))
        if istable(expectedType) then checkType(typeID, actualValue, expectedType, prefix .. key .. ".") end
    end
end

--[[
    lia.inventory.newType

    Purpose:
        Registers a new inventory type with the specified typeID and structure. This function validates the structure,
        stores it in the global inventory type list, and registers it in the Lua registry for later instantiation.

    Parameters:
        typeID (string)         - The unique identifier for the inventory type.
        invTypeStruct (table)   - The structure/table defining the inventory type's behavior and properties.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Register a new inventory type called "backpack"
        lia.inventory.newType("backpack", {
            __index = "table",
            add = function(self, item) print("Added item:", item) end,
            remove = function(self, item) print("Removed item:", item) end,
            sync = function(self) print("Syncing inventory...") end,
            typeID = "backpack",
            className = "liaBackpack",
            config = {width = 5, height = 5}
        })
]]
function lia.inventory.newType(typeID, invTypeStruct)
    assert(not lia.inventory.types[typeID], L("duplicateInventoryType", typeID))
    assert(istable(invTypeStruct), L("expectedTableArg", 2))
    checkType(typeID, invTypeStruct, InvTypeStructType)
    debug.getregistry()[invTypeStruct.className] = invTypeStruct
    lia.inventory.types[typeID] = invTypeStruct
end

--[[
    lia.inventory.new

    Purpose:
        Instantiates a new inventory of the specified type. The new inventory will have its items table and a copy of the
        configuration from the registered inventory type.

    Parameters:
        typeID (string) - The unique identifier of the inventory type to instantiate.

    Returns:
        inventory (table) - The new inventory instance.

    Realm:
        Shared.

    Example Usage:
        -- Create a new "backpack" inventory
        local backpackInv = lia.inventory.new("backpack")
        print(backpackInv.config.width) -- Output: 5 (if set in config)
        print(backpackInv.items) -- Output: {}
]]
function lia.inventory.new(typeID)
    local class = lia.inventory.types[typeID]
    assert(class ~= nil, L("badInventoryType", typeID))
    return setmetatable({
        items = {},
        config = table.Copy(class.config)
    }, class)
end

if SERVER then
    local INV_FIELDS = {"invID", "_invType", "charID"}
    local INV_TABLE = "inventories"
    local DATA_FIELDS = {"key", "value"}
    local DATA_TABLE = "invdata"
    local ITEMS_TABLE = "items"
    --[[
        lia.inventory.loadByID

        Purpose:
            Loads an inventory instance by its unique ID from the database or cache. If a custom loader is defined for the
            inventory type, it will be used. Otherwise, the default loader is used.

        Parameters:
            id (number)      - The unique inventory ID to load.
            noCache (bool)   - If true, bypasses the cache and forces a reload from storage.

        Returns:
            d (deferred)     - A deferred object that resolves to the loaded inventory instance.

        Realm:
            Server.

        Example Usage:
            -- Load inventory with ID 42
            lia.inventory.loadByID(42):next(function(inventory)
                print("Loaded inventory with ID:", inventory.id)
            end)
    ]]
    function lia.inventory.loadByID(id, noCache)
        local instance = lia.inventory.instances[id]
        if instance and not noCache then
            local d = deferred.new()
            d:resolve(instance)
            return d
        end

        for _, invType in pairs(lia.inventory.types) do
            local loadFunction = rawget(invType, "loadFromStorage")
            if loadFunction then
                local d = loadFunction(invType, id)
                if d then return d end
            end
        end

        assert(isnumber(id) and id >= 0, L("noInventoryLoader", tostring(id)))
        return lia.inventory.loadFromDefaultStorage(id, noCache)
    end

    --[[
        lia.inventory.loadFromDefaultStorage

        Purpose:
            Loads an inventory instance from the default storage backend using its ID. Populates the inventory's data and
            items from the database, and caches the instance.

        Parameters:
            id (number)      - The unique inventory ID to load.
            noCache (bool)   - If true, bypasses the cache and forces a reload from storage.

        Returns:
            d (deferred)     - A deferred object that resolves to the loaded inventory instance.

        Realm:
            Server.

        Example Usage:
            -- Load inventory from default storage with ID 100
            lia.inventory.loadFromDefaultStorage(100):next(function(inventory)
                print("Inventory loaded:", inventory)
            end)
    ]]
    function lia.inventory.loadFromDefaultStorage(id, noCache)
        return deferred.all({lia.db.select(INV_FIELDS, INV_TABLE, "invID = " .. id, 1), lia.db.select(DATA_FIELDS, DATA_TABLE, "invID = " .. id)}):next(function(res)
            if lia.inventory.instances[id] and not noCache then return lia.inventory.instances[id] end
            local results = res[1].results and res[1].results[1] or nil
            if not results then return end
            local typeID = results._invType
            local invType = lia.inventory.types[typeID]
            if not invType then
                lia.error(L("inventoryInvalidType", id, typeID))
                return
            end

            local instance = invType:new()
            instance.id = id
            instance.data = {}
            for _, row in ipairs(res[2].results or {}) do
                local decoded = util.JSONToTable(row.value)
                instance.data[row.key] = decoded and decoded[1] or nil
            end

            instance.data.char = tonumber(results.charID) or instance.data.char
            lia.inventory.instances[id] = instance
            instance:onLoaded()
            return instance:loadItems():next(function() return instance end)
        end, function(err)
            lia.information(L("failedLoadInventory", tostring(id)))
            lia.information(err)
        end)
    end

    --[[
        lia.inventory.instance

        Purpose:
            Creates and stores a new inventory instance of the specified type, initializing its storage in the database.
            The new instance is cached and returned via a deferred.

        Parameters:
            typeID (string)      - The unique identifier of the inventory type to instantiate.
            initialData (table)  - Optional table of initial data to store in the inventory.

        Returns:
            d (deferred)         - A deferred object that resolves to the new inventory instance.

        Realm:
            Server.

        Example Usage:
            -- Create a new "backpack" inventory for a character
            lia.inventory.instance("backpack", {char = 123}):next(function(inv)
                print("Created inventory with ID:", inv.id)
            end)
    ]]
    function lia.inventory.instance(typeID, initialData)
        local invType = lia.inventory.types[typeID]
        assert(istable(invType), L("invalidInventoryType", tostring(typeID)))
        assert(initialData == nil or istable(initialData), L("initialDataMustBeTable"))
        initialData = initialData or {}
        return invType:initializeStorage(initialData):next(function(id)
            local instance = invType:new()
            instance.id = id
            instance.data = initialData
            lia.inventory.instances[id] = instance
            instance:onInstanced()
            return instance
        end)
    end

    --[[
        lia.inventory.loadAllFromCharID

        Purpose:
            Loads all inventory instances associated with a given character ID. Returns a deferred that resolves to a table
            of inventory instances.

        Parameters:
            charID (number)  - The character ID whose inventories should be loaded.

        Returns:
            d (deferred)     - A deferred object that resolves to a table of inventory instances.

        Realm:
            Server.

        Example Usage:
            -- Load all inventories for character ID 55
            lia.inventory.loadAllFromCharID(55):next(function(inventories)
                for _, inv in ipairs(inventories) do
                    print("Loaded inventory:", inv.id)
                end
            end)
    ]]
    function lia.inventory.loadAllFromCharID(charID)
        assert(isnumber(charID), L("charIDMustBeNumber"))
        return lia.db.select({"invID"}, INV_TABLE, "charID = " .. charID):next(function(res) return deferred.map(res.results or {}, function(result) return lia.inventory.loadByID(tonumber(result.invID)) end) end)
    end

    --[[
        lia.inventory.deleteByID

        Purpose:
            Deletes an inventory and all its associated data from the database and cache, and destroys the instance.

        Parameters:
            id (number)  - The unique inventory ID to delete.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Delete inventory with ID 77
            lia.inventory.deleteByID(77)
    ]]
    function lia.inventory.deleteByID(id)
        lia.db.delete(DATA_TABLE, "invID = " .. id)
        lia.db.delete(INV_TABLE, "invID = " .. id)
        lia.db.delete(ITEMS_TABLE, "invID = " .. id)
        local instance = lia.inventory.instances[id]
        if instance then instance:destroy() end
    end

    --[[
        lia.inventory.cleanUpForCharacter

        Purpose:
            Destroys all inventory instances associated with a given character, typically used during character deletion or cleanup.

        Parameters:
            character (table) - The character object whose inventories should be destroyed.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Clean up all inventories for a character object
            lia.inventory.cleanUpForCharacter(myCharacter)
    ]]
    function lia.inventory.cleanUpForCharacter(character)
        for _, inventory in pairs(character:getInv(true)) do
            inventory:destroy()
        end
    end
else
    --[[
        lia.inventory.show

        Purpose:
            Displays the given inventory in a GUI panel for the client. If a panel for the inventory already exists, it is removed first.
            Hooks are called for panel creation and inventory open/close events.

        Parameters:
            inventory (table) - The inventory instance to display.
            parent (Panel)    - Optional parent panel for the inventory GUI.

        Returns:
            panel (Panel)     - The created inventory panel.

        Realm:
            Client.

        Example Usage:
            -- Show the inventory panel for a given inventory
            local invPanel = lia.inventory.show(myInventory)
            invPanel:SetPos(100, 100)
    ]]
    function lia.inventory.show(inventory, parent)
        local globalName = "inv" .. inventory.id
        if IsValid(lia.gui[globalName]) then lia.gui[globalName]:Remove() end
        local panel = hook.Run("CreateInventoryPanel", inventory, parent)
        hook.Run("InventoryOpened", panel, inventory)
        local oldOnRemove = panel.OnRemove
        function panel:OnRemove()
            if oldOnRemove then oldOnRemove(self) end
            hook.Run("InventoryClosed", self, inventory)
        end

        lia.gui[globalName] = panel
        return panel
    end
end
