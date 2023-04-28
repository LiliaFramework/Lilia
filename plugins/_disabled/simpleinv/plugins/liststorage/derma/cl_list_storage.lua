local PANEL = {}

local BORDER_FIX_W = 8
local PADDING = 4

function PANEL:Init()
	if (IsValid(lia.gui.storage)) then
		lia.gui.storage:Remove()
	end
	lia.gui.storage = self

	self.gridW = lia.config.get("invW")
	local width = self.gridW * (LIA_ICON_SIZE + PADDING)

	self:SetSize(width * 2 + BORDER_FIX_W, ScrH() * 0.6)
	self:MakePopup()
	self:Center()

	local sideWidth = self:GetWide() / 2 - 7

	self.labels = self:Add("DPanel")
	self.labels:Dock(TOP)
	self.labels:SetTall(36)
	self.labels:SetPaintBackground(false)

	self.storageLabel = self.labels:Add("DLabel")
	self.storageLabel:SetFont("liaMediumFont")
	self.storageLabel:SetText(L"Storage")
	self.storageLabel:SetWide(sideWidth)
	self.storageLabel:Dock(LEFT)
	self.storageLabel:SetTextColor(color_white)
	self.storageLabel:SetPaintBackground(false)

	self.invLabel = self.labels:Add("DLabel")
	self.invLabel:SetFont("liaMediumFont")
	self.invLabel:SetText(L"inv")
	self.invLabel:SetWide(sideWidth)
	self.invLabel:Dock(LEFT)
	self.invLabel:SetTextColor(color_white)
	self.invLabel:DockMargin(4, 0, 0, 0)

	self.storagePane = self:Add("DPanel")
	self.storagePane:Dock(LEFT)
	self.storagePane:SetWide(sideWidth)

	self.invPane = self:Add("DPanel")
	self.invPane:Dock(RIGHT)
	self.invPane:SetWide(sideWidth)
end

function PANEL:OnRemove()
	self:liaDeleteInventoryHooks()
	liaStorageBase:exitStorage()
end

function PANEL:setStorage(storage)
	-- Clean up old storage if one exists.
	if (IsValid(self.storage)) then
		self.storage:RemoveCallOnRemove("ListStorageView")
	end

	-- Quick local player and storage validation.
	local bad = not IsValid(storage)
	local character = LocalPlayer():getChar()
	if (not bad and not storage:getInv()) then
		bad = true
	end
	if (not character) then
		bad = true
	elseif (not character:getInv()) then
		bad = true
	end
	if (bad) then return self:Remove() end
	local inventory = character:getInv()

	-- Store the given storage entity.
	self.storage = storage
	storage:CallOnRemove("ListStorageView", function()
		if (IsValid(self)) then self:Remove() end
	end)

	-- Update the name of the storage labels.
	local name = L(storage:getStorageInfo().name or "Storage")
	self:SetTitle(name)
	self.storageLabel:SetText(name)

	-- Then set up the inventory views.
	self.storageInv = self.storagePane:Add("liaListInventoryPanel")
	self.storageInv:Dock(FILL)
	self.storageInv:setColumns(self.gridW)
	self.storageInv:setInventory(storage:getInv())
	self.storageInv:DockMargin(4, 4, 4, 4)
	self.storageInv.onItemPressed = function(panel, itemIcon, keyCode)
		self:onItemPressed(itemIcon.itemID)
	end

	self.localInv = self.invPane:Add("liaListInventoryPanel")
	self.localInv:Dock(FILL)
	self.localInv:setColumns(self.gridW)
	self.localInv:setInventory(inventory)
	self.localInv:DockMargin(4, 4, 4, 4)
	self.localInv.onItemPressed = function(panel, itemIcon, keyCode)
		self:onItemPressed(itemIcon.itemID)
	end
end

function PANEL:onItemPressed(itemID)
	liaStorageBase:transferItem(itemID)
end

vgui.Register("liaListStorage", PANEL, "DFrame")

if (IsValid(lia.gui.storage)) then
	local storage = lia.gui.storage.storage
	vgui.Create("liaListStorage"):setStorage(storage)
end
