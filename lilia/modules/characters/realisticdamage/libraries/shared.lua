function RealisticDamageCore:GetPlayerDeathSound(_, isFemale)
    local soundTable
    soundTable = isFemale and self.FemaleDeathSounds or self.MaleDeathSounds
    return soundTable and soundTable[math.random(#soundTable)]
end

function RealisticDamageCore:GetPlayerPainSound(_, paintype, isFemale)
    local soundTable
    if paintype == "drown" then
        soundTable = isFemale and self.FemaleDrownSounds or self.MaleDrownSounds
    elseif paintype == "hurt" then
        soundTable = isFemale and self.FemaleHurtSounds or self.MaleHurtSounds
    end
    return soundTable and soundTable[math.random(#soundTable)]
end

function RealisticDamageCore:GetFallDamage(_, speed)
    return math.max(0, (speed - 580) * (100 / 444))
end

function RealisticDamageCore:GetInjuredText(client)
    local health = client:Health()
    local severities = {}
    for k, _ in pairs(self.InjuriesTable) do
        table.insert(severities, k)
    end

    table.sort(severities)
    for _, k in ipairs(severities) do
        local v = self.InjuriesTable[k]
        local severity = k
        local injury, color = unpack(v)
        if (health / client:GetMaxHealth()) < severity then return injury, color end
    end
end