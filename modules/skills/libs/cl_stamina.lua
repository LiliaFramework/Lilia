-------------------------------------------------------------------------------------------------------------------------~
local MODULE = MODULE
-------------------------------------------------------------------------------------------------------------------------~
MODULE.predictedStamina = 100
MODULE.stmBlurAlpha = 0
MODULE.stmBlurAmount = 0

-------------------------------------------------------------------------------------------------------------------------~
function MODULE:Think()
    local ply = LocalPlayer()
    if not ply:getChar() then return end
    local char = ply:getChar()
    local maxStamina = char:GetMaxStamina()
    local offset = self:CalcStaminaChange(ply)
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)

    if offset ~= 0 then
        self.predictedStamina = math.Clamp(self.predictedStamina + offset, 0, maxStamina)
    end
end

-------------------------------------------------------------------------------------------------------------------------~
function MODULE:HUDPaintBackground()
    local ply = LocalPlayer()

    if not ply:getChar() then return end
    if not lia.config.StaminaBlur then return end
    local ply = LocalPlayer()
    local char = ply:getChar()
    local maxStamina = char:GetMaxStamina()
    local Stamina = ply:getLocalVar("stamina", maxStamina)

    if Stamina <= 5 then
        self.stmBlurAlpha = Lerp(RealFrameTime() / 2, self.stmBlurAlpha, 255)
        self.stmBlurAmount = Lerp(RealFrameTime() / 2, self.stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), self.stmBlurAmount, 0.2, self.stmBlurAlpha)
    end
end

-------------------------------------------------------------------------------------------------------------------------~
lia.bar.add(function()
    return MODULE.predictedStamina / 100
end, Color(200, 200, 40), nil, "stamina")