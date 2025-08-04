if SERVER then
    hook.Add("EntityTakeDamage", "liaSimfphys", function(seat, dmgInfo)
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

    hook.Add("simfphysUse", "liaSimfphys", function(entity, client)
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

hook.Add("CheckValidSit", "liaSimfphys", function(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end)

lia.config.add("DamageInCars", "Take Damage in Cars", true, nil, {
    desc = "Whether or not you take damage while in cars",
    category = "Simfphys Vehicles",
    type = "Boolean"
})

lia.config.add("CarEntryDelayEnabled", "Take Damage in Cars", true, nil, {
    desc = "Whether or not you take damage while in cars",
    category = "Simfphys Vehicles",
    type = "Boolean"
})

lia.config.add("TimeToEnterVehicle", "Time To Enter Vehicle", 4, nil, {
    desc = "Defines the time to enter vehicle.",
    category = "Simfphys Vehicles",
    type = "Int",
    min = 1,
    max = 20
})

lia.administrator.registerPrivilege({
    Name = L("canEditSimfphysCars"),
    MinAccess = "superadmin",
    Category = "Simfphys Vehicles"
})

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
hook.Add("IsSuitableForTrunk", "SIMFPHYS_IsSuitableForTrunk", function(vehicle) if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end end)
hook.Add("CanProperty", "SIMFPHYS_CanProperty", function(client, property, ent) if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege(L("canEditSimfphysCars")) end end)
