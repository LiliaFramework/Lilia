local MODULE = MODULE
function MODULE:GetWarnings(charID)
    local condition = "charID = " .. lia.db.convertDataType(charID)
    return lia.db.select({"id", "timestamp", "message", "warner", "warnerSteamID"}, "warnings", condition):next(function(res) return res.results or {} end)
end

function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
    lia.db.insertTable({
        charID = charID,
        warned = warned,
        warnedSteamID = warnedSteamID,
        timestamp = timestamp,
        message = message,
        warner = warner,
        warnerSteamID = warnerSteamID
    }, nil, "warnings")
end

function MODULE:RemoveWarning(charID, index)
    local d = deferred.new()
    self:GetWarnings(charID):next(function(rows)
        if index < 1 or index > #rows then return d:resolve(nil) end
        local row = rows[index]
        lia.db.delete("warnings", "id = " .. lia.db.convertDataType(row.id)):next(function() d:resolve(row) end)
    end)
    return d
end

net.Receive("RequestRemoveWarning", function(_, client)
    if not client:hasPrivilege(L("canRemoveWarns")) then return end
    local charID = net.ReadInt(32)
    local rowData = net.ReadTable()
    local warnIndex = tonumber(rowData.ID or rowData.index)
    if not warnIndex then
        client:notifyLocalized("invalidWarningIndex")
        return
    end

    local targetChar = lia.char.loaded[charID]
    if not targetChar then
        client:notifyLocalized("characterNotFound")
        return
    end

    local targetClient = targetChar:getPlayer()
    if not IsValid(targetClient) then
        client:notifyLocalized("playerNotFound")
        return
    end

    MODULE:RemoveWarning(charID, warnIndex):next(function(warn)
        if not warn then
            client:notifyLocalized("invalidWarningIndex")
            return
        end

        targetClient:notifyLocalized("warningRemovedNotify", client:Nick())
        client:notifyLocalized("warningRemoved", warnIndex, targetClient:Nick())
        hook.Run("WarningRemoved", client, targetClient, {
            reason = warn.message,
            admin = warn.warner
        }, warnIndex)
    end)
end)

net.Receive("liaRequestAllWarnings", function(_, client)
    if not client:hasPrivilege(L("viewPlayerWarnings")) then return end
    lia.db.select({"timestamp", "warned", "warnedSteamID", "warner", "warnerSteamID", "message"}, "warnings"):next(function(res)
        net.Start("liaAllWarnings")
        net.WriteTable(res.results or {})
        net.Send(client)
    end)
end)

net.Receive("liaRequestWarningsCount", function(_, client)
    if not client:hasPrivilege(L("viewPlayerWarnings")) then return end
    lia.db.count("warnings"):next(function(count)
        net.Start("liaWarningsCount")
        net.WriteInt(count or 0, 32)
        net.Send(client)
    end)
end)
