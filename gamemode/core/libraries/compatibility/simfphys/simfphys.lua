if SERVER then
    hook.Add("EntityTakeDamage", "liaSimfphys", function(target, dmgInfo)
        if IsValid(target) and target:isSimfphysCar() then
            local attacker = dmgInfo:GetAttacker()
            if IsValid(attacker) and attacker:IsPlayer() then
                local wep = attacker:GetActiveWeapon()
                if IsValid(wep) and wep:GetClass() == "lia_hands" then
                    dmgInfo:SetDamage(0)
                    dmgInfo:SetDamageType(DMG_DIRECT)
                    return true
                end
            end
        end

        if not lia.config.get("DamageInCars", true) then return end
        if not target:IsVehicle() or target:GetClass() ~= "gmod_sent_vehicle_fphysics_base" then return end
        local client = target:GetDriver()
        local permission = IsValid(client) and isfunction(client.isStaffOnDuty) and client:isStaffOnDuty() or false
        lia.debug("[Permissions]", "Permission Check for hook liaSimfphys staff vehicle damage immunity", "driverValid=", tostring(IsValid(client)), "hasIsStaffOnDutyMethod=", tostring(IsValid(client) and isfunction(client.isStaffOnDuty) or false), "isStaffOnDuty=", tostring(permission), "finalResult=", tostring(permission))
        if permission then
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
        if entity:isLocked() then
            entity:EmitSound("doors/default_locked.wav")
            return true
        end

        if entity.IsBeingEntered then
            client:notifyWarning(string.format("Someone is entering this car!"))
            return true
        end

        local delay = lia.config.get("TimeToEnterVehicle", 5)
        if delay <= 0 then
            entity:SetPassenger(client)
            return true
        end

        entity.IsBeingEntered = true
        local timerID = "liaSimfphysEntryCheck_" .. client:SteamID64()
        timer.Create(timerID, 0.1, 0, function()
            if not IsValid(client) or not IsValid(entity) then
                timer.Remove(timerID)
                if IsValid(entity) then entity.IsBeingEntered = false end
                return
            end

            if entity:isLocked() then
                timer.Remove(timerID)
                entity.IsBeingEntered = false
                client:setAction()
                entity:EmitSound("doors/default_locked.wav")
                return
            end

            if client:GetPos():DistToSqr(entity:GetPos()) > 250 * 250 then
                timer.Remove(timerID)
                entity.IsBeingEntered = false
                client:setAction()
                client:notifyWarning(string.format("You are too far away!"))
            end
        end)

        client:setAction("Entering Vehicle...", delay, function()
            timer.Remove(timerID)
            if IsValid(entity) then entity.IsBeingEntered = false end
            if not IsValid(entity) or not IsValid(client) then return end
            if entity:isLocked() then
                entity:EmitSound("doors/default_locked.wav")
                return
            end

            if client:GetPos():DistToSqr(entity:GetPos()) > 250 * 250 then
                client:notifyWarning(string.format("You are too far away!"))
                return
            end

            entity:SetPassenger(client)
        end)
        return true
    end)

    hook.Add("Initialize", "SIMFPHYS_BlockBrokenEquipmentHook", function()
        if not simfphys then return end
        if simfphys.RegisterEquipment then
            simfphys.RegisterEquipment = function() end
            print("[SIMFPHYS FIX] Blocked broken RegisterEquipment override")
        end

        hook.Remove("simfphys.RegisterEquipment", "SIMFPHYS_ARMED")
    end)

    local _FireHitScan = simfphys.FireHitScan
    local _FirePhysProjectile = simfphys.FirePhysProjectile
    local function SafeCall(funcName, func)
        return function(...)
            local ok, err = pcall(func, ...)
            if not ok then
                print("[SIMFPHYS CRASH PROTECT] Blocked crash in " .. funcName)
                print(err)
                return
            end
            return err
        end
    end

    if _FireHitScan then simfphys.FireHitScan = SafeCall("FireHitScan", _FireHitScan) end
    if _FirePhysProjectile then simfphys.FirePhysProjectile = SafeCall("FirePhysProjectile", _FirePhysProjectile) end
else
    hook.Add("InitializedModules", "liaSimfphys", function() if lia.config.get("DisableSimfphysHUD", false) then hook.Remove("HUDPaint", "simfphys_HUD") end end)
end

hook.Add("StartCommand", "SimfphysHandsRightClickBlock", function(client, cmd)
    if not cmd:KeyDown(IN_ATTACK2) then return end
    local wep = client:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "lia_hands" then return end
    local tr = client:GetEyeTrace()
    if IsValid(tr.Entity) and tr.Entity:isSimfphysCar() and tr.HitPos:DistToSqr(client:GetShootPos()) < 15000 then cmd:RemoveKey(IN_ATTACK2) end
end)

hook.Add("CheckValidSit", "liaSimfphys", function(client)
    local vehicle = client:getTracedEntity()
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return false end
end)

hook.Add("simfphysPhysicsCollide", "SIMFPHYS_simfphysPhysicsCollide", function() return true end)
hook.Add("IsSuitableForTrunk", "SIMFPHYS_IsSuitableForTrunk", function(vehicle) if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end end)
hook.Add("CanProperty", "SIMFPHYS_CanProperty", function(client, property, ent)
    if property == "editentity" and IsValid(ent) and ent:isSimfphysCar() then
        local canEditSimfphysCars = client:hasPrivilege("canEditSimfphysCars")
        lia.debug("[Permissions]", "Permission Check for hook SIMFPHYS_CanProperty", "property=", tostring(property), "entityIsSimfphysCar=", tostring(ent:isSimfphysCar()), "hasPrivilege(canEditSimfphysCars)=", tostring(canEditSimfphysCars), "finalResult=", tostring(canEditSimfphysCars))
        return canEditSimfphysCars
    end
end)

lia.config.add("DamageInCars", "Take Damage in Cars", true, nil, {
    desc = "Whether or not you take damage while in cars",
    category = "Core",
    type = "Boolean"
})

lia.config.add("CarEntryDelayEnabled", "Car Entry Delay Enabled", true, nil, {
    desc = "Whether entering a vehicle requires a delay.",
    category = "Core",
    type = "Boolean"
})

lia.config.add("TimeToEnterVehicle", "Time To Enter Vehicle", 4, nil, {
    desc = "Defines the time to enter vehicle.",
    category = "Core",
    type = "Int",
    min = 1,
    max = 30
})

lia.config.add("DisableSimfphysHUD", "Disable simfphys HUD", false, function()
    if SERVER then
        for _, client in player.Iterator() do
            if IsValid(client) then client:notifyInfo(string.format("The simfphys HUD setting will only apply after a Lua refresh or server restart.,")) end
        end
    end
end, {
    desc = "Removes the simfphys HUD. This only applies after a Lua refresh or server restart.",
    category = "Core",
    type = "Boolean"
})
