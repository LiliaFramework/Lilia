
local playerMeta = FindMetaTable("Player")

function playerMeta:RestoreStamina(amount)
    local current = self:getLocalVar("stamina", 0)
    local maxStamina = self:getChar():GetMaxStamina()
    local value = math.Clamp(current + amount, 0, maxStamina)
    self:setLocalVar("stamina", value)
    if value >= (maxStamina * 0.5) and self:getNetVar("brth", false) then
        self:setNetVar("brth", nil)
        hook.Run("PlayerStaminaGained", self)
    end
end

function playerMeta:ConsumeStamina(amount)
    local current = self:getLocalVar("stamina", 0)
    local value = math.Clamp(current - amount, 0, self:getChar():GetMaxStamina())
    self:setLocalVar("stamina", value)
    if value == 0 and not self:getNetVar("brth", false) then
        self:setNetVar("brth", true)
        hook.Run("PlayerStaminaLost", self)
    end
end
