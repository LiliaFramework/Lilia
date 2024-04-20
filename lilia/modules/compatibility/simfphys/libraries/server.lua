function MODULE:simfphysUse(entity, client)
    if entity.IsBeingEntered then client:notify("Someone is entering this car!") end
    if entity.IsLocked then client:notify("This car is locked!") end
    if lia.config.CarEntryDelayEnabled and entity:IsSimfphysCar() and lia.config.TimeToEnterVehicle > 0 then
        entity.IsBeingEntered = true
        client:setAction("Entering Vehicle...", lia.config.TimeToEnterVehicle)
        client:doStaredAction(entity, function()
            entity.IsBeingEntered = false
            entity:SetPassenger(client)
        end, lia.config.TimeToEnterVehicle, function()
            if IsValid(entity) then
                entity.IsBeingEntered = false
                client:setAction()
            end

            if IsValid(client) then client:setAction() end
        end)
    end
    return true
end

function MODULE:EntityTakeDamage(entity, dmgInfo)
    local damageType = dmgInfo:GetDamageType()
    if self.DamageInCars and entity:IsVehicle() and table.HasValue(self.ValidCarDamages, damageType) then
        local client = entity:GetDriver()
        if IsValid(client) then
            local hitPos = dmgInfo:GetDamagePosition()
            local clientPos = client:GetPos()
            local thresholdDistance = 53
            if hitPos:Distance(clientPos) <= thresholdDistance then
                local newHealth = client:Health() - (dmgInfo:GetDamage() * 0.3)
                if newHealth > 0 then
                    client:SetHealth(newHealth)
                else
                    client:Kill()
                end
            end
        end
    end
end

function MODULE:isSuitableForTrunk(entity)
    if IsValid(entity) and entity:IsSimfphysCar() then return true end
end

function MODULE:CheckValidSit(client, _)
    local entity = client:GetTracedEntity()
    if entity:IsSimfphysCar() then return false end
end

function MODULE:KeyLock(client, entity, time)
    if IsValid(entity) and client:GetPos():Distance(entity:GetPos()) <= 256 and (entity:IsSimfphysCar() and entity:GetCreator() == client) then
        client:setAction("@locking", time, function() end)
        client:doStaredAction(entity, function() self:ToggleLock(client, entity, true) end, time, function() client:setAction() end)
    end
end

function MODULE:KeyUnlock(client, entity, time)
    if IsValid(entity) and client:GetPos():Distance(entity:GetPos()) <= 256 and (entity:IsSimfphysCar() and entity:GetCreator() == client or client:IsSuperAdmin() or client:isStaffOnDuty()) then
        client:setAction("@unlocking", time, function() end)
        client:doStaredAction(entity, function() self:ToggleLock(client, entity, false) end, time, function() client:setAction() end)
    end
end

function MODULE:ToggleLock(client, entity, state)
    entity.IsLocked = not state
    entity:Fire(state and "lock" or "unlock")
    client:EmitSound(state and "doors/door_latch3.wav" or "doors/door_latch1.wav")
end

function MODULE:InitializedModules()
    for k, v in pairs(self.SimfphysConsoleCommands) do
        RunConsoleCommand(k, v)
    end
end
