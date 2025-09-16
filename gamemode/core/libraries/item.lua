lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.list = lia.item.list or {}
lia.item.instances = lia.item.instances or {}
lia.item.itemEntities = lia.item.itemEntities or {}
lia.item.inventories = lia.inventory.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
lia.item.WeaponOverrides = lia.item.WeaponOverrides or {}
lia.item.WeaponsBlackList = lia.item.WeaponsBlackList or {
    weapon_fists = true,
    weapon_medkit = true,
    gmod_camera = true,
    gmod_tool = true,
    adminstick = true,
    lia_hands = true,
    lia_keys = true
}

local DefaultFunctions = {
    drop = {
        tip = "dropTip",
        icon = "icon16/world.png",
        onRun = function(item)
            local client = item.player
            item:removeFromInventory(true):next(function() item:spawn(client) end)
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
                    if item.player and item.player.notifyLocalized then item.player:notifyErrorLocalized("itemNoFit", w, h) end
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
                                if item.player and item.player.notifyLocalized then item.player:notifyErrorLocalized("itemNoFit", w, h) end
                                return false
                            end
                        end
                    end
                end
            end

            item:setData("rotated", newRot)
            return false
        end,
        onCanRun = function(item) return not IsValid(item.entity) and item.width ~= item.height and not item:getData("equip", false) end
    },
    giveForward = {
        tip = "giveForwardTip",
        icon = "icon16/arrow_up.png",
        onRun = function(item)
            local function canTransferItemsFromInventoryUsingGiveForward(_, action, _)
                if action == "transfer" then return true end
            end

            local client = item.player
            local inv = client:getChar():getInv()
            local target = client:getTracedEntity()
            if not (target and target:IsValid() and target:IsPlayer() and target:Alive() and client:GetPos():DistToSqr(target:GetPos()) < 6500) then return false end
            local targetInv = target:getChar():getInv()
            if not target or not targetInv then return false end
            inv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
            targetInv:addAccessRule(canTransferItemsFromInventoryUsingGiveForward)
            client:setAction(L("givingItemTo", L(item.name), target:Name()), lia.config.get("ItemGiveSpeed", 6))
            target:setAction(L("givingYouItem", client:Name(), L(item.name)), lia.config.get("ItemGiveSpeed", 6))
            client:doStaredAction(target, function()
                local res = hook.Run("HandleItemTransferRequest", client, item:getID(), nil, nil, targetInv:getID())
                if not res then return end
                res:next(function()
                    if not IsValid(client) then return end
                    if istable(res) and isstring(res.error) then return client:notifyErrorLocalized(res.error) end
                    client:EmitSound("physics/cardboard/cardboard_box_impact_soft2.wav", 50)
                end)
            end, lia.config.get("ItemGiveSpeed", 6), function() client:setAction() end, 100)
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
        ITEM.desc = "noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "misc"
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
        ITEM.desc = "noDesc"
        ITEM.uniqueID = uniqueID
        ITEM.base = baseID
        ITEM.isBase = isBaseItem
        ITEM.category = ITEM.category or "misc"
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or DefaultFunctions)
        hook.Run("ItemDefaultFunctions", ITEM.functions)
    end

    if not luaGenerated and path then lia.loader.include(path, "shared") end
    for funcName, funcTable in pairs(ITEM.functions) do
        if isstring(funcTable.name) then
            funcTable.name = L(funcTable.name)
        else
            funcTable.name = L(funcName)
        end

        if isstring(funcTable.tip) then funcTable.tip = L(funcTable.tip) end
    end

    if isstring(ITEM.name) then ITEM.name = L(ITEM.name) end
    if isstring(ITEM.desc) then ITEM.desc = L(ITEM.desc) end
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    hook.Run("OnItemRegistered", ITEM)
    ITEM = nil
    return targetTable[itemType]
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

lia.item.holdTypeToWeaponCategory = {
    grenade = "grenade",
    pistol = "sidearm",
    smg = "primary",
    ar2 = "primary",
    rpg = "primary",
    shotgun = "primary",
    crossbow = "primary",
    normal = "primary",
    melee = "secondary",
    melee2 = "secondary",
    fist = "secondary",
    knife = "secondary",
    physgun = "secondary",
    slam = "secondary",
    passive = "secondary"
}

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

function lia.item.generateWeapons()
    for _, wep in ipairs(weapons.GetList()) do
        local className = wep.ClassName
        if not className or className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
        local override = lia.item.WeaponOverrides[className] or {}
        local holdType = wep.HoldType or "normal"
        local isGrenade = holdType == "grenade"
        local baseType = isGrenade and "base_grenade" or "base_weapons"
        local ITEM = lia.item.register(className, baseType, nil, nil, true)
        ITEM.name = hook.Run("GetWeaponName", weapon) or override.name or className
        ITEM.desc = override.desc or L("weaponsDesc")
        ITEM.category = override.category or isGrenade and L("itemCatGrenades") or L("weapons")
        ITEM.model = override.model or wep.WorldModel or wep.WM or "models/props_c17/suitcase_passenger_physics.mdl"
        ITEM.class = override.class or className
        local size = lia.item.holdTypeSizeMapping[holdType] or {
            width = 2,
            height = 1
        }

        ITEM.width = override.width or size.width
        ITEM.height = override.height or size.height
        ITEM.weaponCategory = override.weaponCategory or lia.item.holdTypeToWeaponCategory[holdType] or "primary"
    end
end

function lia.item.generateAmmo()
    local entityList = {}
    local scriptedEntities = scripted_ents.GetList()
    for className, _ in pairs(scriptedEntities) do
        if className then entityList[className] = true end
    end

    for className, _ in pairs(entityList) do
        if not className then continue end
        local isArc9Ammo = className:find("^arc9_ammo_")
        local isArccwAmmo = className:find("^arccw_ammo_")
        if not (isArc9Ammo or isArccwAmmo) then continue end
        if className:find("_base") or lia.item.WeaponsBlackList[className] then continue end
        local override = lia.item.WeaponOverrides[className] or {}
        local baseType = "base_entities"
        local entityID = className
        local ITEM = lia.item.register(className, baseType, nil, nil, true)
        ITEM.name = override.name or isArc9Ammo and "ARC9 " .. className:gsub("^arc9_ammo_", ""):gsub("_", " "):upper() or isArccwAmmo and "ARCCW " .. className:gsub("^arccw_ammo_", ""):gsub("_", " "):upper() or className
        ITEM.desc = override.desc or L("ammoBoxDesc")
        ITEM.category = override.category or L("itemCatAmmunition")
        ITEM.model = override.model or "models/props_c17/suitcase001a.mdl"
        ITEM.entityid = override.entityid or entityID
        ITEM.width = override.width or 1
        ITEM.height = override.height or 1
    end
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

        promise:next(function(item) if callback then callback(item) end end, function(reason)
            if reason and reason:find("An inventory has a missing item") then
                lia.error(reason)
            else
                lia.error("Failed to spawn item: " .. tostring(reason or "Unknown error"))
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
    if lia.config.get("AutoWeaponItemGeneration", true) then lia.item.generateWeapons() end
    if lia.config.get("AutoAmmoItemGeneration", true) then lia.item.generateAmmo() end
    lia.item.itemEntities = {}
    for _, item in pairs(lia.item.list) do
        if item.base == "base_entities" then lia.item.itemEntities[item.uniqueID] = {item.entityid, item.data} end
    end
end)
