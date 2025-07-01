local predictedStamina = 100
local stmBlurAmount = 0
local stmBlurAlpha = 0
function MODULE:ConfigureCharacterCreationSteps(panel)
    panel:addStep(vgui.Create("liaCharacterAttribs"), 98)
end

function MODULE:PlayerBindPress(client, bind, pressed)
    if not pressed then return end
    local char = client:getChar()
    if not char then return end
    local stam = predictedStamina or 0
    if stam == 0 then stam = client:getLocalVar("stamina", 0) end
    local jumpReq = lia.config.get("JumpStaminaCost")
    if bind == "+jump" and stam < jumpReq then return true end
    if bind == "+speed" and stam <= 5 then
        client:ConCommand("-speed")
        return true
    end
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

function MODULE:OnLocalVarSet(key, var)
    if key ~= "stamina" then return end
    if math.abs(predictedStamina - var) > 5 then
        predictedStamina = var
    end
end

function MODULE:HUDPaintBackground()
    local client = LocalPlayer()
    if not lia.config.get("StaminaBlur", false) or not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = character:getMaxStamina()
    local stamina = client:getLocalVar("stamina", maxStamina)
    if stamina < maxStamina * 0.25 then
        local ratio = (maxStamina * 0.25 - stamina) / (maxStamina * 0.25)
        local targetAlpha = ratio * 255
        local targetAmount = ratio * 5
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, targetAlpha)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, targetAmount)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), stmBlurAmount, 0.2, stmBlurAlpha)
    else
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, 0)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, 0)
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
    local char = client:getChar()
    if not char then return 0 end
    local max = char:getMaxStamina()
    return (predictedStamina or client:getLocalVar("stamina", max)) / max
end, Color(200, 200, 40), nil, "stamina")