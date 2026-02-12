local PANEL = {}
function PANEL:Init()
    self.privilegeName = ""
    self.checked = false
    self.editable = true
    self.hovered = false
    self:SetupTransition("HoverAlpha", 6, function(s) return s:IsHovered() end)
    self.panelColor = lia.color.theme.panel[1]
    self.borderColor = lia.color.theme.panel[1]
    self:SetupUI()
end

function PANEL:SetupUI()
    self.checkbox = self:Add("liaCheckbox")
    self.checkbox:SetSize(48, 24)
    self.checkbox:SetPos(self:GetWide() - 75, (self:GetTall() - 24) / 2)
    self.checkbox.OnChange = function(_, value)
        self.checked = value
        if self.OnChange then self:OnChange(value) end
    end

    self.label = self:Add("DLabel")
    self.label:Dock(FILL)
    self.label:DockMargin(18, 0, 60, 0)
    self.label:SetFont("LiliaFont.18")
    self.label:SetTextColor(lia.color.theme.text)
    self.label:SetContentAlignment(4)
end

function PANEL:SetPrivilege(privilegeName, checked, editable)
    self.privilegeName = privilegeName or ""
    self.checked = checked or false
    self.editable = editable ~= false
    local displayKey = lia.admin.privilegeNames[privilegeName] or privilegeName
    self.label:SetText(L(displayKey))
    self.checkbox:SetChecked(self.checked)
    self.checkbox:SetMouseInputEnabled(self.editable)
    if not self.editable then
        self.checkbox:SetCursor("arrow")
        self:SetCursor("arrow")
        self.checkbox:SetAlpha(150)
        local textColor = lia.color.theme.text or color_white
        self.label:SetTextColor(Color(textColor.r * 0.6, textColor.g * 0.6, textColor.b * 0.6, textColor.a))
    else
        self.checkbox:SetAlpha(255)
        self.label:SetTextColor(lia.color.theme.text or color_white)
    end
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
    if IsValid(self.checkbox) then self.checkbox:SetPos(w - 75, (h - 24) / 2) end
end

function PANEL:Paint(w, h)
    local theme = lia.color.theme
    local bgColor = Color(20, 23, 28, 200)
    if not self.editable then bgColor = ColorAlpha(bgColor, 0.4) end
    lia.derma.rect(0, 0, w, h):Rad(4):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    if self.checked then
        local accentColor = theme and theme.accent or theme.theme or Color(100, 150, 200, 255)
        if not self.editable then accentColor = ColorAlpha(accentColor, 0.5) end
        lia.derma.rect(0, 0, 3, h):Radii(4, 0, 0, 4):Color(accentColor):Draw()
    end

    if not self.editable then
        surface.SetDrawColor(100, 100, 100, 20)
        surface.DrawRect(0, 0, w, h)
        local lockIcon = Material("icon16/lock.png", "smooth")
        if lockIcon and not lockIcon:IsError() then
            surface.SetDrawColor(150, 150, 150, 180)
            surface.SetMaterial(lockIcon)
            surface.DrawTexturedRect(w - 90, (h - 16) / 2, 16, 16)
        else
            draw.SimpleText("LOCK", "LiliaFont.12", w - 90, h / 2, Color(150, 150, 150, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end

    local borderColor = Color(40, 45, 50, 60)
    if not self.editable then borderColor = ColorAlpha(borderColor, 0.3) end
    surface.SetDrawColor(borderColor)
    surface.DrawRect(0, h - 1, w, 1)
end

vgui.Register("liaPrivilegeRow", PANEL, "DPanel")
