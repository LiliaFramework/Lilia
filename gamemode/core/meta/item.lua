--[[
    Folder: Meta
    File:  item.md
]]
--[[
    Item Meta

    Item management system for the Lilia framework.
]]
--[[
    Overview:
        The item meta table provides comprehensive functionality for managing item data, properties, and operations in the Lilia framework. It handles item creation, data persistence, inventory management, stacking, rotation, and item-specific operations. The meta table operates on both server and client sides, with the server managing item storage and validation while the client provides item data access and display. It includes integration with the inventory system for item storage, database system for item persistence, and rendering system for item display. The meta table ensures proper item data synchronization, quantity management, rotation handling, and comprehensive item lifecycle management from creation to destruction.
]]
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
ITEM.scale = 1
--[[
    Purpose:
        Reports whether the item is stored in a rotated state.

    When Called:
        Use when calculating grid dimensions or rendering the item icon.

    Parameters:
        None.

    Returns:
        boolean
            True if the item is rotated.

    Realm:
        Shared

    Example Usage:
        ```lua
            if item:isRotated() then swapDims() end
        ```
]]
function ITEM:isRotated()
    return self:getData("rotated", false)
end

--[[
    Purpose:
        Returns the item's width considering rotation and defaults.

    When Called:
        Use when placing the item into a grid inventory.

    Parameters:
        None.

    Returns:
        number
            Width in grid cells.

    Realm:
        Shared

    Example Usage:
        ```lua
            local w = item:getWidth()
        ```
]]
function ITEM:getWidth()
    return self:isRotated() and (self.height or 1) or self.width or 1
end

--[[
    Purpose:
        Returns the item's height considering rotation and defaults.

    When Called:
        Use when calculating how much vertical space an item needs.

    Parameters:
        None.

    Returns:
        number
            Height in grid cells.

    Realm:
        Shared

    Example Usage:
        ```lua
            local h = item:getHeight()
        ```
]]
function ITEM:getHeight()
    return self:isRotated() and (self.width or 1) or self.height or 1
end

--[[
    Purpose:
        Returns the current stack quantity for this item.

    When Called:
        Use when showing stack counts or validating transfers.

    Parameters:
        None.

    Returns:
        number
            Quantity within the stack.

    Realm:
        Shared

    Example Usage:
        ```lua
            local count = item:getQuantity()
        ```
]]
function ITEM:getQuantity()
    if self.id == 0 then return self.maxQuantity end
    return self.quantity
end

--[[
    Purpose:
        Builds a readable string identifier for the item.

    When Called:
        Use for logging, debugging, or console output.

    Parameters:
        None.

    Returns:
        string
            Formatted identifier including uniqueID and item id.

    Realm:
        Shared

    Example Usage:
        ```lua
            print(item:tostring())
        ```
]]
function ITEM:tostring()
    return L("item") .. "[" .. self.uniqueID .. "][" .. self.id .. "]"
end

--[[
    Purpose:
        Retrieves the numeric identifier for this item instance.

    When Called:
        Use when persisting, networking, or comparing items.

    Parameters:
        None.

    Returns:
        number
            Unique item ID.

    Realm:
        Shared

    Example Usage:
        ```lua
            local id = item:getID()
        ```
]]
function ITEM:getID()
    return self.id
end

--[[
    Purpose:
        Returns the model path assigned to this item.

    When Called:
        Use when spawning an entity or rendering the item icon.

    Parameters:
        None.

    Returns:
        string
            Model file path.

    Realm:
        Shared

    Example Usage:
        ```lua
            local mdl = item:getModel()
        ```
]]
function ITEM:getModel()
    return self.model
end

--[[
    Purpose:
        Returns the skin index assigned to this item.

    When Called:
        Use when spawning the entity or applying cosmetics.

    Parameters:
        None.

    Returns:
        number|nil
            Skin index or nil when not set.

    Realm:
        Shared

    Example Usage:
        ```lua
            local skin = item:getSkin()
        ```
]]
function ITEM:getSkin()
    return self.skin
end

--[[
    Purpose:
        Provides the bodygroup configuration for the item model.

    When Called:
        Use when spawning or rendering to ensure correct bodygroups.

    Parameters:
        None.

    Returns:
        table
            Key-value pairs of bodygroup indexes to values.

    Realm:
        Shared

    Example Usage:
        ```lua
            local groups = item:getBodygroups()
        ```
]]
function ITEM:getBodygroups()
    return self.bodygroups or {}
end

--[[
    Purpose:
        Calculates the current sale price for the item.

    When Called:
        Use when selling, buying, or displaying item cost.

    Parameters:
        None.

    Returns:
        number
            Price value, possibly adjusted by calcPrice.

    Realm:
        Shared

    Example Usage:
        ```lua
            local cost = item:getPrice()
        ```
]]
function ITEM:getPrice()
    local price = self.price
    if self.calcPrice then price = self:calcPrice(self.price) end
    return price or 0
end

--[[
    Purpose:
        Invokes an item method while temporarily setting context.

    When Called:
        Use when you need to call an item function with player/entity context.

    Parameters:
        method (string)
            Name of the item method to invoke.
        client (Player|nil)
            Player to treat as the caller.
        entity (Entity|nil)
            Entity representing the item.
        ... (any)
            Additional arguments passed to the method.

    Returns:
        any
            Return values from the invoked method.

    Realm:
        Shared

    Example Usage:
        ```lua
            item:call("onUse", ply, ent)
        ```
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

    When Called:
        Use when routing notifications or networking to the item owner.

    Parameters:
        None.

    Returns:
        Player|nil
            Owning player if found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local owner = item:getOwner()
        ```
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
        Reads a stored data value from the item or its entity.

    When Called:
        Use for custom item metadata such as durability or rotation.

    Parameters:
        key (string)
            Data key to read.
        default (any)
            Value to return when the key is missing.

    Returns:
        any
            Stored value or default.

    Realm:
        Shared

    Example Usage:
        ```lua
            local durability = item:getData("durability", 100)
        ```
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
        Returns a merged table of all item data, including entity netvars.

    When Called:
        Use when syncing the entire data payload to clients.

    Parameters:
        None.

    Returns:
        table
            Combined data table.

    Realm:
        Shared

    Example Usage:
        ```lua
            local data = item:getAllData()
        ```
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
        Registers a pre-run hook for an item interaction.

    When Called:
        Use when adding custom behavior before an action executes.

    Parameters:
        name (string)
            Hook name to bind.
        func (function)
            Callback to execute.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            item:hook("use", function(itm) end)
        ```
]]
function ITEM:hook(name, func)
    if name then self.hooks[name] = func end
end

--[[
    Purpose:
        Registers a post-run hook for an item interaction.

    When Called:
        Use when you need to react after an action completes.

    Parameters:
        name (string)
            Hook name to bind.
        func (function)
            Callback to execute with results.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            item:postHook("use", function(itm, result) end)
        ```
]]
function ITEM:postHook(name, func)
    if name then self.postHooks[name] = func end
end

--[[
    Purpose:
        Performs setup tasks after an item definition is registered.

    When Called:
        Automatically invoked once the item type is loaded.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            item:onRegistered()
        ```
]]
function ITEM:onRegistered()
    if self.model and isstring(self.model) then util.PrecacheModel(self.model) end
end

--[[
    Purpose:
        Prints a concise or detailed identifier for the item.

    When Called:
        Use during debugging or admin commands.

    Parameters:
        detail (boolean)
            Include owner and grid info when true.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            item:print(true)
        ```
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
        Outputs item metadata and all stored data fields.

    When Called:
        Use for diagnostics to inspect an item's state.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            item:printData()
        ```
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
        Returns the display name of the item.

    When Called:
        Use for UI labels, tooltips, and logs.

    Parameters:
        None.

    Returns:
        string
            Item name.

    Realm:
        Shared

    Example Usage:
        ```lua
            local name = item:getName()
        ```
]]
function ITEM:getName()
    return self.name
end

--[[
    Purpose:
        Returns the description text for the item.

    When Called:
        Use in tooltips or inventory details.

    Parameters:
        None.

    Returns:
        string
            Item description.

    Realm:
        Shared

    Example Usage:
        ```lua
            local desc = item:getDesc()
        ```
]]
function ITEM:getDesc()
    return self.desc
end

if SERVER then
    --[[
    Purpose:
        Removes the item from its current inventory instance.

    When Called:
        Use when dropping, deleting, or transferring the item out.

    Parameters:
        preserveItem (boolean)
            When true, keeps the instance for later use.

    Returns:
        Promise
            Deferred resolution for removal completion.

    Realm:
        Server

    Example Usage:
        ```lua
            item:removeFromInventory():next(function() end)
        ```
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
        Deletes the item record from storage after destroying it in-game.

    When Called:
        Use when an item should be permanently removed.

    Parameters:
        None.

    Returns:
        Promise
            Resolves after the database delete and callbacks run.

    Realm:
        Server

    Example Usage:
        ```lua
            item:delete()
        ```
]]
    function ITEM:delete()
        self:destroy()
        return lia.db.delete("items", "itemID = " .. self:getID()):next(function() self:onRemoved() end)
    end

    --[[
    Purpose:
        Removes the world entity, inventory reference, and database entry.

    When Called:
        Use when the item is consumed or otherwise removed entirely.

    Parameters:
        None.

    Returns:
        Promise
            Resolves once removal and deletion complete.

    Realm:
        Server

    Example Usage:
        ```lua
            item:remove()
        ```
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
        Broadcasts item deletion to clients and frees the instance.

    When Called:
        Use internally before removing an item from memory.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            item:destroy()
        ```
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
        Hook called after an item is destroyed; intended for overrides.

    When Called:
        Automatically triggered when the item instance is disposed.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            function ITEM:onDisposed() end
        ```
]]
    function ITEM:onDisposed()
    end

    --[[
    Purpose:
        Finds the world entity representing this item instance.

    When Called:
        Use when needing the spawned entity from the item data.

    Parameters:
        None.

    Returns:
        Entity|nil
            Spawned item entity if present.

    Realm:
        Server

    Example Usage:
        ```lua
            local ent = item:getEntity()
        ```
]]
    function ITEM:getEntity()
        local id = self:getID()
        for _, v in ipairs(ents.FindByClass("lia_item")) do
            if v.liaItemID == id then return v end
        end
    end

    --[[
    Purpose:
        Spawns a world entity for this item at the given position and angle.

    When Called:
        Use when dropping an item into the world.

    Parameters:
        position (Vector|table|Entity)
            Where to spawn, or the player dropping the item.
        angles (Angle|Vector|table|nil)
            Orientation for the spawned entity.

    Returns:
        Entity|nil
            Spawned entity on success.

    Realm:
        Server

    Example Usage:
        ```lua
            local ent = item:spawn(ply, Angle(0, 0, 0))
        ```
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
        Moves the item into another inventory if access rules allow.

    When Called:
        Use when transferring items between containers or players.

    Parameters:
        newInventory (Inventory)
            Destination inventory.
        bBypass (boolean)
            Skip access checks when true.

    Returns:
        boolean
            True if the transfer was initiated.

    Realm:
        Server

    Example Usage:
        ```lua
            item:transfer(otherInv)
        ```
]]
    function ITEM:transfer(newInventory, bBypass)
        if not bBypass and not newInventory:canAccess("transfer") then return false end
        local inventory = lia.inventory.instances[self.invID]
        inventory:removeItem(self.id, true):next(function() newInventory:add(self) end)
        return true
    end

    --[[
    Purpose:
        Hook called when a new item instance is created.

    When Called:
        Automatically invoked after instancing; override to customize.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            function ITEM:onInstanced() end
        ```
]]
    function ITEM:onInstanced()
    end

    --[[
    Purpose:
        Hook called after the item data is synchronized to clients.

    When Called:
        Triggered by sync calls; override for custom behavior.

    Parameters:
        recipient (Player|nil)
            The player who received the sync, or nil for broadcast.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            function ITEM:onSync(ply) end
        ```
]]
    function ITEM:onSync()
    end

    --[[
    Purpose:
        Hook called after the item has been removed from the world/inventory.

    When Called:
        Automatically invoked once deletion finishes.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            function ITEM:onRemoved() end
        ```
]]
    function ITEM:onRemoved()
    end

    --[[
    Purpose:
        Hook called after an item is restored from persistence.

    When Called:
        Automatically invoked after loading an item from the database.

    Parameters:
        None.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            function ITEM:onRestored() end
        ```
]]
    function ITEM:onRestored()
    end

    --[[
    Purpose:
        Sends this item instance to a recipient or all clients for syncing.

    When Called:
        Use after creating or updating an item instance.

    Parameters:
        recipient (Player|nil)
            Specific player to sync; broadcasts when nil.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            item:sync(ply)
        ```
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
        Sets a custom data value on the item, networking and saving as needed.

    When Called:
        Use when updating item metadata that clients or persistence require.

    Parameters:
        key (string)
            Data key to set.
        value (any)
            Value to store.
        receivers (Player|table|nil)
            Targets to send the update to; defaults to owner.
        noSave (boolean)
            Skip database write when true.
        noCheckEntity (boolean)
            Skip updating the world entity netvar when true.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            item:setData("durability", 80, item:getOwner())
        ```
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
        Increases the item quantity by the given amount.

    When Called:
        Use for stacking items or consuming partial quantities.

    Parameters:
        quantity (number)
            Amount to add (can be negative).
        receivers (Player|table|nil)
            Targets to notify; defaults to owner.
        noCheckEntity (boolean)
            Skip updating the entity netvar when true.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            item:addQuantity(-1, ply)
        ```
]]
    function ITEM:addQuantity(quantity, receivers, noCheckEntity)
        self:setQuantity(self:getQuantity() + quantity, receivers, noCheckEntity)
    end

    --[[
    Purpose:
        Sets the item quantity, updating entities, clients, and storage.

    When Called:
        Use after splitting stacks or consuming items.

    Parameters:
        quantity (number)
            New stack amount.
        receivers (Player|table|nil)
            Targets to notify; defaults to owner.
        noCheckEntity (boolean)
            Skip updating the world entity netvar when true.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
            item:setQuantity(5, ply)
        ```
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
        Handles an item interaction action, running hooks and callbacks.

    When Called:
        Use when a player selects an action from an item's context menu.

    Parameters:
        action (string)
            Action identifier from the item's functions table.
        client (Player)
            Player performing the action.
        entity (Entity|nil)
            World entity representing the item, if any.
        data (any)
            Additional data for multi-option actions.

    Returns:
        boolean
            True if the action was processed; false otherwise.

    Realm:
        Server

    Example Usage:
        ```lua
            item:interact("use", ply, ent)
        ```
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
        Returns the item's localized category label.

    When Called:
        Use when grouping or displaying items by category.

    Parameters:
        None.

    Returns:
        string
            Localized category name, or "misc" if undefined.

    Realm:
        Shared

    Example Usage:
        ```lua
            local category = item:getCategory()
        ```
]]
function ITEM:getCategory()
    return self.category and L(self.category) or L("misc")
end

lia.meta.item = ITEM
