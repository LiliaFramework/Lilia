local playerMeta = FindMetaTable("Player")



function playerMeta:isWepRaised()
    local weapon = self:GetActiveWeapon()
    local override = hook.Run("ShouldWeaponBeRaised", self, weapon)
    if override ~= nil then
        return override
    end

    if IsValid(weapon) then
        local weaponClass = weapon:GetClass()
        if lia.config.PermaRaisedWeapons[weaponClass] or weapon.IsAlwaysRaised or weapon.AlwaysRaised then
            return true
        elseif weapon.IsAlwaysLowered or weapon.NeverRaised then
            return false
        end
    end

    if self:getNetVar("restricted") then
        return false
    end

    if lia.config.WepAlwaysRaised then
        return true
    end

    return self:getNetVar("raised", false)
end


if SERVER then
	-- Sets whether or not the weapon is raised.
	function playerMeta:setWepRaised(state)
		-- Sets the networked variable for being raised.
		self:setNetVar("raised", state)
		-- Delays any weapon shooting.
		local weapon = self:GetActiveWeapon()

		if IsValid(weapon) then
			weapon:SetNextPrimaryFire(CurTime() + 1)
			weapon:SetNextSecondaryFire(CurTime() + 1)
		end
	end

	-- Inverts whether or not the weapon is raised.
	function playerMeta:toggleWepRaised()
		timer.Simple(lia.config.WeaponRaiseTimer, function()
			self:setWepRaised(not self:isWepRaised())
		end)

		local weapon = self:GetActiveWeapon()

		if IsValid(weapon) then
			if self:isWepRaised() and weapon.OnRaised then
				weapon:OnRaised()
			elseif not self:isWepRaised() and weapon.OnLowered then
				weapon:OnLowered()
			end
		end
	end
end