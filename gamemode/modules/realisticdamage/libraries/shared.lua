local MaleDeathSounds = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav")}
local MaleHurtSounds = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav")}
local FemaleDeathSounds = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav")}
local FemaleHurtSounds = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav")}
function MODULE:GetPlayerDeathSound(_, isFemale)
    local soundTable
    soundTable = isFemale and FemaleDeathSounds or MaleDeathSounds
    return soundTable and soundTable[math.random(#soundTable)]
end
function MODULE:GetPlayerPainSound(_, paintype, isFemale)
    local soundTable
    if paintype == "hurt" then soundTable = isFemale and FemaleHurtSounds or MaleHurtSounds end
    return soundTable and soundTable[math.random(#soundTable)]
end
function MODULE:GetFallDamage(_, speed)
    return math.max(0, (speed - 580) * 100 / 444)
end