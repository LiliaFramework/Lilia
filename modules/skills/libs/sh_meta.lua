-------------------------------------------------------------------------------------------------------------------------~
local charMeta = lia.meta.character
-------------------------------------------------------------------------------------------------------------------------~
function charMeta:getMaxStamina()
    local maxStamina = hook.Run("CharacterMaxStamina", self) or lia.config.DefaultStamina or 100
    return maxStamina
end
-------------------------------------------------------------------------------------------------------------------------~
function MODULE:GetStrengthBonusDamage(character)
    return (character:getAttrib("strength", 0) * self.StrengthMultiplier) or 0
end
-------------------------------------------------------------------------------------------------------------------------~
function MODULE:GetPunchStrengthBonusDamage(character)
    return (character:getAttrib("strength", 0) * self.PunchStrengthMultiplier) or 0
end
-------------------------------------------------------------------------------------------------------------------------~