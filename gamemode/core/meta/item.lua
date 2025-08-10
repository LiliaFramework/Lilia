local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "invalidName"
ITEM.desc = ITEM.desc or "invalidDescription"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
--[[
    isRotated

    Purpose:
        Checks if the item is currently rotated.

    Returns:
        boolean - True if the item is rotated, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if item:isRotated() then
            print("The item is rotated!")
        end
]]
function ITEM:isRotated()
    return self:getData("rotated", false)
end

--[[
    getWidth

    Purpose:
        Returns the width of the item, taking into account its rotation.

    Returns:
        number - The width of the item.

    Realm:
        Shared.

    Example Usage:
        local width = item:getWidth()
        print("Item width: " .. width)
]]
function ITEM:getWidth()
    return self:isRotated() and (self.height or 1) or self.width or 1
end

--[[
    getHeight

    Purpose:
        Returns the height of the item, taking into account its rotation.

    Returns:
        number - The height of the item.

    Realm:
        Shared.

    Example Usage:
        local height = item:getHeight()
        print("Item height: " .. height)
]]
function ITEM:getHeight()
    return self:isRotated() and (self.width or 1) or self.height or 1
end

--[[
    getQuantity

    Purpose:
        Returns the current quantity of the item.

    Returns:
        number - The quantity of the item.

    Realm:
        Shared.

    Example Usage:
        print("You have " .. item:getQuantity() .. " of this item.")
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    eq

    Purpose:
        Checks if this item is equal to another item by comparing their IDs.

    Parameters:
        other (Item) - The other item to compare.

    Returns:
        boolean - True if the items are equal, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if item:eq(otherItem) then
            print("These items are the same instance.")
        end
]]
function ITEM:eq(other)
    return self:getID() == other:getID()
end

--[[
    tostring

    Purpose:
        Returns a string representation of the item.

    Returns:
        string - The string representation of the item.

    Realm:
        Shared.

    Example Usage:
        print(item:tostring())
]]
function ITEM:tostring()
    return L("item") .. "[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    getID

    Purpose:
        Returns the ID of the item.

    Returns:
        number - The ID of the item.

    Realm:
        Shared.

    Example Usage:
        print("Item ID: " .. item:getID())
]]
function ITEM:getID()
    return self.id
end

--[[
    getModel

    Purpose:
        Returns the model of the item.

    Returns:
        string - The model path of the item.

    Realm:
        Shared.

    Example Usage:
        print("Model path: " .. item:getModel())
]]
function ITEM:getModel()
    return self.model
end

--[[
    getSkin

    Purpose:
        Returns the skin index of the item.

    Returns:
        number - The skin index.

    Realm:
        Shared.

    Example Usage:
        print("Skin index: " .. tostring(item:getSkin()))
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    getPrice

    Purpose:
        Returns the price of the item, using a custom calculation if available.

    Returns:
        number - The price of the item.

    Realm:
        Shared.

    Example Usage:
        print("Item price: " .. item:getPrice())
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    call

    Purpose:
        Calls a method on the item, temporarily setting the player and entity context.

    Parameters:
        method (string) - The method name to call.
        client (Player) - The player context.
        entity (Entity) - The entity context.
        ... - Additional arguments to pass to the method.

    Returns:
        ... - The return values of the called method.

    Realm:
        Shared.

    Example Usage:
        item:call("onUse", client, entity, arg1, arg2)
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
    getOwner

    Purpose:
        Returns the player who owns this item.

    Returns:
        Player - The owner of the item, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local owner = item:getOwner()
        if owner then
            print("Item owner: " .. owner:Name())
        end
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
    getData

    Purpose:
        Returns the value of a data key for this item, checking both local and entity data.

    Parameters:
        key (string) - The data key to retrieve.
        default (any) - The default value if the key is not found.

    Returns:
        any - The value of the data key, or the default.

    Realm:
        Shared.

    Example Usage:
        local durability = item:getData("durability", 100)
]]
function ITEM:getData(key, default)
    self.data = self.data or {}
    local value = self.data[key]
    if value ~= nil then return value end
    if IsValid(self.entity) then
        local data = self.entity:getNetVar("data", {})
        value = data[key]
        if value ~= nil then return value end
    end
    return default
end

--[[
    getAllData

    Purpose:
        Returns a table containing all data for this item, including entity data.

    Returns:
        table - A table of all data for the item.

    Realm:
        Shared.

    Example Usage:
        PrintTable(item:getAllData())
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
    hook

    Purpose:
        Registers a hook function for a specific event on this item.

    Parameters:
        name (string) - The name of the hook/event.
        func (function) - The function to call.

    Realm:
        Shared.

    Example Usage:
        item:hook("onUse", function(self, data) print("Used!") end)
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    postHook

    Purpose:
        Registers a post-hook function for a specific event on this item.

    Parameters:
        name (string) - The name of the post-hook/event.
        func (function) - The function to call.

    Realm:
        Shared.

    Example Usage:
        item:postHook("onUse", function(self, result, data) print("Post-use!") end)
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    onRegistered

    Purpose:
        Called when the item is registered. Precaches the model if set.

    Realm:
        Shared.

    Example Usage:
        -- Called automatically when the item is registered.
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    print

    Purpose:
        Prints information about the item to the console.

    Parameters:
        detail (boolean) - Whether to print detailed information.

    Realm:
        Shared.

    Example Usage:
        item:print(true)
]]
function ITEM:print(detail)
    if detail then
        print(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        print(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--[[
    printData

    Purpose:
        Prints all data associated with the item to the console.

    Realm:
        Shared.

    Example Usage:
        item:printData()
]]
function ITEM:printData()
    self:print(true)
    lia.information(L("itemData") .. ":")
    for k, v in pairs(self.data) do
        lia.information(L("itemDataEntry", k, v))
    end
end

if SERVER then
    --[[
        getName

        Purpose:
            Returns the name of the item.

        Returns:
            string - The name of the item.

        Realm:
            Server.

        Example Usage:
            print(item:getName())
    ]]
    function ITEM:getName()
        return self.name
    end

    --[[
        getDesc

        Purpose:
            Returns the description of the item.

        Returns:
            string - The description of the item.

        Realm:
            Server.

        Example Usage:
            print(item:getDesc())
    ]]
    function ITEM:getDesc()
        return self.desc
    end

    --[[
        removeFromInventory

        Purpose:
            Removes the item from its inventory.

        Parameters:
            preserveItem (boolean) - Whether to preserve the item instance.

        Returns:
            Deferred - A deferred object that resolves when removal is complete.

        Realm:
            Server.

        Example Usage:
            item:removeFromInventory(true):next(function() print("Removed!") end)
    ]]
    function ITEM:removeFromInventory(preserveItem)
        local inventory = lia.inventory.instances[self.invID]
        self.invID = 0
        if inventory then return inventory:removeItem(self:getID(), preserveItem) end
        local d = deferred.new()
        d:resolve()
        return d
    end

    --[[
        delete

        Purpose:
            Deletes the item from the database and calls onRemoved.

        Returns:
            Deferred - A deferred object that resolves when deletion is complete.

        Realm:
            Server.

        Example Usage:
            item:delete():next(function() print("Deleted!") end)
    ]]
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "_itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --[[
        remove

        Purpose:
            Removes the item from the world and inventory, then deletes it.

        Returns:
            Deferred - A deferred object that resolves when removal is complete.

        Realm:
            Server.

        Example Usage:
            item:remove():next(function() print("Item fully removed!") end)
    ]]
    function ITEM:remove()
        local d = deferred.new()
        if IsValid(self.entity) then SafeRemoveEntity(self.entity) end
        self:removeFromInventory():next(function()
            d:resolve()
            return self:delete()
        end)
        return d
    end

    --[[
        destroy

        Purpose:
            Destroys the item instance and notifies clients.

        Realm:
            Server.

        Example Usage:
            item:destroy()
    ]]
    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    --[[
        onDisposed

        Purpose:
            Called when the item is disposed.

        Realm:
            Server.

        Example Usage:
            -- Override in your item definition if needed.
    ]]
    function ITEM:onDisposed()
    end

    --[[
        getEntity

        Purpose:
            Returns the entity associated with this item.

        Returns:
            Entity - The entity, or nil if not found.

        Realm:
            Server.

        Example Usage:
            local ent = item:getEntity()
            if ent then print("Entity found!") end
    ]]
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --[[
        spawn

        Purpose:
            Spawns the item as an entity in the world.

        Parameters:
            position (Vector or table or Player) - The position or player to drop at.
            angles (Angle or table) - The angles to spawn with.

        Returns:
            Entity - The spawned entity, or nil if failed.

        Realm:
            Server.

        Example Usage:
            local ent = item:spawn(Vector(0,0,0))
    ]]
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

            position = lia.data.decode(position)
            if not isvector(position) and istable(position) then
                local x = tonumber(position.x or position[1])
                local y = tonumber(position.y or position[2])
                local z = tonumber(position.z or position[3])
                if x and y and z then position = Vector(x, y, z) end
            end

            if angles then
                angles = lia.data.decode(angles)
                if not isangle(angles) then
                    if isvector(angles) then
                        angles = Angle(angles.x, angles.y, angles.z)
                    elseif istable(angles) then
                        local p = tonumber(angles.p or angles[1])
                        local yaw = tonumber(angles.y or angles[2])
                        local r = tonumber(angles.r or angles[3])
                        if p and yaw and r then angles = Angle(p, yaw, r) end
                    end
                end
            end

            local entity = ents.Create("lia_item")
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or angle_zero)
            entity:setItem(self.id)
            instance.entity = entity
            if IsValid(client) then
                entity.SteamID = client:SteamID()
                entity.liaCharID = client:getChar():getID()
                entity:SetCreator(client)
            end
            return entity
        end
    end

    --[[
        transfer

        Purpose:
            Transfers the item to a new inventory.

        Parameters:
            newInventory (Inventory) - The inventory to transfer to.
            bBypass (boolean) - Whether to bypass access checks.

        Returns:
            boolean - True if transfer started, false otherwise.

        Realm:
            Server.

        Example Usage:
            item:transfer(newInventory)
    ]]
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --[[
        onInstanced

        Purpose:
            Called when the item is instanced.

        Realm:
            Server.

        Example Usage:
            -- Override in your item definition if needed.
    ]]
    function ITEM:onInstanced()
    end

    --[[
        onSync

        Purpose:
            Called when the item is synced to a client.

        Realm:
            Server.

        Example Usage:
            -- Override in your item definition if needed.
    ]]
    function ITEM:onSync()
    end

    --[[
        onRemoved

        Purpose:
            Called when the item is removed.

        Realm:
            Server.

        Example Usage:
            -- Override in your item definition if needed.
    ]]
    function ITEM:onRemoved()
    end

    --[[
        onRestored

        Purpose:
            Called when the item is restored.

        Realm:
            Server.

        Example Usage:
            -- Override in your item definition if needed.
    ]]
    function ITEM:onRestored()
    end

    --[[
        sync

        Purpose:
            Syncs the item instance to a recipient or all clients.

        Parameters:
            recipient (Player) - The player to sync to, or nil for all.

        Realm:
            Server.

        Example Usage:
            item:sync(client)
    ]]
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

    --[[
        setData

        Purpose:
            Sets a data key for the item and syncs it to clients and the database.

        Parameters:
            key (string) - The data key.
            value (any) - The value to set.
            receivers (Player or table) - The recipients to sync to.
            noSave (boolean) - If true, do not save to the database.
            noCheckEntity (boolean) - If true, do not update the entity.

        Realm:
            Server.

        Example Usage:
            item:setData("durability", 50)
    ]]
    function ITEM:setData(key, value, receivers, noSave, noCheckEntity)
        self.data = self.data or {}
        self.data[key] = value
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("data", self.data) end
        end

        if receivers or self:getOwner() then
            net.Start("invData")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(value)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        if key == "x" or key == "y" then
            value = tonumber(value)
            if MYSQLOO_PREPARED then
                lia.db.preparedCall("item" .. key, nil, value, self:getID())
            else
                lia.db.updateTable({
                    [key] = value
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
                data = self.data
            }, nil, "items", "_itemID = " .. self:getID())
        end

        self.data.x, self.data.y = x, y
    end

    --[[
        addQuantity

        Purpose:
            Adds to the item's quantity and updates clients/entities.

        Parameters:
            quantity (number) - The amount to add.
            receivers (Player or table) - The recipients to sync to.
            noCheckEntity (boolean) - If true, do not update the entity.

        Realm:
            Server.

        Example Usage:
            item:addQuantity(5)
    ]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
        setQuantity

        Purpose:
            Sets the item's quantity and updates clients/entities and the database.

        Parameters:
            quantity (number) - The new quantity.
            receivers (Player or table) - The recipients to sync to.
            noCheckEntity (boolean) - If true, do not update the entity.

        Realm:
            Server.

        Example Usage:
            item:setQuantity(10)
    ]]
    function ITEM:setQuantity(quantity, receivers, noCheckEntity)
        self.quantity = quantity
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("quantity", self.quantity) end
        end

        if receivers or self:getOwner() then
            net.Start("invQuantity")
            net.WriteUInt(self:getID(), 32)
            net.WriteUInt(self.quantity, 32)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        if MYSQLOO_PREPARED then
            lia.db.preparedCall("itemq", nil, self.quantity, self:getID())
        else
            lia.db.updateTable({
                quantity = self.quantity
            }, nil, "items", "_itemID = " .. self:getID())
        end
    end

    --[[
        interact

        Purpose:
            Handles a player interaction with the item.

        Parameters:
            action (string) - The action to perform.
            client (Player) - The player interacting.
            entity (Entity) - The entity involved.
            data (any) - Additional data for the interaction.

        Returns:
            boolean - True if the interaction was successful, false otherwise.

        Realm:
            Server.

        Example Usage:
            item:interact("use", client, entity, data)
    ]]
    function ITEM:interact(action, client, entity, data)
        assert(client:IsPlayer() and IsValid(client), L("itemActionNoPlayer"))
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

        if result == nil then
            local isMulti = callback.isMulti or (callback.multiOptions and istable(callback.multiOptions))
            if isMulti and isstring(data) and callback.multiOptions then
                local optionFunc = callback.multiOptions[data]
                if optionFunc then
                    if isfunction(optionFunc) then
                        result = optionFunc(self)
                    elseif istable(optionFunc) then
                        local runFunc = optionFunc[1] or optionFunc.onRun
                        if isfunction(runFunc) then
                            result = runFunc(self)
                        end
                    end
                end
            elseif isfunction(callback.onRun) then
                result = callback.onRun(self, data)
            end
        end

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
    --[[
        getName

        Purpose:
            Returns the name of the item.

        Returns:
            string - The name of the item.

        Realm:
            Client.

        Example Usage:
            print(item:getName())
    ]]
    function ITEM:getName()
        return self.name
    end

    --[[
        getDesc

        Purpose:
            Returns the description of the item.

        Returns:
            string - The description of the item.

        Realm:
            Client.

        Example Usage:
            print(item:getDesc())
    ]]
    function ITEM:getDesc()
        return self.desc
    end
end

--[[
    getCategory

    Purpose:
        Returns the category of the item with automatic localization.

    Returns:
        string - The localized category of the item.

    Realm:
        Shared.

    Example Usage:
        print("Item category: " .. item:getCategory())
]]
function ITEM:getCategory()
    return self.category and L(self.category) or L("misc")
end

lia.meta.item = ITEM