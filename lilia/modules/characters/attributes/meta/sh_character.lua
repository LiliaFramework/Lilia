local MODULE = MODULE
-- @charactermeta Attributes
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

if SERVER then
    --- Restores stamina for the player.
    -- This function restores a certain amount of stamina to the player, clamping the value between 0 and the character's maximum stamina.
    -- If stamina is restored above a certain threshold, it may trigger the removal of a breathless state.
    -- @realm server
    -- @int amount The amount of stamina to restore.
    function playerMeta:restoreStamina(amount)
        local current = self:getLocalVar("stamina", 0)
        local maxStamina = self:getChar():getMaxStamina()
        local value = math.Clamp(current + amount, 0, maxStamina)
        self:setLocalVar("stamina", value)
        if value >= (maxStamina * 0.5) and self:getNetVar("brth", false) then
            self:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    --- Consumes stamina from the player.
    -- This function decreases the player's stamina by a specified amount, clamping the value between 0 and the character's maximum stamina.
    -- If stamina is depleted, it may trigger a breathless state.
    -- @realm server
    -- @int amount The amount of stamina to consume.
    function playerMeta:consumeStamina(amount)
        local current = self:getLocalVar("stamina", 0)
        local value = math.Clamp(current - amount, 0, self:getChar():getMaxStamina())
        self:setLocalVar("stamina", value)
        if value == 0 and not self:getNetVar("brth", false) then
            self:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", self)
        end
    end
end