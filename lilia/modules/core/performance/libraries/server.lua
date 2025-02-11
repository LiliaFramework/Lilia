function MODULE:PropBreak(_, entity)
    if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end
end

function MODULE:EntityEmitSound(tab)
    local sounds = {
        ["weapons/airboat/airboat_gun_lastshot1.wav"] = true,
        ["weapons/airboat/airboat_gun_lastshot2.wav"] = true
    }

    if sounds[tab.SoundName] then return false end
end