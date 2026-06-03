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
        tip = "dropTip",
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
                if err == "noFit" then
                    client:notifyErrorLocalized("itemNoFit", item:getWidth(), item:getHeight())
                else
                    client:notifyErrorLocalized(err)
                end

                client.itemTakeTransaction = nil
                d:reject()
            end)
            return d
        end,
        onCanRun = function(item) return IsValid(item.entity) end
    },
    rotate = {
        tip = "rotateTip",
        icon = "icon16/arrow_rotate_clockwise.png",
        onRun = function(item)
            local inv = lia.item.getInv(item.invID)
            local x, y = item:getData("x"), item:getData("y")
            local newRot = not item:getData("rotated", false)
            if inv and x and y then
                local w = newRot and (item.height or 1) or item.width or 1
                local h = newRot and (item.width or 1) or item.height or 1
                local invW, invH = inv:getSize()
                if x < 1 or y < 1 or x + w - 1 > invW or y + h - 1 > invH then
                    item.player:notifyErrorLocalized("itemNoFit", w, h)
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
                                item.player:notifyErrorLocalized("itemNoFit", w, h)
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
        tip = "giveForwardTip",
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
                client:notifyLocalized("noFit")
                return false
            end

            target:requestBinaryQuestion(L("itemGiveRequest", client:Name(), item.name), "@yes", "@no", function(choice)
                if choice == 0 then
                    inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
                    client:setAction(L("givingItemTo", item.name, target:Name()), lia.config.get("ItemGiveSpeed", 6))
                    target:setAction(L("givingYouItem", client:Name(), item.name), lia.config.get("ItemGiveSpeed", 6))
                    client:doStaredAction(target, function()
                        local res = hook.Run("HandleItemTransferRequest", client, item:getID(), nil, nil, targetInv:getID())
                        if not res then return end
                        res:next(function()
                            if not IsValid(client) then return end
                            if istable(res) and isstring(res.error) then return client:notifyErrorLocalized(res.error) end
                            client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
                            client:doGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_GESTURE_ITEM_PLACE, true)
                        end)
                    end, lia.config.get("ItemGiveSpeed", 6), function() client:setAction() end, 100)
                else
                    client:notifyLocalized("itemGiveDeclined", target:Name())
                    target:notifyLocalized("itemGiveDeclinedSelf", client:Name())
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
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
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
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item
end

function lia.item.getItemDataByID(itemID)
    assert(isnumber(itemID), L("itemIDNumberRequired"))
    local item = lia.item.instances[itemID]
    if not item then return nil, L("itemNotFound") end
    return item.data
end

function lia.item.load(path, baseID, isBaseItem)
    local uniqueID = path:match("sh_([_%w]+)%.lua") or path:match("([_%w]+)%.lua")
    if uniqueID then
        uniqueID = (isBaseItem and "base_" or "") .. uniqueID
        lia.item.register(uniqueID, baseID, isBaseItem, path)
    elseif path:find("%.txt$") then
        local formatted = path:gsub("\\", "/"):lower()
        if not formatted:find("^lilia/") then lia.error("[Lilia] " .. L("textFileLuaRequired", path) .. "\n") end
    else
        lia.error("[Lilia] " .. L("invalidItemNaming", path) .. "\n")
    end
end

function lia.item.isItem(object)
    return istable(object) and object.isItem
end

function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

function lia.item.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.item.rarities[name] = color
end

function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
    assert(isstring(uniqueID), L("itemUniqueIDString"))
    local baseTable = lia.item.base[baseID] or lia.meta.item
    if baseID then assert(baseTable, L("itemBaseNotFound", uniqueID, baseID)) end
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
        ITEM.desc = "@noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "@misc"
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
        ITEM.desc = "@noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "@misc"
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
    if not istable(itemDef) then return end
    for funcName, funcTable in pairs(itemDef.functions or {}) do
        if isstring(funcTable.name) then
            funcTable.name = lia.lang.resolveToken(funcTable.name)
        else
            funcTable.name = lia.lang.resolveToken("@" .. funcName)
        end

        if isstring(funcTable.tip) then funcTable.tip = lia.lang.resolveToken(funcTable.tip) end
    end

    if isstring(itemDef.name) then itemDef.name = lia.lang.resolveToken(itemDef.name) end
    if isstring(itemDef.desc) then itemDef.desc = lia.lang.resolveToken(itemDef.desc) end
    if isstring(itemDef.category) then itemDef.category = lia.lang.resolveToken(itemDef.category) end
end

function lia.item.registerItem(id, base, properties)
    assert(isstring(id), L("itemUniqueIDString"))
    if properties ~= nil and not istable(properties) then
        local errorMsg = string.format("properties must be a table or nil, got %s (type: %s)", tostring(properties), type(properties))
        lia.error(string.format("[Lilia] registerItem called with invalid properties for item '%s': %s\n", id, errorMsg))
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
    assert(isstring(uniqueID), L("itemUniqueIDString"))
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
    assert(isnumber(id), L("itemNonNumberID"))
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
        error("[Lilia] " .. L("unknownItem", tostring(uniqueID)) .. "\n")
    end
end

function lia.item.registerInv(invType, w, h)
    local GridInv = FindMetaTable("GridInv")
    assert(GridInv, L("gridInvNotFound"))
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
    assert(GridInv, L("gridInvNotFound"))
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
        assert(isnumber(itemID), L("itemIDNumberRequired"))
        assert(isstring(key), L("itemKeyString"))
        local item = lia.item.instances[itemID]
        if not item then return false, L("itemNotFound") end
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
            d:reject(L("invalidItemInstantiate", tostring(uniqueID)))
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

        local function onItemCreated(_, itemID)
            local item = lia.item.new(uniqueID, itemID)
            if item then
                item.data = itemData
                item.invID = index
                item.data.x = x
                item.data.y = y
                item.quantity = itemTable.maxQuantity
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
            quantity = itemTable.maxQuantity or 1
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
                lia.error(L("failedToSpawnItem", tostring(reason or L("unknownError"))))
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

lia.item.loadFromDir("lilia/gamemode/items")
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
                desc = override.desc or L("weaponsDesc"),
                category = override.category or isGrenade and L("itemCatGrenades") or L("weapons"),
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
                itemName = override.name or L("generatedArc9AmmoName", ammoType)
            elseif isArccwAmmo then
                ammoType = className:gsub("^arccw_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or L("generatedArccwAmmoName", ammoType)
            elseif isTfaAmmo then
                ammoType = className:gsub("^tfa_ammo_", ""):gsub("_", " "):lower():gsub("(%a)([%w_']*)", function(first, rest) return first:upper() .. rest end)
                itemName = override.name or L("generatedTfaAmmoName", ammoType)
            else
                itemName = override.name or className
                ammoType = className
            end

            local properties = {
                name = itemName,
                desc = override.desc or L("generatedAmmoBoxDesc", ammoType),
                category = override.category or L("itemCatAmmunition"),
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
            lia.error("[Lilia] Cannot override item '" .. tostring(uniqueID) .. "': item not found\n")
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
    local function CreateEntry(scroll, className, weaponTable, overrideData)
        local container = scroll:Add("DPanel")
        container:SetTall(50)
        container:Dock(TOP)
        container:DockMargin(5, 0, 0, 3)
        local expanded = false
        local expandedHeight = 660
        local header = container:Add("DPanel")
        header:Dock(TOP)
        header:SetTall(50)
        header.Paint = function(s, w, h)
            local theme = lia.color.theme
            local accent = theme.accent or theme.theme or Color(116, 185, 255)
            local headerBase = (theme and theme.button_hovered) or (theme and theme.button) or Color(60, 70, 85)
            lia.derma.rect(0, 0, w, h):Rad(6):Color(ColorAlpha(headerBase, 170)):Shape(lia.derma.SHAPE_IOS):Draw()
            lia.derma.rect(0, h - 2, w, 2):Color(ColorAlpha(accent, 150)):Draw()
            if s:IsHovered() then lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(255, 255, 255, 10)):Draw() end
        end

        header:SetCursor("hand")
        local nameLabel = header:Add("DLabel")
        nameLabel:Dock(LEFT)
        nameLabel:DockMargin(15, 0, 0, 0)
        nameLabel:SetFont("LiliaFont.25")
        nameLabel:SetText(L(weaponTable.PrintName or className))
        nameLabel:SizeToContents()
        nameLabel:SetTextColor(lia.color.theme.text)
        local expandBtn = header:Add("DLabel")
        expandBtn:Dock(RIGHT)
        expandBtn:DockMargin(0, 0, 15, 0)
        expandBtn:SetFont("LiliaFont.25")
        expandBtn:SetText("+")
        expandBtn:SizeToContents()
        expandBtn:SetTextColor(lia.color.theme.text)
        local content = container:Add("DPanel")
        content:Dock(FILL)
        content:DockMargin(10, 5, 10, 5)
        content:SetVisible(false)
        content.Paint = function() end
        header.OnMousePressed = function()
            expanded = not expanded
            container:SetTall(expanded and expandedHeight or 50)
            content:SetVisible(expanded)
            expandBtn:SetText(expanded and "-" or "+")
            scroll:InvalidateLayout(true)
        end

        local function AddField(label, key, default, isNum)
            local p = content:Add("DPanel")
            p:Dock(TOP)
            p:SetTall(35)
            p:DockMargin(0, 3, 0, 0)
            p.Paint = function() end
            local l = p:Add("DLabel")
            l:Dock(LEFT)
            l:SetWidth(100)
            l:SetText(label)
            l:SetFont("LiliaFont.18")
            l:SetTextColor(lia.color.theme.text)
            local entry = p:Add("liaEntry")
            entry:Dock(FILL)
            local val = overrideData[key] or default
            if val then entry:SetValue(tostring(val)) end
            entry.textEntry.OnEnter = function(s)
                local newValue = s:GetValue()
                if isNum then newValue = tonumber(newValue) end
                net.Start("liaWeaponOverrideUpdate")
                net.WriteString(className)
                net.WriteString(key)
                net.WriteType(newValue)
                net.SendToServer()
                overrideData[key] = newValue
            end
        end

        local defWidth = 2
        local defHeight = 1
        AddField(L("name"), "name", weaponTable.PrintName or className, false)
        AddField(L("desc"), "desc", L("weaponsDesc"), false)
        AddField(L("model"), "model", weaponTable.WorldModel or "models/props_c17/BriefCase001a.mdl", false)
        AddField(L("weaponItemWidth"), "width", defWidth, true)
        AddField(L("weaponItemHeight"), "height", defHeight, true)
        AddField(L("price"), "price", 500, true)
        AddField(L("Category"), "category", L("weapons"), false)
        local runtimeFields = {{"Primary.Damage", "Pri.Damage", true}, {"Primary.NumShots", "Pri.Shots", true}, {"Primary.Recoil", "Pri.Recoil", true}, {"Primary.Cone", "Pri.Cone", true}, {"Primary.Delay", "Pri.Delay", true}, {"Secondary.Damage", "Sec.Damage", true},}
        local sepPanel = content:Add("DPanel")
        sepPanel:Dock(TOP)
        sepPanel:SetTall(26)
        sepPanel:DockMargin(0, 8, 0, 4)
        sepPanel.Paint = function(s, w, h)
            draw.SimpleText("Runtime SWEP Stats", "LiliaFont.18b", 0, h * 0.5, lia.color.theme.text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            local accent = lia.color.theme.accent or lia.color.theme.theme or Color(116, 185, 255)
            surface.SetDrawColor(accent)
            surface.DrawLine(0, h - 1, w, h - 1)
        end

        local livewep = weapons.Get(className)
        local runtimeOverrides = lia.item.WeaponRuntimeOverrides[className] or {}
        local function AddRuntimeField(dotPath, label)
            local default = livewep and lia.item.getRuntimeValue(livewep, dotPath)
            local current = runtimeOverrides[dotPath] ~= nil and runtimeOverrides[dotPath] or default
            local p = content:Add("DPanel")
            p:Dock(TOP)
            p:SetTall(35)
            p:DockMargin(0, 3, 0, 0)
            p.Paint = function() end
            local l = p:Add("DLabel")
            l:Dock(LEFT)
            l:SetWidth(100)
            l:SetText(label)
            l:SetFont("LiliaFont.18")
            l:SetTextColor(lia.color.theme.text)
            local entry = p:Add("liaEntry")
            entry:Dock(FILL)
            if current ~= nil then entry:SetValue(tostring(current)) end
            entry.textEntry.OnEnter = function(s)
                local raw = s:GetValue()
                net.Start("liaWeaponRuntimeOverrideUpdate")
                net.WriteString(className)
                net.WriteString(dotPath)
                net.WriteString(raw)
                net.SendToServer()
                lia.item.WeaponRuntimeOverrides[className] = lia.item.WeaponRuntimeOverrides[className] or {}
                lia.item.WeaponRuntimeOverrides[className][dotPath] = raw
            end
        end

        for _, rf in ipairs(runtimeFields) do
            AddRuntimeField(rf[1], rf[2])
        end

        local resetBtn = content:Add("DButton")
        resetBtn:Dock(TOP)
        resetBtn:SetTall(30)
        resetBtn:DockMargin(0, 8, 0, 0)
        resetBtn:SetText("Reset Runtime Overrides")
        resetBtn:SetFont("LiliaFont.18")
        resetBtn.DoClick = function()
            net.Start("liaWeaponRuntimeOverrideReset")
            net.WriteString(className)
            net.SendToServer()
            lia.item.WeaponRuntimeOverrides[className] = nil
        end
    end

    hook.Add("PopulateConfigurationButtons", "liaWeaponItemsConfig", function(pages)
        pages[#pages + 1] = {
            name = L("weaponItemsConfig"),
            shouldShow = function() return hook.Run("CanPlayerModifyConfig", LocalPlayer()) ~= false end,
            drawFunc = function(parent)
                parent:Clear()
                local searchBar = parent:Add("liaEntry")
                searchBar:Dock(TOP)
                searchBar:DockMargin(10, 10, 10, 10)
                searchBar:SetTall(35)
                searchBar:SetPlaceholderText(L("searchWeapons"))
                local scroll = parent:Add("liaScrollPanel")
                scroll:Dock(FILL)
                local function Populate(filter)
                    scroll:Clear()
                    filter = filter and filter:lower() or ""
                    local weaponsList = weapons.GetList()
                    table.sort(weaponsList, function(a, b) return (a.PrintName or a.ClassName) < (b.PrintName or b.ClassName) end)
                    for _, wep in ipairs(weaponsList) do
                        local className = wep.ClassName
                        if not className or className:find("_base") or (lia.item.WeaponsBlackList and lia.item.WeaponsBlackList[className]) then continue end
                        local name = wep.PrintName or className
                        if filter ~= "" and not name:lower():find(filter, 1, true) and not className:lower():find(filter, 1, true) then continue end
                        local overrides = lia.item.WeaponOverrides[className] or {}
                        CreateEntry(scroll, className, wep, overrides)
                    end
                end

                searchBar.OnTextChanged = function(s) Populate(s:GetValue()) end
                Populate()
            end
        }
    end)
end

lia.item.registerItem("lia_ammobox", "base_entities", {
    name = "@liaAmmoBoxItemName",
    desc = "@liaAmmoBoxItemDesc",
    model = "models/items/boxsrounds.mdl",
    category = "entities",
    width = 1,
    height = 1,
    entityid = "lia_ammobox"
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
