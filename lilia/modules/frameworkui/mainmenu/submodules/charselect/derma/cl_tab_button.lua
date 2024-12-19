local PANEL = {}
function PANEL:Init()
    self:Dock(TOP)
    self:DockMargin(0, 0, 0, 12)
    self:SetContentAlignment(5)
    self:SetTextColor(lia.gui.character.GOLD)
    self:SetTall(80)
end

function PANEL:setText(name)
    self:SetText(L(name):upper())
    self:SetFont("liaBigFont")
    self:InvalidateLayout(true)
    self:SizeToContentsX()
end

function PANEL:onSelected(callback)
    self.callback = callback
end

function PANEL:Paint(w, h)
    if self:IsHovered() then
        surface.SetDrawColor(lia.gui.character.SELECTED)
    else
        surface.SetDrawColor(Color(20, 15, 10, 80))
    end

    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(0, 0, w, h)
    surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
end

vgui.Register("liaCharacterTabButton", PANEL, "DButton")