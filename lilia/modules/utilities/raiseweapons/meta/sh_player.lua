--- The Player Meta for the Raise Weapons Module.
-- @playermeta RaiseWeapons
local MODULE = MODULE
local playerMeta = FindMetaTable("Player")
--- Checks if the player's weapon is raised.
-- This function determines whether the player's currently active weapon is raised based on various conditions.
-- @realm shared
-- @treturn boolean true if the weapon is raised, false otherwise.
function playerMeta:isWepRaised()
    local weapon = self:GetActiveWeapon()
    local override = hook.Run("ShouldWeaponBeRaised", self, weapon)
    if override ~= nil then return override end
    if IsValid(weapon) then
        local weaponClass = weapon:GetClass()
        local weaponBase = weapon.Base
        if MODULE.PermaRaisedWeapons[weaponClass] or MODULE.PermaRaisedBases[weaponBase] or weapon.IsAlwaysRaised or weapon.AlwaysRaised then
            return true
        elseif weapon.IsAlwaysLowered or weapon.NeverRaised then
            return false
        end
    end

    if MODULE.WepAlwaysRaised then return true end
    return self:getNetVar("raised", false)
end

if SERVER then
    --- Sets the raised state of the player's weapon.
    -- This function sets whether the player's active weapon should be raised or lowered and optionally sends a notification.
    -- @realm server
    -- @bool state The desired raised state (true for raised, false for lowered).
    -- @bool[opt] notification Whether to send a notification about the action.
    function playerMeta:setWepRaised(state, notification)
        self:setNetVar("raised", state)
        if IsValid(self:GetActiveWeapon()) then
            local weapon = self:GetActiveWeapon()
            weapon:SetNextPrimaryFire(CurTime() + 1)
            weapon:SetNextSecondaryFire(CurTime() + 1)
            local weaponClass = weapon:GetClass()
            local action = state and "raises" or "lowers"
            local itemType = weaponClass == "lia_hands" and "hands" or "weapon"
            if notification then lia.chat.send(self, "actions", action .. " his " .. itemType, false) end
        end
    end

    --- Toggles the raised state of the player's weapon.
    -- This function toggles the weapon's raised state and triggers corresponding events.
    -- @realm server
    function playerMeta:toggleWepRaised()
        timer.Simple(1, function() self:setWepRaised(not self:isWepRaised(), MODULE.ShouldPrintMessage) end)
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