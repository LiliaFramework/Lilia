if SERVER then
    hook.Add("EntityTakeDamage", "liaSimfphys", function(seat, dmgInfo)
        local damageInCars = lia.config.get("DamageInCars", true)
        if not damageInCars then return end
        if seat:IsVehicle() and seat:GetClass() == "gmod_sent_vehicle_fphysics_base" then
            local player = seat:GetDriver()
            if isfunction(player.isStaffOnDuty) and player:isStaffOnDuty() and lia.config.get("StaffHasGodMode", true) then return true end
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
        local enabled = lia.config.get("CarEntryDelayEnabled", true)
        if not enabled then return end
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

lia.config.add("DamageInCars", "takeDamageInCars", true, nil, {
    desc = "takeDamageInCarsDesc",
    category = "simfphysVehicles",
    type = "Boolean"
})

lia.config.add("CarEntryDelayEnabled", "carEntryDelayEnabled", true, nil, {
    desc = "carEntryDelayEnabledDesc",
    category = "simfphysVehicles",
    type = "Boolean"
})

lia.config.add("TimeToEnterVehicle", "timeToEnterVehicle", 4, nil, {
    desc = "timeToEnterVehicleDesc",
    category = "simfphysVehicles",
    type = "Int",
    min = 1,
    max = 30
})

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
hook.Add("CanProperty", "SIMFPHYS_CanProperty", function(client, property, ent) if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege("canEditSimfphysCars") end end)