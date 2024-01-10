
local charMeta = lia.meta.character

function charMeta:getMaxStamina()
    local maxStamina = hook.Run("CharacterMaxStamina", self) or AttributesCore.DefaultStamina
    return maxStamina
end


function charMeta:getStamina()
    local Stamina = self:getPlayer():getLocalVar("stamina", 100) or AttributesCore.DefaultStamina
    return Stamina
end

