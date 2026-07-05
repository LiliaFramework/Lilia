--[[
    Folder: Developer - Meta Tables
    File: inventory.md
]]
--[[
    Inventory

    Inventory metadata helpers for inventory type registration, item lookup, data replication, persistence, access rules, and UI display.
]]
--[[
    Overview:
        The inventory meta table wraps inventory instances and inventory type definitions. It exposes helpers for reading and writing inventory data, registering inventory classes, searching contained items, managing server-side persistence and replication, enforcing access rules, and opening the client inventory interface.
]]
local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--[[
    Purpose:
        Returns a stored inventory data value by key, or a fallback if the key is unset.

    Parameters:
        key (string)
            The inventory data key to look up.
        default (any)
            The fallback value returned when the key is not present.

    Returns:
        any
            The stored value for the key, or the provided default.

    Example Usage:
        ```lua
        local ownerID = inventory:getData("ownerID", 0)
        print("Owner ID:", ownerID)
        ```

    Realm:
        Shared
]]
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

--[[
    Purpose:
        Creates or refreshes a derived inventory class in the debug registry.

    Parameters:
        className (string)
            The registry class name used for the derived inventory table.

    Returns:
        table
            The new subclass table inheriting from this inventory meta table.

    Example Usage:
        ```lua
        local BagInventory = Inventory:extend("liaBagInventory")
        ```

    Realm:
        Shared
]]
function Inventory:extend(className)
    local base = debug.getregistry()[className] or {}
    table.Empty(base)
    base.className = className
    local subClass = table.Inherit(base, self)
    subClass.__index = subClass
    return subClass
end

--[[
    Purpose:
        Serves as an override point for configuring an inventory type before registration completes.

    Parameters:
        config (table)
            The configuration table prepared during registration.

    Returns:
        nil

    Example Usage:
        ```lua
        function BagInventory:configure(config)
            config.data.capacity = {}
        end
        ```

    Realm:
        Shared
]]
function Inventory:configure(config)
end

--[[
    Purpose:
        Registers a callback that runs whenever a specific inventory data key changes.

    Parameters:
        key (string)
            The inventory data key to watch.
        onChange (function)
            The callback that receives the old and new values.

    Returns:
        nil

    Example Usage:
        ```lua
        inventoryType:addDataProxy("locked", function(oldValue, newValue)
            print("Lock state changed:", oldValue, newValue)
        end)
        ```

    Realm:
        Shared
]]
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

--[[
    Purpose:
        Returns all items in this inventory whose unique ID matches the requested value.

    Parameters:
        uniqueID (string)
            The item unique ID to search for.
        onlyMain (boolean|nil)
            Forwarded to the underlying item retrieval call when supported.

    Returns:
        table
            A sequential table of matching item instances.

    Example Usage:
        ```lua
        local ammoItems = inventory:getItemsByUniqueID("ammo_9mm")
        print("Found ammo stacks:", #ammoItems)
        ```

    Realm:
        Shared
]]
function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    local items = {}
    for _, v in pairs(self:getItems(onlyMain)) do
        if v.uniqueID == uniqueID then items[#items + 1] = v end
    end
    return items
end

--[[
    Purpose:
        Finalizes inventory type configuration and registers the type with the inventory library.

    Parameters:
        typeID (string)
            The unique identifier used to register this inventory type.

    Returns:
        nil

    Example Usage:
        ```lua
        BagInventory:register("bag")
        ```

    Realm:
        Shared
]]
function Inventory:register(typeID)
    assert(isstring(typeID), L("registerTypeString", self.className))
    self.typeID = typeID
    self.config = {
        data = {}
    }

    if SERVER then
        self.config.persistent = true
        self.config.accessRules = {}
    end

    self:configure(self.config)
    if not InventoryRegistered then
        lia.inventory.newType(self.typeID, self)
        InventoryRegistered = true
    end
end

--[[
    Purpose:
        Creates a new inventory instance for this registered type.

    Returns:
        table
            The newly created inventory instance.

    Example Usage:
        ```lua
        local inventory = inventoryType:new()
        ```

    Realm:
        Shared
]]
function Inventory:new()
    return lia.inventory.new(self.typeID)
end

--[[
    Purpose:
        Builds a readable localized label for this inventory instance.

    Returns:
        string
            A string containing the localized class name and inventory ID.

    Example Usage:
        ```lua
        print(inventory:tostring())
        ```

    Realm:
        Shared
]]
function Inventory:tostring()
    return L(self.className) .. "[" .. tostring(self.id) .. "]"
end

--[[
    Purpose:
        Returns the registered inventory type definition associated with this instance.

    Returns:
        table|nil
            The inventory type table when registered.

    Example Usage:
        ```lua
        local inventoryType = inventory:getType()
        ```

    Realm:
        Shared
]]
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

--[[
    Purpose:
        Runs any proxy callbacks registered for a changed inventory data key.

    Parameters:
        key (string)
            The inventory data key that changed.
        oldValue (any)
            The previous value stored under the key.
        newValue (any)
            The new value stored under the key.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:onDataChanged("locked", false, true)
        ```

    Realm:
        Shared
]]
function Inventory:onDataChanged(key, oldValue, newValue)
    local keyData = self.config.data[key]
    if keyData and keyData.proxies then
        for _, proxy in pairs(keyData.proxies) do
            proxy(oldValue, newValue)
        end
    end
end

--[[
    Purpose:
        Returns the internal item lookup table for this inventory.

    Returns:
        table
            A table keyed by item ID containing item instances.

    Example Usage:
        ```lua
        local items = inventory:getItems()
        ```

    Realm:
        Shared
]]
function Inventory:getItems()
    return self.items
end

--[[
    Purpose:
        Returns every item in this inventory whose unique ID matches the requested type.

    Parameters:
        itemType (string)
            The item unique ID to match.

    Returns:
        table
            A sequential table of matching item instances.

    Example Usage:
        ```lua
        local weapons = inventory:getItemsOfType("pistol")
        ```

    Realm:
        Shared
]]
function Inventory:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

--[[
    Purpose:
        Returns the first item in this inventory whose unique ID matches the requested type.

    Parameters:
        itemType (string)
            The item unique ID to match.

    Returns:
        table|nil
            The first matching item instance, if one exists.

    Example Usage:
        ```lua
        local firstMedkit = inventory:getFirstItemOfType("medkit")
        ```

    Realm:
        Shared
]]
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

--[[
    Purpose:
        Checks whether this inventory contains at least one item of the requested type.

    Parameters:
        itemType (string)
            The item unique ID to search for.

    Returns:
        boolean
            True if at least one matching item exists, otherwise false.

    Example Usage:
        ```lua
        if inventory:hasItem("lockpick") then
            print("Lockpick found.")
        end
        ```

    Realm:
        Shared
]]
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

--[[
    Purpose:
        Counts item quantities in this inventory, optionally restricted to a specific item type.

    Parameters:
        itemType (string|nil)
            The item unique ID to count, or nil to count all item quantities.

    Returns:
        number
            The total quantity of matching items.

    Example Usage:
        ```lua
        local totalAmmo = inventory:getItemCount("ammo_9mm")
        ```

    Realm:
        Shared
]]
function Inventory:getItemCount(itemType)
    local count = 0
    for _, item in pairs(self:getItems()) do
        if itemType == nil or item.uniqueID == itemType then count = count + item:getQuantity() end
    end
    return count
end

--[[
    Purpose:
        Returns the numeric ID assigned to this inventory instance.

    Returns:
        number
            The inventory ID.

    Example Usage:
        ```lua
        print("Inventory ID:", inventory:getID())
        ```

    Realm:
        Shared
]]
function Inventory:getID()
    return self.id
end

if SERVER then
    --[[
    Purpose:
        Adds an item to this inventory, updates its persisted inventory ID, and replicates the change.

    Parameters:
        item (table)
            The item instance being added.
        noReplicate (boolean|nil)
            When true, skips running the `OnItemAdded` hook.

    Returns:
        table
            This inventory instance for chaining.

    Example Usage:
        ```lua
        inventory:addItem(itemInstance)
        ```

    Realm:
        Server
]]
    --[[
    Hooks:
        OnItemAdded(Player|Entity|nil owner, Item item)

    Purpose:
        Runs after an item has been added to an inventory and replicated so modules can react to the ownership change.

    Category:
        Inventory

    Parameters:
        owner (Player|Entity|nil)
            The owner returned by the item when it is added, when available.

        item (Item)
            The item instance that was added to the inventory.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnItemAdded", "liaExampleOnItemAdded", function(owner, item)
            if item then
                print("Added item:", item:getName())
            end
        end)
        ```

    Realm:
        Server
]]
    function Inventory:addItem(item, noReplicate)
        self.items[item:getID()] = item
        item.invID = self:getID()
        local id = self.id
        if not isnumber(id) then id = NULL end
        lia.db.updateTable({
            invID = id
        }, nil, "items", "itemID = " .. item:getID())

        self:syncItemAdded(item)
        if not noReplicate then hook.Run("OnItemAdded", item:getOwner(), item) end
        return self
    end

    --[[
    Purpose:
        Adds an item to this inventory using the shorthand alias for `addItem`.

    Parameters:
        item (table)
            The item instance being added.

    Returns:
        table
            This inventory instance for chaining.

    Example Usage:
        ```lua
        inventory:add(itemInstance)
        ```

    Realm:
        Server
]]
    function Inventory:add(item)
        return self:addItem(item)
    end

    --[[
    Purpose:
        Replicates a newly added item to all clients who can currently access this inventory.

    Parameters:
        item (table)
            The item instance to sync.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:syncItemAdded(itemInstance)
        ```

    Realm:
        Server
]]
    function Inventory:syncItemAdded(item)
        assert(istable(item) and item.getID, L("cannotSyncNonItem"))
        assert(self.items[item:getID()], L("itemDoesNotBelong", item:getID(), self.id))
        local recipients = self:getRecipients()
        item:sync(recipients)
        net.Start("liaInventoryAdd")
        net.WriteUInt(item:getID(), 32)
        net.WriteType(self.id)
        net.Send(recipients)
    end

    --[[
    Purpose:
        Creates persistent database rows for a new inventory and its initial data payload.

    Parameters:
        initialData (table)
            A table of starting inventory data values. The special `char` key is stored on the inventory row.

    Returns:
        table
            A deferred object that resolves with the new inventory ID.

    Example Usage:
        ```lua
        inventoryType:initializeStorage({
            char = character:getID(),
            locked = false
        })
        ```

    Realm:
        Server
]]
    function Inventory:initializeStorage(initialData)
        local d = deferred.new()
        local charID = initialData.char
        lia.db.insertTable({
            invType = self.typeID,
            charID = charID
        }, function(_, lastID)
            local count = 0
            local expected = table.Count(initialData)
            if initialData.char then expected = expected - 1 end
            if expected == 0 then return d:resolve(lastID) end
            for key, value in pairs(initialData) do
                if key == "char" then continue end
                lia.db.insertTable({
                    invID = lastID,
                    key = key,
                    value = {value}
                }, function()
                    count = count + 1
                    if count == expected then d:resolve(lastID) end
                end, "invdata")
            end
        end, "inventories")
        return d
    end

    --[[
    Purpose:
        Serves as an override point for restoring additional server-side state from storage.

    Returns:
        nil

    Example Usage:
        ```lua
        function BagInventory:restoreFromStorage()
            -- Restore custom state here.
        end
        ```

    Realm:
        Server
]]
    function Inventory:restoreFromStorage()
    end

    --[[
    Purpose:
        Removes an item from this inventory and optionally preserves the item instance in storage.

    Parameters:
        itemID (number)
            The numeric item ID to remove.
        preserveItem (boolean|nil)
            When true, detaches the item from this inventory without deleting it.

    Returns:
        table
            A deferred object that resolves after removal finishes.

    Example Usage:
        ```lua
        inventory:removeItem(itemID, true)
        ```

    Realm:
        Server
]]
    function Inventory:removeItem(itemID, preserveItem)
        assert(isnumber(itemID), L("itemIDNumberRequired"))
        local d = deferred.new()
        local instance = self.items[itemID]
        if instance then
            instance.invID = 0
            self.items[itemID] = nil
            hook.Run("InventoryItemRemoved", self, instance, preserveItem)
            net.Start("liaInventoryRemove")
            net.WriteUInt(itemID, 32)
            net.WriteType(self:getID())
            net.Send(self:getRecipients())
            if not preserveItem then
                d:resolve(instance:delete())
            else
                lia.db.updateTable({
                    invID = NULL
                }, function() d:resolve() end, "items", "itemID = " .. itemID)
            end
        else
            d:resolve()
        end
        return d
    end

    --[[
    Purpose:
        Removes an item from this inventory using the shorthand alias for `removeItem`.

    Parameters:
        itemID (number)
            The numeric item ID to remove.

    Returns:
        table
            A deferred object that resolves after removal finishes.

    Example Usage:
        ```lua
        inventory:remove(itemID)
        ```

    Realm:
        Server
]]
    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

    --[[
    Purpose:
        Sets an inventory data value, persists it when allowed, replicates it, and triggers change proxies.

    Parameters:
        key (string)
            The inventory data key to update.
        value (any)
            The value to store for the key.

    Returns:
        table
            This inventory instance for chaining.

    Example Usage:
        ```lua
        inventory:setData("locked", true)
        ```

    Realm:
        Server
]]
    function Inventory:setData(key, value)
        local oldValue = self.data[key]
        self.data[key] = value
        local keyData = self.config.data[key]
        if key == "char" then
            lia.db.updateTable({
                charID = value
            }, nil, "inventories", "invID = " .. self:getID())
        elseif not keyData or not keyData.notPersistent then
            if value == nil then
                lia.db.delete("invdata", "invID = " .. self.id .. " AND key = '" .. lia.db.escape(key) .. "'")
            else
                lia.db.upsert({
                    invID = self.id,
                    key = key,
                    value = {value}
                }, "invdata")
            end
        end

        self:syncData(key)
        self:onDataChanged(key, oldValue, value)
        return self
    end

    --[[
    Purpose:
        Evaluates registered access rules for a specific inventory action and context.

    Parameters:
        action (string)
            The action being checked, such as `repl`.
        context (table|nil)
            Optional contextual data passed to each rule.

    Returns:
        boolean|nil
            The first non-nil rule result.
        string|nil
            An optional reason returned by the matching rule.

    Example Usage:
        ```lua
        local canReplicate = inventory:canAccess("repl", {
            client = client
        })
        ```

    Realm:
        Server
]]
    function Inventory:canAccess(action, context)
        context = context or {}
        local result, reason
        for _, rule in ipairs(self.config.accessRules) do
            result, reason = rule(self, action, context)
            if result ~= nil then return result, reason end
        end
    end

    --[[
    Purpose:
        Adds an access rule to this inventory's rule list, optionally at a specific priority.

    Parameters:
        rule (function)
            The rule callback to add.
        priority (number|nil)
            The insert position for the rule when ordering matters.

    Returns:
        table
            This inventory instance for chaining.

    Example Usage:
        ```lua
        inventory:addAccessRule(function(inv, action, context)
            if action == "repl" then
                return context.client == inv:getOwner()
            end
        end)
        ```

    Realm:
        Server
]]
    function Inventory:addAccessRule(rule, priority)
        if isnumber(priority) then
            table.insert(self.config.accessRules, priority, rule)
        else
            self.config.accessRules[#self.config.accessRules + 1] = rule
        end
        return self
    end

    --[[
    Purpose:
        Removes a previously registered access rule from this inventory.

    Parameters:
        rule (function)
            The exact rule callback to remove.

    Returns:
        table
            This inventory instance for chaining.

    Example Usage:
        ```lua
        inventory:removeAccessRule(myRule)
        ```

    Realm:
        Server
]]
    function Inventory:removeAccessRule(rule)
        table.RemoveByValue(self.config.accessRules, rule)
        return self
    end

    --[[
    Purpose:
        Returns all connected players who currently pass this inventory's replication access rules.

    Returns:
        table
            A sequential table of recipient players.

    Example Usage:
        ```lua
        local recipients = inventory:getRecipients()
        ```

    Realm:
        Server
]]
    function Inventory:getRecipients()
        local recipients = {}
        for _, client in player.Iterator() do
            if self:canAccess("repl", {
                client = client
            }) then
                recipients[#recipients + 1] = client
            end
        end
        return recipients
    end

    --[[
    Purpose:
        Serves as an override point after a server-side inventory instance is created.

    Returns:
        nil

    Example Usage:
        ```lua
        function BagInventory:onInstanced()
            print("Inventory instanced:", self:getID())
        end
        ```

    Realm:
        Server
]]
    function Inventory:onInstanced()
    end

    --[[
    Purpose:
        Serves as an override point after the inventory finishes loading.

    Returns:
        nil

    Example Usage:
        ```lua
        function BagInventory:onLoaded()
            print("Inventory loaded:", self:getID())
        end
        ```

    Realm:
        Server
]]
    function Inventory:onLoaded()
    end

    local ITEM_TABLE = "items"
    local ITEM_FIELDS = {"itemID", "uniqueID", "data", "x", "y", "quantity"}
    --[[
    Purpose:
        Loads all persisted items belonging to this inventory and restores them into memory.

    Returns:
        table
            A promise-like query chain resolving to the restored item table.

    Example Usage:
        ```lua
        inventory:loadItems():next(function(items)
            print("Loaded items:", table.Count(items))
        end)
        ```

    Realm:
        Server
]]
    function Inventory:loadItems()
        return lia.db.select(ITEM_FIELDS, ITEM_TABLE, "invID = " .. self.id):next(function(res)
            if not res or not istable(res) then
                local items = {}
                self.items = items
                self:onItemsLoaded(items)
                return items
            end

            local items = {}
            for _, result in ipairs(res.results or {}) do
                if not result or not istable(result) then continue end
                local itemID = tonumber(result.itemID)
                local uniqueID = result.uniqueID
                if not uniqueID or not isstring(uniqueID) then continue end
                local itemTable = lia.item.list[uniqueID]
                if not itemTable then
                    lia.error(L("inventoryInvalidItem", self.id, uniqueID, itemID))
                    continue
                end

                local item = lia.item.new(uniqueID, itemID)
                if not item then continue end
                item.invID = self.id
                if result.data then item.data = table.Merge(item.data, util.JSONToTable(result.data) or {}) end
                item.data.x = tonumber(result.x)
                item.data.y = tonumber(result.y)
                item.quantity = tonumber(result.quantity)
                items[itemID] = item
                item:onRestored(self)
            end

            self.items = items
            self:onItemsLoaded(items)
            return items
        end)
    end

    --[[
    Purpose:
        Serves as an override point after `loadItems` restores the inventory item table.

    Parameters:
        items (table)
            The restored item table keyed by item ID.

    Returns:
        nil

    Example Usage:
        ```lua
        function BagInventory:onItemsLoaded(items)
            print("Items restored:", table.Count(items))
        end
        ```

    Realm:
        Server
]]
    function Inventory:onItemsLoaded(items)
    end

    --[[
    Purpose:
        Creates and persists a new instance of this inventory type using initial data.

    Parameters:
        initialData (table)
            The initial data table used during inventory instancing.

    Returns:
        table
            The instanced inventory object or deferred result provided by the inventory library.

    Example Usage:
        ```lua
        inventoryType:instance({
            char = character:getID()
        })
        ```

    Realm:
        Server
]]
    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    --[[
    Purpose:
        Replicates a single inventory data key to clients unless replication is disabled for that key.

    Parameters:
        key (string)
            The inventory data key to replicate.
        recipients (table|nil)
            Optional recipient players. Defaults to current access recipients.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:syncData("locked")
        ```

    Realm:
        Server
]]
    function Inventory:syncData(key, recipients)
        if self.config.data[key] and self.config.data[key].noReplication then return end
        net.Start("liaInventoryData")
        net.WriteType(self.id)
        net.WriteString(key)
        net.WriteType(self.data[key])
        net.Send(recipients or self:getRecipients())
    end

    --[[
    Purpose:
        Replicates the full inventory state and all contained items to clients.

    Parameters:
        recipients (table|nil)
            Optional recipient players. Defaults to current access recipients.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:sync()
        ```

    Realm:
        Server
]]
    function Inventory:sync(recipients)
        net.Start("liaInventoryInit")
        net.WriteType(self.id)
        net.WriteString(self.typeID)
        net.WriteTable(self.data)
        local items = {}
        local function writeItem(item)
            items[#items + 1] = {
                i = item:getID(),
                u = item.uniqueID,
                d = item.data,
                q = item:getQuantity()
            }
        end

        for _, item in pairs(self.items) do
            writeItem(item)
        end

        local compressedTable = util.Compress(util.TableToJSON(items))
        net.WriteUInt(#compressedTable, 32)
        net.WriteData(compressedTable, #compressedTable)
        net.Send(recipients or self:getRecipients())
        for _, item in pairs(self.items) do
            item:onSync(recipients)
        end
    end

    --[[
    Purpose:
        Deletes this inventory through the inventory library by its current ID.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:delete()
        ```

    Realm:
        Server
]]
    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

    --[[
    Purpose:
        Destroys all local item instances, unregisters this inventory instance, and broadcasts deletion.

    Returns:
        nil

    Example Usage:
        ```lua
        inventory:destroy()
        ```

    Realm:
        Server
]]
    function Inventory:destroy()
        for _, item in pairs(self:getItems()) do
            item:destroy()
        end

        lia.inventory.instances[self:getID()] = nil
        net.Start("liaInventoryDelete")
        net.WriteType(self.id)
        net.Broadcast()
    end
else
    --[[
    Purpose:
        Opens this inventory in the client inventory UI.

    Parameters:
        parent (Panel|nil)
            The parent panel used when creating the inventory view.

    Returns:
        Panel|table
            The UI panel or value returned by the inventory display helper.

    Example Usage:
        ```lua
        inventory:show(parentPanel)
        ```

    Realm:
        Client
]]
    function Inventory:show(parent)
        return lia.inventory.show(self, parent)
    end
end
