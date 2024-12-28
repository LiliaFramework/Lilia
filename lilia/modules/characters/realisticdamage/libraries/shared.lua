local MaleDeathSounds = {Sound("vo/npc/male01/pain07.wav"), Sound("vo/npc/male01/pain08.wav"), Sound("vo/npc/male01/pain09.wav")}
local MaleHurtSounds = {Sound("vo/npc/male01/pain01.wav"), Sound("vo/npc/male01/pain02.wav"), Sound("vo/npc/male01/pain03.wav"), Sound("vo/npc/male01/pain04.wav"), Sound("vo/npc/male01/pain05.wav"), Sound("vo/npc/male01/pain06.wav")}
local FemaleDeathSounds = {Sound("vo/npc/female01/pain07.wav"), Sound("vo/npc/female01/pain08.wav"), Sound("vo/npc/female01/pain09.wav")}
local FemaleHurtSounds = {Sound("vo/npc/female01/pain01.wav"), Sound("vo/npc/female01/pain02.wav"), Sound("vo/npc/female01/pain03.wav"), Sound("vo/npc/female01/pain04.wav"), Sound("vo/npc/female01/pain05.wav"), Sound("vo/npc/female01/pain06.wav")}
local InjuriesTable = {
    [0.2] = {"Critical Condition", "in a critical state", Color(192, 57, 43)},
    [0.4] = {"Serious Injury", "in a serious state", Color(231, 76, 60)},
    [0.6] = {"Moderate Injury", "in a moderate state", Color(255, 152, 0)},
    [0.8] = {"Minor Injury", "in a minor state", Color(255, 193, 7)},
    [1.0] = {"Healthy", "in perfect health", Color(46, 204, 113)}
}

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
    return math.max(0, (speed - 580) * (100 / 444))
end

function MODULE:GetInjuredText(client, meIsUsed)
    local health = client:Health()
    local severities = {}
    for k, _ in pairs(InjuriesTable) do
        table.insert(severities, k)
    end

    table.sort(severities)
    for _, k in ipairs(severities) do
        local v = InjuriesTable[k]
        local severity = k
        local injury, alternative, color = unpack(v)
        if (health / client:GetMaxHealth()) <= severity then return meIsUsed and alternative or injury, color end
    end
end