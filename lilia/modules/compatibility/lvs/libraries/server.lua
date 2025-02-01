hook.Add("LVS.OnPlayerCannotDrive", "Lilia_LVSOnCantDrive", function(client, vehicle)
    if vehicle:isLocked() then
        client:notify(L("vehicleLocked"))
        return
    end

    if vehicle.IsBeingEntered then
        client:notify(L("someoneEnteringCar"))
        return
    end

    if vehicle:isSimfphysCar() and lia.config.get("TimeToEnterVehicle") > 0 then
        vehicle.IsBeingEntered = true
        client:setAction(L("enteringVehicleAction"), lia.config.get("TimeToEnterVehicle"))
        client:doStaredAction(vehicle, function()
            vehicle.IsBeingEntered = false
            if not IsValid(vehicle:GetDriver()) then
                local DriverSeat = vehicle:GetDriverSeat()
                client:EnterVehicle(DriverSeat)
            else
                vehicle:SetPassenger(client)
            end
        end, lia.config.get("TimeToEnterVehicle"), function()
            if IsValid(vehicle) then
                vehicle.IsBeingEntered = false
                client:stopAction()
            end

            if IsValid(client) then client:stopAction() end
        end)
    end
    return true
end)

function MODULE:EntityTakeDamage(seat, dmgInfo)
    if lia.config.get("DamageInCars", false) and seat:isSimfphysCar() and seat.GetDriver then
        local client = seat:GetDriver()
        if IsValid(client) then
            local hitPos = dmgInfo:GetDamagePosition()
            local clientPos = client:GetPos()
            local thresholdDistance = 53
            if hitPos:Distance(clientPos) <= thresholdDistance then
                local newHealth = client:Health() - dmgInfo:GetDamage() * 0.3
                if newHealth > 0 then
                    client:SetHealth(newHealth)
                else
                    client:Kill()
                end
            end
        end
    end
end

function MODULE:isSuitableForTrunk(vehicle)
    if IsValid(vehicle) and vehicle:isSimfphysCar() then return true end
end

function MODULE:CheckValidSit(client)
    local vehicle = client:getTracedEntity()
    if vehicle:isSimfphysCar() then return false end
end

hook.Add("LVS.CanPlayerDrive", "Lilia_LVSCantDrive", function() return false end)