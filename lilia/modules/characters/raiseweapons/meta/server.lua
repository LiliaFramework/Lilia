local playerMeta = FindMetaTable("Player")
function playerMeta:setWepRaised(state, notification)
    self:setNetVar("raised", state)
    local weapon = self:GetActiveWeapon()
	local weponclass = self:GetActiveWeapon():GetClass()
	if IsValid(weapon) then
        weapon:SetNextPrimaryFire(CurTime() + 1)
        weapon:SetNextSecondaryFire(CurTime() + 1)
    end

	if weponclass == "lia_hands" then
	    if notification then lia.chat.send(self, "iteminternal", state and "raises his hands" or "lowers his hands", false) end
	else
		if notification then lia.chat.send(self, "iteminternal", state and "raises his weapon" or "lowers his weapon", false) end
	end
end

function playerMeta:toggleWepRaised()
    timer.Simple(1, function() self:setWepRaised(not self:isWepRaised(), true) end)
    local weapon = self:GetActiveWeapon()
    if IsValid(weapon) then
        if self:isWepRaised() and weapon.OnRaised then
            weapon:OnRaised()
        elseif not self:isWepRaised() and weapon.OnLowered then
            weapon:OnLowered()
        end
    end
end
