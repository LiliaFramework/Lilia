--[[
    Basic integration with the LVS vehicle system.
    Prevents self-inflicted damage from a player's own
    vehicle during collisions or weapon fire.
]]

hook.Add("EntityTakeDamage", "liaLVS", function(_, dmg)
    local attacker = dmg:GetAttacker()
    local inflictor = dmg:GetInflictor()
    local attackerVehicle
    if IsValid(attacker) and attacker.lvsGetVehicle then attackerVehicle = attacker:lvsGetVehicle() end
    if IsValid(attackerVehicle) and inflictor == attackerVehicle then return true end
end)
