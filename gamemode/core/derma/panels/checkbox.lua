local PANEL = {}
function PANEL:Init()
    self:SetText("")
    self:SetToggle(true)
    self:SetSize(22, 22)
    self.checked = false
end

function PANEL:SetChecked(state)
    self.checked = state and true or false
    self:SetSelected(self.checked)
    if self.OnChange then self:OnChange(self.checked) end
end

function PANEL:GetChecked()
    return self.checked
end

function PANEL:DoClick()
    self:SetChecked(not self.checked)
end

function PANEL:Paint(w, h)
    local icon = self.checked and "checkbox.png" or "unchecked.png"
    lia.util.drawTexture(icon, color_white, 0, 0, w, h)
    return true
end

vgui.Register("liaCheckBox", PANEL, "DButton")