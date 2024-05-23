function MODULE:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.OnCheckLimitReached) or isfunction(faction.onCheckLimitReached) then
        if faction.onCheckLimitReached then print("onCheckLimitReached is deprecated. Use onCheckLimitReached for optimization purposes.") end
        return faction:OnCheckLimitReached(character, client)
    end

    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(player.GetCount()* faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

function MODULE:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info and (info.GetDefaultName or info.getDefaultName) then
        if info.getDefaultName then
            print("getDefaultName is deprecated. Use getDefaultName for optimization purposes.")
            return info:getDefaultName(client)
        end
        return info:GetDefaultName(client)
    end
end

function MODULE:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and (info.GetDefaultDesc or info.getDefaultDesc) then
        if info.getDefaultDesc then
            print("getDefaultDesc is deprecated. Use getDefaultDesc for optimization purposes.")
            return info:getDefaultDesc(client)
        end
        return info:GetDefaultDesc(client)
    end
end