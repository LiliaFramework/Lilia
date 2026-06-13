--[[
    Folder: Developer - Meta Tables
    File: item.md
]]
--[[
    Item

    Item metadata helpers for sizing, ownership, persistence, interaction, and world spawning.
]]
--[[
    Overview:
        The item meta table wraps a registered or instanced item and exposes helpers for dimensions, quantity, pricing, ownership lookup, item data access, interaction hooks, networking, inventory transfer, persistence, and server-side entity spawning and cleanup.
]]
local ITEM = lia.meta.item or {}
debug.getregistry().Item = lia.meta.item
ITEM.__index = ITEM
ITEM.name = "@invalidName"
ITEM.desc = ITEM.desc or "@invalidDescription"
ITEM.id = ITEM.id or 0
ITEM.uniqueID = "undefined"
ITEM.isItem = true
ITEM.isStackable = false
ITEM.quantity = 1
ITEM.maxQuantity = 1
ITEM.canSplit = true
ITEM.scale = 1
--[[
    Purpose:
        Returns whether the item is marked as rotated in its stored data.

    Parameters:
        None

    Returns:
        boolean
            `true` when the item is rotated, otherwise `false`.

    Example Usage:
        ```lua
        if item:isRotated() then
            print("Item is rotated")
        end
        ```

    Realm:
        Shared
]]
function ITEM:isRotated()
    return self:getData("rotated", false)
end

--[[
    Purpose:
        Returns the item's effective width, accounting for rotation.

    Parameters:
        None

    Returns:
        number
            The width used for inventory placement.

    Example Usage:
        ```lua
        local width = item:getWidth()
        ```

    Realm:
        Shared
]]
function ITEM:getWidth()
    return self:isRotated() and (self.height or 1) or self.width or 1
end

--[[
    Purpose:
        Returns the item's effective height, accounting for rotation.

    Parameters:
        None

    Returns:
        number
            The height used for inventory placement.

    Example Usage:
        ```lua
        local height = item:getHeight()
        ```

    Realm:
        Shared
]]
function ITEM:getHeight()
    return self:isRotated() and (self.width or 1) or self.height or 1
end

--[[
    Purpose:
        Returns the current quantity for this item instance.

    Parameters:
        None

    Returns:
        number
            The item quantity, or `maxQuantity` for non-instanced items.

    Example Usage:
        ```lua
        local quantity = item:getQuantity()
        ```

    Realm:
        Shared
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    Purpose:
        Builds a debug-friendly string representation of the item.

    Parameters:
        None

    Returns:
        string
            A formatted identifier containing the item unique ID and instance ID.

    Example Usage:
        ```lua
        print(item:tostring())
        ```

    Realm:
        Shared
]]
function ITEM:tostring()
    return L("item") .. "[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    Purpose:
        Returns the numeric instance ID of this item.

    Parameters:
        None

    Returns:
        number
            The item instance ID.

    Example Usage:
        ```lua
        local id = item:getID()
        ```

    Realm:
        Shared
]]
function ITEM:getID()
    return self.id
end

--[[
    Purpose:
        Returns the model path assigned to this item.

    Parameters:
        None

    Returns:
        string
            The item model path.

    Example Usage:
        ```lua
        local model = item:getModel()
        ```

    Realm:
        Shared
]]
function ITEM:getModel()
    return self.model
end

--[[
    Purpose:
        Returns the skin index used by this item.

    Parameters:
        None

    Returns:
        number
            The configured skin index.

    Example Usage:
        ```lua
        local skin = item:getSkin()
        ```

    Realm:
        Shared
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    Purpose:
        Returns the bodygroups configured for this item.

    Parameters:
        None

    Returns:
        table
            A bodygroup mapping table, or an empty table when unset.

    Example Usage:
        ```lua
        local bodygroups = item:getBodygroups()
        ```

    Realm:
        Shared
]]
function ITEM:getBodygroups()
    return self.bodygroups or {}
end

--[[
    Purpose:
        Returns the price of the item, using `calcPrice` when available.

    Parameters:
        None

    Returns:
        number
            The resolved price, or `0` when no price is set.

    Example Usage:
        ```lua
        local price = item:getPrice()
        ```

    Realm:
        Shared
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    Purpose:
        Calls an item method while temporarily setting `self.player` and `self.entity`.

    Parameters:
        method (string)
            The item method name to invoke.
        client (Player|nil)
            The player context for the call.
        entity (Entity|nil)
            The entity context for the call.
        ... (any)
            Additional arguments forwarded to the method.

    Returns:
        any
            Returns whatever values the called method returns.

    Example Usage:
        ```lua
        item:call("onUse", client, entity, extraData)
        ```

    Realm:
        Shared
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
    Purpose:
        Attempts to find the player that currently owns this item.

    Parameters:
        None

    Returns:
        Player|nil
            The owning player when found.

    Example Usage:
        ```lua
        local owner = item:getOwner()
        ```

    Realm:
        Shared
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
    Purpose:
        Returns a stored data value for this item.

    Parameters:
        key (string)
            The data key to look up.
        default (any)
            The fallback value to return when the key is missing.

    Returns:
        any
            The stored value or the provided default.

    Example Usage:
        ```lua
        local durability = item:getData("durability", 100)
        ```

    Realm:
        Shared
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
    Purpose:
        Returns all stored data for this item, including synced entity data.

    Parameters:
        None

    Returns:
        table
            A merged table of item data values.

    Example Usage:
        ```lua
        local data = item:getAllData()
        ```

    Realm:
        Shared
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
    Purpose:
        Registers a pre-action hook for an item interaction function.

    Parameters:
        name (string)
            The interaction name to hook.
        func (function)
            The function to run before the default action logic.

    Returns:
        None

    Example Usage:
        ```lua
        item:hook("drop", function(self, data) end)
        ```

    Realm:
        Shared
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    Purpose:
        Registers a post-action hook for an item interaction function.

    Parameters:
        name (string)
            The interaction name to hook.
        func (function)
            The function to run after the action completes.

    Returns:
        None

    Example Usage:
        ```lua
        item:postHook("drop", function(self, result, data) end)
        ```

    Realm:
        Shared
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    Purpose:
        Runs when the item is registered and precaches its model when present.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        item:onRegistered()
        ```

    Realm:
        Shared
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    Purpose:
        Prints item information to the framework log output.

    Parameters:
        detail (boolean)
            Whether to include ownership and grid position details.

    Returns:
        None

    Example Usage:
        ```lua
        item:print(true)
        ```

    Realm:
        Shared
]]
function ITEM:print(detail)
    if detail then
        lia.information(Format("%s[%s]: >> [%s](%s,%s)", self.uniqueID, self.id, self.owner, self.gridX, self.gridY))
    else
        lia.information(Format("%s[%s]", self.uniqueID, self.id))
    end
end

--[[
    Purpose:
        Prints the item and each of its stored data entries.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        item:printData()
        ```

    Realm:
        Shared
]]
function ITEM:printData()
    self:print(true)
    lia.information(L("itemData") .. ":")
    for k, v in pairs(self.data) do
        lia.information(L("itemDataEntry", k, v))
    end
end

--[[
    Purpose:
        Returns the configured display name of the item.

    Parameters:
        None

    Returns:
        string
            The item name.

    Example Usage:
        ```lua
        local name = item:getName()
        ```

    Realm:
        Shared
]]
function ITEM:getName()
    return self.name
end

--[[
    Purpose:
        Returns the configured description of the item.

    Parameters:
        None

    Returns:
        string
            The item description.

    Example Usage:
        ```lua
        local desc = item:getDesc()
        ```

    Realm:
        Shared
]]
function ITEM:getDesc()
    return self.desc
end

if SERVER then
    --[[
    Purpose:
        Removes the item from its current inventory.

    Parameters:
        preserveItem (boolean)
            Whether the inventory should preserve the item instance after removal.

    Returns:
        Deferred
            A deferred object that resolves when removal completes.

    Example Usage:
        ```lua
        item:removeFromInventory()
        ```

    Realm:
        Server
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
    Purpose:
        Deletes the item from runtime state and the database.

    Parameters:
        None

    Returns:
        Deferred
            A promise chain for the database delete operation.

    Example Usage:
        ```lua
        item:delete()
        ```

    Realm:
        Server
]]
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --[[
    Purpose:
        Removes the item's entity, inventory entry, and database record.

    Parameters:
        None

    Returns:
        Deferred
            A deferred object that resolves before the delete finishes.

    Example Usage:
        ```lua
        item:remove()
        ```

    Realm:
        Server
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
    Purpose:
        Disposes of the item instance from synced runtime storage.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        item:destroy()
        ```

    Realm:
        Server
]]
    function ITEM:destroy()
        net.Start("liaItemDelete")
        net.WriteUInt(self:getID(), 32)
        net.Broadcast()
        lia.item.instances[self:getID()] = nil
        self:onDisposed()
    end

    --[[
    Purpose:
        Hook called after the item is disposed from runtime storage.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        function ITEM:onDisposed() end
        ```

    Realm:
        Server
]]
    function ITEM:onDisposed()
    end

    --[[
    Purpose:
        Finds the spawned world entity that belongs to this item instance.

    Parameters:
        None

    Returns:
        Entity|nil
            The world entity for this item, if one exists.

    Example Usage:
        ```lua
        local ent = item:getEntity()
        ```

    Realm:
        Server
]]
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --[[
    Purpose:
        Spawns this item into the world at a position or for a player.

    Parameters:
        position (Vector|table|Player)
            A world position, encoded position data, or a player drop source.
        angles (Angle|Vector|table|nil)
            Optional angles for the spawned entity.

    Returns:
        Entity|nil
            The spawned `lia_item` entity when successful.

    Example Usage:
        ```lua
        local ent = item:spawn(client)
        ```

    Realm:
        Server
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
            if not IsValid(entity) then return nil end
            entity:Spawn()
            entity:SetPos(position)
            entity:SetAngles(angles or angle_zero)
            entity:setItem(self.id)
            instance.entity = entity
            if self.scale and self.scale ~= 1 then entity:SetModelScale(self.scale) end
            if IsValid(client) then
                entity.SteamID = client:SteamID()
                if client:getChar() then
                    entity.liaCharID = client:getChar():getID()
                else
                    entity.liaCharID = 0
                end

                entity:SetCreator(client)
            end
            return entity
        end
    end

    --[[
    Purpose:
        Transfers the item into another inventory.

    Parameters:
        newInventory (Inventory)
            The destination inventory.
        bBypass (boolean)
            Whether to bypass transfer access checks.

    Returns:
        boolean
            `true` when the transfer is started, otherwise `false`.

    Example Usage:
        ```lua
        item:transfer(targetInventory)
        ```

    Realm:
        Server
]]
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --[[
    Purpose:
        Hook called when an item instance is first created.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        function ITEM:onInstanced() end
        ```

    Realm:
        Server
]]
    function ITEM:onInstanced()
    end

    --[[
    Purpose:
        Hook called after the item is synced to one or more clients.

    Parameters:
        recipient (Player|table|nil)
            The sync recipient, or `nil` when broadcasted.

    Returns:
        None

    Example Usage:
        ```lua
        function ITEM:onSync(recipient) end
        ```

    Realm:
        Server
]]
    function ITEM:onSync()
    end

    --[[
    Purpose:
        Hook called after the item is removed from persistent storage.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        function ITEM:onRemoved() end
        ```

    Realm:
        Server
]]
    function ITEM:onRemoved()
    end

    --[[
    Purpose:
        Hook called after an item is restored from persistent storage.

    Parameters:
        None

    Returns:
        None

    Example Usage:
        ```lua
        function ITEM:onRestored() end
        ```

    Realm:
        Server
]]
    function ITEM:onRestored()
    end

    --[[
    Purpose:
        Syncs this item instance to clients over the network.

    Parameters:
        recipient (Player|table|nil)
            The recipient to send to, or `nil` to broadcast.

    Returns:
        None

    Example Usage:
        ```lua
        item:sync(client)
        ```

    Realm:
        Server
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
    Purpose:
        Sets a stored data value, syncs it, and optionally saves it.

    Parameters:
        key (string)
            The data key to set.
        value (any)
            The value to store.
        receivers (Player|table|nil)
            Optional recipients for the data update net message.
        noSave (boolean)
            Whether to skip database persistence.
        noCheckEntity (boolean)
            Whether to skip updating the spawned entity netvars.

    Returns:
        None

    Example Usage:
        ```lua
        item:setData("durability", 75)
        ```

    Realm:
        Server
]]
    function ITEM:setData(key, value, receivers, noSave, noCheckEntity)
        self.data = self.data or {}
        self.data[key] = value
        if not noCheckEntity then
            local entity = self:getEntity()
            if IsValid(entity) then entity:setNetVar("data", self.data) end
        end

        if receivers or self:getOwner() then
            net.Start("liaInvData")
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
            lia.db.updateTable({
                [key] = value
            }, nil, "items", "itemID = " .. self:getID())
            return
        end

        local x, y = self.data.x, self.data.y
        self.data.x, self.data.y = nil, nil
        lia.db.updateTable({
            data = self.data
        }, nil, "items", "itemID = " .. self:getID())

        self.data.x, self.data.y = x, y
    end

    --[[
    Purpose:
        Increases the item's quantity by the provided amount.

    Parameters:
        quantity (number)
            The amount to add.
        receivers (Player|table|nil)
            Optional recipients for the quantity update.
        noCheckEntity (boolean)
            Whether to skip updating the spawned entity netvars.

    Returns:
        None

    Example Usage:
        ```lua
        item:addQuantity(5)
        ```

    Realm:
        Server
]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
    Purpose:
        Sets the item's quantity, syncs it, and saves it.

    Parameters:
        quantity (number)
            The new quantity value.
        receivers (Player|table|nil)
            Optional recipients for the quantity update.
        noCheckEntity (boolean)
            Whether to skip updating the spawned entity netvars.

    Returns:
        None

    Example Usage:
        ```lua
        item:setQuantity(10)
        ```

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
            net.Start("liaInvQuantity")
            net.WriteUInt(self:getID(), 32)
            net.WriteUInt(self.quantity, 32)
            if receivers then
                net.Send(receivers)
            else
                net.Send(self:getOwner())
            end
        end

        if noSave or not lia.db then return end
        lia.db.updateTable({
            quantity = self.quantity
        }, nil, "items", "itemID = " .. self:getID())
    end

    --[[
    Purpose:
        Runs an item interaction action for a player.

    Parameters:
        action (string)
            The action identifier to execute.
        client (Player)
            The player interacting with the item.
        entity (Entity|nil)
            The item world entity involved in the interaction.
        data (any)
            Additional action-specific payload.

    Returns:
        boolean
            `true` when the action was handled, otherwise `false`.

    Example Usage:
        ```lua
        item:interact("use", client, entity)
        ```

    Realm:
        Server
]]
    function ITEM:interact(action, client, entity, data)
        assert(client:IsPlayer() and IsValid(client), L("itemActionNoPlayer"))
        local canInteract, reason = hook.Run("CanPlayerInteractItem", client, action, self, data)
        if canInteract == false then
            if reason then client:notifyErrorLocalized(reason) end
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
            local multiOptions = callback.multiOptions
            local isMulti = callback.isMulti or istable(multiOptions) or isfunction(multiOptions)
            if isMulti and multiOptions then
                local options = istable(multiOptions) and multiOptions or multiOptions(self, client)
                if istable(options) then
                    local optionFunc = options[data] or options[tostring(data)] or options[tonumber(data)]
                    if optionFunc then
                        if isfunction(optionFunc) then
                            result = optionFunc(self, data)
                        elseif istable(optionFunc) then
                            local runFunc = optionFunc[1] or optionFunc.onRun
                            if isfunction(runFunc) then result = runFunc(self, data) end
                        end
                    end
                end
            end

            if result == nil and isfunction(callback.onRun) then result = callback.onRun(self, data) end
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
end

--[[
    Purpose:
        Returns the item's category, defaulting to the localized misc category.

    Parameters:
        None

    Returns:
        string
            The resolved item category name.

    Example Usage:
        ```lua
        local category = item:getCategory()
        ```

    Realm:
        Shared
]]
function ITEM:getCategory()
    return self.category or lia.lang.resolveToken("@misc")
end

lia.meta.item = ITEM
