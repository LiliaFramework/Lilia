--- The Inventory Meta for the Grid Inventory Module.
-- @inventorymeta Inventory
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
    if not x or not y then return false, "noFit" end
    local doesFit, item = inventory:doesItemFitAtPos(context.item, x, y)
    if not doesFit then
        return false, {
            item = item
        }
    end
    return true
end

--- Retrieves the width of the inventory grid.
-- @realm shared
-- @treturn integer The width of the inventory grid.
function GridInv:getWidth()
    return self:getData("w", lia.config.invW)
end

--- Retrieves the height of the inventory grid.
-- @realm shared
-- @treturn integer The height of the inventory grid.
function GridInv:getHeight()
    return self:getData("h", lia.config.invH)
end

--- Retrieves the size (width and height) of the inventory grid.
-- @realm shared
-- @treturn integer The width of the inventory grid.
-- @treturn integer The height of the inventory grid.
function GridInv:getSize()
    return self:getWidth(), self:getHeight()
end

--- Checks if an item can fit in the inventory at a given position.
-- @realm shared
-- @item item The item to check.
-- @int x The X position in the inventory grid.
-- @int y The Y position in the inventory grid.
-- @treturn boolean Whether the item can fit in the inventory.
function GridInv:canItemFitInInventory(item, x, y)
    local invW, invH = self:getSize()
    local itemW, itemH = (item.width or 1) - 1, (item.height or 1) - 1
    return x >= 1 and y >= 1 and (x + itemW) <= invW and (y + itemH) <= invH
end

--- Checks if an item can fit within the inventory based on its size.
-- Verifies whether the item's width and height are within the bounds of the inventory dimensions.
-- @realm shared
-- @tab item The item to check. The table must include `width` and `height` properties representing the item's dimensions.
-- @treturn boolean `true` if the item fits within the inventory dimensions, `false` otherwise.
-- @usage
-- local canFit = inventory:canAdd(item) -- Example usage: checks if `item` fits in the inventory.
function GridInv:canAdd(item)
    assert(istable(item), "item must be a table")
    assert(isnumber(item.width) and item.width >= 1, "item.width must be a positive number")
    assert(isnumber(item.height) and item.height >= 1, "item.height must be a positive number")
    local invW, invH = self:getSize()
    local itemW, itemH = item.width, item.height
    if itemH <= invW and itemW <= invH then return true end
    return false
end

--- Checks if an item overlaps with another item in the inventory.
-- @realm shared
-- @item testItem The item to test for overlap.
-- @int x The X position of the test item in the inventory grid.
-- @int y The Y position of the test item in the inventory grid.
-- @item item The item to check against.
-- @treturn boolean Whether the test item overlaps with the given item.
function GridInv:doesItemOverlapWithOther(testItem, x, y, item)
    local testX2, testY2 = x + (testItem.width or 1), y + (testItem.height or 1)
    local itemX, itemY = item:getData("x"), item:getData("y")
    if not itemX or not itemY then return false end
    local itemX2, itemY2 = itemX + (item.width or 1), itemY + (item.height or 1)
    if x >= itemX2 or itemX >= testX2 then return false end
    if y >= itemY2 or itemY >= testY2 then return false end
    return true
end

--- Checks if an item can fit in the inventory, including within bags.
-- @realm shared
-- @item item The item to check.
-- @treturn boolean Whether the item can fit in the inventory.
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

--- Checks if an item fits at a specific position in the inventory.
-- @realm shared
-- @item testItem The item to check.
-- @int x The X position in the inventory grid.
-- @int y The Y position in the inventory grid.
-- @treturn boolean Whether the item fits at the given position.
-- @treturn item The item it overlaps with, if any.
function GridInv:doesItemFitAtPos(testItem, x, y)
    if not self:canItemFitInInventory(testItem, x, y) then return false end
    for _, item in pairs(self.items) do
        if self:doesItemOverlapWithOther(testItem, x, y, item) then return false, item end
    end

    if self.occupied then
        for x2 = 0, (testItem.width or 1) - 1 do
            for y2 = 0, (testItem.height or 1) - 1 do
                if self.occupied[(x + x2) .. (y + y2)] then return false end
            end
        end
    end
    return true
end

--- Finds a free position in the inventory where an item can fit.
-- @realm shared
-- @item item The item to find a position for.
-- @treturn int The X position in the inventory grid.
-- @treturn int The Y position in the inventory grid.
function GridInv:findFreePosition(item)
    local width, height = self:getSize()
    for x = 1, width do
        for y = 1, height do
            if self:doesItemFitAtPos(item, x, y) then return x, y end
        end
    end
end

--- Configures the inventory with specific access rules.
-- @realm shared
function GridInv:configure()
    if SERVER then
        self:addAccessRule(CanNotAddItemIfNoSpace)
        self:addAccessRule(CanAccessInventoryIfCharacterIsOwner)
    end
end

--- Retrieves all items in the inventory.
-- @realm shared
-- @bool[opt=false] noRecurse Whether to include items inside bags (nested inventories).
-- @treturn table A table of all items in the inventory.
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
    --- Sets the size of the inventory grid.
    -- @realm server
    -- @int w The width of the grid.
    -- @int h The height of the grid.
    function GridInv:setSize(w, h)
        self:setData("w", w)
        self:setData("h", h)
    end

    --- Removes all items from the inventory.
    -- @realm server
    function GridInv:wipeItems()
        for _, item in pairs(self:getItems()) do
            item:remove()
        end
    end

    --- Sets the owner of the inventory.
    -- If the owner is a player, it sets the inventory's owner to the player's character ID.
    -- @realm server
    -- @param owner The new owner of the inventory (Player or number).
    -- @bool[opt=false] fullUpdate Whether to sync the inventory to the client.
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

    --- Adds an item to the inventory.
    -- Handles both adding a single item or stacking multiple items if applicable.
    -- @realm server
    -- @item itemTypeOrItem The type of the item or the item object to add.
    -- @int xOrQuantity The X position in the grid or the quantity of items to add.
    -- @int yOrData The Y position in the grid or additional data for the item.
    -- @bool[opt=false] noReplicate If true, the addition will not be replicated to clients.
    -- @treturn deferred A deferred object that resolves when the item is added.
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
                targetInventory.occupied[(x + x2) .. (y + y2)] = true
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
                        targetInventory.occupied[(x + x2) .. (y + y2)] = nil
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
                    item:setQuantity(remainingQuantity - (item.maxQuantity * overStacks))
                    targetInventory:addItem(item, noReplicate)
                    return d:resolve(items)
                else
                    item:setQuantity(remainingQuantity)
                end
            end
        end)
        return d
    end

    --- Removes an item or a quantity of items from the inventory.
    -- @realm server
    -- @param itemTypeOrID The type of the item or its ID to remove.
    -- @int[opt=1] quantity The quantity of items to remove.
    -- @treturn deferred A deferred object that resolves when the item is removed.
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
    --- Requests a transfer of an item to another inventory.
    -- @realm client
    -- @int itemID The ID of the item to transfer.
    -- @int destinationID The ID of the destination inventory.
    -- @int x The X position in the destination grid.
    -- @int y The Y position in the destination grid.
    function GridInv:requestTransfer(itemID, destinationID, x, y)
        local inventory = lia.inventory.instances[destinationID]
        if not inventory then return end
        local item = inventory.items[itemID]
        if item and item:getData("x") == x and item:getData("y") == y then return end
        if item and (x > inventory:getWidth() or y > inventory:getHeight() or (x + (item.width or 1) - 1) < 1 or (y + (item.height or 1) - 1) < 1) then destinationID = nil end
        net.Start("liaTransferItem")
        net.WriteUInt(itemID, 32)
        net.WriteUInt(x, 32)
        net.WriteUInt(y, 32)
        net.WriteType(destinationID)
        net.SendToServer()
    end
end

GridInv:register("grid")