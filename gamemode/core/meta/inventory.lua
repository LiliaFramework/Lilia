local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--[[
    Inventory:getData(key, default)

    Description:
        Returns a stored data value for this inventory.

    Parameters:
        key (string) – Data field key.
        default (any) – Value if the key does not exist.

    Realm:
        Shared

    Returns:
        any – Stored value or default.
]]
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

--[[
    Inventory:extend(className)

    Description:
        Creates a subclass of the inventory meta table with a new class name.

    Parameters:
        className (string) – Name of the subclass meta table.

    Realm:
        Shared

    Returns:
        table – The newly derived inventory table.
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
    Inventory:configure()

    Description:
        Stub for inventory configuration; meant to be overridden.

    Realm:
        Shared
]]
function Inventory:configure()
end

--[[
    Inventory:addDataProxy(key, onChange)

    Description:
        Adds a proxy function that is called when a data field changes.

    Parameters:
        key (string) – Data field to watch.
        onChange (function) – Callback receiving old and new values.

    Realm:
        Shared
]]
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

--[[
    Inventory:getItemsByUniqueID(uniqueID, onlyMain)

    Description:
        Returns all items in the inventory matching the given unique ID.

    Parameters:
        uniqueID (string) – Item unique identifier.
        onlyMain (boolean) – Search only the main item list.

    Realm:
        Shared

    Returns:
        table – Table of matching item objects.
]]
function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    local items = {}
    for _, v in pairs(self:getItems(onlyMain)) do
        if v.uniqueID == uniqueID then items[#items + 1] = v end
    end
    return items
end

--[[
    Inventory:register(typeID)

    Description:
        Registers this inventory type with the lia.inventory system.

    Parameters:
        typeID (string) – Unique identifier for this inventory type.

    Realm:
        Shared
]]
function Inventory:register(typeID)
    assert(isstring(typeID), "Expected argument #1 of " .. self.className .. ".register to be a string")
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
    Inventory:new()

    Description:
        Creates a new inventory of this type.

    Realm:
        Shared

    Returns:
        table – New inventory instance.
]]
function Inventory:new()
    return lia.inventory.new(self.typeID)
end

--[[
    Inventory:tostring()

    Description:
        Returns a printable representation of this inventory.

    Realm:
        Shared

    Returns:
        string – Formatted as "ClassName[id]".
]]
function Inventory:tostring()
    return self.className .. "[" .. tostring(self.id) .. "]"
end

--[[
    Inventory:getType()

    Description:
        Retrieves the inventory type table from lia.inventory.

    Realm:
        Shared

    Returns:
        table – Inventory type definition.
]]
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

--[[
    Inventory:onDataChanged(key, oldValue, newValue)

    Description:
        Called when an inventory data field changes. Executes any
        registered proxy callbacks for that field.

    Parameters:
        key (string) – Data field key.
        oldValue (any) – Previous value.
        newValue (any) – Updated value.

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
    Inventory:getItems()

    Description:
        Returns all items stored in this inventory.

    Realm:
        Shared

    Returns:
        table – Item instance table indexed by itemID.
]]
function Inventory:getItems()
    return self.items
end

--[[
    Inventory:getItemsOfType(itemType)

    Description:
        Collects all items that match the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        table – Array of matching items.
]]
function Inventory:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

--[[
    Inventory:getFirstItemOfType(itemType)

    Description:
        Retrieves the first item matching the given unique ID.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        Item|nil – The first matching item or nil.
]]
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

--[[
    Inventory:hasItem(itemType)

    Description:
        Determines whether the inventory contains an item type.

    Parameters:
        itemType (string) – Item unique identifier.

    Realm:
        Shared

    Returns:
        boolean – True if an item is found.
]]
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

--[[
    Inventory:getItemCount(itemType)

    Description:
        Counts the total quantity of a specific item type.

    Parameters:
        itemType (string|nil) – Item unique ID to count. Counts all if nil.

    Realm:
        Shared

    Returns:
        number – Sum of quantities.
]]
function Inventory:getItemCount(itemType)
    local count = 0
    for _, item in pairs(self:getItems()) do
        if itemType == nil or item.uniqueID == itemType then
            count = count + item:getQuantity()
        end
    end
    return count
end

--[[
    Inventory:getID()

    Description:
        Returns the unique database ID of this inventory.

    Realm:
        Shared

    Returns:
        number – Inventory identifier.
]]
function Inventory:getID()
    return self.id
end

--[[
    Inventory:eq(other)

    Description:
        Compares two inventories by ID for equality.

    Parameters:
        other (Inventory) – Other inventory to compare.

    Realm:
        Shared

    Returns:
        boolean – True if both inventories share the same ID.
]]
function Inventory:eq(other)
    return self:getID() == other:getID()
end

if SERVER then
    --[[
        Inventory:addItem(item, noReplicate)

        Description:
            Inserts an item instance into this inventory and persists it.

        Parameters:
            item (Item) – Item to add.
            noReplicate (boolean) – Skip network replication when true.

        Realm:
            Server
    ]]
    function Inventory:addItem(item, noReplicate)
        self.items[item:getID()] = item
        item.invID = self:getID()
        local id = self.id
        if not isnumber(id) then id = NULL end
        lia.db.updateTable({
            _invID = id
        }, nil, "items", "_itemID = " .. item:getID())

        self:syncItemAdded(item)
        if not noReplicate then hook.Run("OnItemAdded", item:getOwner(), item) end
        return self
    end

    function Inventory:add(item)
        return self:addItem(item)
    end

    function Inventory:syncItemAdded(item)
        assert(istable(item) and item.getID, "cannot sync non-item")
        assert(self.items[item:getID()], "Item " .. item:getID() .. " does not belong to " .. self.id)
        local recipients = self:getRecipients()
        item:sync(recipients)
        net.Start("liaInventoryAdd")
        net.WriteUInt(item:getID(), 32)
        net.WriteType(self.id)
        net.Send(recipients)
    end

    function Inventory:initializeStorage(initialData)
        local d = deferred.new()
        local charID = initialData.char
        lia.db.insertTable({
            _invType = self.typeID,
            _charID = charID
        }, function(_, lastID)
            local count = 0
            local expected = table.Count(initialData)
            if initialData.char then expected = expected - 1 end
            if expected == 0 then return d:resolve(lastID) end
            for key, value in pairs(initialData) do
                if key == "char" then continue end
                lia.db.insertTable({
                    _invID = lastID,
                    _key = key,
                    _value = {value}
                }, function()
                    count = count + 1
                    if count == expected then d:resolve(lastID) end
                end, "invdata")
            end
        end, "inventories")
        return d
    end

    function Inventory:restoreFromStorage()
    end

    --[[
        Inventory:removeItem(itemID, preserveItem)

        Description:
            Removes an item by ID and optionally deletes it.

        Parameters:
            itemID (number) – Unique item identifier.
            preserveItem (boolean) – Keep item in database when true.

        Realm:
            Server
    ]]
    function Inventory:removeItem(itemID, preserveItem)
        assert(isnumber(itemID), "itemID must be a number for remove")
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
                    _invID = NULL
                }, function() d:resolve() end, "items", "_itemID = " .. itemID)
            end
        else
            d:resolve()
        end
        return d
    end

    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

    function Inventory:setData(key, value)
        local oldValue = self.data[key]
        self.data[key] = value
        local keyData = self.config.data[key]
        if key == "char" then
            lia.db.updateTable({
                _charID = value
            }, nil, "inventories", "_invID = " .. self:getID())
        elseif not keyData or not keyData.notPersistent then
            if value == nil then
                lia.db.delete("invdata", "_invID = " .. self.id .. " AND _key = '" .. lia.db.escape(key) .. "'")
            else
                lia.db.upsert({
                    _invID = self.id,
                    _key = key,
                    _value = {value}
                }, "invdata")
            end
        end

        self:syncData(key)
        self:onDataChanged(key, oldValue, value)
        return self
    end

    function Inventory:canAccess(action, context)
        context = context or {}
        local result, reason
        for _, rule in ipairs(self.config.accessRules) do
            result, reason = rule(self, action, context)
            if result ~= nil then return result, reason end
        end
    end

    function Inventory:addAccessRule(rule, priority)
        if isnumber(priority) then
            table.insert(self.config.accessRules, priority, rule)
        else
            self.config.accessRules[#self.config.accessRules + 1] = rule
        end
        return self
    end

    function Inventory:removeAccessRule(rule)
        table.RemoveByValue(self.config.accessRules, rule)
        return self
    end

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

    function Inventory:onInstanced()
    end

    function Inventory:onLoaded()
    end

    local ITEM_TABLE = "items"
    local ITEM_FIELDS = {"_itemID", "_uniqueID", "_data", "_x", "_y", "_quantity"}
    function Inventory:loadItems()
        return lia.db.select(ITEM_FIELDS, ITEM_TABLE, "_invID = " .. self.id):next(function(res)
            local items = {}
            for _, result in ipairs(res.results or {}) do
                local itemID = tonumber(result._itemID)
                local uniqueID = result._uniqueID
                local itemTable = lia.item.list[uniqueID]
                if not itemTable then
                    ErrorNoHalt("Inventory " .. self.id .. " contains invalid item " .. uniqueID .. " (" .. itemID .. ")\n")
                    continue
                end

                local item = lia.item.new(uniqueID, itemID)
                item.invID = self.id
                if result._data then item.data = table.Merge(item.data, util.JSONToTable(result._data) or {}) end
                item.data.x = tonumber(result._x)
                item.data.y = tonumber(result._y)
                item.quantity = tonumber(result._quantity)
                items[itemID] = item
                item:onRestored(self)
            end

            self.items = items
            self:onItemsLoaded(items)
            return items
        end)
    end

    function Inventory:onItemsLoaded()
    end

    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    --[[
        Inventory:syncData(key, recipients)

        Description:
            Sends a single data field to clients.

        Parameters:
            key (string) – Field to replicate.
            recipients (table|nil) – Player recipients.

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
        Inventory:sync(recipients)

        Description:
            Sends the entire inventory and its items to players.

        Parameters:
            recipients (table|nil) – Player recipients.

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
        Inventory:delete()

        Description:
            Removes this inventory record from the database.

        Realm:
            Server
    ]]
    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

    --[[
        Inventory:destroy()

        Description:
            Destroys all items and removes network references.

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
    function Inventory:show(parent)
        return lia.inventory.show(self, parent)
    end
end
