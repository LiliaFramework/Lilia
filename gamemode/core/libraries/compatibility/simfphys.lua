if SERVER then
    hook.Add("EntityTakeDamage", "liaSimfphys", function(seat, dmgInfo)
        if not lia.config.get("DamageInCars", true) then return end
        if not seat:IsVehicle() or seat:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end
        local client = seat:GetDriver()
        if IsValid(client) and isfunction(client.isStaffOnDuty) and client:isStaffOnDuty() then
            dmgInfo:SetDamage(0)
            return
        end

        if not IsValid(client) then return end
        local hitPos = dmgInfo:GetDamagePosition()
        if hitPos:Distance(client:GetPos()) > 53 then return end
        local newHealth = client:Health() - dmgInfo:GetDamage() * 0.3
        if newHealth > 0 then
            client:SetHealth(newHealth)
        else
            client:Kill()
        end
    end)

    hook.Add("simfphysUse", "liaSimfphys", function(entity, client)
        if not lia.config.get("CarEntryDelayEnabled", true) then return end
        if not entity:isSimfphysCar() then return end
        if entity.IsBeingEntered then
            client:notifyWarningLocalized("carOccupiedNotice")
            return true
        end

        local delay = lia.config.get("TimeToEnterVehicle", 5)
        if delay <= 0 then
            entity:SetPassenger(client)
            return true
        end

        entity.IsBeingEntered = true
        client:setAction(L("enteringVehicle"), delay, function()
            if IsValid(entity) then entity.IsBeingEntered = false end
            if not IsValid(entity) or not IsValid(client) then return end
            if client:GetPos():Distance(entity:GetPos()) <= 150 then
                entity:SetPassenger(client)
            else
                client:notifyWarningLocalized("tooFarAway")
            end
        end)
        return true
    end)
else
    hook.Add("InitializedModules", "liaSimfphys", function() if lia.config.get("DisableSimfphysHUD", false) then hook.Remove("HUDPaint", "simfphys_HUD") end end)
end

hook.Add("CheckValidSit", "liaSimfphys", function(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end)

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
hook.Add("IsSuitableForTrunk", "SIMFPHYS_IsSuitableForTrunk", function(vehicle) if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end end)
hook.Add("CanProperty", "SIMFPHYS_CanProperty", function(client, property, ent) if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege("canEditSimfphysCars") end end)
lia.config.add("DamageInCars", "@takeDamageInCars", true, nil, {
    desc = "@takeDamageInCarsDesc",
    category = "@Core",
    type = "Boolean"
})

lia.config.add("CarEntryDelayEnabled", "@carEntryDelayEnabled", true, nil, {
    desc = "@carEntryDelayEnabledDesc",
    category = "@Core",
    type = "Boolean"
})

lia.config.add("TimeToEnterVehicle", "@timeToEnterVehicle", 4, nil, {
    desc = "@timeToEnterVehicleDesc",
    category = "@Core",
    type = "Int",
    min = 1,
    max = 30
})

lia.config.add("DisableSimfphysHUD", "@disableSimfphysHUD", false, function()
    if SERVER then
        for _, client in player.Iterator() do
            if IsValid(client) then client:notifyInfoLocalized("simfphysHudRestartNotice") end
        end
    end
end, {
    desc = "@disableSimfphysHUDDesc",
    category = "@Core",
    type = "Boolean"
})
