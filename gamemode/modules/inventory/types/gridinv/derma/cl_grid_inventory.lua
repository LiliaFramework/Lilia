local function headerHeight(frame)
    return IsValid(frame.btnClose) and frame.btnClose:GetTall() + 4 or 24
end

local function getThemeColors()
    local theme = lia.color and lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    return accent, theme.text or Color(232, 240, 240)
end

local function drawPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

local function getItemCondition(item)
    if not item.getData then return end
    local value = item:getData("condition")
    if value == nil then value = item:getData("durability") end
    if value == nil then value = item:getData("health") end
    value = tonumber(value)
    if not value then return end
    if value <= 1 then value = value * 100 end
    return math.Clamp(math.Round(value), 0, 100)
end

local function styleButton(button, primary)
    button:SetTextColor(Color(232, 240, 240))
    button:SetFont("LiliaFont.18")
    button.Paint = function(self, w, h)
        local accent, textColor = getThemeColors()
        local hovered = self:IsHovered()
        if primary then
            local background = hovered and Color(accent.r, accent.g, accent.b, 235) or Color(accent.r, accent.g, accent.b, 205)
            drawPanel(0, 0, w, h, 6, background, Color(accent.r, accent.g, accent.b, 255))
            self:SetTextColor(Color(7, 19, 22))
        else
            local background = hovered and Color(255, 255, 255, 7) or Color(2, 14, 18, 130)
            drawPanel(0, 0, w, h, 5, background, Color(accent.r, accent.g, accent.b, hovered and 100 or 42))
            self:SetTextColor(textColor)
        end
    end
end

local PRIMARY_TEXT = Color(232, 240, 240)
local SECONDARY_TEXT = Color(165, 187, 188)
local GRID_PANEL_PADDING = 12
local GRID_HEADER_HEIGHT = 54
local FRAME = {}
function FRAME:Init()
    self.content = self:Add("liaGridInventoryPanel")
    self.content:Dock(FILL)
    self.restoreBtn = self:Add("DButton")
    self.restoreBtn:Dock(BOTTOM)
    self.restoreBtn:SetVisible(false)
    self.restoreBtn:SetTall(44)
    self.restoreBtn:DockMargin(0, 4, 0, 0)
    styleButton(self.restoreBtn, false)
    self.restoreBtn.DoClick = function()
        net.Start("liaRestoreOverflowItems")
        net.SendToServer()
    end

    self:SetTitle("")
end

function FRAME:setInventory(inv)
    self.gridW, self.gridH = inv:getSize()
    local size = self.content.size or 64
    local gap = self.content.gap or 6
    local pad = 4
    local head = headerHeight(self)
    local w = self.gridW * size + (self.gridW - 1) * gap + pad * 2
    local h = self.gridH * size + (self.gridH - 1) * gap + pad * 2 + head
    self:SetSize(w, h)
    self.baseHeight = h
    self:DockPadding(pad, head + pad, pad, pad)
    self.content:setGridSize(self.gridW, self.gridH, size)
    self.content:setInventory(inv)
    self:updateRestoreButton()
end

function FRAME:InventoryDeleted()
    self:Remove()
end

function FRAME:Center()
    self:SetPos(ScrW() * 0.5 - self:GetWide() * 0.5, ScrH() * 0.5 - self:GetTall() * 0.5)
end

function FRAME:updateRestoreButton()
    local char = LocalPlayer():getChar()
    local data = char and char:getData("overflowItems")
    if data and data.items and #data.items > 0 then
        local size = data.size or {}
        self.restoreBtn:SetText(L("moveItemsBack", size[1] or 0, size[2] or 0))
        self.restoreBtn:SetVisible(true)
        self:SetTall(self.baseHeight + self.restoreBtn:GetTall() + 4)
    else
        self.restoreBtn:SetVisible(false)
        if self.baseHeight then self:SetTall(self.baseHeight) end
    end
end

function FRAME:Think()
    if self.BaseClass and self.BaseClass.Think then self.BaseClass.Think(self) end
    if not self.nextCheck or self.nextCheck < RealTime() then
        self:updateRestoreButton()
        self.nextCheck = RealTime() + 1
    end
end

vgui.Register("liaGridInventory", FRAME, "liaInventory")
local MENU = {}
local OUTER_PADDING = 28
function MENU:Init()
    self:SetMouseInputEnabled(true)
    self:SetKeyboardInputEnabled(true)
    lia.gui = lia.gui or {}
    lia.gui.gridInventoryMenu = self
    self.isMenuInventory = true
    self.selectedIcon = nil
    self.content = self:Add("liaGridInventoryPanel")
    self.content:Dock(NODOCK)
    self.headerPanel = self:Add("EditablePanel")
    self.headerPanel.Paint = function()
        local accent, textColor = getThemeColors()
        draw.SimpleText("Inventory", "LiliaFont.30", 2, 0, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(self:getSlotStatsText(), "LiliaFont.18", 2, 48, SECONDARY_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 35)
        surface.DrawLine(2, 78, self.headerPanel:GetWide() - 2, 78)
    end

    self.searchEntry = self.headerPanel:Add("DTextEntry")
    self.searchEntry:SetFont("LiliaFont.18")
    self.searchEntry:SetTextColor(PRIMARY_TEXT)
    self.searchEntry:SetCursorColor(select(1, getThemeColors()))
    self.searchEntry:SetMouseInputEnabled(true)
    self.searchEntry:SetKeyboardInputEnabled(true)
    self.searchEntry:SetUpdateOnType(true)
    if self.searchEntry.SetTextInset then self.searchEntry:SetTextInset(52, 0) end
    self.searchEntry.OnChange = function(entry)
        local value = entry:GetValue()
        self.content:setSearchQuery(value)
        if IsValid(self.bagContent) then self.bagContent:setSearchQuery(value) end
    end

    self.searchEntry.OnValueChange = function(_, value)
        self.content:setSearchQuery(value)
        if IsValid(self.bagContent) then self.bagContent:setSearchQuery(value) end
    end

    self.searchEntry.Paint = function(entry, w, h)
        local accent = select(1, getThemeColors())
        local focused = entry:HasFocus()
        local hovered = entry:IsHovered()
        local background = focused and Color(accent.r, accent.g, accent.b, 16) or hovered and Color(255, 255, 255, 7) or Color(3, 16, 21, 185)
        drawPanel(0, 0, w, h, 6, background, focused and Color(accent.r, accent.g, accent.b, 145) or Color(accent.r, accent.g, accent.b, hovered and 100 or 68))
        surface.SetDrawColor(SECONDARY_TEXT.r, SECONDARY_TEXT.g, SECONDARY_TEXT.b, 220)
        surface.DrawCircle(25, h * 0.5 - 1, 8, Color(158, 183, 185, 220))
        surface.DrawLine(31, h * 0.5 + 5, 37, h * 0.5 + 11)
        if entry:GetValue() == "" and not focused then draw.SimpleText("Search inventory...", "LiliaFont.18", 52, h * 0.5, SECONDARY_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        entry:DrawTextEntryText(PRIMARY_TEXT, accent, PRIMARY_TEXT)
    end

    self.categoryButton = self.headerPanel:Add("DButton")
    self.categoryButton:SetText("All items  ▼")
    styleButton(self.categoryButton, false)
    self.categoryButton.DoClick = function() self:openCategoryMenu() end
    self.gridViewport = self:Add("EditablePanel")
    self.gridViewport.Paint = function(_, w, h)
        local accent = select(1, getThemeColors())
        drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.content:SetParent(self.gridViewport)
    self.bagViewport = self:Add("EditablePanel")
    self.bagViewport:SetVisible(false)
    self.bagViewport.Paint = function(_, w, h)
        local accent = select(1, getThemeColors())
        drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
    end

    self.bagContent = self.bagViewport:Add("liaGridInventoryPanel")
    self.bagContent:SetVisible(false)
    self.footerPanel = self:Add("EditablePanel")
    self.footerPanel.Paint = function(_, w, h)
        local accent, textColor = getThemeColors()
        drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
        local item = IsValid(self.selectedIcon) and self.selectedIcon.itemTable
        local name = item and item:getName() or "Select an item"
        draw.SimpleText(name, "LiliaFont.24", 24, 17, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        if not item then
            draw.SimpleText("Choose an inventory item to view its details", "LiliaFont.16", 24, 54, SECONDARY_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            return
        end

        local details = self:getSelectedItemDetails(item)
        local x = 24
        for i, text in ipairs(details) do
            if i > 1 then
                surface.SetDrawColor(accent.r, accent.g, accent.b, 170)
                surface.DrawRect(x - 13, 65, 4, 4)
            end

            draw.SimpleText(text, "LiliaFont.16", x, 57, SECONDARY_TEXT, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
            surface.SetFont("LiliaFont.16")
            x = x + surface.GetTextSize(text) + 32
        end
    end

    self.actionButtons = {}
    self.actionButtonData = {}
end

function MENU:setInventory(inv)
    self.inventory = inv
    self.gridW, self.gridH = inv:getSize()
    self.selectedIcon = nil
    if IsValid(self.content) then
        self.content:setGridSize(self.gridW, self.gridH, self.content.size or 64)
        self.content:setInventory(inv)
        self.content:setFilterCategory(nil)
        self.content:setSearchQuery("")
    end

    if IsValid(self.searchEntry) then self.searchEntry:SetValue("") end
    if IsValid(self.categoryButton) then self.categoryButton:SetText("All items  ▼") end
    self:rebuildActionButtons()
    self:InvalidateLayout(true)
end

function MENU:openBagInventory(item)
    if not item or not isfunction(item.getInv) then return false end
    local inventory = item:getInv()
    if not inventory then return false end
    if self.bagInventory and self.bagInventory ~= inventory then
        self.bagHistory = self.bagHistory or {}
        self.bagHistory[#self.bagHistory + 1] = {
            inventory = self.bagInventory,
            item = self.bagItem
        }
    end

    self.bagInventory = inventory
    self.bagItem = item
    self.bagGridW, self.bagGridH = inventory:getSize()
    self.bagViewport:SetVisible(true)
    self.bagContent:SetVisible(true)
    self.bagContent:setGridSize(self.bagGridW, self.bagGridH, self.bagContent.size or 64)
    self.bagContent:setInventory(inventory)
    self.bagContent:setFilterCategory(self.content.filterCategory)
    self.bagContent:setSearchQuery(IsValid(self.searchEntry) and self.searchEntry:GetValue() or "")
    self.content.pairedPanel = self.bagContent
    self.bagContent.pairedPanel = self.content
    self:rebuildActionButtons()
    self:InvalidateLayout(true)
    return true
end

function MENU:closeBagInventory()
    self.bagHistory = self.bagHistory or {}
    local previous = table.remove(self.bagHistory)
    if previous then
        self.bagInventory = previous.inventory
        self.bagItem = previous.item
        self.bagGridW, self.bagGridH = self.bagInventory:getSize()
        self.bagContent:setGridSize(self.bagGridW, self.bagGridH, self.bagContent.size or 64)
        self.bagContent:setInventory(self.bagInventory)
        self.bagContent:setFilterCategory(self.content.filterCategory)
        self.bagContent:setSearchQuery(IsValid(self.searchEntry) and self.searchEntry:GetValue() or "")
        self:rebuildActionButtons()
        self:InvalidateLayout(true)
        return true
    end

    self.bagInventory = nil
    self.bagItem = nil
    self.bagGridW = nil
    self.bagGridH = nil
    self.content.pairedPanel = nil
    self.bagContent.pairedPanel = nil
    self.bagContent:SetVisible(false)
    self.bagViewport:SetVisible(false)
    self:rebuildActionButtons()
    self:InvalidateLayout(true)
    return true
end

function MENU:goBackInventory()
    return self:closeBagInventory()
end

function MENU:getSlotStatsText()
    if not self.inventory then return "0 / 0 slots used" end
    local used = 0
    for _, item in pairs(self.inventory:getItems(true)) do
        used = used + item:getWidth() * item:getHeight()
    end
    return string.format("%d / %d slots used", used, self.gridW * self.gridH)
end

function MENU:getSelectedItemDetails(item)
    local details = {}
    local condition = getItemCondition(item)
    if condition then details[#details + 1] = "Condition " .. condition .. "%" end
    local desc = item.getDesc and item:getDesc()
    if desc and string.Trim(tostring(desc)) ~= "" then details[#details + 1] = tostring(desc) end
    if #details == 0 then
        local rarity = item:getData("rarity") or item.rarity
        details[1] = rarity and tostring(rarity) or tostring(item.category or "Item")
    end
    return details
end

local function buildActionInvoker(owner, actionKey, action, item, sub, optionKey)
    return function()
        if not item or not action then return end
        item.player = LocalPlayer()
        local actionName = string.lower(tostring(actionKey))
        if actionName == "open" and isfunction(item.getInv) and IsValid(owner) and isfunction(owner.openBagInventory) then owner:openBagInventory(item) end
        local send = true
        if action.onClick then send = action.onClick(item, sub and sub.data) end
        local sound = action.sound
        if sound then
            if istable(sound) then
                LocalPlayer():EmitSound(unpack(sound))
            elseif isstring(sound) then
                surface.PlaySound(sound)
            end
        end

        if send ~= false then
            net.Start("liaInvAct")
            net.WriteString(actionKey)
            net.WriteType(item:getID())
            net.WriteType(optionKey or sub and sub.data)
            net.SendToServer()
        end

        item.player = nil
    end
end

function MENU:clearActionButtons()
    for _, button in ipairs(self.actionButtons or {}) do
        if IsValid(button) then button:Remove() end
    end

    self.actionButtons = {}
    self.actionButtonData = {}
end

function MENU:addFooterAction(label, callback, primary)
    local button = self.footerPanel:Add("DButton")
    button:SetText(label)
    styleButton(button, primary == true)
    button.DoClick = callback
    self.actionButtons[#self.actionButtons + 1] = button
    return button
end

function MENU:getAvailableItemActions(item)
    local actions = {}
    if not item then return actions end
    item.player = LocalPlayer()
    for actionKey, action in SortedPairs(item.functions or {}) do
        local canRun = hook.Run("CanRunItemAction", item, actionKey) ~= false
        if canRun and isfunction(action.onCanRun) then canRun = action.onCanRun(item) end
        if canRun then
            actions[#actions + 1] = {
                key = actionKey,
                action = action
            }
        end
    end

    item.player = nil
    return actions
end

function MENU:openMultiActionMenu(actionKey, action, item)
    item.player = LocalPlayer()
    local options = action.multiOptions
    if isfunction(options) then options = options(item, LocalPlayer()) end
    if not istable(options) then
        item.player = nil
        return
    end

    local menu = lia.derma and lia.derma.dermaMenu and lia.derma.dermaMenu() or DermaMenu()
    for optionKey, option in pairs(options) do
        if isfunction(option) then
            local subOption = {
                name = optionKey,
                onRun = option
            }

            menu:AddOption(L(optionKey), buildActionInvoker(self, actionKey, action, item, subOption, optionKey), "icon16/brick.png")
        elseif istable(option) then
            local canRun = not isfunction(option[2]) or option[2](item, LocalPlayer())
            if canRun then
                local subOption = {
                    name = option.name or optionKey,
                    onRun = option[1] or option.onRun,
                    icon = option.icon
                }

                menu:AddOption(L(subOption.name), buildActionInvoker(self, actionKey, action, item, subOption, optionKey), subOption.icon or "icon16/brick.png")
            end
        end
    end

    menu:Open()
    item.player = nil
end

function MENU:openItemActionMenu(item)
    if not item then return end
    local actions = self:getAvailableItemActions(item)
    if #actions == 0 then return end
    local menu = lia.derma and lia.derma.dermaMenu and lia.derma.dermaMenu() or DermaMenu()
    for _, actionInfo in ipairs(actions) do
        local actionKey = actionInfo.key
        local action = actionInfo.action
        local label = L(action.name or actionKey)
        local isMulti = action.isMulti or action.multiOptions and (istable(action.multiOptions) or isfunction(action.multiOptions))
        local callback = isMulti and function() self:openMultiActionMenu(actionKey, action, item) end or buildActionInvoker(self, actionKey, action, item)
        menu:AddOption(label, callback, action.icon or "icon16/brick.png")
    end

    menu:Open()
end

function MENU:rebuildActionButtons()
    self:clearActionButtons()
    if self.bagInventory then self:addFooterAction(self.bagHistory and #self.bagHistory > 0 and "Back" or "Close Bag", function() self:closeBagInventory() end, false) end
    local item = IsValid(self.selectedIcon) and self.selectedIcon.itemTable
    if not item then
        self:InvalidateLayout(true)
        return
    end

    local actions = self:getAvailableItemActions(item)
    local ordered = {}
    local dropAction
    for _, actionInfo in ipairs(actions) do
        if string.lower(tostring(actionInfo.key)) == "drop" then
            dropAction = actionInfo
        else
            ordered[#ordered + 1] = actionInfo
        end
    end

    if dropAction then ordered[#ordered + 1] = dropAction end
    for index, actionInfo in ipairs(ordered) do
        local actionKey = actionInfo.key
        local action = actionInfo.action
        local label = L(action.name or actionKey)
        local isMulti = action.isMulti or action.multiOptions and (istable(action.multiOptions) or isfunction(action.multiOptions))
        local callback = isMulti and function() self:openMultiActionMenu(actionKey, action, item) end or buildActionInvoker(self, actionKey, action, item)
        self:addFooterAction(label, callback, index == 1)
    end

    self:InvalidateLayout(true)
end

function MENU:setSelectedItem(icon)
    for _, panel in ipairs({self.content, self.bagContent}) do
        if IsValid(panel) and panel.selectedItem ~= icon then
            if IsValid(panel.selectedItem) and panel.selectedItem.setSelected then panel.selectedItem:setSelected(false) end
            panel.selectedItem = nil
        end
    end

    self.selectedIcon = IsValid(icon) and icon or nil
    self:rebuildActionButtons()
end

function MENU:getCategories()
    local categories = {}
    local seen = {}
    local inventories = {self.inventory, self.bagInventory}
    for _, inventory in ipairs(inventories) do
        if inventory then
            for _, item in pairs(inventory:getItems(true)) do
                local category = tostring(item.category or "")
                if category ~= "" and not seen[category] then
                    seen[category] = true
                    categories[#categories + 1] = category
                end
            end
        end
    end

    table.sort(categories)
    return categories
end

function MENU:openCategoryMenu()
    local menu = DermaMenu()
    menu:AddOption("All items", function()
        self.categoryButton:SetText("All items  ▼")
        self.content:setFilterCategory(nil)
        if IsValid(self.bagContent) then self.bagContent:setFilterCategory(nil) end
    end)

    for _, category in ipairs(self:getCategories()) do
        menu:AddOption(category, function()
            self.categoryButton:SetText(category .. "  ▼")
            self.content:setFilterCategory(category)
            if IsValid(self.bagContent) then self.bagContent:setFilterCategory(category) end
        end)
    end

    menu:Open()
end

function MENU:PerformLayout(w, h)
    local innerW = math.max(w - OUTER_PADDING * 2, 1)
    local footerH = 108
    local footerY = math.max(h - OUTER_PADDING - footerH, 0)
    self.headerPanel:SetPos(OUTER_PADDING, OUTER_PADDING)
    self.headerPanel:SetSize(innerW, 156)
    local controlY = 92
    local controlH = 54
    local categoryW = math.max(math.floor(innerW * 0.2), 150)
    local searchW = math.max(innerW - categoryW - 12, 1)
    self.searchEntry:SetPos(0, controlY)
    self.searchEntry:SetSize(searchW, controlH)
    self.categoryButton:SetPos(searchW + 12, controlY)
    self.categoryButton:SetSize(categoryW, controlH)
    self.footerPanel:SetPos(OUTER_PADDING, footerY)
    self.footerPanel:SetSize(innerW, footerH)
    local buttonH = 58
    local buttonY = math.floor((footerH - buttonH) * 0.5)
    local buttonGap = 12
    local buttons = self.actionButtons or {}
    local count = #buttons
    if count > 0 then
        local availableW = math.max(math.floor(innerW * 0.5), 1)
        local maxButtonW = 150
        local minButtonW = 96
        local buttonW = math.Clamp(math.floor((availableW - buttonGap * math.max(count - 1, 0)) / count), minButtonW, maxButtonW)
        local totalButtonW = buttonW * count + buttonGap * math.max(count - 1, 0)
        local buttonX = math.max(innerW - totalButtonW - 20, 0)
        for index, button in ipairs(buttons) do
            if IsValid(button) then
                button:SetPos(buttonX + (index - 1) * (buttonW + buttonGap), buttonY)
                button:SetSize(buttonW, buttonH)
            end
        end
    end

    local gridY = 202
    local gridH = math.max(footerY - gridY - 16, 64)
    local titleH = GRID_HEADER_HEIGHT
    local paneGap = self.bagInventory and 18 or 0
    local mainW = self.bagInventory and math.floor((innerW - paneGap) * 0.5) or innerW
    local bagW = self.bagInventory and innerW - mainW - paneGap or 0
    self.gridViewport:SetPos(OUTER_PADDING, gridY)
    self.gridViewport:SetSize(mainW, gridH)
    self.bagViewport:SetPos(OUTER_PADDING + mainW + paneGap, gridY)
    self.bagViewport:SetSize(bagW, gridH)
    self.bagViewport:SetVisible(self.bagInventory ~= nil)
    if self.gridW and self.gridH then
        local gap = self.content.gap or 6
        local contentW = math.max(mainW - GRID_PANEL_PADDING * 2, 1)
        local contentH = math.max(gridH - titleH - GRID_PANEL_PADDING, 1)
        local availableSlotW = (contentW - gap * (self.gridW - 1)) / self.gridW
        local availableSlotH = (contentH - gap * (self.gridH - 1)) / self.gridH
        local slotSize = math.max(28, math.floor(math.min(availableSlotW, availableSlotH)))
        self.content:setGridSize(self.gridW, self.gridH, slotSize)
        local gridPixelW, gridPixelH = self.content:getGridPixelSize()
        self.content:SetSize(gridPixelW, gridPixelH)
        self.content:SetPos(math.max(math.floor((mainW - gridPixelW) * 0.5), GRID_PANEL_PADDING), titleH)
    end

    if self.bagInventory and self.bagGridW and self.bagGridH then
        local gap = self.bagContent.gap or 6
        local contentW = math.max(bagW - GRID_PANEL_PADDING * 2, 1)
        local contentH = math.max(gridH - titleH - GRID_PANEL_PADDING, 1)
        local availableSlotW = (contentW - gap * (self.bagGridW - 1)) / self.bagGridW
        local availableSlotH = (contentH - gap * (self.bagGridH - 1)) / self.bagGridH
        local slotSize = math.max(28, math.floor(math.min(availableSlotW, availableSlotH)))
        self.bagContent:setGridSize(self.bagGridW, self.bagGridH, slotSize)
        local gridPixelW, gridPixelH = self.bagContent:getGridPixelSize()
        self.bagContent:SetSize(gridPixelW, gridPixelH)
        self.bagContent:SetPos(math.max(math.floor((bagW - gridPixelW) * 0.5), GRID_PANEL_PADDING), titleH)
    end
end

local function getCanonicalInventory(inventory)
    if not inventory or not inventory.getID then return inventory end
    local id = inventory:getID()
    return lia.inventory and lia.inventory.instances and lia.inventory.instances[id] or inventory
end

function MENU:refreshLiveInventories()
    if not IsValid(self.content) then return end
    local inventory = getCanonicalInventory(self.inventory)
    if inventory then
        self.inventory = inventory
        self.gridW, self.gridH = inventory:getSize()
        if self.content.inventory ~= inventory then
            self.content:setInventory(inventory)
        else
            self.content:populateItems()
        end
    end

    if self.bagInventory and IsValid(self.bagContent) then
        local bagInventory = getCanonicalInventory(self.bagInventory)
        if bagInventory then
            self.bagInventory = bagInventory
            self.bagGridW, self.bagGridH = bagInventory:getSize()
            if self.bagContent.inventory ~= bagInventory then
                self.bagContent:setInventory(bagInventory)
            else
                self.bagContent:populateItems()
            end

            self.content.pairedPanel = self.bagContent
            self.bagContent.pairedPanel = self.content
        end
    end

    self:InvalidateLayout(true)
end

local function queueLiveInventoryRefresh()
    timer.Create("liaGridInventoryMenuLiveRefresh", 0, 1, function()
        local menu = lia.gui and lia.gui.gridInventoryMenu
        if not IsValid(menu) or not menu.refreshLiveInventories then return end
        menu:refreshLiveInventories()
    end)
end

hook.Add("InventoryInitialized", "liaGridInventoryMenuLiveInitialized", function(inventory)
    local menu = lia.gui and lia.gui.gridInventoryMenu
    if not IsValid(menu) or not inventory or not inventory.getID then return end
    local inventoryID = inventory:getID()
    local mainID = menu.inventory and menu.inventory.getID and menu.inventory:getID()
    local bagID = menu.bagInventory and menu.bagInventory.getID and menu.bagInventory:getID()
    if inventoryID ~= mainID and inventoryID ~= bagID then return end
    queueLiveInventoryRefresh()
end)

hook.Add("InventoryItemAdded", "liaGridInventoryMenuLiveAdded", function() queueLiveInventoryRefresh() end)
hook.Add("InventoryItemRemoved", "liaGridInventoryMenuLiveRemoved", function() queueLiveInventoryRefresh() end)
hook.Add("ItemDataChanged", "liaGridInventoryMenuLiveData", function() queueLiveInventoryRefresh() end)
hook.Add("ItemQuantityChanged", "liaGridInventoryMenuLiveQuantity", function() queueLiveInventoryRefresh() end)
function MENU:OnRemove()
    if lia.gui and lia.gui.gridInventoryMenu == self then lia.gui.gridInventoryMenu = nil end
end

function MENU:Paint(w, h)
    local accent = select(1, getThemeColors())
    drawPanel(0, 0, w, h, 8, Color(5, 18, 23, 220), Color(accent.r, accent.g, accent.b, 80))
end

vgui.Register("liaGridInventoryMenu", MENU, "EditablePanel")
