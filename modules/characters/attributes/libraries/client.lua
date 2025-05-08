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

function MODULE:HUDPaintBackground()
    local client = LocalPlayer()
    if not lia.config.get("StaminaBlur", false) or not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = character:getMaxStamina()
    local Stamina = client:getLocalVar("stamina", maxStamina)
    if Stamina <= lia.config.get("StaminaBlurThreshold", 25) then
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, 255)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), stmBlurAmount, 0.2, stmBlurAlpha)
    end
end

function MODULE:LoadCharInformation()
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local char = client:getChar()
    if not char then return end
    hook.Run("AddSection", L("attributes"), Color(0, 0, 0), 2, 1)
    local attrs = {}
    for id, attr in pairs(lia.attribs.list) do
        attrs[#attrs + 1] = {
            id = id,
            attr = attr
        }
    end

    table.sort(attrs, function(a, b) return a.attr.name < b.attr.name end)
    for _, entry in ipairs(attrs) do
        local id, attr = entry.id, entry.attr
        local minVal = attr.min or 0
        local maxVal = attr.max or 100
        hook.Run("AddBarField", L("attributes"), id, attr.name, function() return minVal end, function() return maxVal end, function() return char:getAttrib(id) end)
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")