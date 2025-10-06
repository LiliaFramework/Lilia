local PANEL = {}
function PANEL:Init()
    self.groupName = ""
    self.groupData = {}
    self.isDefault = false
    self.selected = false
    self.hovered = false
    -- Hide the base class text since we're drawing our own
    self:SetText("")
    self:SetupTransition("HoverAlpha", 6, function(s) return s:IsHovered() end)
    self:SetupTransition("SelectedAlpha", 8, function(s) return s.selected end)
    -- Cache the panel color for this button
    self.panelColor = lia.derma.getNextPanelColor()
end

function PANEL:SetGroup(groupName, groupData, isDefault)
    self.groupName = groupName or ""
    self.groupData = groupData or {}
    self.isDefault = isDefault or false
end

function PANEL:SetSelected(selected)
    self.selected = selected or false
end

function PANEL:GetSelected()
    return self.selected
end

function PANEL:OnCursorEntered()
    self.hovered = true
end

function PANEL:OnCursorExited()
    self.hovered = false
end

function PANEL:Paint(w, h)
    local bgColor = self.panelColor
    local textColor = lia.color.theme.text
    local accentColor = lia.config.get("Color")
    -- Background
    if self.selected then
        bgColor = ColorAlpha(accentColor, 30)
        textColor = accentColor
    elseif self.hovered then
        bgColor = ColorAlpha(accentColor, 15)
    end

    lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    -- Border for selected state
    if self.selected then lia.derma.rect(0, 0, w, h):Rad(8):Color(accentColor):Shape(lia.derma.SHAPE_IOS):Outline(2):Draw() end
    -- Group name
    draw.SimpleText(self.groupName, "liaMediumFont", 15, h / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end

vgui.Register("liaUserGroupButton", PANEL, "DButton")
