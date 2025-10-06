local PANEL = {}
function PANEL:Init()
    self.text = ""
    self.description = ""
    self.convar = ""
    self.value = false
    self.hoverAnim = 0
    self.circleAnim = 0
    self:SetText("")
    self:SetCursor("hand")
    -- Create the toggle button as the main element
    self.toggle = vgui.Create("DButton", self)
    self.toggle:Dock(FILL) -- Fill the entire panel
    self.toggle:SetText("")
    self.toggle:SetCursor("hand")
    -- Move all the checkbox logic to the toggle button
    self.toggle.hoverAnim = 0
    self.toggle.circleAnim = 0
    self.toggle.Paint = function(toggle, w, h)
        if toggle:IsHovered() then
            self.hoverAnim = math.Clamp(self.hoverAnim + FrameTime() * 6, 0, 1)
        else
            self.hoverAnim = math.Clamp(self.hoverAnim - FrameTime() * 10, 0, 1)
        end

        self.circleAnim = Lerp(FrameTime() * 12, self.circleAnim, self.value and 1 or 0)
        local trackH = math.min(20, h - 4)
        local trackY = (h - trackH) / 2
        local trackW = math.min(w, 120) -- Limit width to 120 pixels for bigger checkboxes
        local trackX = (w - trackW) / 2 -- Center the track
        lia.derma.rect(trackX, trackY, trackW, trackH):Rad(16):Color(lia.color.theme.button):Shape(lia.derma.SHAPE_IOS):Draw()
        if self.hoverAnim > 0 then lia.derma.rect(trackX, trackY, trackW, trackH):Rad(16):Color(Color(lia.color.theme.button_hovered.r, lia.color.theme.button_hovered.g, lia.color.theme.button_hovered.b, self.hoverAnim * 80)):Shape(lia.derma.SHAPE_IOS):Draw() end
        local circleSize = math.min(16, trackH - 4)
        local pad = trackY + (trackH - circleSize) / 2
        local x0 = trackX + pad
        local x1 = trackX + trackW - circleSize - pad
        local circleX = Lerp(self.circleAnim, x0, x1)
        local circleCol = self.value and Color(lia.color.theme.theme.r + 50, lia.color.theme.theme.g + 50, lia.color.theme.theme.b + 50) or lia.color.theme.gray
        lia.derma.circle(circleX + circleSize / 2, h / 2, circleSize):Color(circleCol):Draw()
    end

    self.toggle.DoClick = function()
        if self.convar ~= '' then LocalPlayer():ConCommand(self.convar .. ' ' .. (self.value and 0 or 1)) end
        self.value = not self.value
        self:OnChange(self.value)
        surface.PlaySound('button_click.wav')
    end

    -- Override the main panel's click to go to the toggle
    self.DoClick = function() self.toggle:DoClick() end
end

function PANEL:SetTxt(text)
    self.text = text
end

function PANEL:SetValue(val)
    self.value = val
end

function PANEL:SetChecked(val)
    self:SetValue(tobool(val))
end

function PANEL:GetChecked()
    return self.value
end

function PANEL:IsChecked()
    return self:GetChecked()
end

function PANEL:Toggle()
    self:SetChecked(not self.value)
    self:OnChange(self.value)
end

function PANEL:GetBool()
    return self.value
end

function PANEL:SetConvar(convar)
    self.value = GetConVar(convar):GetBool()
    self.convar = convar
end

function PANEL:SetDescription(desc)
    self.description = desc
    self:SetTooltip(desc)
    self:SetTooltipDelay(1.5)
end

function PANEL:Paint()
    -- No background painting needed - the toggle button handles everything
    -- Text and description are now handled externally since this is just the button
end

function PANEL:DoClick()
    -- Clicking now goes directly to the toggle button
    self.toggle:DoClick()
end

function PANEL:OnChange()
    -- Base OnChange method - can be overridden
    -- val is the new boolean value of the checkbox
end

function PANEL:PerformLayout()
    -- No special layout needed - toggle fills the entire panel
end

-- Override SetSize to ensure proper sizing
function PANEL:SetSize()
    -- The toggle will automatically resize to fill the panel due to Dock(FILL)
end

vgui.Register('liaCheckbox', PANEL, 'Panel')
local SIMPLE_CHECKBOX_PANEL = {}
function SIMPLE_CHECKBOX_PANEL:Init()
    self:SetText("")
    self:SetToggle(true)
    self:SetSize(24, 24)
    self.checked = false
    self.text = ""
    self.textColor = color_white
    self.textFont = "DermaDefault"
end

function SIMPLE_CHECKBOX_PANEL:SetText(text)
    self.text = text
end

function SIMPLE_CHECKBOX_PANEL:SetTextColor(color)
    self.textColor = color
end

function SIMPLE_CHECKBOX_PANEL:SetTextFont(font)
    self.textFont = font
end

function SIMPLE_CHECKBOX_PANEL:SetChecked(state)
    self.checked = state and true or false
    self:SetSelected(self.checked)
    if self.OnChange then self.OnChange(self, self.checked) end
end

function SIMPLE_CHECKBOX_PANEL:GetChecked()
    return self.checked
end

function SIMPLE_CHECKBOX_PANEL:DoClick()
    self:SetChecked(not self.checked)
end

function SIMPLE_CHECKBOX_PANEL:Paint()
    local icon = self.checked and "checkbox.png" or "unchecked.png"
    local w, h = self:GetSize()
    lia.util.drawTexture(icon, color_white, 0, 0, w, h)
    if self.text and self.text ~= "" then
        surface.SetFont(self.textFont)
        surface.SetTextColor(self.textColor)
        surface.SetTextPos(28, 2)
        surface.DrawText(self.text)
    end
    return true
end

vgui.Register("liaSimpleCheckbox", SIMPLE_CHECKBOX_PANEL, "DButton")
