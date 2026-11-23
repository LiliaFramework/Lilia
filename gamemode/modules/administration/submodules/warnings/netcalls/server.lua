local MODULE = MODULE
net.Receive("liaRequestRemoveWarning", function(_, client)
    lia.debug("[Permissions]", "Permission Check for net.Receive liaRequestRemoveWarning", "hasPrivilege(canRemoveWarns)=", tostring(client:hasPrivilege("canRemoveWarns")), "finalResult=", tostring(client:hasPrivilege("canRemoveWarns")))
    if not client:hasPrivilege("canRemoveWarns") then return end
    local charID = net.ReadInt(32)
    local rowData = net.ReadTable()
    local warnIndex = tonumber(rowData.ID or rowData.index)
    if not warnIndex then
        client:notifyError(string.format("Invalid warning index."))
        return
    end

    lia.char.getCharacter(charID, client, function(targetChar)
        if not targetChar then
            client:notifyError(string.format("Character not found."))
            return
        end

        local targetClient = targetChar:getPlayer()
        if not IsValid(targetClient) then
            client:notifyError(string.format("Player not found."))
            return
        end

        MODULE:RemoveWarning(charID, warnIndex):next(function(warn)
            if not warn then
                client:notifyError(string.format("Invalid warning index."))
                return
            end

            targetClient:notifyInfo(string.format("A warning has been removed from your record by %s", client:Nick()))
            client:notifySuccess(string.format("Removed warning #%s from %s", warnIndex, targetClient:Nick()))
            hook.Run("WarningRemoved", client, targetClient, {
                reason = warn.message,
                admin = warn.warner,
                adminSteamID = warn.warnerSteamID,
                targetSteamID = targetClient:SteamID()
            }, warnIndex)
        end)
    end)
end)


