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
    local bgColor = Color(25, 28, 35, 250)
    lia.derma.rect(0, 0, w, h):Rad(12):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
    surface.SetDrawColor(self.lineColor)
    surface.DrawRect(0, 0, w, self.lineWidth)
end

vgui.Register("liaHeaderPanel", PANEL, "Panel")
