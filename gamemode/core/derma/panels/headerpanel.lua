local PANEL = {}
function PANEL:Init()
    self.lineWidth = 1
    self.lineColor = lia.color.theme and lia.color.theme.theme or Color(116, 185, 255)
end

function PANEL:SetLineColor(color)
    self.lineColor = color
end

function PANEL:SetLineWidth(width)
    self.lineWidth = width
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(self.lineColor)
    surface.DrawRect(4, h - self.lineWidth, math.max(w - 8, 0), self.lineWidth)
end

vgui.Register("liaHeaderPanel", PANEL, "Panel")
