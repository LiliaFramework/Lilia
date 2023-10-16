--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function SWEP:ServerSecondaryAttack()
    local owner = self:GetOwner()
    local time = lia.config.DoorLockTime
    local data = {}
    data.start = owner:GetShootPos()
    data.endpos = data.start + owner:GetAimVector() * 96
    data.filter = owner
    local entity = util.TraceLine(data).Entity
    if hook.Run("KeyUnlockOverride", owner, entity) then return end
    if IsValid(entity) and ((entity:isDoor() and entity:checkDoorAccess(owner)) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == owner) or entity:GetCreator() == owner) then
        owner:setAction(
            "@unlocking",
            time,
            function()
                self:ToggleLock(entity, false)
            end
        )

        return
    end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:ServerPrimaryAttack()
    local owner = self:GetOwner()
    local time = lia.config.DoorLockTime
    local data = {}
    data.start = owner:GetShootPos()
    data.endpos = data.start + owner:GetAimVector() * 96
    data.filter = owner
    local entity = util.TraceLine(data).Entity
    if hook.Run("KeyLockOverride", owner, entity) then return end
    if IsValid(entity) and ((entity:isDoor() and entity:checkDoorAccess(owner)) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == owner) or entity:GetCreator() == owner) then
        owner:setAction(
            "@locking",
            time,
            function()
                self:ToggleLock(entity, true)
            end
        )

        return
    end
end

--------------------------------------------------------------------------------------------------------------------------
function SWEP:ToggleLock(door, state)
    local owner = self:GetOwner()
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
            if door.IsSimfphyscar then
                door.IsLocked = true
            end

            owner:EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            if door.IsSimfphyscar then
                door.IsLocked = nil
            end

            owner:EmitSound("doors/door_latch1.wav")
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------