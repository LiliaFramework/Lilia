--------------------------------------------------------------------------------------------------------------------------
function MODULE:ScalePlayerDamage(client, hitgroup, dmgInfo)
    local damageScale = lia.config.DamageScale
    if hitgroup == HITGROUP_HEAD then
        damageScale = lia.config.HeadShotDamage
    elseif table.HasValue(lia.config.LimbHitgroups, hitgroup) then
        damageScale = lia.config.LimbDamage
    end

    dmgInfo:ScaleDamage(damageScale)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetFallDamage(client, speed)
    return math.max(0, (speed - 580) * (100 / 444))
end
--------------------------------------------------------------------------------------------------------------------------
