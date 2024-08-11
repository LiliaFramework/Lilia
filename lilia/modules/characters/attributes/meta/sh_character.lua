--- The Character Meta for the Attributes Module.
-- @charactermeta Attributes
local MODULE = MODULE
local characterMeta = lia.meta.character
--- Retrieves the maximum stamina for a character.
-- This function determines the maximum stamina a character can have, either from a hook or a default value.
-- @realm shared
-- @treturn integer The maximum stamina value.
function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("CharMaxStamina", self) or MODULE.DefaultStamina
    return maxStamina
end

--- Retrieves the current stamina for a character.
-- This function returns the character's current stamina, using either a local variable or a default value.
-- @realm shared
-- @treturn integer The current stamina value.
function characterMeta:getStamina()
    local stamina = self:getPlayer():getLocalVar("stamina", 100) or MODULE.DefaultStamina
    return stamina
end