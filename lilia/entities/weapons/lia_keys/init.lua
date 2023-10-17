--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function SWEP:ServerSecondaryAttack(owner, entity, time)
    if IsValid(entity) and ((entity:isDoor() and entity:checkDoorAccess(owner)) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == owner) or entity:GetCreator() == owner or simfphys.IsCar(entity)) then
        owner:setAction(
            "@unlocking",
            time,
            function()
                self:ToggleLock(owner, entity, false)
            end
        )

        return
    end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:ServerPrimaryAttack(owner, entity, time)
    if ((entity:isDoor() and entity:checkDoorAccess(owner)) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == owner)) or (entity:GetCreator() == owner and simfphys and simfphys.IsCar(entity)) then
        owner:setAction(
            "@locking",
            time,
            function()
                self:ToggleLock(owner, entity, true)
            end
        )

        return
    end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:ToggleLock(owner, door, state)
    if IsValid(owner) and owner:GetPos():Distance(door:GetPos()) > 96 then return end
    if door:isDoor() then
        local partner = door:getDoorPartner()
        if state then
            if IsValid(partner) then
                partner:Fire("lock")
            end

            door:Fire("lock")
            owner:EmitSound("doors/door_latch3.wav")
        else
            if IsValid(partner) then
                partner:Fire("unlock")
            end

            door:Fire("unlock")
            owner:EmitSound("doors/door_latch1.wav")
        end
    elseif door:IsVehicle() then
        if state then
            door:Fire("lock")
            if simfphys.IsCar(door) then
                door.IsLocked = true
            end

            owner:EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            if simfphys.IsCar(door) then
                door.IsLocked = false
            end

            owner:EmitSound("doors/door_latch1.wav")
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------