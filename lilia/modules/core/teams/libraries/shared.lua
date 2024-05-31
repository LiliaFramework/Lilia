﻿function MODULE:CheckFactionLimitReached(faction, character, client)
    if faction.OnCheckLimitReached then return faction:OnCheckLimitReached(character, client) end
    if faction.onCheckLimitReached then
        print("onCheckLimitReached is deprecated. Use OnCheckLimitReached for optimization purposes.")
        return faction:onCheckLimitReached(character, client)
    end

    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(player.GetCount() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

function MODULE:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info then
        if info.getDefaultName then
            print("getDefaultName is deprecated. Use GetDefaultName for optimization purposes.")
            return info:getDefaultName(client)
        end

        if info.GetDefaultName then return info:GetDefaultName(client) end
    end
end

function MODULE:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info then
        if info.getDefaultDesc then
            print("getDefaultDesc is deprecated. Use GetDefaultDesc for optimization purposes.")
            return info:getDefaultDesc(client)
        end

        if info.GetDefaultDesc then return info:GetDefaultDesc(client) end
    end
end