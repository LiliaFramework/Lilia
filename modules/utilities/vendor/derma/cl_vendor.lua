local PANEL = {}
function PANEL:Init()
    local p = LocalPlayer()
    local sw, sh = ScrW(), ScrH()
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
    self.vendorPanel = self:Add("VendorTrader")
    self.vendorPanel:SetSize(math.max(sw * 0.25, 220), sh - self.vendorPanel.y)
    self.vendorPanel:SetPos(sw * 0.5 - self.vendorPanel:GetWide() - 32, 64 + 44)
    self.vendorPanel:SetTall(sh - self.vendorPanel.y)
    self.mePanel = self:Add("VendorTrader")
    self.mePanel:SetSize(self.vendorPanel:GetSize())
    self.mePanel:SetPos(sw * 0.5 + 32, self.vendorPanel.y)
    self:listenForChanges()
    self:liaListenForInventoryChanges(p:getChar():getInv())
    self.items = {
        vendor = {},
        me = {}
    }

    self.currentCategory = nil
    self.meLabel = self:Add("DLabel")
    self.meLabel:SetText(L("vendorYourItems"))
    self.meLabel:SetFont("liaBigFont")
    self.meLabel:SetTextColor(color_white)
    self.meLabel:SetContentAlignment(5)
    self.meLabel:SizeToContents()
    self.meLabel:SetPos(self.mePanel.x + self.mePanel:GetWide() * 0.5 - self.meLabel:GetWide() * 0.5, self.mePanel.y - self.meLabel:GetTall() - 10)
    self.vendorLabel = self:Add("DLabel")
    self.vendorLabel:SetText(L("vendorItems"))
    self.vendorLabel:SetFont("liaBigFont")
    self.vendorLabel:SetTextColor(color_white)
    self.vendorLabel:SetContentAlignment(5)
    self.vendorLabel:SizeToContents()
    self.vendorLabel:SetPos(self.vendorPanel.x + self.vendorPanel:GetWide() * 0.5 - self.vendorLabel:GetWide() * 0.5, self.vendorPanel.y - self.vendorLabel:GetTall() - 10)
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
        local n = liaVendorEnt:getNetVar("name", "Jane Doe")
        local sc = liaVendorEnt:getNetVar("scale", 0.5)
        local m = liaVendorEnt:getMoney() ~= nil and lia.currency.get(liaVendorEnt:getMoney()) or "∞"
        local t = self.items.vendor or {}
        local c = table.Count(t)
        surface.SetDrawColor(30, 30, 30, 190)
        surface.DrawRect(0, 0, sw, SS(215))
        surface.DrawOutlinedRect(0, 0, sw, SS(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, sw * 0.26, sh * 0.033)
        surface.DrawOutlinedRect(0, 0, sw * 0.26, sh * 0.033)
        draw.DrawText(n, "liaMediumFont", sw * 0.005, sh * 0.003, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(L("vendorMoney"), "liaSmallFont", sw * 0.1, sh * 0.05, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(m, "liaSmallFont", sw * 0.2, sh * 0.05, color_white, TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorSellScale"), "liaSmallFont", sw * 0.1, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(math.ceil(sc * 100) .. "%", "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.1, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
        local txt = c == 0 and "No Items" or c == 1 and "1 Item" or c .. " Items"
        draw.DrawText(txt, "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
    end

    self.right = self:Add("DFrame")
    self.right:SetPos(sw * 0.78, sh * 0.35)
    self.right:SetSize(sw * 0.212, sh * 0.61)
    self.right:SetTitle("")
    self.right:ShowCloseButton(false)
    self.right:SetDraggable(false)
    self.right.Paint = function()
        surface.SetDrawColor(30, 30, 30, 190)
        surface.DrawRect(0, 0, sw, SS(215))
        surface.DrawOutlinedRect(0, 0, sw, SS(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, sw * 0.26, sh * 0.033)
        surface.DrawOutlinedRect(0, 0, sw * 0.26, sh * 0.033)
        local c = p:getChar()
        if not c then return end
        draw.DrawText(c:getName(), "liaMediumFont", sw * 0.005, sh * 0.003, color_white, TEXT_ALIGN_LEFT)
        local f = team.GetName(p:Team())
        if #f > 25 then f = f:sub(1, 25) .. "..." end
        draw.DrawText(L("faction"), "liaSmallFont", sw * 0.085, sh * 0.05, color_white, TEXT_ALIGN_LEFT)
        draw.DrawText(f, "liaSmallFont", sw * 0.201, sh * 0.05, color_white, TEXT_ALIGN_RIGHT)
        local cl = c:getClass()
        local invC = c:getInv():getItemCount()
        local disp = invC == 0 and "No Items" or invC == 1 and "1 Item" or invC .. " Items"
        if lia.class.list[cl] then
            draw.DrawText(L("class"), "liaSmallFont", sw * 0.085, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.class.list[cl].name, "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorMoney"), "liaSmallFont", sw * 0.085, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(c:getMoney()), "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.085, sh * 0.11, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(disp, "liaSmallFont", sw * 0.2, sh * 0.11, color_white, TEXT_ALIGN_RIGHT)
        else
            draw.DrawText(L("vendorMoney"), "liaSmallFont", sw * 0.085, sh * 0.07, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(c:getMoney()), "liaSmallFont", sw * 0.2, sh * 0.07, color_white, TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", sw * 0.085, sh * 0.09, color_white, TEXT_ALIGN_LEFT)
            draw.DrawText(disp, "liaSmallFont", sw * 0.2, sh * 0.09, color_white, TEXT_ALIGN_RIGHT)
        end
    end

    local bw, bh = sw * 0.15, sh * 0.05
    if p:CanEditVendor(self.vendorPanel) then
        local by = self.right:GetY() + self.right:GetTall() - bh - sw * 0.02
        self.editor = self:Add("liaSmallButton")
        self.editor:SetSize(bw, bh)
        self.editor:SetPos(self.left:GetWide() - bw - sw * 0.02, by)
        self.editor:SetText(L("vendorEditorButton"))
        self.editor:SetFont("liaMediumFont")
        self.editor:SetTextColor(color_white)
        self.editor.DoClick = function() vgui.Create("VendorEditor"):SetZPos(99) end
    end

    self.leaveBtn = self.right:Add("liaSmallButton")
    self.leaveBtn:SetSize(bw, bh)
    self.leaveBtn:SetPos(self.right:GetWide() - bw - sw * 0.02, self.right:GetTall() - bh - sw * 0.02)
    self.leaveBtn:SetText(L("leave"))
    self.leaveBtn:SetFont("liaMediumFont")
    self.leaveBtn:SetTextColor(color_white)
    self.leaveBtn.DoClick = function() self:Remove() end
    self:DrawModels()
end

function PANEL:createCategoryDropdown()
    local c = self:GetItemCategoryList()
    if table.Count(c) < 1 then return end
    local sw, sh = ScrW(), ScrH()
    self.categoryDropdown = self:Add("liaSmallButton")
    self.categoryDropdown:SetSize(sw * 0.15, sh * 0.035)
    self.categoryDropdown:SetPos(sw * 0.82, 110)
    self.categoryDropdown:SetText(L("vendorShowAll"))
    local sorted = {}
    for k in pairs(c) do
        table.insert(sorted, k)
    end

    table.sort(sorted, function(a, b) return a:lower() < b:lower() end)
    local menuList
    self.categoryDropdown.DoClick = function()
        if IsValid(menuList) then
            menuList:Remove()
            menuList = nil
            return
        end

        menuList = vgui.Create("DScrollPanel", self)
        menuList:SetSize(self.categoryDropdown:GetWide(), #sorted * 24)
        menuList:SetPos(self.categoryDropdown.x, self.categoryDropdown.y + self.categoryDropdown:GetTall() + 2)
        for i, cat in ipairs(sorted) do
            local capital = cat:gsub("^%l", string.upper)
            local btn = menuList:Add("liaSmallButton")
            btn:SetSize(menuList:GetWide(), 22)
            btn:SetPos(0, (i - 1) * 24)
            btn:SetText(capital)
            btn.DoClick = function()
                local vsa = L("vendorShowAll")
                if cat == vsa then
                    self.currentCategory = nil
                    self.categoryDropdown:SetText(vsa)
                else
                    self.currentCategory = cat
                    self.categoryDropdown:SetText(capital)
                end

                self:applyCategoryFilter()
                if IsValid(menuList) then
                    menuList:Remove()
                    menuList = nil
                end
            end
        end
    end
end

function PANEL:DrawModels()
    local p = LocalPlayer()
    self.vendorModel = self:Add("DModelPanel")
    self.vendorModel:SetSize(SS(160, true), SS(170))
    self.vendorModel:SetPos(self:GetWide() * 0.25 - SS(350, true) - SS(100), ScrH() * 0.36 + SS(25))
    local modelPath = liaVendorEnt and liaVendorEnt.GetModel and liaVendorEnt:GetModel() or ""
    if util.IsValidModel(modelPath) then
        self.vendorModel:SetModel(modelPath)
    else
        self.vendorModel:SetModel("")
    end

    self.vendorModel:SetFOV(20)
    self.vendorModel:SetAlpha(0)
    self.vendorModel:AlphaTo(255, 0.2)
    self.vendorModel.LayoutEntity = function()
        local e = self.vendorModel.Entity
        if e then
            local b = e:LookupBone("ValveBiped.Bip01_Head1")
            if b and b >= 0 then self.vendorModel:SetLookAt(e:GetBonePosition(b)) end
            e:SetAngles(Angle(0, 45, 0))
            for _, seq in ipairs(e:GetSequenceList()) do
                if seq:lower():find("idle") and seq ~= "idlenoise" then
                    e:ResetSequence(seq)
                    break
                end
            end
        end
    end

    self.playerModel = self:Add("DModelPanel")
    self.playerModel:SetSize(SS(160, true), SS(170))
    self.playerModel:SetPos(self:GetWide() * 0.75 + SS(110) - SS(50), ScrH() * 0.36 + SS(25))
    local pm = p:GetModel()
    if util.IsValidModel(pm) then
        self.playerModel:SetModel(pm)
    else
        self.playerModel:SetModel("")
    end

    self.playerModel:SetFOV(20)
    self.playerModel:SetAlpha(0)
    self.playerModel:AlphaTo(255, 0.2)
    self.playerModel.LayoutEntity = function()
        local e = self.playerModel.Entity
        if e then
            local b = e:LookupBone("ValveBiped.Bip01_Head1")
            if b and b >= 0 then self.playerModel:SetLookAt(e:GetBonePosition(b)) end
            e:SetAngles(Angle(0, 45, 0))
            for _, seq in ipairs(e:GetSequenceList()) do
                if seq:lower():find("idle") and seq ~= "idlenoise" then
                    e:ResetSequence(seq)
                    break
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
    local d = liaVendorEnt.items
    if not (d and istable(d)) then d = liaVendorEnt:getNetVar("items", {}) end
    for uid in SortedPairs(d) do
        local it = lia.item.list[uid]
        if it then
            local m = liaVendorEnt:getTradeMode(uid)
            if m then
                if m ~= VENDOR_BUYONLY then self:updateItem(uid, "vendor") end
                if m ~= VENDOR_SELLONLY then
                    local p = self:updateItem(uid, "me")
                    if p then p:setIsSelling(true) end
                end
            end
        end
    end
end

function PANEL:shouldShow(uid, w)
    if not IsValid(liaVendorEnt) then return false end
    local m = liaVendorEnt:getTradeMode(uid)
    if not m then return false end
    if w == "me" and m == VENDOR_SELLONLY then return false end
    if w == "vendor" and m == VENDOR_BUYONLY then return false end
    return true
end

function PANEL:updateItem(uid, w, qty)
    local container = self.items[w]
    if not container then return end
    if not self:shouldShow(uid, w) then
        if IsValid(container[uid]) then container[uid]:Remove() end
        return
    end

    local parentPanel = w == "me" and self.mePanel or self.vendorPanel
    if not IsValid(parentPanel.items) then
        parentPanel.items = vgui.Create("DPanel", parentPanel)
        parentPanel.items:Dock(FILL)
        parentPanel.items:SetPaintBackground(false)
    end

    local p = container[uid]
    if not IsValid(p) then
        p = vgui.Create("VendorItem", parentPanel.items)
        p:setItemType(uid)
        p:setIsSelling(w == "me")
        container[uid] = p
    end

    if not isnumber(qty) then
        local lp = LocalPlayer()
        qty = w == "me" and lp:getChar():getInv():getItemCount(uid) or liaVendorEnt:getStock(uid)
    end

    p:setQuantity(qty)
    return p
end

function PANEL:GetItemCategoryList()
    if not IsValid(liaVendorEnt) then return {} end
    local d = liaVendorEnt.items
    if not (d and istable(d)) then d = liaVendorEnt:getNetVar("items", {}) end
    local o = {}
    o[L("vendorShowAll")] = true
    for uid in pairs(d) do
        local it = lia.item.list[uid]
        if it then
            local cat = it.category or "Misc"
            local first = cat:sub(1, 1):upper()
            local rest = cat:sub(2)
            o[first .. rest] = true
        end
    end
    return o
end

function PANEL:applyCategoryFilter()
    if not IsValid(liaVendorEnt) then return end
    for _, pnl in pairs(self.items.vendor) do
        if IsValid(pnl) then pnl:Remove() end
    end

    for _, pnl in pairs(self.items.me) do
        if IsValid(pnl) then pnl:Remove() end
    end

    self.items.vendor = {}
    self.items.me = {}
    local d = liaVendorEnt.items
    if not (d and istable(d)) then d = liaVendorEnt:getNetVar("items", {}) end
    if not self.currentCategory or self.currentCategory == L("vendorShowAll") then
        for uid in SortedPairs(d) do
            local m = liaVendorEnt:getTradeMode(uid)
            if m and m ~= VENDOR_BUYONLY then self:updateItem(uid, "vendor") end
            if m and m ~= VENDOR_SELLONLY then
                local p = self:updateItem(uid, "me")
                if p then p:setIsSelling(true) end
            end
        end
    else
        for uid in SortedPairs(d) do
            local it = lia.item.list[uid]
            if it then
                local cat = it.category or "Misc"
                cat = cat:sub(1, 1):upper() .. cat:sub(2)
                if cat == self.currentCategory then
                    local m = liaVendorEnt:getTradeMode(uid)
                    if m and m ~= VENDOR_BUYONLY then self:updateItem(uid, "vendor") end
                    if m and m ~= VENDOR_SELLONLY then
                        local p = self:updateItem(uid, "me")
                        if p then p:setIsSelling(true) end
                    end
                end
            end
        end
    end

    if IsValid(self.vendorPanel.items) then self.vendorPanel.items:InvalidateLayout() end
    if IsValid(self.mePanel.items) then self.mePanel.items:InvalidateLayout() end
end

function PANEL:onVendorPropEdited(_, k)
    if not IsValid(liaVendorEnt) then return end
    if k == "model" then
        local m = liaVendorEnt:GetModel() or ""
        if util.IsValidModel(m) then
            self.vendorModel:SetModel(m)
        else
            self.vendorModel:SetModel("")
        end
    elseif k == "scale" then
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
    local v = self.items.vendor[uid]
    if IsValid(v) then v:updateLabel() end
    local m = self.items.me[uid]
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

function PANEL:InventoryItemAdded(it)
    if not it or not it.uniqueID then return end
    self:updateItem(it.uniqueID, "me")
end

function PANEL:InventoryItemRemoved(it)
    if not it or not it.uniqueID then return end
    self:InventoryItemAdded(it)
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
    local b = input.LookupBinding("+use", true)
    if b then self:Remove() end
end

vgui.Register("Vendor", PANEL, "EditablePanel")