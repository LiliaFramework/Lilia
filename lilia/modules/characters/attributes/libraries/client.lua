local predictedStamina = 100
local stmBlurAmount = 0
local stmBlurAlpha = 0
function AttributesCore:ConfigureCharacterCreationSteps(panel)
    panel:addStep(vgui.Create("liaCharacterAttribs"), 99)
end

function AttributesCore:Think()
    local client = LocalPlayer()
    if not client:getChar() then return end
    local char = client:getChar()
    local maxStamina = char:getMaxStamina()
    local offset = self:CalcStaminaChange(client)
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)
    if offset ~= 0 then predictedStamina = math.Clamp(predictedStamina + offset, 0, maxStamina) end
end

function AttributesCore:HUDPaintBackground()
    local client = LocalPlayer()
    if not (self.StaminaBlur or client:getChar()) then return end
    local char = client:getChar()
    local maxStamina = char:getMaxStamina()
    local Stamina = client:getLocalVar("stamina", maxStamina)
    if Stamina <= self.StaminaBlurThreshold then
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, 255)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), stmBlurAmount, 0.2, stmBlurAlpha)
    end
end

if not StaminaBarAdded then
    lia.bar.add(function() return predictedStamina / 100 end, Color(200, 200, 40), nil, "stamina")
    StaminaBarAdded = true
end
