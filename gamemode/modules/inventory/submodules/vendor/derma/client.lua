local sw, sh = ScrW(), ScrH()
local COLS_MODE = 2
local COLS_PRICE = 3
local COLS_STOCK = 4
local RarityColors = lia.vendor.rarities
local VendorClick = {"buttons/button15.wav", 30, 250}
local PANEL = {}
function PANEL:Init()
    local ply = LocalPlayer()
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor.noSendExit = true
        lia.gui.vendor:Remove()
    end

    lia.gui.vendor = self
    self:SetSize(sw, sh)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)
    self:SetZPos(50)
    self.buttons = self:Add("DPanel")
    self.buttons:DockMargin(0, 32, 0, 0)
    self.buttons:Dock(TOP)
    self.buttons:SetTall(36)
    self.buttons:SetPaintBackground(false)
    self.y0 = 32 + 44
    self.panelW = math.max(sw * 0.35, 280)
    local panelH = sh - self.y0 - 64
    self.vendorPanel = self:Add("liaSemiTransparentDPanel")
    self.vendorPanel:SetSize(self.panelW, panelH)
    self.vendorPanel:SetPos(sw * 0.5 - self.panelW - 16, self.y0)
    self.vendorPanel.items = self.vendorPanel:Add("liaScrollPanel")
    self.vendorPanel.items:Dock(FILL)
    self.vendorPanel.items:DockPadding(8, 8, 8, 8)
    self.vendorPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.background_alpha or Color(34, 34, 34, 240)):Draw() end
    self.mePanel = self:Add("liaSemiTransparentDPanel")
    self.mePanel:SetSize(self.panelW, panelH)
    self.mePanel:SetPos(sw * 0.5 + 16, self.y0)
    self.mePanel.items = self.mePanel:Add("liaScrollPanel")
    self.mePanel.items:Dock(FILL)
    self.mePanel.items:DockPadding(8, 8, 8, 8)
    self.mePanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(lia.color.theme.background_alpha or Color(34, 34, 34, 240)):Draw() end
    self:listenForChanges()
    self:liaListenForInventoryChanges(ply:getChar():getInv())
    self.items = {
        vendor = {},
        me = {}
    }

    self.currentCategory = nil
    local lbl = self:Add("DLabel")
    lbl:SetText(L("vendorYourItems"))
    lbl:SetFont("LiliaFont.24b")
    lbl:SetTextColor(lia.color.theme.text or color_white)
    lbl:SetContentAlignment(5)
    lbl:SizeToContents()
    lbl:SetPos(self.mePanel.x + self.mePanel:GetWide() * 0.5 - lbl:GetWide() * 0.5, self.y0 - lbl:GetTall() - 12)
    lbl.Paint = function(s, w, h) draw.SimpleText(s:GetText(), s:GetFont(), w * 0.5, h * 0.5, s:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    local lbl2 = self:Add("DLabel")
    local vendorName = IsValid(liaVendorEnt) and liaVendorEnt:getName() or L("vendorItemsTitle")
    local vendorItemsText = vendorName and (vendorName .. "'s " .. L("items")) or L("vendorItemsTitle")
    lbl2:SetText(vendorItemsText)
    lbl2:SetFont("LiliaFont.24b")
    lbl2:SetTextColor(lia.color.theme.text or color_white)
    lbl2:SetContentAlignment(5)
    lbl2:SizeToContents()
    lbl2:SetPos(self.vendorPanel.x + self.vendorPanel:GetWide() * 0.5 - lbl2:GetWide() * 0.5, self.y0 - lbl2:GetTall() - 12)
    lbl2.Paint = function(s, w, h) draw.SimpleText(s:GetText(), s:GetFont(), w * 0.5, h * 0.5, s:GetTextColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    self.vendorItemsLabel = lbl2
    self:populateItems()
    self:createCategoryDropdown()
    timer.Simple(0.1, function()
        if IsValid(self) and IsValid(liaVendorEnt) then
            local itemCount = liaVendorEnt.items and table.Count(liaVendorEnt.items) or 0
            if itemCount > 0 then
                local vendorChildren = IsValid(self.vendorPanel.items) and #self.vendorPanel.items:GetChildren() or 0
                local meChildren = IsValid(self.mePanel.items) and #self.mePanel.items:GetChildren() or 0
                if vendorChildren == 0 and meChildren == 0 then self:populateItems() end
            end
        end
    end)

    local bw, bh = sw * 0.10, sh * 0.05
    if ply:canEditVendor(self.vendorPanel) then
        local btn = self:Add("liaButton")
        btn:SetSize(bw, bh)
        btn:SetPos(sw * 0.88, sh * 0.82)
        btn:SetText(L("vendorEditorButton"))
        btn:SetFont("LiliaFont.18")
        btn.DoClick = function() vgui.Create("liaVendorEditor"):SetZPos(99) end
    end

    local leave = self:Add("liaButton")
    leave:SetSize(bw, bh)
    leave:SetPos(sw * 0.88, sh - 64 - sh * 0.05)
    leave:SetText(L("leave"))
    leave:SetFont("LiliaFont.18")
    leave.DoClick = function() self:Remove() end
end

function PANEL:createCategoryDropdown()
    local c = self:GetItemCategoryList()
    if table.Count(c) < 1 then return end
    local btn = self:Add("liaButton")
    btn:SetSize(sw * 0.10, sh * 0.035)
    btn:SetPos(sw * 0.88, self.y0)
    btn:SetText(L("vendorShowAll"))
    btn:SetFont("LiliaFont.16")
    local sorted = {}
    for k in pairs(c) do
        sorted[#sorted + 1] = k
    end

    table.sort(sorted, function(a, b) return a:lower() < b:lower() end)
    local menu
    btn.DoClick = function()
        if IsValid(menu) then
            menu:Remove()
            menu = nil
            return
        end

        menu = vgui.Create("liaSemiTransparentDPanel", self)
        menu:SetSize(btn:GetWide(), math.min(#sorted * 32 + 8, sh * 0.4))
        menu:SetPos(btn.x, btn.y + btn:GetTall() + 4)
        menu.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(6):Color(lia.color.theme.background_alpha or Color(34, 34, 34, 250)):Draw() end
        local scroll = menu:Add("liaScrollPanel")
        scroll:Dock(FILL)
        scroll:DockPadding(4, 4, 4, 4)
        for _, cat in ipairs(sorted) do
            local text = cat:gsub("^%l", string.upper)
            local item = scroll:Add("liaButton")
            item:SetSize(scroll:GetWide() - 8, 28)
            item:Dock(TOP)
            item:DockMargin(0, 0, 0, 4)
            item:SetText(text)
            item:SetFont("LiliaFont.16")
            item.DoClick = function()
                if cat == L("vendorShowAll") then
                    self.currentCategory = nil
                    btn:SetText(L("vendorShowAll"))
                else
                    self.currentCategory = cat
                    btn:SetText(text)
                end

                self:applyCategoryFilter()
                if IsValid(menu) then
                    menu:Remove()
                    menu = nil
                end
            end
        end
    end
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
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    local vendorItemCount = 0
    local meItemCount = 0
    for id in SortedPairs(data) do
        local item = lia.item.list[id]
        local mode = liaVendorEnt:getTradeMode(id)
        if item and mode then
            if mode ~= VENDOR_BUYONLY then
                local result = self:updateItem(id, "vendor")
                if result then vendorItemCount = vendorItemCount + 1 end
            end

            if mode ~= VENDOR_SELLONLY then
                local pnl = self:updateItem(id, "me")
                if pnl then
                    pnl:setIsSelling(true)
                    meItemCount = meItemCount + 1
                end
            end
        end
    end

    if IsValid(self.vendorPanel.items) then
        local canvas = self.vendorPanel.items.Canvas or self.vendorPanel.items:GetCanvas()
        if canvas then
            local canvasChildren = canvas:GetChildren()
            local panelWidth = self.vendorPanel:GetWide()
            local totalHeight = 0
            for _, child in ipairs(canvasChildren) do
                if IsValid(child) then totalHeight = totalHeight + child:GetTall() end
            end

            canvas:SetWide(panelWidth - 24)
            canvas:SetTall(math.max(totalHeight, 140))
        end

        self.vendorPanel.items:InvalidateLayout()
        timer.Simple(0, function() if IsValid(self) and IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout() end end)
    end

    if IsValid(self.mePanel.items) then
        local canvas = self.mePanel.items.Canvas or self.mePanel.items:GetCanvas()
        if canvas then
            local canvasChildren = canvas:GetChildren()
            local panelWidth = self.mePanel:GetWide()
            local totalHeight = 0
            for _, child in ipairs(canvasChildren) do
                if IsValid(child) then totalHeight = totalHeight + child:GetTall() end
            end

            canvas:SetWide(panelWidth - 24)
            canvas:SetTall(math.max(totalHeight, 140))
        end

        self.mePanel.items:InvalidateLayout()
        timer.Simple(0, function() if IsValid(self) and IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout() end end)
    end
end

function PANEL:shouldShow(id, which)
    if not IsValid(liaVendorEnt) then return false end
    local mode = liaVendorEnt:getTradeMode(id)
    if not mode then return false end
    if which == "me" and mode == VENDOR_SELLONLY then return false end
    if which == "vendor" and mode == VENDOR_BUYONLY then return false end
    return true
end

function PANEL:updateItem(id, which, qty)
    local container = self.items[which]
    if not container then return end
    if not self:shouldShow(id, which) then
        if IsValid(container[id]) then container[id]:Remove() end
        return
    end

    local parent = which == "me" and self.mePanel or self.vendorPanel
    if not IsValid(parent.items) then return end
    local pnl = container[id]
    if not IsValid(pnl) then
        local targetParent = parent.items
        if parent.items.Canvas then
            targetParent = parent.items.Canvas
        elseif parent.items:GetCanvas() then
            targetParent = parent.items:GetCanvas()
        end

        pnl = targetParent:Add("liaVendorItem")
        local panelWidth = parent:GetWide()
        pnl:SetWide(panelWidth - 24)
        pnl:SetTall(140)
        pnl:setItemType(id)
        pnl:setIsSelling(which == "me")
        pnl:Dock(TOP)
        pnl:DockMargin(0, 0, 0, 8)
        container[id] = pnl
        local totalHeight = 0
        for _, child in ipairs(targetParent:GetChildren()) do
            if IsValid(child) then totalHeight = totalHeight + child:GetTall() end
        end

        targetParent:SetWide(panelWidth - 24)
        targetParent:SetTall(math.max(totalHeight, 140))
    end

    if not isnumber(qty) then qty = which == "me" and LocalPlayer():getChar():getInv():getItemCount(id) or (IsValid(liaVendorEnt) and liaVendorEnt:getStock(id) or 0) end
    pnl:setQuantity(qty)
    if IsValid(pnl) then
        pnl:SetVisible(true)
        if pnl:GetTall() <= 0 then pnl:SetTall(160) end
    end
    return pnl
end

function PANEL:GetItemCategoryList()
    if not IsValid(liaVendorEnt) then return {} end
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    local out = {
        [L("vendorShowAll")] = true
    }

    for id in pairs(data) do
        local itm = lia.item.list[id]
        if itm then
            local cat = itm:getCategory()
            out[cat:sub(1, 1):upper() .. cat:sub(2)] = true
        end
    end
    return out
end

function PANEL:applyCategoryFilter()
    for _, p in pairs(self.items.vendor) do
        if IsValid(p) then p:Remove() end
    end

    for _, p in pairs(self.items.me) do
        if IsValid(p) then p:Remove() end
    end

    self.items.vendor = {}
    self.items.me = {}
    if not IsValid(liaVendorEnt) then return end
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    for id in SortedPairs(data) do
        local itm = lia.item.list[id]
        local cat = itm and itm:getCategory()
        if cat then cat = cat:sub(1, 1):upper() .. cat:sub(2) end
        if not self.currentCategory or self.currentCategory == L("vendorShowAll") or cat == self.currentCategory then
            local mode = liaVendorEnt:getTradeMode(id)
            if mode ~= VENDOR_BUYONLY then self:updateItem(id, "vendor") end
            if mode ~= VENDOR_SELLONLY then
                local pnl = self:updateItem(id, "me")
                if pnl then pnl:setIsSelling(true) end
            end
        end
    end

    if IsValid(self.vendorPanel.items) then
        self.vendorPanel.items:InvalidateLayout()
        self.vendorPanel.items:SizeToChildren(false, true)
    end

    if IsValid(self.mePanel.items) then
        self.mePanel.items:InvalidateLayout()
        self.mePanel.items:SizeToChildren(false, true)
    end
end

function PANEL:listenForChanges()
    hook.Add("VendorItemPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onVendorModeUpdated)
    hook.Add("VendorEdited", self, self.onVendorPropEdited)
    hook.Add("VendorSynchronized", self, self.onVendorSynchronized)
end

function PANEL:InventoryItemAdded(it)
    if it and it.uniqueID then self:updateItem(it.uniqueID, "me") end
end

function PANEL:InventoryItemRemoved(it)
    if it and it.uniqueID then self:InventoryItemAdded(it) end
end

function PANEL:onVendorPropEdited(_, key)
    if not IsValid(liaVendorEnt) then return end
    if key == "name" then
        if IsValid(self.vendorItemsLabel) then
            local vendorName = liaVendorEnt:getName()
            local vendorItemsText = vendorName and (vendorName .. "'s " .. L("items")) or L("vendorItemsTitle")
            self.vendorItemsLabel:SetText(vendorItemsText)
            self.vendorItemsLabel:SizeToContents()
            self.vendorItemsLabel:SetPos(self.vendorPanel.x + self.vendorPanel:GetWide() * 0.5 - self.vendorItemsLabel:GetWide() * 0.5, self.y0 - self.vendorItemsLabel:GetTall() - 12)
        end
    elseif key == "scale" then
        for _, v in pairs(self.items.vendor) do
            if IsValid(v) then v:updateLabel() end
        end

        for _, v in pairs(self.items.me) do
            if IsValid(v) then v:updateLabel() end
        end
    elseif key == "skin" then
        if IsValid(self.skin) then self.skin:SetValue(liaVendorEnt:GetSkin()) end
    elseif key == "bodygroup" then
        if IsValid(lia.gui.vendorBodygroupEditor) then lia.gui.vendorBodygroupEditor:onVendorEdited(nil, key) end
    end

    self:applyCategoryFilter()
end

function PANEL:onVendorPriceUpdated(_, id)
    if IsValid(self.items.vendor[id]) then self.items.vendor[id]:updateLabel() end
    if IsValid(self.items.me[id]) then self.items.me[id]:updateLabel() end
    self:applyCategoryFilter()
end

function PANEL:onVendorModeUpdated(_, id)
    self:updateItem(id, "vendor")
    self:updateItem(id, "me")
    self:applyCategoryFilter()
end

function PANEL:onItemStockUpdated(_, id)
    self:updateItem(id, "vendor")
    self:applyCategoryFilter()
end

function PANEL:onVendorSynchronized(vendor)
    if not IsValid(self) then return end
    if vendor ~= liaVendorEnt then return end
    self:populateItems()
    self:applyCategoryFilter()
    timer.Simple(0, function()
        if IsValid(self) then
            if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout() end
            if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout() end
        end
    end)
end

function PANEL:Paint()
end

function PANEL:OnRemove()
    if not self.noSendExit then
        net.Start("liaVendorExit")
        net.SendToServer()
        self.noSendExit = true
    end

    if IsValid(lia.gui.vendorEditor) then lia.gui.vendorEditor:Remove() end
    if IsValid(lia.gui.vendorFactionEditor) then lia.gui.vendorFactionEditor:Remove() end
    if self.refreshTimer then timer.Remove(self.refreshTimer) end
    if self.searchTimer then timer.Remove(self.searchTimer) end
    hook.Remove("VendorFactionUpdated", self)
    hook.Remove("VendorClassUpdated", self)
    hook.Remove("VendorSynchronized", self)
    self:liaDeleteInventoryHooks()
end

function PANEL:OnKeyCodePressed()
    if input.LookupBinding("+use", true) then self:Remove() end
end

vgui.Register("liaVendor", PANEL, "EditablePanel")
PANEL = {}
local function drawIcon(mat, _, x, y)
    surface.SetDrawColor(color_white)
    if isstring(mat) then mat = Material(mat) end
    surface.SetMaterial(mat)
    surface.DrawTexturedRect(0, 0, x, y)
end

function PANEL:Init()
    self:SetSize(600, 140)
    self:Dock(TOP)
    self:SetPaintBackground(false)
    self:SetCursor("hand")
    self.hoverAlpha = 0
    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background.Paint = function(_, w, h)
        local theme = lia.color.theme
        local bgColor = theme and theme.panel and theme.panel[1] or Color(50, 50, 50, 240)
        local hoverColor = theme and theme.button_hovered or Color(70, 140, 140, 30)
        lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Draw()
        if self:IsHovered() then
            self.hoverAlpha = math.min(self.hoverAlpha + FrameTime() * 5, 1)
        else
            self.hoverAlpha = math.max(self.hoverAlpha - FrameTime() * 5, 0)
        end

        if self.hoverAlpha > 0 then
            local hoverCol = ColorAlpha(hoverColor, hoverColor.a * self.hoverAlpha)
            lia.derma.rect(0, 0, w, h):Rad(8):Color(hoverCol):Draw()
        end

        surface.SetDrawColor(theme and theme.panel and theme.panel[2] or Color(80, 80, 80, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.iconFrame = self.background:Add("DPanel")
    self.iconFrame:SetSize(100, 100)
    self.iconFrame:Dock(LEFT)
    self.iconFrame:DockMargin(10, 10, 10, 10)
    self.iconFrame.ExtraPaint = function() end
    self.iconFrame.Paint = function(_, w, h)
        lia.derma.rect(0, 0, w, h):Rad(6):Color(lia.color.theme.panel and lia.color.theme.panel[2] or Color(30, 30, 30, 200)):Draw()
        self.iconFrame:ExtraPaint(w, h)
    end

    self.icon = self.iconFrame:Add("liaItemIcon")
    self.icon:SetSize(100, 100)
    self.icon:Dock(FILL)
    self.icon.Paint = function() end
    self.contentArea = self.background:Add("DPanel")
    self.contentArea:Dock(FILL)
    self.contentArea:DockMargin(0, 10, 10, 10)
    self.contentArea:SetPaintBackground(false)
    self.topRow = self.contentArea:Add("DPanel")
    self.topRow:Dock(TOP)
    self.topRow:SetTall(36)
    self.topRow:SetPaintBackground(false)
    self.name = self.topRow:Add("DLabel")
    self.name:SetFont("LiliaFont.22b")
    self.name:SetExpensiveShadow(1, color_black)
    self.name:Dock(FILL)
    self.name:DockMargin(0, 0, 8, 0)
    self.name:SetContentAlignment(4)
    self.name:SetWrap(true)
    self.name:SetAutoStretchVertical(true)
    self.name:SetText("")
    self.priceBadge = self.topRow:Add("DPanel")
    self.priceBadge:Dock(RIGHT)
    self.priceBadge:SetWide(120)
    self.priceBadge:SetPaintBackground(false)
    self.priceBadge.Paint = function(_, w, h)
        local theme = lia.color.theme
        local priceColor = theme and theme.theme or Color(100, 150, 200)
        lia.derma.rect(0, 0, w, h):Rad(4):Color(ColorAlpha(priceColor, 20)):Draw()
        surface.SetDrawColor(ColorAlpha(priceColor, 100))
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.priceLabel = self.priceBadge:Add("DLabel")
    self.priceLabel:SetFont("LiliaFont.18b")
    self.priceLabel:Dock(FILL)
    self.priceLabel:SetContentAlignment(5)
    self.priceLabel:SetTextColor(lia.color.theme.text or color_white)
    self.priceLabel:SetText("")
    self.quantityBadge = self.topRow:Add("DPanel")
    self.quantityBadge:Dock(RIGHT)
    self.quantityBadge:SetWide(60)
    self.quantityBadge:DockMargin(0, 0, 8, 0)
    self.quantityBadge:SetPaintBackground(false)
    self.quantityBadge.Paint = function(_, w, h)
        local theme = lia.color.theme
        local qtyColor = theme and theme.panel and theme.panel[2] or Color(60, 60, 60, 150)
        lia.derma.rect(0, 0, w, h):Rad(4):Color(qtyColor):Draw()
    end

    self.quantityLabel = self.quantityBadge:Add("DLabel")
    self.quantityLabel:SetFont("LiliaFont.16")
    self.quantityLabel:Dock(FILL)
    self.quantityLabel:SetContentAlignment(5)
    self.quantityLabel:SetTextColor(lia.color.theme.text or color_white)
    self.quantityLabel:SetText("")
    self.description = self.contentArea:Add("DLabel")
    self.description:SetFont("LiliaFont.14")
    self.description:SetTextColor(lia.color.theme.text and ColorAlpha(lia.color.theme.text, 180) or Color(180, 180, 180))
    self.description:Dock(TOP)
    self.description:DockMargin(0, 4, 0, 8)
    self.description:SetWrap(true)
    self.description:SetContentAlignment(7)
    self.description:SetAutoStretchVertical(true)
    self.description:SetText("")
    self.bottomRow = self.contentArea:Add("DPanel")
    self.bottomRow:Dock(BOTTOM)
    self.bottomRow:SetTall(36)
    self.bottomRow:SetPaintBackground(false)
    self.spacer = self.bottomRow:Add("DPanel")
    self.spacer:Dock(FILL)
    self.spacer:SetPaintBackground(false)
    self.action = self.bottomRow:Add("liaButton")
    self.action:SetWide(140)
    self.action:SetHeight(36)
    self.action:Dock(RIGHT)
    self.action:SetFont("LiliaFont.16")
    self.isSelling = false
    self.suffix = ""
    self.currentPrice = 0
    self.currentQuantity = 0
end

local function clickEffects()
    local client = LocalPlayer()
    client:EmitSound(unpack(VendorClick))
end

function PANEL:sellItemToVendor()
    local item = self.item
    if not item then return end
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor:sellItemToVendor(item.uniqueID)
        clickEffects()
    end
end

function PANEL:buyItemFromVendor()
    local item = self.item
    if not item then return end
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor:buyItemFromVendor(item.uniqueID)
        clickEffects()
    end
end

function PANEL:updateAction()
    if not self.action or not self.item then return end
    if not IsValid(liaVendorEnt) then
        self.action:SetText(self.isSelling and L("vendorSellAction", "N/A") or L("vendorBuyAction", "N/A"))
        return
    end

    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    self.currentPrice = price
    local priceText
    if price == 0 then
        priceText = L("vendorFree")
    elseif price > 1 then
        priceText = string.format("%s %s", price, lia.currency.plural)
    else
        priceText = string.format("%s %s", price, lia.currency.singular)
    end

    if IsValid(self.priceLabel) then self.priceLabel:SetText(priceText) end
    self.action:SetText(self.isSelling and L("sell") or L("buy"))
    self.action.DoClick = function()
        if self.isSelling then
            self:sellItemToVendor()
        else
            self:buyItemFromVendor()
        end
    end
end

function PANEL:setQuantity(quantity, skipUpdate)
    if not self.item then return end
    if quantity then
        if quantity <= 0 and self.isSelling then
            self:Remove()
            return
        end

        self.currentQuantity = quantity
        if IsValid(self.quantityLabel) then
            if self.isSelling then
                self.quantityLabel:SetText(tostring(quantity))
            else
                if IsValid(liaVendorEnt) then
                    local current, max = liaVendorEnt:getStock(self.item.uniqueID)
                    if max then
                        self.quantityLabel:SetText(current .. "/" .. max)
                    else
                        self.quantityLabel:SetText(tostring(quantity))
                    end
                else
                    self.quantityLabel:SetText(tostring(quantity))
                end
            end
        end

        if quantity > 0 or not self.isSelling then
            self.suffix = L("vendorItemQuantity", quantity)
        else
            self.suffix = ""
        end
    else
        self.currentQuantity = 0
        if IsValid(self.quantityLabel) then self.quantityLabel:SetText("") end
        self.suffix = ""
    end

    if not skipUpdate then self:updateLabel() end
end

function PANEL:setItemType(itemType)
    local item = lia.item.list[itemType]
    assert(item, L("invalidItemTypeOrID", tostring(itemType)))
    self.item = item
    local itemIcon = item.icon
    if not itemIcon and item.functions and item.functions.use and item.functions.use.icon then itemIcon = item.functions.use.icon end
    if itemIcon then
        self.icon:SetVisible(false)
        self.iconFrame.ExtraPaint = function(pnl, w, h) drawIcon(itemIcon, pnl, w, h) end
    else
        self.icon:SetVisible(true)
        self.icon:SetModel(item.model, item.skin or 0)
        self.iconFrame.ExtraPaint = function() end
    end

    self:updateLabel()
    self:updateAction()
    local rarity = item.rarity or "Common"
    local nameColor = RarityColors[rarity] or color_white
    self.name:SetTextColor(nameColor)
end

function PANEL:setIsSelling(isSelling)
    self.isSelling = isSelling
    self:updateLabel()
    self:updateAction()
end

function PANEL:updateLabel()
    if not self.item then return end
    self.name:SetText(self.item:getName())
    self.description:SetText(self.item:getDesc() or L("noDesc"))
    self:updateAction()
    if self.currentQuantity > 0 or not self.isSelling then self:setQuantity(self.currentQuantity, true) end
end

vgui.Register("liaVendorItem", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.vendorEditor) then lia.gui.vendorEditor:Remove() end
    lia.gui.vendorEditor = self
    local entity = liaVendorEnt
    if not IsValid(entity) then
        self:Remove()
        return
    end

    local width = math.min(ScrW() * 0.95, 1000)
    local height = math.min(ScrH() * 0.90, 900)
    self:SetSize(width, height)
    self:MakePopup()
    self:Center()
    self:SetTitle(L("vendorEditor"))
    self.name = self:Add("liaEntry")
    self.name:Dock(TOP)
    self.name:SetPlaceholderText(L("name"))
    self.name:SetValue(entity:getName())
    self.name.action = function(value) if entity:getNetVar("name") ~= value then lia.vendor.editor.name(value) end end
    self.model = self:Add("liaEntry")
    self.model:Dock(TOP)
    self.model:DockMargin(0, 4, 0, 0)
    self.model:SetPlaceholderText(L("model"))
    self.model:SetValue(entity:GetModel())
    self.model.action = function(value)
        local modelText = value:lower()
        if entity:GetModel():lower() ~= modelText then lia.vendor.editor.model(modelText) end
    end

    self.welcome = self:Add("liaEntry")
    self.welcome:Dock(TOP)
    self.welcome:DockMargin(0, 4, 0, 0)
    self.welcome:SetPlaceholderText(L("vendorEditorWelcomeMessage"))
    self.welcome:SetValue(entity:getWelcomeMessage())
    self.welcome.action = function(value) if value ~= entity:getWelcomeMessage() then lia.vendor.editor.welcome(value) end end
    local hasBodygroups = false
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) > 1 then
            hasBodygroups = true
            break
        end
    end

    self.factionPanel = self:Add("DPanel")
    self.factionPanel:Dock(FILL)
    self.factionPanel:DockMargin(0, 8, 0, 0)
    self.factionPanel:SetPaintBackground(false)
    self.factionScroll = self.factionPanel:Add("liaScrollPanel")
    self.factionScroll:Dock(FILL)
    self.factionScroll:DockPadding(0, 0, 0, 4)
    self.factions = {}
    self.classes = {}
    self:populateFactionPanel()
    self.leftPanel = self:Add("DPanel")
    self.leftPanel:Dock(LEFT)
    self.leftPanel:DockMargin(0, 0, 4, 0)
    self.leftPanel:SetWide(self:GetWide() * 0.4)
    self.leftPanel:SetPaintBackground(false)
    self.rightPanel = self:Add("DPanel")
    self.rightPanel:Dock(FILL)
    self.rightPanel:DockMargin(0, 0, 0, 0)
    self.rightPanel:SetPaintBackground(false)
    self.name:SetParent(self.leftPanel)
    self.model:SetParent(self.leftPanel)
    self.welcome:SetParent(self.leftPanel)
    if IsValid(self.faction) then self.faction:SetParent(self.leftPanel) end
    if IsValid(self.animation) then self.animation:SetParent(self.leftPanel) end
    if IsValid(self.factionPanel) then self.factionPanel:SetParent(self.leftPanel) end
    if hasBodygroups or entity:SkinCount() > 1 then
        if hasBodygroups then
            self.bodygroups = self.leftPanel:Add("liaSmallButton")
            self.bodygroups:Dock(BOTTOM)
            self.bodygroups:DockMargin(0, 4, 0, 0)
            self.bodygroups:SetText(L("bodygroups"))
            self.bodygroups:SetTextColor(lia.color.theme.text or color_white)
            self.bodygroups.DoClick = function() vgui.Create("liaVendorBodygroupEditor", self):MoveLeftOf(self, 4) end
        end

        if entity:SkinCount() > 1 then
            self.skin = self.leftPanel:Add("DNumSlider")
            self.skin:Dock(BOTTOM)
            self.skin:DockMargin(16, 4, 16, 0)
            self.skin:SetText(L("skin"))
            self.skin.Label:SetTextColor(lia.color.theme.text or color_white)
            self.skin:SetDecimals(0)
            self.skin:SetMinMax(0, entity:SkinCount() - 1)
            self.skin:SetValue(entity:GetSkin())
            self.skin.OnValueChanged = function(_, value)
                value = math.Round(value)
                if entity:GetSkin() ~= value then lia.vendor.editor.skin(value) end
            end
        end
    end

    self.animation = self.leftPanel:Add("liaComboBox")
    self.animation:Dock(BOTTOM)
    self.animation:DockMargin(0, 4, 0, 0)
    self.animation:PostInit()
    self.animation:SetText(L("animation"))
    self.animation:SetTooltip(L("vendorAnimationTooltip"))
    self:refreshAnimationDropdown()
    local currentAnimation = entity:getNetVar("animation", "")
    self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation)
    self.animation:ChooseOption(currentAnimation == "" and L("none") or currentAnimation)
    self.animation.OnSelect = function(_, _, value)
        local currentValue = self.animation:GetValue()
        if not IsValid(self.animation) then return end
        local selectedValue = value or currentValue
        if not isstring(selectedValue) then return end
        if selectedValue == L("none") then selectedValue = "" end
        if lia.vendor.editor.animation then lia.vendor.editor.animation(selectedValue) end
        timer.Simple(0.1, function()
            if IsValid(self.animation) then
                local displayValue = selectedValue == "" and L("none") or selectedValue
                self.animation:SetValue(displayValue)
            end
        end)
    end

    self.itemSearchBar = self.rightPanel:Add("liaEntry")
    self.itemSearchBar:Dock(TOP)
    self.itemSearchBar:DockMargin(0, 0, 0, 4)
    self.itemSearchBar:SetPlaceholderText(L("search"))
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

    self.items = self.rightPanel:Add("DListView")
    self.items:Dock(FILL)
    self.items:DockMargin(0, 0, 0, 0)
    self.items:AddColumn(L("name")).Header:SetTextColor(lia.color.theme.text or color_white)
    self.items:AddColumn(L("mode")).Header:SetTextColor(lia.color.theme.text or color_white)
    self.items:AddColumn(L("price")).Header:SetTextColor(lia.color.theme.text or color_white)
    self.items:AddColumn(L("stock")).Header:SetTextColor(lia.color.theme.text or color_white)
    self.items:AddColumn(L("category")).Header:SetTextColor(lia.color.theme.text or color_white)
    self.items:SetMultiSelect(false)
    self.items.OnRowRightClick = function(_, _, line) self:OnRowRightClick(line) end
    self.items.Paint = function(listView)
        for _, line in ipairs(listView:GetLines()) do
            for i = 1, #listView.Columns do
                local colData = line.Columns and line.Columns[i]
                if colData and colData.TextPanel then colData.TextPanel:SetTextColor(lia.color.theme.text or color_white) end
            end
        end
    end

    self.lines = {}
    self:ReloadItemList()
    self:listenForUpdates()
end

function PANEL:populateFactionPanel()
    if not IsValid(self.factionScroll) then return end
    self.factionScroll:Clear()
    for k, v in ipairs(lia.faction.indices) do
        local panel = self.factionScroll:Add("DPanel")
        panel:Dock(TOP)
        panel:DockPadding(4, 4, 4, 4)
        panel:DockMargin(0, 0, 0, 4)
        panel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(4):Color(lia.color.theme.panel[1]):Draw() end
        local faction = panel:Add("DCheckBoxLabel")
        faction:Dock(TOP)
        faction:SetTextColor(lia.color.theme.text or color_white)
        faction:SetText(L(v.name))
        faction:DockMargin(0, 0, 0, 4)
        faction:SetFont("LiliaFont.17")
        faction.factionID = k
        faction.OnChange = function(_, state) lia.vendor.editor.faction(k, state) end
        self.factions[k] = faction
        for k2, v2 in ipairs(lia.class.list) do
            if v2.faction == k then
                local class = panel:Add("DCheckBoxLabel")
                class:Dock(TOP)
                class:DockMargin(16, 0, 0, 4)
                class:SetText(L(v2.name))
                class:SetTextColor(lia.color.theme.text or color_white)
                class:SetFont("LiliaFont.17")
                class.classID = k2
                class.factionID = faction.factionID
                class.OnChange = function(_, state) lia.vendor.editor.class(k2, state) end
                self.classes[k2] = class
                panel:SetTall(panel:GetTall() + class:GetTall() + 4)
            end
        end
    end

    self:updateFactionChecked()
    hook.Add("VendorFactionUpdated", self, self.updateFactionChecked)
    hook.Add("VendorClassUpdated", self, self.updateFactionChecked)
end

function PANEL:updateFactionChecked()
    local entity = liaVendorEnt
    if not entity then return end
    for id, panel in pairs(self.factions) do
        panel:SetChecked(entity:isFactionAllowed(id))
    end

    for id, panel in pairs(self.classes) do
        panel:SetChecked(entity:isClassAllowed(id))
    end
end

function PANEL:PerformLayout(width, height)
    self.BaseClass.PerformLayout(self, width, height)
    if IsValid(self.cls) then
        self.cls:SetSize(20, 20)
        self.cls:SetPos(width - 22, 2)
    end

    if IsValid(self.leftPanel) then self.leftPanel:SetWide(width * 0.4) end
end

local VendorText = {
    [VENDOR_SELLANDBUY] = "buyOnlynSell",
    [VENDOR_BUYONLY] = "buyOnly",
    [VENDOR_SELLONLY] = "sellOnly",
}

function PANEL:getModeText(mode)
    return mode and L(VendorText[mode]) or L("none")
end

function PANEL:OnRemove()
    if IsValid(lia.gui.editorFaction) then lia.gui.editorFaction:Remove() end
    if self.refreshTimer then timer.Remove(self.refreshTimer) end
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

function PANEL:OnFocusChanged(gained)
    if not gained then
        timer.Simple(0, function()
            if not IsValid(self) then return end
            self:MakePopup()
        end)
    end
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

    local currentAnimation = liaVendorEnt:getNetVar("animation", "")
    if isstring(currentAnimation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
end

function PANEL:onNameDescChanged(key)
    local entity = liaVendorEnt
    if key == "name" then
        self.name:SetText(entity:getName())
    elseif key == "model" then
        self.model:SetText(entity:GetModel())
        self:refreshAnimationDropdown()
        timer.Simple(0.1, function()
            if IsValid(self) and IsValid(entity) then
                local currentAnimation = entity:getNetVar("animation", "")
                if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
            end
        end)
    elseif key == "scale" then
        self:updateSellScale()
    elseif key == "welcome" and entity.getWelcomeMessage then
        self.welcome:SetText(entity:getWelcomeMessage())
    elseif key == "animation" then
        local currentAnimation = entity:getNetVar("animation", "")
        if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
    end
end

function PANEL:onItemModeUpdated(_, itemType, value)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    line:SetColumnText(COLS_MODE, self:getModeText(value))
    timer.Simple(0, function()
        if IsValid(line) then
            local colData = line.Columns and line.Columns[COLS_MODE]
            if colData and colData.TextPanel then colData.TextPanel:SetTextColor(lia.color.theme.text or color_white) end
        end
    end)
end

function PANEL:onItemPriceUpdated(vendor, itemType)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    line:SetColumnText(COLS_PRICE, vendor:getPrice(itemType))
    timer.Simple(0, function()
        if IsValid(line) then
            local colData = line.Columns and line.Columns[COLS_PRICE]
            if colData and colData.TextPanel then colData.TextPanel:SetTextColor(lia.color.theme.text or color_white) end
        end
    end)
end

function PANEL:onItemStockUpdated(vendor, itemType)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    local current, max = vendor:getStock(itemType)
    line:SetColumnText(COLS_STOCK, max and current .. "/" .. max or "-")
    timer.Simple(0, function()
        if IsValid(line) then
            local colData = line.Columns and line.Columns[COLS_STOCK]
            if colData and colData.TextPanel then colData.TextPanel:SetTextColor(lia.color.theme.text or color_white) end
        end
    end)
end

function PANEL:listenForUpdates()
    hook.Add("VendorEdited", self, self.onNameDescChanged)
    hook.Add("VendorItemModeUpdated", self, self.onItemModeUpdated)
    hook.Add("VendorItemPriceUpdated", self, self.onItemPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
end

function PANEL:OnRowRightClick(line)
    local entity = liaVendorEnt
    if not IsValid(entity) then
        LocalPlayer():notifyError(L("vendorEntityInvalid"))
        return
    end

    if IsValid(menu) then menu:Remove() end
    local uniqueID = line.item
    local itemTable = lia.item.list[uniqueID]
    menu = lia.derma.dermaMenu()
    local mode, modePanel = menu:AddSubMenu(L("mode"))
    modePanel:SetImage("icon16/key.png")
    mode:AddOption(L("none"), function() lia.vendor.editor.mode(uniqueID, nil) end):SetImage("icon16/cog_error.png")
    mode:AddOption(L("buyOnlynSell"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLANDBUY) end):SetImage("icon16/cog.png")
    mode:AddOption(L("buyOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_BUYONLY) end):SetImage("icon16/cog_delete.png")
    mode:AddOption(L("sellOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLONLY) end):SetImage("icon16/cog_add.png")
    menu:AddOption(L("price"), function()
        LocalPlayer():requestString(itemTable:getName(), L("vendorPriceReq"), function(text)
            text = tonumber(text)
            lia.vendor.editor.price(uniqueID, text)
        end, entity:getPrice(uniqueID))
    end):SetImage("icon16/coins.png")

    local stock, stockPanel = menu:AddSubMenu(L("stock"))
    stockPanel:SetImage("icon16/table.png")
    stock:AddOption(L("disable"), function() lia.vendor.editor.stockDisable(uniqueID) end):SetImage("icon16/table_delete.png")
    stock:AddOption(L("edit"), function()
        local _, max = entity:getStock(uniqueID)
        LocalPlayer():requestString(itemTable:getName(), L("vendorStockReq"), function(text)
            text = math.max(math.Round(tonumber(text) or 1), 1)
            lia.vendor.editor.stockMax(uniqueID, text)
        end, max or 1)
    end):SetImage("icon16/table_edit.png")

    stock:AddOption(L("vendorEditCurStock"), function()
        LocalPlayer():requestString(itemTable:getName(), L("vendorStockCurReq"), function(text)
            text = math.Round(tonumber(text) or 0)
            lia.vendor.editor.stock(uniqueID, text)
        end, entity:getStock(uniqueID) or 0)
    end):SetImage("icon16/table_edit.png")

    menu:Open()
end

function PANEL:ReloadItemList(filter)
    local entity = liaVendorEnt
    if not IsValid(entity) then
        self.lines = {}
        self.items:Clear()
        return
    end

    self.lines = {}
    self.items:Clear()
    for k, v in SortedPairsByMemberValue(lia.item.list, "name") do
        local name = v.getName and v:getName() or v.name
        if filter and not (v.getName and name or L(name)):lower():find(filter:lower(), 1, true) then continue end
        local mode = entity.items[k] and entity.items[k][VENDOR_MODE]
        local current, max = entity:getStock(k)
        local panel = self.items:AddLine(v.getName and name or L(name), self:getModeText(mode), entity:getPrice(k), max and current .. "/" .. max or "-", v:getCategory())
        panel.item = k
        self.lines[k] = panel
        timer.Simple(0, function()
            if IsValid(panel) then
                for i = 1, #self.items.Columns do
                    local colData = panel.Columns and panel.Columns[i]
                    if colData and colData.TextPanel then colData.TextPanel:SetTextColor(lia.color.theme.text or color_white) end
                end
            end
        end)
    end
end

vgui.Register("liaVendorEditor", PANEL, "liaFrame")
PANEL = {}
local function onFactionStateChanged(checkBox, state)
    lia.vendor.editor.faction(checkBox.factionID, state)
end

local function onClassStateChanged(checkBox, state)
    lia.vendor.editor.class(checkBox.classID, state)
end

function PANEL:Init()
    if IsValid(lia.gui.vendorFactionEditor) then lia.gui.vendorFactionEditor:Remove() end
    lia.gui.vendorFactionEditor = self
    self:SetSize(256, 360)
    self:Center()
    self:MakePopup()
    self:SetTitle(L("vendorFaction"))
    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockPadding(0, 0, 0, 4)
    self.factions = {}
    self.classes = {}
    for k, v in ipairs(lia.faction.indices) do
        local panel = self.scroll:Add("DPanel")
        panel:Dock(TOP)
        panel:DockPadding(4, 4, 4, 4)
        panel:DockMargin(0, 0, 0, 4)
        local faction = panel:Add("DCheckBoxLabel")
        faction:Dock(TOP)
        faction:SetTextColor(lia.color.theme.text or color_white)
        faction:SetText(L(v.name))
        faction:DockMargin(0, 0, 0, 4)
        faction.factionID = k
        faction.OnChange = onFactionStateChanged
        self.factions[k] = faction
        for k2, v2 in ipairs(lia.class.list) do
            if v2.faction == k then
                local class = panel:Add("DCheckBoxLabel")
                class:Dock(TOP)
                class:DockMargin(16, 0, 0, 4)
                class:SetText(L(v2.name))
                class:SetTextColor(lia.color.theme.text or color_white)
                class.classID = k2
                class.factionID = faction.factionID
                class.OnChange = onClassStateChanged
                self.classes[k2] = class
                panel:SetTall(panel:GetTall() + class:GetTall() + 4)
            end
        end
    end

    self:updateChecked()
    hook.Add("VendorFactionUpdated", self, self.updateChecked)
    hook.Add("VendorClassUpdated", self, self.updateChecked)
end

function PANEL:updateChecked()
    local entity = liaVendorEnt
    for id, panel in pairs(self.factions) do
        panel:SetChecked(entity:isFactionAllowed(id))
    end

    for id, panel in pairs(self.classes) do
        panel:SetChecked(entity:isClassAllowed(id))
    end
end

vgui.Register("liaVendorFactionEditor", PANEL, "liaFrame")
PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.vendorBodygroupEditor) then lia.gui.vendorBodygroupEditor:Remove() end
    lia.gui.vendorBodygroupEditor = self
    self:SetSize(256, 360)
    self:Center()
    self:MakePopup()
    self:SetTitle(L("bodygroups"))
    self.scroll = self:Add("liaScrollPanel")
    self.scroll:Dock(FILL)
    self.scroll:DockPadding(0, 0, 0, 4)
    self.sliders = {}
    local entity = liaVendorEnt
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) <= 1 then continue end
        local slider = self.scroll:Add("DNumSlider")
        slider:Dock(TOP)
        slider:DockMargin(0, 0, 0, 4)
        slider:SetText(entity:GetBodygroupName(i))
        slider.Label:SetTextColor(lia.color.theme.text or color_white)
        slider:SetDecimals(0)
        slider:SetMinMax(0, entity:GetBodygroupCount(i) - 1)
        slider:SetValue(entity:GetBodygroup(i))
        slider.OnValueChanged = function(_, val) lia.vendor.editor.bodygroup(i, math.Round(val)) end
        slider.Paint = function(s, w)
            if not IsValid(s.Label) then return end
            s.Label:Dock(TOP)
            s.Label:DockMargin(0, 0, 0, 5)
            s.Label:SetTall(20)
            s.Label:SetTextColor(lia.color.theme.text or color_white)
            local trackY = 25
            local trackHeight = 6
            local handleWidth = 20
            local progress = (s:GetValue() - s:GetMin()) / (s:GetMax() - s:GetMin())
            local activeWidth = math.Clamp(w * progress, 0, w)
            lia.derma.rect(0, trackY, w, trackHeight):Rad(3):Color(lia.color.theme.window_shadow or Color(60, 60, 60)):Draw()
            lia.derma.rect(0, trackY, w, trackHeight):Rad(3):Color(lia.color.theme.focus_panel or Color(80, 80, 80)):Draw()
            lia.derma.rect(0, trackY, activeWidth, trackHeight):Rad(3):Color(lia.color.theme.theme or Color(100, 150, 200)):Draw()
            local handleX = activeWidth - handleWidth / 2
            handleX = math.Clamp(handleX, 0, w - handleWidth)
            lia.derma.rect(handleX, trackY - 2, handleWidth, trackHeight + 4):Rad(3):Color(lia.color.theme.theme or Color(100, 150, 200)):Shadow(2, 8):Draw()
            draw.SimpleText(s:GetValue(), "LiliaFont.16", w / 2, 8, lia.color.theme.text or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        self.sliders[i] = slider
    end

    hook.Add("VendorEdited", self, self.onVendorEdited)
end

function PANEL:onVendorEdited(_, key)
    if key ~= "bodygroup" and key ~= "skin" then return end
    local entity = liaVendorEnt
    for id, s in pairs(self.sliders) do
        s:SetValue(entity:GetBodygroup(id))
    end
end

function PANEL:OnRemove()
    hook.Remove("VendorEdited", self)
end

vgui.Register("liaVendorBodygroupEditor", PANEL, "liaFrame")
