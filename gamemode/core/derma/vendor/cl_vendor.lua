lia.config.add("VendorNameColor", "Vendor Name Color", {
    r = 255,
    g = 120,
    b = 30
}, nil, {
    desc = "Color for vendor and player header text",
    category = "Visuals",
    type = "Color"
})

surface.CreateFont("liaVendorHeader", {
    font = "Roboto",
    size = 42,
    weight = 500
})

surface.CreateFont("liaVendorItem", {
    font = "Roboto",
    size = 24,
    weight = 600
})

local PANEL = {}
function PANEL:Init()
    local ply = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor.noSendExit = true
        lia.gui.vendor:Remove()
    end

    lia.gui.vendor = self
    self:SetSize(sw, sh)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, .2, 0)
    self.buttons = self:Add("DPanel")
    self.buttons:Dock(TOP)
    self.buttons:DockMargin(0, 32, 0, 0)
    self.buttons:SetTall(36)
    self.buttons:SetPaintBackground(false)
    local vpw, vph = math.max(sw * .35, 350), sh - 64
    self.vendorPanel = self:Add("VendorTrader")
    self.vendorPanel:SetSize(vpw, vph)
    self.vendorPanel:SetPos(sw * .25 - vpw * .5, 64)
    self.mePanel = self:Add("VendorTrader")
    self.mePanel:SetSize(vpw, vph)
    self.mePanel:SetPos(sw * .75 - vpw * .5, 64)
    self:listenForChanges()
    self:liaListenForInventoryChanges(ply:getChar():getInv())
    self.items = {
        vendor = {},
        me = {}
    }

    local vendName = liaVendorEnt:getNetVar("name", "Vendor")
    local vendMoney = liaVendorEnt:getMoney() and lia.currency.get(liaVendorEnt:getMoney()) or "∞"
    self.vendorHeader = self:Add("DLabel")
    self.vendorHeader:SetFont("liaVendorHeader")
    self.vendorHeader:SetText(vendName .. " (" .. vendMoney .. ")")
    local cfg = lia.config.get("VendorNameColor")
    self.vendorHeader:SetTextColor(Color(cfg.r, cfg.g, cfg.b))
    self.vendorHeader:SetContentAlignment(5)
    self.vendorHeader:SizeToContents()
    self.vendorHeader:SetPos(self.vendorPanel.x + (self.vendorPanel:GetWide() - self.vendorHeader:GetWide()) * .5, self.vendorPanel.y - self.vendorHeader:GetTall() - 8)
    local myCash = ply:getChar():getMoney()
    self.meHeader = self:Add("DLabel")
    self.meHeader:SetFont("liaVendorHeader")
    self.meHeader:SetText("You (" .. lia.currency.get(myCash) .. ")")
    self.meHeader:SetTextColor(Color(cfg.r, cfg.g, cfg.b))
    self.meHeader:SetContentAlignment(5)
    self.meHeader:SizeToContents()
    self.meHeader:SetPos(self.mePanel.x + (self.mePanel:GetWide() - self.meHeader:GetWide()) * .5, self.mePanel.y - self.meHeader:GetTall() - 8)
    self:populateItems()
    self:createCategoryDropdown()
end

function PANEL:createCategoryDropdown()
    local cats = self:GetItemCategoryList()
    if table.Count(cats) < 1 then return end
    local sw, sh = ScrW(), ScrH()
    local vpw = self.vendorPanel:GetWide()
    local gap = sw * .5 - vpw
    local dw = math.min(sw * .2, gap * .9)
    local dh = sh * .04
    local dx = sw * .5 - dw * .5
    local dy = self.vendorPanel.y - dh - 8
    self.categoryDropdown = self:Add("liaSmallButton")
    self.categoryDropdown:SetSize(dw, dh)
    self.categoryDropdown:SetPos(dx, dy)
    self.categoryDropdown:SetText(L("vendorShowAll"))
    local sorted = {}
    for cat in pairs(cats) do
        sorted[#sorted + 1] = cat
    end

    table.sort(sorted, function(a, b) return a:lower() < b:lower() end)
    local menu
    self.categoryDropdown.DoClick = function()
        if IsValid(menu) then
            menu:Remove()
            menu = nil
            return
        end

        menu = vgui.Create("DScrollPanel", self)
        menu:SetSize(self.categoryDropdown:GetWide(), #sorted * 24)
        menu:SetPos(self.categoryDropdown.x, self.categoryDropdown.y + self.categoryDropdown:GetTall() + 2)
        for i, cat in ipairs(sorted) do
            local cap = cat:gsub("^%l", string.upper)
            local btn = menu:Add("liaSmallButton")
            btn:SetSize(menu:GetWide(), 22)
            btn:SetPos(0, (i - 1) * 24)
            btn:SetText(cap)
            btn.DoClick = function()
                local all = L("vendorShowAll")
                if cat == all then
                    self.currentCategory = nil
                    self.categoryDropdown:SetText(all)
                else
                    self.currentCategory = cat
                    self.categoryDropdown:SetText(cap)
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

function PANEL:buyItemFromVendor(uid)
    net.Start("VendorTrade")
    net.WriteString(uid)
    net.WriteBool(false)
    net.SendToServer()
end

function PANEL:sellItemToVendor(uid)
    net.Start("VendorTrade")
    net.WriteString(uid)
    net.WriteBool(true)
    net.SendToServer()
end

function PANEL:populateItems()
    if not IsValid(liaVendorEnt) then return end
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    for uid in SortedPairs(data) do
        local item = lia.item.list[uid]
        if item then
            local mode = liaVendorEnt:getTradeMode(uid)
            if mode then
                if mode ~= VENDOR_BUYONLY then self:updateItem(uid, "vendor") end
                if mode ~= VENDOR_SELLONLY then
                    local pnl = self:updateItem(uid, "me")
                    if pnl then pnl:setIsSelling(true) end
                end
            end
        end
    end
end

function PANEL:shouldShow(uid, which)
    if not IsValid(liaVendorEnt) then return false end
    local mode = liaVendorEnt:getTradeMode(uid)
    if not mode then return false end
    if which == "me" and mode == VENDOR_SELLONLY then return false end
    if which == "vendor" and mode == VENDOR_BUYONLY then return false end
    return true
end

function PANEL:updateItem(uid, which, qty)
    local c = self.items[which]
    if not c or not self:shouldShow(uid, which) then
        if c and IsValid(c[uid]) then c[uid]:Remove() end
        return
    end

    local parent = which == "me" and self.mePanel or self.vendorPanel
    if not IsValid(parent.items) then
        parent.items = vgui.Create("DPanel", parent)
        parent.items:Dock(FILL)
        parent.items:SetPaintBackground(false)
    end

    local pnl = c[uid]
    if not IsValid(pnl) then
        pnl = vgui.Create("VendorItem", parent.items)
        pnl:setItemType(uid)
        pnl:setIsSelling(which == "me")
        c[uid] = pnl
    end

    if not isnumber(qty) then qty = which == "me" and LocalPlayer():getChar():getInv():getItemCount(uid) or liaVendorEnt:getStock(uid) end
    pnl:setQuantity(qty)
    return pnl
end

function PANEL:GetItemCategoryList()
    if not IsValid(liaVendorEnt) then return {} end
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    local out = {
        [L("vendorShowAll")] = true
    }

    for uid in pairs(data) do
        local item = lia.item.list[uid]
        if item then
            local cat = item.category or "Misc"
            out[cat:sub(1, 1):upper() .. cat:sub(2)] = true
        end
    end
    return out
end

function PANEL:applyCategoryFilter()
    for _, v in pairs(self.items.vendor) do
        if IsValid(v) then v:Remove() end
    end

    for _, v in pairs(self.items.me) do
        if IsValid(v) then v:Remove() end
    end

    self.items = {
        vendor = {},
        me = {}
    }

    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    local all = not self.currentCategory or self.currentCategory == L("vendorShowAll")
    for uid in SortedPairs(data) do
        local item = lia.item.list[uid]
        if all or item and (item.category or "Misc"):sub(1, 1):upper() .. (item.category or "Misc"):sub(2) == self.currentCategory then
            local mode = liaVendorEnt:getTradeMode(uid)
            if mode and mode ~= VENDOR_BUYONLY then self:updateItem(uid, "vendor") end
            if mode and mode ~= VENDOR_SELLONLY then
                local pnl = self:updateItem(uid, "me")
                if pnl then pnl:setIsSelling(true) end
            end
        end
    end

    self.vendorPanel.items:InvalidateLayout()
    self.mePanel.items:InvalidateLayout()
end

function PANEL:onVendorPropEdited(_, key)
    if not IsValid(liaVendorEnt) then return end
    if key == "model" then
        local m = liaVendorEnt:GetModel() or ""
        self.vendorModel:SetModel(util.IsValidModel(m) and m or "")
    elseif key == "scale" then
        for _, v in pairs(self.items.vendor) do
            if IsValid(v) then v:updateLabel() end
        end

        for _, v in pairs(self.items.me) do
            if IsValid(v) then v:updateLabel() end
        end
    end

    self:applyCategoryFilter()
end

function PANEL:onVendorPriceUpdated(_, uid)
    if not IsValid(liaVendorEnt) then return end
    local v, m = self.items.vendor[uid], self.items.me[uid]
    if IsValid(v) then v:updateLabel() end
    if IsValid(m) then m:updateLabel() end
    self:applyCategoryFilter()
end

function PANEL:onVendorModeUpdated(_, uid)
    if not IsValid(liaVendorEnt) then return end
    self:updateItem(uid, "vendor")
    self:updateItem(uid, "me")
    self:applyCategoryFilter()
end

function PANEL:onItemStockUpdated(_, uid)
    if not IsValid(liaVendorEnt) then return end
    self:updateItem(uid, "vendor")
    self:applyCategoryFilter()
end

function PANEL:listenForChanges()
    hook.Add("VendorItemPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onVendorModeUpdated)
    hook.Add("VendorEdited", self, self.onVendorPropEdited)
end

function PANEL:InventoryItemAdded(item)
    if not item or not item.uniqueID then return end
    self:updateItem(item.uniqueID, "me")
end

function PANEL:InventoryItemRemoved(item)
    if not item or not item.uniqueID then return end
    self:updateItem(item.uniqueID, "me")
end

function PANEL:Paint()
    lia.util.drawBlur(self, 15)
end

function PANEL:OnRemove()
    if not self.noSendExit then
        net.Start("VendorExit")
        net.SendToServer()
        self.noSendExit = true
    end

    if IsValid(lia.gui.vendorEditor) then lia.gui.vendorEditor:Remove() end
    if IsValid(lia.gui.vendorFactionEditor) then lia.gui.vendorFactionEditor:Remove() end
    self:liaDeleteInventoryHooks()
end

function PANEL:OnKeyCodePressed()
    if input.LookupBinding("+use", true) then self:Remove() end
end

vgui.Register("Vendor", PANEL, "EditablePanel")
local PANEL = {}
function PANEL:Init()
    self.items = self:Add("DScrollPanel")
    self.items:Dock(FILL)
    self.items:SetPaintBackground(false)
end

vgui.Register("VendorTrader", PANEL, "DPanel")
local clickSound = {"buttons/button15.wav", 30, 250}
local PANEL = {}
function PANEL:Init()
    self:SetTall(80)
    self:Dock(TOP)
    self:SetPaintBackground(false)
    self:SetCursor("hand")
    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background:DockMargin(0, 0, 0, 8)
    self.iconFrame = self.background:Add("DPanel")
    self.iconFrame:SetWide(80)
    self.iconFrame:Dock(LEFT)
    self.iconFrame:DockMargin(16, 8, 16, 8)
    self.icon = self.iconFrame:Add("liaSpawnIcon")
    self.icon:SetSize(80, 80)
    self.icon:Dock(FILL)
    self.icon.Paint = function() end
    self.nameLabel = self.background:Add("DLabel")
    self.nameLabel:SetFont("liaVendorItem")
    self.nameLabel:Dock(FILL)
    self.nameLabel:SetContentAlignment(4)
    self.nameLabel:SetExpensiveShadow(1, color_black)
    self.action = self.background:Add("liaSmallButton")
    self.action:SetWide(160)
    self.action:Dock(RIGHT)
    self.action:DockMargin(0, 12, 12, 12)
    self.action:SetFont("liaVendorItem")
    self.action:SetTextColor(color_white)
    self.isSelling = false
    self.prefix = ""
end

local function clickEffects()
    LocalPlayer():EmitSound(unpack(clickSound))
end

function PANEL:sellItemToVendor()
    if not self.item then return end
    lia.gui.vendor:sellItemToVendor(self.item.uniqueID)
    clickEffects()
end

function PANEL:buyItemFromVendor()
    if not self.item then return end
    lia.gui.vendor:buyItemFromVendor(self.item.uniqueID)
    clickEffects()
end

function PANEL:setQuantity(q)
    if not self.item then return end
    if q and q <= 0 then
        self:Remove()
        return
    end

    self.prefix = q and q .. "x " or ""
    self:updateLabel()
end

function PANEL:setItemType(uid)
    local item = lia.item.list[uid]
    assert(item)
    self.item = item
    self.icon:SetModel(item.model, item.skin or 0)
    self:updateLabel()
    self:updateAction()
end

function PANEL:setIsSelling(b)
    self.isSelling = b
    self:updateLabel()
    self:updateAction()
end

function PANEL:updateLabel()
    if not self.item then return end
    self.nameLabel:SetText(self.prefix .. string.upper(self.item:getName()))
    self:updateAction()
end

function PANEL:updateAction()
    if not self.action or not self.item then return end
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local suffix = price == 0 and L("vendorFree") or price > 1 and price .. " " .. lia.currency.plural or price .. " " .. lia.currency.singular
    local text = self.isSelling and L("vendorSellAction", suffix) or L("vendorBuyAction", suffix)
    self.action:SetText(text)
    self.action.DoClick = function()
        if self.isSelling then
            self:sellItemToVendor()
        else
            self:buyItemFromVendor()
        end
    end
end

vgui.Register("VendorItem", PANEL, "DPanel")