local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "INVALID NAME"
ITEM.desc = ITEM.desc or "[[INVALID DESCRIPTION]]"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
--[[
    ITEM:getQuantity()

    Description:
        Retrieves how many of this item the stack represents.

    Realm:
        Shared

    Returns:
        number – Quantity contained in this item instance.
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    ITEM:eq(other)

    Description:
        Compares this item instance to another by ID.

    Parameters:
        other (Item) – The other item to compare with.

    Realm:
        Shared

    Returns:
        boolean – True if both items share the same ID.
]]
function ITEM:eq(other)
    return self:getID() == other:getID()
end

--[[
    ITEM:tostring()

    Description:
        Returns a printable representation of this item.

    Realm:
        Shared

    Returns:
        string – Identifier in the form "item[uniqueID][id]".
]]
function ITEM:tostring()
    return "item[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    ITEM:getID()

    Description:
        Retrieves the unique identifier of this item.

    Realm:
        Shared

    Returns:
        number – Item database ID.
]]
function ITEM:getID()
    return self.id
end

--[[
    ITEM:getModel()

    Description:
        Returns the model path associated with this item.

    Realm:
        Shared

    Returns:
        string – Model path.
]]
function ITEM:getModel()
    return self.model
end

--[[
    ITEM:getSkin()

    Description:
        Retrieves the skin index this item uses.

    Realm:
        Shared

    Returns:
        number – Skin ID applied to the model.
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    ITEM:getPrice()

    Description:
        Returns the calculated purchase price for the item.

    Realm:
        Shared

    Returns:
        number – The price value.
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    ITEM:call(method, client, entity, ...)

    Description:
        Invokes an item method with the given player and entity context.

    Parameters:
        method (string) – Method name to run.
        client (Player) – The player performing the action.
        entity (Entity) – Entity representing this item.
        ... – Additional arguments passed to the method.

    Realm:
        Shared

    Returns:
        any – Results returned by the called function.
]]
function ITEM:call(method, client, entity, ...)
    local oldPlayer, oldEntity = self.player, self.entity
    self.player = client or self.player
    self.entity = entity or self.entity
    if isfunction(self[method]) then
        local results = {self[method](self, ...)}
        self.player = oldPlayer
        self.entity = oldEntity
        hook.Run("ItemFunctionCalled", self, method, client, entity, results)
        return unpack(results)
    end

    self.player = oldPlayer
    self.entity = oldEntity
end

--[[
    ITEM:getOwner()

    Description:
        Attempts to find the player currently owning this item.

    Realm:
        Shared

    Returns:
        Player|nil – The owner if available.
]]
function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

--[[
    ITEM:getData(key, default)

    Description:
        Retrieves a piece of persistent data stored on the item.

    Parameters:
        key (string) – Data key to read.
        default (any) – Value to return when the key is absent.

    Realm:
        Shared

    Returns:
        any – Stored value or default.
]]
function ITEM:getData(key, default)
    self.data = self.data or {}
    local value = self.data[key]
    if value ~= nil then return value end
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        local value = data[key]
        if value ~= nil then return value end
    end
    return default
end

--[[
    ITEM:getAllData()

    Description:
        Returns a merged table of this item's stored data and any
        networked values on its entity.

    Realm:
        Shared

    Returns:
        table – Key/value table of all data fields.
]]
function ITEM:getAllData()
    self.data = self.data or {}
    local fullData = table.Copy(self.data)
    if IsValid(self.entity) then
        local entityData = self.entity:getNetVar("data", {})
        for key, value in pairs(entityData) do
            fullData[key] = value
        end
    end
    return fullData
end

--[[
    ITEM:hook(name, func)

    Description:
        Registers a hook callback for this item instance.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function to call.

    Realm:
        Shared
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    ITEM:postHook(name, func)

    Description:
        Registers a post-hook callback for this item.

    Parameters:
        name (string) – Hook identifier.
        func (function) – Function invoked after the main hook.

    Realm:
        Shared
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    ITEM:onRegistered()

    Description:
        Called when the item table is first registered.

    Realm:
        Shared
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    ITEM:print(detail)

    Description:
        Prints a simple representation of the item to the console.

    Parameters:
        detail (boolean) – Include position details when true.

    Realm:
        Server
]]
function ITEM:print(detail)
    if detail then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--[[
    ITEM:printData()

    Description:
        Debug helper that prints all stored item data.

    Realm:
        Server
]]
function ITEM:printData()
    self:print(true)
    lia.information("ITEM DATA:")
    for k, v in pairs(self.data) do
        lia.information(Format("[%s] = %s", k, v))
    end
end

if SERVER then
    function ITEM:getName()
        return self.name
    end

    function ITEM:getDesc()
        return self.desc
    end

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
        if IsValid(self.entity) then SafeRemoveEntity(self.entity) end
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
                SafeRemoveEntity(instance.entity)
            end

            local client
            if isentity(position) and position:IsPlayer() then
                client = position
                position = position:getItemDropPos()
            end

            local entity = ents.Create("lia_item")
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or angle_zero)
            entity:setItem(self.id)
            instance.entity = entity
            if IsValid(client) then
                entity.SteamID64 = client:SteamID64()
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

    --[[
        ITEM:addQuantity(quantity, receivers, noCheckEntity)

        Description:
            Increases the stored quantity for this item instance.

        Parameters:
            quantity (number) – Amount to add.
            receivers (Player|nil) – Who to network the change to.
            noCheckEntity (boolean) – Skip entity network update.

        Realm:
            Server
    ]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
        ITEM:setQuantity(quantity, receivers, noCheckEntity)

        Description:
            Sets the current stack quantity and replicates the change.

        Parameters:
            quantity (number) – New amount to store.
            receivers (Player|nil) – Recipients to send updates to.
            noCheckEntity (boolean) – Skip entity updates when true.

        Realm:
            Server
    ]]
    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then
            netstream.Start(receivers or self:getOwner(), "invQuantity", self:getID(), self.quantity)
        end
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
        assert(client:IsPlayer() and IsValid(client), "Item action cannot be performed without a player")
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

        if isfunction(callback.onCanRun) then
            canInteract = callback.onCanRun(self, data)
        else
            canInteract = true
        end

        if not canInteract then
            self.player = oldPlayer
            self.entity = oldEntity
            return false
        end

        hook.Run("PrePlayerInteractItem", client, action, self)
        local result
        if isfunction(self.hooks[action]) then result = self.hooks[action](self, data) end
        if result == nil and isfunction(callback.onRun) then result = callback.onRun(self, data) end
        if self.postHooks[action] then self.postHooks[action](self, result, data) end
        hook.Run("OnPlayerInteractItem", client, action, self, result, data)
        if result ~= false and not deferred.isPromise(result) then
            if IsValid(entity) then
                SafeRemoveEntity(entity)
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

    function ITEM:getDesc()
        return L(self.desc)
    end
end

lia.meta.item = ITEM
