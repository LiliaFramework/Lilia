--[[
    Folder: Developer - Libraries
    File: lia.inventory.md
]]
--[[
    Inventory

    Inventory helpers for registering inventory types, creating and loading inventory instances, managing persistent storage definitions, and opening inventory panels.
]]
--[[
    Overview:
        The inventory library centralizes shared inventory behavior under `lia.inventory`. It registers inventory type structures, creates inventory objects, loads and deletes server-side inventory records, manages storage and vehicle trunk definitions, handles overflow after size changes, and opens single or dual inventory interfaces on the client.
]]
--[[
    Hooks:
        CreateInventoryPanel(table inventory, Panel|nil parent)

    Purpose:
        Allows the clientside inventory interface to be created for a specific inventory.

    Category:
        Inventory

    Parameters:
        inventory (table)
            The inventory instance that needs a panel.

        parent (Panel|nil)
            Optional parent panel for the created inventory panel.

    Example Usage:
        ```lua
        hook.Add("CreateInventoryPanel", "liaExampleCreateInventoryPanel", function(inventory, parent)
            print("[MyModule] handled CreateInventoryPanel")
        end)
        ```

    Returns:
        Panel
            The created inventory panel.

    Realm:
        Client
]]
--[[
    Hooks:
        InventoryOpened(Panel panel, table inventory)

    Purpose:
        Called after an inventory panel has been created and opened.

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The inventory panel that was opened.

        inventory (table)
            The inventory instance displayed by the panel.

    Example Usage:
        ```lua
        hook.Add("InventoryOpened", "liaExampleInventoryOpened", function(panel, inventory)
            if not IsValid(panel) then return end
            panel:SetTooltip("InventoryOpened handled by MyModule")
        end)
        ```

    Returns:
        None

    Realm:
        Client
]]
--[[
    Hooks:
        InventoryClosed(Panel panel, table inventory)

    Purpose:
        Called when an inventory panel is removed or closed.

    Category:
        Inventory

    Parameters:
        panel (Panel)
            The inventory panel that was closed.

        inventory (table)
            The inventory instance that was displayed by the panel.

    Example Usage:
        ```lua
        hook.Add("InventoryClosed", "liaExampleInventoryClosed", function(panel, inventory)
            if not IsValid(panel) then return end
            panel:SetTooltip("InventoryClosed handled by MyModule")
        end)
        ```

    Returns:
        None

    Realm:
        Client
]]
--[[
    Hooks:
        OnCreateDualInventoryPanels(Panel panel1, Panel panel2, table inventory1, table inventory2)

    Purpose:
        Called after two inventory panels have been created and positioned for a dual-inventory view.

    Category:
        Inventory

    Parameters:
        panel1 (Panel)
            The panel displaying the first inventory.

        panel2 (Panel)
            The panel displaying the second inventory.

        inventory1 (table)
            The first inventory instance.

        inventory2 (table)
            The second inventory instance.

    Example Usage:
        ```lua
        hook.Add("OnCreateDualInventoryPanels", "liaExampleOnCreateDualInventoryPanels", function(panel1, panel2, inventory1, inventory2)
            print("[MyModule] handled OnCreateDualInventoryPanels")
        end)
        ```

    Returns:
        None

    Realm:
        Client
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
        Registers a new inventory type structure under `lia.inventory.types`.

    Parameters:
        typeID (string)
            Unique identifier used to reference the inventory type.

        invTypeStruct (table)
            Inventory type structure containing the required metatable fields and server methods.

    Returns:
        None

    Example Usage:
        ```lua
        lia.inventory.newType("grid", inventoryType)
        ```

    Realm:
        Shared
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
        Creates a new inventory object from a registered inventory type without loading or assigning persistent storage.

    Parameters:
        typeID (string)
            Identifier of the registered inventory type to instantiate.

    Returns:
        table
            A new inventory object with copied configuration and an empty item table.

    Example Usage:
        ```lua
        local inventory = lia.inventory.new("grid")
        ```

    Realm:
        Shared
]]
function lia.inventory.new(typeID)
    local class = lia.inventory.types[typeID]
    assert(class ~= nil, L("invalidInventoryType", typeID))
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
    local function inventoryDevLog(...)
        if not lia.devmode then return end
        local parts = {...}
        for i = 1, #parts do
            parts[i] = tostring(parts[i])
        end

        MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 200, 0), "[DevMode] ", Color(255, 255, 255), table.concat(parts, " "), "\n")
    end

    --[[
        Purpose:
            Loads an inventory by its persistent ID, using the cached instance unless `noCache` is enabled.

        Parameters:
            id (number)
                Persistent inventory ID to load.

            noCache (boolean|nil)
                Whether to bypass an existing cached inventory instance.

        Returns:
            Deferred
                A deferred that resolves with the loaded inventory instance.

        Example Usage:
            ```lua
            lia.inventory.loadByID(invID):next(function(inventory)
                if inventory then inventory:sync(client) end
            end)
            ```

        Realm:
            Server
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
            Loads an inventory from the default database tables and restores its saved data and items.

        Parameters:
            id (number)
                Persistent inventory ID to load.

            noCache (boolean|nil)
                Whether to bypass an existing cached inventory instance.

        Returns:
            Deferred
                A deferred that resolves with the loaded inventory instance, or nil if no record exists.

        Example Usage:
            ```lua
            lia.inventory.loadFromDefaultStorage(invID, true):next(function(inventory)
                if inventory then inventory:onLoaded() end
            end)
            ```

        Realm:
            Server
    ]]
    function lia.inventory.loadFromDefaultStorage(id, noCache)
        local started = SysTime()
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
            return instance:loadItems():next(function()
                if lia.devmode then inventoryDevLog(string.format("Loaded inventory %s for char %s in %.3fs", tostring(id), tostring(instance.data.char or "nil"), SysTime() - started)) end
                return instance
            end)
        end, function(err)
            lia.information(L("failedLoadInventory", tostring(id)))
            lia.information(err)
        end)
    end

    --[[
        Purpose:
            Creates and persists a new inventory instance of the given type.

        Parameters:
            typeID (string)
                Identifier of the registered inventory type to create.

            initialData (table|nil)
                Optional data table assigned to the new inventory instance.

        Returns:
            Deferred
                A deferred that resolves with the newly created inventory instance.

        Example Usage:
            ```lua
            lia.inventory.instance("grid", {char = character:getID()}):next(function(inventory)
                character:setInv(inventory)
            end)
            ```

        Realm:
            Server
    ]]
    function lia.inventory.instance(typeID, initialData)
        local invType = lia.inventory.types[typeID]
        if not istable(invType) then
            local available = {}
            for k in pairs(lia.inventory.types) do
                available[#available + 1] = k
            end

            ErrorNoHalt("[Lilia] Inventory type mismatch: '" .. tostring(typeID) .. "' does not match any registered type. This may be a leftover reference to an old inventory type. Available types: " .. table.concat(available, ", ") .. "\n")
            local d = deferred.new()
            d:reject(L("invalidInventoryType", tostring(typeID)))
            return d
        end

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
            Loads every inventory associated with a character ID.

        Parameters:
            charID (number|string)
                Character ID whose inventories should be loaded.

        Returns:
            Deferred
                A deferred that resolves with the loaded inventory instances.

        Example Usage:
            ```lua
            lia.inventory.loadAllFromCharID(character:getID()):next(function(inventories)
                for _, inventory in pairs(inventories) do
                    inventory:sync(client)
                end
            end)
            ```

        Realm:
            Server
    ]]
    function lia.inventory.loadAllFromCharID(charID)
        local originalCharID = charID
        local started = SysTime()
        charID = tonumber(charID)
        if not charID then
            lia.error(L("charIDMustBeNumber") .. " (received: " .. tostring(originalCharID) .. ", type: " .. type(originalCharID) .. ")")
            return deferred.reject(L("charIDMustBeNumber"))
        end
        return lia.db.select({"invID"}, INV_TABLE, "charID = " .. charID):next(function(res)
            local rows = res.results or {}
            if lia.devmode then inventoryDevLog("Loading", tostring(#rows), "inventories for char", tostring(charID)) end
            return deferred.map(rows, function(result) return lia.inventory.loadByID(tonumber(result.invID)) end)
        end):next(function(inventories)
            if lia.devmode then inventoryDevLog(string.format("Finished loading inventories for char %s in %.3fs", tostring(charID), SysTime() - started)) end
            return inventories
        end)
    end

    --[[
        Purpose:
            Deletes an inventory and its related data from persistent storage, then destroys the cached instance if present.

        Parameters:
            id (number)
                Persistent inventory ID to delete.

        Returns:
            None

        Example Usage:
            ```lua
            lia.inventory.deleteByID(invID)
            ```

        Realm:
            Server
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
            Destroys all inventory instances currently associated with a character.

        Parameters:
            character (Character)
                Character whose inventories should be cleaned up.

        Returns:
            None

        Example Usage:
            ```lua
            lia.inventory.cleanUpForCharacter(character)
            ```

        Realm:
            Server
    ]]
    function lia.inventory.cleanUpForCharacter(character)
        for _, inventory in pairs(character:getInv(true)) do
            inventory:destroy()
        end
    end

    --[[
        Purpose:
            Removes items that no longer fit in an inventory and stores them as character overflow data.

        Parameters:
            inv (table)
                Inventory instance being checked for overflow.

            character (Character)
                Character that owns the inventory.

            oldW (number)
                Previous inventory width used for overflow metadata.

            oldH (number)
                Previous inventory height used for overflow metadata.

        Returns:
            boolean
                True if one or more items overflowed and were stored, otherwise false.

        Example Usage:
            ```lua
            if lia.inventory.checkOverflow(inventory, character, oldW, oldH) then
                client:notifyWarning("Some items no longer fit in your inventory.")
            end
            ```

        Realm:
            Server
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
            Registers a world storage definition for a model.

        Parameters:
            model (string)
                Model path used as the storage lookup key.

            data (table)
                Storage definition containing `name`, `invType`, and `invData`, with optional description data.

        Returns:
            table
                The registered storage definition.

        Example Usage:
            ```lua
            lia.inventory.registerStorage("models/props_junk/wood_crate001a.mdl", {
                name = "Crate",
                invType = "grid",
                invData = {w = 4, h = 4}
            })
            ```

        Realm:
            Server
    ]]
    function lia.inventory.registerStorage(model, data)
        assert(isstring(model), L("modelMustBeString"))
        assert(istable(data), L("dataMustBeTable"))
        assert(isstring(data.name), L("storageNameRequired"))
        assert(isstring(data.invType), L("inventoryTypeRequired"))
        assert(istable(data.invData), L("inventoryDataRequired"))
        data.name = lia.lang.resolveToken(data.name)
        if isstring(data.desc) then data.desc = lia.lang.resolveToken(data.desc) end
        lia.inventory.storage[model:lower()] = data
        return data
    end

    --[[
        Purpose:
            Retrieves a registered storage definition by model.

        Parameters:
            model (string)
                Model path used to look up storage data.

        Returns:
            table|nil
                The matching storage definition, or nil if none exists.

        Example Usage:
            ```lua
            local storage = lia.inventory.getStorage(entity:GetModel())
            ```

        Realm:
            Server
    ]]
    function lia.inventory.getStorage(model)
        if not model then return end
        return lia.inventory.storage[model:lower()]
    end

    --[[
        Purpose:
            Registers a vehicle trunk storage definition for a vehicle class.

        Parameters:
            vehicleClass (string)
                Vehicle class used as the trunk lookup key.

            data (table)
                Trunk definition containing `name`, `invType`, and `invData`, with optional description data.

        Returns:
            table
                The registered trunk definition.

        Example Usage:
            ```lua
            lia.inventory.registerTrunk("prop_vehicle_jeep", {
                name = "Vehicle Trunk",
                invType = "grid",
                invData = {w = 6, h = 3}
            })
            ```

        Realm:
            Server
    ]]
    function lia.inventory.registerTrunk(vehicleClass, data)
        assert(isstring(vehicleClass), L("vehicleClassMustBeString"))
        assert(istable(data), "Data must be a table")
        assert(isstring(data.name), L("trunkNameRequired"))
        assert(isstring(data.invType), L("inventoryTypeRequired"))
        assert(istable(data.invData), L("inventoryDataRequired"))
        data.name = lia.lang.resolveToken(data.name)
        if isstring(data.desc) then data.desc = lia.lang.resolveToken(data.desc) end
        if not data.invData.w then data.invData.w = lia.config.get("trunkInvW", 10) end
        if not data.invData.h then data.invData.h = lia.config.get("trunkInvH", 2) end
        data.isTrunk = true
        data.trunkKey = vehicleClass:lower()
        lia.inventory.storage[vehicleClass:lower()] = data
        return data
    end

    --[[
        Purpose:
            Retrieves a registered vehicle trunk definition by vehicle class.

        Parameters:
            vehicleClass (string)
                Vehicle class used to look up trunk data.

        Returns:
            table|nil
                The matching trunk definition, or nil if the class is not registered as a trunk.

        Example Usage:
            ```lua
            local trunk = lia.inventory.getTrunk(vehicle:GetClass())
            ```

        Realm:
            Server
    ]]
    function lia.inventory.getTrunk(vehicleClass)
        if not vehicleClass then return end
        local trunkData = lia.inventory.storage[vehicleClass:lower()]
        return trunkData and trunkData.isTrunk and trunkData or nil
    end

    --[[
        Purpose:
            Returns every registered vehicle trunk definition.

        Parameters:
            None

        Returns:
            table
                Table of registered trunk definitions keyed by their lowercase trunk keys.

        Example Usage:
            ```lua
            local trunks = lia.inventory.getAllTrunks()
            ```

        Realm:
            Server
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
            Returns registered storage definitions, optionally excluding vehicle trunks.

        Parameters:
            includeTrunks (boolean|nil)
                Set to false to return only non-trunk storage definitions.

        Returns:
            table
                Registered storage definitions keyed by lowercase model or vehicle class.

        Example Usage:
            ```lua
            local storageOnly = lia.inventory.getAllStorage(false)
            ```

        Realm:
            Server
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
            Creates and opens a clientside panel for an inventory.

        Parameters:
            inventory (table)
                Inventory instance to display.

            parent (Panel|nil)
                Optional parent panel for the created inventory panel.

        Returns:
            Panel
                The created inventory panel.

        Example Usage:
            ```lua
            local panel = lia.inventory.show(inventory)
            ```

        Realm:
            Client
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
            Opens two inventory panels side by side and links their close behavior.

        Parameters:
            inventory1 (table)
                First inventory instance to display.

            inventory2 (table)
                Second inventory instance to display.

            parent (Panel|nil)
                Optional parent panel for the created inventory panels.

        Returns:
            table|nil
                A table containing both created panels, or nil if panel creation fails.

        Example Usage:
            ```lua
            local panels = lia.inventory.showDual(characterInv, storageInv)
            ```

        Realm:
            Client
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
