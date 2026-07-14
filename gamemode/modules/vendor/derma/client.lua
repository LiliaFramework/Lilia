local RarityColors = lia.item.rarities
local VendorClick = {"buttons/button15.wav", 30, 250}
local function getVendorThemeColors()
    local theme = lia.color.theme or {}
    local accent = theme.accent or theme.theme or lia.config.get("Color") or Color(45, 190, 170)
    local text = theme.text or Color(225, 238, 238)
    return accent, text
end

local function drawVendorPanel(x, y, w, h, radius, color, outline)
    lia.derma.rect(x, y, w, h):Rad(radius):Color(color):Shape(lia.derma.SHAPE_IOS):Draw()
    if outline then lia.derma.rect(x, y, w, h):Rad(radius):Color(outline):Shape(lia.derma.SHAPE_IOS):Outline(1):Draw() end
end

local function resolveVendorIcon(icon)
    if not icon then return nil end
    if type(icon) == "IMaterial" then return icon end
    if isstring(icon) and icon ~= "" then return Material(icon, "smooth") end
end

local function drawVendorIcon(material, x, y, w, h, color)
    if not material or material:IsError() then return end
    surface.SetMaterial(material)
    surface.SetDrawColor(color or color_white)
    surface.DrawTexturedRect(x, y, w, h)
end

local function formatVendorPrice(price)
    if price == 0 then return L("vendorFree") end
    local symbol = lia.currency.symbol
    if isstring(symbol) and symbol ~= "" then return symbol .. string.Comma(price) end
    if price > 1 then return string.format("%s %s", price, lia.currency.plural) end
    return string.format("%s %s", price, lia.currency.singular)
end

local function countVisiblePanels(panels)
    local count = 0
    for _, panel in pairs(panels or {}) do
        if IsValid(panel) and panel:IsVisible() then count = count + 1 end
    end
    return count
end

local function createVendorButton(parent, text, primary)
    local button = parent:Add("DButton")
    button:SetText("")
    button._text = text or ""
    button._primary = primary == true
    button._negative = false
    button.Paint = function(s, w, h)
        local accent = getVendorThemeColors()
        local hovered = s:IsHovered() and s:IsEnabled()
        local background
        local outline
        if s._negative then
            local negative = lia.color.returnMainAdjustedColors().negative or Color(220, 85, 85)
            background = Color(negative.r, negative.g, negative.b, s:IsEnabled() and 45 or 25)
            outline = Color(negative.r, negative.g, negative.b, hovered and 145 or 90)
        elseif s._primary then
            background = Color(accent.r, accent.g, accent.b, hovered and 52 or 30)
            outline = Color(accent.r, accent.g, accent.b, hovered and 145 or 95)
        else
            background = hovered and Color(16, 34, 40, 235) or Color(13, 30, 35, 225)
            outline = Color(accent.r, accent.g, accent.b, hovered and 100 or 60)
        end

        drawVendorPanel(0, 0, w, h, 6, background, outline)
        local textColor = s:IsEnabled() and Color(230, 239, 239) or Color(125, 145, 146)
        draw.SimpleText(s._text or "", "LiliaFont.18", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    return button
end

local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor.noSendExit = true
        lia.gui.vendor:Remove()
    end

    lia.gui.vendor = self
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.25, 0)
    self:SetZPos(50)
    self.items = {
        vendor = {},
        me = {}
    }

    self.currentCategory = nil
    self.panelGap = math.Clamp(ScrW() * 0.012, 14, 22)
    self.modalW = math.min(ScrW() * 0.76, 1280)
    self.panelW = math.floor((self.modalW - self.panelGap) * 0.5)
    self.panelH = math.min(ScrH() * 0.75, 760)
    self.y0 = math.max(72, math.floor((ScrH() - self.panelH) * 0.5) - 10)
    self.leftX = math.floor(ScrW() * 0.5 - self.modalW * 0.5)
    self.rightX = self.leftX + self.panelW + self.panelGap
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    self:ApplyCurrentTheme()
    self.vendorPanel = self:CreateInventoryPanel(self.leftX, self.y0, true)
    self.mePanel = self:CreateInventoryPanel(self.rightX, self.y0, false)
    self:listenForChanges()
    self:liaListenForInventoryChanges(client:getChar():getInv())
    self:populateItems()
    timer.Simple(0.1, function()
        if not IsValid(self) or not IsValid(liaVendorEnt) then return end
        local itemCount = liaVendorEnt.items and table.Count(liaVendorEnt.items) or 0
        if itemCount <= 0 then return end
        local vendorCanvas = IsValid(self.vendorPanel.items) and self.vendorPanel.items:GetCanvas()
        local meCanvas = IsValid(self.mePanel.items) and self.mePanel.items:GetCanvas()
        local vendorChildren = IsValid(vendorCanvas) and #vendorCanvas:GetChildren() or 0
        local meChildren = IsValid(meCanvas) and #meCanvas:GetChildren() or 0
        if vendorChildren == 0 and meChildren == 0 then self:populateItems() end
    end)

    local buttonW = math.Clamp(ScrW() * 0.095, 150, 190)
    local buttonH = 46
    local buttonY = math.min(self.y0 + self.panelH + 18, ScrH() - buttonH - 18)
    self.leaveButton = createVendorButton(self, L("leave"), false)
    self.leaveButton:SetSize(buttonW, buttonH)
    self.leaveButton:SetPos(self.rightX + self.panelW - buttonW, buttonY)
    self.leaveButton.DoClick = function()
        lia.websound.playButtonSound()
        self:Remove()
    end

    if client:canEditVendor(self.vendorPanel) then
        self.editButton = createVendorButton(self, L("vendorEditorButton"), false)
        self.editButton:SetSize(buttonW, buttonH)
        self.editButton:SetPos(self.leaveButton.x - buttonW - 12, buttonY)
        self.editButton.DoClick = function()
            lia.websound.playButtonSound()
            vgui.Create("liaVendorEditor"):SetZPos(99)
        end
    end

    self:RefreshEmptyStates()
end

function PANEL:ApplyCurrentTheme()
    local currentTheme = lia.color.getCurrentTheme()
    if currentTheme and lia.color.themes[currentTheme] then lia.color.theme = table.Copy(lia.color.themes[currentTheme]) end
end

function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    self:ApplyCurrentTheme()
    local _, text = getVendorThemeColors()
    if IsValid(self.vendorPanel) and IsValid(self.vendorPanel.title) then self.vendorPanel.title:SetTextColor(text) end
    if IsValid(self.mePanel) and IsValid(self.mePanel.title) then self.mePanel.title:SetTextColor(text) end
    self:InvalidateLayout(true)
end

function PANEL:CreateInventoryPanel(x, y, isVendor)
    local panel = self:Add("DPanel")
    panel:SetSize(self.panelW, self.panelH)
    panel:SetPos(x, y)
    panel.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 10, Color(6, 18, 23, 226), Color(accent.r, accent.g, accent.b, 72))
    end

    panel.header = panel:Add("DPanel")
    panel.header:Dock(TOP)
    panel.header:SetTall(70)
    panel.header:DockMargin(18, 12, 18, 8)
    panel.header.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        surface.SetDrawColor(accent.r, accent.g, accent.b, 28)
        surface.DrawRect(26, h - 12, w - 52, 1)
    end

    panel.title = panel.header:Add("DLabel")
    panel.title:Dock(FILL)
    panel.title:SetFont("LiliaFont.25")
    panel.title:SetTextColor(select(2, getVendorThemeColors()))
    panel.title:SetContentAlignment(5)
    if isVendor then
        local vendorName = IsValid(liaVendorEnt) and liaVendorEnt:getName() or L("vendorItemsTitle")
        panel.title:SetText(string.format("%s's %s", vendorName, L("items")))
        self.vendorItemsLabel = panel.title
    else
        panel.title:SetText(L("vendorYourItems"))
    end

    panel.items = panel:Add("liaScrollPanel")
    panel.items:Dock(FILL)
    panel.items:DockMargin(18, 0, 18, 18)
    panel.items:DockPadding(8, 6, 8, 8)
    panel.items.Paint = function() end
    local canvas = panel.items:GetCanvas()
    if IsValid(canvas) then
        canvas:DockPadding(0, 0, 4, 0)
        canvas.Paint = function() end
    end

    panel.empty = panel:Add("DPanel")
    panel.empty:SetSize(260, 84)
    panel.empty:SetVisible(false)
    panel.empty:SetMouseInputEnabled(false)
    panel.empty:SetZPos(100)
    panel.empty.Paint = function(_, w, h)
        local _, text = getVendorThemeColors()
        drawVendorIcon(Material("icon16/box.png", "smooth"), math.floor((w - 24) * 0.5), 6, 24, 24, Color(125, 148, 149))
        draw.SimpleText("No items available", "LiliaFont.18", w * 0.5, 50, Color(text.r, text.g, text.b, 145), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    panel.Think = function(s)
        if not IsValid(s.empty) then return end
        local w, h = s:GetSize()
        s.empty:SetPos(math.floor((w - s.empty:GetWide()) * 0.5), math.floor(82 + (h - 82 - s.empty:GetTall()) * 0.5))
    end
    return panel
end

function PANEL:createCategoryDropdown()
end

function PANEL:RefreshEmptyStates()
    if IsValid(self.vendorPanel) and IsValid(self.vendorPanel.empty) then self.vendorPanel.empty:SetVisible(countVisiblePanels(self.items.vendor) == 0) end
    if IsValid(self.mePanel) and IsValid(self.mePanel.empty) then self.mePanel.empty:SetVisible(countVisiblePanels(self.items.me) == 0) end
end

function PANEL:buyItemFromVendor(id)
    net.Start("liaVendorTrade")
    net.WriteString(id)
    net.WriteBool(false)
    net.SendToServer()
end

function PANEL:sellItemToVendor(id)
    net.Start("liaVendorTrade")
    net.WriteString(id)
    net.WriteBool(true)
    net.SendToServer()
end

function PANEL:populateItems()
    if not IsValid(liaVendorEnt) then return end
    local data = liaVendorEnt.items or {}
    for id in SortedPairs(data) do
        local item = lia.item.list[id]
        local mode = liaVendorEnt:getTradeMode(id)
        if item and mode then
            if mode ~= VENDOR_BUYONLY then self:updateItem(id, "vendor") end
            if mode ~= VENDOR_SELLONLY then
                local panel = self:updateItem(id, "me")
                if panel then panel:setIsSelling(true) end
            end
        end
    end

    if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout(true) end
    if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout(true) end
    self:RefreshEmptyStates()
end

function PANEL:shouldShow(id, which)
    if not IsValid(liaVendorEnt) then return false end
    local mode = liaVendorEnt:getTradeMode(id)
    if not mode then return false end
    if which == "me" and mode == VENDOR_SELLONLY then return false end
    if which == "vendor" and mode == VENDOR_BUYONLY then return false end
    return true
end

function PANEL:updateItem(id, which, quantity)
    local container = self.items[which]
    if not container then return end
    if not self:shouldShow(id, which) then
        if IsValid(container[id]) then container[id]:Remove() end
        container[id] = nil
        self:RefreshEmptyStates()
        return
    end

    local parent = which == "me" and self.mePanel or self.vendorPanel
    if not IsValid(parent) or not IsValid(parent.items) then return end
    local panel = container[id]
    if not IsValid(panel) then
        local targetParent = parent.items:GetCanvas()
        if not IsValid(targetParent) then targetParent = parent.items end
        panel = targetParent:Add("liaVendorItem")
        panel:Dock(TOP)
        panel:DockMargin(0, 0, 0, 8)
        panel:SetTall(122)
        panel:setItemType(id)
        panel:setIsSelling(which == "me")
        container[id] = panel
    end

    if not isnumber(quantity) then
        if which == "me" then
            quantity = LocalPlayer():getChar():getInv():getItemCount(id)
        else
            quantity = IsValid(liaVendorEnt) and liaVendorEnt:getStock(id) or 0
        end
    end

    panel:setQuantity(quantity)
    if not IsValid(panel) then
        container[id] = nil
        self:RefreshEmptyStates()
        return
    end

    panel:SetVisible(true)
    self:RefreshEmptyStates()
    return panel
end

function PANEL:GetItemCategoryList()
    if not IsValid(liaVendorEnt) then return {} end
    local data = liaVendorEnt.items or {}
    local categories = {
        [L("vendorShowAll")] = true
    }

    for id in pairs(data) do
        local item = lia.item.list[id]
        if item then
            local category = item:getCategory()
            categories[category:sub(1, 1):upper() .. category:sub(2)] = true
        end
    end
    return categories
end

function PANEL:applyCategoryFilter()
    for _, panel in pairs(self.items.vendor) do
        if IsValid(panel) then panel:Remove() end
    end

    for _, panel in pairs(self.items.me) do
        if IsValid(panel) then panel:Remove() end
    end

    self.items.vendor = {}
    self.items.me = {}
    if not IsValid(liaVendorEnt) then
        self:RefreshEmptyStates()
        return
    end

    local data = liaVendorEnt.items or {}
    for id in SortedPairs(data) do
        local item = lia.item.list[id]
        if item then
            local category = item:getCategory()
            if category then category = category:sub(1, 1):upper() .. category:sub(2) end
            if not self.currentCategory or self.currentCategory == L("vendorShowAll") or category == self.currentCategory then
                local mode = liaVendorEnt:getTradeMode(id)
                if mode ~= VENDOR_BUYONLY then self:updateItem(id, "vendor") end
                if mode ~= VENDOR_SELLONLY then
                    local panel = self:updateItem(id, "me")
                    if panel then panel:setIsSelling(true) end
                end
            end
        end
    end

    if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout(true) end
    if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout(true) end
    self:RefreshEmptyStates()
end

function PANEL:listenForChanges()
    hook.Add("VendorItemBuyPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemSellPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onVendorModeUpdated)
    hook.Add("VendorEdited", self, self.onVendorPropEdited)
    hook.Add("VendorPropertyUpdated", self, self.onVendorPropertyUpdated)
    hook.Add("VendorSynchronized", self, self.onVendorSynchronized)
end

function PANEL:InventoryItemAdded(item)
    if item and item.uniqueID then self:updateItem(item.uniqueID, "me") end
    self:RefreshEmptyStates()
end

function PANEL:InventoryItemRemoved(item)
    if item and item.uniqueID then self:InventoryItemAdded(item) end
    self:RefreshEmptyStates()
end

function PANEL:onVendorPropEdited(_, key)
    if not IsValid(liaVendorEnt) then return end
    if key == "name" then
        if IsValid(self.vendorItemsLabel) then
            local vendorName = liaVendorEnt:getName() or L("vendorItemsTitle")
            self.vendorItemsLabel:SetText(string.format("%s's %s", vendorName, L("items")))
        end
    elseif key == "skin" then
        if IsValid(self.skin) then self.skin:SetValue(liaVendorEnt:GetSkin()) end
    elseif key == "bodygroup" then
        if IsValid(lia.gui.vendorBodygroupEditor) then lia.gui.vendorBodygroupEditor:onVendorEdited(nil, key) end
    end

    self:applyCategoryFilter()
end

function PANEL:onVendorPropertyUpdated(vendor, key)
    if vendor ~= liaVendorEnt then return end
    self:onVendorPropEdited(nil, key)
end

function PANEL:onVendorPriceUpdated(_, id)
    if IsValid(self.items.vendor[id]) then self.items.vendor[id]:updateLabel() end
    if IsValid(self.items.me[id]) then self.items.me[id]:updateLabel() end
end

function PANEL:onVendorModeUpdated(_, id)
    self:updateItem(id, "vendor")
    self:updateItem(id, "me")
    self:RefreshEmptyStates()
end

function PANEL:onItemStockUpdated(_, id)
    self:updateItem(id, "vendor")
    self:RefreshEmptyStates()
end

function PANEL:onVendorSynchronized(vendor)
    if not IsValid(self) or vendor ~= liaVendorEnt then return end
    for _, panel in pairs(self.items.vendor) do
        if IsValid(panel) then panel:Remove() end
    end

    for _, panel in pairs(self.items.me) do
        if IsValid(panel) then panel:Remove() end
    end

    self.items.vendor = {}
    self.items.me = {}
    self:populateItems()
    timer.Simple(0, function()
        if not IsValid(self) then return end
        if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout(true) end
        if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout(true) end
        self:RefreshEmptyStates()
    end)
end

function PANEL:Paint(w, h)
    lia.util.drawBlackBlur(self, 1, 5, 255, 225)
    surface.SetDrawColor(0, 8, 10, 110)
    surface.DrawRect(0, 0, w, h)
end

function PANEL:OnRemove()
    hook.Remove("OnThemeChanged", self)
    if not self.noSendExit then
        net.Start("liaVendorExit")
        net.SendToServer()
        self.noSendExit = true
    end

    if IsValid(lia.gui.vendorEditor) then
        if IsValid(lia.gui.vendorEditor.deletePresetSelector) then lia.gui.vendorEditor.deletePresetSelector:Remove() end
        lia.gui.vendorEditor:Remove()
    end

    if IsValid(lia.gui.vendorFactionEditor) then lia.gui.vendorFactionEditor:Remove() end
    if self.refreshTimer then timer.Remove(self.refreshTimer) end
    if self.searchTimer then timer.Remove(self.searchTimer) end
    hook.Remove("VendorFactionUpdated", self)
    hook.Remove("VendorClassUpdated", self)
    hook.Remove("VendorSynchronized", self)
    self:liaDeleteInventoryHooks()
end

function PANEL:OnKeyCodePressed(key)
    if key == KEY_ESCAPE or key == KEY_E then self:Remove() end
end

vgui.Register("liaVendor", PANEL, "EditablePanel")
PANEL = {}
local function clickVendorEffects()
    LocalPlayer():EmitSound(unpack(VendorClick))
end

function PANEL:Init()
    self:SetTall(122)
    self:Dock(TOP)
    self:SetPaintBackground(false)
    self:SetCursor("hand")
    self.hoverAlpha = 0
    self.purchaseAttempted = false
    self.purchaseAttemptTime = nil
    self.cooldownActive = false
    self.cooldownTimer = "vendorCooldown_" .. tostring(self)
    timer.Create(self.cooldownTimer, 1, 0, function()
        if not IsValid(self) or not IsValid(self.action) then
            timer.Remove(self.cooldownTimer)
            return
        end

        self:updateCooldown()
        self:updateAction()
        self:InvalidateLayout(true)
    end)

    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        local hovered = self:IsHovered()
        local background = hovered and Color(12, 29, 35, 238) or Color(10, 25, 30, 232)
        local outline = Color(accent.r, accent.g, accent.b, hovered and 80 or 45)
        drawVendorPanel(0, 0, w, h, 8, background, outline)
        if hovered then
            surface.SetDrawColor(accent.r, accent.g, accent.b, 220)
            surface.DrawRect(0, 9, 3, h - 18)
        end
    end

    self.iconFrame = self.background:Add("DPanel")
    self.iconFrame:Dock(LEFT)
    self.iconFrame:SetWide(102)
    self.iconFrame:DockMargin(10, 10, 12, 10)
    self.iconFrame._material = nil
    self.iconFrame.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 6, Color(3, 16, 21, 185), Color(accent.r, accent.g, accent.b, 68))
        if self.iconFrame._material then drawVendorIcon(self.iconFrame._material, 0, 0, w, h, color_white) end
    end

    self.icon = self.iconFrame:Add("liaItemIcon")
    self.icon:Dock(FILL)
    self.icon.Paint = function() end
    self.contentArea = self.background:Add("DPanel")
    self.contentArea:Dock(FILL)
    self.contentArea:DockMargin(0, 10, 10, 10)
    self.contentArea:SetPaintBackground(false)
    self.topRow = self.contentArea:Add("DPanel")
    self.topRow:Dock(TOP)
    self.topRow:SetTall(38)
    self.topRow:SetPaintBackground(false)
    self.action = createVendorButton(self.topRow, "", true)
    self.action:Dock(RIGHT)
    self.action:SetWide(108)
    self.action:DockMargin(12, 0, 0, 0)
    self.name = self.topRow:Add("DLabel")
    self.name:Dock(FILL)
    self.name:SetFont("LiliaFont.22")
    self.name:SetTextColor(Color(242, 247, 247))
    self.name:SetContentAlignment(4)
    self.name:SetText("")
    self.description = self.contentArea:Add("DLabel")
    self.description:Dock(TOP)
    self.description:SetTall(38)
    self.description:DockMargin(0, 6, 0, 4)
    self.description:SetFont("LiliaFont.16")
    self.description:SetTextColor(Color(165, 187, 188))
    self.description:SetWrap(true)
    self.description:SetContentAlignment(7)
    self.description:SetText("")
    self.bottomRow = self.contentArea:Add("DPanel")
    self.bottomRow:Dock(BOTTOM)
    self.bottomRow:SetTall(28)
    self.bottomRow:SetPaintBackground(false)
    self.priceLabel = self.bottomRow:Add("DLabel")
    self.priceLabel:Dock(LEFT)
    self.priceLabel:SetWide(140)
    self.priceLabel:SetFont("LiliaFont.18")
    self.priceLabel:SetContentAlignment(4)
    self.priceLabel:SetTextColor(select(1, getVendorThemeColors()))
    self.priceLabel:SetText("")
    self.quantityLabel = self.bottomRow:Add("DLabel")
    self.quantityLabel:Dock(RIGHT)
    self.quantityLabel:SetWide(100)
    self.quantityLabel:SetFont("LiliaFont.16")
    self.quantityLabel:SetContentAlignment(6)
    self.quantityLabel:SetTextColor(Color(165, 187, 188))
    self.quantityLabel:SetText("")
    self.isSelling = false
    self.currentPrice = 0
    self.currentQuantity = 0
end

function PANEL:GetCooldownRemaining()
    if self.isSelling or not self.item or not self.item.Cooldown or self.item.Cooldown <= 0 then return 0 end
    local remaining = 0
    if self.purchaseAttempted and self.purchaseAttemptTime then
        local elapsed = os.time() - self.purchaseAttemptTime
        if elapsed < self.item.Cooldown then
            remaining = math.max(remaining, math.ceil(self.item.Cooldown - elapsed))
        elseif elapsed > self.item.Cooldown + 10 then
            self.purchaseAttempted = false
            self.purchaseAttemptTime = nil
        end
    end

    local char = LocalPlayer():getChar()
    if not char then return remaining end
    local cooldowns = char:getData("vendorCooldowns", {})
    local lastPurchase = 0
    if istable(cooldowns) then
        lastPurchase = cooldowns[self.item.uniqueID] or 0
    elseif isstring(cooldowns) then
        local itemPattern = self.item.uniqueID .. ";([^;]+);"
        local timestamp = string.match(cooldowns, itemPattern)
        if timestamp then
            if timestamp:sub(1, 1) == "X" then
                lastPurchase = tonumber(timestamp:sub(2), 16) or 0
            else
                lastPurchase = tonumber(timestamp) or 0
            end
        end
    end

    if lastPurchase > 0 then remaining = math.max(remaining, math.max(0, math.ceil(self.item.Cooldown - (os.time() - lastPurchase)))) end
    return remaining
end

function PANEL:updateCooldown()
    if not IsValid(self.action) or not self.item then return end
    local remaining = self:GetCooldownRemaining()
    self.cooldownActive = remaining > 0
    self.action._negative = self.cooldownActive
    if self.cooldownActive then
        local minutes = math.floor(remaining / 60)
        local seconds = remaining % 60
        local timeText = minutes > 0 and string.format("%dm %ds", minutes, seconds) or string.format("%ds", seconds)
        self.action._text = L("vendorOnCooldown", timeText)
        self.action:SetEnabled(false)
    else
        self.action:SetEnabled(true)
    end
end

function PANEL:updateAction()
    if not IsValid(self.action) or not self.item then return end
    if not IsValid(liaVendorEnt) then
        self.action._text = self.isSelling and L("sell") or L("buy")
        self.action:SetEnabled(false)
        return
    end

    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling, LocalPlayer())
    self.currentPrice = price
    if IsValid(self.priceLabel) then self.priceLabel:SetText(formatVendorPrice(price)) end
    if self.cooldownActive then return end
    self.action._negative = false
    self.action._text = self.isSelling and L("sell") or L("buy")
    self.action:SetEnabled(true)
    self.action.DoClick = function()
        if self.isSelling then
            self:sellItemToVendor()
        else
            self:buyItemFromVendor()
        end
    end
end

function PANEL:sellItemToVendor()
    if not self.item or not IsValid(lia.gui.vendor) then return end
    lia.gui.vendor:sellItemToVendor(self.item.uniqueID)
    clickVendorEffects()
end

function PANEL:buyItemFromVendor()
    if not self.item or not IsValid(lia.gui.vendor) then return end
    if self.item.Cooldown and self.item.Cooldown > 0 then
        self.purchaseAttempted = true
        self.purchaseAttemptTime = os.time()
    end

    lia.gui.vendor:buyItemFromVendor(self.item.uniqueID)
    clickVendorEffects()
    self:updateCooldown()
end

function PANEL:setQuantity(quantity, skipUpdate)
    if not self.item then return end
    if quantity and quantity <= 0 and self.isSelling then
        self:Remove()
        if IsValid(lia.gui.vendor) then lia.gui.vendor:RefreshEmptyStates() end
        return
    end

    self.currentQuantity = tonumber(quantity) or 0
    if IsValid(self.quantityLabel) then
        if self.isSelling then
            self.quantityLabel:SetText("x" .. tostring(self.currentQuantity))
        elseif IsValid(liaVendorEnt) then
            local current, maximum = liaVendorEnt:getStock(self.item.uniqueID)
            if current and current < 0 then
                self.quantityLabel:SetText("∞")
            elseif maximum then
                self.quantityLabel:SetText(string.format("%s/%s", tostring(current or self.currentQuantity), tostring(maximum)))
            else
                self.quantityLabel:SetText(tostring(self.currentQuantity))
            end
        else
            self.quantityLabel:SetText(tostring(self.currentQuantity))
        end
    end

    if not skipUpdate then self:updateLabel() end
end

function PANEL:setItemType(itemType)
    local item = lia.item.list[itemType]
    assert(item, L("invalidItemTypeOrID", tostring(itemType)))
    self.item = item
    self.iconFrame._material = resolveVendorIcon(item.icon)
    if self.iconFrame._material then
        self.icon:SetVisible(false)
    else
        self.icon:SetVisible(true)
        self.icon:SetModel(item.model, item.skin or 0)
    end

    local rarity = item.rarity or "Common"
    self.name:SetTextColor(RarityColors[rarity] or Color(242, 247, 247))
    self:updateLabel()
    self:updateCooldown()
    self:updateAction()
end

function PANEL:setIsSelling(isSelling)
    self.isSelling = isSelling == true
    self:updateLabel()
    self:updateCooldown()
    self:updateAction()
end

function PANEL:updateLabel()
    if not self.item then return end
    self.name:SetText(self.item:getName())
    self.description:SetText(self.item:getDesc() or L("noDesc"))
    self:updateAction()
    if self.currentQuantity > 0 or not self.isSelling then self:setQuantity(self.currentQuantity, true) end
end

function PANEL:OnRemove()
    if self.cooldownTimer then timer.Remove(self.cooldownTimer) end
end

vgui.Register("liaVendorItem", PANEL, "DPanel")
PANEL = {}
local function styleEditorEntry(entry)
    if not IsValid(entry) then return end
    local textEntry = IsValid(entry.textEntry) and entry.textEntry or entry
    if isfunction(entry.SetFont) then entry:SetFont("LiliaFont.17") end
    if isfunction(entry.SetTextColor) then entry:SetTextColor(Color(225, 238, 238)) end
    if isfunction(entry.SetCursorColor) then entry:SetCursorColor(getVendorThemeColors()) end
    if isfunction(entry.SetPaintBackground) then entry:SetPaintBackground(false) end
    if not IsValid(textEntry) then return end
    if isfunction(textEntry.SetPaintBackground) then textEntry:SetPaintBackground(false) end
    if isfunction(textEntry.SetPaintBackgroundEnabled) then textEntry:SetPaintBackgroundEnabled(false) end
    if isfunction(textEntry.SetDrawBorder) then textEntry:SetDrawBorder(false) end
    if isfunction(textEntry.SetPaintBorderEnabled) then textEntry:SetPaintBorderEnabled(false) end
    textEntry.Paint = function() end
    textEntry.PaintOver = function(s, w, h)
        local accent = getVendorThemeColors()
        local focused = (isfunction(s.IsEditing) and s:IsEditing()) or s:HasFocus()
        drawVendorPanel(0, 0, w, h, 6, Color(9, 24, 29, 238), Color(accent.r, accent.g, accent.b, focused and 110 or 62))
        local value = isfunction(entry.GetValue) and entry:GetValue() or s:GetText()
        value = tostring(value or "")
        if entry._centerText then
            local displayText = value ~= "" and value or entry.placeholder or ""
            local displayColor = value ~= "" and Color(225, 238, 238) or Color(165, 187, 188, 120)
            draw.SimpleText(displayText, entry.font or "LiliaFont.17", w * 0.5, h * 0.5, displayColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            return
        end

        if value == "" and entry.placeholder and entry.placeholder ~= "" then draw.SimpleText(entry.placeholder, entry.font or "LiliaFont.17", 8, h * 0.5, Color(165, 187, 188, 120), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER) end
        s:DrawTextEntryText(Color(225, 238, 238), Color(accent.r, accent.g, accent.b, 70), accent)
    end
end

local function styleEditorButton(button, negative)
    button._negative = negative == true
    button.Paint = function(s, w, h)
        local accent = getVendorThemeColors()
        local hovered = s:IsHovered() and s:IsEnabled()
        local background = hovered and Color(16, 34, 40, 235) or Color(10, 27, 32, 228)
        local outline = Color(accent.r, accent.g, accent.b, hovered and 110 or 62)
        local textColor = s:IsEnabled() and Color(230, 239, 239) or Color(120, 139, 140)
        if s._negative then
            local negativeColor = lia.color.returnMainAdjustedColors().negative or Color(220, 85, 85)
            background = Color(negativeColor.r, negativeColor.g, negativeColor.b, hovered and 40 or 24)
            outline = Color(negativeColor.r, negativeColor.g, negativeColor.b, hovered and 135 or 80)
        end

        drawVendorPanel(0, 0, w, h, 6, background, outline)
        draw.SimpleText(s:GetText(), "LiliaFont.16", w * 0.5, h * 0.5, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end

local function addEditorSection(parent, title, subtitle)
    local header = parent:Add("DPanel")
    header:Dock(TOP)
    header:DockMargin(0, 4, 0, 10)
    header:SetTall(subtitle and subtitle ~= "" and 54 or 34)
    header.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        draw.SimpleText(string.upper(title or ""), "LiliaFont.17", 0, 4, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        if subtitle and subtitle ~= "" then draw.SimpleText(subtitle, "LiliaFont.15", 0, 27, Color(150, 174, 175), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP) end
        surface.SetDrawColor(accent.r, accent.g, accent.b, 44)
        surface.DrawRect(0, h - 1, w, 1)
    end
    return header
end

local function addEditorFieldLabel(parent, text)
    local label = parent:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(0, 0, 0, 5)
    label:SetTall(22)
    label:SetText(text)
    label:SetFont("LiliaFont.17")
    label:SetTextColor(Color(205, 220, 220))
    label:SetContentAlignment(4)
    return label
end

function PANEL:Init()
    if IsValid(lia.gui.vendorEditor) then lia.gui.vendorEditor:Remove() end
    lia.gui.vendorEditor = self
    local entity = liaVendorEnt
    if not IsValid(entity) then
        self:Remove()
        return
    end

    local screenMargin = math.Clamp(math.floor(math.min(ScrW(), ScrH()) * 0.025), 18, 32)
    local width = math.min(ScrW() - screenMargin * 2, 1540)
    local height = math.min(ScrH() - screenMargin * 2, 920)
    self:SetSize(width, height)
    self:MakePopup()
    self:Center()
    self:SetTitle(string.format("%s — %s", L("vendorEditor"), entity:getName()))
    self.factions = {}
    self.classes = {}
    hook.Add("OnThemeChanged", self, self.OnThemeChanged)
    self.backgroundPanel = self:Add("DPanel")
    self.backgroundPanel:Dock(FILL)
    self.backgroundPanel:DockPadding(10, 10, 10, 10)
    self.backgroundPanel.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 8, Color(4, 16, 21, 238), Color(accent.r, accent.g, accent.b, 70))
    end

    self.generalFrame = self.backgroundPanel:Add("DPanel")
    self.generalFrame:Dock(LEFT)
    self.generalFrame:SetWide(math.Clamp(width * 0.265, 320, 400))
    self.generalFrame:DockMargin(0, 0, 10, 0)
    self.generalFrame:DockPadding(12, 12, 12, 12)
    self.generalFrame.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 8, Color(6, 19, 24, 235), Color(accent.r, accent.g, accent.b, 68))
    end

    self.itemsFrame = self.backgroundPanel:Add("DPanel")
    self.itemsFrame:Dock(FILL)
    self.itemsFrame:DockPadding(12, 12, 12, 12)
    self.itemsFrame.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 8, Color(6, 19, 24, 235), Color(accent.r, accent.g, accent.b, 68))
    end

    self.generalScroll = self.generalFrame:Add("liaScrollPanel")
    self.generalScroll:Dock(FILL)
    self.generalScroll:DockPadding(2, 0, 4, 12)
    self.generalScroll.Paint = function() end
    self:initializeGeneralInfoPanel(entity)
    self:populateFactionPanel()
    self.itemsHeaderCard = self.itemsFrame:Add("DPanel")
    self.itemsHeaderCard:Dock(TOP)
    self.itemsHeaderCard:SetTall(66)
    self.itemsHeaderCard:DockMargin(0, 0, 0, 10)
    self.itemsHeaderCard.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        draw.SimpleText(string.upper(L("vendorItemsTitle")), "LiliaFont.18", 0, 4, accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        draw.SimpleText(L("vendorItemsSubtitle"), "LiliaFont.16", 0, 31, Color(155, 178, 179), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        surface.SetDrawColor(accent.r, accent.g, accent.b, 44)
        surface.DrawRect(0, h - 1, w, 1)
    end

    self.itemSearchBar = self.itemsHeaderCard:Add("liaEntry")
    self.itemSearchBar:Dock(RIGHT)
    self.itemSearchBar:SetWide(math.Clamp(width * 0.17, 190, 280))
    self.itemSearchBar:DockMargin(0, 7, 0, 17)
    self.itemSearchBar:SetPlaceholderText(L("search"))
    styleEditorEntry(self.itemSearchBar)
    self.itemSearchBar.action = function(value) self:ReloadItemList(value) end
    self.lastSearchValue = ""
    self.searchTimer = timer.Create("VendorSearch_" .. tostring(self), 0.2, 0, function()
        if not IsValid(self) or not IsValid(self.itemSearchBar) then
            if self.searchTimer then timer.Remove(self.searchTimer) end
            return
        end

        local currentValue = self.itemSearchBar:GetValue() or ""
        if currentValue ~= self.lastSearchValue then
            self.lastSearchValue = currentValue
            self:ReloadItemList(currentValue)
        end
    end)

    self.itemHeader = self.itemsFrame:Add("DPanel")
    self.itemHeader:Dock(TOP)
    self.itemHeader:SetTall(36)
    self.itemHeader:DockMargin(0, 0, 0, 4)
    self.itemHeader:DockPadding(10, 0, 10, 0)
    self.itemHeader.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 5, Color(8, 23, 28, 242), Color(accent.r, accent.g, accent.b, 55))
    end

    self.itemHeaderStock = self.itemHeader:Add("DLabel")
    self.itemHeaderStock:Dock(RIGHT)
    self.itemHeaderStock:SetWide(72)
    self.itemHeaderStock:SetText(L("vendorStockMaxShort"))
    self.itemHeaderStock:SetTooltip(L("vendorStockReq"))
    self.itemHeaderStock:SetFont("LiliaFont.15")
    self.itemHeaderStock:SetTextColor(Color(196, 211, 211))
    self.itemHeaderStock:SetContentAlignment(5)
    self.itemHeaderCurrentStock = self.itemHeader:Add("DLabel")
    self.itemHeaderCurrentStock:Dock(RIGHT)
    self.itemHeaderCurrentStock:SetWide(68)
    self.itemHeaderCurrentStock:DockMargin(6, 0, 0, 0)
    self.itemHeaderCurrentStock:SetText(L("vendorStockCurrentShort"))
    self.itemHeaderCurrentStock:SetTooltip(L("vendorEditCurStock"))
    self.itemHeaderCurrentStock:SetFont("LiliaFont.15")
    self.itemHeaderCurrentStock:SetTextColor(Color(196, 211, 211))
    self.itemHeaderCurrentStock:SetContentAlignment(5)
    self.itemHeaderSellPrice = self.itemHeader:Add("DLabel")
    self.itemHeaderSellPrice:Dock(RIGHT)
    self.itemHeaderSellPrice:SetWide(92)
    self.itemHeaderSellPrice:DockMargin(6, 0, 0, 0)
    self.itemHeaderSellPrice:SetText(L("vendorSellPriceLabel"))
    self.itemHeaderSellPrice:SetFont("LiliaFont.15")
    self.itemHeaderSellPrice:SetTextColor(Color(196, 211, 211))
    self.itemHeaderSellPrice:SetContentAlignment(5)
    self.itemHeaderBuyPrice = self.itemHeader:Add("DLabel")
    self.itemHeaderBuyPrice:Dock(RIGHT)
    self.itemHeaderBuyPrice:SetWide(92)
    self.itemHeaderBuyPrice:DockMargin(6, 0, 0, 0)
    self.itemHeaderBuyPrice:SetText(L("vendorBuyPriceLabel"))
    self.itemHeaderBuyPrice:SetFont("LiliaFont.15")
    self.itemHeaderBuyPrice:SetTextColor(Color(196, 211, 211))
    self.itemHeaderBuyPrice:SetContentAlignment(5)
    self.itemHeaderMode = self.itemHeader:Add("DLabel")
    self.itemHeaderMode:Dock(RIGHT)
    self.itemHeaderMode:SetWide(136)
    self.itemHeaderMode:DockMargin(6, 0, 0, 0)
    self.itemHeaderMode:SetText(L("mode"))
    self.itemHeaderMode:SetFont("LiliaFont.15")
    self.itemHeaderMode:SetTextColor(Color(196, 211, 211))
    self.itemHeaderMode:SetContentAlignment(5)
    self.itemHeaderName = self.itemHeader:Add("DLabel")
    self.itemHeaderName:Dock(FILL)
    self.itemHeaderName:SetText(L("name"))
    self.itemHeaderName:SetFont("LiliaFont.15")
    self.itemHeaderName:SetTextColor(Color(196, 211, 211))
    self.itemHeaderName:SetContentAlignment(4)
    self.itemList = self.itemsFrame:Add("liaScrollPanel")
    self.itemList:Dock(FILL)
    self.itemList:DockPadding(0, 0, 4, 12)
    self.itemList.Paint = function() end
    self.lines = {}
    self:ReloadItemList()
    self.itemList:InvalidateLayout(true)
    self:UpdateItemColumnLayout()
    self:listenForUpdates()
end

function PANEL:initializeGeneralInfoPanel(entity)
    if not IsValid(entity) or not IsValid(self.generalScroll) then return end
    addEditorSection(self.generalScroll, L("vendorGeneralInfo"), L("vendorGeneralInfoSubtitle"))
    self.nameLabel = addEditorFieldLabel(self.generalScroll, L("name"))
    self.name = self.generalScroll:Add("liaEntry")
    self.name:Dock(TOP)
    self.name:DockMargin(0, 0, 0, 12)
    self.name:SetTall(38)
    self.name:SetValue(entity:getName())
    styleEditorEntry(self.name)
    self.name.action = function(value)
        local currentName = lia.vendor.getVendorProperty(entity, "name")
        if currentName == value then return end
        if not value or value == "" then value = L("vendorDefaultName") end
        if self.name.processing then return end
        self.name.processing = true
        lia.vendor.editor.name(value)
        timer.Simple(0.1, function() if IsValid(self) and IsValid(self.name) then self.name.processing = false end end)
    end

    self.modelLabel = addEditorFieldLabel(self.generalScroll, L("model"))
    self.model = self.generalScroll:Add("liaEntry")
    self.model:Dock(TOP)
    self.model:DockMargin(0, 0, 0, 12)
    self.model:SetTall(38)
    self.model:SetValue(entity:GetModel())
    styleEditorEntry(self.model)
    self.model.action = function(value)
        local modelText = value:lower()
        if entity:GetModel():lower() ~= modelText then lia.vendor.editor.model(modelText) end
    end

    if entity:SkinCount() > 1 then
        self.skinLabel = addEditorFieldLabel(self.generalScroll, L("skin"))
        self.skin = self.generalScroll:Add("liaSlider")
        self.skin:Dock(TOP)
        self.skin:DockMargin(0, 0, 0, 12)
        self.skin:SetText(L("skin"))
        self.skin:SetRange(0, entity:SkinCount() - 1, 0)
        self.skin:SetValue(entity:GetSkin())
        self.skin.OnValueChanged = function(_, value)
            value = math.Round(value)
            if entity:GetSkin() ~= value then lia.vendor.editor.skin(value) end
        end
    end

    self.animationLabel = addEditorFieldLabel(self.generalScroll, L("animation"))
    self.animation = self.generalScroll:Add("liaComboBox")
    self.animation:Dock(TOP)
    self.animation:DockMargin(0, 0, 0, 8)
    self.animation:SetTall(38)
    self.animation:PostInit()
    self.animation:SetText(L("vendorPickAnimation"))
    self.animation:SetTooltip(L("vendorAnimationTooltip"))
    self:refreshAnimationDropdown()
    local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
    self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation)
    self.animation:ChooseOption(currentAnimation == "" and L("none") or currentAnimation)
    self.animation.OnSelect = function(_, _, value)
        if not IsValid(self.animation) then return end
        local selectedValue = value or self.animation:GetValue()
        if not isstring(selectedValue) then return end
        if selectedValue == L("none") then selectedValue = "" end
        if lia.vendor.editor.animation then lia.vendor.editor.animation(selectedValue) end
        timer.Simple(0.1, function() if IsValid(self.animation) then self.animation:SetValue(selectedValue == "" and L("none") or selectedValue) end end)
    end

    addEditorSection(self.generalScroll, L("preset"))
    self.presetActions = self.generalScroll:Add("DPanel")
    self.presetActions:Dock(TOP)
    self.presetActions:DockMargin(0, 0, 0, 8)
    self.presetActions:SetTall(38)
    self.presetActions.Paint = function() end
    self.presetButton = self.presetActions:Add("liaButton")
    self.presetButton:Dock(LEFT)
    self.presetButton:SetWide(104)
    self.presetButton:DockMargin(0, 0, 6, 0)
    self.presetButton:SetText(L("loadThing", L("preset")))
    self.presetButton:SetTooltip(L("vendorLoadPresetTooltip"))
    styleEditorButton(self.presetButton)
    self.presetButton.DoClick = function() self:openPresetSelector() end
    self.savePresetButton = self.presetActions:Add("liaButton")
    self.savePresetButton:Dock(LEFT)
    self.savePresetButton:SetWide(104)
    self.savePresetButton:DockMargin(0, 0, 6, 0)
    self.savePresetButton:SetText(L("vendorSavePreset"))
    styleEditorButton(self.savePresetButton)
    self.savePresetButton.DoClick = function()
        LocalPlayer():requestString("@vendorSavePresetTitle", "@vendorSavePresetPrompt", function(text)
            if not text or text == "" then return end
            net.Start("liaVendorSavePreset")
            net.WriteString(text)
            net.WriteTable(liaVendorEnt.items or {})
            net.SendToServer()
            self:refreshPresetButton()
        end)
    end

    self.deletePresetButton = self.presetActions:Add("liaButton")
    self.deletePresetButton:Dock(FILL)
    self.deletePresetButton:SetText(L("vendorDeletePreset"))
    self.deletePresetButton:SetTooltip(L("vendorDeletePresetTooltip"))
    styleEditorButton(self.deletePresetButton, true)
    self.deletePresetButton.DoClick = function() self:openDeletePresetSelector() end
    addEditorSection(self.generalScroll, L("vendorStockToggle"))
    self.stockEnabledButton = self.generalScroll:Add("liaButton")
    self.stockEnabledButton:Dock(TOP)
    self.stockEnabledButton:DockMargin(0, 0, 0, 8)
    self.stockEnabledButton:SetTall(38)
    styleEditorButton(self.stockEnabledButton)
    self.stockEnabledButton.DoClick = function()
        local enabled = lia.vendor.getVendorProperty(entity, "stockEnabled")
        lia.vendor.editor.stockEnabled(not enabled)
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:updateStockEnabledButton()
                self:ReloadItemList(self.lastSearchValue)
            end
        end)
    end

    self:updateStockEnabledButton()
    addEditorSection(self.generalScroll, L("vendorFaction"), L("vendorFactionAccessSubtitle"))
    self.factionAccessPanel = self.generalScroll:Add("DPanel")
    self.factionAccessPanel:Dock(TOP)
    self.factionAccessPanel:DockMargin(0, 0, 0, 10)
    self.factionAccessPanel:SetTall(270)
    self.factionAccessPanel:DockPadding(8, 8, 8, 8)
    self.factionAccessPanel.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 7, Color(8, 23, 28, 230), Color(accent.r, accent.g, accent.b, 55))
    end

    self.factionScroll = self.factionAccessPanel:Add("liaScrollPanel")
    self.factionScroll:Dock(FILL)
    self.factionScroll:DockPadding(0, 0, 4, 0)
    self.factionScroll.Paint = function() end
    local hasBodygroups = false
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) > 1 then
            hasBodygroups = true
            break
        end
    end

    if hasBodygroups then
        addEditorSection(self.generalScroll, L("bodygroups"))
        self.bodygroupsPanel = self.generalScroll:Add("DPanel")
        self.bodygroupsPanel:Dock(TOP)
        self.bodygroupsPanel:DockMargin(0, 0, 0, 10)
        self.bodygroupsPanel:SetTall(230)
        self.bodygroupsPanel:DockPadding(8, 8, 8, 8)
        self.bodygroupsPanel.Paint = function(_, w, h)
            local accent = getVendorThemeColors()
            drawVendorPanel(0, 0, w, h, 7, Color(8, 23, 28, 230), Color(accent.r, accent.g, accent.b, 55))
        end

        local bodygroupsScroll = self.bodygroupsPanel:Add("liaScrollPanel")
        bodygroupsScroll:Dock(FILL)
        bodygroupsScroll:DockPadding(0, 0, 4, 0)
        for i = 0, entity:GetNumBodyGroups() - 1 do
            if entity:GetBodygroupCount(i) <= 1 then continue end
            local bodygroupLabel = addEditorFieldLabel(bodygroupsScroll, entity:GetBodygroupName(i))
            bodygroupLabel:SetFont("LiliaFont.16")
            local slider = bodygroupsScroll:Add("liaSlider")
            slider:Dock(TOP)
            slider:DockMargin(0, 0, 0, 10)
            slider:SetText("")
            slider:SetRange(0, entity:GetBodygroupCount(i) - 1, 0)
            slider:SetValue(entity:GetBodygroup(i))
            slider.OnValueChanged = function(_, value)
                value = math.Round(value)
                timer.Create("liaVendorBodygroup" .. i, 0.3, 1, function() if IsValid(slider) then lia.vendor.editor.bodygroup(i, value) end end)
            end
        end
    end

    self.generalScroll:InvalidateLayout(true)
end

function PANEL:populateFactionPanel()
    if not IsValid(self.factionScroll) then return end
    self.factionScroll:Clear()
    self.factions = {}
    self.classes = {}
    local entity = liaVendorEnt
    for factionID, faction in ipairs(lia.faction.indices) do
        local classRows = {}
        for classID, class in ipairs(lia.class.list) do
            if class.faction == factionID then
                classRows[#classRows + 1] = {
                    id = classID,
                    data = class
                }
            end
        end

        local card = self.factionScroll:Add("DPanel")
        card:Dock(TOP)
        card:DockMargin(0, 0, 0, 6)
        card.expanded = #classRows > 0 and IsValid(entity) and entity:isFactionAllowed(factionID) or false
        card.Paint = function(_, w, h)
            local accent = getVendorThemeColors()
            drawVendorPanel(0, 0, w, h, 6, Color(10, 26, 31, 232), Color(accent.r, accent.g, accent.b, 48))
        end

        local header = card:Add("DButton")
        header:Dock(TOP)
        header:SetTall(38)
        header:SetText("")
        header.Paint = function(s, w, h)
            local accent = getVendorThemeColors()
            if s:IsHovered() then drawVendorPanel(0, 0, w, h, 6, Color(accent.r, accent.g, accent.b, 20)) end
            draw.SimpleText(#classRows > 0 and (card.expanded and "−" or "+") or "", "LiliaFont.18", 12, h * 0.5, accent, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(L(faction.name), "LiliaFont.17", 66, h * 0.5, Color(225, 238, 238), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local factionCheckbox = header:Add("liaCheckbox")
        factionCheckbox:SetSize(38, 24)
        factionCheckbox:SetPos(22, 7)
        factionCheckbox.factionID = factionID
        factionCheckbox.OnChange = function(checkbox, state)
            if checkbox.suppressVendorSync then return end
            lia.vendor.editor.faction(factionID, state)
        end

        self.factions[factionID] = factionCheckbox
        local classContainer = card:Add("DPanel")
        classContainer:Dock(TOP)
        classContainer:DockMargin(10, 0, 10, 8)
        classContainer.Paint = function(_, w)
            local accent = getVendorThemeColors()
            surface.SetDrawColor(accent.r, accent.g, accent.b, 30)
            surface.DrawRect(0, 0, w, 1)
        end

        for _, classInfo in ipairs(classRows) do
            local classRow = classContainer:Add("DPanel")
            classRow:Dock(TOP)
            classRow:SetTall(27)
            classRow:DockMargin(12, 3, 0, 0)
            classRow.Paint = function() end
            local classCheckbox = classRow:Add("liaCheckbox")
            classCheckbox:Dock(LEFT)
            classCheckbox:SetWide(40)
            classCheckbox.classID = classInfo.id
            classCheckbox.factionID = factionID
            classCheckbox.OnChange = function(checkbox, state)
                if checkbox.suppressVendorSync then return end
                lia.vendor.editor.class(classInfo.id, state)
            end

            self.classes[classInfo.id] = classCheckbox
            local classLabel = classRow:Add("DLabel")
            classLabel:Dock(FILL)
            classLabel:SetText(L(classInfo.data.name))
            classLabel:SetFont("LiliaFont.15")
            classLabel:SetTextColor(Color(186, 204, 204))
            classLabel:SetContentAlignment(4)
        end

        local function updateCardHeight()
            classContainer:SetVisible(card.expanded and #classRows > 0)
            classContainer:SetTall(card.expanded and #classRows * 30 + 6 or 0)
            card:SetTall(38 + (card.expanded and #classRows * 30 + 14 or 0))
            card:InvalidateLayout(true)
            if IsValid(self.factionScroll) then self.factionScroll:InvalidateLayout(true) end
        end

        header.DoClick = function()
            if #classRows <= 0 then return end
            card.expanded = not card.expanded
            updateCardHeight()
        end

        updateCardHeight()
    end

    self:updateFactionChecked()
    hook.Add("VendorFactionUpdated", self, self.updateFactionChecked)
    hook.Add("VendorClassUpdated", self, self.updateFactionChecked)
end

function PANEL:updateFactionChecked()
    local entity = liaVendorEnt
    if not entity then return end
    for id, panel in pairs(self.factions) do
        panel.suppressVendorSync = true
        panel:SetChecked(entity:isFactionAllowed(id))
        panel.suppressVendorSync = nil
    end

    for id, panel in pairs(self.classes) do
        panel.suppressVendorSync = true
        panel:SetChecked(entity:isClassAllowed(id))
        panel.suppressVendorSync = nil
    end
end

function PANEL:GetItemColumnWidths()
    local contentWidth = IsValid(self.itemList) and self.itemList:GetWide() or 900
    local stockEnabled = IsValid(liaVendorEnt) and lia.vendor.getVendorProperty(liaVendorEnt, "stockEnabled") or false
    local compact = contentWidth < 760
    local mode = math.Clamp(math.floor(contentWidth * (compact and 0.17 or 0.18)), 112, 144)
    local price = math.Clamp(math.floor(contentWidth * (compact and 0.105 or 0.115)), 78, 98)
    local stock = stockEnabled and math.Clamp(math.floor(contentWidth * 0.078), 60, 74) or 0
    local currentStock = stockEnabled and math.Clamp(math.floor(contentWidth * 0.072), 56, 70) or 0
    return {
        mode = mode,
        buy = price,
        sell = price,
        stock = stock,
        currentStock = currentStock
    }
end

function PANEL:UpdateItemColumnLayout()
    local widths = self:GetItemColumnWidths()
    if IsValid(self.itemHeaderMode) then self.itemHeaderMode:SetWide(widths.mode) end
    if IsValid(self.itemHeaderBuyPrice) then self.itemHeaderBuyPrice:SetWide(widths.buy) end
    if IsValid(self.itemHeaderSellPrice) then self.itemHeaderSellPrice:SetWide(widths.sell) end
    if IsValid(self.itemHeaderStock) then self.itemHeaderStock:SetWide(widths.stock) end
    if IsValid(self.itemHeaderCurrentStock) then self.itemHeaderCurrentStock:SetWide(widths.currentStock) end
    for _, row in pairs(self.lines or {}) do
        if IsValid(row) and row.ApplyColumnLayout then row:ApplyColumnLayout() end
    end
end

function PANEL:PerformLayout(width, height)
    self.BaseClass.PerformLayout(self, width, height)
    if IsValid(self.cls) then
        self.cls:SetSize(24, 24)
        self.cls:SetPos(width - 30, 4)
    end

    if IsValid(self.generalFrame) then self.generalFrame:SetWide(math.Clamp(width * 0.265, 320, 400)) end
    if IsValid(self.itemSearchBar) and IsValid(self.itemsHeaderCard) then self.itemSearchBar:SetWide(math.Clamp(math.floor(self.itemsHeaderCard:GetWide() * 0.29), 180, 280)) end
    self:UpdateItemColumnLayout()
    if IsValid(self.itemList) then self.itemList:InvalidateLayout(true) end
end

local VendorText = {
    [VENDOR_SELLANDBUY] = "buyOnlynSell",
    [VENDOR_BUYONLY] = "buyOnly",
    [VENDOR_SELLONLY] = "sellOnly",
}

local VendorModeChoices = {
    {
        text = L("none"),
        value = nil
    },
    {
        text = L("buyOnlynSell"),
        value = VENDOR_SELLANDBUY
    },
    {
        text = L("buyOnly"),
        value = VENDOR_BUYONLY
    },
    {
        text = L("sellOnly"),
        value = VENDOR_SELLONLY
    }
}

function PANEL:getModeText(mode)
    return mode and L(VendorText[mode]) or L("none")
end

function PANEL:notifyNumberError(fieldName)
    LocalPlayer():notifyError(string.format("%s must be a number.", fieldName))
end

function PANEL:getItemRowValue(itemType)
    local entity = liaVendorEnt
    local itemTable = lia.item.list[itemType]
    if not IsValid(entity) or not itemTable then return end
    local currentStock, maxStock = entity:getStock(itemType)
    return {
        item = itemType,
        name = itemTable.getName and itemTable:getName() or L(itemTable.name),
        desc = itemTable.getDesc and itemTable:getDesc() or itemTable.desc or L("noDesc"),
        mode = entity.items[itemType] and entity.items[itemType][VENDOR_MODE],
        buyPrice = entity.items[itemType] and (entity.items[itemType][VENDOR_BUYPRICE] ~= nil and entity.items[itemType][VENDOR_BUYPRICE] or entity.items[itemType][VENDOR_PRICE]),
        sellPrice = entity.items[itemType] and (entity.items[itemType][VENDOR_SELLPRICE] ~= nil and entity.items[itemType][VENDOR_SELLPRICE] or entity.items[itemType][VENDOR_PRICE]),
        stock = maxStock,
        currentStock = currentStock
    }
end

local ROW = {}
function ROW:Init()
    self:SetTall(48)
    self:DockPadding(7, 5, 8, 5)
    self.hoverAlpha = 0
    self.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        if self:IsHovered() then
            self.hoverAlpha = math.min(self.hoverAlpha + FrameTime() * 7, 1)
        else
            self.hoverAlpha = math.max(self.hoverAlpha - FrameTime() * 7, 0)
        end

        local base = self._rowIndex and self._rowIndex % 2 == 0 and Color(9, 25, 30, 224) or Color(7, 22, 27, 218)
        drawVendorPanel(0, 0, w, h, 4, base, Color(accent.r, accent.g, accent.b, 34 + 36 * self.hoverAlpha))
        if self.hoverAlpha > 0 then
            surface.SetDrawColor(accent.r, accent.g, accent.b, 12 * self.hoverAlpha)
            surface.DrawRect(0, 0, w, h)
        end
    end

    self.currentStockEntry = self:Add("liaEntry")
    self.currentStockEntry:Dock(RIGHT)
    self.currentStockEntry:SetWide(68)
    self.currentStockEntry:DockMargin(6, 0, 0, 0)
    self.currentStockEntry:SetNumeric(true)
    self.currentStockEntry:SetPlaceholderText("Cur.")
    styleEditorEntry(self.currentStockEntry)
    self.currentStockEntry.action = function() self:CommitCurrentStock() end
    self.stockEntry = self:Add("liaEntry")
    self.stockEntry:Dock(RIGHT)
    self.stockEntry:SetWide(72)
    self.stockEntry:DockMargin(6, 0, 0, 0)
    self.stockEntry:SetNumeric(true)
    self.stockEntry:SetPlaceholderText("Max")
    styleEditorEntry(self.stockEntry)
    self.stockEntry.action = function() self:CommitStock() end
    self.sellPriceEntry = self:Add("liaEntry")
    self.sellPriceEntry:Dock(RIGHT)
    self.sellPriceEntry:SetWide(92)
    self.sellPriceEntry:DockMargin(6, 0, 0, 0)
    self.sellPriceEntry:SetNumeric(true)
    self.sellPriceEntry:SetPlaceholderText(L("vendorSellPriceLabel"))
    styleEditorEntry(self.sellPriceEntry)
    self.sellPriceEntry.action = function() self:CommitSellPrice() end
    self.buyPriceEntry = self:Add("liaEntry")
    self.buyPriceEntry:Dock(RIGHT)
    self.buyPriceEntry:SetWide(92)
    self.buyPriceEntry:DockMargin(6, 0, 0, 0)
    self.buyPriceEntry:SetNumeric(true)
    self.buyPriceEntry:SetPlaceholderText(L("vendorBuyPriceLabel"))
    styleEditorEntry(self.buyPriceEntry)
    self.buyPriceEntry.action = function() self:CommitBuyPrice() end
    self.modeCombo = self:Add("liaComboBox")
    self.modeCombo:Dock(RIGHT)
    self.modeCombo:SetWide(136)
    self.modeCombo:DockMargin(6, 0, 0, 0)
    self.modeCombo:PostInit()
    self.modeCombo:SetTextColor(Color(225, 238, 238))
    for _, choice in ipairs(VendorModeChoices) do
        self.modeCombo:AddChoice(choice.text, choice.value)
    end

    self.modeCombo.OnSelect = function(_, _, text, value)
        if self.isRefreshing or not IsValid(self.editor) then return end
        lia.vendor.editor.mode(self.itemID, value)
        self.modeCombo:SetValue(text)
    end

    self.itemIdentity = self:Add("DPanel")
    self.itemIdentity:Dock(FILL)
    self.itemIdentity.Paint = function() end
    self.iconFrame = self.itemIdentity:Add("DPanel")
    self.iconFrame:Dock(LEFT)
    self.iconFrame:SetWide(36)
    self.iconFrame:DockMargin(0, 0, 10, 0)
    self.iconFrame.Paint = function(_, w, h)
        local accent = getVendorThemeColors()
        drawVendorPanel(0, 0, w, h, 4, Color(13, 30, 35, 230), Color(accent.r, accent.g, accent.b, 55))
        if self.itemIconMaterial then drawVendorIcon(self.itemIconMaterial, 3, 3, w - 6, h - 6, color_white) end
    end

    self.modelIcon = self.iconFrame:Add("liaItemIcon")
    self.modelIcon:Dock(FILL)
    self.modelIcon.Paint = function() end
    self.nameLabel = self.itemIdentity:Add("DLabel")
    self.nameLabel:Dock(FILL)
    self.nameLabel:SetFont("LiliaFont.16")
    self.nameLabel:SetTextColor(Color(225, 238, 238))
    self.nameLabel:SetContentAlignment(4)
end

function ROW:SetEditor(editor)
    self.editor = editor
    self:ApplyColumnLayout()
end

function ROW:ApplyColumnLayout()
    if not IsValid(self.editor) or not self.editor.GetItemColumnWidths then return end
    local widths = self.editor:GetItemColumnWidths()
    self.modeCombo:SetWide(widths.mode)
    self.buyPriceEntry:SetWide(widths.buy)
    self.sellPriceEntry:SetWide(widths.sell)
    self.stockEntry:SetWide(widths.stock)
    self.currentStockEntry:SetWide(widths.currentStock)
end

function ROW:SetItemID(itemID)
    self.itemID = itemID
end

function ROW:CommitBuyPrice()
    if self.isRefreshing or not IsValid(self.editor) then return end
    local raw = string.Trim(self.buyPriceEntry:GetValue() or "")
    if raw == "" then
        lia.vendor.editor.buyPrice(self.itemID, nil)
        return
    end

    local value = tonumber(raw)
    if not isnumber(value) then
        self.editor:notifyNumberError("buy price")
        self:Refresh()
        return
    end

    value = math.max(math.Round(value), 0)
    self.buyPriceEntry:SetValue(value)
    lia.vendor.editor.buyPrice(self.itemID, value)
end

function ROW:CommitSellPrice()
    if self.isRefreshing or not IsValid(self.editor) then return end
    local raw = string.Trim(self.sellPriceEntry:GetValue() or "")
    if raw == "" then
        lia.vendor.editor.sellPrice(self.itemID, nil)
        return
    end

    local value = tonumber(raw)
    if not isnumber(value) then
        self.editor:notifyNumberError("sell price")
        self:Refresh()
        return
    end

    value = math.max(math.Round(value), 0)
    self.sellPriceEntry:SetValue(value)
    lia.vendor.editor.sellPrice(self.itemID, value)
end

function ROW:CommitStock()
    if self.isRefreshing or not IsValid(self.editor) then return end
    if not self:IsStockEnabled() then
        self.stockEntry:SetValue("")
        return
    end

    local raw = string.Trim(self.stockEntry:GetValue() or "")
    if raw == "" then
        lia.vendor.editor.stockDisable(self.itemID)
        return
    end

    local stockValue = tonumber(raw)
    if not isnumber(stockValue) then
        self.editor:notifyNumberError(L("stock"))
        self:Refresh()
        return
    end

    stockValue = math.max(math.Round(stockValue), 1)
    self.stockEntry:SetValue(stockValue)
    lia.vendor.editor.stockMax(self.itemID, stockValue)
end

function ROW:CommitCurrentStock()
    if self.isRefreshing or not IsValid(self.editor) then return end
    if not self:IsStockEnabled() then
        self.currentStockEntry:SetValue("0")
        return
    end

    local raw = string.Trim(self.currentStockEntry:GetValue() or "")
    local currentStock = raw == "" and 0 or tonumber(raw)
    if not isnumber(currentStock) then
        self.editor:notifyNumberError(L("vendorEditCurStock"))
        self:Refresh()
        return
    end

    currentStock = math.max(math.Round(currentStock), 0)
    if isnumber(self.currentMaxStockValue) then currentStock = math.min(currentStock, self.currentMaxStockValue) end
    self.currentStockEntry:SetValue(currentStock)
    lia.vendor.editor.stock(self.itemID, currentStock)
end

function ROW:IsStockEnabled()
    return IsValid(liaVendorEnt) and lia.vendor.getVendorProperty(liaVendorEnt, "stockEnabled") or false
end

function ROW:UpdateStockFieldState()
    local enabled = self:IsStockEnabled()
    if IsValid(self.stockEntry) then
        self.stockEntry:SetEditable(enabled)
        self.stockEntry:SetDisabled(not enabled)
        self.stockEntry:SetVisible(enabled)
    end

    if IsValid(self.currentStockEntry) then
        self.currentStockEntry:SetEditable(enabled)
        self.currentStockEntry:SetDisabled(not enabled)
        self.currentStockEntry:SetVisible(enabled)
    end
end

function ROW:Refresh()
    if not IsValid(self.editor) then return end
    local data = self.editor:getItemRowValue(self.itemID)
    if not data then return end
    self.isRefreshing = true
    self.nameLabel:SetText(data.name)
    self.nameLabel:SetTooltip(data.desc or data.name)
    self.currentStockValue = data.stock
    self.currentMaxStockValue = data.stock
    self.currentItemStockValue = data.currentStock
    self.modeCombo:SetValue(self.editor:getModeText(data.mode))
    self.buyPriceEntry:SetValue(data.buyPrice ~= nil and tostring(data.buyPrice) or "")
    self.sellPriceEntry:SetValue(data.sellPrice ~= nil and tostring(data.sellPrice) or "")
    self.currentStockEntry:SetValue(data.currentStock ~= nil and tostring(data.currentStock) or "0")
    self.stockEntry:SetValue(data.stock ~= nil and tostring(data.stock) or "")
    self:UpdateStockFieldState()
    self.currentStockEntry:SetTooltip(L("vendorEditCurStock"))
    self.stockEntry:SetTooltip(data.stock ~= nil and string.format("%s: %s", L("stock"), data.stock) or L("disable"))
    local item = lia.item.list[self.itemID]
    self.itemIconMaterial = nil
    if item and item.icon then
        self.itemIconMaterial = resolveVendorIcon(item.icon)
        self.modelIcon:SetVisible(false)
    elseif item and item.model then
        self.modelIcon:SetVisible(true)
        self.modelIcon:SetModel(item.model, item.skin or 0)
    else
        self.modelIcon:SetVisible(false)
    end

    self.isRefreshing = false
end

function ROW:OnMousePressed(code)
    if code == MOUSE_RIGHT and IsValid(self.editor) then
        self.editor:OnRowRightClick(nil, {
            item = self.itemID
        })
    end
end

vgui.Register("liaVendorEditorItemRow", ROW, "DPanel")
function PANEL:OnThemeChanged()
    if not IsValid(self) then return end
    self:InvalidateLayout(true)
    if IsValid(self.itemList) then self.itemList:InvalidateLayout(true) end
end

function PANEL:OnRemove()
    hook.Remove("OnThemeChanged", self)
    if IsValid(lia.gui.editorFaction) then lia.gui.editorFaction:Remove() end
    if IsValid(self.presetSelector) then self.presetSelector:Remove() end
    if IsValid(self.deletePresetSelector) then self.deletePresetSelector:Remove() end
    if self.refreshTimer then timer.Remove(self.refreshTimer) end
    if self.searchTimer then timer.Remove(self.searchTimer) end
end

function PANEL:updateVendor(key, value)
    net.Start("liaVendorEdit")
    net.WriteString(key)
    if value ~= nil then
        if istable(value) then
            net.WriteUInt(#value, 16)
            for _, v in ipairs(value) do
                net.WriteType(v)
            end
        else
            net.WriteType(value)
        end
    end

    net.SendToServer()
end

function PANEL:refreshAnimationDropdown()
    if not IsValid(self.animation) then return end
    self.animation:Clear()
    self.animation:AddChoice(L("none"))
    if IsValid(liaVendorEnt) then
        local sequenceList = liaVendorEnt:GetSequenceList()
        if sequenceList and #sequenceList > 0 then
            for _, sequenceName in ipairs(sequenceList) do
                if isstring(sequenceName) and sequenceName ~= "" then self.animation:AddChoice(sequenceName) end
            end
        end
    end

    local currentAnimation = lia.vendor.getVendorProperty(liaVendorEnt, "animation")
    if isstring(currentAnimation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
end

function PANEL:refreshPresetButton()
    if not IsValid(self.presetButton) then return end
    self.presetButton:SetText(L("loadThing", L("preset")))
end

function PANEL:updateStockEnabledButton()
    if not IsValid(self.stockEnabledButton) or not IsValid(liaVendorEnt) then return end
    local enabled = lia.vendor.getVendorProperty(liaVendorEnt, "stockEnabled")
    self.stockEnabledButton:SetText(enabled and L("enabled") or L("disabled"))
end

function PANEL:updateStockColumnVisibility()
    if not IsValid(self.itemHeaderStock) or not IsValid(self.itemHeaderCurrentStock) or not IsValid(liaVendorEnt) then return end
    local enabled = lia.vendor.getVendorProperty(liaVendorEnt, "stockEnabled")
    self.itemHeaderStock:SetVisible(enabled)
    self.itemHeaderCurrentStock:SetVisible(enabled)
    self:UpdateItemColumnLayout()
end

function PANEL:openPresetSelector()
    if IsValid(self.presetSelector) then
        self.presetSelector:Remove()
        return
    end

    self.presetSelector = vgui.Create("DPanel")
    self.presetSelector:SetSize(700, 500)
    self.presetSelector:Center()
    self.presetSelector:MakePopup()
    self.presetSelector:SetBackgroundColor(Color(0, 0, 0, 0))
    self.presetSelector.OnRemove = function()
        if IsValid(self.leftFrame) then self.leftFrame:Remove() end
        if IsValid(self.rightFrame) then self.rightFrame:Remove() end
    end

    self.leftFrame = self.presetSelector:Add("liaFrame")
    self.leftFrame:SetTitle(L("loadThing", L("preset")))
    self.leftFrame:SetSize(300, 500)
    self.leftFrame:SetPos(0, 0)
    self.leftFrame.OnRemove = function() if IsValid(self.presetSelector) then self.presetSelector:Remove() end end
    local leftScroll = self.leftFrame:Add("liaScrollPanel")
    leftScroll:Dock(FILL)
    leftScroll:DockPadding(8, 8, 8, 8)
    local noneButton = leftScroll:Add("liaButton")
    noneButton:Dock(TOP)
    noneButton:DockMargin(0, 0, 0, 8)
    noneButton:SetText(L("none"))
    noneButton:SetTall(40)
    noneButton.DoClick = function() self:showPresetDetails("none", {}) end
    if lia.vendor.presets then
        local sortedPresets = {}
        for presetName, presetData in pairs(lia.vendor.presets) do
            if isstring(presetName) and presetName ~= "" and presetName ~= "none" then
                table.insert(sortedPresets, {
                    name = presetName,
                    data = presetData
                })
            end
        end

        table.sort(sortedPresets, function(a, b) return a.name < b.name end)
        for _, preset in ipairs(sortedPresets) do
            local presetButton = leftScroll:Add("liaButton")
            presetButton:Dock(TOP)
            presetButton:DockMargin(0, 0, 0, 8)
            presetButton:SetText(preset.name)
            presetButton:SetTall(40)
            presetButton.DoClick = function() self:showPresetDetails(preset.name, preset.data) end
        end
    end

    self.rightFrame = self.presetSelector:Add("liaFrame")
    self.rightFrame:SetTitle(L("vendorPresetDetails"))
    self.rightFrame:SetSize(400, 500)
    self.rightFrame:SetPos(300, 0)
    self.rightFrame.OnRemove = function() if IsValid(self.presetSelector) then self.presetSelector:Remove() end end
    self.presetDetailsScroll = self.rightFrame:Add("liaScrollPanel")
    self.presetDetailsScroll:Dock(FILL)
    self.presetDetailsScroll:DockPadding(10, 10, 10, 10)
    self:showPresetDetails(nil)
    local submitButton = self.rightFrame:Add("liaButton")
    submitButton:Dock(BOTTOM)
    submitButton:DockMargin(10, 10, 10, 10)
    submitButton:SetText(L("load"))
    submitButton:SetTall(40)
    submitButton:SetDisabled(true)
    submitButton.DoClick = function()
        if self.selectedPreset then
            local presetName = string.lower(self.selectedPreset)
            net.Start("liaVendorLoadPreset")
            net.WriteString(presetName)
            net.SendToServer()
            self.presetSelector:Remove()
        end
    end

    self.presetSubmitButton = submitButton
end

function PANEL:openDeletePresetSelector()
    if IsValid(self.deletePresetSelector) then
        self.deletePresetSelector:Remove()
        return
    end

    self.deletePresetSelector = vgui.Create("DPanel")
    self.deletePresetSelector:SetSize(700, 500)
    self.deletePresetSelector:Center()
    self.deletePresetSelector:MakePopup()
    self.deletePresetSelector:SetBackgroundColor(Color(0, 0, 0, 0))
    self.deletePresetSelector._removing = false
    self.deletePresetSelector.OnRemove = function()
        self.deletePresetSelector._removing = true
        if IsValid(self.deleteLeftFrame) then self.deleteLeftFrame:Remove() end
        if IsValid(self.deleteRightFrame) then self.deleteRightFrame:Remove() end
    end

    self.deleteLeftFrame = self.deletePresetSelector:Add("liaFrame")
    self.deleteLeftFrame:SetTitle(L("vendorDeletePreset"))
    self.deleteLeftFrame:SetSize(300, 500)
    self.deleteLeftFrame:SetPos(0, 0)
    self.deleteLeftFrame.OnRemove = function() if IsValid(self.deletePresetSelector) and not self.deletePresetSelector._removing then self.deletePresetSelector:Remove() end end
    local leftScroll = self.deleteLeftFrame:Add("liaScrollPanel")
    leftScroll:Dock(FILL)
    leftScroll:DockPadding(8, 8, 8, 8)
    self.deleteSelectedPreset = nil
    if lia.vendor.presets then
        local sortedPresets = {}
        for presetName, presetData in pairs(lia.vendor.presets) do
            if isstring(presetName) and presetName ~= "" and presetName ~= "none" then
                table.insert(sortedPresets, {
                    name = presetName,
                    data = presetData
                })
            end
        end

        table.sort(sortedPresets, function(a, b) return a.name < b.name end)
        for _, preset in ipairs(sortedPresets) do
            local presetButton = leftScroll:Add("liaButton")
            presetButton:Dock(TOP)
            presetButton:DockMargin(0, 0, 0, 8)
            presetButton:SetText(preset.name)
            presetButton:SetTall(40)
            presetButton.DoClick = function()
                self.deleteSelectedPreset = preset.name
                self:showDeletePresetDetails(preset.name, preset.data)
            end
        end
    end

    self.deleteRightFrame = self.deletePresetSelector:Add("liaFrame")
    self.deleteRightFrame:SetTitle(L("vendorDeletePreset"))
    self.deleteRightFrame:SetSize(400, 500)
    self.deleteRightFrame:SetPos(300, 0)
    self.deleteRightFrame.OnRemove = function() if IsValid(self.deletePresetSelector) and not self.deletePresetSelector._removing then self.deletePresetSelector:Remove() end end
    self.deletePresetDetailsScroll = self.deleteRightFrame:Add("liaScrollPanel")
    self.deletePresetDetailsScroll:Dock(FILL)
    self.deletePresetDetailsScroll:DockPadding(10, 10, 10, 10)
    self:showDeletePresetDetails(nil)
    local deleteButton = self.deleteRightFrame:Add("liaButton")
    deleteButton:Dock(BOTTOM)
    deleteButton:DockMargin(10, 10, 10, 10)
    deleteButton:SetText(L("delete"))
    deleteButton:SetTall(40)
    deleteButton:SetDisabled(true)
    deleteButton.DoClick = function()
        if self.deleteSelectedPreset then
            local presetName = string.lower(self.deleteSelectedPreset)
            net.Start("liaVendorDeletePreset")
            net.WriteString(presetName)
            net.SendToServer()
            self.deletePresetSelector:Remove()
        end
    end

    self.deleteSubmitButton = deleteButton
end

function PANEL:showDeletePresetDetails(presetName, presetData)
    self.deletePresetDetailsScroll:Clear()
    if not presetName or not presetData then
        local displayText = L("vendorNoPresetSelected")
        local emptyPanel = self.deletePresetDetailsScroll:Add("DPanel")
        emptyPanel:Dock(TOP)
        emptyPanel:DockMargin(0, 20, 0, 0)
        emptyPanel:SetTall(100)
        emptyPanel.Paint = function(_, w, h)
            local themeColor = lia.color.theme or {}
            local bgColor = themeColor.secondary or Color(35, 35, 40, 255)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end

        local label = emptyPanel:Add("DLabel")
        label:Dock(FILL)
        label:SetText(displayText)
        label:SetFont("LiliaFont.18b")
        label:SetTextColor(Color(150, 150, 150))
        label:SetContentAlignment(5)
        if IsValid(self.deleteSubmitButton) then self.deleteSubmitButton:SetDisabled(true) end
        return
    end

    if IsValid(self.deleteSubmitButton) then self.deleteSubmitButton:SetDisabled(false) end
    local nameLabel = self.deletePresetDetailsScroll:Add("DLabel")
    nameLabel:Dock(TOP)
    nameLabel:DockMargin(0, 0, 0, 10)
    nameLabel:SetText(L("name") .. ": " .. presetName)
    nameLabel:SetFont("LiliaFont.20b")
    nameLabel:SetTextColor(lia.color.theme.text or color_white)
    nameLabel:SetContentAlignment(4)
    nameLabel:SetTall(30)
    local warningLabel = self.deletePresetDetailsScroll:Add("DLabel")
    warningLabel:Dock(TOP)
    warningLabel:DockMargin(0, 0, 0, 20)
    warningLabel:SetText(L("vendorDeletePresetWarning"))
    warningLabel:SetFont("LiliaFont.16")
    warningLabel:SetTextColor(Color(255, 100, 100))
    warningLabel:SetContentAlignment(4)
    warningLabel:SetWrap(true)
    warningLabel:SetAutoStretchVertical(true)
    local itemsLabel = self.deletePresetDetailsScroll:Add("DLabel")
    itemsLabel:Dock(TOP)
    itemsLabel:DockMargin(0, 0, 0, 10)
    itemsLabel:SetText(L("items") .. ": " .. table.Count(presetData))
    itemsLabel:SetFont("LiliaFont.16")
    itemsLabel:SetTextColor(lia.color.theme.text or color_white)
    itemsLabel:SetContentAlignment(4)
    itemsLabel:SetTall(24)
end

function PANEL:showPresetDetails(presetName, presetData)
    self.presetDetailsScroll:Clear()
    if not presetName or presetName == "none" or not presetData or table.Count(presetData) == 0 then
        local displayText = presetName == "none" and L("none") or L("vendorNoPresetSelected")
        local emptyPanel = self.presetDetailsScroll:Add("DPanel")
        emptyPanel:Dock(TOP)
        emptyPanel:DockMargin(0, 20, 0, 0)
        emptyPanel:SetTall(100)
        emptyPanel.Paint = function(_, w, h)
            local themeColor = lia.color.theme or {}
            local bgColor = themeColor.secondary or Color(35, 35, 40, 255)
            draw.RoundedBox(4, 0, 0, w, h, bgColor)
        end

        local label = emptyPanel:Add("DLabel")
        label:Dock(FILL)
        label:SetText(displayText)
        label:SetFont("LiliaFont.18b")
        label:SetTextColor(Color(150, 150, 150))
        label:SetContentAlignment(5)
        if IsValid(self.presetSubmitButton) then
            if presetName == "none" then
                self.presetSubmitButton:SetDisabled(false)
            else
                self.presetSubmitButton:SetDisabled(true)
            end
        end

        self.selectedPreset = presetName == "none" and "none" or nil
        return
    end

    local headerPanel = self.presetDetailsScroll:Add("DPanel")
    headerPanel:Dock(TOP)
    headerPanel:DockMargin(0, 0, 0, 15)
    headerPanel:SetTall(60)
    headerPanel.Paint = function(_, w, h)
        local themeColor = lia.color.theme or {}
        local bgColor = themeColor.primary or Color(50, 50, 50, 255)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        draw.RoundedBox(4, 0, 0, w, 2, themeColor.accent or Color(100, 150, 255, 255))
    end

    local nameLabel = headerPanel:Add("DLabel")
    nameLabel:Dock(TOP)
    nameLabel:DockMargin(10, 8, 10, 0)
    nameLabel:SetText(presetName)
    nameLabel:SetFont("LiliaFont.20b")
    nameLabel:SetTextColor(lia.color.theme and lia.color.theme.text or color_white)
    nameLabel:SizeToContents()
    local itemCount = table.Count(presetData)
    local countLabel = headerPanel:Add("DLabel")
    countLabel:Dock(TOP)
    countLabel:DockMargin(10, 2, 10, 8)
    countLabel:SetText(L("vendorPresetItemCount", itemCount))
    countLabel:SetFont("LiliaFont.14")
    countLabel:SetTextColor(Color(200, 200, 200))
    countLabel:SizeToContents()
    local itemsHeader = self.presetDetailsScroll:Add("DLabel")
    itemsHeader:Dock(TOP)
    itemsHeader:DockMargin(0, 5, 0, 10)
    itemsHeader:SetText(L("items"))
    itemsHeader:SetFont("LiliaFont.18b")
    itemsHeader:SetTextColor(lia.color.theme and lia.color.theme.text or color_white)
    itemsHeader:SizeToContents()
    for itemType, itemData in pairs(presetData) do
        local item = lia.item.list[itemType]
        if item then
            local itemPanel = self.presetDetailsScroll:Add("DPanel")
            itemPanel:Dock(TOP)
            itemPanel:DockMargin(0, 0, 0, 8)
            itemPanel:SetTall(90)
            itemPanel.Paint = function(_, w, h)
                local themeColor = lia.color.theme or {}
                local bgColor = themeColor.secondary or Color(35, 35, 40, 255)
                draw.RoundedBox(4, 0, 0, w, h, bgColor)
                draw.RoundedBox(0, 0, 0, 3, h, themeColor.accent or Color(100, 150, 255, 200))
            end

            local itemName = itemPanel:Add("DLabel")
            itemName:Dock(LEFT)
            itemName:DockMargin(15, 0, 10, 0)
            itemName:SetText(item:getName())
            itemName:SetFont("LiliaFont.18")
            itemName:SetTextColor(lia.color.theme and lia.color.theme.text or color_white)
            itemName:SetContentAlignment(4)
            itemName:SizeToContents()
            itemName:SetTall(90)
            local rightContainer = itemPanel:Add("DPanel")
            rightContainer:Dock(RIGHT)
            rightContainer:DockMargin(0, 0, 15, 0)
            rightContainer:SetWide(180)
            rightContainer:SetBackgroundColor(Color(0, 0, 0, 0))
            rightContainer.Paint = function() end
            local priceContainer = rightContainer:Add("DPanel")
            priceContainer:Dock(TOP)
            priceContainer:SetTall(45)
            priceContainer:SetBackgroundColor(Color(0, 0, 0, 0))
            priceContainer.Paint = function() end
            local priceLabel = priceContainer:Add("DLabel")
            priceLabel:Dock(LEFT)
            priceLabel:SetText("Buy/Sell: ")
            priceLabel:SetFont("LiliaFont.14")
            priceLabel:SetTextColor(Color(180, 180, 180))
            priceLabel:SizeToContents()
            priceLabel:SetTall(45)
            priceLabel:SetContentAlignment(4)
            local itemPrice = priceContainer:Add("DLabel")
            itemPrice:Dock(LEFT)
            itemPrice:DockMargin(5, 0, 0, 0)
            local buyPrice = itemData[VENDOR_BUYPRICE] or itemData[VENDOR_PRICE] or item:getPrice()
            local sellPrice = itemData[VENDOR_SELLPRICE] or itemData[VENDOR_PRICE] or item:getPrice()
            itemPrice:SetText(string.format("%s / %s", lia.currency.get(buyPrice), lia.currency.get(sellPrice)))
            itemPrice:SetFont("LiliaFont.16")
            itemPrice:SetTextColor(Color(100, 255, 100))
            itemPrice:SizeToContents()
            itemPrice:SetTall(45)
            itemPrice:SetContentAlignment(4)
            local modeContainer = rightContainer:Add("DPanel")
            modeContainer:Dock(TOP)
            modeContainer:SetTall(45)
            modeContainer:SetBackgroundColor(Color(0, 0, 0, 0))
            modeContainer.Paint = function() end
            local modeLabel = modeContainer:Add("DLabel")
            modeLabel:Dock(LEFT)
            modeLabel:SetText(L("attribMode") .. ": ")
            modeLabel:SetFont("LiliaFont.14")
            modeLabel:SetTextColor(Color(180, 180, 180))
            modeLabel:SizeToContents()
            modeLabel:SetTall(45)
            modeLabel:SetContentAlignment(4)
            local itemMode = modeContainer:Add("DLabel")
            itemMode:Dock(LEFT)
            itemMode:DockMargin(5, 0, 0, 0)
            local mode = itemData[VENDOR_MODE]
            local modeText = L("unknown")
            local modeColor = Color(255, 255, 0)
            if mode == VENDOR_SELLANDBUY then
                modeText = L("buyOnlynSell")
                modeColor = Color(100, 255, 100)
            elseif mode == VENDOR_SELLONLY then
                modeText = L("sellOnly")
                modeColor = Color(255, 200, 100)
            elseif mode == VENDOR_BUYONLY then
                modeText = L("buyOnly")
                modeColor = Color(100, 200, 255)
            end

            itemMode:SetText(modeText)
            itemMode:SetFont("LiliaFont.16")
            itemMode:SetTextColor(modeColor)
            itemMode:SizeToContents()
            itemMode:SetTall(45)
            itemMode:SetContentAlignment(4)
        end
    end

    if IsValid(self.presetSubmitButton) then self.presetSubmitButton:SetDisabled(false) end
    self.selectedPreset = presetName
end

function PANEL:onNameDescChanged(key)
    local entity = liaVendorEnt
    if key == "name" then
        self.name:SetText(entity:getName())
    elseif key == "desc" then
        if IsValid(self.desc) then self.desc:SetText(lia.vendor.getVendorProperty(entity, "desc") or "") end
    elseif key == "model" then
        self.model:SetText(entity:GetModel())
        self:refreshAnimationDropdown()
        timer.Simple(0.1, function()
            if IsValid(self) and IsValid(entity) then
                local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
                if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
            end
        end)
    elseif key == "animation" then
        local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
        if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
    end
end

function PANEL:onVendorPropertyUpdated(vendor, key)
    if vendor ~= liaVendorEnt then return end
    self:onNameDescChanged(key)
    if key == "stockEnabled" then
        self:updateStockEnabledButton()
        self:updateStockColumnVisibility()
        self:ReloadItemList(self.lastSearchValue)
    end
end

function PANEL:onItemModeUpdated()
    self:ReloadItemList(self.lastSearchValue)
end

function PANEL:onItemPriceUpdated()
    self:ReloadItemList(self.lastSearchValue)
end

function PANEL:onItemStockUpdated()
    self:ReloadItemList(self.lastSearchValue)
end

function PANEL:onVendorSynchronized(vendor)
    if vendor ~= liaVendorEnt then return end
    self:ReloadItemList(self.lastSearchValue)
end

function PANEL:listenForUpdates()
    hook.Add("VendorEdited", self, self.onNameDescChanged)
    hook.Add("VendorPropertyUpdated", self, self.onVendorPropertyUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onItemModeUpdated)
    hook.Add("VendorItemBuyPriceUpdated", self, self.onItemPriceUpdated)
    hook.Add("VendorItemSellPriceUpdated", self, self.onItemPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorSynchronized", self, self.onVendorSynchronized)
end

function PANEL:OnRowRightClick(_, rowData)
    local entity = liaVendorEnt
    if not IsValid(entity) then
        LocalPlayer():notifyError(L("vendorEntityInvalid"))
        return
    end

    if IsValid(menu) then menu:Remove() end
    local uniqueID = rowData.item
    local itemTable = lia.item.list[uniqueID]
    if not itemTable then return end
    menu = lia.derma.dermaMenu()
    local mode, modePanel = menu:AddSubMenu(L("mode"))
    modePanel:SetImage("icon16/key.png")
    mode:AddOption(L("none"), function() lia.vendor.editor.mode(uniqueID, nil) end):SetImage("icon16/cog_error.png")
    mode:AddOption(L("buyOnlynSell"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLANDBUY) end):SetImage("icon16/cog.png")
    mode:AddOption(L("buyOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_BUYONLY) end):SetImage("icon16/cog_delete.png")
    mode:AddOption(L("sellOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLONLY) end):SetImage("icon16/cog_add.png")
    menu:AddOption("Buy Price", function()
        LocalPlayer():requestString(itemTable:getName(), "@vendorPriceReq", function(text)
            text = tonumber(text)
            lia.vendor.editor.buyPrice(uniqueID, text)
        end, entity.items[uniqueID] and (entity.items[uniqueID][VENDOR_BUYPRICE] or entity.items[uniqueID][VENDOR_PRICE]) or entity:getPrice(uniqueID))
    end):SetImage("icon16/coins.png")

    menu:AddOption("Sell Price", function()
        LocalPlayer():requestString(itemTable:getName(), "@vendorPriceReq", function(text)
            text = tonumber(text)
            lia.vendor.editor.sellPrice(uniqueID, text)
        end, entity.items[uniqueID] and (entity.items[uniqueID][VENDOR_SELLPRICE] or entity.items[uniqueID][VENDOR_PRICE]) or entity:getPrice(uniqueID, true))
    end):SetImage("icon16/coins.png")

    local stock, stockPanel = menu:AddSubMenu(L("stock"))
    stockPanel:SetImage("icon16/table.png")
    stock:AddOption(L("disable"), function() lia.vendor.editor.stockDisable(uniqueID) end):SetImage("icon16/table_delete.png")
    stock:AddOption(L("edit"), function()
        local _, max = entity:getStock(uniqueID)
        LocalPlayer():requestString(itemTable:getName(), "@vendorStockReq", function(text)
            text = math.max(math.Round(tonumber(text) or 1), 1)
            lia.vendor.editor.stockMax(uniqueID, text)
        end, max or 1)
    end):SetImage("icon16/table_edit.png")

    stock:AddOption(L("vendorEditCurStock"), function()
        LocalPlayer():requestString(itemTable:getName(), "@vendorStockCurReq", function(text)
            text = math.Round(tonumber(text) or 0)
            lia.vendor.editor.stock(uniqueID, text)
        end, entity:getStock(uniqueID) or 0)
    end):SetImage("icon16/table_edit.png")

    menu:Open()
    return true
end

function PANEL:ReloadItemList(filter)
    local entity = liaVendorEnt
    self.lines = {}
    if not IsValid(self.itemList) then return end
    self.itemList:Clear()
    if not IsValid(entity) then return end
    self:updateStockColumnVisibility()
    local rowIndex = 0
    for k, v in SortedPairsByMemberValue(lia.item.list, "name") do
        local name = v.getName and v:getName() or v.name
        if filter and not (v.getName and name or L(name)):lower():find(filter:lower(), 1, true) then continue end
        rowIndex = rowIndex + 1
        local rowData = self.itemList:Add("liaVendorEditorItemRow")
        rowData:Dock(TOP)
        rowData:DockMargin(0, 0, 0, 6)
        rowData._rowIndex = rowIndex
        rowData:SetEditor(self)
        rowData:SetItemID(k)
        rowData:Refresh()
        self.lines[k] = rowData
    end
end

vgui.Register("liaVendorEditor", PANEL, "liaFrame")
