lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.list = lia.item.list or {}
lia.item.rarities = lia.item.rarities or {}
lia.item.instances = lia.item.instances or {}
lia.item.itemEntities = lia.item.itemEntities or {}
lia.item.inventories = lia.inventory.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
lia.item.WeaponOverrides = lia.item.WeaponOverrides or {}
lia.item.WeaponRuntimeOverrides = lia.item.WeaponRuntimeOverrides or {}
lia.item.pendingOverrides = lia.item.pendingOverrides or {}
lia.item.pendingRegistrations = lia.item.pendingRegistrations or {}
lia.item.WeaponsBlackList = lia.item.WeaponsBlackList or {
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    lia_adminstick = true,
    lia_hands = true,
    lia_keys = true
}

local DefaultFunctions = {
    drop = {
        tip = "Drops the item.",
        icon = "icon16/world.png",
        onRun = function(item)
            local client = item.player
            item:removeFromInventory(true):next(function()
                local spawnedItem = item:spawn(client)
                hook.Run("OnPlayerDroppedItem", client, spawnedItem)
            end)
            return false
        end,
        onCanRun = function(item) return not IsValid(item.entity) and not IsValid(item.entity) and not item.noDrop end
    },
    take = {
        tip = "takeTip",
        icon = "icon16/box.png",
        onRun = function(item)
            local client = item.player
            local inventory = client:getChar():getInv()
            local entity = item.entity
            if client.itemTakeTransaction and client.itemTakeTransactionTimeout > RealTime() then return false end
            client.itemTakeTransaction = true
            client.itemTakeTransactionTimeout = RealTime()
            if not inventory then return false end
            local d = deferred.new()
            inventory:add(item):next(function()
                client.itemTakeTransaction = nil
                if IsValid(entity) then
                    entity.liaIsSafe = true
                    entity:Remove()
                end

                hook.Run("OnPlayerTakeItem", client, item)
                if not IsValid(client) then return end
                d:resolve()
            end):catch(function(err)
                if err == "This item can not fit in your inventory." or err == "noFit" then
                    client:notifyError(string.format("This item can't fit in your inventory. (%sx%s)", item:getWidth(), item:getHeight()))
                else
                    client:notifyError(err)
                end

                client.itemTakeTransaction = nil
                d:reject()
            end)
            return d
        end,
        onCanRun = function(item) return IsValid(item.entity) end
    },
    rotate = {
        tip = "Rotates the item.",
        icon = "icon16/arrow_rotate_clockwise.png",
        onRun = function(item, data)
            local inv = lia.item.getInv(item.invID)
            local x, y = item:getData("x"), item:getData("y")
            local newRot = not item:getData("rotated", false)
            local showNoFitNotice = istable(data) and data.placementAttempt == true
            if inv and x and y then
                local w = newRot and (item.height or 1) or item.width or 1
                local h = newRot and (item.width or 1) or item.height or 1
                local invW, invH = inv:getSize()
                if x < 1 or y < 1 or x + w - 1 > invW or y + h - 1 > invH then
                    if showNoFitNotice and IsValid(item.player) then item.player:notifyError(string.format("This item can't fit in your inventory. (%sx%s)", w, h)) end
                    return false
                end

                for _, v in pairs(inv:getItems(true)) do
                    if v ~= item then
                        local ix, iy = v:getData("x"), v:getData("y")
                        if ix and iy then
                            local ix2 = ix + v:getWidth() - 1
                            local iy2 = iy + v:getHeight() - 1
                            local x2 = x + w - 1
                            local y2 = y + h - 1
                            if x <= ix2 and ix <= x2 and y <= iy2 and iy <= y2 then
                                if showNoFitNotice and IsValid(item.player) then item.player:notifyError(string.format("This item can't fit in your inventory. (%sx%s)", w, h)) end
                                return false
                            end
                        end
                    end
                end
            end

            item:setData("rotated", newRot)
            if IsValid(item.player) then hook.Run("OnPlayerRotateItem", item.player, item, newRot) end
            return false
        end,
        onCanRun = function(item) return not IsValid(item.entity) and item.width ~= item.height and not item:getData("equip", false) end
    },
    giveForward = {
        tip = "Gives the item to the player in front of you.",
        icon = "icon16/arrow_up.png",
        onRun = function(item)
            local function canTransferItemsFromInventoryUsingGiveForward(_, action)
                if action == "transfer" then return true end
            end

            local client = item.player
            local inv = client:getChar():getInv()
            local target = client:getTracedEntity()
            if not (target and target:IsValid() and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500) then return false end
            local targetInv = target:getChar():getInv()
            if not target or not targetInv then return false end
            if not targetInv:doesFitInventory(item) then
                client:notify(string.format("This item can not fit in your inventory."))
                return false
            end

            target:requestBinaryQuestion(string.format("%s wants to give you a %s. Accept?", client:Name(), item.name), "Yes", "No", function(choice)
                if choice == 0 then
                    inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    client:setAction(string.format("Giving %s to %s", item.name, target:Name()), lia.config.get("ItemGiveSpeed", 6))
                    target:setAction(string.format("%s is giving you a %s", client:Name(), item.name), lia.config.get("ItemGiveSpeed", 6))
                    client:doStaredAction(target, function()
                        local res = hook.Run("HandleItemTransferRequest", client, item:getID(), nil, nil, targetInv:getID())
                        if not res then return end
                        res:next(function()
                            if not IsValid(client) then return end
                            if istable(res) and isstring(res.error) then return client:notifyError(res.error) end
                            client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
                            client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
                        end)
                    end, lia.config.get("ItemGiveSpeed", 6), function() client:setAction() end, 100)
                else
                    client:notify(string.format("%s declined your item offer.", target:Name()))
                    target:notify(string.format("You declined %s's item offer.", client:Name()))
                end
            end)
            return false
        end,
        onCanRun = function(item)
            local client = item.player
            local target = client:getTracedEntity()
            return not IsValid(item.entity) and lia.config.get("ItemGiveEnabled") and not IsValid(item.entity) and not item.noDrop and target and IsValid(target) and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500
        end
    },
}

lia.meta.item.width = 1
lia.meta.item.height = 1
function lia.item.get(identifier)
    return lia.item.base[identifier] or lia.item.list[identifier]
end

function lia.item.applyWeaponOverride(uniqueID)
    local data = lia.item.WeaponOverrides and lia.item.WeaponOverrides[uniqueID]
    if not istable(data) then return end
    local itemDef = lia.item.list and lia.item.list[uniqueID]
    if not itemDef then return end
    for k, v in pairs(data) do
        itemDef[k] = v
    end
end

function lia.item.getItemByID(itemID)
    assert(isnumber(itemID), "Item ID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
    local location = "unknown"
    if item.invID then
        local inventory = lia.item.getInv(item.invID)
        if inventory then location = "inventory" end
    elseif item.entity and IsValid(item.entity) then
        location = "world"
    end
    return {
        item = item,
        location = location
    }
end

function lia.item.getInstancedItemByID(itemID)
    assert(isnumber(itemID), "Item ID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
    return item
end

function lia.item.getItemDataByID(itemID)
    assert(isnumber(itemID), "Item ID must be a number")
    local item = lia.item.instances[itemID]
    if not item then return nil, "Item not found" end
    return item.data
end

function lia.item.load(path, baseID, isBaseItem)
    local uniqueID = path:match("sh_([_%w]+)%.lua") or path:match("([_%w]+)%.lua")
    if uniqueID then
        uniqueID = (isBaseItem and "base_" or "") .. uniqueID
        lia.item.register(uniqueID, baseID, isBaseItem, path)
    elseif path:find("%.txt$") then
        local formatted = path:gsub("\\", "/"):lower()
        if not formatted:find("^lilia/") then lia.error("[Lilia] " .. string.format("Text file found at '%s'  to use it properly, it needs to be a .lua file.", path) .. "\n") end
    else
        lia.error("[Lilia] " .. string.format("Item at '%s' follows an invalid naming convention!", path) .. "\n")
    end
end

function lia.item.isItem(object)
    return istable(object) and object.isItem
end

function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

function lia.item.addRarities(name, color)
    assert(isstring(name), "Rarity name must be a string")
    assert(IsColor(color), "Color must be a Color")
    lia.item.rarities[name] = color
end

function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
    assert(isstring(uniqueID), "uniqueID must be a string")
    local baseTable = lia.item.base[baseID] or lia.meta.item
    if baseID then assert(baseTable, string.format("Item base not found for item %s with base ID %s", uniqueID, baseID)) end
    local targetTable = isBaseItem and lia.item.base or lia.item.list
    if luaGenerated then
        ITEM = setmetatable({
            hooks = table.Copy(baseTable.hooks or {}),
            postHooks = table.Copy(baseTable.postHooks or {}),
            BaseClass = baseTable,
            __tostring = baseTable.__tostring,
        }, {
            __eq = baseTable.__eq,
            __tostring = baseTable.__tostring,
            __index = baseTable
        })

        ITEM.__tostring = baseTable.__tostring
        ITEM.desc = "No Description"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "Miscellaneous"
        ITEM.functions = table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    else
        ITEM = targetTable[uniqueID] or setmetatable({
            hooks = table.Copy(baseTable.hooks or {}),
            postHooks = table.Copy(baseTable.postHooks or {}),
            BaseClass = baseTable,
            __tostring = baseTable.__tostring,
        }, {
            __eq = baseTable.__eq,
            __tostring = baseTable.__tostring,
            __index = baseTable
        })

        ITEM.__tostring = baseTable.__tostring
        ITEM.desc = "No Description"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "Miscellaneous"
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    end

    if not luaGenerated and path then lia.loader.include(path, "shared") end
    lia.item.localizeDefinition(ITEM)
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    if not isBaseItem then lia.item.applyWeaponOverride(itemType) end
    lia.item.localizeDefinition(targetTable[itemType])
    hook.Run("OnItemRegistered", ITEM)
    ITEM = nil
    return targetTable[itemType]
end

function lia.item.localizeDefinition(itemDef)
    return itemDef
end

function lia.item.registerItem(id, base, properties)
    assert(isstring(id), "uniqueID must be a string")
    if properties ~= nil and not istable(properties) then
        local errorMsg = string.format("properties must be a table or nil, got %s (type: %s)", tostring(properties), type(properties))
        lia.error(string.format("[Lilia] registerItem called with invalid properties for item ('%s'): %s\n", id, errorMsg))
        properties = {}
    end

    table.insert(lia.item.pendingRegistrations, {
        id = id,
        base = base,
        properties = properties
    })

    local placeholder = {
        uniqueID = id,
        base = base,
        _isPlaceholder = true
    }

    setmetatable(placeholder, {
        __index = function(self, key)
            if self._isPlaceholder then
                local actualItem = lia.item.get(id)
                if actualItem then return actualItem[key] end
            end
            return nil
        end
    })
    return placeholder
end

function lia.item.overrideItem(uniqueID, overrides)
    assert(isstring(uniqueID), "uniqueID must be a string")
    assert(istable(overrides), "overrides must be a table")
    if not lia.item.pendingOverrides[uniqueID] then lia.item.pendingOverrides[uniqueID] = {} end
    for key, value in pairs(overrides) do
        lia.item.pendingOverrides[uniqueID][key] = value
    end
end

function lia.item.loadFromDir(directory)
    local files, folders
    files = file.Find(directory .. "/base/*.lua", "LUA")
    for _, v in ipairs(files) do
        lia.item.load(directory .. "/base/" .. v, nil, true)
    end

    files, folders = file.Find(directory .. "/*", "LUA")
    for _, v in ipairs(folders) do
        if v == "base" then continue end
        for _, v2 in ipairs(file.Find(directory .. "/" .. v .. "/*.lua", "LUA")) do
            lia.item.load(directory .. "/" .. v .. "/" .. v2, "base_" .. v, nil)
        end
    end

    for _, v in ipairs(files) do
        lia.item.load(directory .. "/" .. v)
    end

    hook.Run("InitializedItems")
end

function lia.item.new(uniqueID, id)
    id = id and tonumber(id) or id
    assert(isnumber(id), "Item Non Number ID")
    if lia.item.instances[id] and lia.item.instances[id].uniqueID == uniqueID then return lia.item.instances[id] end
    local stockItem = lia.item.list[uniqueID]
    if stockItem then
        local item = setmetatable({
            id = id,
            data = {}
        }, {
            __eq = stockItem.__eq,
            __tostring = stockItem.__tostring,
            __index = stockItem
        })

        lia.item.instances[id] = item
        hook.Run("OnItemCreated", item)
        return item
    else
        error("[Lilia] " .. string.format("An inventory has an unknown item '%s'", tostring(uniqueID)) .. "\n")
    end
end

function lia.item.registerInv(invType, w, h)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, "Grid Inventory Not Found")
    local inventory = GridInv:extend("GridInv" .. invType)
    inventory.invType = invType
    function inventory:getWidth()
        return w
    end

    function inventory:getHeight()
        return h
    end

    inventory:register(invType)
end

function lia.item.newInv(owner, invType, callback)
    lia.inventory.instance(invType, {
        char = owner
    }):next(function(inventory)
        inventory.invType = invType
        if owner and owner > 0 then
            for _, v in player.Iterator() do
                if v:getChar() and v:getChar():getID() == owner then
                    inventory:sync(v)
                    break
                end
            end
        end

        if callback then callback(inventory) end
    end)
end

function lia.item.createInv(w, h, id)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, "Grid Inventory Not Found")
    local instance = GridInv:new()
    instance.id = id
    instance.data = {
        w = w,
        h = h
    }

    lia.inventory.instances[id] = instance
    return instance
end

lia.item.holdTypeSizeMapping = {
    grenade = {
        width = 1,
        height = 1
    },
    pistol = {
        width = 1,
        height = 1
    },
    smg = {
        width = 2,
        height = 1
    },
    ar2 = {
        width = 2,
        height = 2
    },
    rpg = {
        width = 1,
        height = 2
    },
    shotgun = {
        width = 2,
        height = 1
    },
    crossbow = {
        width = 1,
        height = 2
    },
    normal = {
        width = 2,
        height = 1
    },
    melee = {
        width = 1,
        height = 1
    },
    melee2 = {
        width = 1,
        height = 1
    },
    fist = {
        width = 1,
        height = 1
    },
    knife = {
        width = 1,
        height = 1
    },
    physgun = {
        width = 2,
        height = 1
    },
    slam = {
        width = 1,
        height = 2
    },
    passive = {
        width = 1,
        height = 1
    }
}

function lia.item.addWeaponOverride(className, data)
    lia.item.WeaponOverrides[className] = data
end

function lia.item.addWeaponToBlacklist(className)
    lia.item.WeaponsBlackList[className] = true
end

function lia.item.applyRuntimeOverridePath(wepTable, dotPath, value)
    if not istable(wepTable) then return false end
    local parts = string.Explode(".", dotPath)
    if #parts < 2 then return false end
    local cur = wepTable
    for i = 1, #parts - 1 do
        local seg = parts[i]
        if not istable(cur[seg]) then return false end
        cur = cur[seg]
    end

    cur[parts[#parts]] = value
    return true
end

function lia.item.getRuntimeValue(wepTable, dotPath)
    if not istable(wepTable) then return nil end
    local parts = string.Explode(".", dotPath)
    local cur = wepTable
    for _, seg in ipairs(parts) do
        if not istable(cur) then return nil end
        cur = cur[seg]
    end
    return cur
end

if SERVER then
    function lia.item.setItemDataByID(itemID, key, value, receivers, noSave, noCheckEntity)
        assert(isnumber(itemID), "Item ID must be a number")
        assert(isstring(key), "Item Key String")
        local item = lia.item.instances[itemID]
        if not item then return false, "Item not found" end
        item:setData(key, value, receivers, noSave, noCheckEntity)
        return true
    end

    function lia.item.instance(index, uniqueID, itemData, x, y, callback)
        if isstring(index) and (istable(uniqueID) or itemData == nil and x == nil) then
            itemData = uniqueID
            uniqueID = index
        end

        local d = deferred.new()
        local itemTable = lia.item.list[uniqueID]
        if not itemTable then
            d:reject(string.format("An inventory has a missing item '%s'", tostring(uniqueID)))
            return d
        end

        if not istable(itemData) then itemData = {} end
        if isnumber(itemData.x) then
            x = itemData.x
            itemData.x = nil
        end

        if isnumber(itemData.y) then
            y = itemData.y
            itemData.y = nil
        end

        local defaultQuantity = tonumber(itemData.quantity)
        if not defaultQuantity then defaultQuantity = itemTable.isStackable and 1 or itemTable.maxQuantity or 1 end
        local function onItemCreated(_, itemID)
            local item = lia.item.new(uniqueID, itemID)
            if item then
                item.data = itemData
                item.invID = index
                item.data.x = x
                item.data.y = y
                item.quantity = defaultQuantity
                if callback then callback(item) end
                d:resolve(item)
                item:onInstanced(index, x, y, item)
            end
        end

        if not isnumber(index) then index = NULL end
        lia.db.insertTable({
            invID = index,
            uniqueID = uniqueID,
            data = itemData,
            x = x,
            y = y,
            quantity = defaultQuantity
        }, onItemCreated, "items")
        return d
    end

    function lia.item.deleteByID(id)
        if lia.item.instances[id] then
            lia.item.instances[id]:delete()
        else
            lia.db.delete("items", "itemID = " .. id)
        end
    end

    function lia.item.loadItemByID(itemIndex)
        local range
        if istable(itemIndex) then
            range = "(" .. table.concat(itemIndex, ", ") .. ")"
        elseif isnumber(itemIndex) then
            range = "(" .. itemIndex .. ")"
        else
            return
        end

        lia.db.query("SELECT itemID, uniqueID, data, x, y, quantity FROM lia_items WHERE itemID IN " .. range, function(results)
            if not results then return end
            for _, row in ipairs(results) do
                local id = tonumber(row.itemID)
                local itemDef = lia.item.list[row.uniqueID]
                if id and itemDef then
                    local item = lia.item.new(row.uniqueID, id)
                    local itemData = util.JSONToTable(row.data or "[]") or {}
                    item.invID = 0
                    item.data = itemData
                    item.data.x = tonumber(row.x)
                    item.data.y = tonumber(row.y)
                    item.quantity = tonumber(row.quantity)
                    item:onRestored()
                end
            end
        end)
    end

    function lia.item.spawn(uniqueID, position, callback, angles, data)
        local d
        if not isfunction(callback) then
            if isangle(callback) or istable(angles) then
                angles = callback
                data = angles
            end

            d = deferred.new()
            callback = function(item) d:resolve(item) end
        end

        local promise = lia.item.instance(0, uniqueID, data or {}, 1, 1, function(item)
            item:spawn(position, angles)
            if callback then callback(item) end
        end)

        promise:next(function() end, function(reason)
            if reason and reason:find("An inventory has a missing item") then
                lia.error(reason)
            else
                lia.error(string.format("Failed to spawn item: %s", tostring(reason or "Unknown error")))
            end

            if callback then callback(nil) end
        end)
        return d
    end

    function lia.item.restoreInv(invID, w, h, callback)
        lia.inventory.loadByID(invID):next(function(inventory)
            if not inventory then return end
            inventory:setData("w", w)
            inventory:setData("h", h)
            if callback then callback(inventory) end
        end)
    end
end

hook.Add("InitializedModules", "liaItems", function()
    for _, registration in ipairs(lia.item.pendingRegistrations) do
        local item = lia.item.register(registration.id, registration.base, false, nil, true)
        if registration.properties then
            for key, value in pairs(registration.properties) do
                item[key] = value
            end

            lia.item.localizeDefinition(item)
        end
    end

    lia.item.pendingRegistrations = {}
    if lia.config.get("AutoWeaponItemGeneration", true) then
        for _, wep in ipairs(weapons.GetList()) do
            local className = wep.ClassName
            if not className or className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
            local override = lia.item.WeaponOverrides[className] or {}
            local holdType = wep.HoldType or "normal"
            local isGrenade = holdType == "grenade"
            local baseType = isGrenade and "base_grenade" or "base_weapons"
            local size = lia.item.holdTypeSizeMapping[holdType] or {
                width = 2,
                height = 1
            }

            local properties = {
                name = hook.Run("GetWeaponName", wep) or override.name or className,
                desc = override.desc or "A Weapon.",
                category = override.category or isGrenade and "Grenades" or "Weapons",
                model = override.model or wep.WorldModel or wep.WM or "models/props_c17/suitcase_passenger_physics.mdl",
                class = override.class or className,
                width = override.width or size.width,
                height = override.height or size.height
            }

            if override.weaponCategory then properties.weaponCategory = override.weaponCategory end
            local item = lia.item.register(className, baseType, false, nil, true)
            for key, value in pairs(properties) do
                item[key] = value
            end

            lia.item.localizeDefinition(item)
        end
    end

    if lia.config.get("AutoAmmoItemGeneration", true) then
        local entityList = {}
        local scriptedEntities = scripted_ents.GetList()
        for className, _ in pairs(scriptedEntities) do
            if isstring(className) and className then entityList[className] = true end
        end

        for className, _ in pairs(entityList) do
            if not className or not isstring(className) then continue end
            local isArc9Ammo = className:find("^arc9_ammo_")
            local isArccwAmmo = className:find("^arccw_ammo_")
            local isTfaAmmo = className:find("^tfa_ammo_")
            if not (isArc9Ammo or isArccwAmmo or isTfaAmmo) then continue end
            if className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
            local override = lia.item.WeaponOverrides[className] or {}
            local baseType = "base_entities"
            local entityID = className
            local ammoType
            local itemName
            if isArc9Ammo then
                ammoType = className:gsub("^arc9_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or string.format("[ARC9] %s Ammunition", ammoType)
            elseif isArccwAmmo then
                ammoType = className:gsub("^arccw_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or string.format("[ARCCW] %s Ammunition", ammoType)
            elseif isTfaAmmo then
                ammoType = className:gsub("^tfa_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or string.format("[TFA] %s Ammunition", ammoType)
            else
                itemName = override.name or className
                ammoType = className
            end

            local properties = {
                name = itemName,
                desc = override.desc or string.format("A box of %s ammunition", ammoType),
                category = override.category or "Ammunition",
                model = override.model or "models/items/boxsrounds.mdl",
                entityid = override.entityid or entityID,
                width = override.width or 1,
                height = override.height or 1
            }

            lia.item.registerItem(className, baseType, properties)
        end
    end

    lia.item.itemEntities = {}
    for _, item in pairs(lia.item.list) do
        if item.base == "base_entities" then lia.item.itemEntities[item.uniqueID] = {item.entityid, item.data} end
    end

    if lia.config.get("ItemsCanBeDestroyed", true) then
        for _, item in pairs(lia.item.list) do
            item.CanBeDestroyed = true
        end
    end

    for uniqueID, overrides in pairs(lia.item.pendingOverrides) do
        local item = lia.item.get(uniqueID)
        if item then
            for key, value in pairs(overrides) do
                if isfunction(value) then
                    item[key] = value
                elseif istable(value) then
                    if key == "functions" then
                        item.functions = item.functions or {}
                        for funcName, funcData in pairs(value) do
                            item.functions[funcName] = funcData
                        end
                    elseif key == "hooks" then
                        item.hooks = item.hooks or {}
                        for hookName, hookFunc in pairs(value) do
                            item.hooks[hookName] = hookFunc
                        end
                    elseif key == "postHooks" then
                        item.postHooks = item.postHooks or {}
                        for hookName, hookFunc in pairs(value) do
                            item.postHooks[hookName] = hookFunc
                        end
                    else
                        item[key] = value
                    end
                else
                    item[key] = value
                end
            end

            lia.item.localizeDefinition(item)
            hook.Run("OnItemOverridden", item, overrides)
        else
            lia.error("[Lilia] Cannot override item ('" .. tostring(uniqueID) .. "'): item not found\n")
        end
    end

    lia.item.pendingOverrides = {}
end)

if SERVER then
    function lia.item.loadWeaponOverrides()
        local stored = lia.data.get("weaponOverrides") or {}
        lia.item.WeaponOverrides = stored
        for className, data in pairs(lia.item.WeaponOverrides) do
            local itemDef = lia.item.list[className]
            if itemDef and istable(data) then
                for k, v in pairs(data) do
                    itemDef[k] = v
                end
            end
        end
    end

    function lia.item.loadWeaponRuntimeOverrides()
        local stored = lia.data.get("weaponRuntimeOverrides") or {}
        lia.item.WeaponRuntimeOverrides = stored
        for className, paths in pairs(stored) do
            local wep = weapons.GetStored(className)
            if wep then
                for dotPath, value in pairs(paths) do
                    lia.item.applyRuntimeOverridePath(wep, dotPath, value)
                end
            end
        end
    end
else
    local function GetWeaponConfigTheme()
        local theme = lia.color and lia.color.theme or {}
        local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(185, 125, 55)
        local text = theme.text or Color(225, 238, 238)
        return accent, text
    end

    local function DrawWeaponConfigPanel(x, y, w, h, radius, color, outline)
        if lia.derma.SHAPE_IOS then
            lia.derma.rect(x, y, w, h):Rad(radius or 6):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
            if outline then lia.derma.rect(x, y, w, h):Rad(radius or 6):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
            return
        end

        draw.RoundedBox(radius or 6, x, y, w, h, color)
        if outline then
            surface.SetDrawColor(outline)
            surface.DrawOutlinedRect(x, y, w, h, 1)
        end
    end

    local function GetWeaponDisplayName(className, weaponTable, overrideData)
        local value = overrideData and overrideData.name or weaponTable.PrintName or className
        return tostring(tostring(value))
    end

    local function GetWeaponItemCategory(weaponTable, overrideData)
        return tostring(overrideData and overrideData.category or weaponTable.Category or "Weapons")
    end

    local function NormalizeFilter(value)
        return string.Trim(tostring(value or "")):lower()
    end

    local function ApplyTextEntryStyle(entry, numeric)
        local accent = GetWeaponConfigTheme()
        entry:SetFont("LiliaFont.18")
        entry:SetTextColor(Color(230, 239, 239))
        entry:SetCursorColor(accent)
        entry:SetPaintBackground(false)
        entry:SetPaintBackground(false)
        entry:SetPaintBorderEnabled(false)
        if numeric then entry:SetNumeric(true) end
        entry.Paint = function(s, w, h)
            local activeAccent = GetWeaponConfigTheme()
            local borderAlpha = s:HasFocus() and 110 or s:IsHovered() and 80 or 48
            local fill = s:HasFocus() and Color(12, 30, 35, 240) or Color(9, 24, 29, 235)
            DrawWeaponConfigPanel(0, 0, w, h, 5, fill, Color(activeAccent.r, activeAccent.g, activeAccent.b, borderAlpha))
            s:DrawTextEntryText(Color(230, 239, 239), activeAccent, Color(230, 239, 239))
        end
    end

    local function ApplyButtonStyle(button, danger, active)
        button:SetText("")
        button.Paint = function(s, w, h)
            local accent, textColor = GetWeaponConfigTheme()
            local color = danger and Color(210, 60, 60) or accent
            local hovered = s:IsHovered()
            local fill
            if danger then
                fill = hovered and Color(70, 18, 20, 220) or Color(30, 10, 12, 205)
            elseif active then
                fill = Color(accent.r, accent.g, accent.b, hovered and 48 or 34)
            else
                fill = hovered and Color(16, 34, 40, 230) or Color(9, 24, 29, 225)
            end

            DrawWeaponConfigPanel(0, 0, w, h, 6, fill, Color(color.r, color.g, color.b, hovered and 150 or 90))
            draw.SimpleText(s._label or "", "LiliaFont.18", w * 0.5, h * 0.5, danger and Color(255, 95, 95) or textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local function CreateSearchBox(parent, placeholder)
        local box = parent:Add("DTextEntry")
        box:SetTall(42)
        if box.SetPlaceholderText then box:SetPlaceholderText(placeholder or "") end
        box:SetUpdateOnType(true)
        ApplyTextEntryStyle(box)
        return box
    end

    local function CommitWeaponOverride(className, key, value)
        net.Start("liaWeaponOverrideUpdate")
        net.WriteString(className)
        net.WriteString(key)
        net.WriteType(value)
        net.SendToServer()
        lia.item.WeaponOverrides[className] = lia.item.WeaponOverrides[className] or {}
        lia.item.WeaponOverrides[className][key] = value
    end

    local function CommitRuntimeOverride(className, dotPath, value)
        net.Start("liaWeaponRuntimeOverrideUpdate")
        net.WriteString(className)
        net.WriteString(dotPath)
        net.WriteString(value)
        net.SendToServer()
        lia.item.WeaponRuntimeOverrides[className] = lia.item.WeaponRuntimeOverrides[className] or {}
        lia.item.WeaponRuntimeOverrides[className][dotPath] = value
    end

    hook.Add("PopulateConfigurationButtons", "liaWeaponItemsConfig", function(pages)
        pages[#pages + 1] = {
            name = "Weapon Items Config",
            shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
            drawFunc = function(parent)
                parent:Clear()
                parent:DockPadding(0, 0, 0, 0)
                local state = {
                    selectedClass = nil,
                    selectedWeapon = nil,
                    listButtons = {},
                    itemFields = {},
                    runtimeFields = {},
                    dirtyItem = {},
                    dirtyRuntime = {},
                    category = "__all"
                }

                local function GetDirtyCount()
                    local count = 0
                    for _ in pairs(state.dirtyItem) do
                        count = count + 1
                    end

                    for _ in pairs(state.dirtyRuntime) do
                        count = count + 1
                    end
                    return count
                end

                local function MarkItemDirty(key)
                    state.dirtyItem[key] = true
                end

                local function MarkRuntimeDirty(key)
                    state.dirtyRuntime[key] = true
                end

                local function RegisterItemField(key, getter, numeric)
                    state.itemFields[key] = {
                        getValue = getter,
                        numeric = numeric
                    }
                end

                local function RegisterRuntimeField(key, getter)
                    state.runtimeFields[key] = {
                        getValue = getter
                    }
                end

                local shell = parent:Add("DPanel")
                shell:Dock(FILL)
                shell.Paint = function() end
                local header = shell:Add("DPanel")
                header:Dock(TOP)
                header:SetTall(76)
                header.Paint = function(_, w)
                    local _, textColor = GetWeaponConfigTheme()
                    draw.SimpleText("Weapon Items Config", "LiliaFont.30", 8, 4, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText("Manage generated weapon items and runtime SWEP overrides.", "LiliaFont.17", 8, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    local accent = GetWeaponConfigTheme()
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 60)
                    surface.DrawRect(8, 72, w - 16, 1)
                end

                local toolbar = shell:Add("DPanel")
                toolbar:Dock(TOP)
                toolbar:SetTall(42)
                toolbar:DockMargin(0, 0, 0, 12)
                toolbar.Paint = function() end
                local dirtyBadge = toolbar:Add("DPanel")
                dirtyBadge:Dock(RIGHT)
                dirtyBadge:SetWide(150)
                dirtyBadge.Paint = function(_, w, h)
                    local accent, textColor = GetWeaponConfigTheme()
                    local dirtyCount = GetDirtyCount()
                    DrawWeaponConfigPanel(0, 0, w, h, 5, Color(9, 24, 29, 235), Color(accent.r, accent.g, accent.b, dirtyCount > 0 and 95 or 55))
                    local dotColor = dirtyCount > 0 and accent or Color(120, 136, 140)
                    draw.RoundedBox(4, 12, math.floor(h * 0.5) - 4, 8, 8, Color(dotColor.r, dotColor.g, dotColor.b, 255))
                    draw.SimpleText(dirtyCount > 0 and dirtyCount .. " Modified" or "No Changes", "LiliaFont.18", w * 0.5 + 8, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local categoryFilter = toolbar:Add("DComboBox")
                categoryFilter:Dock(RIGHT)
                categoryFilter:SetWide(164)
                categoryFilter:DockMargin(10, 0, 10, 0)
                categoryFilter:SetValue("All Categories")
                categoryFilter:SetFont("LiliaFont.18")
                categoryFilter:SetTextColor(Color(230, 239, 239))
                categoryFilter.Paint = function(s, w, h)
                    local accent = GetWeaponConfigTheme()
                    DrawWeaponConfigPanel(0, 0, w, h, 5, Color(9, 24, 29, 235), Color(accent.r, accent.g, accent.b, s:IsHovered() and 86 or 50))
                    draw.SimpleText(s:GetValue(), "LiliaFont.18", 14, h * 0.5, Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    draw.SimpleText("▾", "LiliaFont.18", w - 18, h * 0.5, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                categoryFilter:AddChoice("All Categories", "__all", true)
                local searchBar = CreateSearchBox(toolbar, "Search Weapons...")
                searchBar:Dock(FILL)
                local body = shell:Add("DPanel")
                body:Dock(FILL)
                body.Paint = function() end
                local left = body:Add("DPanel")
                left:Dock(LEFT)
                left:SetWide(math.Clamp(ScrW() * 0.18, 272, 330))
                left:DockMargin(0, 0, 12, 0)
                left:DockPadding(8, 8, 8, 8)
                left.Paint = function(_, w, h)
                    local accent = GetWeaponConfigTheme()
                    DrawWeaponConfigPanel(0, 0, w, h, 7, Color(5, 18, 23, 218), Color(accent.r, accent.g, accent.b, 65))
                end

                local weaponList = left:Add("liaScrollPanel")
                weaponList:Dock(FILL)
                weaponList.Paint = function() end
                local right = body:Add("DPanel")
                right:Dock(FILL)
                right:DockPadding(0, 0, 0, 0)
                right.Paint = function(_, w, h)
                    local accent = GetWeaponConfigTheme()
                    DrawWeaponConfigPanel(0, 0, w, h, 7, Color(5, 18, 23, 218), Color(accent.r, accent.g, accent.b, 65))
                end

                local editorHeader = right:Add("DPanel")
                editorHeader:Dock(TOP)
                editorHeader:SetTall(84)
                editorHeader:DockMargin(12, 12, 12, 0)
                editorHeader.Paint = function(_, w, h)
                    local accent, textColor = GetWeaponConfigTheme()
                    local className = state.selectedClass or ""
                    local weaponTable = state.selectedWeapon or {}
                    local overrideData = lia.item.WeaponOverrides[className] or {}
                    local title = className ~= "" and GetWeaponDisplayName(className, weaponTable, overrideData) or "No Weapon Selected"
                    local category = className ~= "" and GetWeaponItemCategory(weaponTable, overrideData) or ""
                    draw.SimpleText(title, "LiliaFont.28", 12, 10, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(className ~= "" and className or "Select a weapon from the list.", "LiliaFont.17", 12, 43, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    if category ~= "" then
                        local tw = select(1, surface.GetTextSize(title))
                        draw.SimpleText(category, "LiliaFont.16", 20 + tw, 16, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end

                    surface.SetDrawColor(accent.r, accent.g, accent.b, 58)
                    surface.DrawRect(0, h - 1, w, 1)
                end

                local editorScroll = right:Add("liaScrollPanel")
                editorScroll:Dock(FILL)
                editorScroll:DockMargin(12, 8, 12, 0)
                editorScroll.Paint = function() end
                local footer = right:Add("DPanel")
                footer:Dock(BOTTOM)
                footer:SetTall(58)
                footer:DockMargin(12, 10, 12, 12)
                footer.Paint = function(_, w, h)
                    local accent = GetWeaponConfigTheme()
                    surface.SetDrawColor(accent.r, accent.g, accent.b, 40)
                    surface.DrawRect(0, 0, w, 1)
                    local dirtyCount = GetDirtyCount()
                    local statusText = dirtyCount > 0 and dirtyCount .. " modified" or "No changes"
                    draw.SimpleText(statusText .. "  |  Changes save when you press Save Changes.", "LiliaFont.17", 0, h * 0.5, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end

                local saveButton = footer:Add("DButton")
                saveButton:Dock(RIGHT)
                saveButton:SetWide(170)
                saveButton:DockMargin(10, 10, 0, 10)
                saveButton._label = "Save Changes"
                ApplyButtonStyle(saveButton, false, true)
                local cancelButton = footer:Add("DButton")
                cancelButton:Dock(RIGHT)
                cancelButton:SetWide(118)
                cancelButton:DockMargin(10, 10, 0, 10)
                cancelButton._label = "Reset View"
                ApplyButtonStyle(cancelButton)
                local resetButton = footer:Add("DButton")
                resetButton:Dock(RIGHT)
                resetButton:SetWide(176)
                resetButton:DockMargin(10, 10, 0, 10)
                resetButton._label = "Reset Runtime"
                ApplyButtonStyle(resetButton)
                local function CreateSectionHeader(parentPanel, title)
                    local headerPanel = parentPanel:Add("DPanel")
                    headerPanel:Dock(TOP)
                    headerPanel:SetTall(26)
                    headerPanel:DockMargin(0, 0, 0, 0)
                    headerPanel.Paint = function(_, w, h)
                        local accent = GetWeaponConfigTheme()
                        draw.SimpleText(string.upper(title), "LiliaFont.17", 12, h * 0.5, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        surface.SetDrawColor(accent.r, accent.g, accent.b, 78)
                        surface.DrawRect(0, h - 1, w, 1)
                    end
                    return headerPanel
                end

                local function CreateSectionBlock(parentPanel, title)
                    local block = parentPanel:Add("DPanel")
                    block:Dock(TOP)
                    block:DockMargin(0, 0, 0, 14)
                    block.Paint = function(_, w, h)
                        local accent = GetWeaponConfigTheme()
                        DrawWeaponConfigPanel(0, 0, w, h, 6, Color(6, 17, 22, 205), Color(accent.r, accent.g, accent.b, 36))
                    end

                    local container = block:Add("DPanel")
                    container:Dock(FILL)
                    container:DockPadding(12, 12, 12, 8)
                    container.Paint = function() end
                    CreateSectionHeader(container, title)
                    local list = container:Add("DPanel")
                    list:Dock(FILL)
                    list.Paint = function() end
                    block.list = list
                    block.PerformLayout = function(s, w)
                        local y = 0
                        for _, child in ipairs(list:GetChildren()) do
                            local _, ch = child:GetSize()
                            y = y + ch
                        end

                        local paddingTop = 12 + 26
                        local paddingBottom = 8
                        s:SetTall(paddingTop + paddingBottom + y)
                    end
                    return block
                end

                local function CreateSwitch(parentPanel, value, onChanged)
                    local button = parentPanel:Add("DButton")
                    button:SetText("")
                    button:SetSize(44, 24)
                    button._value = tobool(value)
                    button.Paint = function(s, w, h)
                        local accent = GetWeaponConfigTheme()
                        local fill = s._value and Color(accent.r, accent.g, accent.b, 180) or Color(45, 60, 68, 220)
                        draw.RoundedBox(h * 0.5, 0, 0, w, h, fill)
                        local knobSize = h - 6
                        local knobX = s._value and w - knobSize - 3 or 3
                        draw.RoundedBox(knobSize * 0.5, knobX, 3, knobSize, knobSize, Color(235, 240, 240))
                    end

                    button.DoClick = function(s)
                        s._value = not s._value
                        onChanged(s._value)
                    end
                    return button
                end

                local function CreateValueEntry(parentPanel, value, width, numeric, onChanged)
                    local entry = parentPanel:Add("DTextEntry")
                    entry:SetWide(width or 280)
                    entry:SetTall(30)
                    entry:SetUpdateOnType(true)
                    ApplyTextEntryStyle(entry, numeric)
                    if value ~= nil then entry:SetValue(tostring(value)) end
                    entry.OnValueChange = function(s, val) onChanged(val, s) end
                    return entry
                end

                local function CreateValueCombo(parentPanel, value, choices, onChanged)
                    local combo = parentPanel:Add("DComboBox")
                    combo:SetWide(220)
                    combo:SetTall(30)
                    combo:SetFont("LiliaFont.18")
                    combo:SetTextColor(Color(230, 239, 239))
                    combo:SetValue(tostring(value or ""))
                    combo.Paint = function(s, w, h)
                        local accent = GetWeaponConfigTheme()
                        DrawWeaponConfigPanel(0, 0, w, h, 5, Color(9, 24, 29, 235), Color(accent.r, accent.g, accent.b, s:IsHovered() and 86 or 50))
                        draw.SimpleText(s:GetValue(), "LiliaFont.18", 12, h * 0.5, Color(230, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        draw.SimpleText("▾", "LiliaFont.18", w - 16, h * 0.5, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local seen = {}
                    for _, choice in ipairs(choices or {}) do
                        if isstring(choice) and choice ~= "" and not seen[choice] then
                            seen[choice] = true
                            combo:AddChoice(choice, choice, choice == value)
                        end
                    end

                    if isstring(value) and value ~= "" and not seen[value] then combo:AddChoice(value, value, true) end
                    combo.OnSelect = function(_, _, selected, data)
                        combo:SetValue(selected)
                        onChanged(data or selected)
                    end
                    return combo
                end

                local function CreateSettingRow(parentPanel, title, description, builder)
                    local row = parentPanel:Add("DPanel")
                    row:Dock(TOP)
                    row:SetTall(52)
                    row.Paint = function(_, w, h)
                        surface.SetDrawColor(255, 255, 255, 10)
                        surface.DrawRect(0, h - 1, w, 1)
                        draw.SimpleText(title, "LiliaFont.18", 12, 10, Color(228, 239, 239), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(description, "LiliaFont.16", 12, 30, Color(145, 166, 168), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end

                    local controlWrap = row:Add("DPanel")
                    controlWrap:Dock(RIGHT)
                    controlWrap:SetWide(390)
                    controlWrap.Paint = function() end
                    row.PerformLayout = function(_, w, h) controlWrap:SetWide(math.min(390, math.floor(w * 0.42))) end
                    local control = builder(controlWrap)
                    controlWrap.PerformLayout = function(s, w, h)
                        if not IsValid(control) then return end
                        local cw, ch = control:GetSize()
                        control:SetPos(w - cw, math.floor((h - ch) * 0.5))
                    end
                    return row, controlWrap
                end

                local allWeapons = {}
                local categories = {}
                local BuildEditor, SelectWeapon, PopulateWeaponList
                local function BuildWeaponCache()
                    allWeapons = {}
                    categories = {}
                    for _, wep in ipairs(weapons.GetList()) do
                        local className = wep.ClassName
                        if not className or className:find("_base") or lia.item.WeaponsBlackList and lia.item.WeaponsBlackList[className] then continue end
                        local overrideData = lia.item.WeaponOverrides[className] or {}
                        local category = GetWeaponItemCategory(wep, overrideData)
                        categories[category] = true
                        allWeapons[#allWeapons + 1] = {
                            className = className,
                            weapon = wep,
                            name = GetWeaponDisplayName(className, wep, overrideData),
                            category = category
                        }
                    end

                    table.sort(allWeapons, function(a, b) return a.name:lower() < b.name:lower() end)
                end

                local function RebuildCategoryFilter()
                    local selectedValue = state.category or "__all"
                    categoryFilter:Clear()
                    categoryFilter:AddChoice("All Categories", "__all", selectedValue == "__all")
                    local sorted = {}
                    for category in pairs(categories) do
                        sorted[#sorted + 1] = category
                    end

                    table.sort(sorted)
                    for _, category in ipairs(sorted) do
                        categoryFilter:AddChoice(category, category, selectedValue == category)
                    end

                    categoryFilter:SetValue(selectedValue == "__all" and "All Categories" or selectedValue)
                end

                local function SaveCurrent()
                    if not state.selectedClass then return end
                    for key, data in pairs(state.itemFields) do
                        if state.dirtyItem[key] and isfunction(data.getValue) then
                            local value = data.getValue()
                            if data.numeric then value = tonumber(value) end
                            CommitWeaponOverride(state.selectedClass, key, value)
                        end
                    end

                    for dotPath, data in pairs(state.runtimeFields) do
                        if state.dirtyRuntime[dotPath] and isfunction(data.getValue) then CommitRuntimeOverride(state.selectedClass, dotPath, tostring(data.getValue() or "")) end
                    end

                    state.dirtyItem = {}
                    state.dirtyRuntime = {}
                    BuildWeaponCache()
                    RebuildCategoryFilter()
                    BuildEditor()
                    PopulateWeaponList()
                end

                BuildEditor = function()
                    editorScroll:Clear()
                    state.itemFields = {}
                    state.runtimeFields = {}
                    state.dirtyItem = {}
                    state.dirtyRuntime = {}
                    if not state.selectedClass or not state.selectedWeapon then
                        local empty = editorScroll:Add("DPanel")
                        empty:Dock(TOP)
                        empty:SetTall(120)
                        empty.Paint = function(_, w, h) draw.SimpleText("Select a weapon from the list to edit its item settings.", "LiliaFont.20", w * 0.5, h * 0.5, Color(155, 178, 179), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                        return
                    end

                    local className = state.selectedClass
                    local weaponTable = state.selectedWeapon
                    local overrideData = lia.item.WeaponOverrides[className] or {}
                    local runtimeOverrides = lia.item.WeaponRuntimeOverrides[className] or {}
                    local liveWeapon = weapons.GetStored(className) or weaponTable
                    local categoryChoices = {}
                    for category in pairs(categories) do
                        categoryChoices[#categoryChoices + 1] = category
                    end

                    table.sort(categoryChoices)
                    local function RuntimeValue(dotPath)
                        local default = liveWeapon and lia.item.getRuntimeValue(liveWeapon, dotPath)
                        return runtimeOverrides[dotPath] ~= nil and runtimeOverrides[dotPath] or default
                    end

                    local overview = CreateSectionBlock(editorScroll, "Item Settings")
                    CreateSettingRow(overview.list, "Name", "Display name shown in the weapon item list.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.name or weaponTable.PrintName or className, 300, false, function(value) MarkItemDirty("name") end)
                        RegisterItemField("name", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(overview.list, "Description", "Description shown when viewing the item.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.desc or overrideData.description or weaponTable.Instructions or "A Weapon.", 300, false, function(value) MarkItemDirty("desc") end)
                        RegisterItemField("desc", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(overview.list, "Category", "Item category used by the generated item.", function(parentPanel)
                        local combo = CreateValueCombo(parentPanel, overrideData.category or GetWeaponItemCategory(weaponTable, overrideData), categoryChoices, function(value) MarkItemDirty("category") end)
                        RegisterItemField("category", function() return combo:GetValue() end)
                        return combo
                    end)

                    CreateSettingRow(overview.list, "Price", "Purchase price used by vendors or stores.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.price or 0, 160, true, function(value) MarkItemDirty("price") end)
                        RegisterItemField("price", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    CreateSettingRow(overview.list, "Width", "Inventory width of the generated item.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.width or 2, 120, true, function(value) MarkItemDirty("width") end)
                        RegisterItemField("width", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    CreateSettingRow(overview.list, "Height", "Inventory height of the generated item.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.height or 1, 120, true, function(value) MarkItemDirty("height") end)
                        RegisterItemField("height", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    local models = CreateSectionBlock(editorScroll, "Model / Appearance")
                    CreateSettingRow(models.list, "World Model", "Model shown when the item is dropped or displayed.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.model or weaponTable.WorldModel or "", 360, false, function(value) MarkItemDirty("model") end)
                        RegisterItemField("model", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(models.list, "View Model", "Optional first-person view model reference.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.viewModel or weaponTable.ViewModel or "", 360, false, function(value) MarkItemDirty("viewModel") end)
                        RegisterItemField("viewModel", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(models.list, "Model Scale", "Scale multiplier for the generated item model.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.modelScale or 1, 120, true, function(value) MarkItemDirty("modelScale") end)
                        RegisterItemField("modelScale", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    CreateSettingRow(models.list, "Weapon Category", "SWEP category shown for this weapon.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.weaponCategory or weaponTable.Category or "", 260, false, function(value) MarkItemDirty("weaponCategory") end)
                        RegisterItemField("weaponCategory", function() return entry:GetValue() end)
                        return entry
                    end)

                    local runtime = CreateSectionBlock(editorScroll, "Runtime SWEP Stats")
                    local runtimeRows = {{"Primary Damage", "Primary.Damage", "Primary damage value applied at runtime."}, {"Primary Shots", "Primary.NumShots", "Primary shot count fired each attack."}, {"Primary Recoil", "Primary.Recoil", "Primary recoil value used by the weapon."}, {"Primary Cone", "Primary.Cone", "Primary spread cone value."}, {"Primary Delay", "Primary.Delay", "Primary fire delay between shots."}, {"Secondary Damage", "Secondary.Damage", "Secondary damage value applied at runtime."}, {"Secondary Shots", "Secondary.NumShots", "Secondary shot count fired each attack."}, {"Secondary Delay", "Secondary.Delay", "Secondary fire delay between shots."}}
                    for _, rowData in ipairs(runtimeRows) do
                        local label, dotPath, desc = rowData[1], rowData[2], rowData[3]
                        CreateSettingRow(runtime.list, label, desc, function(parentPanel)
                            local entry = CreateValueEntry(parentPanel, RuntimeValue(dotPath) or "", 180, true, function(value) MarkRuntimeDirty(dotPath) end)
                            RegisterRuntimeField(dotPath, function() return entry:GetValue() end)
                            return entry
                        end)
                    end

                    local advanced = CreateSectionBlock(editorScroll, "Advanced")
                    CreateSettingRow(advanced.list, "Base", "Optional base item override for this weapon item.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.base or "", 220, false, function(value) MarkItemDirty("base") end)
                        RegisterItemField("base", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(advanced.list, "Hold Type", "SWEP hold type override.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.holdType or weaponTable.HoldType or "", 180, false, function(value) MarkItemDirty("holdType") end)
                        RegisterItemField("holdType", function() return entry:GetValue() end)
                        return entry
                    end)

                    CreateSettingRow(advanced.list, "Clip Size", "Primary clip size stored on the item definition.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.clipSize or RuntimeValue("Primary.ClipSize") or "", 120, true, function(value) MarkItemDirty("clipSize") end)
                        RegisterItemField("clipSize", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    CreateSettingRow(advanced.list, "Default Ammo", "Default ammo amount given with the item.", function(parentPanel)
                        local entry = CreateValueEntry(parentPanel, overrideData.defaultAmmo or weaponTable.Primary and weaponTable.Primary.DefaultClip or "", 120, true, function(value) MarkItemDirty("defaultAmmo") end)
                        RegisterItemField("defaultAmmo", function() return entry:GetValue() end, true)
                        return entry
                    end)

                    CreateSettingRow(advanced.list, "Auto Equip", "Automatically equips the weapon after use.", function(parentPanel)
                        local switch = CreateSwitch(parentPanel, overrideData.autoEquip == nil and false or overrideData.autoEquip, function(value) MarkItemDirty("autoEquip") end)
                        RegisterItemField("autoEquip", function() return switch._value end)
                        return switch
                    end)

                    CreateSettingRow(advanced.list, "Allow Drop", "Whether the generated item can be dropped.", function(parentPanel)
                        local switch = CreateSwitch(parentPanel, overrideData.allowDrop == nil and true or overrideData.allowDrop, function(value) MarkItemDirty("allowDrop") end)
                        RegisterItemField("allowDrop", function() return switch._value end)
                        return switch
                    end)

                    CreateSettingRow(advanced.list, "Allow Trade", "Whether the generated item can be traded.", function(parentPanel)
                        local switch = CreateSwitch(parentPanel, overrideData.allowTrade == nil and true or overrideData.allowTrade, function(value) MarkItemDirty("allowTrade") end)
                        RegisterItemField("allowTrade", function() return switch._value end)
                        return switch
                    end)

                    CreateSettingRow(advanced.list, "Is Unique", "Prevents multiple copies from stacking logically.", function(parentPanel)
                        local switch = CreateSwitch(parentPanel, overrideData.isUnique == nil and false or overrideData.isUnique, function(value) MarkItemDirty("isUnique") end)
                        RegisterItemField("isUnique", function() return switch._value end)
                        return switch
                    end)
                end

                SelectWeapon = function(className, weaponTable)
                    state.selectedClass = className
                    state.selectedWeapon = weaponTable
                    for key, button in pairs(state.listButtons) do
                        if IsValid(button) then button._selected = key == className end
                    end

                    BuildEditor()
                end

                PopulateWeaponList = function()
                    weaponList:Clear()
                    state.listButtons = {}
                    local filter = NormalizeFilter(searchBar:GetValue())
                    local filtered = {}
                    for _, item in ipairs(allWeapons) do
                        if state.category ~= "__all" and item.category ~= state.category then continue end
                        local haystack = (item.name .. " " .. item.className .. " " .. item.category):lower()
                        if filter ~= "" and not haystack:find(filter, 1, true) then continue end
                        filtered[#filtered + 1] = item
                    end

                    local totalVisible = #filtered
                    local summary = weaponList:Add("DPanel")
                    summary:Dock(TOP)
                    summary:SetTall(56)
                    summary:DockMargin(0, 0, 0, 8)
                    summary.Paint = function(_, w, h)
                        local accent, textColor = GetWeaponConfigTheme()
                        DrawWeaponConfigPanel(0, 0, w, h, 5, Color(7, 21, 26, 228), Color(accent.r, accent.g, accent.b, 46))
                        draw.SimpleText("All Weapons", "LiliaFont.20", 14, 12, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(totalVisible .. " weapon" .. (totalVisible == 1 and "" or "s"), "LiliaFont.16", 14, 34, Color(145, 166, 168), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end

                    local firstMatch
                    local selectedVisible = false
                    for _, item in ipairs(filtered) do
                        firstMatch = firstMatch or item
                        if item.className == state.selectedClass then selectedVisible = true end
                        local row = weaponList:Add("DButton")
                        row:Dock(TOP)
                        row:SetTall(60)
                        row:DockMargin(0, 0, 0, 6)
                        row:SetText("")
                        row._selected = item.className == state.selectedClass
                        row.Paint = function(s, w, h)
                            local accent, textColor = GetWeaponConfigTheme()
                            local hovered = s:IsHovered()
                            local fill = s._selected and Color(accent.r, accent.g, accent.b, 35) or hovered and Color(12, 30, 35, 225) or Color(7, 21, 26, 225)
                            DrawWeaponConfigPanel(0, 0, w, h, 5, fill, Color(accent.r, accent.g, accent.b, s._selected and 125 or hovered and 68 or 38))
                            draw.SimpleText(item.name, "LiliaFont.19", 14, 12, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                            draw.SimpleText(item.category, "LiliaFont.16", 14, 34, Color(145, 166, 168), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        end

                        row.DoClick = function() SelectWeapon(item.className, item.weapon) end
                        state.listButtons[item.className] = row
                    end

                    if not selectedVisible and firstMatch then SelectWeapon(firstMatch.className, firstMatch.weapon) end
                    if not firstMatch then
                        state.selectedClass = nil
                        state.selectedWeapon = nil
                        BuildEditor()
                        local empty = weaponList:Add("DPanel")
                        empty:Dock(TOP)
                        empty:SetTall(72)
                        empty.Paint = function(_, w, h) draw.SimpleText("No weapons found.", "LiliaFont.18", w * 0.5, h * 0.5, Color(155, 178, 179), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
                    end
                end

                saveButton.DoClick = SaveCurrent
                cancelButton.DoClick = function() BuildEditor() end
                resetButton.DoClick = function()
                    if not state.selectedClass then return end
                    net.Start("liaWeaponRuntimeOverrideReset")
                    net.WriteString(state.selectedClass)
                    net.SendToServer()
                    lia.item.WeaponRuntimeOverrides[state.selectedClass] = nil
                    BuildEditor()
                end

                searchBar.OnValueChange = function() PopulateWeaponList() end
                categoryFilter.OnSelect = function(_, _, _, data)
                    state.category = data or "__all"
                    PopulateWeaponList()
                end

                BuildWeaponCache()
                RebuildCategoryFilter()
                PopulateWeaponList()
            end
        }
    end)
end

lia.item.registerItem("lia_ammobox", "base_entities", {
    name = "Ammo Box Crate",
    desc = "A placeable ammo box that refills the weapon you are holding.",
    model = "models/items/boxsrounds.mdl",
    category = "entities",
    width = 1,
    height = 1,
    entityid = "lia_ammobox"
})

lia.item.registerItem("lia_backpack", "base_bags", {
    name = "Backpack",
    desc = "A medium-sized backpack with enough space for extra supplies.",
    model = "models/props_c17/SuitCase_Passenger_Physics.mdl",
    category = "storage",
    width = 2,
    height = 2,
    invWidth = 4,
    invHeight = 4
})

local RUNTIME_SNAPSHOT_PATHS = {"Primary.Damage", "Primary.NumShots", "Primary.Recoil", "Primary.Cone", "Primary.Delay", "Primary.ClipSize", "Secondary.Damage", "Secondary.NumShots", "Secondary.Recoil", "Secondary.Cone", "Secondary.Delay",}
hook.Add("InitPostEntity", "liaWeaponRuntimeDefaults", function()
    lia.item.defaultRuntimeValues = {}
    for _, wep in ipairs(weapons.GetList()) do
        local cls = wep.ClassName
        if not cls then continue end
        lia.item.defaultRuntimeValues[cls] = {}
        for _, path in ipairs(RUNTIME_SNAPSHOT_PATHS) do
            local val = lia.item.getRuntimeValue(wep, path)
            if val ~= nil then lia.item.defaultRuntimeValues[cls][path] = val end
        end
    end
end)