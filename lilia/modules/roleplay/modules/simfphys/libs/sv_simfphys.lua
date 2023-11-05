--------------------------------------------------------------------------------------------------------------------------
function MODULE:simfphysUse(entity, client)
    if (lia.module.list["tying"] and not IsHandcuffed(client)) and simfphys.IsCar(entity) and lia.config.TimeToEnterVehicle > 0 and not (entity.IsBeingEntered or entity.IsLocked) then
        entity.IsBeingEntered = true
        client:setAction("Entering Vehicle...", lia.config.TimeToEnterVehicle)
        client:doStaredAction(
            entity,
            function()
                entity.IsBeingEntered = false
                entity:SetPassenger(client)
            end,
            lia.config.TimeToEnterVehicle,
            function()
                if IsValid(entity) then
                    entity.IsBeingEntered = false
                    client:setAction()
                end

                if IsValid(client) then client:setAction() end
            end
        )
    end
    return lia.config.CarEntryDelayEnabled
end
--------------------------------------------------------------------------------------------------------------------------