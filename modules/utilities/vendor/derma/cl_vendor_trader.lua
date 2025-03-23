local PANEL = {}
function PANEL:Init()
    self.items = self:Add("DScrollPanel")
    self.items:Dock(FILL)
end

vgui.Register("VendorTrader", PANEL, "DPanel")