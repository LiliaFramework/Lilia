local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--[[
    getData

    Purpose:
        Retrieves the value associated with the given key from the inventory's data table.
        If the key does not exist, returns the provided default value.

    Parameters:
        key (string) - The key to look up in the data table.
        default (any) - The value to return if the key does not exist.

    Returns:
        any - The value associated with the key, or the default value if not found.

    Realm:
        Shared.

    Example Usage:
        local value = inventory:getData("weight", 0)
]]
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

--[[
    extend

    Purpose:
        Creates a subclass of the Inventory with the specified class name.

    Parameters:
        className (string) - The name of the subclass to create.

    Returns:
        table - The new subclass table.

    Realm:
        Shared.

    Example Usage:
        local MyInventory = Inventory:extend("MyInventory")
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
    configure

    Purpose:
        Configures the inventory type. Intended to be overridden by subclasses.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        function MyInventory:configure()
            -- custom configuration
        end
]]
function Inventory:configure()
end

--[[
    addDataProxy

    Purpose:
        Adds a proxy function to be called when the specified data key changes.

    Parameters:
        key (string) - The data key to watch.
        onChange (function) - The function to call when the data changes.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        inventory:addDataProxy("weight", function(old, new) print(old, new) end)
]]
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

--[[
    getItemsByUniqueID

    Purpose:
        Returns a table of items in the inventory that match the given uniqueID.

    Parameters:
        uniqueID (string) - The uniqueID of the items to find.
        onlyMain (boolean) - If true, only search the main inventory.

    Returns:
        table - A table of matching items.

    Realm:
        Shared.

    Example Usage:
        local medkits = inventory:getItemsByUniqueID("medkit")
]]
function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    local items = {}
    for _, v in pairs(self:getItems(onlyMain)) do
        if v.uniqueID == uniqueID then items[#items + 1] = v end
    end
    return items
end

--[[
    register

    Purpose:
        Registers a new inventory type with the given typeID.

    Parameters:
        typeID (string) - The unique identifier for this inventory type.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        Inventory:register("my_inventory_type")
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
    new

    Purpose:
        Creates a new instance of this inventory type.

    Parameters:
        None.

    Returns:
        table - The new inventory instance.

    Realm:
        Shared.

    Example Usage:
        local inv = Inventory:new()
]]
function Inventory:new()
    return lia.inventory.new(self.typeID)
end

--[[
    tostring

    Purpose:
        Returns a string representation of the inventory.

    Parameters:
        None.

    Returns:
        string - The string representation.

    Realm:
        Shared.

    Example Usage:
        print(inventory:tostring())
]]
function Inventory:tostring()
    return L(self.className) .. "[" .. tostring(self.id) .. "]"
end

--[[
    getType

    Purpose:
        Retrieves the inventory type table for this inventory.

    Parameters:
        None.

    Returns:
        table - The inventory type table.

    Realm:
        Shared.

    Example Usage:
        local typeTable = inventory:getType()
]]
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

--[[
    onDataChanged

    Purpose:
        Called when a data key changes value. Invokes any registered proxies.

    Parameters:
        key (string) - The data key that changed.
        oldValue (any) - The old value.
        newValue (any) - The new value.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        inventory:onDataChanged("weight", 10, 15)
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
    getItems

    Purpose:
        Returns the table of items in this inventory.

    Parameters:
        None.

    Returns:
        table - The items table.

    Realm:
        Shared.

    Example Usage:
        local items = inventory:getItems()
]]
function Inventory:getItems()
    return self.items
end

--[[
    getItemsOfType

    Purpose:
        Returns a table of items in the inventory that match the given itemType (uniqueID).

    Parameters:
        itemType (string) - The uniqueID of the items to find.

    Returns:
        table - A table of matching items.

    Realm:
        Shared.

    Example Usage:
        local bandages = inventory:getItemsOfType("bandage")
]]
function Inventory:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

--[[
    getFirstItemOfType

    Purpose:
        Returns the first item in the inventory that matches the given itemType (uniqueID).

    Parameters:
        itemType (string) - The uniqueID of the item to find.

    Returns:
        table|none - The first matching item, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local medkit = inventory:getFirstItemOfType("medkit")
]]
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

--[[
    hasItem

    Purpose:
        Checks if the inventory contains at least one item of the given itemType (uniqueID).

    Parameters:
        itemType (string) - The uniqueID of the item to check for.

    Returns:
        boolean - True if at least one item is found, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if inventory:hasItem("keycard") then ...
]]
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

--[[
    getItemCount

    Purpose:
        Returns the total quantity of items in the inventory, optionally filtered by itemType.

    Parameters:
        itemType (string|none) - The uniqueID of the item to count, or nil to count all items.

    Returns:
        number - The total quantity.

    Realm:
        Shared.

    Example Usage:
        local count = inventory:getItemCount("ammo_9mm")
]]
function Inventory:getItemCount(itemType)
    local count = 0
    for _, item in pairs(self:getItems()) do
        if itemType == nil or item.uniqueID == itemType then count = count + item:getQuantity() end
    end
    return count
end

--[[
    getID

    Purpose:
        Returns the unique ID of this inventory.

    Parameters:
        None.

    Returns:
        number - The inventory ID.

    Realm:
        Shared.

    Example Usage:
        local id = inventory:getID()
]]
function Inventory:getID()
    return self.id
end

--[[
    eq

    Purpose:
        Checks if this inventory is equal to another by comparing their IDs.

    Parameters:
        other (Inventory) - The other inventory to compare.

    Returns:
        boolean - True if the IDs match, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if inventory:eq(otherInventory) then ...
]]
function Inventory:eq(other)
    return self:getID() == other:getID()
end

if SERVER then
    --[[
    addItem

    Purpose:
        Adds an item to the inventory and updates the database.

    Parameters:
        item (Item) - The item to add.
        noReplicate (boolean) - If true, do not replicate to clients.

    Returns:
        Inventory - The inventory instance.

    Realm:
        Server.

    Example Usage:
        inventory:addItem(item)
]]
    function Inventory:addItem(item, noReplicate)
        self.items[item:getID()] = item
        item.invID = self:getID()
        local id = self.id
        if not isnumber(id) then id = NULL end
        lia.db.updateTable({
            invID = id
        }, nil, "items", "_itemID = " .. item:getID())

        self:syncItemAdded(item)
        if not noReplicate then hook.Run("OnItemAdded", item:getOwner(), item) end
        return self
    end

    --[[
    add

    Purpose:
        Adds an item to the inventory (alias for addItem).

    Parameters:
        item (Item) - The item to add.

    Returns:
        Inventory - The inventory instance.

    Realm:
        Server.

    Example Usage:
        inventory:add(item)
]]
    function Inventory:add(item)
        return self:addItem(item)
    end

    --[[
    syncItemAdded

    Purpose:
        Synchronizes the addition of an item to all relevant clients.

    Parameters:
        item (Item) - The item that was added.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:syncItemAdded(item)
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
    initializeStorage

    Purpose:
        Initializes persistent storage for the inventory and its initial data.

    Parameters:
        initialData (table) - The initial data to store.

    Returns:
        deferred - A deferred object resolved with the new inventory ID.

    Realm:
        Server.

    Example Usage:
        inventory:initializeStorage({char = 1, weight = 10})
]]
    function Inventory:initializeStorage(initialData)
        local d = deferred.new()
        local charID = initialData.char
        lia.db.insertTable({
            _invType = self.typeID,
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
    restoreFromStorage

    Purpose:
        Restores the inventory from persistent storage.
        (To be implemented by subclasses if needed.)

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:restoreFromStorage()
]]
    function Inventory:restoreFromStorage()
    end

    --[[
    removeItem

    Purpose:
        Removes an item from the inventory and updates the database.

    Parameters:
        itemID (number) - The ID of the item to remove.
        preserveItem (boolean) - If true, do not delete the item from the database.

    Returns:
        deferred - A deferred object resolved when removal is complete.

    Realm:
        Server.

    Example Usage:
        inventory:removeItem(123)
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
                }, function() d:resolve() end, "items", "_itemID = " .. itemID)
            end
        else
            d:resolve()
        end
        return d
    end

    --[[
    remove

    Purpose:
        Removes an item from the inventory (alias for removeItem).

    Parameters:
        itemID (number) - The ID of the item to remove.

    Returns:
        deferred - A deferred object resolved when removal is complete.

    Realm:
        Server.

    Example Usage:
        inventory:remove(123)
]]
    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

    --[[
    setData

    Purpose:
        Sets a data key to a value, updates the database, and synchronizes the change.

    Parameters:
        key (string) - The data key to set.
        value (any) - The value to set.

    Returns:
        Inventory - The inventory instance.

    Realm:
        Server.

    Example Usage:
        inventory:setData("weight", 20)
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
    canAccess

    Purpose:
        Checks if an action can be performed on this inventory, using access rules.

    Parameters:
        action (string) - The action to check (e.g., "repl").
        context (table) - Additional context for the check.

    Returns:
        booleannone, string|none - True/false and optional reason, or nil if no rule applies.

    Realm:
        Server.

    Example Usage:
        local can, reason = inventory:canAccess("repl", {client = ply})
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
    addAccessRule

    Purpose:
        Adds an access rule to the inventory.

    Parameters:
        rule (function) - The rule function to add.
        priority (number|none) - The position to insert the rule at.

    Returns:
        Inventory - The inventory instance.

    Realm:
        Server.

    Example Usage:
        inventory:addAccessRule(myRule, 1)
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
    removeAccessRule

    Purpose:
        Removes an access rule from the inventory.

    Parameters:
        rule (function) - The rule function to remove.

    Returns:
        Inventory - The inventory instance.

    Realm:
        Server.

    Example Usage:
        inventory:removeAccessRule(myRule)
]]
    function Inventory:removeAccessRule(rule)
        table.RemoveByValue(self.config.accessRules, rule)
        return self
    end

    --[[
    getRecipients

    Purpose:
        Returns a table of clients who can receive inventory updates.

    Parameters:
        None.

    Returns:
        table - A table of player objects.

    Realm:
        Server.

    Example Usage:
        local recipients = inventory:getRecipients()
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
    onInstanced

    Purpose:
        Called when the inventory is instanced. Intended to be overridden.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        function Inventory:onInstanced() ... end
]]
    function Inventory:onInstanced()
    end

    --[[
    onLoaded

    Purpose:
        Called when the inventory is loaded. Intended to be overridden.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        function Inventory:onLoaded() ... end
]]
    function Inventory:onLoaded()
    end

    local ITEM_TABLE = "items"
    local ITEM_FIELDS = {"_itemID", "uniqueID", "data", "x", "y", "quantity"}
    --[[
    loadItems

    Purpose:
        Loads all items for this inventory from the database.

    Parameters:
        None.

    Returns:
        deferred - A deferred object resolved with the items table.

    Realm:
        Server.

    Example Usage:
        inventory:loadItems():next(function(items) ... end)
]]
    function Inventory:loadItems()
        return lia.db.select(ITEM_FIELDS, ITEM_TABLE, "invID = " .. self.id):next(function(res)
            local items = {}
            for _, result in ipairs(res.results or {}) do
                local itemID = tonumber(result._itemID)
                local uniqueID = result.uniqueID
                local itemTable = lia.item.list[uniqueID]
                if not itemTable then
                    lia.error(L("inventoryInvalidItem", self.id, uniqueID, itemID))
                    continue
                end

                local item = lia.item.new(uniqueID, itemID)
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
    onItemsLoaded

    Purpose:
        Called after items are loaded from the database. Intended to be overridden.

    Parameters:
        items (table) - The loaded items.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        function Inventory:onItemsLoaded(items) ... end
]]
    function Inventory:onItemsLoaded()
    end

    --[[
    instance

    Purpose:
        Creates a new inventory instance with the given initial data.

    Parameters:
        initialData (table) - The initial data for the inventory.

    Returns:
        Inventory - The new inventory instance.

    Realm:
        Server.

    Example Usage:
        local inv = Inventory:instance({char = 1})
]]
    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    --[[
    syncData

    Purpose:
        Synchronizes a data key to clients.

    Parameters:
        key (string) - The data key to sync.
        recipients (table|none) - The clients to send to, or nil for all recipients.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:syncData("weight")
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
    sync

    Purpose:
        Synchronizes the entire inventory to clients.

    Parameters:
        recipients (table|none) - The clients to send to, or nil for all recipients.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:sync()
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
    delete

    Purpose:
        Deletes the inventory from the system.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:delete()
]]
    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

    --[[
    destroy

    Purpose:
        Destroys the inventory and all its items, and notifies clients.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        inventory:destroy()
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
    show

    Purpose:
        Displays the inventory to the player.

    Parameters:
        parent (panel|none) - The parent panel to attach to.

    Returns:
        Panel - The inventory UI panel.

    Realm:
        Client.

    Example Usage:
        inventory:show()
]]
    function Inventory:show(parent)
        return lia.inventory.show(self, parent)
    end
end
