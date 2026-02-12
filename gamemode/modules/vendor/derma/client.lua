local sw, sh = ScrW(), ScrH()
local RarityColors = lia.item.rarities
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
    self.vendorPanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(25, 28, 35, 240)):Draw() end
    self.mePanel = self:Add("liaSemiTransparentDPanel")
    self.mePanel:SetSize(self.panelW, panelH)
    self.mePanel:SetPos(sw * 0.5 + 16, self.y0)
    self.mePanel.items = self.mePanel:Add("liaScrollPanel")
    self.mePanel.items:Dock(FILL)
    self.mePanel.items:DockPadding(8, 8, 8, 8)
    self.mePanel.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(25, 28, 35, 240)):Draw() end
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
        menu.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(6):Color(Color(25, 28, 35, 250)):Draw() end
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
    local data = liaVendorEnt.items or {}
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
    local data = liaVendorEnt.items or {}
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
    local data = liaVendorEnt.items or {}
    for id in SortedPairs(data) do
        local itm = lia.item.list[id]
        if not itm then continue end
        local cat = itm:getCategory()
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
    for _, p in pairs(self.items.vendor) do
        if IsValid(p) then p:Remove() end
    end

    for _, p in pairs(self.items.me) do
        if IsValid(p) then p:Remove() end
    end

    self.items.vendor = {}
    self.items.me = {}
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
    self.localCooldowns = {}
    self.purchaseAttempted = false
    self.purchaseAttemptTime = nil
    self.cooldownTimer = "vendorCooldown_" .. tostring(self)
    timer.Create(self.cooldownTimer, 1, 0, function()
        if IsValid(self) and IsValid(self.action) then
            if self.isSelling then
                self:updateAction()
                self:updateCooldown()
            else
                self:updateCooldown()
                self:updateAction()
            end

            if IsValid(self) then
                self:InvalidateLayout(true)
                self:SetVisible(true)
            end

            if IsValid(self.action) then self.action:InvalidateLayout(true) end
        else
            timer.Remove(self.cooldownTimer)
        end
    end)

    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background.Paint = function(_, w, h)
        local theme = lia.color.theme
        local bgColor = Color(25, 28, 35, 240)
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
    self.action:SetEnabled(true)
    self.action:SetVisible(true)
    self.action:SetText("")
    self.action.text = ""
    self.action._hasCustomPaint = false
    if not self.action._originalPaint then self.action._originalPaint = self.action.Paint end
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
    if item.Cooldown and item.Cooldown > 0 then
        self.purchaseAttempted = true
        self.purchaseAttemptTime = os.time()
        timer.Simple(0.1, function()
            if IsValid(self) then
                self:updateCooldown()
                if IsValid(self.action) then self.action:InvalidateLayout(true) end
            end
        end)
    end

    if IsValid(lia.gui.vendor) then
        lia.gui.vendor:buyItemFromVendor(item.uniqueID)
        clickEffects()
    end
end

function PANEL:updateCooldown()
    if not self.action or not self.item then return end
    if self.isSelling then
        if self.action and self.action._hasCustomPaint then
            if self._cooldownThinkAdded and self._cooldownHookName then
                hook.Remove("Think", self._cooldownHookName)
                self._cooldownThinkAdded = false
                self._cooldownHookName = nil
            end

            if self.action._originalPaint then
                self.action.Paint = self.action._originalPaint
            else
                self.action.Paint = nil
            end

            self.action._hasCustomPaint = false
            if self.action._originalCol then
                self.action.col = self.action._originalCol
                self.action._originalCol = nil
            end

            if self.action._originalColHov then
                self.action.col_hov = self.action._originalColHov
                self.action._originalColHov = nil
            end

            self.action:SetVisible(true)
            self.action:SetText(L("sell"))
            self.action.text = L("sell")
            self.action:SetEnabled(true)
            self.action:InvalidateLayout()
        end
        return
    end

    if not self.item.Cooldown or self.item.Cooldown <= 0 then return end
    local client = LocalPlayer()
    local char = client:getChar()
    local remainingTime = 0
    local shouldShowCooldown = false
    if self.purchaseAttempted and self.purchaseAttemptTime then
        local timeSinceAttempt = os.time() - self.purchaseAttemptTime
        if timeSinceAttempt < self.item.Cooldown then
            remainingTime = math.max(0, math.ceil(self.item.Cooldown - timeSinceAttempt))
            shouldShowCooldown = remainingTime > 0
        elseif timeSinceAttempt > self.item.Cooldown + 10 then
            self.purchaseAttempted = false
            self.purchaseAttemptTime = nil
        end
    end

    if not shouldShowCooldown and char then
        local cooldowns = char:getData("vendorCooldowns", {})
        local lastPurchase = 0
        if istable(cooldowns) then
            lastPurchase = cooldowns[self.item.uniqueID] or 0
        elseif isstring(cooldowns) then
            local itemPattern = self.item.uniqueID .. ";([^;]+);"
            local hexTimestamp = string.match(cooldowns, itemPattern)
            if hexTimestamp then
                if string.sub(hexTimestamp, 1, 1) == "X" then
                    local hexValue = string.sub(hexTimestamp, 2)
                    lastPurchase = tonumber(hexValue, 16) or 0
                else
                    lastPurchase = tonumber(hexTimestamp) or 0
                end
            end
        end

        if lastPurchase > 0 then
            local timeSincePurchase = os.time() - lastPurchase
            remainingTime = math.max(0, math.ceil(self.item.Cooldown - timeSincePurchase))
            if remainingTime > 0 then shouldShowCooldown = true end
        end
    end

    if shouldShowCooldown and remainingTime > 0 and not self.isSelling then
        local minutes = math.floor(remainingTime / 60)
        local seconds = remainingTime % 60
        local timeString
        if minutes > 0 then
            timeString = string.format("%dm %ds", minutes, seconds)
        else
            timeString = string.format("%ds", seconds)
        end

        local cooldownText = L("vendorOnCooldown", timeString)
        self.action:SetText(cooldownText)
        self.action.text = cooldownText
        self.action:SetEnabled(false)
        self.action.DoClick = function() end
        self.action:InvalidateLayout()
        self.action:SetText(cooldownText)
        self.action:InvalidateLayout(true)
        if IsValid(self) then self:InvalidateLayout() end
        local adjustedColors = lia.color.returnMainAdjustedColors()
        local negativeColor = adjustedColors.negative or Color(255, 100, 100)
        if not self.action._hasCustomPaint then
            self.action._originalCol = self.action.col
            self.action._originalColHov = self.action.col_hov
        end

        self.action.col = negativeColor
        self.action.col_hov = Color(math.Clamp(negativeColor.r * 0.85, 0, 255), math.Clamp(negativeColor.g * 0.85, 0, 255), math.Clamp(negativeColor.b * 0.85, 0, 255))
        local panelSelf = self
        self.action.Paint = function(panel, w, h)
            if panelSelf and panelSelf.item and not panelSelf.isSelling and panelSelf.action._hasCustomPaint and panelSelf.item.Cooldown and panelSelf.item.Cooldown > 0 then
                local paintRemainingTime = 0
                local paintClient = LocalPlayer()
                local paintChar = paintClient:getChar()
                if panelSelf.purchaseAttempted and panelSelf.purchaseAttemptTime then
                    local timeSinceAttempt = os.time() - panelSelf.purchaseAttemptTime
                    if timeSinceAttempt < panelSelf.item.Cooldown then paintRemainingTime = math.max(0, math.ceil(panelSelf.item.Cooldown - timeSinceAttempt)) end
                end

                if paintRemainingTime == 0 and paintChar then
                    local cooldowns = paintChar:getData("vendorCooldowns", {})
                    local lastPurchase = 0
                    if istable(cooldowns) then
                        lastPurchase = cooldowns[panelSelf.item.uniqueID] or 0
                    elseif isstring(cooldowns) then
                        local itemPattern = panelSelf.item.uniqueID .. ";([^;]+);"
                        local hexTimestamp = string.match(cooldowns, itemPattern)
                        local isHex = hexTimestamp and string.sub(hexTimestamp, 1, 1) == "X"
                        local hexValue = hexTimestamp and (isHex and string.sub(hexTimestamp, 2) or hexTimestamp) or ""
                        local base = isHex and 16 or 10
                        lastPurchase = hexTimestamp and (tonumber(hexValue, base) or 0) or 0
                    end

                    if lastPurchase > 0 then
                        local timeSincePurchase = os.time() - lastPurchase
                        paintRemainingTime = math.max(0, math.ceil(panelSelf.item.Cooldown - timeSincePurchase))
                    end
                end

                if paintRemainingTime > 0 then
                    local paintCooldownText = L("vendorOnCooldown", paintRemainingTime)
                    panel.text = paintCooldownText
                    panel:SetText(paintCooldownText)
                end
            end

            local math_clamp = math.Clamp
            if panel:IsHovered() then
                panel.hover_status = math_clamp((panel.hover_status or 0) + 4 * FrameTime(), 0, 1)
            else
                panel.hover_status = math_clamp((panel.hover_status or 0) - 8 * FrameTime(), 0, 1)
            end

            local isActive = (panel:IsDown() or panel.Depressed) and (panel.hover_status or 0) > 0.8
            if isActive then panel._activeShadowTimer = SysTime() + (panel._activeShadowMinTime or 0.03) end
            local showActiveShadow = isActive or ((panel._activeShadowTimer or 0) > SysTime())
            local activeTarget = showActiveShadow and 10 or 0
            local activeSpeed = (activeTarget > 0) and 7 or 3
            panel._activeShadowLerp = Lerp(FrameTime() * activeSpeed, panel._activeShadowLerp or 0, activeTarget)
            if panel._activeShadowLerp > 0 then
                local col = Color(panel.col_hov.r, panel.col_hov.g, panel.col_hov.b, math.Clamp(panel.col_hov.a * 1.5, 0, 255))
                draw.RoundedBox(panel.radius or 16, 0, 0, w, h, col)
            end

            draw.RoundedBox(panel.radius or 16, 0, 0, w, h, panel.col)
            if panel.bool_gradient ~= false then
                local shadowCol = (lia.color.theme and lia.color.theme.button_shadow) or Color(18, 32, 32, 35)
                surface.SetDrawColor(shadowCol)
                surface.SetMaterial(Material("vgui/gradient-d"))
                surface.DrawTexturedRect(0, 0, w, h)
            end

            if panel.bool_hover ~= false and (panel.hover_status or 0) > 0 then
                local hoverCol = Color(panel.col_hov.r, panel.col_hov.g, panel.col_hov.b, (panel.hover_status or 0) * 255)
                draw.RoundedBox(panel.radius or 16, 0, 0, w, h, hoverCol)
            end

            if panel.click_alpha and panel.click_alpha > 0 then
                panel.click_alpha = math_clamp(panel.click_alpha - FrameTime() * (panel.ripple_speed or 4), 0, 1)
                local ripple_size = (1 - panel.click_alpha) * math.max(w, h) * 2
                local ripple_color = Color(255, 255, 255, 30 * panel.click_alpha)
                draw.RoundedBox(ripple_size * 0.5, (panel.click_x or w / 2) - ripple_size * 0.5, (panel.click_y or h / 2) - ripple_size * 0.5, ripple_size, ripple_size, ripple_color)
            end

            local iconSize = panel.icon_size or 16
            local displayText = panel.text or ""
            if displayText == "" then displayText = panel:GetText() or "" end
            if displayText ~= "" then
                draw.SimpleText(displayText, panel.font or "LiliaFont.16", w * 0.5 + (panel.icon and panel.icon ~= "" and iconSize * 0.5 + 2 or 0), h * 0.5, (lia.color.theme and lia.color.theme.text) or Color(210, 235, 235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                if panel.icon and panel.icon ~= "" then
                    surface.SetFont(panel.font or "LiliaFont.16")
                    local textSize = surface.GetTextSize(displayText)
                    local posX = (w - textSize - iconSize) * 0.5 - 2
                    local posY = (h - iconSize) * 0.5
                    surface.SetMaterial(panel.icon)
                    surface.SetDrawColor(color_white)
                    surface.DrawTexturedRect(posX, posY, iconSize, iconSize)
                end
            elseif panel.icon and panel.icon ~= "" then
                local posX = (w - iconSize) * 0.5
                local posY = (h - iconSize) * 0.5
                surface.SetMaterial(panel.icon)
                surface.SetDrawColor(color_white)
                surface.DrawTexturedRect(posX, posY, iconSize, iconSize)
            end
        end

        self.action._hasCustomPaint = true
        if not self._cooldownThinkAdded then
            self._cooldownThinkAdded = true
            local hookName = "VendorCooldownUpdate_" .. tostring(self)
            self._cooldownHookName = hookName
            hook.Add("Think", hookName, function()
                if not IsValid(self) or not IsValid(self.action) or not self.action._hasCustomPaint then
                    hook.Remove("Think", hookName)
                    if IsValid(self) then
                        self._cooldownThinkAdded = false
                        self._cooldownHookName = nil
                    end
                    return
                end

                self.action:InvalidateLayout()
            end)
        end
    else
        if self.action._hasCustomPaint then
            if self._cooldownThinkAdded and self._cooldownHookName then
                hook.Remove("Think", self._cooldownHookName)
                self._cooldownThinkAdded = false
                self._cooldownHookName = nil
            end

            if self.action._originalPaint then
                self.action.Paint = self.action._originalPaint
            else
                self.action.Paint = nil
            end

            self.action._hasCustomPaint = false
            if self.action._originalCol then
                self.action.col = self.action._originalCol
                self.action._originalCol = nil
            end

            if self.action._originalColHov then
                self.action.col_hov = self.action._originalColHov
                self.action._originalColHov = nil
            end

            self.action:InvalidateLayout()
        end
    end
end

function PANEL:updateAction()
    if not self.action or not self.item then return end
    if not IsValid(liaVendorEnt) then
        local errorText = self.isSelling and L("vendorSellAction", L("vendorNotAvailable")) or L("vendorBuyAction", L("vendorNotAvailable"))
        self.action:SetText(errorText)
        self.action.text = errorText
        return
    end

    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling, LocalPlayer())
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
    self.action:SetVisible(true)
    if self.isSelling then
        if self.action._hasCustomPaint then
            if self._cooldownThinkAdded and self._cooldownHookName then
                hook.Remove("Think", self._cooldownHookName)
                self._cooldownThinkAdded = false
                self._cooldownHookName = nil
            end

            if self.action._originalPaint then
                self.action.Paint = self.action._originalPaint
            else
                self.action.Paint = nil
            end

            self.action._hasCustomPaint = false
            if self.action._originalCol then
                self.action.col = self.action._originalCol
                self.action._originalCol = nil
            end

            if self.action._originalColHov then
                self.action.col_hov = self.action._originalColHov
                self.action._originalColHov = nil
            end
        end

        local buttonText = L("sell")
        self.action:SetText(buttonText)
        self.action.text = buttonText
        self.action:SetEnabled(true)
        self.action:SetVisible(true)
        self.action:InvalidateLayout()
        self.action.DoClick = function() self:sellItemToVendor() end
        return
    end

    local isInCooldown = self.action._hasCustomPaint or false
    if not isInCooldown then
        local buttonText = self.isSelling and L("sell") or L("buy")
        self.action:SetText(buttonText)
        self.action.text = buttonText
        self.action:SetEnabled(true)
        if self.action._hasCustomPaint then
            if self.action._originalPaint then
                self.action.Paint = self.action._originalPaint
            else
                self.action.Paint = nil
            end

            self.action._hasCustomPaint = false
            if self.action._originalCol then
                self.action.col = self.action._originalCol
                self.action._originalCol = nil
            end

            if self.action._originalColHov then
                self.action.col_hov = self.action._originalColHov
                self.action._originalColHov = nil
            end

            self.action:InvalidateLayout()
        end

        self.action.DoClick = function()
            if self.isSelling then
                self:sellItemToVendor()
            else
                self:buyItemFromVendor()
            end
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
    self:updateCooldown()
    local rarity = item.rarity or "Common"
    local nameColor = RarityColors[rarity] or color_white
    self.name:SetTextColor(nameColor)
end

function PANEL:setIsSelling(isSelling)
    self.isSelling = isSelling
    self:updateLabel()
    self:updateAction()
    self:updateCooldown()
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
    if self._cooldownThinkAdded and self._cooldownHookName then
        hook.Remove("Think", self._cooldownHookName)
        self._cooldownThinkAdded = false
        self._cooldownHookName = nil
    end
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

    local width = math.min(ScrW() * 0.95, 1400)
    local height = math.min(ScrH() * 0.90, 900)
    self:SetSize(width, height)
    self:MakePopup()
    self:Center()
    self:SetTitle(L("vendorEditor"))
    self.name = self:Add("liaEntry")
    self.name:Dock(TOP)
    self.name:SetPlaceholderText(L("name"))
    self.name:SetValue(entity:getName())
    self.name.action = function(value)
        local currentName = lia.vendor.getVendorProperty(entity, "name")
        if currentName ~= value then
            if not value or value == "" then value = L("vendorDefaultName") end
            if not self.name.processing then
                self.name.processing = true
                lia.vendor.editor.name(value)
                timer.Simple(0.1, function() if IsValid(self) and IsValid(self.name) then self.name.processing = false end end)
            end
        end
    end

    self.model = self:Add("liaEntry")
    self.model:Dock(TOP)
    self.model:DockMargin(0, 4, 0, 0)
    self.model:SetPlaceholderText(L("model"))
    self.model:SetValue(entity:GetModel())
    self.model.action = function(value)
        local modelText = value:lower()
        if entity:GetModel():lower() ~= modelText then lia.vendor.editor.model(modelText) end
    end

    self.backgroundPanel = self:Add("DPanel")
    self.backgroundPanel:Dock(FILL)
    self.backgroundPanel:SetPaintBackground(false)
    self.factionsFrame = self.backgroundPanel:Add("liaFrame")
    self.factionsFrame:SetSize(width * 0.25, height)
    self.factionsFrame:SetPos(0, 0)
    self.factionsFrame:SetTitle(L("vendorFaction"))
    self.factionsFrame:SetDraggable(false)
    self.factionsFrame:ShowCloseButton(false)
    self.generalFrame = self.backgroundPanel:Add("liaFrame")
    self.generalFrame:SetSize(width * 0.20, height)
    self.generalFrame:SetPos(width * 0.25, 0)
    self.generalFrame:SetTitle(L("vendorGeneralInfo"))
    self.generalFrame:SetDraggable(false)
    self.generalFrame:ShowCloseButton(false)
    self.itemsFrame = self.backgroundPanel:Add("liaFrame")
    self.itemsFrame:SetSize(width * 0.55, height)
    self.itemsFrame:SetPos(width * 0.45, 0)
    self.itemsFrame:SetTitle(L("vendorItemsTitle"))
    self.itemsFrame:SetDraggable(false)
    self.itemsFrame:ShowCloseButton(false)
    self.factionPanel = self.factionsFrame:Add("DPanel")
    self.factionPanel:Dock(FILL)
    self.factionPanel:DockMargin(0, 8, 0, 0)
    self.factionPanel:SetPaintBackground(false)
    self.factionScroll = self.factionPanel:Add("liaScrollPanel")
    self.factionScroll:Dock(FILL)
    self.factionScroll:DockPadding(0, 0, 0, 4)
    self.factions = {}
    self.classes = {}
    self:populateFactionPanel()
    self.generalScroll = self.generalFrame:Add("liaScrollPanel")
    self.generalScroll:Dock(FILL)
    self.generalScroll:DockPadding(12, 12, 12, 12)
    self:initializeGeneralInfoPanel(entity)
    self.itemSearchBar = self.itemsFrame:Add("liaEntry")
    self.itemSearchBar:Dock(TOP)
    self.itemSearchBar:DockMargin(8, 8, 8, 4)
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

    self.items = self.itemsFrame:Add("liaTable")
    if not self.items then
        print("ERROR: Failed to create liaTable")
        return
    end

    self.items:Dock(FILL)
    self.items:DockMargin(8, 0, 8, 8)
    local nameCol = self.items:AddColumn("Name")
    nameCol:SetMinWidth(150)
    nameCol:SetMaxWidth(200)
    local modeCol = self.items:AddColumn("Mode")
    modeCol:SetMinWidth(110)
    local priceCol = self.items:AddColumn("Price")
    priceCol:SetMinWidth(90)
    local stockCol = self.items:AddColumn("Stock")
    stockCol:SetMinWidth(80)
    local categoryCol = self.items:AddColumn("Category")
    categoryCol:SetMinWidth(90)
    self.lines = {}
    self.items:ClearMenuOptions()
    self.items:AddMenuOption(L("mode") .. " - " .. L("none"), function(rowData)
        if not rowData or not rowData.item then return end
        lia.vendor.editor.mode(rowData.item, nil)
    end, "icon16/cog_error.png")

    self.items:AddMenuOption(L("mode") .. " - " .. L("buyOnlynSell"), function(rowData)
        if not rowData or not rowData.item then return end
        lia.vendor.editor.mode(rowData.item, VENDOR_SELLANDBUY)
    end, "icon16/cog.png")

    self.items:AddMenuOption(L("mode") .. " - " .. L("buyOnly"), function(rowData)
        if not rowData or not rowData.item then return end
        lia.vendor.editor.mode(rowData.item, VENDOR_BUYONLY)
    end, "icon16/cog_delete.png")

    self.items:AddMenuOption(L("mode") .. " - " .. L("sellOnly"), function(rowData)
        if not rowData or not rowData.item then return end
        lia.vendor.editor.mode(rowData.item, VENDOR_SELLONLY)
    end, "icon16/cog_add.png")

    self.items:AddMenuOption(L("price"), function(rowData)
        if not rowData or not rowData.item then return end
        local vEnt = liaVendorEnt
        if not IsValid(vEnt) then return end
        local itemTable = lia.item.list[rowData.item]
        if not itemTable then return end
        LocalPlayer():requestString(itemTable:getName(), L("vendorPriceReq"), function(text)
            text = tonumber(text)
            lia.vendor.editor.price(rowData.item, text)
        end, vEnt:getPrice(rowData.item))
    end, "icon16/coins.png")

    self.items:AddMenuOption(L("stock") .. " - " .. L("disable"), function(rowData)
        if not rowData or not rowData.item then return end
        lia.vendor.editor.stockDisable(rowData.item)
    end, "icon16/table_delete.png")

    self.items:AddMenuOption(L("stock") .. " - " .. L("edit"), function(rowData)
        if not rowData or not rowData.item then return end
        local vEnt = liaVendorEnt
        if not IsValid(vEnt) then return end
        local _, max = vEnt:getStock(rowData.item)
        local itemTable = lia.item.list[rowData.item]
        if not itemTable then return end
        LocalPlayer():requestString(itemTable:getName(), L("vendorStockReq"), function(text)
            text = math.max(math.Round(tonumber(text) or 1), 1)
            lia.vendor.editor.stockMax(rowData.item, text)
        end, max or 1)
    end, "icon16/table_edit.png")

    self.items:AddMenuOption(L("stock") .. " - " .. L("vendorEditCurStock"), function(rowData)
        if not rowData or not rowData.item then return end
        local vEnt = liaVendorEnt
        if not IsValid(vEnt) then return end
        local itemTable = lia.item.list[rowData.item]
        if not itemTable then return end
        LocalPlayer():requestString(itemTable:getName(), L("vendorStockCurReq"), function(text)
            text = math.Round(tonumber(text) or 0)
            lia.vendor.editor.stock(rowData.item, text)
        end, vEnt:getStock(rowData.item) or 0)
    end, "icon16/table_edit.png")

    self:ReloadItemList()
    self.items:InvalidateLayout(true)
    self:listenForUpdates()
end

function PANEL:initializeGeneralInfoPanel(entity)
    if not IsValid(entity) or not IsValid(self.generalScroll) then return end
    if not IsValid(self.nameLabel) then
        self.nameLabel = self.generalScroll:Add("DLabel")
        self.nameLabel:Dock(TOP)
        self.nameLabel:DockMargin(0, 0, 0, 6)
        self.nameLabel:SetText(L("vendorName"))
        self.nameLabel:SetFont("LiliaFont.20b")
        self.nameLabel:SetTextColor(lia.color.theme.text or color_white)
        self.nameLabel:SetContentAlignment(5)
        self.nameLabel:SetTall(24)
    end

    if not IsValid(self.name) then
        self.name:SetParent(self.generalScroll)
        self.name:Dock(TOP)
        self.name:DockMargin(0, 0, 0, 12)
    end

    if not IsValid(self.modelLabel) then
        self.modelLabel = self.generalScroll:Add("DLabel")
        self.modelLabel:Dock(TOP)
        self.modelLabel:DockMargin(0, 0, 0, 6)
        self.modelLabel:SetText(L("model"))
        self.modelLabel:SetFont("LiliaFont.20b")
        self.modelLabel:SetTextColor(lia.color.theme.text or color_white)
        self.modelLabel:SetContentAlignment(5)
        self.modelLabel:SetTall(24)
    end

    if not IsValid(self.model) then
        self.model:SetParent(self.generalScroll)
        self.model:Dock(TOP)
        self.model:DockMargin(0, 0, 0, 12)
    end

    if entity:SkinCount() > 1 and not IsValid(self.skinLabel) then
        self.skinLabel = self.generalScroll:Add("DLabel")
        self.skinLabel:Dock(TOP)
        self.skinLabel:DockMargin(0, 0, 0, 6)
        self.skinLabel:SetText(L("skin"))
        self.skinLabel:SetFont("LiliaFont.20b")
        self.skinLabel:SetTextColor(lia.color.theme.text or color_white)
        self.skinLabel:SetContentAlignment(5)
        self.skinLabel:SetTall(24)
    end

    if entity:SkinCount() > 1 and not IsValid(self.skin) then
        self.skin = self.generalScroll:Add("liaSlider")
        self.skin:Dock(TOP)
        self.skin:DockMargin(0, 0, 0, 8)
        self.skin:SetText(L("skin"))
        self.skin:SetRange(0, entity:SkinCount() - 1, 0)
        self.skin:SetValue(entity:GetSkin())
        self.skin.OnValueChanged = function(_, value)
            value = math.Round(value)
            if entity:GetSkin() ~= value then lia.vendor.editor.skin(value) end
        end
    end

    if not IsValid(self.animationLabel) then
        self.animationLabel = self.generalScroll:Add("DLabel")
        self.animationLabel:Dock(TOP)
        self.animationLabel:DockMargin(0, 0, 0, 6)
        self.animationLabel:SetText(L("animation"))
        self.animationLabel:SetFont("LiliaFont.20b")
        self.animationLabel:SetTextColor(lia.color.theme.text or color_white)
        self.animationLabel:SetContentAlignment(5)
        self.animationLabel:SetTall(24)
    end

    if not IsValid(self.animation) then
        self.animation = self.generalScroll:Add("liaComboBox")
        self.animation:Dock(TOP)
        self.animation:DockMargin(0, 0, 0, 8)
        self.animation:PostInit()
        self.animation:SetText(L("vendorPickAnimation"))
        self.animation:SetTooltip(L("vendorAnimationTooltip"))
        self:refreshAnimationDropdown()
        local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
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
    end

    if not IsValid(self.presetLabel) then
        self.presetLabel = self.generalScroll:Add("DLabel")
        self.presetLabel:Dock(TOP)
        self.presetLabel:DockMargin(0, 0, 0, 6)
        self.presetLabel:SetText(L("preset"))
        self.presetLabel:SetFont("LiliaFont.20b")
        self.presetLabel:SetTextColor(lia.color.theme.text or color_white)
        self.presetLabel:SetContentAlignment(5)
        self.presetLabel:SetTall(24)
    end

    if not IsValid(self.deletePresetButton) then
        self.deletePresetButton = self.generalScroll:Add("liaButton")
        self.deletePresetButton:Dock(TOP)
        self.deletePresetButton:DockMargin(0, 0, 0, 8)
        self.deletePresetButton:SetText(L("vendorDeletePreset"))
        self.deletePresetButton:SetTooltip(L("vendorDeletePresetTooltip"))
        self.deletePresetButton.DoClick = function() self:openDeletePresetSelector() end
    end

    if not IsValid(self.presetButton) then
        self.presetButton = self.generalScroll:Add("liaButton")
        self.presetButton:Dock(TOP)
        self.presetButton:DockMargin(0, 0, 0, 8)
        self.presetButton:SetText(L("vendorLoadPreset"))
        self.presetButton:SetTooltip(L("vendorLoadPresetTooltip"))
        self.presetButton.DoClick = function() self:openPresetSelector() end
    end

    if not IsValid(self.savePresetButton) then
        self.savePresetButton = self.generalScroll:Add("liaButton")
        self.savePresetButton:Dock(TOP)
        self.savePresetButton:DockMargin(0, 0, 0, 8)
        self.savePresetButton:SetText(L("vendorSavePreset"))
        self.savePresetButton:SetFont("LiliaFont.16")
        self.savePresetButton.DoClick = function()
            LocalPlayer():requestString(L("vendorSavePresetTitle"), L("vendorSavePresetPrompt"), function(text)
                if text and text ~= "" then
                    local items = liaVendorEnt.items or {}
                    net.Start("liaVendorSavePreset")
                    net.WriteString(text)
                    net.WriteTable(items)
                    net.SendToServer()
                    self:refreshPresetButton()
                end
            end)
        end
    end

    local hasBodygroupsBottom = false
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) > 1 then
            hasBodygroupsBottom = true
            break
        end
    end

    if hasBodygroupsBottom and not IsValid(self.bodygroupsPanel) then
        self.bodygroupsPanel = self.generalScroll:Add("DPanel")
        self.bodygroupsPanel:Dock(TOP)
        self.bodygroupsPanel:DockMargin(0, 8, 0, 8)
        self.bodygroupsPanel:SetTall(250)
        self.bodygroupsPanel:SetPaintBackground(false)
        local titleLabel = self.bodygroupsPanel:Add("DLabel")
        titleLabel:Dock(TOP)
        titleLabel:DockMargin(8, 8, 8, 6)
        titleLabel:SetTall(24)
        titleLabel:SetText(L("bodygroups"))
        titleLabel:SetFont("LiliaFont.20b")
        titleLabel:SetTextColor(lia.color.theme.text or color_white)
        titleLabel:SetContentAlignment(5)
        local bodygroupsScroll = self.bodygroupsPanel:Add("liaScrollPanel")
        bodygroupsScroll:Dock(FILL)
        bodygroupsScroll:DockPadding(8, 4, 8, 8)
        for i = 0, entity:GetNumBodyGroups() - 1 do
            if entity:GetBodygroupCount(i) <= 1 then continue end
            local bodygroupLabel = bodygroupsScroll:Add("DLabel")
            bodygroupLabel:Dock(TOP)
            bodygroupLabel:DockMargin(0, 0, 0, 6)
            bodygroupLabel:SetText(entity:GetBodygroupName(i))
            bodygroupLabel:SetFont("LiliaFont.18b")
            bodygroupLabel:SetTextColor(lia.color.theme.text or color_white)
            bodygroupLabel:SetContentAlignment(5)
            bodygroupLabel:SetTall(22)
            local slider = bodygroupsScroll:Add("liaSlider")
            slider:Dock(TOP)
            slider:DockMargin(0, 0, 0, 8)
            slider:SetText("")
            slider:SetRange(0, entity:GetBodygroupCount(i) - 1, 0)
            slider:SetValue(entity:GetBodygroup(i))
            slider.OnValueChanged = function(_, val)
                val = math.Round(val)
                local timerName = "liaVendorBodygroup" .. i
                timer.Create(timerName, 0.3, 1, function() if IsValid(slider) then lia.vendor.editor.bodygroup(i, val) end end)
            end
        end
    end

    self.generalScroll:InvalidateLayout(true)
    self.generalScroll:SizeToChildren(false, true)
end

function PANEL:populateFactionPanel()
    if not IsValid(self.factionScroll) then return end
    self.factionScroll:Clear()
    for k, v in ipairs(lia.faction.indices) do
        local panel = self.factionScroll:Add("liaSemiTransparentDPanel")
        panel:Dock(TOP)
        panel:DockPadding(8, 8, 8, 8)
        panel:DockMargin(0, 0, 0, 6)
        panel.hoverAlpha = 0
        panel.Paint = function(_, w, h)
            local theme = lia.color.theme
            local bgColor = Color(25, 28, 35, 240)
            local hoverColor = theme and theme.button_hovered or Color(70, 140, 140, 30)
            lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Draw()
            if panel:IsHovered() then
                panel.hoverAlpha = math.min(panel.hoverAlpha + FrameTime() * 5, 1)
            else
                panel.hoverAlpha = math.max(panel.hoverAlpha - FrameTime() * 5, 0)
            end

            if panel.hoverAlpha > 0 then
                local hoverCol = ColorAlpha(hoverColor, hoverColor.a * panel.hoverAlpha)
                lia.derma.rect(0, 0, w, h):Rad(8):Color(hoverCol):Draw()
            end

            if panel.hoverAlpha > 0.5 then
                local glowColor = ColorAlpha(theme and theme.theme or Color(100, 150, 200), 15 * panel.hoverAlpha)
                lia.derma.rect(2, 2, w - 4, h - 4):Rad(6):Color(glowColor):Draw()
            end

            surface.SetDrawColor(theme and theme.panel and theme.panel[2] or Color(80, 80, 80, 100))
            surface.DrawOutlinedRect(0, 0, w, h)
            if panel.hoverAlpha > 0.3 then
                surface.SetDrawColor(ColorAlpha(theme and theme.theme or Color(100, 150, 200), 100 * panel.hoverAlpha))
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        end

        local factionHeader = panel:Add("DPanel")
        factionHeader:Dock(TOP)
        factionHeader:DockMargin(0, 0, 0, 8)
        factionHeader:SetTall(36)
        factionHeader:SetPaintBackground(false)
        local factionCheckbox = factionHeader:Add("liaCheckbox")
        factionCheckbox:Dock(LEFT)
        factionCheckbox:SetWide(48)
        factionCheckbox:DockMargin(0, 0, 8, 0)
        factionCheckbox.factionID = k
        factionCheckbox.OnChange = function(_, state) lia.vendor.editor.faction(k, state) end
        self.factions[k] = factionCheckbox
        local factionLabel = factionHeader:Add("DLabel")
        factionLabel:Dock(FILL)
        factionLabel:SetText(L(v.name))
        factionLabel:SetTextColor(lia.color.theme.text or color_white)
        factionLabel:SetFont("LiliaFont.18b")
        factionLabel:SetContentAlignment(4)
        factionLabel:SetCursor("hand")
        factionLabel.DoClick = function() factionCheckbox:Toggle() end
        local separator = panel:Add("DPanel")
        separator:Dock(TOP)
        separator:DockMargin(0, 0, 0, 8)
        separator:SetTall(1)
        separator.Paint = function(_, w, h)
            surface.SetDrawColor(lia.color.theme.panel and lia.color.theme.panel[2] or Color(80, 80, 80, 50))
            surface.DrawRect(0, 0, w, h)
        end

        local classCount = 0
        for k2, v2 in ipairs(lia.class.list) do
            if v2.faction == k then
                local classRow = panel:Add("DPanel")
                classRow:Dock(TOP)
                classRow:DockMargin(16, 0, 0, 6)
                classRow:SetTall(28)
                classRow:SetPaintBackground(false)
                local classCheckbox = classRow:Add("liaCheckbox")
                classCheckbox:Dock(LEFT)
                classCheckbox:SetWide(44)
                classCheckbox:DockMargin(0, 0, 6, 0)
                classCheckbox.classID = k2
                classCheckbox.factionID = factionCheckbox.factionID
                classCheckbox.OnChange = function(_, state) lia.vendor.editor.class(k2, state) end
                self.classes[k2] = classCheckbox
                local classLabel = classRow:Add("DLabel")
                classLabel:Dock(FILL)
                classLabel:SetText(L(v2.name))
                classLabel:SetTextColor(lia.color.theme.text and ColorAlpha(lia.color.theme.text, 220) or Color(220, 220, 220))
                classLabel:SetFont("LiliaFont.16")
                classLabel:SetContentAlignment(4)
                classLabel:SetCursor("hand")
                classLabel.DoClick = function() classCheckbox:Toggle() end
                classCount = classCount + 1
            end
        end

        local buyScalePanel = panel:Add("DPanel")
        buyScalePanel:Dock(TOP)
        buyScalePanel:DockMargin(0, 8, 0, 4)
        buyScalePanel:SetTall(40)
        buyScalePanel:SetPaintBackground(false)
        local buyScaleLabel = buyScalePanel:Add("DLabel")
        buyScaleLabel:Dock(TOP)
        buyScaleLabel:SetText(string.format("%s - %s: %.0f%%", L(v.name), L("vendorBuyScale"), (liaVendorEnt:getFactionBuyScale(k) or 1.0) * 100))
        buyScaleLabel:SetFont("LiliaFont.16b")
        buyScaleLabel:SetTextColor(lia.color.theme.text or color_white)
        buyScaleLabel:SetContentAlignment(5)
        local buyScaleSlider = buyScalePanel:Add("liaSlider")
        buyScaleSlider:Dock(BOTTOM)
        buyScaleSlider:DockMargin(0, 4, 0, 0)
        buyScaleSlider:SetRange(0, 500, 10)
        buyScaleSlider:SetValue((liaVendorEnt:getFactionBuyScale(k) or 1.0) * 100)
        buyScaleSlider.OnValueChanged = function(_, value)
            value = math.Round(value) / 100
            local timerName = "liaVendorFactionBuyScale" .. k
            timer.Create(timerName, 0.3, 1, function()
                if IsValid(buyScaleSlider) then
                    lia.vendor.editor.factionBuyScale(k, value)
                    buyScaleLabel:SetText(string.format("%s - %s: %.0f%%", L(v.name), L("vendorBuyScale"), value * 100))
                end
            end)
        end

        local sellScalePanel = panel:Add("DPanel")
        sellScalePanel:Dock(TOP)
        sellScalePanel:DockMargin(0, 4, 0, 8)
        sellScalePanel:SetTall(40)
        sellScalePanel:SetPaintBackground(false)
        local sellScaleLabel = sellScalePanel:Add("DLabel")
        sellScaleLabel:Dock(TOP)
        sellScaleLabel:SetText(string.format("%s - %s: %.0f%%", L(v.name), L("vendorSellScale"), (liaVendorEnt:getFactionSellScale(k) or 1.0) * 100))
        sellScaleLabel:SetFont("LiliaFont.16b")
        sellScaleLabel:SetTextColor(lia.color.theme.text or color_white)
        sellScaleLabel:SetContentAlignment(5)
        local sellScaleSlider = sellScalePanel:Add("liaSlider")
        sellScaleSlider:Dock(BOTTOM)
        sellScaleSlider:DockMargin(0, 4, 0, 0)
        sellScaleSlider:SetRange(0, 100, 5)
        sellScaleSlider:SetValue((liaVendorEnt:getFactionSellScale(k) or 1.0) * 100)
        sellScaleSlider.OnValueChanged = function(_, value)
            value = math.Round(value) / 100
            local timerName = "liaVendorFactionSellScale" .. k
            timer.Create(timerName, 0.3, 1, function()
                if IsValid(sellScaleSlider) then
                    lia.vendor.editor.factionSellScale(k, value)
                    sellScaleLabel:SetText(string.format("%s - %s: %.0f%%", L(v.name), L("vendorSellScale"), value * 100))
                end
            end)
        end

        local baseHeight = 69 + (classCount * 34) + 96
        panel:SetTall(math.max(baseHeight, 100))
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

    if IsValid(self.factionsFrame) then
        self.factionsFrame:SetSize(width * 0.25, height)
        self.factionsFrame:SetPos(0, 0)
    end

    if IsValid(self.generalFrame) then
        self.generalFrame:SetSize(width * 0.20, height)
        self.generalFrame:SetPos(width * 0.25, 0)
    end

    if IsValid(self.itemsFrame) then
        self.itemsFrame:SetSize(width * 0.55, height)
        self.itemsFrame:SetPos(width * 0.45, 0)
        if IsValid(self.items) then self.items:InvalidateLayout(true) end
    end
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
    if IsValid(self.presetSelector) then self.presetSelector:Remove() end
    if IsValid(self.deletePresetSelector) then self.deletePresetSelector:Remove() end
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
    self.presetButton:SetText(L("vendorLoadPreset"))
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
    self.leftFrame:SetTitle(L("vendorLoadPreset"))
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
            priceLabel:SetText(L("priceLabel"))
            priceLabel:SetFont("LiliaFont.14")
            priceLabel:SetTextColor(Color(180, 180, 180))
            priceLabel:SizeToContents()
            priceLabel:SetTall(45)
            priceLabel:SetContentAlignment(4)
            local itemPrice = priceContainer:Add("DLabel")
            itemPrice:Dock(LEFT)
            itemPrice:DockMargin(5, 0, 0, 0)
            local price = itemData[VENDOR_PRICE] or item:getPrice()
            itemPrice:SetText(lia.currency.get(price))
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
            modeLabel:SetText(L("modeLabel"))
            modeLabel:SetFont("LiliaFont.14")
            modeLabel:SetTextColor(Color(180, 180, 180))
            modeLabel:SizeToContents()
            modeLabel:SetTall(45)
            modeLabel:SetContentAlignment(4)
            local itemMode = modeContainer:Add("DLabel")
            itemMode:Dock(LEFT)
            itemMode:DockMargin(5, 0, 0, 0)
            local mode = itemData[VENDOR_MODE]
            local modeText = L("vendorUnknownMode")
            local modeColor = Color(255, 255, 0)
            if mode == VENDOR_SELLANDBUY then
                modeText = L("vendorPresetBuySell")
                modeColor = Color(100, 255, 100)
            elseif mode == VENDOR_SELLONLY then
                modeText = L("vendorPresetSellOnly")
                modeColor = Color(255, 200, 100)
            elseif mode == VENDOR_BUYONLY then
                modeText = L("vendorPresetBuyOnly")
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
    elseif key == "model" then
        self.model:SetText(entity:GetModel())
        self:refreshAnimationDropdown()
        timer.Simple(0.1, function()
            if IsValid(self) and IsValid(entity) then
                local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
                if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
            end
        end)
    elseif key == "scale" then
        self:updateSellScale()
    elseif key == "animation" then
        local currentAnimation = lia.vendor.getVendorProperty(entity, "animation")
        if IsValid(self.animation) then self.animation:SetValue(currentAnimation == "" and L("none") or currentAnimation) end
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
    hook.Add("VendorItemModeUpdated", self, self.onItemModeUpdated)
    hook.Add("VendorItemPriceUpdated", self, self.onItemPriceUpdated)
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

    print("[liaVendorEditor] OnRowRightClick triggered for row", rowData and rowData.item)
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
    return true
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
        local rowData = self.items:AddLine(v.getName and name or L(name), self:getModeText(mode), entity:getPrice(k, false, LocalPlayer()), max and current .. "/" .. max or "-", v:getCategory())
        rowData.item = k
        self.lines[k] = rowData
    end

    self.items:ForceCommit()
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
        local panel = self.scroll:Add("liaSemiTransparentDPanel")
        panel:Dock(TOP)
        panel:DockPadding(8, 8, 8, 8)
        panel:DockMargin(0, 0, 0, 6)
        panel.hoverAlpha = 0
        panel.Paint = function(_, w, h)
            local theme = lia.color.theme
            local bgColor = Color(25, 28, 35, 240)
            local hoverColor = theme and theme.button_hovered or Color(70, 140, 140, 30)
            lia.derma.rect(0, 0, w, h):Rad(8):Color(bgColor):Draw()
            if panel:IsHovered() then
                panel.hoverAlpha = math.min(panel.hoverAlpha + FrameTime() * 5, 1)
            else
                panel.hoverAlpha = math.max(panel.hoverAlpha - FrameTime() * 5, 0)
            end

            if panel.hoverAlpha > 0 then
                local hoverCol = ColorAlpha(hoverColor, hoverColor.a * panel.hoverAlpha)
                lia.derma.rect(0, 0, w, h):Rad(8):Color(hoverCol):Draw()
            end

            if panel.hoverAlpha > 0.5 then
                local glowColor = ColorAlpha(theme and theme.theme or Color(100, 150, 200), 15 * panel.hoverAlpha)
                lia.derma.rect(2, 2, w - 4, h - 4):Rad(6):Color(glowColor):Draw()
            end

            surface.SetDrawColor(theme and theme.panel and theme.panel[2] or Color(80, 80, 80, 100))
            surface.DrawOutlinedRect(0, 0, w, h)
            if panel.hoverAlpha > 0.3 then
                surface.SetDrawColor(ColorAlpha(theme and theme.theme or Color(100, 150, 200), 100 * panel.hoverAlpha))
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        end

        local factionHeader = panel:Add("DPanel")
        factionHeader:Dock(TOP)
        factionHeader:DockMargin(0, 0, 0, 8)
        factionHeader:SetTall(36)
        factionHeader:SetPaintBackground(false)
        local factionCheckbox = factionHeader:Add("liaCheckbox")
        factionCheckbox:Dock(LEFT)
        factionCheckbox:SetWide(48)
        factionCheckbox:DockMargin(0, 0, 8, 0)
        factionCheckbox.factionID = k
        factionCheckbox.OnChange = onFactionStateChanged
        self.factions[k] = factionCheckbox
        local factionLabel = factionHeader:Add("DLabel")
        factionLabel:Dock(FILL)
        factionLabel:SetText(L(v.name))
        factionLabel:SetTextColor(lia.color.theme.text or color_white)
        factionLabel:SetFont("LiliaFont.18b")
        factionLabel:SetContentAlignment(4)
        factionLabel:SetCursor("hand")
        factionLabel.DoClick = function() factionCheckbox:Toggle() end
        local separator = panel:Add("DPanel")
        separator:Dock(TOP)
        separator:DockMargin(0, 0, 0, 8)
        separator:SetTall(1)
        separator.Paint = function(_, w, h)
            surface.SetDrawColor(lia.color.theme.panel and lia.color.theme.panel[2] or Color(80, 80, 80, 50))
            surface.DrawRect(0, 0, w, h)
        end

        local classCount = 0
        for k2, v2 in ipairs(lia.class.list) do
            if v2.faction == k then
                local classRow = panel:Add("DPanel")
                classRow:Dock(TOP)
                classRow:DockMargin(16, 0, 0, 6)
                classRow:SetTall(28)
                classRow:SetPaintBackground(false)
                local classCheckbox = classRow:Add("liaCheckbox")
                classCheckbox:Dock(LEFT)
                classCheckbox:SetWide(44)
                classCheckbox:DockMargin(0, 0, 6, 0)
                classCheckbox.classID = k2
                classCheckbox.factionID = factionCheckbox.factionID
                classCheckbox.OnChange = onClassStateChanged
                self.classes[k2] = classCheckbox
                local classLabel = classRow:Add("DLabel")
                classLabel:Dock(FILL)
                classLabel:SetText(L(v2.name))
                classLabel:SetTextColor(lia.color.theme.text and ColorAlpha(lia.color.theme.text, 220) or Color(220, 220, 220))
                classLabel:SetFont("LiliaFont.16")
                classLabel:SetContentAlignment(4)
                classLabel:SetCursor("hand")
                classLabel.DoClick = function() classCheckbox:Toggle() end
                classCount = classCount + 1
            end
        end

        local baseHeight = 69 + (classCount * 34)
        panel:SetTall(math.max(baseHeight, 100))
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
        local slider = self.scroll:Add("liaSlider")
        slider:Dock(TOP)
        slider:DockMargin(0, 0, 0, 4)
        slider:SetText(entity:GetBodygroupName(i))
        slider:SetRange(0, entity:GetBodygroupCount(i) - 1, 0)
        slider:SetValue(entity:GetBodygroup(i))
        slider.OnValueChanged = function(_, val)
            val = math.Round(val)
            local timerName = "liaVendorBodygroupEditor" .. i
            timer.Create(timerName, 0.3, 1, function() if IsValid(slider) then lia.vendor.editor.bodygroup(i, val) end end)
        end

        self.sliders[i] = slider
    end

    hook.Add("VendorEdited", self, self.onVendorEdited)
end

function PANEL:onVendorEdited(_, key)
    if key == "preset" then
        self:refreshPresetButton()
    elseif key ~= "bodygroup" and key ~= "skin" then
        return
    end

    local entity = liaVendorEnt
    for id, s in pairs(self.sliders) do
        s:SetValue(entity:GetBodygroup(id))
    end
end

function PANEL:OnRemove()
    hook.Remove("VendorEdited", self)
    if IsValid(self.presetSelector) then self.presetSelector:Remove() end
end

vgui.Register("liaVendorBodygroupEditor", PANEL, "liaFrame")
