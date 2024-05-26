local MODULE = MODULE
local characterMeta = lia.meta.character
function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("CharMaxStamina", self) or MODULE.DefaultStamina
    return maxStamina
end

function characterMeta:getStamina()
    local Stamina = self:getPlayer():getLocalVar("stamina", 100) or MODULE.DefaultStamina
    return Stamina
end
