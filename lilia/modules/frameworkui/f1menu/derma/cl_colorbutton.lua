local MODULE = MODULE
local PANEL = {}
function PANEL:Init()
    self:SetText("")
    self:SetTall(50)
    self:SetFont("liaMediumFont")
    self:SetTextColor(color_white)
    self:SetExpensiveShadow(1, Color(0, 0, 0, 100))
    self:SetContentAlignment(5)
    self.isAvailable = false
    self.active = false
    self.tabName = ""
end

function PANEL:SetTabData(name, isAvailable, callback)
    self.tabName = name
    self.isAvailable = isAvailable
    self.DoClick = function() if callback then callback(self) end end
end

function PANEL:Paint(w, h)
    if self.active then
        surface.SetDrawColor(MODULE.MenuColors.accent)
    elseif self:IsHovered() then
        surface.SetDrawColor(self.isAvailable and MODULE.MenuColors.hover or Color(100, 100, 100))
    else
        surface.SetDrawColor(self.isAvailable and MODULE.MenuColors.sidebar or Color(80, 80, 80))
    end

    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(MODULE.MenuColors.border)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("liaColoredButton", PANEL, "DButton")