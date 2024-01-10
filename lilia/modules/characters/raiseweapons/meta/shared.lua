
local playerMeta = FindMetaTable("Player")

function playerMeta:isWepRaised()
    local weapon = self:GetActiveWeapon()
    local override = hook.Run("ShouldWeaponBeRaised", self, weapon)
    if override ~= nil then return override end
    if IsValid(weapon) then
        local weaponClass = weapon:GetClass()
        if RaisedWeaponCore.PermaRaisedWeapons[weaponClass] or weapon.IsAlwaysRaised or weapon.AlwaysRaised then
            return true
        elseif weapon.IsAlwaysLowered or weapon.NeverRaised then
            return false
        end
    end

    if RaisedWeaponCore.WepAlwaysRaised then return true end
    return self:getNetVar("raised", false)
end

