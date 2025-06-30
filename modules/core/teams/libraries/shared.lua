function MODULE:CheckFactionLimitReached(faction, character, client)
    if faction.OnCheckLimitReached then return faction:OnCheckLimitReached(character, client) end
    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(player.GetCount() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

function MODULE:GetDefaultCharName(client, faction, data)
    local info = lia.faction.indices[faction]
    local nameFunc = info and (info.NameTemplate or info.nameTemplate)
    if isfunction(nameFunc) then
        local name, override = nameFunc(info, client)
        if override then return name, true end
    end

    local prefix = info and (isfunction(info.prefix) and info.prefix(client) or info.prefix) or ""
    if not prefix or prefix == "" then return data, false end
    local nameWithPrefix = string.Trim(prefix .. " " .. data)
    if info and info.GetDefaultName then info:GetDefaultName(client) end
    return nameWithPrefix, false
end

function MODULE:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.GetDefaultDesc then info:GetDefaultDesc(client) end
end
