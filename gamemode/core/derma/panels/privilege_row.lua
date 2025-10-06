local PANEL = {}
function PANEL:Init()
    self.privilegeName = ""
    self.checked = false
    self.editable = true
    self.hovered = false
    self:SetupTransition("HoverAlpha", 6, function(s) return s:IsHovered() end)
    self.panelColor = lia.derma.getNextPanelColor()
    self.borderColor = lia.derma.getNextPanelColor()
    self:SetupUI()
end

function PANEL:SetupUI()
    -- Checkbox
    self.checkbox = self:Add("liaSimpleCheckbox")
    self.checkbox:SetSize(24, 24)
    self.checkbox:SetPos(self:GetWide() - 30, (self:GetTall() - 24) / 2)
    self.checkbox.OnChange = function(_, value)
        self.checked = value
        if self.OnChange then self:OnChange(value) end
    end

    -- Label
    self.label = self:Add("DLabel")
    self.label:Dock(FILL)
    self.label:DockMargin(15, 0, 40, 0)
    self.label:SetFont("liaMediumFont")
    self.label:SetTextColor(lia.color.theme.text)
    self.label:SetContentAlignment(4)
end

function PANEL:SetPrivilege(privilegeName, checked, editable)
    self.privilegeName = privilegeName or ""
    self.checked = checked or false
    self.editable = editable ~= false
    local displayKey = lia.administrator.privilegeNames[privilegeName] or privilegeName
    self.label:SetText(L(displayKey))
    self.checkbox:SetChecked(self.checked)
    self.checkbox:SetMouseInputEnabled(self.editable)
    if not self.editable then self.checkbox:SetCursor("arrow") end
end

function PANEL:GetChecked()
    return self.checked
end

function PANEL:SetChecked(checked)
    self.checked = checked or false
    self.checkbox:SetChecked(self.checked)
end

function PANEL:OnCursorEntered()
    self.hovered = true
end

function PANEL:OnCursorExited()
    self.hovered = false
end

function PANEL:PerformLayout(w, h)
    if IsValid(self.checkbox) then self.checkbox:SetPos(w - 30, (h - 24) / 2) end
end

function PANEL:Paint(w, h)
    local bgColor = self.panelColor
    -- Hover effect
    if self.hovered then bgColor = ColorAlpha(lia.config.get("Color"), 10) end
    lia.derma.rect(0, 0, w, h):Rad(6):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    -- Bottom border
    surface.SetDrawColor(self.borderColor)
    surface.DrawRect(0, h - 1, w, 1)
end

vgui.Register("liaPrivilegeRow", PANEL, "DPanel")
