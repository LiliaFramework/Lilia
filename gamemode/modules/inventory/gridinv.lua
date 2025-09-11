local GridInv = lia.Inventory:extend("GridInv")
local function CanAccessInventoryIfCharacterIsOwner(inventory, action, context)
    if inventory.virtual then return action == "transfer" end
    local ownerID = inventory:getData("char")
    local client = context.client
    if table.HasValue(client.liaCharList or {}, ownerID) then return true end
    if IsValid(client.liaSearchTarget) then
        local target = client.liaSearchTarget
        if IsValid(target) and target:getChar() then
            local targetCharID = target:getChar():getID()
            if targetCharID == ownerID then return true end
            if not ownerID then
                local targetInv = target:getChar():getInv()
                if targetInv and targetInv:getID() == inventory:getID() then return true end
            end
        end
    end
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

function GridInv:canAdd(item)
    if isstring(item) then item = lia.item.list[item] end
    assert(istable(item), L("itemMustBeTable"))
    assert(isnumber(item.width) and item.width >= 1, L("itemWidthPositiveNumber"))
    assert(isnumber(item.height) and item.height >= 1, L("itemHeightPositiveNumber"))
    local invW, invH = self:getSize()
    local itemW, itemH = item:getWidth(), item:getHeight()
    if itemW <= invW and itemH <= invH then return true end
    if itemH <= invW and itemW <= invH then return true end
    return false
end

function GridInv:doesItemOverlapWithOther(testItem, x, y, item)
    local testX2, testY2 = x + testItem:getWidth(), y + testItem:getHeight()
    local itemX, itemY = item:getData("x"), item:getData("y")
    if not itemX or not itemY then return false end
    local itemX2, itemY2 = itemX + item:getWidth(), itemY + item:getHeight()
    if x >= itemX2 or itemX >= testX2 then return false end
    if y >= itemY2 or itemY >= testY2 then return false end
    return true
end

function GridInv:doesFitInventory(item)
    if isstring(item) then item = lia.item.list[item] end
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

function GridInv:canItemFitInInventory(item, x, y)
    local invW, invH = self:getSize()
    local itemW, itemH = item:getWidth() - 1, item:getHeight() - 1
    return x >= 1 and y >= 1 and x + itemW <= invW and y + itemH <= invH
end

function GridInv:doesItemFitAtPos(testItem, x, y)
    if not self:canItemFitInInventory(testItem, x, y) then return false end
    for _, v in pairs(self.items) do
        if self:doesItemOverlapWithOther(testItem, x, y, v) then return false, v end
    end

    if self.occupied then
        local w, h = testItem:getWidth(), testItem:getHeight()
        for x2 = 0, w - 1 do
            for y2 = 0, h - 1 do
                if self.occupied[x + x2 .. y + y2] then return false end
            end
        end
    end
    return true
end

function GridInv:findFreePosition(item)
    local w, h = self:getSize()
    for x = 1, w do
        for y = 1, h do
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

        if fullUpdate then
            for _, client in player.Iterator() do
                if client:getChar():getID() == owner then
                    self:sync(client)
                    break
                end
            end
        end

        self:setData("char", owner)
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

        if not item then return d:reject(L("invalidItemTypeOrID", item and item.name or tostring(itemTypeOrItem))) end
        local targetInventory = self
        if not targetInventory:canAdd(itemTypeOrItem) then return d:reject(L("noSpaceForItem")) end
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
        local targetAssignments, remainingQuantity = {}, xOrQuantity
        if isStackCommand then
            local existing = targetInventory:getItemsOfType(itemTypeOrItem)
            if existing then
                for _, targetItem in pairs(existing) do
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
            end
            return d:reject(tostring(reason or L("noAccess")))
        end

        if not isStackCommand and justAddDirectly then
            item:setData("x", x)
            item:setData("y", y)
            targetInventory:addItem(item, noReplicate)
            return d:resolve(item)
        end

        targetInventory.occupied = targetInventory.occupied or {}
        for x2 = 0, item:getWidth() - 1 do
            for y2 = 0, item:getHeight() - 1 do
                targetInventory.occupied[x + x2 .. y + y2] = true
            end
        end

        data = table.Merge({
            x = x,
            y = y
        }, data or {})

        local itemType = item.uniqueID
        lia.item.instance(targetInventory:getID(), itemType, data, 0, 0, function(instItem)
            if targetInventory.occupied then
                for x2 = 0, instItem:getWidth() - 1 do
                    for y2 = 0, instItem:getHeight() - 1 do
                        targetInventory.occupied[x + x2 .. y + y2] = nil
                    end
                end
            end

            targetInventory:addItem(instItem, noReplicate)
            d:resolve(instItem)
        end):next(function(returnedItem)
            if isStackCommand and remainingQuantity > 0 then
                for targetItem, assignedQuantity in pairs(targetAssignments) do
                    targetItem:addQuantity(assignedQuantity)
                end

                local overStacks = math.ceil(remainingQuantity / returnedItem.maxQuantity) - 1
                if overStacks > 0 then
                    local items = {}
                    for i = 1, overStacks do
                        items[i] = self:add(itemTypeOrItem)
                    end

                    deferred.all(items):next(nil, function() hook.Run("OnPlayerLostStackItem", itemTypeOrItem) end)
                    returnedItem:setQuantity(remainingQuantity - returnedItem.maxQuantity * overStacks)
                    targetInventory:addItem(returnedItem, noReplicate)
                    return d:resolve(items)
                end

                returnedItem:setQuantity(remainingQuantity)
            end
        end)
        return d
    end

    function GridInv:remove(itemTypeOrID, quantity)
        quantity = quantity or 1
        assert(isnumber(quantity), L("quantityMustBeNumber"))
        local d = deferred.new()
        if quantity <= 0 then return d:reject(L("quantityMustBePositive")) end
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
        local item = lia.item.instances[itemID]
        if not item then return end

        -- Handle drop outside inventory (destinationID is nil)
        if not destinationID then
            net.Start("liaTransferItem")
            net.WriteUInt(itemID, 32)
            net.WriteUInt(x, 32)
            net.WriteUInt(y, 32)
            net.WriteType(destinationID)
            net.SendToServer()
            return
        end

        -- Handle normal inventory transfer
        -- Allow transfers even to the same position to prevent user confusion
        -- if item and item:getData("x") == x and item:getData("y") == y then return end
        if item and (x > inventory:getWidth() or y > inventory:getHeight() or x + item:getWidth() - 1 < 1 or y + item:getHeight() - 1 < 1) then destinationID = nil end
        net.Start("liaTransferItem")
        net.WriteUInt(itemID, 32)
        net.WriteUInt(x, 32)
        net.WriteUInt(y, 32)
        net.WriteType(destinationID)
        net.SendToServer()
    end
end

GridInv:register("GridInv")
