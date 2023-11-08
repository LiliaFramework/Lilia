--------------------------------------------------------------------------------------------------------------------------
function MODULE:ScalePlayerDamage(client, hitgroup, dmgInfo)
    local damageScale = lia.config.DamageScale
    if hitgroup == HITGROUP_HEAD then
        damageScale = lia.config.HeadShotDamage
    elseif table.HasValue(lia.config.LimbHitgroups, hitgroup) then
        if lia.config.BreakableLegsEnabled then self:CheckForBrokenLeg(client, hitgroup, dmgInfo) end
        damageScale = lia.config.LimbDamage
    end

    dmgInfo:ScaleDamage(damageScale)
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:CheckForBrokenLeg(client, hitgroup, dmgInfo)
    if not table.HasValue(lia.config.LegHitgroups, hitgroup) then return end
    local chance = math.random(1, 100)
    if chance <= lia.config.ChanceToBreakLegByShooting then
        client:getChar():setData("leg_broken", true)
        local slowMultiplier = lia.config.BrokenLegSlowMultiplier
        client:SetWalkSpeed(lia.config.WalkSpeed * slowMultiplier)
        client:SetRunSpeed(lia.config.RunSpeed * slowMultiplier)
        if dmgInfo:GetDamageType() == DMG_FALL and dmgInfo:GetDamage() >= lia.config.DamageThresholdOnFallBreak then
            client:getChar():setData("leg_broken", true)
            client:SetWalkSpeed(lia.config.WalkSpeed * slowMultiplier)
            client:SetRunSpeed(lia.config.RunSpeed * slowMultiplier)
        end
    end
end

--------------------------------------------------------------------------------------------------------------------------
function MODULE:GetFallDamage(client, speed)
    return math.max(0, (speed - 580) * (100 / 444))
end
--------------------------------------------------------------------------------------------------------------------------
