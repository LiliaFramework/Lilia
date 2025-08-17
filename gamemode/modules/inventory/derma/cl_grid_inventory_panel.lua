local PANEL = {}
local function drawSlot(x, y, w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawOutlinedRect(x, y, w, h, 2)
    surface.SetDrawColor(0, 0, 0, 150)
    surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
end

function PANEL:Init()
    self:SetPaintBackground(false)
    self.icons = {}
    self:setGridSize(1, 1)
    self.occupied = {}
end

function PANEL:computeOccupied()
    if not self.inventory then return end
    self.occupied = {}
    for y = 0, self.gridH - 1 do
        local row = {}
        for x = 0, self.gridW - 1 do
            row[x] = false
        end

        self.occupied[y] = row
    end

    for _, item in pairs(self.inventory:getItems(true)) do
        local ix, iy = item:getData("x"), item:getData("y")
        if ix and iy then
            for offsetX = 0, item:getWidth() - 1 do
                for offsetY = 0, item:getHeight() - 1 do
                    local gx = ix + offsetX - 1
                    local gy = iy + offsetY - 1
                    if not self.occupied[gy] then self.occupied[gy] = {} end
                    self.occupied[gy][gx] = true
                end
            end
        end
    end
end

function PANEL:setInventory(inventory)
    self:liaListenForInventoryChanges(inventory)
    self.inventory = inventory
    self:populateItems()
end

function PANEL:setGridSize(width, height, iconSize)
    self.size = iconSize or 64
    self.gridW = width
    self.gridH = height
end

function PANEL:getIcons()
    return self.icons
end

function PANEL:removeIcon(icon)
    self.content:RemoveItem(icon)
end

function PANEL:onItemPressed(itemIcon, keyCode)
    if hook.Run("InterceptClickItemIcon", self, itemIcon, keyCode) ~= true then
        if keyCode == MOUSE_RIGHT then
            itemIcon:openActionMenu()
        elseif keyCode == MOUSE_LEFT then
            itemIcon:DragMousePress(keyCode)
            itemIcon:MouseCapture(true)
            lia.item.held = itemIcon
            lia.item.heldPanel = self
        end
    end
end

function PANEL:onItemReleased(itemIcon)
    local item = itemIcon.itemTable
    if not item then return end
    local x, y = self:LocalCursorPos()
    local size = self.size + 2
    local itemW = item:getWidth() * size - 2
    local itemH = item:getHeight() * size - 2
    x = math.Round((x - itemW * 0.5) / size) + 1
    y = math.Round((y - itemH * 0.5) / size) + 1
    self.inventory:requestTransfer(item:getID(), self.inventory:getID(), x, y)
    hook.Run("OnRequestItemTransfer", self, item:getID(), self.inventory:getID(), x, y)
end

function PANEL:populateItems()
    for key, icon in pairs(self.icons) do
        if IsValid(icon) then icon:Remove() end
        self.icons[key] = nil
    end

    for _, item in pairs(self.inventory:getItems(true)) do
        self:addItem(item)
    end

    self:computeOccupied()
end

function PANEL:addItem(item)
    local id = item:getID()
    local x, y = item:getData("x"), item:getData("y")
    if not x or not y then return end
    if IsValid(self.icons[id]) then self.icons[id]:Remove() end
    local size = self.size + 2
    local icon = self:Add("liaGridInvItem")
    icon:setItem(item)
    icon:SetPos((x - 1) * size, (y - 1) * size)
    icon:SetSize(item:getWidth() * size - 2, item:getHeight() * size - 2)
    icon:InvalidateLayout(true)
    icon.OnMousePressed = function(_, keyCode) self:onItemPressed(icon, keyCode) end
    icon.OnMouseReleased = function(_, keyCode)
        local heldPanel = lia.item.heldPanel
        if IsValid(heldPanel) then heldPanel:onItemReleased(icon, keyCode) end
        icon:DragMouseRelease(keyCode)
        icon:MouseCapture(false)
        lia.item.held = nil
        lia.item.heldPanel = nil
    end

    self.icons[id] = icon
    hook.Run("InventoryItemIconCreated", icon, item, self)
end

function PANEL:drawHeldItemRectangle()
    local held = lia.item.held
    if not IsValid(held) or not held.itemTable then return end
    local item = held.itemTable
    local size = self.size + 2
    local w = item:getWidth() * size - 2
    local h = item:getHeight() * size - 2
    local mx, my = self:LocalCursorPos()
    local x = math.Round((mx - w * 0.5) / size)
    local y = math.Round((my - h * 0.5) / size)
    if x < 0 or y < 0 or x + item:getWidth() > self.gridW or y + item:getHeight() > self.gridH then return end
    drawSlot(x * size, y * size, w, h)
end

function PANEL:computeHeldPanel()
    if not lia.item.held or lia.item.held == self then return end
    local cursorX, cursorY = self:LocalCursorPos()
    if cursorX < 0 or cursorY < 0 or cursorX > self:GetWide() or cursorY > self:GetTall() then return end
    lia.item.heldPanel = self
end

function PANEL:Paint()
    local size = self.size
    for y = 0, self.gridH - 1 do
        for x = 0, self.gridW - 1 do
            drawSlot(x * (size + 2), y * (size + 2), size, size)
        end
    end

    self:drawHeldItemRectangle()
    self:computeHeldPanel()
end

function PANEL:InventoryItemAdded()
    self:populateItems()
end

function PANEL:InventoryItemRemoved()
    self:populateItems()
end

function PANEL:InventoryItemDataChanged(item, key)
    if key == "rotated" then item.forceRender = true end
    self:populateItems()
end

function PANEL:OnCursorMoved()
end

function PANEL:OnCursorExited()
    if lia.item.heldPanel == self then lia.item.heldPanel = nil end
end

vgui.Register("liaGridInventoryPanel", PANEL, "DPanel")
