--[[--
Interactable entities that can be held in inventories.

Items are objects that are contained inside of an `Inventory`, or as standalone entities if they are dropped in the world. They
usually have functionality that provides more gameplay aspects to the schema.

For an item to have an actual presence, they need to be instanced (usually by spawning them). Items describe the
properties, while instances are a clone of these properties that can have their own unique data (e.g an ID card will have the
same name but different numerical IDs). You can think of items as the class, while instances are objects of the `Item` class.
]]
-- @classmod Item
local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "INVALID ITEM"
ITEM.desc = (ITEM.desc or ITEM.description) or "[[INVALID ITEM]]"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

function ITEM:__eq(other)
    return self:getID() == other:getID()
end

function ITEM:__tostring()
    return "item[" .. self.uniqueID .. "][" .. self.id .. "]"
end

function ITEM:getID()
    return self.id
end

function ITEM:getModel()
    return self.model
end

function ITEM:getSkin()
    return self.skin
end

function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

function ITEM:call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity
    if isfunction(self[method]) then
        local results = {self[method](self, ...)}
        self.player = oldPlayer
        self.entity = oldEntity
        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

function ITEM:getData(key, default)
    self.data = self.data or {}
    if key == true then return self.data end
    local value = self.data[key]
    if value ~= nil then return value end
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        local value = data[key]
        if value ~= nil then return value end
    end
    return default
end

function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

function ITEM:onRegistered()
end

function ITEM:print(detail)
    if detail == true then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

function ITEM:printData()
    self:print(true)
    print("ITEM DATA:")
    for k, v in pairs(self.data) do
        print(Format("[%s] = %s", k, v))
    end
end

if SERVER then
    function ITEM:getName()
        return self.name
    end

    ITEM.GetName = ITEM.getName
    function ITEM:getDesc()
        return self.desc
    end

    ITEM.GetDescription = ITEM.getDesc
    function ITEM:removeFromInventory(preserveItem)
        local inventory = lia.inventory.instances[self.invID]
        self.invID = 0
        if inventory then return inventory:removeItem(self:getID(), preserveItem) end
        local d = deferred.new()
        d:resolve()
        return d
    end

    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "_itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    function ITEM:remove()
        local d = deferred.new()
        if IsValid(self.entity) then self.entity:Remove() end
        self:removeFromInventory():next(function()
            d:resolve()
            return self:delete()
        end)
        return d
    end

    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    function ITEM:onDisposed()
    end

    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    function ITEM:spawn(position, angles)
        local instance = lia.item.instances[self.id]
        if instance then
            if IsValid(instance.entity) then
                instance.entity.liaIsSafe = true
                instance.entity:Remove()
            end

            local client
            if type(position) == "Player" then
                client = position
                position = position:getItemDropPos()
            end

            local entity = ents.Create("lia_item")
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or Angle(0, 0, 0))
            entity:setItem(self.id)
            instance.entity = entity
            if IsValid(client) then
                entity.SteamID64 = client:SteamID()
                entity.liaCharID = client:getChar():getID()
                entity:SetCreator(client)
            end
            return entity
        end
    end

    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    function ITEM:onInstanced()
    end

    function ITEM:onSync()
    end

    function ITEM:onRemoved()
    end

    function ITEM:onRestored()
    end

    function ITEM:sync(recipient)
        net.Start("liaItemInstance")
        net.WriteUInt(self:getID(), 32)
        net.WriteString(self.uniqueID)
        net.WriteTable(self.data)
        net.WriteType(self.invID)
        net.WriteUInt(self.quantity, 32)
        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end

        self:onSync(recipient)
    end

    function ITEM:setData(key, value, receivers, noSave, noCheckEntity)
        self.data = self.data or {}
        self.data[key] = value
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("data", self.data) end
        end

        if receivers or self:getOwner() then netstream.Start(receivers or self:getOwner(), "invData", self:getID(), key, value) end
        if noSave or not lia.db then return end
        if key == "x" or key == "y" then
            value = tonumber(value)
            if MYSQLOO_PREPARED then
                lia.db.preparedCall("item" .. key, nil, value, self:getID())
            else
                lia.db.updateTable({
                    ["_" .. key] = value
                }, nil, "items", "_itemID = " .. self:getID())
            end
            return
        end

        local x, y = self.data.x, self.data.y
        self.data.x, self.data.y = nil, nil
        if MYSQLOO_PREPARED then
            lia.db.preparedCall("itemData", nil, self.data, self:getID())
        else
            lia.db.updateTable({
                _data = self.data
            }, nil, "items", "_itemID = " .. self:getID())
        end

        self.data.x, self.data.y = x, y
    end

    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then netstream.Start(receivers or self:getOwner(), "invQuantity", self:getID(), self.quantity) end
        if noSave or not lia.db then return end
        if MYSQLOO_PREPARED then
            lia.db.preparedCall("itemq", nil, self.quantity, self:getID())
        else
            lia.db.updateTable({
                _quantity = self.quantity
            }, nil, "items", "_itemID = " .. self:getID())
        end
    end

    function ITEM:interact(action, client, entity, data)
        assert(type(client) == "Player" and IsValid(client), "Item action cannot be performed without a player")
        local canInteract, reason = hook.Run("CanPlayerInteractItem", client, action, self, data)
        if canInteract == false then
            if reason then client:notifyLocalized(reason) end
            return false
        end

        local oldPlayer, oldEntity = self.player, self.entity
        self.player = client
        self.entity = entity
        local callback = self.functions[action]
        if not callback then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        local canRun = (isfunction(callback.onCanRun) and not callback.onCanRun(self, data)) or (isfunction(callback.OnCanRun) and not callback.OnCanRun(self, data)) or true
        if not canRun then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        local result
        if isfunction(self.hooks[action]) then result = self.hooks[action](self, data) end
        if result == nil then
            if isfunction(callback.onRun) then
                result = callback.onRun(self, data)
            elseif isfunction(callback.OnRun) then
                result = callback.OnRun(self, data)
            end
        end

        if self.postHooks[action] then self.postHooks[action](self, result, data) end
        hook.Run("OnPlayerInteractItem", client, action, self, result, data)
        lia.log.add(client, "itemUse", action, item)
        if result ~= false and not deferred.isPromise(result) then
            if IsValid(entity) then
                entity:Remove()
            else
                self:remove()
            end
        end

        self.player = oldPlayer
        self.entity = oldEntity
        return true
    end
else
    function ITEM:getName()
        return L(self.name)
    end

    ITEM.GetName = ITEM.getName
    function ITEM:getDesc()
        return L(self.desc)
    end

    ITEM.GetDescription = ITEM.getDesc
end

ITEM.GetQuantity = ITEM.getQuantity
ITEM.GetID = ITEM.getID
ITEM.GetModel = ITEM.getModel
ITEM.GetSkin = ITEM.getSkin
ITEM.GetPrice = ITEM.getPrice
ITEM.Call = ITEM.call
ITEM.GetOwner = ITEM.getOwner
ITEM.GetData = ITEM.getData
ITEM.Hook = ITEM.hook
ITEM.PostHook = ITEM.postHook
ITEM.OnRegistered = ITEM.onRegistered
ITEM.Print = ITEM.print
ITEM.PrintData = ITEM.printData
ITEM.Print = ITEM.Print
ITEM.PrintData = ITEM.PrintData
ITEM.RemoveFromInventory = ITEM.removeFromInventory
ITEM.Delete = ITEM.delete
ITEM.Remove = ITEM.remove
ITEM.Destroy = ITEM.destroy
ITEM.OnDisposed = ITEM.onDisposed
ITEM.GetEntity = ITEM.getEntity
ITEM.Spawn = ITEM.spawn
ITEM.Transfer = ITEM.transfer
ITEM.OnInstanced = ITEM.onInstanced
ITEM.OnSync = ITEM.onSync
ITEM.OnRemoved = ITEM.onRemoved
ITEM.OnRestored = ITEM.onRestored
ITEM.Sync = ITEM.sync
ITEM.SetData = ITEM.setData
ITEM.AddQuantity = ITEM.addQuantity
ITEM.SetQuantity = ITEM.setQuantity
ITEM.Interact = ITEM.interact
lia.meta.item = ITEM