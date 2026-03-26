net.Receive("liaStorageExit", function(_, client)
    local storage = client.liaStorageEntity
    if IsValid(storage) then storage.receivers[client] = nil end
    client.liaStorageEntity = nil
end)

net.Receive("liaStorageUnlock", function(_, client)
    local password = net.ReadString()
    local storageFunc = function()
        if not IsValid(client.liaStorageEntity) then return end
        if client:GetPos():Distance(client.liaStorageEntity:GetPos()) > 128 then return end
        return client.liaStorageEntity
    end

    local passwordDelay = 1
    local storage = storageFunc()
    if not storage then return end
    if client.lastPasswordAttempt and CurTime() < client.lastPasswordAttempt + passwordDelay then
        client:notifyWarningLocalized("passwordTooQuick")
    else
        if storage.password == password then
            lia.log.add(client, "storageUnlock", storage:GetClass())
            storage:openInv(client)
        else
            lia.log.add(client, "storageUnlockFailed", storage:GetClass(), password)
            client:notifyErrorLocalized("wrongPassword")
            client.liaStorageEntity = nil
        end

        client.lastPasswordAttempt = CurTime()
    end
end)

net.Receive("liaStorageTransfer", function(_, client)
    local itemID = net.ReadUInt(32)
    if not client:getChar() then return end
    local storageFunc = function()
        if not IsValid(client.liaStorageEntity) then return end
        if client:GetPos():Distance(client.liaStorageEntity:GetPos()) > 128 then return end
        return client.liaStorageEntity
    end

    local storage = storageFunc()
    if not storage or not storage.receivers[client] then return end
    local clientInv = client:getChar():getInv()
    local storageInv = storage:getInv()
    if not clientInv or not storageInv then return end
    local item = clientInv.items[itemID] or storageInv.items[itemID]
    if not item then return end
    local toInv = clientInv:getID() == item.invID and storageInv or clientInv
    local fromInv = toInv == clientInv and storageInv or clientInv
    if hook.Run("StorageCanTransferItem", client, storage, item) == false then return end
    local context = {
        client = client,
        item = item,
        storage = storage,
        from = fromInv,
        to = toInv
    }

    if clientInv:canAccess("transfer", context) == false or storageInv:canAccess("transfer", context) == false then return end
    if client.storageTransaction and client.storageTransactionTimeout > RealTime() then return end
    client.storageTransaction = true
    client.storageTransactionTimeout = RealTime() + 0.1
    local failItemDropPos = client:getItemDropPos()
    fromInv:removeItem(itemID, true):next(function() return toInv:add(item) end):next(function(res)
        client.storageTransaction = nil
        hook.Run("ItemTransfered", context)
        return res
    end):catch(function(err)
        client.storageTransaction = nil
        if IsValid(client) then lia.log.add(client, "itemTransferFailed", item:getName(), fromInv:getID(), toInv:getID()) end
        if IsValid(client) then client:notifyErrorLocalized(err) end
        return fromInv:add(item)
    end):catch(function()
        client.storageTransaction = nil
        if IsValid(client) then lia.log.add(client, "itemTransferFailed", item:getName(), fromInv:getID(), toInv:getID()) end
        item:spawn(failItemDropPos)
        if IsValid(client) then client:notifyInfoLocalized("itemOnGround") end
    end)
end)

net.Receive("liaStorageSetPassword", function(_, client)
    local action = net.ReadString()
    local storageFunc = function()
        if not IsValid(client.liaStorageEntity) then return end
        if client:GetPos():Distance(client.liaStorageEntity:GetPos()) > 128 then return end
        return client.liaStorageEntity
    end

    local storage = storageFunc()
    if not storage or not storage.receivers[client] then return end
    if action == "remove" then
        if not storage.password then
            client:notifyErrorLocalized("storageNotLocked")
            return
        end

        storage.password = nil
        storage:setNetVar("locked", false)
        client:notifySuccessLocalized("storageUnlocked")
        lia.log.add(client, "storagePasswordRemoved", storage:GetClass())
    elseif action == "set" then
        local newPassword = net.ReadString()
        if not newPassword or newPassword == "" then
            client:notifyErrorLocalized("invalidPassword")
            return
        end

        storage.password = newPassword
        storage:setNetVar("locked", true)
        client:notifySuccessLocalized("storageLocked")
        lia.log.add(client, "storagePasswordSet", storage:GetClass())
    elseif action == "change" then
        if not storage.password then
            client:notifyErrorLocalized("storageNotLocked")
            return
        end

        local oldPassword = net.ReadString()
        local newPassword = net.ReadString()
        if storage.password ~= oldPassword then
            client:notifyErrorLocalized("wrongPassword")
            return
        end

        if not newPassword or newPassword == "" then
            client:notifyErrorLocalized("invalidPassword")
            return
        end

        storage.password = newPassword
        storage:setNetVar("locked", true)
        client:notifySuccessLocalized("storagePasswordChanged")
        lia.log.add(client, "storagePasswordChanged", storage:GetClass())
    end

    hook.Run("UpdateEntityPersistence", storage)
end)
