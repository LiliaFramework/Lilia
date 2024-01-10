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
    for k, v in pairs(self.InjuriesTable) do
        if (health / client:GetMaxHealth()) < k then return v[1], v[2] end
    end
end
