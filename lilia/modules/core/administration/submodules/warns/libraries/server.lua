util.AddNetworkString("RequestRemoveWarning")
net.Receive("RequestRemoveWarning", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Can Remove Warnrs") then return end
    local charID = net.ReadInt(32)
    local rowData = net.ReadTable()
    local warnIndex = tonumber(rowData.ID or rowData.index)
    if not warnIndex then
        client:notify("Invalid warning index.")
        return
    end

    local targetClient = lia.char.getByID(charID)
    if not IsValid(targetClient) then
        client:notify("Player not found.")
        return
    end

    local targetChar = targetClient:getChar()
    if not targetChar then
        client:notify("Character not found.")
        return
    end

    local warns = targetClient:getLiliaData("warns") or {}
    if warnIndex < 1 or warnIndex > #warns then
        client:notify("Invalid warning index.")
        return
    end

    local warning = warns[warnIndex]
    table.remove(warns, warnIndex)
    targetClient:setLiliaData("warns", warns)
    targetClient:notify("A warning has been removed from your record by " .. client:Nick())
    client:notify("Removed warning #" .. warnIndex .. " from " .. targetClient:Nick())
    lia.log.add(client, "warningRemoved", targetClient, warning)
end)

lia.log.addType("warningIssued", function(client, target, reason) return string.format("[%s] %s issued a warning to %s for: %s.", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), target:SteamID(), reason) end, "Warnings", Color(255, 165, 0))
lia.log.addType("warningRemoved", function(client, target, warning) return string.format("[%s] %s removed a warning from %s. Reason was: %s.", os.date("%Y-%m-%d %H:%M:%S"), client:SteamID(), target:SteamID(), warning.reason) end, "Warnings", Color(255, 0, 0))
