---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ApplyPunishment(client, infraction, kick, ban, time)
    local bantime = time or 0
    if kick then client:Kick("Kicked for " .. infraction .. ".") end
    if ban then client:Ban(bantime, "Banned for " .. infraction .. ".") end
end

---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function MODULE:ShouldCollide(ent1, ent2)
    if table.HasValue(self.BlockedCollideEntities, ent1:GetClass()) and table.HasValue(self.BlockedCollideEntities, ent2:GetClass()) then return false end
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
