---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then client:Kick("Kicked for " .. infraction .. ".") end
    if ban then client:Ban(bantime, "Banned for " .. infraction .. ".") end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
