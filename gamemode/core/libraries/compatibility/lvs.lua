hook.Add("EntityTakeDamage", "liaLVS", function(_, dmg)
    local attacker = dmg:GetAttacker()
    local inflictor = dmg:GetInflictor()
    local attackerVehicle
    if IsValid(attacker) and attacker.lvsGetVehicle then attackerVehicle = attacker:lvsGetVehicle() end
    if IsValid(attackerVehicle) and inflictor == attackerVehicle then return true end
end)