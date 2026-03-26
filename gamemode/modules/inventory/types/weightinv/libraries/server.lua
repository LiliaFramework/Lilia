function MODULE:HandleItemTransferRequest(client, itemID, x, y, invID)
    local newInventory = lia.inventory.instances[invID]
    local item = lia.item.instances[itemID]
    if not item then return end
    local oldInventory = lia.inventory.instances[item.invID]
    if not oldInventory or not oldInventory.items[itemID] then return end
    local transferAllowed, transferReason = hook.Run("CanItemBeTransfered", item, oldInventory, newInventory, client)
    if transferAllowed == false then
        client:notifyErrorLocalized(transferReason or "notNow")
        return
    end

    local context = {
        client = client,
        item = item,
        from = oldInventory,
        to = newInventory
    }

    local canAccessTransfer, accessReason = oldInventory:canAccess("transfer", context)
    if not newInventory then return hook.Run("ItemDraggedOutOfInventory", client, item) end
    if not canAccessTransfer then
        if isstring(accessReason) then client:notifyErrorLocalized(accessReason) end
        return
    end

    local canAccessTransferTo, accessReasonTo = newInventory:canAccess("transfer", context)
    if not canAccessTransferTo then
        if isstring(accessReasonTo) then client:notifyErrorLocalized(accessReasonTo) end
        return
    end

    local dropPos = client:getItemDropPos()
    if client.invTransferTransaction and client.invTransferTransactionTimeout > RealTime() then return end
    client.invTransferTransaction = true
    client.invTransferTransactionTimeout = RealTime()
    local function fail(err)
        client.invTransferTransaction = nil
        if err then
            lia.error(err)
            debug.Trace()
        end

        if IsValid(client) then lia.log.add(client, "itemTransferFailed", item:getName(), oldInventory:getID(), newInventory and newInventory:getID() or 0) end
        if IsValid(client) then client:notifyInfoLocalized("itemOnGround") end
        item:spawn(dropPos)
    end
    return oldInventory:removeItem(itemID, true):next(function() return newInventory:add(item) end):next(function(res)
        client.invTransferTransaction = nil
        if res and res.error then
            fail()
        else
            hook.Run("ItemTransfered", context)
        end
    end):catch(fail)
end
