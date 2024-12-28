--- The Player Meta for the Attributes Module.
-- @playermeta Attributes
local playerMeta = FindMetaTable("Player")
--- Checks if the player has a skill level equal to or greater than the specified level.
-- @realm shared
-- @string skill The skill to check.
-- @int level The required skill level.
-- @treturn bool Whether the player's skill level meets or exceeds the specified level.
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--- Checks if the player meets the required skill levels.
-- @realm shared
-- @tab requiredSkillLevels A table containing the required skill levels.
-- @treturn bool Whether the player meets all the required skill levels.
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

if SERVER then
    --- Restores stamina for the player.
    -- This function restores a certain amount of stamina to the player, clamping the value between 0 and the character's maximum stamina. If stamina is restored above a certain threshold, it will trigger the removal of a breathless state.
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
    -- This function decreases the player's stamina by a specified amount, clamping the value between 0 and the character's maximum stamina. If stamina is depleted, it may trigger a breathless state.
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