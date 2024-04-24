local MODULE = MODULE
local charMeta = lia.meta.character
function charMeta:getMaxStamina()
    local maxStamina = hook.Run("CharMaxStamina", self) or MODULE.DefaultStamina
    return maxStamina
end

function charMeta:getStamina()
    local Stamina = self:getPlayer():getLocalVar("stamina", 100) or MODULE.DefaultStamina
    return Stamina
end