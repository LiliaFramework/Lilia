local PANEL = {}
function PANEL:Init()
    self:MakePopup()
    self:Center()
    self:SetDraggable(true)
    self:SetTitle(L("inv"))
end

function PANEL:setInventory(inventory)
    self.inventory = inventory
    self:liaListenForInventoryChanges(inventory)
end

function PANEL:InventoryInitialized()
end

function PANEL:InventoryDataChanged()
end

function PANEL:InventoryDeleted(inventory)
    if self.inventory == inventory then self:Remove() end
end

function PANEL:InventoryItemAdded()
end

function PANEL:InventoryItemRemoved()
end

function PANEL:InventoryItemDataChanged()
end

function PANEL:OnRemove()
    self:liaDeleteInventoryHooks()
end

vgui.Register("liaInventory", PANEL, "DFrame")
PANEL = {}
function PANEL:Init()
    self:MakePopup()
    self.content = self:Add("liaGridInventoryPanel")
    self.content:Dock(FILL)
    self.content:setGridSize(1, 1)
    self:SetTitle("")
end

function PANEL:setInventory(inventory)
    self.gridW, self.gridH = inventory:getSize()
    local iconSize = self.content.size or 64
    local sidePadding = 5
    local topPadding = 30
    local bottomPadding = 5
    local titleHeight = self.GetTitleBarHeight and self:GetTitleBarHeight() or 22
    local contentHeight = self.gridH * (iconSize + 2)
    local totalWidth = self.gridW * (iconSize + 2) + sidePadding * 2
    local totalHeight = contentHeight + topPadding + bottomPadding + titleHeight
    self:SetSize(totalWidth, totalHeight)
    self:InvalidateLayout(true)
    self:DockPadding(sidePadding, topPadding, sidePadding, bottomPadding)
    self.content:setGridSize(self.gridW, self.gridH)
    self.content:setInventory(inventory)
end

function PANEL:InventoryDeleted()
    self:Remove()
end

function PANEL:Center()
    local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
    self:SetPos(centerX - self:GetWide() * 0.5, centerY - self:GetTall() * 0.5)
end

vgui.Register("liaGridInventory", PANEL, "liaInventory")