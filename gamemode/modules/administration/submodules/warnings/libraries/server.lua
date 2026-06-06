local MODULE = MODULE
function MODULE:GetWarnings(charID)
    local condition = "charID = " .. lia.db.convertDataType(charID)
    return lia.db.select({"id", "timestamp", "message", "warner", "warnerSteamID", "severity"}, "warnings", condition):next(function(res) return res.results or {} end)
end

function MODULE:AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID, severity)
    local finalSeverity = severity or "Medium"
    lia.db.insertTable({
        charID = charID,
        warned = warned,
        warnedSteamID = warnedSteamID,
        timestamp = timestamp,
        message = message,
        warner = warner,
        warnerSteamID = warnerSteamID,
        severity = finalSeverity
    }, nil, "warnings")
    return finalSeverity
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
