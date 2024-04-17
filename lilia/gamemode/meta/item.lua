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
--- Returns the quantity of the item.
-- @realm shared
-- @treturn number The quantity of the item

function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--- Returns true if this item is equal to another item. Internally, this checks item IDs.
-- @realm shared
-- @item other Item to compare to
-- @treturn bool Whether or not this item is equal to the given item
-- @usage print(lia.item.instances[1] == lia.item.instances[2])
-- > falsefunction ITEM:__eq(other)
function ITEM:__eq(other)
    return self:getID() == other:getID()
end
--- Returns a string representation of this item.
-- @realm shared
-- @treturn string String representation
-- @usage print(lia.item.instances[1])
-- > "item[1]"
function ITEM:__tostring()
    return "item[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--- Returns this item's database ID. This is guaranteed to be unique.
-- @realm shared
-- @treturn number Unique ID of item
function ITEM:getID()
    return self.id
end
--- Returns the model of the item.
-- @realm shared
-- @treturn string The model of the item

function ITEM:getModel()
    return self.model
end
--- Returns the skin of the item.
-- @realm shared
-- @treturn number The skin of the item

function ITEM:getSkin()
    return self.skin
end
--- Returns the price of the item.
-- @realm shared
-- @treturn string The price of the item

function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end
--- Calls one of the item's methods.
-- @realm shared
-- @string method The method to be called
-- @player client The client to pass when calling the method, if applicable
-- @entity entity The eneity to pass when calling the method, if applicable
-- @param ... Arguments to pass to the method
-- @return The values returned by the method

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
--- Returns the player that owns this item.
-- @realm shared
-- @treturn player Player owning this item

function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in ipairs(player.GetAll()) do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end
--- Returns the value stored on a key within the item's data.
-- @realm shared
-- @string key The key in which the value is stored
-- @param[opt=nil] default The value to return in case there is no value stored in the key
-- @return The value stored within the key

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
--- Changes the function called on specific events for the item.
-- @realm shared
-- @string name The name of the hook
-- @func func The function to call once the event occurs
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end
--- Changes the function called after hooks for specific events for the item.
-- @realm shared
-- @string name The name of the hook
-- @func func The function to call after the original hook was called
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

function ITEM:onRegistered()
end
--- A utility function which prints the item's details.
-- @realm shared
-- @bool[opt=false] detail Whether additional detail should be printed or not(Owner, X position, Y position)

function ITEM:print(detail)
    if detail == true then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end
--- A utility function printing the item's stored data.
-- @realm shared
function ITEM:printData()
    self:print(true)
    print("ITEM DATA:")
    for k, v in pairs(self.data) do
        print(Format("[%s] = %s", k, v))
    end
end

if SERVER then

--- Returns the name of the item.
-- @realm server
-- @treturn string The name of the item

    function ITEM:getName()
        return self.name
    end

    ITEM.GetName = ITEM.getName
    --- Returns the description of the item.
-- @realm server
-- @treturn string The description of the item

    function ITEM:getDesc()
        return self.desc
    end

    ITEM.GetDescription = ITEM.getDesc
    --- Removes the item from its current inventory.
    -- @realm server

-- @param preserveItem (boolean) Optional. If true, the item is not fully deleted from the database.
-- @return (deferred) A deferred object representing the asynchronous operation of removing the item.
    function ITEM:removeFromInventory(preserveItem)
        local inventory = lia.inventory.instances[self.invID]
        self.invID = 0
        if inventory then return inventory:removeItem(self:getID(), preserveItem) end
        local d = deferred.new()
        d:resolve()
        return d
    end
--- Deletes the item from the database and performs cleanup.
-- @realm server
-- @return (deferred) A deferred object representing the asynchronous operation of deleting the item from the database.

    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "_itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

--- Removes the item.
-- @realm server
-- @bool bNoReplication Whether or not the item's removal should not be replicated.
-- @bool bNoDelete Whether or not the item should not be fully deleted
-- @treturn bool Whether the item was successfully deleted or not

    function ITEM:remove()
        local d = deferred.new()
        if IsValid(self.entity) then self.entity:Remove() end
        self:removeFromInventory():next(function()
            d:resolve()
            return self:delete()
        end)
        return d
    end
--- Destroys the item instance, removing it from the game world and notifying all clients.
-- @realm server

    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end
--- Gets called upon destroying an item.
-- @realm server
    function ITEM:onDisposed()
    end
	--- Returns the item's entity.
	-- @realm server
	-- @treturn entity The entity of the item

    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end
	--- Spawn an item entity based off the item table.
	-- @realm server
	-- @param[type=vector] position The position in which the item's entity will be spawned
	-- @param[type=angle] angles The angles at which the item's entity will spawn
	-- @treturn entity The spawned entity

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
--- Transfers the item to another inventory.
-- @realm server
-- @bool bBypass Whether to bypass access checks for transferring the item.
-- @treturn bool Whether the item was successfully transferred or not.

    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

--- Gets called upon creating (instancing) an item.
-- @realm server

    function ITEM:onInstanced()
    end

--- Gets called upon syncing an item.
-- @realm server
    function ITEM:onSync()
    end
--- Gets called upon removing an item.
-- @realm server
    function ITEM:onRemoved()
    end
--- Gets called upon restoring an item.
-- @realm server
    function ITEM:onRestored()
    end
--- Synchronizes the item data with the specified recipient or broadcasts it to all clients if no recipient is specified.
-- @param recipient (Player) The player to whom the item data should be synchronized. If set to nil, the data is broadcasted to all clients.
-- @realm server

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
--- Sets a key within the item's data.
-- @realm server
-- @string key The key to store the value within
-- @param[opt=nil] value The value to store within the key
-- @tab[opt=nil] receivers The players to replicate the data on
-- @bool[opt=false] noSave Whether to disable saving the data on the database or not
-- @bool[opt=false] noCheckEntity Whether to disable setting the data on the entity, if applicable

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
--- Adds a specified quantity to the item's current quantity.
-- @realm server
-- @param quantity (number) The quantity to add.
-- @param receivers (table) Optional. Players who should receive updates about the quantity change.
-- @param noCheckEntity (boolean) Optional. If true, entity checks will be skipped.

    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

--- Sets the quantity of the item to the specified value.
-- @realm server
-- @param quantity (number) The new quantity value.
-- @param receivers (table) Optional. Players who should receive updates about the quantity change.
-- @param noCheckEntity (boolean) Optional. If true, entity checks will be skipped.

    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then netstream.Start(receivers or self:getOwner(), "invQuantity", self:getID(), self.quantity) end
        if noSave or not lia.db then return end
        if MYSQLOO_PREPARED then
            lia.db.preparedCall("itemq",l, self.quantity, self:getID())
        else
            lia.db.updateTable({
                _quantity = self.quantity
            }, nil, "items", "_itemID = " .. self:getID())
        end
    end
--- Performs an interaction action with the item.
-- @realm server
-- @param action (string) The interaction action to perform.
-- @param client (Player) The player performing the interaction.
-- @param entity (Entity) The entity associated with the interaction, if any.
-- @param data (table) Optional. Additional data related to the interaction.
-- @return (boolean) Whether the interaction was successful.

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

--- Returns the name of the item.
-- @realm client
-- @treturn string The name of the item

    function ITEM:getName()
        return L(self.name)
    end

    ITEM.GetName = ITEM.getName
    --- Returns the description of the item.
-- @realm client
-- @treturn string The description of the item


    function ITEM:getDesc()
        return L(self.desc)
    end

    ITEM.GetDescription = ITEM.getDesc
end

ITEM.GetQuantity = ITEM.getQuantity
ITEM.GetPrice = ITEM.getPrice
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
ITEM.OnDisposed = ITEM.onDisposed
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