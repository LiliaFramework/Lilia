--[[--
Interactable entities that can be held in inventories.

Items are objects that are contained inside of an `Inventory`, or as standalone entities if they are dropped in the world. They
usually have functionality that provides more gameplay aspects to the schema.

For an item to have an actual presence, they need to be instanced (usually by spawning them). Items describe the
properties, while instances are a clone of these properties that can have their own unique data (e.g., an ID card will have the
same name but different numerical IDs). You can think of items as the class, while instances are objects of the `Item` class.
]]
-- @itemmeta Framework
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
-- @treturn Integer The quantity of the item.
-- @usage
-- local qty = item:getQuantity()
-- print("Quantity:", qty)
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--- Returns true if this item is equal to another item. Internally, this checks item IDs.
-- @realm shared
-- @tparam Item other The item to compare to.
-- @treturn Boolean Whether or not this item is equal to the given item.
-- @usage
-- if lia.item.instances[1] == lia.item.instances[2] then
--     print("Items are equal.")
-- else
--     print("Items are not equal.")
-- end
function ITEM:__eq(other)
    return self:getID() == other:getID()
end

--- Returns a string representation of this item.
-- @realm shared
-- @treturn String String representation.
-- @usage
-- print(tostring(lia.item.instances[1]))
-- Output: "item[uniqueID][1]"
function ITEM:__tostring()
    return "item[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--- Returns this item's database ID. This is guaranteed to be unique.
-- @realm shared
-- @treturn Integer Unique ID of item.
-- @usage
-- local itemID = item:getID()
-- print("Item ID:", itemID)
function ITEM:getID()
    return self.id
end

--- Returns the model of the item.
-- @realm shared
-- @treturn String The model of the item.
-- @usage
-- local model = item:getModel()
-- print("Model:", model)
function ITEM:getModel()
    return self.model
end

--- Returns the skin of the item.
-- @realm shared
-- @treturn Integer The skin of the item.
-- @usage
-- local skin = item:getSkin()
-- print("Skin:", skin)
function ITEM:getSkin()
    return self.skin
end

--- Returns the price of the item.
-- @realm shared
-- @treturn Float The price of the item.
-- @usage
-- local price = item:getPrice()
-- print("Price:", price)
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--- Calls one of the item's methods.
-- @realm shared
-- @string method The method to be called.
-- @client client The player to pass when calling the method, if applicable.
-- @entity entity The entity to pass when calling the method, if applicable.
-- @tab ... Arguments to pass to the method.
-- @treturn any The values returned by the method.
-- @usage
-- item:call("use", player, entity, arg1, arg2)
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

--- Returns the player that owns this item.
-- @realm shared
-- @treturn Player Player owning this item.
-- @usage
-- local owner = item:getOwner()
-- if owner then
--     print("Item is owned by:", owner:Nick())
-- else
--     print("Item has no owner.")
-- end
function ITEM:getOwner()
    local inventory = lia.inventory.instances[self.invID]
    if inventory and SERVER then return inventory:getRecipients()[1] end
    local id = self:getID()
    for _, v in player.Iterator() do
        local character = v:getChar()
        if character and character:getInv() and character:getInv().items[id] then return v end
    end
end

--- Returns the value stored on a key within the item's data.
-- @realm shared
-- @string key The key in which the value is stored.
-- @tparam any[opt] default The value to return in case there is no value stored in the key.
-- @treturn any The value stored within the key.
-- @usage
-- local health = item:getData("health", 100)
-- print("Item Health:", health)
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
-- @string name The name of the hook.
-- @func func The function to call once the event occurs.
-- @usage
-- item:hook("onUse", function(item)
--     print("Item was used.")
-- end)
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--- Changes the function called after hooks for specific events for the item.
-- @realm shared
-- @string name The name of the hook.
-- @func func The function to call after the original hook was called.
-- @usage
-- item:postHook("onUse", function(item, result)
--     print("Item use post-processing.")
-- end)
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--- Gets called when the item is registered.
-- @realm shared
-- @usage
-- function ITEM:onRegistered()
--     print("Item has been registered.")
-- end
function ITEM:onRegistered()
end

--- A utility function which prints the item's details.
-- @realm shared
-- @bool detail Whether additional detail should be printed or not (Owner, X position, Y position).
-- @usage
-- item:print()
-- item:print(true)
function ITEM:print(detail)
    if detail == true then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--- A utility function printing the item's stored data.
-- @realm shared
-- @usage
-- item:printData()
function ITEM:printData()
    self:print(true)
    LiliaInformation("ITEM DATA:")
    for k, v in pairs(self.data) do
        LiliaInformation(Format("[%s] = %s", k, v))
    end
end

if SERVER then
    --- Returns the name of the item.
    -- @realm server
    -- @treturn String The name of the item.
    -- @usage
    -- local name = item:getName()
    -- print("Item Name:", name)
    function ITEM:getName()
        return self.name
    end

    ITEM.GetName = ITEM.getName
    --- Returns the description of the item.
    -- @realm server
    -- @treturn String The description of the item.
    -- @usage
    -- local desc = item:getDesc()
    -- print("Description:", desc)
    function ITEM:getDesc()
        return self.desc
    end

    ITEM.GetDescription = ITEM.getDesc
    --- Removes the item from its current inventory.
    -- @realm server
    -- @bool preserveItem If true, the item is not fully deleted from the database.
    -- @treturn Deferred A deferred object representing the asynchronous operation of removing the item.
    -- @usage
    -- item:removeFromInventory(true):next(function()
    --     print("Item removed while preserving data.")
    -- end)
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
    -- @treturn Deferred A deferred object representing the asynchronous operation of deleting the item from the database.
    -- @usage
    -- item:delete():next(function()
    --     print("Item deleted from database.")
    -- end)
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "_itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --- Removes the item.
    -- @realm server
    -- @bool bNoReplication Whether or not the item's removal should not be replicated.
    -- @bool bNoDelete Whether or not the item should not be fully deleted.
    -- @treturn Deferred A deferred object representing the asynchronous operation of removing the item.
    -- @usage
    -- item:remove():next(function()
    --     print("Item removed.")
    -- end)
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
    -- @usage
    -- item:destroy()
    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    --- Gets called upon destroying an item.
    -- @realm server
    -- @usage
    -- function ITEM:onDisposed()
    --     print("Item has been disposed.")
    -- end
    function ITEM:onDisposed()
    end

    --- Returns the item's entity.
    -- @realm server
    -- @treturn Entity The entity of the item.
    -- @usage
    -- local entity = item:getEntity()
    -- if entity then
    --     print("Item entity exists.")
    -- end
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --- Spawns an item entity based off the item table.
    -- @realm server
    -- @vector position The position in which the item's entity will be spawned.
    -- @angle angles The angles at which the item's entity will spawn.
    -- @treturn Entity The spawned entity.
    -- @usage
    -- local spawnedEntity = item:spawn(Vector(0, 0, 0), Angle(0, 90, 0))
    function ITEM:spawn(position, angles)
        local instance = lia.item.instances[self.id]
        if instance then
            if IsValid(instance.entity) then
                instance.entity.liaIsSafe = true
                instance.entity:Remove()
            end

            local client
            if isentity(position) and position:IsPlayer() then
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
    -- @tab newInventory The inventory to which the item should be transferred.
    -- @bool bBypass Whether to bypass access checks for transferring the item.
    -- @treturn Boolean Whether the item was successfully transferred or not.
    -- @usage
    -- local success = item:transfer(targetInventory, true)
    -- if success then
    --     print("Item transferred successfully.")
    -- else
    --     print("Item transfer failed.")
    -- end
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --- Gets called upon creating (instancing) an item.
    -- @realm server
    -- @usage
    -- function ITEM:onInstanced()
    --     print("Item has been instanced.")
    -- end
    function ITEM:onInstanced()
    end

    --- Gets called upon syncing an item.
    -- @realm server
    -- @usage
    -- function ITEM:onSync(recipient)
    --     print("Item has been synced with recipient:", recipient:Nick())
    -- end
    function ITEM:onSync()
    end

    --- Gets called upon removing an item.
    -- @realm server
    -- @usage
    -- function ITEM:onRemoved()
    --     print("Item has been removed.")
    -- end
    function ITEM:onRemoved()
    end

    --- Gets called upon restoring an item.
    -- @realm server
    -- @usage
    -- function ITEM:onRestored()
    --     print("Item has been restored.")
    -- end
    function ITEM:onRestored()
    end

    --- Synchronizes the item data with the specified recipient or broadcasts it to all clients if no recipient is specified.
    -- @realm server
    -- @client[opt] recipient The player to whom the item data should be synchronized. If set to nil, the data is broadcasted to all clients.
    -- @usage
    -- item:sync(player)
    -- item:sync()
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

    --- Sets a key-value pair within the item's data table.
    -- This function updates the item's data and optionally synchronizes it with the entity's network variables
    -- and sends the updated data to specified receivers or the item's owner.
    -- @realm server
    -- @string key The key to store the value under.
    -- @tparam any[opt=nil] value The value to set for the key. If nil, the key is effectively removed.
    -- @tab[opt=nil] receivers A table of players to whom the data should be sent. Defaults to the item's owner.
    -- @bool[opt=false] noSave If true, prevents saving the data to the database.
    -- @bool[opt=false] noCheckEntity If true, skips updating the network variable for the item's entity.
    -- @usage
    -- item:setData("health", 100, {player1, player2}, false, false)
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

    ITEM.SetData = ITEM.setData
    --- Adds a specified quantity to the item's current quantity.
    -- @realm server
    -- @int quantity The quantity to add.
    -- @tab receivers Players who should receive updates about the quantity change.
    -- @bool noCheckEntity If true, entity checks will be skipped.
    -- @usage
    -- item:addQuantity(5, {player1, player2}, false)
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --- Sets the quantity of the item to the specified value.
    -- @realm server
    -- @int quantity The new quantity value.
    -- @tab receivers Players who should receive updates about the quantity change.
    -- @bool noCheckEntity If true, entity checks will be skipped.
    -- @usage
    -- item:setQuantity(10, {player1}, true)
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

    ITEM.SetQuantity = ITEM.setQuantity
    --- Performs an interaction action with the item.
    -- @realm server
    -- @string action The interaction action to perform.
    -- @client client The player performing the interaction.
    -- @entity entity The entity associated with the interaction, if any.
    -- @tab data Additional data related to the interaction.
    -- @treturn Boolean Whether the interaction was successful.
    -- @usage
    -- if item:interact("use", player, entity, data) then
    --     print("Interaction successful.")
    -- else
    --     print("Interaction failed.")
    -- end
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
        lia.log.add(client, "itemInteraction", action, self)
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
    -- @treturn String The name of the item.
    -- @usage
    -- local name = item:getName()
    -- print("Item Name:", name)
    function ITEM:getName()
        return L(self.name)
    end

    ITEM.GetName = ITEM.getName
    --- Returns the description of the item.
    -- @realm client
    -- @treturn String The description of the item.
    -- @usage
    -- local desc = item:getDesc()
    -- print("Item Description:", desc)
    function ITEM:getDesc()
        return L(self.desc)
    end

    ITEM.GetDescription = ITEM.getDesc
end

ITEM.GetItems = ITEM.getItems
ITEM.GetItemsOfType = ITEM.getItemsOfType
ITEM.GetFirstItemOfType = ITEM.getFirstItemOfType
ITEM.HasItem = ITEM.hasItem
ITEM.GetItemCount = ITEM.getItemCount
ITEM.GetID = ITEM.getID
ITEM.GetData = ITEM.getData
ITEM.Show = ITEM.show
lia.meta.item = ITEM