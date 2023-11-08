--------------------------------------------------------------------------------------------------------------------------
function MODULE:HandleItemTransferRequest(client, itemID, x, y, invID)
    local inventory = lia.inventory.instances[invID]
    local item = lia.item.instances[itemID]
    if not item then return end
    local oldInventory = lia.inventory.instances[item.invID]
    if not oldInventory or not oldInventory.items[itemID] then return end
    local status, reason = hook.Run("CanItemBeTransfered", item, oldInventory, inventory, client)
    if status == false then
        client:notify(reason or "You can't do that right now.")
        return
    end

    local context = {
        client = client,
        item = item,
        from = oldInventory,
        to = inventory
    }

    local canTransfer, reason = oldInventory:canAccess("transfer", context)
    if not canTransfer then return end
    if not inventory then return hook.Run("ItemDraggedOutOfInventory", client, item) end
    canTransfer, reason = inventory:canAccess("transfer", context)
    if not canTransfer then
        if isstring(reason) then client:notifyLocalized(reason) end
        return
    end

    local oldX, oldY = item:getData("x"), item:getData("y")
    local failItemDropPos = client:getItemDropPos()
    if client.invTransferTransaction and client.invTransferTransactionTimeout > RealTime() then return end
    client.invTransferTransaction = true
    client.invTransferTransactionTimeout = RealTime()
    local function fail(err)
        client.invTransferTransaction = nil
        if err then
            print(err)
            debug.Trace()
        end

        if IsValid(client) then client:notifyLocalized("itemOnGround") end
        item:spawn(failItemDropPos)
    end

    local tryCombineWith
    local originalAddRes
    return     oldInventory:removeItem(itemID, true):next(function() return inventory:add(item, x, y) end):next(
        function(res)
            if not res or not res.error then return end
            local conflictingItem = istable(res.error) and res.error.item
            if conflictingItem then tryCombineWith = conflictingItem end
            originalAddRes = res
            return oldInventory:add(item, oldX, oldY)
        end
    ):next(
        function(res)
            if res and res.error then return res end
            if tryCombineWith and IsValid(client) then if hook.Run("ItemCombine", client, item, tryCombineWith) then return end end
        end
    ):next(
        function(res)
            client.invTransferTransaction = nil
            if res and res.error then
                fail()
            else
                hook.Run("ItemTransfered", context)
            end
            return originalAddRes
        end
    ):catch(fail)
end
--------------------------------------------------------------------------------------------------------------------------
