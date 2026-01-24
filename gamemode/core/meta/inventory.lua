--[[
    Folder: Meta
    File:  inventory.md
]]
--[[
    Inventory Meta

    Inventory management system for the Lilia framework.
]]
--[[
    Overview:
        The inventory meta table provides comprehensive functionality for managing inventory data, item storage, and inventory operations in the Lilia framework. It handles inventory creation, item management, data persistence, capacity management, and inventory-specific operations. The meta table operates on both server and client sides, with the server managing inventory storage and validation while the client provides inventory data access and display. It includes integration with the item system for item storage, database system for inventory persistence, character system for character inventories, and network system for inventory synchronization. The meta table ensures proper inventory data synchronization, item capacity management, item validation, and comprehensive inventory lifecycle management from creation to deletion.
]]
local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--[[
    Purpose:
        Retrieves a stored data value on the inventory.

    When Called:
        Use whenever reading custom inventory metadata.

    Parameters:
        key (string)
            Data key to read.
        default (any)
            Value returned when the key is missing.

    Returns:
        any
            Stored value or the provided default.

    Realm:
        Shared

    Example Usage:
        ```lua
            local owner = inv:getData("char")
        ```
]]
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

--[[
    Purpose:
        Creates a subclass of Inventory with its own metatable.

    When Called:
        Use when defining a new inventory type.

    Parameters:
        className (string)
            Registry name for the new subclass.

    Returns:
        table
            Newly created subclass table.

    Realm:
        Shared

    Example Usage:
        ```lua
            local Backpack = Inventory:extend("liaBackpack")
        ```
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
        Sets up inventory defaults; meant to be overridden.

    When Called:
        Invoked during type registration to configure behavior.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            function Inventory:configure() self.config.size = {4,4} end
        ```
]]
function Inventory:configure()
end

--[[
    Purpose:
        Registers a proxy callback for a specific data key.

    When Called:
        Use when you need to react to data changes.

    Parameters:
        key (string)
            Data key to watch.
        onChange (function)
            Callback receiving old and new values.
    Realm:
        Shared

    Example Usage:
        ```lua
            inv:addDataProxy("locked", function(o,n) end)
        ```
]]
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

--[[
    Purpose:
        Returns all items in the inventory matching a uniqueID.

    When Called:
        Use when finding all copies of a specific item type.

    Parameters:
        uniqueID (string)
            Item unique identifier.
        onlyMain (boolean)
            Restrict search to main inventory when true.

    Returns:
        table
            Array of matching item instances.

    Realm:
        Shared

    Example Usage:
        ```lua
            local meds = inv:getItemsByUniqueID("medkit")
        ```
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
        Registers this inventory type with the system.

    When Called:
        Invoke once per subclass to set type ID and defaults.

    Parameters:
        typeID (string)
            Unique identifier for this inventory type.
    Realm:
        Shared

    Example Usage:
        ```lua
            Inventory:register("bag")
        ```
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
        Creates a new instance of this inventory type.

    When Called:
        Use when a character or container needs a fresh inventory.

    Parameters:
        None.

    Returns:
        table
            Deferred inventory instance creation.

    Realm:
        Shared

    Example Usage:
        ```lua
            local inv = Inventory:new()
        ```
]]
function Inventory:new()
    return lia.inventory.new(self.typeID)
end

--[[
    Purpose:
        Formats the inventory as a readable string with its ID.

    When Called:
        Use for logging or debugging output.

    Parameters:
        None.

    Returns:
        string
            Localized class name and ID.

    Realm:
        Shared

    Example Usage:
        ```lua
            print(inv:tostring())
        ```
]]
function Inventory:tostring()
    return L(self.className) .. "[" .. tostring(self.id) .. "]"
end

--[[
    Purpose:
        Returns the inventory type definition table.

    When Called:
        Use when accessing type-level configuration.

    Parameters:
        None.

    Returns:
        table
            Registered inventory type data.

    Realm:
        Shared

    Example Usage:
        ```lua
            local typeData = inv:getType()
        ```
]]
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

--[[
    Purpose:
        Fires proxy callbacks when a tracked data value changes.

    When Called:
        Internally after setData updates.

    Parameters:
        key (string)
            Data key that changed.
        oldValue (any)
            Previous value.
        newValue (any)
            New value.
    Realm:
        Shared

    Example Usage:
        ```lua
            inv:onDataChanged("locked", false, true)
        ```
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
        Returns the table of item instances in this inventory.

    When Called:
        Use when iterating all items.

    Parameters:
        None.

    Returns:
        table
            Item instances keyed by item ID.

    Realm:
        Shared

    Example Usage:
        ```lua
            for id, itm in pairs(inv:getItems()) do end
        ```
]]
function Inventory:getItems()
    return self.items
end

--[[
    Purpose:
        Collects items of a given type from the inventory.

    When Called:
        Use when filtering for a specific item uniqueID.

    Parameters:
        itemType (string)
            Unique item identifier to match.

    Returns:
        table
            Array of matching items.

    Realm:
        Shared

    Example Usage:
        ```lua
            local foods = inv:getItemsOfType("food")
        ```
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
        Returns the first item matching a uniqueID.

    When Called:
        Use when only one instance of a type is needed.

    Parameters:
        itemType (string)
            Unique item identifier to find.

    Returns:
        table|nil
            Item instance or nil if none found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local gun = inv:getFirstItemOfType("pistol")
        ```
]]
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

--[[
    Purpose:
        Checks whether the inventory contains an item type.

    When Called:
        Use before consuming or requiring an item.

    Parameters:
        itemType (string)
            Unique item identifier to check.

    Returns:
        boolean
            True if at least one matching item exists.

    Realm:
        Shared

    Example Usage:
        ```lua
            if inv:hasItem("keycard") then unlock() end
        ```
]]
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

--[[
    Purpose:
        Counts items, optionally filtering by uniqueID.

    When Called:
        Use for capacity checks or UI badge counts.

    Parameters:
        itemType (string|nil)
            Unique ID to filter by; nil counts all.

    Returns:
        number
            Total quantity of matching items.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ammoCount = inv:getItemCount("ammo")
        ```
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
        Returns the numeric identifier for this inventory.

    When Called:
        Use when networking, saving, or comparing inventories.

    Parameters:
        None.

    Returns:
        number
            Inventory ID.

    Realm:
        Shared

    Example Usage:
        ```lua
            local id = inv:getID()
        ```
]]
function Inventory:getID()
    return self.id
end

if SERVER then
    --[[
    Purpose:
        Inserts an item into this inventory and persists its invID.

    When Called:
        Use when adding an item to the inventory on the server.

    Parameters:
        item (Item)
            Item instance to add.
        noReplicate (boolean)
            Skip replication hooks when true.

    Returns:
        Inventory
            The inventory for chaining.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:addItem(item)
        ```
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
        Alias to addItem for convenience.

    When Called:
        Use wherever you would call addItem.

    Parameters:
        item (Item)
            Item instance to add.

    Returns:
        Inventory
            The inventory for chaining.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:add(item)
        ```
]]
    function Inventory:add(item)
        return self:addItem(item)
    end

    --[[
    Purpose:
        Notifies clients about an item newly added to this inventory.

    When Called:
        Invoked after addItem to replicate state.

    Parameters:
        item (Item)
            Item instance already inserted.
    Realm:
        Server

    Example Usage:
        ```lua
            inv:syncItemAdded(item)
        ```
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
        Creates a database record for a new inventory and its data.

    When Called:
        Use during initial inventory creation.

    Parameters:
        initialData (table)
            Key/value pairs to seed invdata rows; may include char.

    Returns:
        Promise
            Resolves with new inventory ID.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:initializeStorage({char = charID})
        ```
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
        Hook for restoring inventory data from storage.

    When Called:
        Override to load custom data during restoration.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            function Inventory:restoreFromStorage() end
        ```
]]
    function Inventory:restoreFromStorage()
    end

    --[[
    Purpose:
        Removes an item from this inventory and updates clients/DB.

    When Called:
        Use when deleting or moving items out of the inventory.

    Parameters:
        itemID (number)
            ID of the item to remove.
        preserveItem (boolean)
            Keep the instance and DB row when true.

    Returns:
        Promise
            Resolves after removal finishes.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:removeItem(itemID)
        ```
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
        Alias for removeItem.

    When Called:
        Use interchangeably with removeItem.

    Parameters:
        itemID (number)
            ID of the item to remove.

    Returns:
        Promise
            Resolves after removal.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:remove(id)
        ```
]]
    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

    --[[
    Purpose:
        Updates inventory data, persists it, and notifies listeners.

    When Called:
        Use to change stored metadata such as character assignment.

    Parameters:
        key (string)
            Data key to set.
        value (any)
            New value or nil to delete.

    Returns:
        Inventory
            The inventory for chaining.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:setData("locked", true)
        ```
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
        Evaluates access rules for a given action context.

    When Called:
        Use before allowing inventory interactions.

    Parameters:
        action (string)
            Action name (e.g., "repl", "transfer").
        context (table)
            Additional data such as client.

    Returns:
        boolean|nil, string|nil
            Decision and optional reason if a rule handled it.

    Realm:
        Server

    Example Usage:
        ```lua
            local ok = inv:canAccess("repl", {client = ply})
        ```
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
        Inserts an access rule into the rule list.

    When Called:
        Use when configuring permissions for this inventory type.

    Parameters:
        rule (function)
            Function returning decision and reason.
        priority (number|nil)
            Optional insert position.

    Returns:
        Inventory
            The inventory for chaining.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:addAccessRule(myRule, 1)
        ```
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
        Removes a previously added access rule.

    When Called:
        Use when unregistering dynamic permission logic.

    Parameters:
        rule (function)
            The rule function to remove.

    Returns:
        Inventory
            The inventory for chaining.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:removeAccessRule(myRule)
        ```
]]
    function Inventory:removeAccessRule(rule)
        table.RemoveByValue(self.config.accessRules, rule)
        return self
    end

    --[[
    Purpose:
        Determines which players should receive inventory replication.

    When Called:
        Use before sending inventory data to clients.

    Parameters:
        None.

    Returns:
        table
            List of player recipients allowed by access rules.

    Realm:
        Server

    Example Usage:
        ```lua
            local recips = inv:getRecipients()
        ```
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
        Hook called when an inventory instance is created.

    When Called:
        Override to perform custom initialization.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            function Inventory:onInstanced() end
        ```
]]
    function Inventory:onInstanced()
    end

    --[[
    Purpose:
        Hook called after inventory data is loaded.

    When Called:
        Override to react once storage data is retrieved.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            function Inventory:onLoaded() end
        ```
]]
    function Inventory:onLoaded()
    end

    local ITEM_TABLE = "items"
    local ITEM_FIELDS = {"itemID", "uniqueID", "data", "x", "y", "quantity"}
    --[[
    Purpose:
        Loads item instances from the database into this inventory.

    When Called:
        Use during inventory initialization to restore contents.

    Parameters:
        None.

    Returns:
        Promise
            Resolves with the loaded items table.

    Realm:
        Server

    Example Usage:
        ```lua
            inv:loadItems():next(function(items) end)
        ```
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
        Hook called after items are loaded into the inventory.

    When Called:
        Override to run logic after contents are ready.

    Parameters:
        items (table)
            Loaded items table.
    Realm:
        Server

    Example Usage:
        ```lua
            function Inventory:onItemsLoaded(items) end
        ```
]]
    function Inventory:onItemsLoaded()
    end

    --[[
    Purpose:
        Creates and registers an inventory instance with initial data.

    When Called:
        Use to instantiate a server-side inventory of this type.

    Parameters:
        initialData (table)
            Data used during creation (e.g., char assignment).

    Returns:
        Promise
            Resolves with the new inventory instance.

    Realm:
        Server

    Example Usage:
        ```lua
            Inventory:instance({char = charID})
        ```
]]
    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    --[[
    Purpose:
        Sends a single inventory data key to recipients.

    When Called:
        Use after setData to replicate a specific field.

    Parameters:
        key (string)
            Data key to send.
        recipients (Player|table|nil)
            Targets to notify; defaults to recipients with access.
    Realm:
        Server

    Example Usage:
        ```lua
            inv:syncData("locked")
        ```
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
        Sends full inventory state and contained items to recipients.

    When Called:
        Use when initializing or resyncing an inventory for clients.

    Parameters:
        recipients (Player|table|nil)
            Targets to receive the update; defaults to access list.
    Realm:
        Server

    Example Usage:
        ```lua
            inv:sync(ply)
        ```
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
        Deletes this inventory via the inventory manager.

    When Called:
        Use when permanently removing an inventory record.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            inv:delete()
        ```
]]
    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

    --[[
    Purpose:
        Clears inventory items, removes it from cache, and notifies clients.

    When Called:
        Use when unloading or destroying an inventory instance.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            inv:destroy()
        ```
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
        Opens the inventory UI on the client.

    When Called:
        Use to display this inventory to the player.

    Parameters:
        parent (Panel)
            Optional parent panel.

    Returns:
        Panel
            The created inventory panel.

    Realm:
        Client

    Example Usage:
        ```lua
            inv:show()
        ```
]]
    function Inventory:show(parent)
        return lia.inventory.show(self, parent)
    end
end
