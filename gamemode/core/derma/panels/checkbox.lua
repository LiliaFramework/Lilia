local PANEL = {}
function PANEL:Init()
    self:SetText("")
    self:SetToggle(true)
    self:SetSize(24, 24)
    self.checked = false
    self.text = ""
    self.textColor = color_white
    self.textFont = "DermaDefault"
end
function PANEL:SetText(text)
    self.text = text
end
function PANEL:SetTextColor(color)
    self.textColor = color
end
function PANEL:SetTextFont(font)
    self.textFont = font
end
function PANEL:SetChecked(state)
    self.checked = state and true or false
    self:SetSelected(self.checked)
    if self.OnChange then self.OnChange(self, self.checked) end
end
function PANEL:GetChecked()
    return self.checked
end
function PANEL:DoClick()
    self:SetChecked(not self.checked)
end
function PANEL:Paint()
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
vgui.Register("liaCheckbox", PANEL, "DButton")
