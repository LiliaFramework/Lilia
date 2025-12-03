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

function lia.inventory.newType(typeID, invTypeStruct)
    assert(not lia.inventory.types[typeID], L("duplicateInventoryType", typeID))
    assert(istable(invTypeStruct), L("expectedTableArg", 2))
    checkType(typeID, invTypeStruct, InvTypeStructType)
    debug.getregistry()[invTypeStruct.className] = invTypeStruct
    lia.inventory.types[typeID] = invTypeStruct
end

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

    function lia.inventory.loadAllFromCharID(charID)
        local originalCharID = charID
        charID = tonumber(charID)
        if not charID then
            lia.error(L("charIDMustBeNumber") .. " (received: " .. tostring(originalCharID) .. ", type: " .. type(originalCharID) .. ")")
            return deferred.reject(L("charIDMustBeNumber"))
        end
        return lia.db.select({"invID"}, INV_TABLE, "charID = " .. charID):next(function(res) return deferred.map(res.results or {}, function(result) return lia.inventory.loadByID(tonumber(result.invID)) end) end)
    end

    function lia.inventory.deleteByID(id)
        lia.db.delete(DATA_TABLE, "invID = " .. id)
        lia.db.delete(INV_TABLE, "invID = " .. id)
        lia.db.delete(ITEMS_TABLE, "invID = " .. id)
        local instance = lia.inventory.instances[id]
        if instance then instance:destroy() end
    end

    function lia.inventory.cleanUpForCharacter(character)
        for _, inventory in pairs(character:getInv(true)) do
            inventory:destroy()
        end
    end

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

    function lia.inventory.registerStorage(model, data)
        assert(isstring(model), L("storageModelMustBeString"))
        assert(istable(data), L("storageDataMustBeTable"))
        assert(isstring(data.name), L("storageNameRequired"))
        assert(isstring(data.invType), L("storageInvTypeRequired"))
        assert(istable(data.invData), L("storageInvDataRequired"))
        lia.inventory.storage[model:lower()] = data
        return data
    end

    function lia.inventory.getStorage(model)
        if not model then return end
        return lia.inventory.storage[model:lower()]
    end

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

    function lia.inventory.getTrunk(vehicleClass)
        if not vehicleClass then return end
        local trunkData = lia.inventory.storage[vehicleClass:lower()]
        return trunkData and trunkData.isTrunk and trunkData or nil
    end

    function lia.inventory.getAllTrunks()
        local trunks = {}
        for key, data in pairs(lia.inventory.storage) do
            if data.isTrunk then trunks[key] = data end
        end
        return trunks
    end

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
