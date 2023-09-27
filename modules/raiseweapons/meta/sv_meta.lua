--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:setWepRaised(state)
	self:setNetVar("raised", state)
	local weapon = self:GetActiveWeapon()
	if IsValid(weapon) then
		weapon:SetNextPrimaryFire(CurTime() + 1)
		weapon:SetNextSecondaryFire(CurTime() + 1)
	end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:toggleWepRaised()
	timer.Simple(
		1,
		function()
			self:setWepRaised(not self:isWepRaised())
		end
	)

	local weapon = self:GetActiveWeapon()
	if IsValid(weapon) then
		if self:isWepRaised() and weapon.OnRaised then
			weapon:OnRaised()
		elseif not self:isWepRaised() and weapon.OnLowered then
			weapon:OnLowered()
		end
	end
end
--------------------------------------------------------------------------------------------------------