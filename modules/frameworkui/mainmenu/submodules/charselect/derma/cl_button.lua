local PANEL = {}
function PANEL:Init()
    self:SetFont("liaCharButtonFont")
    self:SizeToContentsY()
    self:SetTextColor(lia.gui.character.color)
    self:SetPaintBackground(false)
end

function PANEL:OnCursorEntered()
    lia.gui.character:hoverSound()
    self:SetTextColor(lia.gui.character.colorHovered)
end

function PANEL:OnCursorExited()
    self:SetTextColor(lia.gui.character.color)
end

function PANEL:OnMousePressed()
    lia.gui.character:clickSound()
    DButton.OnMousePressed(self)
end

vgui.Register("liaCharButton", PANEL, "DButton")
