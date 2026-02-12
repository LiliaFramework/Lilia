local PANEL = {}
function PANEL:Init()
    self.text = ""
    self.icon = nil
    self.isActive = false
    self.indicatorHeight = 2
    self.hoverColor = Color(255, 255, 255, 10)
    self.animationSpeed = 8
    self:SetMouseInputEnabled(true)
    self:SetCursor("hand")
end

function PANEL:SetText(text)
    self.text = text
end

function PANEL:GetText()
    return self.text
end

function PANEL:OnMousePressed(keyCode)
    if keyCode == MOUSE_LEFT then
        self:DoClick()
        return true
    end
end

function PANEL:OnMouseReleased()
    return true
end

function PANEL:OnCursorEntered()
    self:InvalidateLayout()
end

function PANEL:OnCursorExited()
    self:InvalidateLayout()
end

function PANEL:DoClick()
    lia.websound.playButtonSound()
    if self.DoClickCallback then self:DoClickCallback() end
end

function PANEL:SetDoClick(callback)
    self.DoClickCallback = callback
end

function PANEL:OnRemove()
    self.DoClickCallback = nil
    self.startTime = nil
end

function PANEL:SetIcon(icon)
    self.icon = icon
end

function PANEL:GetIcon()
    return self.icon
end

function PANEL:SetActive(state)
    self.isActive = state
    self:InvalidateLayout()
end

function PANEL:IsActive()
    return self.isActive
end

function PANEL:SetIndicatorHeight(height)
    self.indicatorHeight = height
    self:InvalidateLayout()
end

function PANEL:Paint(w, h)
    if not self.text then return end
    local theme = lia.color.theme
    local colorText = self.isActive and color_white or theme.text or Color(200, 200, 200)
    local colorIcon = self.isActive and color_white or Color(180, 180, 180)
    if self.isActive then
        local highlight = Color(255, 255, 255, 10)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(highlight):Shape(lia.derma.SHAPE_IOS):Draw()
    end

    local iconW = self.icon and 16 or 0
    local iconTextGap = self.icon and 8 or 0
    surface.SetFont("LiliaFont.18")
    local totalContentWidth = iconW + iconTextGap + surface.GetTextSize(self.text)
    local startX = (w - totalContentWidth) / 2
    local textX = startX + (iconW > 0 and (iconW + iconTextGap) or 0)
    if self.icon then
        surface.SetDrawColor(colorIcon.r, colorIcon.g, colorIcon.b, 255)
        surface.SetMaterial(self.icon)
        surface.DrawTexturedRect(startX, (h - 16) * 0.5, 16, 16)
    end

    surface.SetTextColor(colorText.r, colorText.g, colorText.b, 255)
    surface.SetTextPos(textX, h * 0.5 - 9)
    surface.DrawText(self.text)
end

vgui.Register("liaTabButton", PANEL, "DPanel")
