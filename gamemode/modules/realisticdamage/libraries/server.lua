local LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}
function MODULE:ScalePlayerDamage(_, hitgroup, dmgInfo)
    local damageScale = lia.config.get("DamageScale")
    hook.Run("PreScaleDamage", hitgroup, dmgInfo, damageScale)
    if hitgroup == HITGROUP_HEAD then
        damageScale = lia.config.get("HeadShotDamage")
    elseif table.HasValue(LimbHitgroups, hitgroup) then
        damageScale = lia.config.get("LimbDamage")
    end

    damageScale = hook.Run("GetDamageScale", hitgroup, dmgInfo, damageScale) or damageScale
    dmgInfo:ScaleDamage(damageScale)
    hook.Run("PostScaleDamage", hitgroup, dmgInfo, damageScale)
end

function MODULE:PlayerDeath(client)
    if not lia.config.get("DeathSoundEnabled") then return end
    local deathSound = hook.Run("GetPlayerDeathSound", client, client:isFemale())
    if deathSound and hook.Run("ShouldPlayDeathSound", client, deathSound) ~= false then
        client:EmitSound(deathSound)
        hook.Run("OnDeathSoundPlayed", client, deathSound)
    end
end

function MODULE:EntityTakeDamage(client)
    if not lia.config.get("PainSoundEnabled") or not client:IsPlayer() or client:Health() <= 0 then return end
    local painSound = self:GetPlayerPainSound(client, "hurt", client:isFemale())
    if client:WaterLevel() >= 3 then painSound = self:GetPlayerPainSound(client, "drown", client:isFemale()) end
    if painSound and hook.Run("ShouldPlayPainSound", client, painSound) ~= false then
        client:EmitSound(painSound)
        hook.Run("OnPainSoundPlayed", client, painSound)
        client.NextPain = CurTime() + 0.33
    end
end
