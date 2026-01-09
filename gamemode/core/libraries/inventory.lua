--[[
    Folder: Libraries
    File: inventory.md
]]
--[[
    Inventory Library

    Comprehensive inventory system management with multiple storage types for the Lilia framework.
]]
--[[
    Overview:
        The inventory library provides comprehensive functionality for managing inventory systems in the Lilia framework. It handles inventory type registration, instance creation, storage management, and database persistence. The library operates on both server and client sides, with the server managing inventory data persistence, loading, and storage registration, while the client handles inventory panel display and user interaction. It supports multiple inventory types, storage containers, vehicle trunks, and character-based inventory management. The library ensures proper data validation, caching, and cleanup for optimal performance.
]]
lia.inventory = lia.inventory or {}
lia.inventory.types = lia.inventory.types or {}
lia.inventory.storage = lia.inventory.storage or {}
lia.inventory.instances = lia.inventory.instances or {}
lia.inventory.dualInventoryOpen = lia.inventory.dualInventoryOpen or false
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
    Purpose:
        Registers a new inventory type with the specified ID and structure.

    When Called:
        Called during gamemode initialization or when defining custom inventory types that extend the base inventory system.

    Parameters:
        typeID (string)
            Unique identifier for the inventory type.
        invTypeStruct (table)
            Table containing the inventory type definition with required fields like className, config, and methods.

    Returns:
        nil
            No return value.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.inventory.newType("grid", {
            className = "GridInv",
            config = {w = 10, h = 10},
            add = function(self, item) end,
            remove = function(self, item) end,
            sync = function(self, client) end
        })
        ```
]]
function lia.inventory.newType(typeID, invTypeStruct)
    assert(not lia.inventory.types[typeID], L("duplicateInventoryType", typeID))
    assert(istable(invTypeStruct), L("expectedTableArg", 2))
    checkType(typeID, invTypeStruct, InvTypeStructType)
    debug.getregistry()[invTypeStruct.className] = invTypeStruct
    lia.inventory.types[typeID] = invTypeStruct
end

--[[
    Purpose:
        Creates a new inventory instance of the specified type.

    When Called:
        Called when instantiating inventories during loading, character creation, or when creating new storage containers.

    Parameters:
        typeID (string)
            The inventory type identifier that was previously registered with newType.

    Returns:
        table
            A new inventory instance with items table and copied config from the type definition.

    Realm:
        Shared

    Example Usage:
        ```lua
        local myInventory = lia.inventory.new("grid")
        -- Creates a new grid-based inventory instance
        ```
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
    local INV_FIELDS = {"invID", "invType", "charID"}
    local INV_TABLE = "inventories"
    local DATA_FIELDS = {"key", "value"}
    local DATA_TABLE = "invdata"
    local ITEMS_TABLE = "items"
    --[[
    Purpose:
        Loads an inventory instance by its ID, checking cache first and falling back to storage loading.

    When Called:
        Called when accessing inventories by ID, typically during character loading, item operations, or storage access.

    Parameters:
        id (number)
            The unique inventory ID to load.
        noCache (boolean)
            Optional flag to bypass cache and force loading from storage.

    Returns:
        Deferred
            A deferred object that resolves to the loaded inventory instance, or rejects if loading fails.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.loadByID(123):next(function(inventory)
            print("Loaded inventory:", inventory.id)
        end)
        ```
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
    Purpose:
        Loads an inventory from the default database storage, including associated data and items.

    When Called:
        Called by loadByID when no custom storage loader is found, or when directly loading from database storage.

    Parameters:
        id (number)
            The inventory ID to load from database storage.
        noCache (boolean)
            Optional flag to bypass cache and force fresh loading.

    Returns:
        Deferred
            A deferred object that resolves to the fully loaded inventory instance with data and items.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.loadFromDefaultStorage(456, true):next(function(inventory)
            -- Inventory loaded with fresh data, bypassing cache
        end)
        ```
]]
    function lia.inventory.loadFromDefaultStorage(id, noCache)
        return deferred.all({lia.db.select(INV_FIELDS, INV_TABLE, "invID = " .. id, 1), lia.db.select(DATA_FIELDS, DATA_TABLE, "invID = " .. id)}):next(function(res)
            if lia.inventory.instances[id] and not noCache then return lia.inventory.instances[id] end
            local results = res[1].results and res[1].results[1] or nil
            if not results then return end
            local typeID = results.invType
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
    Purpose:
        Creates a new inventory instance with persistent storage initialization.

    When Called:
        Called when creating new inventories that need database persistence, such as character inventories or storage containers.

    Parameters:
        typeID (string)
            The inventory type identifier.
        initialData (table)
            Optional initial data to store with the inventory instance.

    Returns:
        Deferred
            A deferred object that resolves to the created inventory instance after storage initialization.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.instance("grid", {char = 1}):next(function(inventory)
            -- New inventory created and stored in database
        end)
        ```
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
    Purpose:
        Loads all inventories associated with a specific character ID.

    When Called:
        Called during character loading to restore all inventory data for a character.

    Parameters:
        charID (number|string)
            The character ID to load inventories for (will be converted to number).

    Returns:
        Deferred
            A deferred object that resolves to an array of loaded inventory instances.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.loadAllFromCharID(42):next(function(inventories)
            for _, inv in ipairs(inventories) do
                print("Loaded inventory:", inv.id)
            end
        end)
        ```
]]
    function lia.inventory.loadAllFromCharID(charID)
        local originalCharID = charID
        charID = tonumber(charID)
        if not charID then
            lia.error(L("charIDMustBeNumber") .. " (received: " .. tostring(originalCharID) .. ", type: " .. type(originalCharID) .. ")")
            return deferred.reject(L("charIDMustBeNumber"))
        end
        return lia.db.select({"invID"}, INV_TABLE, "charID = " .. charID):next(function(res) return deferred.map(res.results or {}, function(result) return lia.inventory.loadByID(tonumber(result.invID)) end) end)
    end

    --[[
    Purpose:
        Permanently deletes an inventory and all its associated data from the database.

    When Called:
        Called when removing inventories, such as during character deletion or storage cleanup.

    Parameters:
        id (number)
            The inventory ID to delete.

    Returns:
        nil
            No return value.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.deleteByID(123)
        -- Inventory 123 and all its data/items are permanently removed
        ```
]]
    function lia.inventory.deleteByID(id)
        lia.db.delete(DATA_TABLE, "invID = " .. id)
        lia.db.delete(INV_TABLE, "invID = " .. id)
        lia.db.delete(ITEMS_TABLE, "invID = " .. id)
        local instance = lia.inventory.instances[id]
        if instance then instance:destroy() end
    end

    --[[
    Purpose:
        Destroys all inventories associated with a character during cleanup.

    When Called:
        Called during character deletion or when cleaning up character data to prevent memory leaks.

    Parameters:
        character (table)
            The character object whose inventories should be destroyed.

    Returns:
        nil
            No return value.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.cleanUpForCharacter(player:getChar())
        -- All inventories for this character are destroyed
        ```
]]
    function lia.inventory.cleanUpForCharacter(character)
        for _, inventory in pairs(character:getInv(true)) do
            inventory:destroy()
        end
    end

    --[[
    Purpose:
        Checks for items that no longer fit in an inventory after resizing and moves them to overflow storage.

    When Called:
        Called when inventory dimensions change (like when upgrading inventory size) to handle items that no longer fit.

    Parameters:
        inv (table)
            The inventory instance to check for overflow.
        character (table)
            The character object to store overflow items on.
        oldW (number)
            The previous width of the inventory.
        oldH (number)
            The previous height of the inventory.

    Returns:
        boolean
            True if overflow items were found and moved, false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        if lia.inventory.checkOverflow(inventory, player:getChar(), 5, 5) then
            -- Items were moved to overflow storage
        end
        ```
]]
    function lia.inventory.checkOverflow(inv, character, oldW, oldH)
        local overflow, toRemove = {}, {}
        for _, item in pairs(inv:getItems()) do
            local x, y = item:getData("x"), item:getData("y")
            if x and y and not inv:canItemFitInInventory(item, x, y) then
                local data = item:getAllData()
                data.x, data.y = nil, nil
                overflow[#overflow + 1] = {
                    uniqueID = item.uniqueID,
                    quantity = item:getQuantity(),
                    data = data
                }

                toRemove[#toRemove + 1] = item
            end
        end

        for _, item in ipairs(toRemove) do
            item:remove()
        end

        if #overflow > 0 then
            character:setData("overflowItems", {
                size = {oldW, oldH},
                items = overflow
            })
            return true
        end
        return false
    end

    --[[
    Purpose:
        Registers a storage container configuration for entities with the specified model.

    When Called:
        Called during gamemode initialization to define storage containers like lockers, crates, or other inventory-holding entities.

    Parameters:
        model (string)
            The model path of the entity that will have storage capability.
        data (table)
            Configuration table containing name, invType, invData, and other storage properties.

    Returns:
        table
            The registered storage data table.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.registerStorage("models/props_c17/lockers001a.mdl", {
            name = "Locker",
            invType = "grid",
            invData = {w = 4, h = 6}
        })
        ```
]]
    function lia.inventory.registerStorage(model, data)
        assert(isstring(model), L("storageModelMustBeString"))
        assert(istable(data), L("storageDataMustBeTable"))
        assert(isstring(data.name), L("storageNameRequired"))
        assert(isstring(data.invType), L("storageInvTypeRequired"))
        assert(istable(data.invData), L("storageInvDataRequired"))
        lia.inventory.storage[model:lower()] = data
        return data
    end

    --[[
    Purpose:
        Retrieves the storage configuration for a specific model.

    When Called:
        Called when checking if an entity model has storage capabilities or retrieving storage properties.

    Parameters:
        model (string)
            The model path to look up storage configuration for.

    Returns:
        table|nil
            The storage configuration table if found, nil otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        local storage = lia.inventory.getStorage("models/props_c17/lockers001a.mdl")
        if storage then
            print("Storage name:", storage.name)
        end
        ```
]]
    function lia.inventory.getStorage(model)
        if not model then return end
        return lia.inventory.storage[model:lower()]
    end

    --[[
    Purpose:
        Registers a vehicle trunk configuration for vehicles with the specified class.

    When Called:
        Called during gamemode initialization to define vehicle trunk storage capabilities.

    Parameters:
        vehicleClass (string)
            The vehicle class name that will have trunk capability.
        data (table)
            Configuration table containing name, invType, invData, and trunk-specific properties.

    Returns:
        table
            The registered trunk data table with trunk flags set.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.inventory.registerTrunk("vehicle_class", {
            name = "Car Trunk",
            invType = "grid",
            invData = {w = 8, h = 4}
        })
        ```
]]
    function lia.inventory.registerTrunk(vehicleClass, data)
        assert(isstring(vehicleClass), L("vehicleClassMustBeString"))
        assert(istable(data), "Data must be a table")
        assert(isstring(data.name), L("trunkNameRequired"))
        assert(isstring(data.invType), L("storageInvTypeRequired"))
        assert(istable(data.invData), L("storageInvDataRequired"))
        if not data.invData.w then data.invData.w = lia.config.get("trunkInvW", 10) end
        if not data.invData.h then data.invData.h = lia.config.get("trunkInvH", 2) end
        data.isTrunk = true
        data.trunkKey = vehicleClass:lower()
        lia.inventory.storage[vehicleClass:lower()] = data
        return data
    end

    --[[
    Purpose:
        Retrieves the trunk configuration for a specific vehicle class.

    When Called:
        Called when checking if a vehicle class has trunk capabilities or retrieving trunk properties.

    Parameters:
        vehicleClass (string)
            The vehicle class name to look up trunk configuration for.

    Returns:
        table|nil
            The trunk configuration table if found and it's a trunk, nil otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
        local trunk = lia.inventory.getTrunk("vehicle_class")
        if trunk then
            print("Trunk capacity:", trunk.invData.w, "x", trunk.invData.h)
        end
        ```
]]
    function lia.inventory.getTrunk(vehicleClass)
        if not vehicleClass then return end
        local trunkData = lia.inventory.storage[vehicleClass:lower()]
        return trunkData and trunkData.isTrunk and trunkData or nil
    end

    --[[
    Purpose:
        Retrieves all registered trunk configurations.

    When Called:
        Called when listing all available vehicle trunk types or for administrative purposes.

    Parameters:
        None

    Returns:
        table
            A table containing all registered trunk configurations keyed by vehicle class.

    Realm:
        Server

    Example Usage:
        ```lua
        local trunks = lia.inventory.getAllTrunks()
        for class, config in pairs(trunks) do
            print("Trunk for", class, ":", config.name)
        end
        ```
]]
    function lia.inventory.getAllTrunks()
        local trunks = {}
        for key, data in pairs(lia.inventory.storage) do
            if data.isTrunk then trunks[key] = data end
        end
        return trunks
    end

    --[[
    Purpose:
        Retrieves all registered storage configurations, optionally excluding trunks.

    When Called:
        Called when listing all available storage types or for administrative purposes.

    Parameters:
        includeTrunks (boolean)
            Optional flag to include (true) or exclude (false) trunk configurations. Defaults to true.

    Returns:
        table
            A table containing all registered storage configurations, optionally filtered.

    Realm:
        Server

    Example Usage:
        ```lua
        -- Get all storage including trunks
        local allStorage = lia.inventory.getAllStorage(true)

        -- Get only non-trunk storage
        local storageOnly = lia.inventory.getAllStorage(false)
        ```
]]
    function lia.inventory.getAllStorage(includeTrunks)
        if includeTrunks ~= false then
            return lia.inventory.storage
        else
            local storageOnly = {}
            for key, data in pairs(lia.inventory.storage) do
                if not data.isTrunk then storageOnly[key] = data end
            end
            return storageOnly
        end
    end
else
    --[[
    Purpose:
        Creates and displays an inventory panel for the specified inventory.

    When Called:
        Called when opening inventory interfaces, such as character inventories, storage containers, or other inventory UIs.

    Parameters:
        inventory (table)
            The inventory instance to display in the panel.
        parent (Panel)
            Optional parent panel for the inventory panel.

    Returns:
        Panel
            The created inventory panel instance.

    Realm:
        Client

    Example Usage:
        ```lua
        local panel = lia.inventory.show(myInventory)
        -- Opens the inventory UI for myInventory
        ```
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

    --[[
    Purpose:
        Creates and displays two inventory panels side by side for dual inventory interactions.

    When Called:
        Called when opening dual inventory interfaces, such as trading, transferring items between inventories, or accessing storage.

    Parameters:
        inventory1 (table)
            The first inventory instance to display.
        inventory2 (table)
            The second inventory instance to display.
        parent (Panel)
            Optional parent panel for the inventory panels.

    Returns:
        table
            An array containing both created inventory panel instances {panel1, panel2}.

    Realm:
        Client

    Example Usage:
        ```lua
        local panels = lia.inventory.showDual(playerInv, storageInv)
        -- Opens dual inventory UI for trading between player and storage
        ```
]]
    function lia.inventory.showDual(inventory1, inventory2, parent)
        if not inventory1 or not inventory1.id or not inventory2 or not inventory2.id then
            lia.error("Invalid inventories provided to showDual")
            return nil
        end

        if lia.inventory.dualInventoryOpen then
            lia.notify(L("inventoryAlreadyOpen"), "error")
            return nil
        end

        local panel1 = lia.inventory.show(inventory1, parent)
        local panel2 = lia.inventory.show(inventory2, parent)
        if not IsValid(panel1) or not IsValid(panel2) then
            lia.error("Failed to create inventory panels")
            return nil
        end

        lia.inventory.dualInventoryOpen = true
        local extraWidth = (panel2:GetWide() + 4) / 2
        panel1:Center()
        panel2:Center()
        panel1.x = panel1.x + extraWidth
        panel2:MoveLeftOf(panel1, 4)
        panel1:ShowCloseButton(true)
        panel2:ShowCloseButton(true)
        local firstToRemove = true
        local oldOnRemove1 = panel1.OnRemove
        local oldOnRemove2 = panel2.OnRemove
        local function exitDualOnRemove(closingPanel)
            if firstToRemove then
                firstToRemove = false
                local otherPanel = (closingPanel == panel1) and panel2 or panel1
                if IsValid(otherPanel) then otherPanel:Remove() end
                lia.inventory.dualInventoryOpen = false
            end

            if closingPanel == panel1 and oldOnRemove1 then
                oldOnRemove1(closingPanel)
            elseif closingPanel == panel2 and oldOnRemove2 then
                oldOnRemove2(closingPanel)
            end
        end

        panel1.OnRemove = exitDualOnRemove
        panel2.OnRemove = exitDualOnRemove
        hook.Run("OnCreateDualInventoryPanels", panel1, panel2, inventory1, inventory2)
        return {panel1, panel2}
    end
end
