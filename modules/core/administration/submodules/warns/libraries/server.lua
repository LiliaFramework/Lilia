net.Receive("RequestRemoveWarning", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Can Remove Warns") then return end
    local charID = net.ReadInt(32)
    local rowData = net.ReadTable()
    local warnIndex = tonumber(rowData.ID or rowData.index)
    if not warnIndex then
        client:notifyLocalized("invalidWarningIndex")
        return
    end

    local targetClient = lia.char.getBySteamID(charID)
    if not IsValid(targetClient) then
        client:notifyLocalized("playerNotFound")
        return
    end

    local targetChar = targetClient:getChar()
    if not targetChar then
        client:notifyLocalized("characterNotFound")
        return
    end

    local warns = targetClient:getLiliaData("warns") or {}
    if warnIndex < 1 or warnIndex > #warns then
        client:notifyLocalized("invalidWarningIndex")
        return
    end

    local warning = warns[warnIndex]
    table.remove(warns, warnIndex)
    targetClient:setLiliaData("warns", warns)
    targetClient:notifyLocalized("warningRemovedNotify", client:Nick())
    client:notifyLocalized("warningRemoved", warnIndex, targetClient:Nick())
    lia.log.add(client, "warningRemoved", targetClient, warning)
end)
