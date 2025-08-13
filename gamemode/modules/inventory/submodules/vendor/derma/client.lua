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
    self.buttons = self:Add("DPanel")
    self.buttons:DockMargin(0, 32, 0, 0)
    self.buttons:Dock(TOP)
    self.buttons:SetTall(36)
    self.buttons:SetPaintBackground(false)
    local y0 = 64 + 44
    local panelW = math.max(sw * 0.25, 220)
    local panelH = sh - y0
    self.vendorPanel = self:Add("DPanel")
    self.vendorPanel:SetSize(panelW, panelH)
    self.vendorPanel:SetPos(sw * 0.5 - panelW - 32, y0)
    self.vendorPanel.items = self.vendorPanel:Add("DScrollPanel")
    self.vendorPanel.items:Dock(FILL)
    self.mePanel = self:Add("DPanel")
    self.mePanel:SetSize(panelW, panelH)
    self.mePanel:SetPos(sw * 0.5 + 32, y0)
    self.mePanel.items = self.mePanel:Add("DScrollPanel")
    self.mePanel.items:Dock(FILL)
    self:listenForChanges()
    self:liaListenForInventoryChanges(ply:getChar():getInv())
    self.items = {
        vendor = {},
        me = {}
    }

    self.currentCategory = nil
    local lbl = self:Add("DLabel")
    lbl:SetText(L("vendorYourItems"))
    lbl:SetFont("liaBigFont")
    lbl:SetTextColor(color_white)
    lbl:SetContentAlignment(5)
    lbl:SizeToContents()
    lbl:SetPos(self.mePanel.x + panelW * 0.5 - lbl:GetWide() * 0.5, y0 - lbl:GetTall() - 10)
    local lbl2 = self:Add("DLabel")
    lbl2:SetText(L("vendorItemsTitle"))
    lbl2:SetFont("liaBigFont")
    lbl2:SetTextColor(color_white)
    lbl2:SetContentAlignment(5)
    lbl2:SizeToContents()
    lbl2:SetPos(self.vendorPanel.x + panelW * 0.5 - lbl2:GetWide() * 0.5, y0 - lbl2:GetTall() - 10)
    self:populateItems()
    self:createCategoryDropdown()
    self.left = self:Add("DFrame")
    self.left:SetPos(sw * 0.015, sh * 0.35)
    self.left:SetSize(sw * 0.212, sh * 0.24)
    self.left:SetTitle("")
    self.left:ShowCloseButton(false)
    self.left:SetDraggable(false)
    self.left.Paint = function()
        if not IsValid(liaVendorEnt) then return end
        local scale = liaVendorEnt:getNetVar("scale", 0.5)
        local money = liaVendorEnt:getMoney() and lia.currency.get(liaVendorEnt:getMoney()) or "∞"
        local count = table.Count(self.items.vendor)
        surface.SetDrawColor(30, 30, 30, 190)
        surface.DrawRect(0, 0, sw, ScreenScaleH(215))
        surface.DrawOutlinedRect(0, 0, sw, ScreenScaleH(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, sw * 0.26, sh * 0.033)
        surface.DrawOutlinedRect(0, 0, sw * 0.26, sh * 0.033)
        draw.DrawText(liaVendorEnt:getNetVar("name") or L("vendorDefaultName"), "liaMediumFont", sw * 0.005, sh * 0.003, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(L("money"), "liaSmallFont", sw * 0.1, sh * 0.05, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(money, "liaSmallFont", sw * 0.2, sh * 0.05, color_white, TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorSellScale"), "liaSmallFont", sw * 0.1, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(math.ceil(scale * 100) .. "%", "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.1, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(count == 0 and L("vendorNoItems") or count == 1 and L("vendorOneItem") or L("vendorItems", count), "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
    end

    self.right = self:Add("DFrame")
    self.right:SetPos(sw * 0.78, sh * 0.35)
    self.right:SetSize(sw * 0.212, sh * 0.61)
    self.right:SetTitle("")
    self.right:ShowCloseButton(false)
    self.right:SetDraggable(false)
    self.right.Paint = function()
        surface.SetDrawColor(30, 30, 30, 190)
        surface.DrawRect(0, 0, sw, ScreenScaleH(215))
        surface.DrawOutlinedRect(0, 0, sw, ScreenScaleH(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, sw * 0.26, sh * 0.033)
        surface.DrawOutlinedRect(0, 0, sw * 0.26, sh * 0.033)
        local char = ply:getChar()
        if not char then return end
        draw.DrawText(char:getName(), "liaMediumFont", sw * 0.005, sh * 0.003, color_white, TEXT_ALIGN_LEFT)
        local faction = team.GetName(ply:Team())
        if #faction > 25 then faction = faction:sub(1, 25) .. "..." end
        draw.DrawText(L("faction"), "liaSmallFont", sw * 0.085, sh * 0.05, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(faction, "liaSmallFont", sw * 0.201, sh * 0.05, color_white, TEXT_ALIGN_RIGHT)
        local class = char:getClass()
        local invCount = char:getInv():getItemCount()
        if lia.class.list[class] then
            draw.DrawText(L("class"), "liaSmallFont", sw * 0.085, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.class.list[class].name, "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("money"), "liaSmallFont", sw * 0.085, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(char:getMoney()), "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.085, sh * 0.11, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(invCount == 0 and L("vendorNoItems") or invCount == 1 and L("vendorOneItem") or L("vendorItems", invCount), "liaSmallFont", sw * 0.2, sh * 0.11, color_white, TEXT_ALIGN_RIGHT)
        else
            draw.DrawText(L("money"), "liaSmallFont", sw * 0.085, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(char:getMoney()), "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.085, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(invCount == 0 and L("vendorNoItems") or invCount == 1 and L("vendorOneItem") or L("vendorItems", invCount), "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
        end
    end

    local bw, bh = sw * 0.15, sh * 0.05
    if ply:CanEditVendor(self.vendorPanel) then
        local by = self.right:GetY() + self.right:GetTall() - bh - sw * 0.02
        local btn = self:Add("liaSmallButton")
        btn:SetSize(bw, bh)
        btn:SetPos(self.left:GetWide() - bw - sw * 0.02, by)
        btn:SetText(L("vendorEditorButton"))
        btn:SetFont("liaMediumFont")
        btn:SetTextColor(color_white)
        btn.DoClick = function() vgui.Create("VendorEditor"):SetZPos(99) end
    end

    local leave = self.right:Add("liaSmallButton")
    leave:SetSize(bw, bh)
    leave:SetPos(self.right:GetWide() - bw - sw * 0.02, self.right:GetTall() - bh - sw * 0.02)
    leave:SetText(L("leave"))
    leave:SetFont("liaMediumFont")
    leave:SetTextColor(color_white)
    leave.DoClick = function() self:Remove() end
    self:DrawModels()
end

function PANEL:createCategoryDropdown()
    local c = self:GetItemCategoryList()
    if table.Count(c) < 1 then return end
    local btn = self:Add("liaSmallButton")
    btn:SetSize(sw * 0.15, sh * 0.035)
    btn:SetPos(sw * 0.82, 110)
    btn:SetText(L("vendorShowAll"))
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

        menu = vgui.Create("DScrollPanel", self)
        menu:SetSize(btn:GetWide(), #sorted * 24)
        menu:SetPos(btn.x, btn.y + btn:GetTall() + 2)
        for i, cat in ipairs(sorted) do
            local text = cat:gsub("^%l", string.upper)
            local item = menu:Add("liaSmallButton")
            item:SetSize(menu:GetWide(), 22)
            item:SetPos(0, (i - 1) * 24)
            item:SetText(text)
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

function PANEL:updateVendorModel()
    if not (IsValid(self.vendorModel) and IsValid(liaVendorEnt)) then return end
    local ent = self.vendorModel.Entity
    if not IsValid(ent) then return end
    ent:SetSkin(liaVendorEnt:GetSkin())
    for i = 0, liaVendorEnt:GetNumBodyGroups() - 1 do
        ent:SetBodygroup(i, liaVendorEnt:GetBodygroup(i))
    end
end

function PANEL:DrawModels()
    self.vendorModel = self:Add("DModelPanel")
    self.vendorModel:SetSize(ScreenScale(160), ScreenScaleH(170))
    self.vendorModel:SetPos(self:GetWide() * 0.25 - ScreenScale(350) - ScreenScale(100), sh * 0.36 + ScreenScaleH(25))
    local model = liaVendorEnt and liaVendorEnt.GetModel and liaVendorEnt:GetModel() or ""
    if util.IsValidModel(model) then
        self.vendorModel:SetModel(model)
        self:updateVendorModel()
    else
        self.vendorModel:SetModel("")
    end

    self.vendorModel:SetFOV(20)
    self.vendorModel:SetAlpha(0)
    self.vendorModel:AlphaTo(255, 0.2)
    self.vendorModel.LayoutEntity = function(_, ent)
        local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
        if bone and bone >= 0 then
            ent:SetAngles(Angle(0, 45, 0))
            self.vendorModel:SetLookAt(ent:GetBonePosition(bone))
        end
    end

    self.playerModel = self:Add("DModelPanel")
    self.playerModel:SetSize(ScreenScale(160), ScreenScaleH(170))
    self.playerModel:SetPos(self:GetWide() * 0.75 + ScreenScale(110) - ScreenScale(50), sh * 0.36 + ScreenScaleH(25))
    local pm = LocalPlayer():GetModel()
    if util.IsValidModel(pm) then
        self.playerModel:SetModel(pm)
    else
        self.playerModel:SetModel("")
    end

    self.playerModel:SetFOV(20)
    self.playerModel:SetAlpha(0)
    self.playerModel:AlphaTo(255, 0.2)
    self.playerModel.LayoutEntity = function(_, ent)
        local bone = ent:LookupBone("ValveBiped.Bip01_Head1")
        if bone and bone >= 0 then
            ent:SetAngles(Angle(0, 45, 0))
            self.playerModel:SetLookAt(ent:GetBonePosition(bone))
        end
    end
end

function PANEL:buyItemFromVendor(id)
    net.Start("VendorTrade")
    net.WriteString(id)
    net.WriteBool(false)
    net.SendToServer()
end

function PANEL:sellItemToVendor(id)
    net.Start("VendorTrade")
    net.WriteString(id)
    net.WriteBool(true)
    net.SendToServer()
end

function PANEL:populateItems()
    if not IsValid(liaVendorEnt) then return end
    local data = liaVendorEnt.items
    if not istable(data) then data = liaVendorEnt:getNetVar("items", {}) end
    for id in SortedPairs(data) do
        local item = lia.item.list[id]
        local mode = liaVendorEnt:getTradeMode(id)
        if item and mode then
            if mode ~= VENDOR_BUYONLY then self:updateItem(id, "vendor") end
            if mode ~= VENDOR_SELLONLY then
                local pnl = self:updateItem(id, "me")
                if pnl then pnl:setIsSelling(true) end
            end
        end
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
    if not IsValid(parent.items) then
        parent.items = vgui.Create("DPanel", parent)
        parent.items:Dock(FILL)
        parent.items:SetPaintBackground(false)
    end

    local pnl = container[id]
    if not IsValid(pnl) then
        pnl = vgui.Create("VendorItem", parent.items)
        pnl:setItemType(id)
        pnl:setIsSelling(which == "me")
        container[id] = pnl
    end

    if not isnumber(qty) then qty = which == "me" and LocalPlayer():getChar():getInv():getItemCount(id) or liaVendorEnt:getStock(id) end
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

    if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout() end
    if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout() end
end

function PANEL:listenForChanges()
    hook.Add("VendorItemPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onVendorModeUpdated)
    hook.Add("VendorEdited", self, self.onVendorPropEdited)
end

function PANEL:InventoryItemAdded(it)
    if it and it.uniqueID then self:updateItem(it.uniqueID, "me") end
end

function PANEL:InventoryItemRemoved(it)
    if it and it.uniqueID then self:InventoryItemAdded(it) end
end

function PANEL:onVendorPropEdited(_, key)
    if not IsValid(liaVendorEnt) then return end
    if key == "model" then
        local m = liaVendorEnt:GetModel() or ""
        if util.IsValidModel(m) then
            self.vendorModel:SetModel(m)
            self:updateVendorModel()
        else
            self.vendorModel:SetModel("")
        end
    elseif key == "scale" then
        for _, v in pairs(self.items.vendor) do
            if IsValid(v) then v:updateLabel() end
        end

        for _, v in pairs(self.items.me) do
            if IsValid(v) then v:updateLabel() end
        end
    elseif key == "preset" then
        local preset = liaVendorEnt:getNetVar("preset", "none")
        if IsValid(self.preset) then self.preset:SetValue(preset == "none" and L("none") or preset) end
    elseif key == "skin" then
        if IsValid(self.skin) then self.skin:SetValue(liaVendorEnt:GetSkin()) end
        self:updateVendorModel()
    elseif key == "bodygroup" then
        if IsValid(lia.gui.vendorBodygroupEditor) then lia.gui.vendorBodygroupEditor:onVendorEdited(nil, key) end
        self:updateVendorModel()
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
PANEL = {}
function PANEL:Init()
    self:SetSize(600, 200)
    self:Dock(TOP)
    self:SetPaintBackground(false)
    self:SetCursor("hand")
    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background:DockMargin(0, 0, 0, 10)
    self.iconFrame = self.background:Add("DPanel")
    self.iconFrame:SetSize(96, 96)
    self.iconFrame:Dock(LEFT)
    self.iconFrame:DockMargin(10, 10, 10, 10)
    self.icon = self.iconFrame:Add("liaItemIcon")
    self.icon:SetSize(96, 96)
    self.icon:Dock(FILL)
    self.icon.Paint = function() end
    self.textContainer = self.background:Add("DPanel")
    self.textContainer:Dock(FILL)
    self.textContainer:DockMargin(0, 10, 10, 10)
    self.textContainer:SetPaintBackground(false)
    self.name = self.textContainer:Add("DLabel")
    self.name:SetFont("VendorItemNameFont")
    self.name:SetExpensiveShadow(1, color_black)
    self.name:Dock(TOP)
    self.name:DockMargin(0, 0, 0, 8)
    self.name:SetContentAlignment(5)
    self.name:SetText("")
    self.description = self.textContainer:Add("DLabel")
    self.description:SetFont("VendorItemDescFont")
    self.description:SetTextColor(Color(200, 200, 200))
    self.description:Dock(TOP)
    self.description:DockMargin(0, 12, 0, 0)
    self.description:SetWrap(true)
    self.description:SetContentAlignment(1)
    self.description:SetAutoStretchVertical(true)
    self.description:SetText("")
    self.spacer = self.textContainer:Add("DPanel")
    self.spacer:Dock(FILL)
    self.spacer:SetPaintBackground(false)
    self.action = self.textContainer:Add("liaSmallButton")
    self.action:SetHeight(40)
    self.action:Dock(BOTTOM)
    self.action:DockMargin(0, 10, 0, 0)
    self.action:SetFont("VendorItemDescFont")
    self.action:SetTextColor(color_white)
    self.isSelling = false
    self.suffix = ""
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
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local priceSuffix
    if price == 0 then
        priceSuffix = L("vendorFree")
    elseif price > 1 then
        priceSuffix = string.format("%s %s", price, lia.currency.plural)
    else
        priceSuffix = string.format("%s %s", price, lia.currency.singular)
    end

    self.action:SetText(self.isSelling and L("vendorSellAction", priceSuffix) or L("vendorBuyAction", priceSuffix))
    self.action.DoClick = function()
        if self.isSelling then
            self:sellItemToVendor()
        else
            self:buyItemFromVendor()
        end
    end
end

function PANEL:setQuantity(quantity)
    if not self.item then return end
    if quantity then
        if quantity <= 0 then
            self:Remove()
            return
        end

        self.suffix = L("vendorItemQuantity", quantity)
    else
        self.suffix = ""
    end

    self:updateLabel()
end

function PANEL:setItemType(itemType)
    local item = lia.item.list[itemType]
    assert(item, L("invalidItemTypeOrID", tostring(itemType)))
    self.item = item
    self.icon:SetModel(item.model, item.skin or 0)
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
    local nameText = (self.suffix ~= "" and self.suffix or "") .. self.item:getName()
    self.name:SetText(nameText)
    self.description:SetText(self.item:getDesc() or L("noDesc"))
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local priceSuffix
    if price == 0 then
        priceSuffix = L("vendorFree")
    elseif price > 1 then
        priceSuffix = string.format("%s %s", price, lia.currency.plural)
    else
        priceSuffix = string.format("%s %s", price, lia.currency.singular)
    end

    self.action:SetText(self.isSelling and L("vendorSellAction", priceSuffix) or L("vendorBuyAction", priceSuffix))
end

vgui.Register("VendorItem", PANEL, "DPanel")
PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.vendorEditor) then lia.gui.vendorEditor:Remove() end
    lia.gui.vendorEditor = self
    local entity = liaVendorEnt
    local width = math.min(ScrW() * 0.75, 480)
    local height = math.min(ScrH() * 0.75, 640)
    self:SetSize(width, height)
    self:MakePopup()
    self:Center()
    self:SetTitle(L("vendorEditor"))
    self.name = self:Add("DTextEntry")
    self.name:Dock(TOP)
    self.name:SetTooltip(L("name"))
    self.name:SetText(entity:getName())
    self.name.OnEnter = function(this) if entity:getNetVar("name") ~= this:GetText() then lia.vendor.editor.name(this:GetText()) end end
    self.model = self:Add("DTextEntry")
    self.model:Dock(TOP)
    self.model:SetTooltip(L("model"))
    self.model:DockMargin(0, 4, 0, 0)
    self.model:SetText(entity:GetModel())
    self.model.OnEnter = function(this)
        local modelText = this:GetText():lower()
        if entity:GetModel():lower() ~= modelText then lia.vendor.editor.model(modelText) end
    end

    if entity:SkinCount() > 1 then
        self.skin = self:Add("DNumSlider")
        self.skin:Dock(TOP)
        self.skin:DockMargin(0, 4, 0, 0)
        self.skin:SetText(L("skin"))
        self.skin.Label:SetTextColor(color_white)
        self.skin:SetDecimals(0)
        self.skin:SetMinMax(0, entity:SkinCount() - 1)
        self.skin:SetValue(entity:GetSkin())
        self.skin.OnValueChanged = function(_, value)
            value = math.Round(value)
            if entity:GetSkin() ~= value then lia.vendor.editor.skin(value) end
        end
    end

    local hasBodygroups = false
    for i = 0, entity:GetNumBodyGroups() - 1 do
        if entity:GetBodygroupCount(i) > 1 then
            hasBodygroups = true
            break
        end
    end

    if hasBodygroups or entity:SkinCount() > 1 then
        self.bodygroups = self:Add("DButton")
        self.bodygroups:Dock(TOP)
        self.bodygroups:DockMargin(0, 4, 0, 0)
        self.bodygroups:SetText(L("bodygroups"))
        self.bodygroups:SetTextColor(color_white)
        self.bodygroups.DoClick = function() vgui.Create("VendorBodygroupEditor", self):MoveLeftOf(self, 4) end
    end

    self.flag = self:Add("DTextEntry")
    self.flag:Dock(TOP)
    self.flag:DockMargin(0, 4, 0, 0)
    self.flag:SetText(entity:getNetVar("flag") or L("flag"))
    self.flag.OnEnter = function(this)
        local value = this:GetText()
        if value:match("^%a$") then
            lia.vendor.editor.flag(value)
        else
            local correctedValue = value:sub(1, 1):match("^%a$") and value:sub(1, 1) or "F"
            this:SetText(correctedValue)
            lia.vendor.editor.flag(correctedValue)
        end
    end

    self.welcome = self:Add("DTextEntry")
    self.welcome:Dock(TOP)
    self.welcome:DockMargin(0, 4, 0, 0)
    self.welcome:SetText(entity:getWelcomeMessage())
    self.welcome:SetTooltip(L("vendorEditorWelcomeMessage"))
    self.welcome.OnEnter = function(this)
        local msg = this:GetText()
        if msg ~= entity:getWelcomeMessage() then lia.vendor.editor.welcome(msg) end
    end

    self.money = self:Add("DTextEntry")
    self.money:Dock(TOP)
    self.money:SetTooltip(lia.currency.plural)
    self.money:DockMargin(0, 4, 0, 0)
    self.money:SetNumeric(true)
    self.money.OnEnter = function(this)
        local value = tonumber(this:GetText()) or entity:getMoney()
        value = math.Round(value)
        value = math.max(value, 0)
        if value ~= entity:getMoney() then lia.vendor.editor.money(value) end
    end

    self.useMoney = self:Add("DCheckBoxLabel")
    self.useMoney:SetText(L("vendorUseMoney"))
    self.useMoney:Dock(TOP)
    self.useMoney:SetTextColor(Color(255, 255, 255))
    self.useMoney:DockMargin(0, 4, 0, 0)
    self.useMoney.OnChange = function(_, value) lia.vendor.editor.useMoney(value) end
    self.sellScale = self:Add("DNumSlider")
    self.sellScale:Dock(TOP)
    self.sellScale:DockMargin(0, 4, 0, 0)
    self.sellScale:SetText(L("vendorSellScale"))
    self.sellScale.Label:SetTextColor(color_white)
    self.sellScale.TextArea:SetTextColor(color_white)
    self.sellScale:SetDecimals(2)
    self.sellScale.OnValueChanged = function(_, value)
        timer.Create("VendorScale", 0.5, 1, function()
            if IsValid(self) and IsValid(self.sellScale) then
                value = self.sellScale:GetValue()
                local diff = math.abs(value - entity:getSellScale())
                if diff > 0.05 then lia.vendor.editor.scale(value) end
            end
        end)
    end

    self.faction = self:Add("DButton")
    self.faction:SetText(L("vendorFaction"))
    self.faction:Dock(TOP)
    self.faction:SetTextColor(color_white)
    self.faction:DockMargin(0, 4, 0, 0)
    self.faction.DoClick = function() vgui.Create("VendorFactionEditor", self):MoveLeftOf(self, 4) end
    self.preset = self:Add("DComboBox")
    self.preset:Dock(TOP)
    self.preset:SetSortItems(false)
    self.preset:DockMargin(0, 4, 0, 0)
    self.preset:AddChoice(L("none"))
    for name in pairs(lia.vendor.presets or {}) do
        self.preset:AddChoice(name)
    end

    local currentPreset = entity:getNetVar("preset", "none")
    self.preset:SetValue(currentPreset == "none" and L("none") or currentPreset)
    self.preset:ChooseOption(currentPreset == "none" and L("none") or currentPreset)
    self.preset.OnSelect = function(_, _, value)
        if value == L("none") then value = "none" end
        lia.vendor.editor.preset(value)
    end

    self.items = self:Add("DListView")
    self.items:Dock(FILL)
    self.items:DockMargin(0, 4, 0, 0)
    self.items:AddColumn(L("name")).Header:SetTextColor(color_white)
    self.items:AddColumn(L("mode")).Header:SetTextColor(color_white)
    self.items:AddColumn(L("price")).Header:SetTextColor(color_white)
    self.items:AddColumn(L("stock")).Header:SetTextColor(color_white)
    self.items:AddColumn(L("category")).Header:SetTextColor(color_white)
    self.items:SetMultiSelect(false)
    self.items.OnRowRightClick = function(_, _, line) self:OnRowRightClick(line) end
    self.searchBar = self:Add("DTextEntry")
    self.searchBar:Dock(TOP)
    self.searchBar:DockMargin(0, 4, 0, 0)
    self.searchBar:SetUpdateOnType(true)
    self.searchBar:SetPlaceholderText(L("search"))
    self.searchBar.OnValueChange = function(_, value) self:ReloadItemList(value) end
    self.lines = {}
    self:ReloadItemList()
    self:listenForUpdates()
    self:updateMoney()
    self:updateSellScale()
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
end

function PANEL:updateVendor(key, value)
    net.Start("VendorEdit")
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

function PANEL:updateMoney()
    local money = liaVendorEnt:getMoney()
    local useMoney = isnumber(money)
    if money then
        self.money:SetText(money)
    else
        self.money:SetText("∞")
    end

    self.money:SetDisabled(not useMoney)
    self.money:SetEnabled(useMoney)
    self.useMoney:SetChecked(useMoney)
end

function PANEL:updateSellScale()
    self.sellScale:SetValue(liaVendorEnt:getSellScale())
end

function PANEL:onNameDescChanged(key)
    local entity = liaVendorEnt
    if key == "name" then
        self.name:SetText(entity:getName())
    elseif key == "model" then
        self.model:SetText(entity:GetModel())
    elseif key == "scale" then
        self:updateSellScale()
    elseif key == "welcome" and entity.getWelcomeMessage then
        self.welcome:SetText(entity:getWelcomeMessage())
    end
end

function PANEL:onItemModeUpdated(_, itemType, value)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    line:SetColumnText(COLS_MODE, self:getModeText(value))
end

function PANEL:onItemPriceUpdated(vendor, itemType)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    line:SetColumnText(COLS_PRICE, vendor:getPrice(itemType))
end

function PANEL:onItemStockUpdated(vendor, itemType)
    local line = self.lines[itemType]
    if not IsValid(line) then return end
    local current, max = vendor:getStock(itemType)
    line:SetColumnText(COLS_STOCK, max and current .. "/" .. max or "-")
end

function PANEL:listenForUpdates()
    hook.Add("VendorEdited", self, self.onNameDescChanged)
    hook.Add("VendorMoneyUpdated", self, self.updateMoney)
    hook.Add("VendorItemModeUpdated", self, self.onItemModeUpdated)
    hook.Add("VendorItemPriceUpdated", self, self.onItemPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
end

function PANEL:OnRowRightClick(line)
    local entity = liaVendorEnt
    if entity:getNetVar("preset") ~= "none" then return end
    if IsValid(menu) then menu:Remove() end
    local uniqueID = line.item
    local itemTable = lia.item.list[uniqueID]
    menu = DermaMenu(self)
    local mode, modePanel = menu:AddSubMenu(L("mode"))
    modePanel:SetImage("icon16/key.png")
    mode:AddOption(L("none"), function() lia.vendor.editor.mode(uniqueID, nil) end):SetImage("icon16/cog_error.png")
    mode:AddOption(L("buyOnlynSell"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLANDBUY) end):SetImage("icon16/cog.png")
    mode:AddOption(L("buyOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_BUYONLY) end):SetImage("icon16/cog_delete.png")
    mode:AddOption(L("sellOnly"), function() lia.vendor.editor.mode(uniqueID, VENDOR_SELLONLY) end):SetImage("icon16/cog_add.png")
    menu:AddOption(L("price"), function()
        Derma_StringRequest(itemTable:getName(), L("vendorPriceReq"), entity:getPrice(uniqueID), function(text)
            text = tonumber(text)
            lia.vendor.editor.price(uniqueID, text)
        end):SetParent(self)
    end):SetImage("icon16/coins.png")

    local stock, stockPanel = menu:AddSubMenu(L("stock"))
    stockPanel:SetImage("icon16/table.png")
    stock:AddOption(L("disable"), function() lia.vendor.editor.stockDisable(uniqueID) end):SetImage("icon16/table_delete.png")
    stock:AddOption(L("edit"), function()
        local _, max = entity:getStock(uniqueID)
        Derma_StringRequest(itemTable:getName(), L("vendorStockReq"), max or 1, function(text)
            text = math.max(math.Round(tonumber(text) or 1), 1)
            lia.vendor.editor.stockMax(uniqueID, text)
        end):SetParent(self)
    end):SetImage("icon16/table_edit.png")

    stock:AddOption(L("vendorEditCurStock"), function()
        Derma_StringRequest(itemTable:getName(), L("vendorStockCurReq"), entity:getStock(uniqueID) or 0, function(text)
            text = math.Round(tonumber(text) or 0)
            lia.vendor.editor.stock(uniqueID, text)
        end):SetParent(self)
    end):SetImage("icon16/table_edit.png")

    menu:Open()
end

function PANEL:ReloadItemList(filter)
    local entity = liaVendorEnt
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
    end
end

vgui.Register("VendorEditor", PANEL, "DFrame")
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
    self.scroll = self:Add("DScrollPanel")
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
        faction:SetTextColor(color_white)
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
                class:SetTextColor(color_white)
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

vgui.Register("VendorFactionEditor", PANEL, "DFrame")
PANEL = {}
function PANEL:Init()
    if IsValid(lia.gui.vendorBodygroupEditor) then lia.gui.vendorBodygroupEditor:Remove() end
    lia.gui.vendorBodygroupEditor = self
    self:SetSize(256, 360)
    self:Center()
    self:MakePopup()
    self:SetTitle(L("bodygroups"))
    self.scroll = self:Add("DScrollPanel")
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
        slider.Label:SetTextColor(color_white)
        slider:SetDecimals(0)
        slider:SetMinMax(0, entity:GetBodygroupCount(i) - 1)
        slider:SetValue(entity:GetBodygroup(i))
        slider.OnValueChanged = function(_, val) lia.vendor.editor.bodygroup(i, math.Round(val)) end
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

vgui.Register("VendorBodygroupEditor", PANEL, "DFrame")