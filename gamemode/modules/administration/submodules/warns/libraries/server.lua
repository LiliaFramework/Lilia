local MODULE = MODULE
function MODULE:GetWarnings(charID)
    local condition = "_charID = " .. lia.db.convertDataType(charID)
    return lia.db.select({"_id", "_timestamp", "_reason", "_admin"}, "warnings", condition):next(function(res) return res.results or {} end)
end

function MODULE:AddWarning(charID, steamID, timestamp, reason, admin)
    lia.db.insertTable({
        _charID = charID,
        _steamID = steamID,
        _timestamp = timestamp,
        _reason = reason,
        _admin = admin
    }, nil, "warnings")
end

function MODULE:RemoveWarning(charID, index)
    local d = deferred.new()
    self:GetWarnings(charID):next(function(rows)
        if index < 1 or index > #rows then return d:resolve(nil) end
        local row = rows[index]
        lia.db.delete("warnings", "_id = " .. lia.db.convertDataType(row._id)):next(function() d:resolve(row) end)
    end)
    return d
end

net.Receive("RequestRemoveWarning", function(_, client)
    if not client:hasPrivilege("Staff Permissions - Can Remove Warns") then return end
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
            reason = warn._reason,
            admin = warn._admin
        }, warnIndex)
    end)
end)
