function MODULE:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.OnCheckLimitReached) or isfunction(faction.onCheckLimitReached) then
        if faction.onCheckLimitReached then print("onCheckLimitReached is deprecated. Use onCheckLimitReached for optimization purposes.") end
        return faction:OnCheckLimitReached(character, client)
    end

    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(#player.GetAll() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

function MODULE:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.getDefaultName then return info:getDefaultName(client) end
end

function MODULE:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.getDefaultDesc then return info:getDefaultDesc(client) end
end