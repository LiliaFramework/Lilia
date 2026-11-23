local GM = GM or GAMEMODE
local LimbHitgroups = {HITGROUP_GEAR, HITGROUP_RIGHTARM, HITGROUP_LEFTARM}
local sounds = {
    male = {
        death = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav"),},
        hurt = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav"),},
    },
    female = {
        death = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav"),},
        hurt = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav"),},
    }
}

local function getGender(isFemale)
    return isFemale and "female" or "male"
end

function GM:GetPlayerDeathSound(client, isFemale)
    if hook.Run("ShouldPlayDeathSound", client) == false then return end
    local sndTab = sounds[getGender(isFemale)].death
    return sndTab[math.random(#sndTab)]
end

function GM:GetPlayerPainSound(client, paintype, isFemale)
    if hook.Run("ShouldPlayPainSound", client, paintype) == false then return end
    if paintype == "hurt" then
        local sndTab = sounds[getGender(isFemale)].hurt
        return sndTab[math.random(#sndTab)]
    end
end

function GM:GetFallDamage(client, speed)
    if not lia.config.get("FallDamageEnabled", true) then return 0 end
    return math.max(0, (speed - 580) * 100 / 444)
end

function GM:ScalePlayerDamage(client, hitgroup, dmgInfo)
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