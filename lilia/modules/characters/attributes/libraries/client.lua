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
    if self.F1DisplayAttributes then return false end
end

function MODULE:LoadCharInformation()
    if hook.Run("CanPlayerViewAttributes") == false then
        hook.Run("AddSection", "Attributes", Color(0, 0, 0), 2)
        for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
            local maximum = hook.Run("GetAttributeMax", LocalPlayer(), k)
            hook.Run("AddBarField", "Attributes", v.name, v.name, function() return 0 end, function() return maximum end, function() return LocalPlayer():getChar():getAttrib(k, 0) end)
        end
    end
end

function MODULE:HUDPaintBackground()
    local client = LocalPlayer()
    if not self.StaminaBlur or not client:getChar() then return end
    local character = client:getChar()
    local maxStamina = character:getMaxStamina()
    local Stamina = client:getLocalVar("stamina", maxStamina)
    if Stamina <= self.StaminaBlurThreshold then
        stmBlurAlpha = Lerp(RealFrameTime() / 2, stmBlurAlpha, 255)
        stmBlurAmount = Lerp(RealFrameTime() / 2, stmBlurAmount, 5)
        lia.util.drawBlurAt(0, 0, ScrW(), ScrH(), stmBlurAmount, 0.2, stmBlurAlpha)
    end
end

function MODULE:CreateMenuButtons(tabs)
    local client = LocalPlayer()
    if table.Count(lia.attribs.list) > 0 and hook.Run("CanPlayerViewAttributes") ~= false then
        tabs["Attributes"] = function(panel)
            panel.attribs = panel:Add("DScrollPanel")
            panel.attribs:Dock(FILL)
            panel.attribs:DockMargin(0, 10, 0, 0)
            if not IsValid(panel.attribs) then return end
            local character = client:getChar()
            local boost = character:getBoosts()
            for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
                local attribBoost = 0
                if boost[k] then
                    for _, bValue in pairs(boost[k]) do
                        attribBoost = attribBoost + bValue
                    end
                end

                local bar = panel.attribs:Add("liaAttribBar")
                bar:Dock(TOP)
                bar:DockMargin(0, 0, 0, 3)
                local attribValue = character:getAttrib(k, 0)
                if attribBoost then
                    bar:setValue(attribValue - attribBoost or 0)
                else
                    bar:setValue(attribValue)
                end

                local maximum = hook.Run("GetAttributeMax", LocalPlayer(), k)
                bar:setMax(maximum)
                bar:setReadOnly()
                bar:setText(Format("%s [%.1f/%.1f] (%.1f", L(v.name), attribValue, maximum, attribValue / maximum * 100) .. "%)")
                if attribBoost then bar:setBoost(attribBoost) end
            end
        end
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")