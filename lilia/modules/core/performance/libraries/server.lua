function MODULE:PropBreak(_, entity)
    if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end
end

function MODULE:EntityEmitSound(tab)
    local sounds = {
        ["weapons/airboat/airboat_gun_lastshot1.wav"] = true,
        ["weapons/airboat/airboat_gun_lastshot2.wav"] = true
    }

    if IsValid(tab.Entity) and tab.Entity:IsPlayer() then
        local wep = tab.Entity:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "gmod_tool" and sounds[tab.SoundName] then return false end
    end
end