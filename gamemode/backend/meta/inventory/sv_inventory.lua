--------------------------------------------------------------------------------------------------------
local Inventory = lia.Inventory
local INV_TABLE_NAME = "inventories"
local INV_DATA_TABLE_NAME = "invdata"
--------------------------------------------------------------------------------------------------------
function Inventory:addItem(item)
    self.items[item:getID()] = item
    item.invID = self:getID()
    local id = self.id
    if not isnumber(id) then
        id = NULL
    end

    lia.db.updateTable(
        {
            _invID = id
        }, nil, "items", "_itemID = " .. item:getID()
    )

    self:syncItemAdded(item)

    return self
end
--------------------------------------------------------------------------------------------------------
function Inventory:add(item)
    return self:addItem(item)
end
--------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------
function Inventory:initializeStorage(initialData)
    local d = deferred.new()
    local charID = initialData.char
    lia.db.insertTable(
        {
            _invType = self.typeID,
            _charID = charID
        },
        function(results, lastID)
            local count = 0
            local expected = table.Count(initialData)
            if initialData.char then
                expected = expected - 1
            end

            if expected == 0 then return d:resolve(lastID) end
            for key, value in pairs(initialData) do
                if key == "char" then continue end
                lia.db.insertTable(
                    {
                        _invID = lastID,
                        _key = key,
                        _value = {value}
                    },
                    function()
                        count = count + 1
                        if count == expected then
                            d:resolve(lastID)
                        end
                    end, INV_DATA_TABLE_NAME
                )
            end
        end, INV_TABLE_NAME
    )

    return d
end
--------------------------------------------------------------------------------------------------------
function Inventory:restoreFromStorage(id)
end
--------------------------------------------------------------------------------------------------------
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
            lia.db.updateTable(
                {
                    _invID = NULL
                },
                function()
                    d:resolve()
                end, "items", "_itemID = " .. itemID
            )
        end
    else
        d:resolve()
    end

    return d
end
--------------------------------------------------------------------------------------------------------
function Inventory:remove(itemID)
    return self:removeItem(itemID)
end
--------------------------------------------------------------------------------------------------------
function Inventory:setData(key, value)
    local oldValue = self.data[key]
    self.data[key] = value
    local keyData = self.config.data[key]
    if key == "char" then
        lia.db.updateTable(
            {
                _charID = value
            }, nil, INV_TABLE_NAME, "_invID = " .. self:getID()
        )
    elseif not keyData or not keyData.notPersistent then
        if value == nil then
            lia.db.delete(INV_DATA_TABLE_NAME, "_invID = " .. self.id .. " AND _key = '" .. lia.db.escape(key) .. "'")
        else
            lia.db.upsert(
                {
                    _invID = self.id,
                    _key = key,
                    _value = {value}
                }, INV_DATA_TABLE_NAME
            )
        end
    end

    self:syncData(key)
    self:onDataChanged(key, oldValue, value)

    return self
end
--------------------------------------------------------------------------------------------------------
function Inventory:canAccess(action, context)
    context = context or {}
    local result

    for _, rule in ipairs(self.config.accessRules) do
        result, reason = rule(self, action, context)
        if result ~= nil then return result, reason end
    end
end
--------------------------------------------------------------------------------------------------------
function Inventory:addAccessRule(rule, priority)
    if isnumber(priority) then
        table.insert(self.config.accessRules, priority, rule)
    else
        self.config.accessRules[#self.config.accessRules + 1] = rule
    end

    return self
end
--------------------------------------------------------------------------------------------------------
function Inventory:removeAccessRule(rule)
    table.RemoveByValue(self.config.accessRules, rule)

    return self
end
--------------------------------------------------------------------------------------------------------
function Inventory:getRecipients()
    local recipients = {}
    for _, client in ipairs(player.GetAll()) do
        if self:canAccess(
            "repl",
            {
                client = client
            }
        ) then
            recipients[#recipients + 1] = client
        end
    end

    return recipients
end
--------------------------------------------------------------------------------------------------------
function Inventory:onInstanced()
end
--------------------------------------------------------------------------------------------------------
function Inventory:onLoaded()
end
--------------------------------------------------------------------------------------------------------
function Inventory:loadItems()
    local ITEM_TABLE = "items"
    local ITEM_FIELDS = {"_itemID", "_uniqueID", "_data", "_x", "_y", "_quantity"}

    return lia.db.select(ITEM_FIELDS, ITEM_TABLE, "_invID = " .. self.id):next(
        function(res)
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
                if result._data then
                    item.data = table.Merge(item.data, util.JSONToTable(result._data) or {})
                end

                item.data.x = tonumber(result._x)
                item.data.y = tonumber(result._y)
                item.quantity = tonumber(result._quantity)
                items[itemID] = item
                item:onRestored(self)
            end

            self.items = items
            self:onItemsLoaded(items)

            return items
        end
    )
end
--------------------------------------------------------------------------------------------------------
function Inventory:onItemsLoaded(items)
end
--------------------------------------------------------------------------------------------------------
function Inventory:instance(initialData)
    return lia.inventory.instance(self.typeID, initialData)
end
--------------------------------------------------------------------------------------------------------
function Inventory:syncData(key, recipients)
    if self.config.data[key] and self.config.data[key].noReplication then return end
    net.Start("liaInventoryData")
    net.WriteType(self.id)
    net.WriteString(key)
    net.WriteType(self.data[key])
    net.Send(recipients or self:getRecipients())
end
--------------------------------------------------------------------------------------------------------
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
    local res = net.Send(recipients or self:getRecipients())
    for _, item in pairs(self.items) do
        item:onSync(recipients)
    end
end
--------------------------------------------------------------------------------------------------------
function Inventory:delete()
    lia.inventory.deleteByID(self.id)
end
--------------------------------------------------------------------------------------------------------
function Inventory:destroy()
    for _, item in pairs(self:getItems()) do
        item:destroy()
    end

    lia.inventory.instances[self:getID()] = nil
    net.Start("liaInventoryDelete")
    net.WriteType(id)
    net.Broadcast()
end
--------------------------------------------------------------------------------------------------------