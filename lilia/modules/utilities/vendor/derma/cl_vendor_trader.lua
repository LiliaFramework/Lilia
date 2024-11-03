local PANEL = {}
function PANEL:Init()
    self.items = self:Add("DScrollPanel")
    self.items:Dock(FILL)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(40, 40, 40, 220)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(255, 255, 255, 50)
    surface.DrawOutlinedRect(0, 0, w, h)
end

vgui.Register("VendorTrader", PANEL, "DPanel")