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
        client:notifyWarning(string.format("Please wait before setting another password!"))
    else
        if storage.password == password then
            storage:openInv(client)
        else
            client:notifyError(string.format("You've entered the wrong password."))
            client.liaStorageEntity = nil
        end

        client.lastPasswordAttempt = CurTime()
    end
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
            client:notifyError(string.format("This storage is not locked."))
            return
        end

        storage.password = nil
        storage:setNetVar("locked", false)
        client:notifySuccess(string.format("Storage password has been removed."))
    elseif action == "set" then
        local newPassword = net.ReadString()
        if not newPassword or newPassword == "" then
            client:notifyError(string.format("Password cannot be empty."))
            return
        end

        storage.password = newPassword
        storage:setNetVar("locked", true)
        client:notifySuccess(string.format("Storage has been locked."))
    elseif action == "change" then
        if not storage.password then
            client:notifyError(string.format("This storage is not locked."))
            return
        end

        local oldPassword = net.ReadString()
        local newPassword = net.ReadString()
        if storage.password ~= oldPassword then
            client:notifyError(string.format("You've entered the wrong password."))
            return
        end

        if not newPassword or newPassword == "" then
            client:notifyError(string.format("Password cannot be empty."))
            return
        end

        storage.password = newPassword
        storage:setNetVar("locked", true)
        client:notifySuccess(string.format("Storage password has been changed."))
    end

    hook.Run("UpdateEntityPersistence", storage)
end)
