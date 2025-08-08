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
local function headerHeight(f)
    return IsValid(f.btnClose) and f.btnClose:GetTall() + 4 or 24
end

function PANEL:Init()
    self:MakePopup()
    self.content = self:Add("liaGridInventoryPanel")
    self.content:Dock(FILL)
    self:SetTitle("")
end

function PANEL:setInventory(inv)
    self.gridW, self.gridH = inv:getSize()
    local size = self.content.size or 64
    local gap = 2
    local pad = 4
    local head = headerHeight(self)
    local w = self.gridW * size + (self.gridW - 1) * gap + pad * 2
    local h = self.gridH * size + (self.gridH - 1) * gap + pad * 2 + head
    self:SetSize(w, h)
    self:DockPadding(pad, head + pad, pad, pad)
    self.content:setGridSize(self.gridW, self.gridH, size)
    self.content:setInventory(inv)
end

function PANEL:InventoryDeleted()
    self:Remove()
end

function PANEL:Center()
    self:SetPos(ScrW() * 0.5 - self:GetWide() * 0.5, ScrH() * 0.5 - self:GetTall() * 0.5)
end

vgui.Register("liaGridInventory", PANEL, "liaInventory")