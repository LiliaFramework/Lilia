local PANEL = {}
local InvSlotMat = Material("invslotfree.png", "smooth noclamp")
local renderedIcons = renderedIcons or {}
function renderNewIcon(panel, itemTable)
    if itemTable.iconCam and not renderedIcons[string.lower(itemTable.model)] or itemTable.forceRender then
        local iconCam = itemTable.iconCam
        iconCam = {
            cam_pos = iconCam.pos,
            cam_ang = iconCam.ang,
            cam_fov = iconCam.fov,
        }

        renderedIcons[string.lower(itemTable.model)] = true
        panel.Icon:RebuildSpawnIconEx(iconCam)
    end
end

local function drawIcon(mat, _, x, y)
    surface.SetDrawColor(color_white)
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, x, y)
end

function PANEL:setItemType(itemTypeOrID)
    local item = lia.item.list[itemTypeOrID]
    if isnumber(itemTypeOrID) then
        item = lia.item.instances[itemTypeOrID]
        self.itemID = itemTypeOrID
    else
        self.itemType = itemTypeOrID
    end

    assert(item, "invalid item type or ID " .. tostring(item))
    self.liaToolTip = true
    self.itemTable = item
    self:SetModel(item:getModel(), item:getSkin())
    self:updateTooltip()
    if item.icon then
        self.Icon:SetVisible(false)
        self.ExtraPaint = function(self, w, h) drawIcon(item.icon, self, w, h) end
    else
        renderNewIcon(self, item)
    end
end

function PANEL:updateTooltip()
    self:SetTooltip("<font=liaItemBoldFont>" .. self.itemTable:getName() .. "</font>\n" .. "<font=liaItemDescFont>" .. self.itemTable:getDesc())
end

function PANEL:getItem()
    return self.itemTable
end

function PANEL:ItemDataChanged()
    self:updateTooltip()
end

function PANEL:Init()
    self:Droppable("inv")
    self:SetSize(64, 64)
end

function PANEL:PaintOver(w, h)
    local itemTable = lia.item.instances[self.itemID]
    if itemTable and itemTable.paintOver then
        w, h = self:GetSize()
        itemTable.paintOver(self, itemTable, w, h)
    end

    hook.Run("ItemPaintOver", self, itemTable, w, h)
end

function PANEL:PaintBehind(w, h)
    surface.SetDrawColor(0, 0, 0, 85)
    surface.DrawRect(2, 2, w - 4, h - 4)
end

function PANEL:ExtraPaint()
end

function PANEL:Paint(w, h)
    self:PaintBehind(w, h)
    self:ExtraPaint(w, h)
end

local buildActionFunc = function(action, actionIndex, itemTable, invID, sub)
    return function()
        itemTable.player = LocalPlayer()
        local send = true
        if action.onClick then send = action.onClick(itemTable, sub and sub.data) end
        local snd = action.sound or SOUND_INVENTORY_INTERACT
        if snd then
            if istable(snd) then
                LocalPlayer():EmitSound(unpack(snd))
            elseif isstring(snd) then
                surface.PlaySound(snd)
            end
        end

        if send ~= false then netstream.Start("invAct", actionIndex, itemTable.id, invID, sub and sub.data) end
        itemTable.player = nil
    end
end

function PANEL:openActionMenu()
    local itemTable = self.itemTable
    assert(itemTable, "attempt to open action menu for invalid item")
    itemTable.player = LocalPlayer()
    local menu = DermaMenu()
    local override = hook.Run("OnCreateItemInteractionMenu", self, menu, itemTable)
    if override then
        if IsValid(menu) then menu:Remove() end
        return
    end

    for k, v in SortedPairs(itemTable.functions) do
        if hook.Run("CanRunItemAction", itemTable, k) == false or isfunction(v.onCanRun) and not v.onCanRun(itemTable) then continue end
        if v.isMulti then
            local subMenu, subMenuOption = menu:AddSubMenu(L(v.name or k), buildActionFunc(v, k, itemTable, self.invID))
            subMenuOption:SetImage(v.icon or "icon16/brick.png")
            if not v.multiOptions then return end
            local options = isfunction(v.multiOptions) and v.multiOptions(itemTable, LocalPlayer()) or v.multiOptions
            for _, sub in pairs(options) do
                subMenu:AddOption(L(sub.name or "subOption"), buildActionFunc(v, k, itemTable, self.invID, sub)):SetImage(sub.icon or "icon16/brick.png")
            end
        else
            menu:AddOption(L(v.name or k), buildActionFunc(v, k, itemTable, self.invID)):SetImage(v.icon or "icon16/brick.png")
        end
    end

    menu:Open()
    itemTable.player = nil
end

vgui.Register("liaItemIcon", PANEL, "SpawnIcon")
PANEL = {}
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
    self:SetSize(self.gridW * (64 + 2) + 4 * 2, self.gridH * (64 + 2) + 22 + 4 * 2)
    self:InvalidateLayout(true)
    self.content:setGridSize(self.gridW, self.gridH)
    self.content:setInventory(inventory)
    self.content.InventoryDeleted = function(_, deletedInventory) if deletedInventory == inventory then self:InventoryDeleted() end end
end

function PANEL:InventoryDeleted()
    self:Remove()
end

function PANEL:Center()
    local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
    self:SetPos(centerX - self:GetWide() * 0.5, centerY - self:GetTall() * 0.5)
end

vgui.Register("liaGridInventory", PANEL, "liaInventory")
local PANEL = {}
function PANEL:Init()
    self.size = 64
end

function PANEL:setIconSize(size)
    self.size = size
end

function PANEL:setItem(item)
    self.Icon:SetSize(self.size * (item.width or 1), self.size * (item.height or 1))
    self.Icon:InvalidateLayout(true)
    self:setItemType(item:getID())
    self:centerIcon()
end

function PANEL:centerIcon(w, h)
    w = w or self:GetWide()
    h = h or self:GetTall()
    local iconW, iconH = self.Icon:GetSize()
    self.Icon:SetPos((w - iconW) * 0.5, (h - iconH) * 0.5)
end

function PANEL:PaintBehind()
end

function PANEL:PerformLayout(w, h)
    self:centerIcon(w, h)
end

vgui.Register("liaGridInvItem", PANEL, "liaItemIcon")
local PANEL = {}
function PANEL:Init()
    self:SetPaintBackground(false)
    self.icons = {}
    self:setGridSize(1, 1)
    self.occupied = {}
end

function PANEL:computeOccupied()
    if not self.inventory then return end
    for y = 0, self.gridH do
        self.occupied[y] = {}
        for x = 0, self.gridW do
            self.occupied[y][x] = false
        end
    end

    for _, item in pairs(self.inventory:getItems(true)) do
        local x, y = item:getData("x"), item:getData("y")
        if not x then continue end
        for offsetX = 0, (item.width or 1) - 1 do
            for offsetY = 0, (item.height or 1) - 1 do
                self.occupied[y + offsetY - 1][x + offsetX - 1] = true
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
    local itemW = (item.width or 1) * size - 2
    local itemH = (item.height or 1) * size - 2
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
    icon:SetSize((item.width or 1) * size - 2, (item.height or 1) * size - 2)
    icon:InvalidateLayout(true)
    icon.OnMousePressed = function(icon, keyCode) self:onItemPressed(icon, keyCode) end
    icon.OnMouseReleased = function(icon, keyCode)
        local heldPanel = lia.item.heldPanel
        if IsValid(heldPanel) then heldPanel:onItemReleased(icon, keyCode) end
        icon:DragMouseRelease(keyCode)
        icon:MouseCapture(false)
        lia.item.held = nil
        lia.item.heldPanel = nil
    end

    self.icons[id] = icon
end

function PANEL:drawHeldItemRectangle()
    local held = lia.item.held
    if not IsValid(held) or not held.itemTable then return end
    local item = held.itemTable
    local size = self.size + 2
    local w = (item.width or 1) * size - 2
    local h = (item.height or 1) * size - 2
    local mx, my = self:LocalCursorPos()
    local x = math.Round((mx - w * 0.5) / size)
    local y = math.Round((my - h * 0.5) / size)
    if x < 0 or y < 0 or x + (item.width or 1) > self.gridW or y + (item.height or 1) > self.gridH then return end
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(InvSlotMat)
    surface.DrawTexturedRect(x * size, y * size, w, h)
end

function PANEL:Center()
    local centerX, centerY = ScrW() * 0.5, ScrH() * 0.5
    self:SetPos(centerX - self:GetWide() * 0.5, centerY - self:GetTall() * 0.5)
end

function PANEL:InventoryItemAdded()
    self:populateItems()
end

function PANEL:InventoryItemRemoved()
    self:populateItems()
end

function PANEL:InventoryItemDataChanged()
    self:populateItems()
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
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(InvSlotMat)
            surface.DrawTexturedRect(x * (size + 2), y * (size + 2), size, size)
        end
    end

    self:drawHeldItemRectangle()
    self:computeHeldPanel()
end

function PANEL:OnCursorMoved()
end

function PANEL:OnCursorExited()
    if lia.item.heldPanel == self then lia.item.heldPanel = nil end
end

vgui.Register("liaGridInventoryPanel", PANEL, "DPanel")
local margin = 10
hook.Add("CreateMenuButtons", "liaInventory", function(tabs)
    if hook.Run("CanPlayerViewInventory") == false then return end
    tabs["inv"] = function(panel)
        local inventory = LocalPlayer():getChar():getInv()
        if not inventory then return end
        local mainPanel = inventory:show(panel)
        local sortPanels = {}
        local totalSize = {
            x = 0,
            y = 0,
            p = 0
        }

        table.insert(sortPanels, mainPanel)
        totalSize.x = totalSize.x + mainPanel:GetWide() + margin
        totalSize.y = math.max(totalSize.y, mainPanel:GetTall())
        for _, item in pairs(inventory:getItems()) do
            if item.isBag and hook.Run("CanOpenBagPanel", item) ~= false then
                local inventory = item:getInv()
                local childPanels = inventory:show(mainPanel)
                lia.gui["inv" .. inventory:getID()] = childPanels
                table.insert(sortPanels, childPanels)
                totalSize.x = totalSize.x + childPanels:GetWide() + margin
                totalSize.y = math.max(totalSize.y, childPanels:GetTall())
            end
        end

        local px, py, pw, ph = mainPanel:GetBounds()
        local x, y = px + pw / 2 - totalSize.x / 2, py + ph / 2
        for _, panel in pairs(sortPanels) do
            panel:ShowCloseButton(false)
            panel:SetPos(x, y - panel:GetTall() / 2)
            x = x + panel:GetWide() + margin
        end

        hook.Add("PostRenderVGUI", mainPanel, function() hook.Run("PostDrawInventory", mainPanel, panel) end)
    end
end)