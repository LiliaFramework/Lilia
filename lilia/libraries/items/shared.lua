--[[--
Item manipulation and helper functions.
]]
-- @module lia.item
lia.item = lia.item or {}
lia.item.base = lia.item.base or {}
lia.item.list = lia.item.list or {}
lia.item.instances = lia.item.instances or {}
lia.item.inventories = lia.inventory.instances or {}
lia.item.inventoryTypes = lia.item.inventoryTypes or {}
lia.item.DefaultFunctions = {
    drop = {
        tip = "dropTip",
        icon = "icon16/world.png",
        onRun = function(item)
            local client = item.player
            item:removeFromInventory(true):next(function() item:spawn(client) end)
            lia.log.add(item.player, "itemDrop", item.name, 1)
            return false
        end,
        onCanRun = function(item) return item.entity == nil and not IsValid(item.entity) and not item.noDrop end
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
            inventory:add(item):next(function(res)
                client.itemTakeTransaction = nil
                if IsValid(entity) then
                    entity.liaIsSafe = true
                    entity:Remove()
                end

                if not IsValid(client) then return end
                lia.log.add(client, "itemTake", item.name, 1)
                d:resolve()
            end):catch(function(err)
                client.itemTakeTransaction = nil
                client:notifyLocalized(err)
                d:reject()
            end)
            return d
        end,
        onCanRun = function(item) return IsValid(item.entity) end
    },
}
local GridInv = FindMetaTable("GridInv")
--- Retrieves an item table.
-- @realm shared
-- @string identifier Unique ID of the item
-- @treturn item Item table
-- @usage print(lia.item.get("example"))
-- > "item[example][0]"
function lia.item.get(identifier)
    return lia.item.base[identifier] or lia.item.list[identifier]
end

function lia.item.load(path, baseID, isBaseItem)
    local uniqueID = path:match("sh_([_%w]+)%.lua") or path:match("([_%w]+)%.lua")
    if uniqueID then
        uniqueID = (isBaseItem and "base_" or "") .. uniqueID
        lia.item.register(uniqueID, baseID, isBaseItem, path)
    elseif not path:find(".txt") then
        ErrorNoHalt("[Lilia] Item at '" .. path .. "' follows an invalid naming convention!\n")
    end
end

function lia.item.isItem(object)
    return istable(object) and object.isItem == true
end

function lia.item.register(uniqueID, baseID, isBaseItem, path, luaGenerated)
    assert(isstring(uniqueID), "uniqueID must be a string")
    local baseTable = lia.item.base[baseID] or lia.meta.item
    if baseID then assert(baseTable, "Item " .. uniqueID .. " has a non-existent base " .. baseID) end
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
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or lia.item.DefaultFunctions)
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
        ITEM.functions = ITEM.functions or table.Copy(baseTable.functions or lia.item.DefaultFunctions)
    end

    if not luaGenerated and path then lia.include(path, "shared") end
    ITEM:onRegistered()
    local itemType = ITEM.uniqueID
    targetTable[itemType] = ITEM
    ITEM = nil
    return targetTable[itemType]
end

function lia.item.loadFromDir(directory, isFirstLoad)
    local files, folders
    files = file.Find(directory .. "/base/*.lua", "LUA")
    for _, v in ipairs(files) do
        lia.item.load(directory .. "/base/" .. v, nil, true)
    end

    files, folders = file.Find(directory .. "/*", "LUA")
    for _, v in ipairs(folders) do
        if v == "base" then continue end
        for _, v2 in ipairs(file.Find(directory .. "/" .. v .. "/*.lua", "LUA")) do
            lia.item.load(directory .. "/" .. v .. "/" .. v2, "base_" .. v, nil, false)
        end
    end

    for _, v in ipairs(files) do
        lia.item.load(directory .. "/" .. v)
    end

    if isFirstLoad then hook.Run("InitializedItems") end
end

function lia.item.new(uniqueID, id)
    id = id and tonumber(id) or id
    assert(isnumber(id), "non-number ID given to lia.item.new")
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
        error("[Lilia] Attempt to create an unknown item '" .. tostring(uniqueID) .. "'\n")
    end
end

function lia.item.registerInv(invType, w, h)
    assert(GridInv, "GridInv not found")
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
            for k, v in ipairs(player.GetAll()) do
                if v:getChar() and v:getChar():getID() == owner then
                    inventory:sync(v)
                    break
                end
            end
        end

        if callback then callback(inventory) end
    end)
end

function lia.item.getInv(invID)
    return lia.inventory.instances[invID]
end

function lia.item.createInv(w, h, id)
    assert(GridInv, "GridInv not found")
    local instance = GridInv:new()
    instance.id = id
    instance.data = {
        w = w,
        h = h
    }

    lia.inventory.instances[id] = instance
    return instance
end

lia.char.registerVar("inv", {
    noNetworking = true,
    noDisplay = true,
    onGet = function(character, index)
        if index and not isnumber(index) then return character.vars.inv or {} end
        return character.vars.inv and character.vars.inv[index or 1]
    end,
    onSync = function(character, recipient)
        net.Start("liaCharacterInvList")
        net.WriteUInt(character:getID(), 32)
        net.WriteUInt(#character.vars.inv, 32)
        for i = 1, #character.vars.inv do
            net.WriteType(character.vars.inv[i].id)
        end

        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end
})

if SERVER then
    function lia.item.instance(index, uniqueID, itemData, x, y, callback)
        if isstring(index) and (istable(uniqueID) or (itemData == nil and x == nil)) then
            itemData = uniqueID
            uniqueID = index
        end

        local d = deferred.new()
        local itemTable = lia.item.list[uniqueID]
        if not itemTable then
            d:reject("Attempt to instantiate invalid item " .. tostring(uniqueID))
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

        local function onItemCreated(data, itemID)
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
        if MYSQLOO_PREPARED and isnumber(index) then
            lia.db.preparedCall("itemInstance", onItemCreated, index, uniqueID, itemData, x, y, itemTable.maxQuantity or 1)
        else
            lia.db.insertTable({
                _invID = index,
                _uniqueID = uniqueID,
                _data = itemData,
                _x = x,
                _y = y,
                _quantity = itemTable.maxQuantity or 1
            }, onItemCreated, "items")
        end
        return d
    end

    function lia.item.deleteByID(id)
        if lia.item.instances[id] then
            lia.item.instances[id]:delete()
        else
            lia.db.delete("items", "_itemID = " .. id)
        end
    end

    function lia.item.loadItemByID(itemIndex, recipientFilter)
        local range
        if istable(itemIndex) then
            range = "(" .. table.concat(itemIndex, ", ") .. ")"
        elseif isnumber(itemIndex) then
            range = "(" .. itemIndex .. ")"
        else
            return
        end

        lia.db.query("SELECT _itemID, _uniqueID, _data, _x, _y, _quantity FROM lia_items WHERE _itemID IN " .. range, function(data)
            if data then
                for _, v in ipairs(data) do
                    local itemID = tonumber(v._itemID)
                    local data = util.JSONToTable(v._data or "[]")
                    local uniqueID = v._uniqueID
                    local itemTable = lia.item.list[uniqueID]
                    if itemTable and itemID then
                        local item = lia.item.new(uniqueID, itemID)
                        item.invID = 0
                        item.data = data or {}
                        item.data.x = tonumber(v._x)
                        item.data.y = tonumber(v._y)
                        item.quantity = tonumber(v._quantity)
                        item:onRestored()
                    end
                end
            end
        end)
    end

--- Instances and spawns a given item type.
-- @realm server
-- @string uniqueID Unique ID of the item
-- @vector position The position in which the item's entity will be spawned
-- @func[opt=nil] callback Function to call when the item entity is created
-- @angle[opt=angle_zero] angles The angles at which the item's entity will spawn
-- @tab[opt=nil] data Additional data for this item instance
    function lia.item.spawn(uniqueID, position, callback, angles, data)
        local d
        if not isfunction(callback) then
            if isangle(callback) == "Angle" or istable(angles) then
                angles = callback
                data = angles
            end

            d = deferred.new()
            callback = function(item) d:resolve(item) end
        end

        lia.item.instance(0, uniqueID, data or {}, 1, 1, function(item)
            local entity = item:spawn(position, angles)
            if callback then callback(item, entity) end
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
