--[[--
Holds items within a grid layout.

Inventories are an object that contains `Item`s in a grid layout. Every `Character` will have exactly one inventory attached to
it, which is the only inventory that is allowed to hold bags - any item that has its own inventory (i.e a suitcase). Inventories
can be owned by a character, or it can be individually interacted with as a standalone object. For example, the container plugin
attaches inventories to props, allowing for items to be stored outside of any character inventories and remain "in the world".

You may be looking for the following common functions:

`add` Which adds an item to the inventory.

`getItems` Which gets all of the items inside the inventory.

`getID` Which gets the inventory's ID.

`hasItem` Which checks if the inventory has an item.
]]
-- @classmod Inventory
local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
--- Retrieves data associated with a specified key from the inventory.
-- @realm shared
-- @function Inventory:getData
-- @tparam any key The key for the data.
-- @param[opt] any default The default value to return if the key does not exist.
-- @treturn any The value associated with the key, or the default value if the key does not exist.
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

--- Extends the inventory to create a subclass with a specified class name.
-- @realm shared
-- @function Inventory:extend
-- @tparam string className The name of the subclass.
-- @treturn table A subclass of the Inventory class.
function Inventory:extend(className)
    local base = debug.getregistry()[className] or {}
    table.Empty(base)
    base.className = className
    local subClass = table.Inherit(base, self)
    subClass.__index = subClass
    return subClass
end

--- Configures the inventory.
-- @realm shared
-- This function is meant to be overridden in subclasses to define specific configurations.
-- @function Inventory:configure
function Inventory:configure()
end

--- Adds a data proxy to the inventory for a specified key.
-- @realm shared
-- @function Inventory:addDataProxy
-- @tparam any key The key for the data proxy.
-- @tparam function onChange The function to call when the data associated with the key changes.
function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

--- Retrieves items with a specified unique ID from the inventory.
-- @realm shared
-- @function Inventory:getItemsByUniqueID
-- @tparam string uniqueID The unique ID of the items to retrieve.
-- @tparam[opt=false] boolean onlyMain Whether to retrieve only main items.
-- @treturn table An array containing the items with the specified unique ID.
function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    local items = {}
    for _, v in pairs(self:getItems(onlyMain)) do
        if v.uniqueID == uniqueID then items[#items + 1] = v end
    end
    return items
end

--- Registers the inventory with a specified type ID.
-- @realm shared
-- @function Inventory:register
-- @tparam string typeID The type ID to register the inventory with.
-- @raise If the argument `typeID` is not a string.
-- @usage
-- inventory:register("grid")
-- @see lia.inventory.newType
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

--- Creates a new instance of the inventory.
-- @realm shared
-- @function Inventory:new
-- @treturn table A new instance of the Inventory class.
-- @usage
-- local newInventory = Inventory:new()
function Inventory:new()
    return lia.inventory.new(self.typeID)
end

--- Returns a string representation of the inventory.
-- @function Inventory:__tostring
-- @realm shared
-- @treturn string A string representation of the inventory, including its class name and ID.
function Inventory:__tostring()
    return self.className .. "[" .. tostring(self.id) .. "]"
end

--- Retrieves the type of the inventory.
-- @function Inventory:getType
-- @realm shared
-- @treturn table The type of the inventory.
function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

--- Callback function called when data associated with a key changes.
-- @function Inventory:onDataChanged
-- @realm shared
-- @tparam any key The key whose data has changed.
-- @param oldValue The old value of the data.
-- @param newValue The new value of the data.
function Inventory:onDataChanged(key, oldValue, newValue)
    local keyData = self.config.data[key]
    if keyData and keyData.proxies then
        for _, proxy in pairs(keyData.proxies) do
            proxy(oldValue, newValue)
        end
    end
end

--- Retrieves all items in the inventory.
-- @function Inventory:getItems
-- @realm shared
-- @treturn table An array containing all items in the inventory.
function Inventory:getItems()
    return self.items
end

--- Retrieves items of a specific type from the inventory.
-- @function Inventory:getItemsOfType
-- @realm shared
-- @tparam string itemType The type of items to retrieve.
-- @treturn table An array containing items of the specified type.
function Inventory:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

--- Retrieves the first item of a specific type from the inventory.
-- @function Inventory:getFirstItemOfType
-- @realm shared
-- @tparam string itemType The type of item to retrieve.
-- @treturn table|nil The first item of the specified type, or nil if not found.
function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

--- Checks if the inventory contains an item of a specific type.
-- @function Inventory:hasItem
-- @realm shared
-- @tparam string itemType The type of item to check for.
-- @treturn boolean Returns true if the inventory contains an item of the specified type, otherwise false.
function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

--- Retrieves the total count of items in the inventory, optionally filtered by item type.
-- @function Inventory:getItemCount
-- @realm shared
-- @tparam[opt] string itemType The type of item to count. If nil, counts all items.
-- @treturn number The total count of items in the inventory, optionally filtered by item type.
function Inventory:getItemCount(itemType)
    local count = 0
    for _, item in pairs(self:getItems()) do
        if itemType == nil and true or item.uniqueID == itemType then count = count + item:getQuantity() end
    end
    return count
end

--- Retrieves the ID of the inventory.
-- @function Inventory:getID
-- @realm shared
-- @treturn any The ID of the inventory.
function Inventory:getID()
    return self.id
end

--- Checks if two inventories are equal based on their IDs.
-- @function Inventory:__eq
-- @realm shared
-- @tparam Inventory other The other inventory to compare with.
-- @treturn boolean Returns true if the inventories have the same ID, otherwise false.
function Inventory:__eq(other)
    return self:getID() == other:getID()
end

if SERVER then
    --- Adds an item to the inventory.
    -- @function Inventory:addItem
    -- @realm server
    -- @tparam Item item The item to add to the inventory.
    -- @treturn Inventory Returns the inventory itself.
    function Inventory:addItem(item)
        self.items[item:getID()] = item
        item.invID = self:getID()
        local id = self.id
        if not isnumber(id) then id = NULL end
        lia.db.updateTable({
            _invID = id
        }, nil, "items", "_itemID = " .. item:getID())

        self:syncItemAdded(item)
        hook.Run("OnItemAdded", item:getOwner(), item)
        return self
    end

    Inventory.AddItem = Inventory.addItem
    --- Alias for `addItem` function.
    -- @function Inventory:add
    -- @realm server
    -- @tparam Item item The item to add to the inventory.
    -- @treturn Inventory Returns the inventory itself.
    function Inventory:add(item)
        return self:addItem(item)
    end

    Inventory.Add = Inventory.add
    --- Synchronizes the addition of an item with clients.
    -- @function Inventory:syncItemAdded
    -- @realm server
    -- @tparam Item item The item being added.
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

    --- Initializes the storage for the inventory.
    -- @function Inventory:initializeStorage
    -- @realm server
    -- @tparam table initialData Initial data for the inventory.
    -- @treturn Deferred A deferred promise.
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

    --- Removes an item from the inventory.
    -- @function Inventory:removeItem
    -- @realm server
    -- @tparam number itemID The ID of the item to remove.
    -- @tparam[opt=false] boolean preserveItem Whether to preserve the item's data in the database.
    -- @treturn Deferred A deferred promise.
    function Inventory:removeItem(itemID, preserveItem)
        assert(isnumber(itemID), "itemID must be a number for remove")
        local d = deferred.new()
        local instance = self.items[itemID]
        if instance then
            instance.invID = 0
            self.items[itemID] = nil
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

    Inventory.RemoveItem = Inventory.removeItem
    --- Alias for `removeItem` function.
    -- @function Inventory.Remove
    -- @realm server
    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

    Inventory.Remove = Inventory.remove
    --- Sets data associated with a key in the inventory.
    -- @function Inventory:setData
    -- @realm server
    -- @tparam any key The key to associate the data with.
    -- @param value The value to set for the key.
    -- @treturn Inventory Returns the inventory itself.
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

    Inventory.SetData = Inventory.setData
    --- Checks if a certain action is permitted for the inventory.
    -- @function Inventory:canAccess
    -- @realm server
    -- @tparam string action The action to check for access.
    -- @tparam[opt] table context Additional context for the access check.
    -- @treturn boolean|nil Returns true if the action is permitted, false if denied, or nil if not applicable.
    -- @treturn[opt] string A reason for the access result.
    function Inventory:canAccess(action, context)
        context = context or {}
        local result
        for _, rule in ipairs(self.config.accessRules) do
            result, reason = rule(self, action, context)
            if result ~= nil then return result, reason end
        end
    end

    --- Adds an access rule to the inventory.
    -- @function Inventory:addAccessRule
    -- @realm server
    -- @tparam function rule The access rule function.
    -- @tparam[opt] number priority The priority of the access rule.
    -- @treturn Inventory Returns the inventory itself.
    function Inventory:addAccessRule(rule, priority)
        if isnumber(priority) then
            table.insert(self.config.accessRules, priority, rule)
        else
            self.config.accessRules[#self.config.accessRules + 1] = rule
        end
        return self
    end

    --- Removes an access rule from the inventory.
    -- @function Inventory:removeAccessRule
    -- @realm server
    -- @tparam function rule The access rule function to remove.
    -- @treturn Inventory Returns the inventory itself.
    function Inventory:removeAccessRule(rule)
        table.RemoveByValue(self.config.accessRules, rule)
        return self
    end

    --- Retrieves the recipients for synchronization.
    -- @function Inventory:getRecipients
    -- @realm server
    -- @treturn table An array containing the recipients for synchronization.
    function Inventory:getRecipients()
        local recipients = {}
        for _, client in ipairs(player.GetAll()) do
            if self:canAccess("repl", {
                client = client
            }) then
                recipients[#recipients + 1] = client
            end
        end
        return recipients
    end

    --- Initializes an instance of the inventory.
    -- @function Inventory:onInstanced
    -- @realm server
    function Inventory:onInstanced()
    end

    --- Callback function called when the inventory is loaded.
    -- @function Inventory:onLoaded
    -- @realm server
    function Inventory:onLoaded()
        -- Function implementation
    end

    --- Loads items from the database into the inventory.
    -- @function Inventory:loadItems
    -- @realm server
    -- @treturn Deferred A deferred promise.
    function Inventory:loadItems()
        local ITEM_TABLE = "items"
        local ITEM_FIELDS = {"_itemID", "_uniqueID", "_data", "_x", "_y", "_quantity"}
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

    --- Callback function called when items are loaded into the inventory.
    -- @function Inventory:onItemsLoaded
    -- @realm server
    function Inventory:onItemsLoaded()
    end

    --- Instantiates a new inventory instance.
    -- @function Inventory:instance
    -- @realm server
    -- @tparam table initialData Initial data for the inventory instance.
    -- @treturn Inventory The newly instantiated inventory instance.
    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    --- Synchronizes data changes with clients.
    -- @function Inventory:syncData
    -- @realm server
    -- @tparam any key The key whose data has changed.
    -- @tparam[opt] table recipients The recipients to synchronize with.
    function Inventory:syncData(key, recipients)
        if self.config.data[key] and self.config.data[key].noReplication then return end
        net.Start("liaInventoryData")
        net.WriteType(self.id)
        net.WriteString(key)
        net.WriteType(self.data[key])
        net.Send(recipients or self:getRecipients())
    end

    --- Synchronizes the inventory with clients.
    -- @function Inventory:sync
    -- @realm server
    -- @tparam[opt] table recipients The recipients to synchronize with.
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

    --- Deletes the inventory.
    -- @function Inventory:delete
    -- @realm server
    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

    --- Destroys the inventory and its associated items.
    -- @function Inventory:destroy
    -- @realm server
    function Inventory:destroy()
        for _, item in pairs(self:getItems()) do
            item:destroy()
        end

        lia.inventory.instances[self:getID()] = nil
        net.Start("liaInventoryDelete")
        net.WriteType(id)
        net.Broadcast()
    end
else
    --- Displays the inventory UI to the specified parent element.
    -- @tparam[opt] any parent The parent element to which the inventory UI will be displayed.
    -- @return The result of the `lia.inventory.show` function.
    -- @realm client
    function Inventory:show(parent)
        return lia.inventory.show(self, parent)
    end

    Inventory.Show = Inventory.show
end

Inventory.GetItems = Inventory.getItems
Inventory.GetItemsOfType = Inventory.getItemsOfType
Inventory.GetFirstItemOfType = Inventory.getFirstItemOfType
Inventory.HasItem = Inventory.hasItem
Inventory.GetItemCount = Inventory.getItemCount
Inventory.GetID = Inventory.getID
Inventory.GetData = Inventory.getData
Inventory.Show = Inventory.show