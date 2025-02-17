local PANEL = {}
function PANEL:Init()
	self:Dock(FILL)
	self:DockMargin(0, 64, 0, 0)
	self:InvalidateParent(true)
	self:InvalidateLayout(true)
	self.panels = {}
	self.scroll = self:Add("liaHorizontalScroll")
	self.scroll:Dock(FILL)
	local scrollBar = self.scroll:GetHBar()
	scrollBar:SetTall(8)
	scrollBar:SetHideButtons(true)
	scrollBar.Paint = function(scroll, w, h)
		surface.SetDrawColor(255, 255, 255, 10)
		surface.DrawRect(0, 0, w, h)
	end

	scrollBar.btnGrip.Paint = function(grip, w, h)
		local alpha = 50
		if scrollBar.Dragging then
			alpha = 150
		elseif grip:IsHovered() then
			alpha = 100
		end

		surface.SetDrawColor(255, 255, 255, alpha)
		surface.DrawRect(0, 0, w, h)
	end

	self:createCharacterSlots()
	hook.Add("CharacterListUpdated", self, function() self:createCharacterSlots() end)
end

function PANEL:createCharacterSlots()
	self.scroll:Clear()
	if #lia.characters == 0 then return lia.gui.character:showContent() end
	local totalWide = 0
	for _, id in ipairs(lia.characters) do
		local character = lia.char.loaded[id]
		if not character then continue end
		local parentPanel = self.scroll:Add("DPanel")
		parentPanel:Dock(LEFT)
		parentPanel:DockMargin(0, 0, 8, 8)
		parentPanel:SetPaintBackground(false)
		local slotPanel = parentPanel:Add("liaCharacterSlot")
		slotPanel:Dock(LEFT)
		slotPanel:setCharacter(character)
		slotPanel.onSelected = function(panel) self:onCharacterSelected(character) end
		parentPanel:SetWide(slotPanel:GetWide())
		totalWide = totalWide + parentPanel:GetWide() + 8
	end

	totalWide = totalWide - 8
	self.scroll:SetWide(self:GetWide())
	self.scroll:DockMargin(math.max(0, self.scroll:GetWide() * 0.5 - totalWide * 0.5), 0, 0, 0)
end

function PANEL:onCharacterSelected(character)
	if self.choosing then return end
	if character == LocalPlayer():getChar() then return lia.gui.character:fadeOut() end
	self.choosing = true
	lia.gui.character:setFadeToBlack(true):next(function() return MainMenu:chooseCharacter(character:getID()) end):next(function(err)
		self.choosing = false
		if IsValid(lia.gui.character) then
			timer.Simple(0.25, function()
				if not IsValid(lia.gui.character) then return end
				lia.gui.character:setFadeToBlack(false)
				lia.gui.character:Remove()
			end)
		end
	end, function(err)
		self.choosing = false
		lia.gui.character:setFadeToBlack(false)
		lia.util.notifyLocalized(err)
	end)
end

vgui.Register("liaCharacterSelection", PANEL, "EditablePanel")