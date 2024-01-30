---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
local GM = GM or GAMEMODE
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function TeamsCore:CheckFactionLimitReached(faction, character, client)
    if isfunction(faction.onCheckLimitReached) then return faction:onCheckLimitReached(character, client) end
    if not isnumber(faction.limit) then return false end
    local maxPlayers = faction.limit
    if faction.limit < 1 then maxPlayers = math.Round(#player.GetAll() * faction.limit) end
    return team.NumPlayers(faction.index) >= maxPlayers
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:GetDefaultCharName(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultName then return info:onGetDefaultName(client) end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function GM:GetDefaultCharDesc(client, faction)
    local info = lia.faction.indices[faction]
    if info and info.onGetDefaultDesc then return info:onGetDefaultDesc(client) end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------