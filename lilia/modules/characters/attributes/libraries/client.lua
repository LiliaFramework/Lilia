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
            local scroll = panel:Add("DScrollPanel")
            scroll:SetSize(listWidth, listHeight)
            scroll:SetPos(listX, listY)
            local function addAttributeLine(attrName, currentValue, maxValue, progress)
                local lineHeight = 50
                local linePanel = scroll:Add("DPanel")
                linePanel:SetTall(lineHeight)
                linePanel:Dock(TOP)
                linePanel:DockMargin(0, 0, 0, 10)
                linePanel.Paint = function(_, w, h)
                    surface.SetDrawColor(40, 40, 40, 200)
                    surface.DrawRect(0, 0, w, h)
                    surface.SetDrawColor(80, 80, 80, 255)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                local nameLabel = linePanel:Add("DLabel")
                nameLabel:SetText(attrName)
                nameLabel:SetFont("liaMediumFont")
                nameLabel:SetTextColor(Color(255, 255, 255))
                nameLabel:SizeToContents()
                nameLabel:SetPos(10, lineHeight / 2 - nameLabel:GetTall() / 2)
                local barWidth = listWidth * 0.6
                local barX = 150
                local barY = (lineHeight / 2) - 12
                local progressBar = linePanel:Add("DPanel")
                progressBar:SetPos(barX, barY)
                progressBar:SetSize(barWidth, 24)
                progressBar.Paint = function(_, w, h)
                    surface.SetDrawColor(20, 20, 20, 180)
                    surface.DrawRect(0, 0, w, h)
                    local fillWidth = math.Clamp(w * (progress / 100), 0, w)
                    surface.SetDrawColor(0, 255, 0, 250)
                    surface.DrawRect(0, 0, fillWidth, h)
                    surface.SetDrawColor(100, 100, 100, 200)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                local valueText = string.format("%d / %d (%d%%)", currentValue, maxValue, progress)
                local valueLabel = linePanel:Add("DLabel")
                valueLabel:SetText(valueText)
                valueLabel:SetFont("liaMediumFont")
                valueLabel:SetTextColor(Color(255, 255, 255))
                valueLabel:SizeToContents()
                valueLabel:SetPos(barX + barWidth + 10, lineHeight / 2 - valueLabel:GetTall() / 2)
            end

            for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
                local currentValue = LocalPlayer():getChar() and LocalPlayer():getChar():getAttrib(attrKey, 0) or 0
                local maxValue = hook.Run("GetAttributeMax", LocalPlayer(), attrKey) or 100
                local progress = math.Round((currentValue / maxValue) * 100, 1)
                addAttributeLine(attrData.name, currentValue, maxValue, progress)
            end
        end
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")