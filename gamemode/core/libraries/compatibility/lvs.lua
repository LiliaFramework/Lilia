--[[
    Folder: Compatibility
    File:  lvs.md
]]
--[[
    LVS Compatibility

    Provides compatibility with LVS (Lua Vehicle Script) addon for vehicle damage and interaction handling within the Lilia framework.
]]
--[[
    Improvements Done:
        The LVS compatibility module ensures proper damage handling for vehicles created with the Lua Vehicle Script addon. It manages vehicle-related damage mechanics to prevent conflicts with Lilia's damage systems.
        The module operates on the server side to handle vehicle damage events, ensuring that vehicle collisions and attacks are processed correctly within the framework's combat mechanics.
        It includes special handling for vehicle-mounted weapons and passenger damage to maintain balance and prevent exploits.
        The module integrates with Lilia's damage system to provide consistent vehicle interaction across different gameplay scenarios.
]]
hook.Add("EntityTakeDamage", "liaLVS", function(_, dmg)
    local attacker = dmg:GetAttacker()
    local inflictor = dmg:GetInflictor()
    local attackerVehicle
    if IsValid(attacker) and attacker.lvsGetVehicle then attackerVehicle = attacker:lvsGetVehicle() end
    if IsValid(attackerVehicle) and inflictor == attackerVehicle then return true end
end)
