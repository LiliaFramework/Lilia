function SimfphysCompatibility:simfphysUse(entity, client)
    if simfphys.IsCar(entity) and self.TimeToEnterVehicle > 0 and not (entity.IsBeingEntered or entity.IsLocked) then
        entity.IsBeingEntered = true
        client:setAction("Entering Vehicle...", self.TimeToEnterVehicle)
        client:doStaredAction(
            entity,
            function()
                entity.IsBeingEntered = false
                entity:SetPassenger(client)
            end,
            self.TimeToEnterVehicle,
            function()
                if IsValid(entity) then
                    entity.IsBeingEntered = false
                    client:setAction()
                end

                if IsValid(client) then client:setAction() end
            end
        )
    end
    return self.CarEntryDelayEnabled
end

function SimfphysCompatibility:isSuitableForTrunk(ent)
    if IsValid(ent) and simfphys.IsCar(ent) then return true end
end

function SimfphysCompatibility:CheckValidSit(client, _)
    local entity = client:GetTracedEntity()
    if simfphys.IsCar(entity) then return false end
end
