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
    if hook.Run("CanPlayerViewAttributes") ~= false then
        tabs["Attributes"] = function(panel)
            local baseWidth, baseHeight = sW(800), sH(600)
            local listWidth, listHeight = baseWidth * 0.9, baseHeight * 0.8
            local listX, listY = (ScrW() - listWidth) / 2, (ScrH() - listHeight) / 2
            local title = panel:Add("DLabel")
            title:SetText("Character Attributes")
            title:SetFont("Trebuchet24")
            title:SizeToContents()
            title:SetPos(listX + listWidth / 2 - title:GetWide() / 2, listY - sH(40))
            panel.attributesListView = panel:Add("DListView")
            panel.attributesListView:SetMultiSelect(false)
            panel.attributesListView:AddColumn("Attribute"):SetFixedWidth(listWidth * 0.3)
            panel.attributesListView:AddColumn("Value"):SetFixedWidth(listWidth * 0.2)
            panel.attributesListView:AddColumn("Max"):SetFixedWidth(listWidth * 0.2)
            panel.attributesListView:AddColumn("Progress (%)"):SetFixedWidth(listWidth * 0.3)
            panel.attributesListView:SetSize(listWidth, listHeight)
            panel.attributesListView:SetPos(listX, listY)
            for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
                local currentValue = LocalPlayer():getChar() and LocalPlayer():getChar():getAttrib(attrKey, 0) or 0
                local maxValue = hook.Run("GetAttributeMax", LocalPlayer(), attrKey) or 100
                local progress = math.Round((currentValue / maxValue) * 100, 1)
                panel.attributesListView:AddLine(attrData.name, currentValue, maxValue, progress .. "%")
            end
        end
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")