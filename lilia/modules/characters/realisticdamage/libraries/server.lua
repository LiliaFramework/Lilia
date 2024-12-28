local LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}
function MODULE:ScalePlayerDamage(_, hitgroup, dmgInfo)
    local damageScale = self.DamageScale
    if hitgroup == HITGROUP_HEAD then
        damageScale = self.HeadShotDamage
    elseif table.HasValue(LimbHitgroups, hitgroup) then
        damageScale = self.LimbDamage
    end

    dmgInfo:ScaleDamage(damageScale)
end

function MODULE:PlayerDeath(client)
    if not self.DeathSoundEnabled then return end
    local deathSound = hook.Run("GetPlayerDeathSound", client, client:isFemale())
    if deathSound then client:EmitSound(deathSound) end
end

function MODULE:EntityTakeDamage(client)
    if not self.PainSoundEnabled or not client:IsPlayer() or client:Health() <= 0 then return end
    local painSound = self:GetPlayerPainSound(client, "hurt", client:isFemale())
    if client:WaterLevel() >= 3 then painSound = self:GetPlayerPainSound(client, "drown", client:isFemale()) end
    if painSound then
        client:EmitSound(painSound)
        client.NextPain = CurTime() + 0.33
    end
end

function MODULE:PlayerDisconnected(client)
    local steamID64 = client:SteamID64()
    if timer.Exists("DrownTimer_" .. steamID64) then timer.Remove("DrownTimer_" .. steamID64) end
end