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

function Inventory:new()
    return lia.inventory.new(self.typeID)
end

function Inventory:tostring()
    return self.className .. "[" .. tostring(self.id) .. "]"
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

local GridInv = lia.Inventory:extend("GridInv")
local function CanAccessInventoryIfCharacterIsOwner(inventory, action, context)
    if inventory.virtual then return action == "transfer" end
    local ownerID = inventory:getData("char")
    local client = context.client
    if table.HasValue(client.liaCharList or {}, ownerID) then return true end
end

local function CanNotAddItemIfNoSpace(inventory, action, context)
    if action ~= "add" then return end
    if inventory.virtual then return true end
    local x, y = context.x, context.y
    if not x or not y then return false, L("noFit") end
    local doesFit, item = inventory:doesItemFitAtPos(context.item, x, y)
    if not doesFit then
        return false, {
            item = item
        }
    end
    return true
end

function GridInv:getWidth()
    return self:getData("w", lia.config.get("invW"))
end

function GridInv:getHeight()
    return self:getData("h", lia.config.get("invH"))
end

function GridInv:getSize()
    return self:getWidth(), self:getHeight()
end

function GridInv:canItemFitInInventory(item, x, y)
    local invW, invH = self:getSize()
    local itemW, itemH = (item.width or 1) - 1, (item.height or 1) - 1
    return x >= 1 and y >= 1 and x + itemW <= invW and y + itemH <= invH
end

function GridInv:canAdd(item)
    if isstring(item) then item = lia.item.list[item] end
    assert(istable(item), "item must be a table")
    assert(isnumber(item.width) and item.width >= 1, "item.width must be a positive number")
    assert(isnumber(item.height) and item.height >= 1, "item.height must be a positive number")
    local invW, invH = self:getSize()
    local itemW, itemH = item.width, item.height
    if itemH <= invW and itemW <= invH then return true end
    return false
end

function GridInv:doesItemOverlapWithOther(testItem, x, y, item)
    local testX2, testY2 = x + (testItem.width or 1), y + (testItem.height or 1)
    local itemX, itemY = item:getData("x"), item:getData("y")
    if not itemX or not itemY then return false end
    local itemX2, itemY2 = itemX + (item.width or 1), itemY + (item.height or 1)
    if x >= itemX2 or itemX >= testX2 then return false end
    if y >= itemY2 or itemY >= testY2 then return false end
    return true
end

function GridInv:doesFitInventory(item)
    local x, y = self:findFreePosition(item)
    if x and y then return true end
    for _, bagItem in pairs(self:getItems(true)) do
        if bagItem.isBag then
            local bagInventory = bagItem:getInv()
            x, y = bagInventory:findFreePosition(item)
            if x and y then return true end
        end
    end
    return false
end

function GridInv:doesItemFitAtPos(testItem, x, y)
    if not self:canItemFitInInventory(testItem, x, y) then return false end
    for _, item in pairs(self.items) do
        if self:doesItemOverlapWithOther(testItem, x, y, item) then return false, item end
    end

    if self.occupied then
        for x2 = 0, (testItem.width or 1) - 1 do
            for y2 = 0, (testItem.height or 1) - 1 do
                if self.occupied[x + x2 .. y + y2] then return false end
            end
        end
    end
    return true
end

function GridInv:findFreePosition(item)
    local width, height = self:getSize()
    for x = 1, width do
        for y = 1, height do
            if self:doesItemFitAtPos(item, x, y) then return x, y end
        end
    end
end

function GridInv:configure()
    if SERVER then
        self:addAccessRule(CanNotAddItemIfNoSpace)
        self:addAccessRule(CanAccessInventoryIfCharacterIsOwner)
    end
end

function GridInv:getItems(noRecurse)
    local items = self.items
    if noRecurse then return items end
    local allItems = {}
    for id, item in pairs(items) do
        allItems[id] = item
        if item.getInv and item:getInv() then allItems = table.Merge(allItems, item:getInv():getItems()) end
    end
    return allItems
end

if SERVER then
    function GridInv:setSize(w, h)
        self:setData("w", w)
        self:setData("h", h)
    end

    function GridInv:wipeItems()
        for _, item in pairs(self:getItems()) do
            item:remove()
        end
    end

    function GridInv:setOwner(owner, fullUpdate)
        if type(owner) == "Player" and owner:getChar() then
            owner = owner:getChar():getID()
        elseif not isnumber(owner) then
            return
        end

        if SERVER then
            if fullUpdate then
                for _, client in player.Iterator() do
                    if client:getChar():getID() == owner then
                        self:sync(client)
                        break
                    end
                end
            end

            self:setData("char", owner)
        end

        self.owner = owner
    end

    function GridInv:add(itemTypeOrItem, xOrQuantity, yOrData, noReplicate)
        local x, y, data
        local isStackCommand = isstring(itemTypeOrItem) and isnumber(xOrQuantity)
        if istable(yOrData) then
            local quantity = tonumber(xOrQuantity) or 1
            data = yOrData
            if quantity > 1 then
                local items = {}
                for i = 1, quantity do
                    items[i] = self:add(itemTypeOrItem, 1, data, noReplicate)
                end
                return deferred.all(items)
            end
        else
            x = tonumber(xOrQuantity)
            y = tonumber(yOrData)
        end

        local d = deferred.new()
        local item, justAddDirectly
        if lia.item.isItem(itemTypeOrItem) then
            item = itemTypeOrItem
            justAddDirectly = true
        else
            item = lia.item.list[itemTypeOrItem]
        end

        if not item then return d:reject("invalid item type") end
        local targetInventory = self
        local fits = targetInventory:canAdd(itemTypeOrItem)
        if not fits then return d:reject("No space available for the item.") end
        if not x or not y then
            x, y = self:findFreePosition(item)
            if not x or not y then
                for _, bagItem in pairs(self:getItems(true)) do
                    if bagItem.isBag then
                        local bagInventory = bagItem:getInv()
                        x, y = bagInventory:findFreePosition(item)
                        if x and y then
                            targetInventory = bagInventory
                            break
                        end
                    end
                end
            end
        end

        if isStackCommand and item.isStackable ~= true then isStackCommand = false end
        local targetAssignments = {}
        local remainingQuantity = xOrQuantity
        if isStackCommand then
            local items = targetInventory:getItemsOfType(itemTypeOrItem)
            if items then
                for _, targetItem in pairs(items) do
                    if remainingQuantity == 0 then break end
                    local freeSpace = targetItem.maxQuantity - targetItem:getQuantity()
                    if freeSpace > 0 then
                        local filler = freeSpace - remainingQuantity
                        if filler > 0 then
                            targetAssignments[targetItem] = remainingQuantity
                            remainingQuantity = 0
                        else
                            targetAssignments[targetItem] = freeSpace
                            remainingQuantity = math.abs(filler)
                        end
                    end
                end
            end
        end

        if isStackCommand and remainingQuantity == 0 then
            local resultItems = {}
            for targetItem, assignedQuantity in pairs(targetAssignments) do
                targetItem:addQuantity(assignedQuantity)
                table.insert(resultItems, targetItem)
            end
            return d:resolve(resultItems)
        end

        local context = {
            item = item,
            x = x,
            y = y
        }

        local canAccess, reason = targetInventory:canAccess("add", context)
        if not canAccess then
            if istable(reason) then
                return d:resolve({
                    error = reason
                })
            else
                return d:reject(tostring(reason or "noAccess"))
            end
        end

        if not isStackCommand and justAddDirectly then
            item:setData("x", x)
            item:setData("y", y)
            targetInventory:addItem(item, noReplicate)
            return d:resolve(item)
        end

        targetInventory.occupied = targetInventory.occupied or {}
        for x2 = 0, (item.width or 1) - 1 do
            for y2 = 0, (item.height or 1) - 1 do
                targetInventory.occupied[x + x2 .. y + y2] = true
            end
        end

        data = table.Merge({
            x = x,
            y = y
        }, data or {})

        local itemType = item.uniqueID
        lia.item.instance(targetInventory:getID(), itemType, data, 0, 0, function(item)
            if targetInventory.occupied then
                for x2 = 0, (item.width or 1) - 1 do
                    for y2 = 0, (item.height or 1) - 1 do
                        targetInventory.occupied[x + x2 .. y + y2] = nil
                    end
                end
            end

            targetInventory:addItem(item, noReplicate)
            d:resolve(item)
        end):next(function(item)
            if isStackCommand and remainingQuantity > 0 then
                for targetItem, assignedQuantity in pairs(targetAssignments) do
                    targetItem:addQuantity(assignedQuantity)
                end

                local overStacks = math.ceil(remainingQuantity / item.maxQuantity) - 1
                if overStacks > 0 then
                    local items = {}
                    for i = 1, overStacks do
                        items[i] = self:add(itemTypeOrItem)
                    end

                    deferred.all(items):next(nil, function() hook.Run("OnPlayerLostStackItem", itemTypeOrItem) end)
                    item:setQuantity(remainingQuantity - item.maxQuantity * overStacks)
                    targetInventory:addItem(item, noReplicate)
                    return d:resolve(items)
                else
                    item:setQuantity(remainingQuantity)
                end
            end
        end)
        return d
    end

    function GridInv:remove(itemTypeOrID, quantity)
        quantity = quantity or 1
        assert(isnumber(quantity), "quantity must be a number")
        local d = deferred.new()
        if quantity <= 0 then return d:reject("quantity must be positive") end
        if isnumber(itemTypeOrID) then
            self:removeItem(itemTypeOrID)
        else
            local items = self:getItemsOfType(itemTypeOrID)
            for i = 1, math.min(quantity, #items) do
                self:removeItem(items[i]:getID())
            end
        end

        d:resolve()
        return d
    end
else
    function GridInv:requestTransfer(itemID, destinationID, x, y)
        local inventory = lia.inventory.instances[destinationID]
        if not inventory then return end
        local item = inventory.items[itemID]
        if item and item:getData("x") == x and item:getData("y") == y then return end
        if item and (x > inventory:getWidth() or y > inventory:getHeight() or x + (item.width or 1) - 1 < 1 or y + (item.height or 1) - 1 < 1) then destinationID = nil end
        net.Start("liaTransferItem")
        net.WriteUInt(itemID, 32)
        net.WriteUInt(x, 32)
        net.WriteUInt(y, 32)
        net.WriteType(destinationID)
        net.SendToServer()
    end
end

GridInv:register("grid")