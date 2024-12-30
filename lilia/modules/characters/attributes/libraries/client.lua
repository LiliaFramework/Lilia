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
    local client = LocalPlayer()
    if hook.Run("CanPlayerViewAttributes") ~= false then
        tabs["Attributes"] = function(panel)
            local baseWidth, baseHeight = sW(1200), sH(900)
            local listWidth, listHeight = baseWidth * 0.85, baseHeight * 0.75
            local listX, listY = (ScrW() - listWidth) / 2, (ScrH() - listHeight) / 2
            local background = panel:Add("DPanel")
            background:SetSize(listWidth, listHeight + sH(30))
            background:SetPos(listX, listY - sH(30))
            background.Paint = function(_, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
                surface.SetDrawColor(60, 60, 60, 255)
                surface.DrawOutlinedRect(0, 0, w, h)
            end

            local scroll = panel:Add("DScrollPanel")
            scroll:SetSize(listWidth * 0.96, listHeight)
            scroll:SetPos(listX + listWidth * 0.02, listY)
            scroll:GetVBar():SetWide(6)
            scroll:GetVBar().Paint = function() end
            scroll:GetVBar().btnUp.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200)) end
            scroll:GetVBar().btnDown.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(50, 50, 50, 200)) end
            scroll:GetVBar().btnGrip.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(80, 80, 80, 200)) end
            local function addAttributeLine(attrName, currentValue, maxValue, progress)
                local lineHeight = 40
                local linePanel = scroll:Add("DPanel")
                linePanel:SetTall(lineHeight)
                linePanel:Dock(TOP)
                linePanel:DockMargin(0, 0, 0, 8)
                linePanel.Paint = function(_, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 200))
                    surface.SetDrawColor(80, 80, 80, 255)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                local nameLabel = linePanel:Add("DLabel")
                nameLabel:SetText(attrName)
                nameLabel:SetFont("liaMiniFont")
                nameLabel:SetTextColor(Color(255, 255, 255))
                nameLabel:SizeToContents()
                nameLabel:SetPos(10, (lineHeight - nameLabel:GetTall()) / 2)
                local barWidth = listWidth * 0.4
                local barX = 150
                local barY = (lineHeight - 20) / 2
                local progressBar = linePanel:Add("DPanel")
                progressBar:SetPos(barX, barY)
                progressBar:SetSize(barWidth, 20)
                progressBar.Paint = function(_, w, h)
                    draw.RoundedBox(10, 0, 0, w, h, Color(20, 20, 20, 180))
                    local fillWidth = math.Clamp(w * (progress / 100), 0, w)
                    draw.RoundedBox(10, 0, 0, fillWidth, h, Color(0, 200, 0, 250))
                    surface.SetDrawColor(100, 100, 100, 200)
                    surface.DrawOutlinedRect(0, 0, w, h)
                end

                local valueText = string.format("%d / %d (%d%%)", currentValue, maxValue, progress)
                local valueLabel = linePanel:Add("DLabel")
                valueLabel:SetText(valueText)
                valueLabel:SetFont("liaMiniFont")
                valueLabel:SetTextColor(Color(255, 255, 255))
                valueLabel:SizeToContents()
                valueLabel:SetPos(barX + barWidth + 10, (lineHeight - valueLabel:GetTall()) / 2)
            end

            local function updateAttributes()
                scroll:Clear()
                for attrKey, attrData in SortedPairsByMemberValue(lia.attribs.list, "name") do
                    local currentValue = client:getChar():getAttrib(attrKey, 0) or 0
                    local maxValue = hook.Run("GetAttributeMax", client, attrKey) or 100
                    local progress = math.Round((currentValue / maxValue) * 100, 1)
                    addAttributeLine(attrData.name, currentValue, maxValue, progress)
                end
            end

            updateAttributes()
        end
    end
end

lia.bar.add(function()
    local client = LocalPlayer()
    return client:getLocalVar("stamina", 0) / 100
end, Color(200, 200, 40), nil, "stamina")