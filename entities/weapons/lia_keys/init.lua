--------------------------------------------------------------------------------------------------------
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
--------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack()
	local time = lia.config.DoorLockTime
	local time2 = math.max(time, 1)
	self:SetNextPrimaryFire(CurTime() + time2)
	self:SetNextSecondaryFire(CurTime() + time2)
	if not IsFirstTimePredicted() then return end
	if CLIENT then return end
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
				self:toggleLock(entity, true)
			end
		)

		return
	end
end

--------------------------------------------------------------------------------------------------------
function SWEP:toggleLock(door, state)
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
	elseif door.IsSimfphyscar then
		if state then
			door:Fire("lock")
			door:Lock()
			self:GetOwner():EmitSound("doors/door_latch3.wav")
		else
			door:Fire("unlock")
			door:UnLock()
			door:SetPassenger(self:GetOwner())
			self:GetOwner():EmitSound("doors/door_latch1.wav")
		end
	elseif door:IsVehicle() then
		if state then
			door:Fire("lock")
			if door.IsSimfphyscar then
				door:Lock()
			end

			self:GetOwner():EmitSound("doors/door_latch3.wav")
		else
			door:Fire("unlock")
			if door.IsSimfphyscar then
				door:UnLock()
				door:SetPassenger(self:GetOwner())
			end

			self:GetOwner():EmitSound("doors/door_latch1.wav")
		end
	end
end

--------------------------------------------------------------------------------------------------------
function SWEP:SecondaryAttack()
	local time = lia.config.DoorLockTime
	local time2 = math.max(time, 1)
	self:SetNextPrimaryFire(CurTime() + time2)
	self:SetNextSecondaryFire(CurTime() + time2)
	if not IsFirstTimePredicted() then return end
	if CLIENT then return end
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
				self:toggleLock(entity, false)
			end
		)

		return
	end
end
--------------------------------------------------------------------------------------------------------