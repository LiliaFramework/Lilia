--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:EntityTakeDamage(target, dmginfo)
    if not dmginfo:GetAttacker():IsPlayer() then return end
    local attacker = dmginfo:GetAttacker()
    local char = attacker:getChar()
    local weapon = attacker:GetActiveWeapon()
    local damage = dmginfo:GetDamage()
    local strbonus = hook.Run("GetStrengthBonusDamage", char)
    if IsValid(attacker) and IsValid(weapon) and table.HasValue(lia.config.MeleeWeapons, weapon:GetClass()) and lia.config.MeleeDamageBonus then dmginfo:SetDamage(damage + strbonus) end
    if self.DevMode then self:PrintAllDetails(target, dmginfo) end
end

--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PlayerGetFistDamage(client, damage, context)
    local char = client:getChar()
    local strbonus = hook.Run("GetPunchStrengthBonusDamage", char)
    if client:getChar() then context.damage = context.damage + strbonus end
end

--------------------------------------------------------------------------------------------------------------------------------------------
function MODULE:PrintAllDetails(target, dmginfo)
    local attacker = dmginfo:GetAttacker()
    local IsPlayer = attacker:IsPlayer()
    local weapon = IsPlayer and attacker:GetActiveWeapon()
    local baseDamage = dmginfo:GetDamage()
    local strbonus = hook.Run("GetStrengthBonusDamage", attacker:getChar())
    if not (attacker:IsNPC() or attacker:IsNextBot() or attacker:IsPlayer()) then return end
    if IsPlayer then
        target:ChatPrint("You are being attacked by: " .. tostring(attacker:GetName()))
        attacker:ChatPrint("You are attacking: " .. tostring(attacker:GetName()))
        if table.HasValue(self.MeleeWeapons, weapon:GetClass()) then
            target:ChatPrint("Weapon: " .. tostring(dmginfo:GetWeapon()))
            target:ChatPrint("Base Damage: " .. baseDamage)
            target:ChatPrint("Total Damage (with strength): " .. (baseDamage + strbonus))
        end
    else
        target:ChatPrint("Base Damage: " .. baseDamage)
        target:ChatPrint("You are being attacked by a " .. tostring(attacker:GetName()))
    end
end
--------------------------------------------------------------------------------------------------------------------------------------------
