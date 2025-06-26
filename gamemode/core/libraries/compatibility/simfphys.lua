--[[
    Adds Simfphys vehicle support.
    Applies crash damage to drivers, registers configuration settings
    and defines privileges for editing cars.
]]
if SERVER then
    hook.Add("EntityTakeDamage", "SIMFPHYS_EntityTakeDamage", function(seat, dmgInfo)
        if seat:IsVehicle() and seat:GetClass() == "gmod_sent_vehicle_fphysics_base" then
            local player = seat:GetDriver()
            if IsValid(player) then
                local hitPos = dmgInfo:GetDamagePosition()
                local playerPos = player:GetPos()
                local thresholdDistance = 53
                if hitPos:Distance(playerPos) <= thresholdDistance then
                    local newHealth = player:Health() - dmgInfo:GetDamage() * 0.3
                    if newHealth > 0 then
                        player:SetHealth(newHealth)
                    else
                        player:Kill()
                    end
                end
            end
        end
    end)

    hook.Add("simfphysUse", "SIMFPHYS_simfphysUse", function(entity, client)
        if entity.IsBeingEntered then
            client:notifyLocalized("carOccupiedNotice")
            return true
        end

        local delay = lia.config.get("TimeToEnterVehicle", 5)
        if entity:isSimfphysCar() and delay > 0 then
            entity.IsBeingEntered = true
            client:setAction(L("enteringVehicle"), delay)
            client:doStaredAction(entity, function()
                if IsValid(entity) then
                    entity.IsBeingEntered = false
                    entity:SetPassenger(client)
                end
            end, delay, function()
                if IsValid(entity) then entity.IsBeingEntered = false end
                if IsValid(client) then client:stopAction() end
            end)
        end
        return true
    end)
else
    hook.Remove("HUDPaint", "simfphys_HUD")
end

hook.Add("CheckValidSit", "SIMFPHYS_CheckValidSit", function(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end)

lia.config.add("DamageInCars", "Take Damage in Cars", true, nil, {
    desc = "Whether or not you take damage while in cars",
    category = "Simfphys",
    type = "Boolean"
})

lia.config.add("CarEntryDelayEnabled", "Take Damage in Cars", true, nil, {
    desc = "Whether or not you take damage while in cars",
    category = "Simfphys",
    type = "Boolean"
})

lia.config.add("TimeToEnterVehicle", "Time To Enter Vehicle", 4, nil, {
    desc = "Defines the time to enter vehicle.",
    category = "Simfphys",
    type = "Int",
    min = 1,
    max = 20
})

CAMI.RegisterPrivilege({
    Name = "Staff Permissions - Can Edit Simfphys Cars",
    MinAccess = "superadmin",
    Description = "Allows access to Editting Simfphys Cars"
})

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
hook.Add("IsSuitableForTrunk", "SIMFPHYS_IsSuitableForTrunk", function(vehicle) if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end end)
hook.Add("CanProperty", "SIMFPHYS_CanProperty", function(client, property, ent) if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege("Staff Permissions - Can Edit Simfphys Cars") end end)
