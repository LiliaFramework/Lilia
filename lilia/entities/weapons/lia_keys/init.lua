--------------------------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------------------------
function SWEP:ServerSecondaryAttack()
    local time = lia.config.DoorLockTime
    local data = {}
    data.start = self:GetOwner():GetShootPos()
    data.endpos = data.start + self:GetOwner():GetAimVector() * 96
    data.filter = self:GetOwner()
    local entity = util.TraceLine(data).Entity
    if hook.Run("KeyUnlockOverride", self:GetOwner(), entity) then return end
    if IsValid(entity) and ((entity:isDoor() and entity:checkDoorAccess(self:GetOwner())) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == self:GetOwner())) then
        self:GetOwner():setAction(
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
    local time = lia.config.DoorLockTime
    local data = {}
    data.start = self:GetOwner():GetShootPos()
    data.endpos = data.start + self:GetOwner():GetAimVector() * 96
    data.filter = self:GetOwner()
    local entity = util.TraceLine(data).Entity
    if hook.Run("KeyLockOverride", self:GetOwner(), entity) then return end
    if IsValid(entity) and ((entity:isDoor() and entity:checkDoorAccess(self:GetOwner())) or (entity:IsVehicle() and entity.CPPIGetOwner and entity:CPPIGetOwner() == self:GetOwner())) then
        self:GetOwner():setAction(
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
    if IsValid(self:GetOwner()) and self:GetOwner():GetPos():Distance(door:GetPos()) > 96 then return end
    if door:isDoor() then
        local partner = door:getDoorPartner()
        if state then
            if IsValid(partner) then
                partner:Fire("lock")
            end

            door:Fire("lock")
            self:GetOwner():EmitSound("doors/door_latch3.wav")
        else
            if IsValid(partner) then
                partner:Fire("unlock")
            end

            door:Fire("unlock")
            self:GetOwner():EmitSound("doors/door_latch1.wav")
        end
    elseif door:IsVehicle() then
        if state then
            door:Fire("lock")
            if door.IsSimfphyscar then
                door.IsLocked = true
            end

            self:GetOwner():EmitSound("doors/door_latch3.wav")
        else
            door:Fire("unlock")
            if door.IsSimfphyscar then
                door.IsLocked = nil
            end

            self:GetOwner():EmitSound("doors/door_latch1.wav")
        end
    end
end
--------------------------------------------------------------------------------------------------------------------------