if SERVER then
    hook.Add("EntityTakeDamage", "SIMFPHYS_EntityTakeDamage", function(seat, dmgInfo)
        if not lia.config.get("DamageInCars", true) then return end
        if not seat:isSimfphysCar() then return end
        if seat.GetDriver == nil then return end
        local client = seat:GetDriver()
        if not IsValid(client) then return end
        if dmgInfo:GetDamagePosition():Distance(client:GetPos()) > 300 then return end
        local damageAmount = dmgInfo:GetDamage() * 0.3
        local newHealth = client:Health() - damageAmount
        if newHealth > 0 then
            client:SetHealth(newHealth)
        else
            client:Kill()
        end
    end)

    hook.Add("simfphysUse", "SIMFPHYS_simfphysUse", function(entity, client)
        if entity.IsBeingEntered then
            client:notify("Someone is entering this car!")
            return true
        end

        local delay = lia.config.get("TimeToEnterVehicle", 5)
        if entity:isSimfphysCar() and delay > 0 then
            entity.IsBeingEntered = true
            client:setAction("Entering Vehicle...", delay)
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

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
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

lia.config.add("TimeToEnterVehicle", "Inventory Height", 4, nil, {
    desc = "Defines the height of the default inventory.",
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

hook.Add("CanProperty", "SIMFPHYS_HOOKID", function(client, property, ent) if property == "editentity" and ent:isSimfphysCar() then return client:hasPrivilege("Staff Permissions - Can Edit Simfphys Cars") end end)
hook.Add("IsSuitableForTrunk", "SIMFPHYS_HOOKID", function(vehicle) if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end end)
hook.Add("CheckValidSit", "SIMFPHYS_HOOKID", function(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end)