--------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character
--------------------------------------------------------------------------------------------------------
function charMeta:GetMaxStamina()
    local maxStamina = hook.Run("CharacterMaxStamina", self) or lia.config.DefaultStamina or 100

    return maxStamina
end
--------------------------------------------------------------------------------------------------------
function charMeta:GetStamina()
    local Stamina = self:getPlayer():getLocalVar("stamina", 100) or lia.config.DefaultStamina or 100

    return Stamina
end
--------------------------------------------------------------------------------------------------------