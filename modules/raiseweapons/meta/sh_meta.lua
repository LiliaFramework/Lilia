--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
lia.config.PermaRaisedWeapons = lia.config.PermaRaisedWeapons or {
	["weapon_physgun"] = true,
	["gmod_tool"] = true,
	["lia_poshelper"] = true,
}
--------------------------------------------------------------------------------------------------------
function playerMeta:isWepRaised()
	local weapon = self:GetActiveWeapon()
	local override = hook.Run("ShouldWeaponBeRaised", self, weapon)
	if override ~= nil then return override end
	if IsValid(weapon) then
		local weaponClass = weapon:GetClass()
		if lia.config.PermaRaisedWeapons[weaponClass] or weapon.IsAlwaysRaised or weapon.AlwaysRaised then
			return true
		elseif weapon.IsAlwaysLowered or weapon.NeverRaised then
			return false
		end
	end

	if lia.config.WepAlwaysRaised then return true end

	return self:getNetVar("raised", false)
end
--------------------------------------------------------------------------------------------------------