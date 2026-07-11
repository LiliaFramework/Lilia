local PANEL = {}
local SLOT_GAP = 6
local SLOT_RADIUS = 6
local function getThemeColors()
    local theme = lia.color and lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    return accent, theme.text or Color(232, 240, 240)
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

local function drawSlot(x, y, w, h, highlighted)
    local accent = select(1, getThemeColors())
    local background = highlighted and Color(255, 255, 255, 7) or Color(2, 14, 18, 130)
    local outline = highlighted and Color(accent.r, accent.g, accent.b, 100) or Color(accent.r, accent.g, accent.b, 30)
    drawPanel(x, y, w, h, SLOT_RADIUS, background, outline)
end

local function getInventoryFrame(panel)
    local parent = panel:GetParent()
    while IsValid(parent) do
        if parent.setSelectedItem then return parent end
        parent = parent:GetParent()
    end
end

local function getDragOverlay(panel)
    local inventoryFrame = getInventoryFrame(panel)
    if not IsValid(inventoryFrame) then return vgui.GetWorldPanel() end
    local root = inventoryFrame:GetParent()
    return IsValid(root) and root or vgui.GetWorldPanel()
end

local function getItemSearchText(item)
    local values = {}
    local name = item.getName and item:getName()
    local desc = item.getDesc and item:getDesc()
    local category = item.category
    local uniqueID = item.uniqueID
    if name ~= nil then values[#values + 1] = tostring(name):lower() end
    if desc ~= nil then values[#values + 1] = tostring(desc):lower() end
    if category ~= nil then values[#values + 1] = tostring(category):lower() end
    if uniqueID ~= nil then values[#values + 1] = tostring(uniqueID):lower() end
    return table.concat(values, " ")
end

local function getItemDimensions(item, rotatedOverride)
    local rotated = rotatedOverride
    if rotated == nil then rotated = item:getData("rotated", false) end
    if rotated then return item.height or 1, item.width or 1 end
    return item.width or 1, item.height or 1
end

local function getIconRotatedState(icon)
    if not IsValid(icon) or not icon.itemTable then return end
    if icon.previewRotated ~= nil then return icon.previewRotated end
    return icon.itemTable:getData("rotated", false)
end

local function canItemFitAtPosition(inventory, item, x, y, itemWidth, itemHeight)
    if not inventory or not item then return false end
    local invW, invH = inventory:getSize()
    if x < 1 or y < 1 or x + itemWidth - 1 > invW or y + itemHeight - 1 > invH then return false end
    local x2 = x + itemWidth - 1
    local y2 = y + itemHeight - 1
    for _, otherItem in pairs(inventory:getItems(true)) do
        if otherItem ~= item then
            local otherX = otherItem:getData("x")
            local otherY = otherItem:getData("y")
            if otherX and otherY then
                local otherX2 = otherX + otherItem:getWidth() - 1
                local otherY2 = otherY + otherItem:getHeight() - 1
                if x <= otherX2 and otherX <= x2 and y <= otherY2 and otherY <= y2 then return false end
            end
        end
    end
    return true
end

function PANEL:Init()
    self:SetPaintBackground(false)
    self.icons = {}
    self.occupied = {}
    self.hoveredItem = nil
    self.selectedItem = nil
    self.searchQuery = ""
    self.filterCategory = nil
    self.gap = SLOT_GAP
    self:setGridSize(1, 1)
end

function PANEL:getStride()
    return self.size + self.gap
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
    self.size = iconSize or self.size or 64
    self.gridW = width
    self.gridH = height
    if self.inventory then self:relayoutItems() end
end

function PANEL:getGridPixelSize()
    local stride = self:getStride()
    return self.gridW * stride - self.gap, self.gridH * stride - self.gap
end

function PANEL:getIcons()
    return self.icons
end

function PANEL:removeIcon(icon)
    if not IsValid(icon) then return end
    for id, stored in pairs(self.icons) do
        if stored == icon then
            self.icons[id] = nil
            break
        end
    end

    icon:Remove()
end

function PANEL:setSearchQuery(value)
    self.searchQuery = string.Trim(tostring(value or "")):lower()
    self:applyFilters()
end

function PANEL:setFilterCategory(category)
    self.filterCategory = category and tostring(category) or nil
    self:applyFilters()
end

function PANEL:relayoutItems()
    local stride = self:getStride()
    local held = lia.item and lia.item.held
    for _, icon in pairs(self.icons) do
        if IsValid(icon) and icon.itemTable and icon ~= held then
            local item = icon.itemTable
            local x = tonumber(item:getData("x")) or 1
            local y = tonumber(item:getData("y")) or 1
            icon:setIconSize(self.size)
            icon:SetPos((x - 1) * stride, (y - 1) * stride)
            icon:SetSize(item:getWidth() * stride - self.gap, item:getHeight() * stride - self.gap)
            icon:InvalidateLayout(true)
        end
    end
end

function PANEL:applyFilters()
    local held = lia.item and lia.item.held
    for _, icon in pairs(self.icons) do
        if IsValid(icon) and icon.itemTable and icon ~= held then
            local item = icon.itemTable
            local queryMatch = self.searchQuery == "" or string.find(getItemSearchText(item), self.searchQuery, 1, true) ~= nil
            local category = tostring(item.category or "")
            local categoryMatch = not self.filterCategory or category == self.filterCategory
            icon:SetVisible(queryMatch and categoryMatch)
        end
    end

    self:relayoutItems()
end

function PANEL:setSelectedItem(icon)
    if self.selectedItem == icon then return end
    if IsValid(self.selectedItem) and self.selectedItem.setSelected then self.selectedItem:setSelected(false) end
    self.selectedItem = IsValid(icon) and icon or nil
    if IsValid(self.selectedItem) and self.selectedItem.setSelected then self.selectedItem:setSelected(true) end
    local frame = getInventoryFrame(self)
    if IsValid(frame) then frame:setSelectedItem(self.selectedItem) end
end

local tempAlreadyTherePos = {}
local function GetTargetPanel(originPanel)
    if IsValid(originPanel.pairedPanel) and originPanel.pairedPanel:IsVisible() and originPanel.pairedPanel.inventory then return originPanel.pairedPanel.inventory end
    local invOrigin = originPanel.inventory
    for _, panel in ipairs(vgui.GetAll()) do
        if panel:GetName() == "liaGridInventoryPanel" and panel:IsVisible() then
            local inv = panel.inventory
            if inv ~= invOrigin then return inv end
        end
    end
end

local function CustomFindFreePos(inv, item)
    local width, height = inv:getSize()
    for x = 1, width do
        for y = 1, height do
            if inv:doesItemFitAtPos(item, x, y) then
                local posKey = x .. "-" .. y
                if not tempAlreadyTherePos[posKey] then return x, y end
            end
        end
    end
end

function PANEL:rotateHeldItem(itemIcon)
    if not IsValid(itemIcon) or not itemIcon.itemTable then return end
    local item = itemIcon.itemTable
    local action = item.functions and item.functions.rotate
    if not action then return end
    item.player = LocalPlayer()
    if hook.Run("CanRunItemAction", item, "rotate") == false or isfunction(action.onCanRun) and not action.onCanRun(item) then
        item.player = nil
        return
    end

    itemIcon.previewRotated = not getIconRotatedState(itemIcon)
    self:updateDragPreview()
    item.player = nil
end

function PANEL:removeDragPreview()
    self.dragPreview = nil
end

function PANEL:updateDragPreview()
    local held = lia.item and lia.item.held
    if not IsValid(held) or lia.item.heldOriginPanel ~= self or not held.itemTable then return end
    local parent = held:GetParent()
    if not IsValid(parent) then return end
    local item = held.itemTable
    local stride = self:getStride()
    local itemWidth, itemHeight = getItemDimensions(item, getIconRotatedState(held))
    local width = itemWidth * stride - self.gap
    local height = itemHeight * stride - self.gap
    held:setIconSize(self.size)
    held:SetSize(width, height)
    held:InvalidateLayout(true)
    local mouseX, mouseY = gui.MousePos()
    if parent ~= vgui.GetWorldPanel() then mouseX, mouseY = parent:ScreenToLocal(mouseX, mouseY) end
    held:SetPos(math.floor(mouseX - width * 0.5), math.floor(mouseY - height * 0.5))
    held:SetZPos(32767)
    if held.SetDrawOnTop then held:SetDrawOnTop(true) end
    held:MoveToFront()
end

function PANEL:startDraggingItem(itemIcon)
    if not IsValid(itemIcon) or not itemIcon.itemTable then return end
    local currentHeld = lia.item and lia.item.held
    if IsValid(currentHeld) then return end
    local dragLayer = getDragOverlay(self)
    itemIcon:SetParent(dragLayer)
    itemIcon:SetMouseInputEnabled(false)
    itemIcon:SetKeyboardInputEnabled(false)
    itemIcon:SetAlpha(255)
    itemIcon:SetVisible(true)
    itemIcon.isDragPreview = true
    itemIcon:SetZPos(32767)
    if itemIcon.SetDrawOnTop then itemIcon:SetDrawOnTop(true) end
    itemIcon:MoveToFront()
    lia.item.held = itemIcon
    lia.item.heldOriginPanel = self
    lia.item.heldPanel = self
    self.dragPreview = itemIcon
    self.dragMouseWasDown = true
    self:updateDragPreview()
end

function PANEL:finishDraggingItem(itemIcon)
    if IsValid(itemIcon) then
        itemIcon:SetParent(self)
        itemIcon.previewRotated = nil
        itemIcon.isDragPreview = nil
        itemIcon:SetMouseInputEnabled(true)
        itemIcon:SetKeyboardInputEnabled(false)
        itemIcon:SetAlpha(255)
        itemIcon:SetVisible(true)
        itemIcon:SetZPos(0)
        if itemIcon.SetDrawOnTop then itemIcon:SetDrawOnTop(false) end
    end

    self.dragPreview = nil
    self.dragMouseWasDown = nil
    lia.item.held = nil
    lia.item.heldOriginPanel = nil
    lia.item.heldPanel = nil
    self:applyFilters()
end

function PANEL:releaseHeldItem(itemIcon)
    local targetPanel = lia.item and lia.item.heldPanel
    if IsValid(targetPanel) then targetPanel:onItemReleased(itemIcon) end
    self:finishDraggingItem(itemIcon)
end

function PANEL:onItemPressed(itemIcon, keyCode)
    self:setSelectedItem(itemIcon)
    if keyCode == MOUSE_RIGHT then
        if not IsValid(itemIcon) or not itemIcon.itemTable then return end
        local frame = getInventoryFrame(self)
        if IsValid(frame) and frame.openItemActionMenu then
            frame:openItemActionMenu(itemIcon.itemTable)
        elseif itemIcon.openActionMenu then
            itemIcon:openActionMenu()
        end
        return
    end

    if hook.Run("InterceptClickItemIcon", self, itemIcon, keyCode) == true then return end
    if keyCode == MOUSE_LEFT and input.IsShiftDown() then
        if not itemIcon or not itemIcon.itemTable then return end
        local item = itemIcon.itemTable
        local targetInv = GetTargetPanel(self)
        if not targetInv then return end
        local x, y = CustomFindFreePos(targetInv, item)
        if not x or not y then return end
        for i = 0, item:getWidth() - 1 do
            for j = 0, item:getHeight() - 1 do
                local posKey = (x + i) .. "-" .. (y + j)
                tempAlreadyTherePos[posKey] = true
                timer.Simple(2, function() tempAlreadyTherePos[posKey] = nil end)
            end
        end

        targetInv:requestTransfer(item:getID(), targetInv:getID(), x, y)
    elseif keyCode == MOUSE_LEFT then
        self:startDraggingItem(itemIcon)
    end
end

function PANEL:onItemReleased(itemIcon)
    local item = itemIcon.itemTable
    if not item then return end
    local cursorX, cursorY = self:LocalCursorPos()
    local panelW, panelH = self:GetSize()
    if cursorX < 0 or cursorY < 0 or cursorX > panelW or cursorY > panelH then return end
    local stride = self:getStride()
    local rotated = getIconRotatedState(itemIcon)
    local itemWidth, itemHeight = getItemDimensions(item, rotated)
    local itemW = itemWidth * stride - self.gap
    local itemH = itemHeight * stride - self.gap
    local x = math.Round((cursorX - itemW * 0.5) / stride) + 1
    local y = math.Round((cursorY - itemH * 0.5) / stride) + 1
    if not canItemFitAtPosition(self.inventory, item, x, y, itemWidth, itemHeight) then return end
    self.inventory:requestTransfer(item:getID(), self.inventory:getID(), x, y, rotated)
    hook.Run("OnRequestItemTransfer", self, item:getID(), self.inventory:getID(), x, y)
end

function PANEL:populateItems()
    local selectedID = IsValid(self.selectedItem) and self.selectedItem.itemTable and self.selectedItem.itemTable:getID()
    for id, icon in pairs(self.icons) do
        if IsValid(icon) then icon:Remove() end
        self.icons[id] = nil
    end

    self.selectedItem = nil
    for _, item in pairs(self.inventory:getItems(true)) do
        self:addItem(item)
    end

    self:computeOccupied()
    self:applyFilters()
    if selectedID and IsValid(self.icons[selectedID]) then self:setSelectedItem(self.icons[selectedID]) end
end

function PANEL:addItem(item)
    local id = item:getID()
    local x, y = item:getData("x"), item:getData("y")
    if not x or not y then return end
    if IsValid(self.icons[id]) then self.icons[id]:Remove() end
    local stride = self:getStride()
    local icon = self:Add("liaGridInvItem")
    icon:setIconSize(self.size)
    icon:setItem(item)
    icon:SetPos((x - 1) * stride, (y - 1) * stride)
    icon:SetSize(item:getWidth() * stride - self.gap, item:getHeight() * stride - self.gap)
    icon:InvalidateLayout(true)
    icon.OnMousePressed = function(_, keyCode) self:onItemPressed(icon, keyCode) end
    icon.OnMouseReleased = function(_, keyCode)
        if keyCode ~= MOUSE_LEFT then return end
        if lia.item and lia.item.held == icon and lia.item.heldOriginPanel == self then self:releaseHeldItem(icon) end
    end

    icon.OnCursorEntered = function()
        self.hoveredItem = icon
        icon.Hovered = true
    end

    icon.OnCursorExited = function()
        if self.hoveredItem == icon then self.hoveredItem = nil end
        icon.Hovered = false
    end

    self.icons[id] = icon
    hook.Run("InventoryItemIconCreated", icon, item, self)
end

function PANEL:Think()
    local rotateDown = input.IsKeyDown(KEY_R)
    local held = lia.item and lia.item.held
    if IsValid(held) and lia.item.heldOriginPanel == self then
        self:updateDragPreview()
        if rotateDown and not self.rotateKeyDown then self:rotateHeldItem(held) end
        local mouseDown = input.IsMouseDown(MOUSE_LEFT)
        if self.dragMouseWasDown and not mouseDown then
            self:releaseHeldItem(held)
            self.rotateKeyDown = rotateDown
            return
        end

        self.dragMouseWasDown = mouseDown
    end

    self.rotateKeyDown = rotateDown
end

function PANEL:drawHeldItemRectangle()
    local held = lia.item and lia.item.held
    if not IsValid(held) or not held.itemTable then return end
    if lia.item.heldPanel ~= self then return end
    local item = held.itemTable
    local stride = self:getStride()
    local itemWidth, itemHeight = getItemDimensions(item, getIconRotatedState(held))
    local w = itemWidth * stride - self.gap
    local h = itemHeight * stride - self.gap
    local mx, my = self:LocalCursorPos()
    local x = math.Round((mx - w * 0.5) / stride)
    local y = math.Round((my - h * 0.5) / stride)
    if not canItemFitAtPosition(self.inventory, item, x + 1, y + 1, itemWidth, itemHeight) then return end
    drawSlot(x * stride, y * stride, w, h, true)
end

function PANEL:computeHeldPanel()
    local held = lia.item and lia.item.held
    if not IsValid(held) then return end
    local cursorX, cursorY = self:LocalCursorPos()
    if cursorX < 0 or cursorY < 0 or cursorX > self:GetWide() or cursorY > self:GetTall() then return end
    lia.item.heldPanel = self
end

function PANEL:Paint()
    local stride = self:getStride()
    for y = 0, self.gridH - 1 do
        for x = 0, self.gridW - 1 do
            drawSlot(x * stride, y * stride, self.size, self.size, false)
        end
    end

    self:computeHeldPanel()
    self:drawHeldItemRectangle()
end

function PANEL:InventoryItemAdded()
    self:populateItems()
end

function PANEL:InventoryItemRemoved()
    self:populateItems()
end

function PANEL:InventoryItemDataChanged(item, key)
    local icon = self.icons[item:getID()]
    local held = lia.item and lia.item.held
    local isHeld = IsValid(icon) and held == icon and lia.item.heldOriginPanel == self
    if key == "rotated" then
        item.forceRender = true
        if IsValid(icon) then
            icon.itemTable = item
            icon:setIconSize(self.size)
            local stride = self:getStride()
            icon:SetSize(item:getWidth() * stride - self.gap, item:getHeight() * stride - self.gap)
            if icon.ItemDataChanged then icon:ItemDataChanged(item, key) end
            icon:InvalidateLayout(true)
            self:computeOccupied()
            if isHeld then
                self:updateDragPreview()
            else
                self:applyFilters()
            end
            return
        end
    end

    if isHeld then
        icon.itemTable = item
        if icon.ItemDataChanged then icon:ItemDataChanged(item, key) end
        return
    end

    self:populateItems()
end

function PANEL:OnCursorMoved()
end

function PANEL:OnCursorExited()
    if lia.item.heldPanel == self then lia.item.heldPanel = nil end
    self.hoveredItem = nil
end

function PANEL:OnRemove()
    local held = lia.item and lia.item.held
    if IsValid(held) and lia.item.heldOriginPanel == self then held:Remove() end
    self.dragPreview = nil
    lia.item.held = nil
    lia.item.heldOriginPanel = nil
    lia.item.heldPanel = nil
end

vgui.Register("liaGridInventoryPanel", PANEL, "DPanel")
