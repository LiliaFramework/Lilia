--------------------------------------------------------------------------------------------------------
function MODULE:PlayerDeath(client)
    if not lia.config.DeathSoundEnabled then return end
    local deathSound = hook.Run("GetPlayerDeathSound", client, "death", client:isFemale())
    client:EmitSound(deathSound)
end
--------------------------------------------------------------------------------------------------------
function MODULE:GetPlayerPainSound(client, paintype, isFemale)
    local soundTable
    if paintype == "drown" then
        soundTable = isFemale and lia.config.FemaleDrownSounds or lia.config.MaleDrownSounds
    elseif paintype == "hurt" then
        soundTable = isFemale and lia.config.FemaleHurtSounds or lia.config.MaleHurtSounds
    elseif paintype == "death" then
        soundTable = isFemale and lia.config.FemaleDeathSounds or lia.config.MaleDeathSounds
    end
    return soundTable and soundTable[math.random(#soundTable)]
end
--------------------------------------------------------------------------------------------------------
function MODULE:EntityTakeDamage(client, dmg)
    if not lia.config.PainSoundEnabled or not client:IsPlayer() or client:Health() <= 0 then return end
    local painSound = self:GetPlayerPainSound(client, "hurt", client:isFemale())
    if client:WaterLevel() >= 3 then painSound = self:GetPlayerPainSound(client, "drown", client:isFemale()) end
    if painSound then
        client:EmitSound(painSound)
        client.NextPain = CurTime() + 0.33
    end
end
--------------------------------------------------------------------------------------------------------