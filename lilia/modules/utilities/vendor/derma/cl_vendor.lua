local PANEL = {}
function PANEL:Init()
    local w, h = ScrW(), ScrH()
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor.noSendExit = true
        lia.gui.vendor:Remove()
    end

    lia.gui.vendor = self
    self:SetSize(ScrW(), ScrH())
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)
    self.buttons = self:Add("DPanel")
    self.buttons:DockMargin(0, 32, 0, 0)
    self.buttons:Dock(TOP)
    self.buttons:SetPaintBackground(false)
    self.buttons:SetTall(36)
    self.vendor = self:Add("VendorTrader")
    self.vendor:SetWide(math.max(ScrW() * 0.25, 220))
    self.vendor:SetPos(ScrW() * 0.5 - self.vendor:GetWide() - 64 / 2, 64 + 44)
    self.vendor:SetTall(ScrH() - self.vendor.y - 64)
    self.me = self:Add("VendorTrader")
    self.me:SetSize(self.vendor:GetSize())
    self.me:SetPos(ScrW() * 0.5 + 64 / 2, self.vendor.y)
    self:listenForChanges()
    self:liaListenForInventoryChanges(LocalPlayer():getChar():getInv())
    self.items = {
        [self.vendor] = {},
        [self.me] = {}
    }

    self.meText = vgui.Create("DLabel", self)
    self.meText:SetText("Your Items")
    self.meText:SetFont("liaBigFont")
    self.meText:SetTextColor(color_white)
    self.meText:SetContentAlignment(5)
    self.meText:SizeToContents()
    self.meText:SetPos(self.me.x + self.me:GetWide() / 2 - self.meText:GetWide() / 2, self.me.y - self.meText:GetTall() - 10)
    self.vendorText = vgui.Create("DLabel", self)
    self.vendorText:SetText("Vendor Items")
    self.vendorText:SetFont("liaBigFont")
    self.vendorText:SetTextColor(color_white)
    self.vendorText:SetContentAlignment(5)
    self.vendorText:SizeToContents()
    self.vendorText:SetPos(self.vendor.x + self.vendor:GetWide() / 2 - self.vendorText:GetWide() / 2, self.vendor.y - self.vendorText:GetTall() - 10)
    self:initializeItems()
    self.left = vgui.Create("DFrame", self)
    self.left:SetPos(ScrW() * 0.015, ScrH() * 0.35)
    self.left:SetSize(ScrW() * 0.212, ScrH() * 0.24)
    self.left:SetTitle("")
    self.left:ShowCloseButton(false)
    self.left:SetDraggable(false)
    if LocalPlayer():CanEditVendor() then
        self.editor = self.left:Add("DButton")
        self.editor:SetSize(ScrW() * 0.085, ScrH() * 0.0325)
        self.editor:SetPos(ScrW() * 0.0115, ScrH() * 0.187)
        self.editor:SetText("Editor")
        self.editor:SetFont("liaMediumFont")
        self.editor:SetTextColor(Color(255, 255, 255, 210))
        self.editor.DoClick = function() vgui.Create("VendorEditor"):SetZPos(99) end
        self.editor.Paint = function()
            if self.editor:IsDown() then
                surface.SetDrawColor(Color(40, 40, 40, 240))
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(Color(0, 0, 0, 235))
                surface.DrawOutlinedRect(0, 0, w, h)
            elseif self.editor:IsHovered() then
                surface.SetDrawColor(Color(30, 30, 30, 150))
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(Color(0, 0, 0, 235))
                surface.DrawOutlinedRect(0, 0, w, h)
            else
                surface.SetDrawColor(Color(30, 30, 30, 160))
                surface.DrawRect(0, 0, w, h)
                surface.SetDrawColor(Color(0, 0, 0, 235))
                surface.DrawOutlinedRect(0, 0, w, h)
            end
        end
    end

    self.left.Paint = function()
        local name = liaVendorEnt:getNetVar("name", "Jane Doe")
        local desc = liaVendorEnt:getNetVar("desc", "")
        if desc == "" then desc = "A Merchant" end
        local scale = liaVendorEnt:getNetVar("scale", 0.5)
        local money = liaVendorEnt:getMoney() ~= nil and liaVendorEnt:getMoney() or "∞"
        local itemCount = table.Count(self.items[self.vendor])
        local panelHeight = self.editor and h or C(215)
        surface.SetDrawColor(Color(30, 30, 30, 190))
        surface.DrawRect(0, 0, w, panelHeight)
        surface.DrawOutlinedRect(0, 0, w, panelHeight)
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(ScrW() * 0, ScrH() * 0, ScrW() * 0.26, ScrH() * 0.033)
        surface.SetDrawColor(Color(30, 30, 30, 50))
        surface.DrawOutlinedRect(ScrW() * 0, ScrH() * 0, ScrW() * 0.26, ScrH() * 0.033)
        draw.DrawText("Vendor", "liaMediumFont", ScrW() * 0.005, ScrH() * 0.003, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(ScrW() * 0.0115, ScrH() * 0.0575, ScrW() * 0.085, ScrH() * 0.125)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        surface.DrawOutlinedRect(ScrW() * 0.0115, ScrH() * 0.0575, ScrW() * 0.085, ScrH() * 0.125)
        draw.DrawText(name, "liaSmallFont", ScrW() * 0.1, ScrH() * 0.06, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText("Description:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(desc, "liaSmallFont", ScrW() * 0.2, ScrH() * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Money:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.111, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(money, "liaSmallFont", ScrW() * 0.2, ScrH() * 0.111, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Sell Scale:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.132, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(math.ceil(scale * 100) .. "%", "liaSmallFont", ScrW() * 0.2, ScrH() * 0.132, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Item Count:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.153, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(itemCount, "liaSmallFont", ScrW() * 0.2, ScrH() * 0.153, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
    end

    self.right = vgui.Create("DFrame", self)
    self.right:SetPos(ScrW() * 0.77, ScrH() * 0.35)
    self.right:SetSize(ScrW() * 0.212, ScrH() * 0.61)
    self.right:SetTitle("")
    self.right:ShowCloseButton(false)
    self.right:SetDraggable(false)
    self.right.Paint = function()
        surface.SetDrawColor(Color(30, 30, 30, 190))
        surface.DrawRect(0, 0, w, C(215))
        surface.DrawOutlinedRect(0, 0, w, C(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(ScrW() * 0, ScrH() * 0, ScrW() * 0.26, ScrH() * 0.033)
        surface.DrawOutlinedRect(ScrW() * 0, ScrH() * 0, ScrW() * 0.26, ScrH() * 0.033)
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(ScrW() * 0.0115, ScrH() * 0.0575, ScrW() * 0.085, ScrH() * 0.125)
        surface.SetDrawColor(Color(0, 0, 0, 255))
        draw.DrawText("Character", "liaMediumFont", ScrW() * 0.005, ScrH() * 0.003, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(LocalPlayer():getChar():getName(), "liaSmallFont", ScrW() * 0.1, ScrH() * 0.06, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText("Faction:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(team.GetName(LocalPlayer():Team()), "liaSmallFont", ScrW() * 0.2, ScrH() * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Class:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.111, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(LocalPlayer():getChar():getClass() or "None", "liaSmallFont", ScrW() * 0.2, ScrH() * 0.111, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Money:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.132, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(lia.currency.get(LocalPlayer():getChar():getMoney()), "liaSmallFont", ScrW() * 0.2, ScrH() * 0.132, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText("Item Count:", "liaSmallFont", ScrW() * 0.1, ScrH() * 0.153, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(LocalPlayer():getChar():getInv():getItemCount() .. " " .. (LocalPlayer():getChar():getInv():getItemCount() > 1 and "Items" or "Item"), "liaSmallFont", ScrW() * 0.2, ScrH() * 0.153, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
    end

    self.leaveButton = vgui.Create("DButton", self.right)
    self.leaveButton:SetSize(ScrW() * 0.15, ScrH() * 0.05)
    self.leaveButton:SetPos(self.right:GetWide() - (ScrW() * 0.17), self.right:GetTall() - (ScrH() * 0.07))
    self.leaveButton:SetText("Leave")
    self.leaveButton:SetFont("liaMediumFont")
    self.leaveButton:SetTextColor(Color(255, 255, 255, 210))
    self.leaveButton.DoClick = function() lia.gui.vendor:Remove() end
    self.leaveButton.Paint = function()
        if self.leaveButton:IsDown() then
            surface.SetDrawColor(Color(40, 40, 40, 240))
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 235))
            surface.DrawOutlinedRect(0, 0, w, h)
        elseif self.leaveButton:IsHovered() then
            surface.SetDrawColor(Color(30, 30, 30, 150))
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 235))
            surface.DrawOutlinedRect(0, 0, w, h)
        else
            surface.SetDrawColor(Color(30, 30, 30, 160))
            surface.DrawRect(0, 0, w, h)
            surface.SetDrawColor(Color(0, 0, 0, 235))
            surface.DrawOutlinedRect(0, 0, w, h)
        end
    end

    self.Think = function()
        if (self.nextUpdate or 0) < CurTime() then
            self:InvalidateLayout()
            self.nextUpdate = CurTime() + 0.4
        end
    end

    self:DrawPortraits()
end

function PANEL:DrawPortraits()
    self.vendorModel = self:Add("DModelPanel")
    self.vendorModel:SetSize(C(160, true), C(170))
    self.vendorModel:SetPos((self:GetWide() / 2) / 2 - self.vendorModel:GetWide() / 2 - C(350, true), ScrH() * 0.35 + C(25))
    self.vendorModel:SetModel(liaVendorEnt:GetModel())
    self.vendorModel:SetFOV(20)
    self.vendorModel:SetAlpha(0)
    self.vendorModel:AlphaTo(255, 0.2)
    local vendorhead = self.vendorModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
    if vendorhead and vendorhead >= 0 then self.vendorModel:SetLookAt(self.vendorModel.Entity:GetBonePosition(vendorhead)) end
    self.vendorModel.LayoutEntity = function()
        self.vendorModel.Entity:SetAngles(Angle(0, 45, 0))
        self.vendorModel.Entity:ResetSequence(2)
        for k, v in ipairs(self.vendorModel.Entity:GetSequenceList()) do
            if v:lower():find("idle") and v ~= "idlenoise" then return self.vendorModel.Entity:ResetSequence(k) end
        end

        self.vendorModel.Entity:ResetSequence(4)
    end

    self.playerModel = self:Add("DModelPanel")
    self.playerModel:SetSize(C(160, true), C(170))
    self.playerModel:SetPos((self:GetWide() / 2) / 2 - self.playerModel:GetWide() / 2 + C(1100, true), ScrH() * 0.35 + C(25))
    self.playerModel:SetModel(LocalPlayer():GetModel())
    self.playerModel:SetFOV(20)
    self.playerModel:SetAlpha(0)
    self.playerModel:AlphaTo(255, 0.2)
    local playerhead = self.playerModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
    if playerhead and playerhead >= 0 then self.playerModel:SetLookAt(self.playerModel.Entity:GetBonePosition(playerhead)) end
    self.playerModel.LayoutEntity = function()
        self.playerModel.Entity:SetAngles(Angle(0, 45, 0))
        self.playerModel.Entity:ResetSequence(2)
    end
end

function PANEL:CenterTextEntryHorizontally(textEntry, parent)
    local parentWidth = parent:GetWide()
    local textEntryWidth = textEntry:GetWide()
    local posX = (parentWidth - textEntryWidth) / 2
    textEntry:SetPos(posX, 0)
    textEntry:SetContentAlignment(5)
    textEntry:SetEditable(false)
end

function PANEL:buyItemFromVendor(itemType)
    net.Start("VendorTrade")
    net.WriteString(itemType)
    net.WriteBool(false)
    net.SendToServer()
end

function PANEL:sellItemToVendor(itemType)
    net.Start("VendorTrade")
    net.WriteString(itemType)
    net.WriteBool(true)
    net.SendToServer()
end

function PANEL:initializeItems()
    for itemType in SortedPairs(liaVendorEnt.items) do
        local mode = liaVendorEnt:getTradeMode(itemType)
        if not mode then continue end
        if mode ~= VENDOR_SELLONLY then self:updateItem(itemType, self.me):setIsSelling(true) end
        if mode ~= VENDOR_BUYONLY then self:updateItem(itemType, self.vendor) end
    end
end

function PANEL:shouldItemBeVisible(itemType, parent)
    local mode = liaVendorEnt:getTradeMode(itemType)
    if parent == self.me and mode == VENDOR_SELLONLY then return false end
    if parent == self.vendor and mode == VENDOR_BUYONLY then return false end
    return mode ~= nil
end

function PANEL:updateItem(itemType, parent, quantity)
    assert(isstring(itemType), "itemType must be a string")
    if not self.items[parent] then return end
    local panel = self.items[parent][itemType]
    if not self:shouldItemBeVisible(itemType, parent) then
        if IsValid(panel) then panel:Remove() end
        return
    end

    if not IsValid(panel) then
        panel = parent.items:Add("VendorItem")
        panel:setItemType(itemType)
        panel:setIsSelling(parent == self.me)
        self.items[parent][itemType] = panel
    end

    if not isnumber(quantity) then quantity = parent == self.me and LocalPlayer():getChar():getInv():getItemCount(itemType) or liaVendorEnt:getStock(itemType) end
    panel:setQuantity(quantity)
    return panel
end

function PANEL:onVendorPropEdited(vendor, key)
    if key == "model" then
        self.vendorModel:SetModel(vendor:GetModel())
    elseif key == "scale" then
        for _, panel in pairs(self.items[self.vendor]) do
            if not IsValid(panel) then continue end
            panel:updatePrice()
        end

        for _, panel in pairs(self.items[self.me]) do
            if not IsValid(panel) then continue end
            panel:updatePrice()
        end
    end
end

function PANEL:onVendorPriceUpdated(_, itemType, _)
    local panel = self.items[self.vendor][itemType]
    if IsValid(panel) then panel:updatePrice() end
    panel = self.items[self.me][itemType]
    if IsValid(panel) then panel:updatePrice() end
end

function PANEL:onVendorModeUpdated(_, itemType, _)
    self:updateItem(itemType, self.vendor)
    self:updateItem(itemType, self.me)
end

function PANEL:onItemStockUpdated(_, itemType)
    self:updateItem(itemType, self.vendor)
end

function PANEL:listenForChanges()
    hook.Add("VendorItemPriceUpdated", self, self.onVendorPriceUpdated)
    hook.Add("VendorItemStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemMaxStockUpdated", self, self.onItemStockUpdated)
    hook.Add("VendorItemModeUpdated", self, self.onVendorModeUpdated)
    hook.Add("VendorEdited", self, self.onVendorPropEdited)
end

function PANEL:InventoryItemAdded(item)
    self:updateItem(item.uniqueID, self.me)
end

function PANEL:InventoryItemRemoved(item)
    self:InventoryItemAdded(item)
end

function PANEL:Paint(w, h)
    lia.util.drawBlur(self, 10)
    surface.SetDrawColor(0, 0, 0, 100)
    surface.DrawRect(0, 0, w, h)
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

function PANEL:OnKeyCodePressed(_)
    local useKey = input.LookupBinding("+use", true)
    if useKey then self:Remove() end
end

vgui.Register("Vendor", PANEL, "EditablePanel")
if IsValid(lia.gui.vendor) then vgui.Create("Vendor") end