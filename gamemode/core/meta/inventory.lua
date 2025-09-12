local Inventory = lia.Inventory or {}
Inventory.__index = Inventory
lia.Inventory = Inventory
Inventory.data = {}
Inventory.items = {}
Inventory.id = -1
function Inventory:getData(key, default)
    local value = self.data[key]
    if value == nil then return default end
    return value
end

function Inventory:extend(className)
    local base = debug.getregistry()[className] or {}
    table.Empty(base)
    base.className = className
    local subClass = table.Inherit(base, self)
    subClass.__index = subClass
    return subClass
end

function Inventory:configure()
end

function Inventory:addDataProxy(key, onChange)
    local dataConfig = self.config.data[key] or {}
    dataConfig.proxies[#dataConfig.proxies + 1] = onChange
    self.config.data[key] = dataConfig
end

function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    local items = {}
    for _, v in pairs(self:getItems(onlyMain)) do
        if v.uniqueID == uniqueID then items[#items + 1] = v end
    end
    return items
end

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

function Inventory:new()
    return lia.inventory.new(self.typeID)
end

function Inventory:tostring()
    return L(self.className) .. "[" .. tostring(self.id) .. "]"
end

function Inventory:getType()
    return lia.inventory.types[self.typeID]
end

function Inventory:onDataChanged(key, oldValue, newValue)
    local keyData = self.config.data[key]
    if keyData and keyData.proxies then
        for _, proxy in pairs(keyData.proxies) do
            proxy(oldValue, newValue)
        end
    end
end

function Inventory:getItems()
    return self.items
end

function Inventory:getItemsOfType(itemType)
    local items = {}
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then items[#items + 1] = item end
    end
    return items
end

function Inventory:getFirstItemOfType(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return item end
    end
end

function Inventory:hasItem(itemType)
    for _, item in pairs(self:getItems()) do
        if item.uniqueID == itemType then return true end
    end
    return false
end

function Inventory:getItemCount(itemType)
    local count = 0
    for _, item in pairs(self:getItems()) do
        if itemType == nil or item.uniqueID == itemType then count = count + item:getQuantity() end
    end
    return count
end

function Inventory:getID()
    return self.id
end

function Inventory:eq(other)
    return self:getID() == other:getID()
end

if SERVER then
    function Inventory:addItem(item, noReplicate)
        self.items[item:getID()] = item
        item.invID = self:getID()
        local id = self.id
        if not isnumber(id) then id = NULL end
        lia.db.updateTable({
            invID = id
        }, nil, "items", "itemID = " .. item:getID())

        local charID = self:getData("char")
        if charID then
            local client = self:getRecipients()[1]
            if IsValid(client) then
                item:setData("charID", charID, nil, true, true)
                item:setData("steamID", client:SteamID(), nil, true, true)
                if IsValid(item.entity) then
                    item.entity.liaCharID = charID
                    item.entity.liaSteamID = client:SteamID()
                    item.entity.SteamID = client:SteamID()
                end
            end
        end

        self:syncItemAdded(item)
        if not noReplicate then hook.Run("OnItemAdded", item:getOwner(), item) end
        return self
    end

    function Inventory:add(item)
        return self:addItem(item)
    end

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

    function Inventory:initializeStorage(initialData)
        local d = deferred.new()
        local charID = initialData.char
        lia.db.waitForTablesToLoad():next(function()
            lia.db.tableExists("lia_inventories"):next(function(inventoriesExists)
                if not inventoriesExists then
                    d:reject("Inventory tables not yet loaded")
                    return
                end

                lia.db.tableExists("lia_invdata"):next(function(invdataExists)
                    if not invdataExists then
                        d:reject("Inventory data tables not yet loaded")
                        return
                    end

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
                    end, "inventories"):catch(function(err) d:reject("Failed to create inventory: " .. tostring(err)) end)
                end)
            end)
        end):catch(function(err) d:reject("Failed to wait for database tables: " .. tostring(err)) end)
        return d
    end

    function Inventory:restoreFromStorage()
    end

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

    function Inventory:remove(itemID)
        return self:removeItem(itemID)
    end

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
                lia.db.delete("invdata", "invID = " .. self.id .. " AND key = " .. lia.db.convertDataType(key))
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
    local ITEM_FIELDS = {"itemID", "uniqueID", "data", "x", "y", "quantity"}
    function Inventory:loadItems()
        return lia.db.select(ITEM_FIELDS, ITEM_TABLE, "invID = " .. self.id):next(function(res)
            local items = {}
            for _, result in ipairs(res.results or {}) do
                local itemID = tonumber(result.itemID)
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

    function Inventory:onItemsLoaded()
    end

    function Inventory:instance(initialData)
        return lia.inventory.instance(self.typeID, initialData)
    end

    function Inventory:syncData(key, recipients)
        if self.config.data[key] and self.config.data[key].noReplication then return end
        net.Start("liaInventoryData")
        net.WriteType(self.id)
        net.WriteString(key)
        net.WriteType(self.data[key])
        net.Send(recipients or self:getRecipients())
    end

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

    function Inventory:delete()
        lia.inventory.deleteByID(self.id)
    end

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
