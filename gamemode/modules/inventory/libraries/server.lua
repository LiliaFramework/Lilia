local function CanAccessIfPlayerHasAccessToBag(inventory, action, context)
    local bagItemID = inventory:getData("item")
    if not bagItemID then return end
    local bagItem = lia.item.instances[bagItemID]
    if not bagItem then return false, L("invalidBagItem") end
    local parentInv = lia.inventory.instances[bagItem.invID]
    if parentInv == inventory then return end
    local contextWithBagInv = {}
    for key, value in pairs(context) do
        contextWithBagInv[key] = value
    end

    contextWithBagInv.bagInv = inventory
    return parentInv and parentInv:canAccess(action, contextWithBagInv) or false, L("noAccess")
end

local function CanNotTransferBagIntoBag(_, action, context)
    if action ~= "transfer" then return end
    local item, toInventory = context.item, context.to
    if toInventory and toInventory:getData("item") and item.isBag then return false, L("bagIntoBagError") end
end

local function CanNotTransferBagIfNestedItemCanNotBe(_, action, context)
    if action ~= "transfer" then return end
    local bag = context.item
    if not bag.isBag then return end
    local bagInventory = bag:getInv()
    if not bagInventory then return end
    for _, nestedItem in pairs(bagInventory:getItems()) do
        local canTransfer, reason = hook.Run("CanItemBeTransfered", nestedItem, bagInventory, bagInventory, context.client)
        if canTransfer == false then return false, reason or L("nestedItemTransferError") end
    end
end

function MODULE:SetupBagInventoryAccessRules(inventory)
    inventory:addAccessRule(CanNotTransferBagIntoBag, 1)
    inventory:addAccessRule(CanNotTransferBagIfNestedItemCanNotBe, 1)
    inventory:addAccessRule(CanAccessIfPlayerHasAccessToBag)
end

function MODULE:ItemCombine(client, item, target)
    if target.onCombine and target:call("onCombine", client, nil, item) then return end
    if item.onCombineTo and item and item:call("onCombineTo", client, nil, target) then return end
    lia.log.add(client, "itemCombine", item:getName(), target:getName())
end

function MODULE:ItemDraggedOutOfInventory(client, item)
    item:interact("drop", client)
end

function MODULE:PlayerLoadedChar(client, character)
    local inv = character:getInv()
    if inv then
        local w, h = inv:getSize()
        local baseW, baseH = lia.config.get("invW"), lia.config.get("invH")
        if w ~= baseW or h ~= baseH then return w, h end
        local dw, dh = hook.Run("GetDefaultInventorySize", client)
        dw = dw or baseW
        dh = dh or baseH
        w, h = inv:getSize()
        if w ~= dw or h ~= dh then
            inv:setSize(dw, dh)
            inv:sync(client)
        end
    end
end

function MODULE:HandleItemTransferRequest(client, itemID, x, y, invID)
    local newInventory = lia.inventory.instances[invID]
    local item = lia.item.instances[itemID]
    if not item then return end
    local oldInventory = lia.inventory.instances[item.invID]
    if not oldInventory or not oldInventory.items[itemID] then return end
    local transferAllowed, transferReason = hook.Run("CanItemBeTransfered", item, oldInventory, newInventory, client)
    if transferAllowed == false then
        client:notifyLocalized(transferReason or "notNow")
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
        if isstring(accessReason) then client:notifyLocalized(accessReason) end
        return
    end

    local canAccessTransferTo, accessReasonTo = newInventory:canAccess("transfer", context)
    if not canAccessTransferTo then
        if isstring(accessReasonTo) then client:notifyLocalized(accessReasonTo) end
        return
    end

    local oldX, oldY = item:getData("x"), item:getData("y")
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
        if IsValid(client) then client:notifyLocalized("itemOnGround") end
        item:spawn(dropPos)
    end

    local tryCombineWith
    local originalAddResult
    return oldInventory:removeItem(itemID, true):next(function() return newInventory:add(item, x, y) end):next(function(res)
        if not res or not res.error then return end
        if istable(res.error) then tryCombineWith = res.error.item end
        originalAddResult = res
        return oldInventory:add(item, oldX, oldY)
    end):next(function(res)
        if res and res.error then return res end
        if tryCombineWith and IsValid(client) and hook.Run("ItemCombine", client, item, tryCombineWith) then return end
    end):next(function(res)
        client.invTransferTransaction = nil
        if res and res.error then
            fail()
        else
            hook.Run("ItemTransfered", context)
        end
        return originalAddResult
    end):catch(fail)
end