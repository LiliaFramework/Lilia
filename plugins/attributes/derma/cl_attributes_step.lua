-- Compatibility with the multichar charmenu plugin.

local PANEL = {}

-- How many clicks should be simulated if the add/subtract button is held down.
local AUTO_CLICK_TIME = 0.1

function PANEL:Init()
	self.title = self:addLabel("attributes")
	self.leftLabel = self:addLabel("points left")
	self.leftLabel:SetFont("liaCharSubTitleFont")

	self.total = hook.Run(
		"GetStartAttribPoints",
		LocalPlayer(),
		self:getContext()
	) or lia.config.get("maxAttribs", 30)
	self.attribs = {}

	for k, v in SortedPairsByMemberValue(lia.attribs.list, "name") do
		if (v.noStartBonus) then
			continue
		end
		self.attribs[k] = self:addAttribute(k, v)
	end
end

function PANEL:updatePointsLeft()
	self.leftLabel:SetText(L("points left"):upper()..": "..self.left)
end

function PANEL:onDisplay()
	local attribs = self:getContext("attribs", {})
	local sum = 0
	for _, quantity in pairs(attribs) do
		sum = sum + quantity
	end
	self.left = math.max(self.total - sum, 0)
	self:updatePointsLeft()

	for key, row in pairs(self.attribs) do
		row.points = attribs[key] or 0
		row:updateQuantity()
	end
end

function PANEL:addAttribute(key, attribute)
	local row = self:Add("liaCharacterAttribsRow")
	row:setAttribute(key, attribute)
	row.parent = self
	return row
end

function PANEL:onPointChange(key, delta)
	if (not key) then return 0 end
	local attribs = self:getContext("attribs", {})
	local startingMax = lia.attribs.list[key].startingMax or nil
	local quantity = attribs[key] or 0
	local newQuantity = quantity + delta
	local newPointsLeft = self.left - delta
	if (
		newPointsLeft < 0 or newPointsLeft > self.total or
		newQuantity < 0 or newQuantity > self.total or
		(startingMax and startingMax < newQuantity)
	) then
		return quantity
	end

	self.left = newPointsLeft
	self:updatePointsLeft()

	attribs[key] = newQuantity
	self:setContext("attribs", attribs)
	return newQuantity
end

vgui.Register("liaCharacterAttribs", PANEL, "liaCharacterCreateStep")

-- Child attribute "slider" component.
PANEL = {}

function PANEL:Init()
	self:Dock(TOP)
	self:DockMargin(0, 0, 0, 4)
	self:SetTall(36)
	self:SetPaintBackground(false)

	self.buttons = self:Add("DPanel")
	self.buttons:Dock(RIGHT)
	self.buttons:SetWide(128)
	self.buttons:SetPaintBackground(false)

	self.add = self:addButton("⯈", 1)
	self.add:Dock(RIGHT)

	self.sub = self:addButton("⯇", -1)
	self.sub:Dock(LEFT)

	self.quantity = self.buttons:Add("DLabel")
	self.quantity:SetFont("liaCharSubTitleFont")
	self.quantity:SetTextColor(color_white)
	self.quantity:Dock(FILL)
	self.quantity:SetText("0")
	self.quantity:SetContentAlignment(5)

	self.name = self:Add("DLabel")
	self.name:SetFont("liaCharSubTitleFont")
	self.name:SetContentAlignment(4)
	self.name:SetTextColor(lia.gui.character.WHITE)
	self.name:Dock(FILL)
	self.name:DockMargin(8, 0, 0, 0)
end

function PANEL:setAttribute(key, attribute)
	self.key = key
	local startingMax = lia.attribs.list[key].startingMax or nil
	self.name:SetText(L(attribute.name))
	self:SetTooltip(L(attribute.desc or "noDesc").. (startingMax and " Max: "..startingMax or ""))
end

function PANEL:delta(delta)
	if (IsValid(self.parent)) then
		local oldPoints = self.points
		self.points = self.parent:onPointChange(self.key, delta)
		self:updateQuantity()
		if (oldPoints ~= self.points) then
			LocalPlayer():EmitSound(unpack(SOUND_ATTRIBUTE_BUTTON))
		end
	end
end

function PANEL:addButton(symbol, delta)
	local button = self.buttons:Add("liaCharButton")
	button:SetFont("liaCharSubTitleFont")
	button:SetWide(32)
	button:SetText(symbol)
	button:SetContentAlignment(5)
	button.OnMousePressed = function(button)
		self.autoDelta = delta
		self.nextAuto = CurTime() + AUTO_CLICK_TIME
		self:delta(delta)
	end
	button.OnMouseReleased = function(button)
		self.autoDelta = nil
	end
	button:SetPaintBackground(false)
	return button
end

function PANEL:Think()
	local curTime = CurTime()
	if (self.autoDelta and (self.nextAuto or 0) < curTime) then
		self.nextAuto = CurTime() + AUTO_CLICK_TIME
		self:delta(self.autoDelta)
	end
end

function PANEL:updateQuantity()
	self.quantity:SetText(self.points)
end

function PANEL:Paint(w, h)
	lia.util.drawBlur(self)
	surface.SetDrawColor(0, 0, 0, 100)
	surface.DrawRect(0, 0, w, h)
end

vgui.Register("liaCharacterAttribsRow", PANEL, "DPanel")
