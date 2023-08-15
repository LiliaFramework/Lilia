local PANEL = {}

function PANEL:Init()
	self:SetFont("liaCharButtonFont")
	self:SizeToContentsY()
	self:SetTextColor(lia.gui.character.WHITE)
	self:SetPaintBackground(false)
end

function PANEL:OnCursorEntered()
	lia.gui.character:hoverSound()
	self:SetTextColor(lia.gui.character.HOVERED)
end

function PANEL:OnCursorExited()
	self:SetTextColor(lia.gui.character.WHITE)
end

function PANEL:OnMousePressed()
	lia.gui.character:clickSound()
	DButton.OnMousePressed(self)
end

vgui.Register("liaCharButton", PANEL, "DButton")
