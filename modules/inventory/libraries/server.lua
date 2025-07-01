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
    local item = context.item
    if not item.isBag then return end
    local bagInventory = item:getInv()
    if not bagInventory then return end
    for _, item in pairs(bagInventory:getItems()) do
        local canTransferItem, reason = hook.Run("CanItemBeTransfered", item, bagInventory, bagInventory, context.client)
        if canTransferItem == false then return false, reason or L("nestedItemTransferError") end
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
    local inventory = lia.inventory.instances[invID]
    local item = lia.item.instances[itemID]
    if not item then return end
    local oldInventory = lia.inventory.instances[item.invID]
    if not oldInventory or not oldInventory.items[itemID] then return end
    local status, reason = hook.Run("CanItemBeTransfered", item, oldInventory, inventory, client)
    if status == false then
        client:notify(reason or L("notNow"))
        return
    end

    local context = {
        client = client,
        item = item,
        from = oldInventory,
        to = inventory
    }

    local canTransfer, reason = oldInventory:canAccess("transfer", context)
    if not inventory then return hook.Run("ItemDraggedOutOfInventory", client, item) end
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
    return oldInventory:removeItem(itemID, true):next(function() return inventory:add(item, x, y) end):next(function(res)
        if not res or not res.error then return end
        local conflictingItem = istable(res.error) and res.error.item
        if conflictingItem then tryCombineWith = conflictingItem end
        originalAddRes = res
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
        return originalAddRes
    end):catch(fail)
end
