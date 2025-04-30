local ScrW, ScrH = ScrW(), ScrH()
local predictedStamina = 100
local stmBlurAmount = 0
local stmBlurAlpha = 0
function MODULE:ConfigureCharacterCreationSteps(panel)
    panel:addStep(vgui.Create("liaCharacterAttribs"), 98)
end

function MODULE:Think()
    local client = LocalPlayer()
    if not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = character:getMaxStamina()
    local offset = self:CalcStaminaChange(client)
    offset = math.Remap(FrameTime(), 0, 0.25, 0, offset)
    if offset ~= 0 then predictedStamina = math.Clamp(predictedStamina + offset, 0, maxStamina) end
end

function MODULE:CanPlayerViewAttributes()
    return table.Count(lia.attribs.list) > 0
end

function MODULE:HUDPaintBackground()
    local client = LocalPlayer()
    if not lia.config.get("StaminaBlur", false) or not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = character:getMaxStamina()
    local Stamina = client:getLocalVar("stamina", maxStamina)
    if Stamina <= lia.config.get("StaminaBlurThreshold", 25) then
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, 255)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW, ScrH, stmBlurAmount, 0.2, stmBlurAlpha)
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")