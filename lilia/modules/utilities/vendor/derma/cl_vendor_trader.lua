local PANEL = {}
function PANEL:Init()
    self.items = self:Add("DScrollPanel")
    self.items:Dock(FILL)
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, h)
end

vgui.Register("VendorTrader", PANEL, "DPanel")