local PANEL = {}
function PANEL:Init()
    local client = LocalPlayer()
    local w, h = ScrW(), ScrH()
    if IsValid(lia.gui.vendor) then
        lia.gui.vendor.noSendExit = true
        lia.gui.vendor:Remove()
    end

    lia.gui.vendor = self
    self:SetSize(w, h)
    self:MakePopup()
    self:SetAlpha(0)
    self:AlphaTo(255, 0.2, 0)
    self.buttons = self:Add("DPanel")
    self.buttons:DockMargin(0, 32, 0, 0)
    self.buttons:Dock(TOP)
    self.buttons:SetPaintBackground(false)
    self.buttons:SetTall(36)
    self.categoryList = self:Add("DHorizontalScroller")
    self.categoryList:SetSize(w, 60)
    self.categoryList:SetPos(0, 0)
    self.categoryList:SetOverlap(5)
    self.vendor = self:Add("VendorTrader")
    self.vendor:SetSize(math.max(w * 0.25, 220), h - self.vendor.y)
    self.vendor:SetPos(w * 0.5 - self.vendor:GetWide() - 32, 64 + 44)
    self.vendor:SetTall(h - self.vendor.y)
    self.me = self:Add("VendorTrader")
    self.me:SetSize(self.vendor:GetSize())
    self.me:SetPos(w * 0.5 + 32, self.vendor.y)
    self:listenForChanges()
    self:liaListenForInventoryChanges(client:getChar():getInv())
    self.items = {
        [self.vendor] = {},
        [self.me] = {}
    }

    self.currentCategory = nil
    self.meText = vgui.Create("DLabel", self)
    self.meText:SetText(L("vendorYourItems"))
    self.meText:SetFont("liaBigFont")
    self.meText:SetTextColor(color_white)
    self.meText:SetContentAlignment(5)
    self.meText:SizeToContents()
    self.meText:SetPos(self.me.x + self.me:GetWide() / 2 - self.meText:GetWide() / 2, self.me.y - self.meText:GetTall() - 10)
    self.vendorText = vgui.Create("DLabel", self)
    self.vendorText:SetText(L("vendorItems"))
    self.vendorText:SetFont("liaBigFont")
    self.vendorText:SetTextColor(color_white)
    self.vendorText:SetContentAlignment(5)
    self.vendorText:SizeToContents()
    self.vendorText:SetPos(self.vendor.x + self.vendor:GetWide() / 2 - self.vendorText:GetWide() / 2, self.vendor.y - self.vendorText:GetTall() - 10)
    self:initializeItems()
    self:createCategoryList()
    self.left = vgui.Create("DFrame", self)
    self.left:SetPos(w * 0.015, h * 0.35)
    self.left:SetSize(w * 0.212, h * 0.24)
    self.left:SetTitle("")
    self.left:ShowCloseButton(false)
    self.left:SetDraggable(false)
    self.left.Paint = function()
        local name = liaVendorEnt:getNetVar("name", "Jane Doe")
        local scale = liaVendorEnt:getNetVar("scale", 0.5)
        local money = liaVendorEnt:getMoney() ~= nil and liaVendorEnt:getMoney() or "∞"
        local itemCount = table.Count(self.items[self.vendor])
        local panelHeight = SS(215)
        surface.SetDrawColor(Color(30, 30, 30, 190))
        surface.DrawRect(0, 0, w, panelHeight)
        surface.DrawOutlinedRect(0, 0, w, panelHeight)
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, w * 0.26, h * 0.033)
        surface.SetDrawColor(Color(30, 30, 30, 50))
        surface.DrawOutlinedRect(0, 0, w * 0.26, h * 0.033)
        draw.DrawText(name, "liaMediumFont", w * 0.005, h * 0.003, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(L("vendorMoney"), "liaSmallFont", w * 0.1, h * 0.05, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(money, "liaSmallFont", w * 0.2, h * 0.05, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorSellScale"), "liaSmallFont", w * 0.1, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(math.ceil(scale * 100) .. "%", "liaSmallFont", w * 0.2, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        draw.DrawText(L("vendorItemCount"), "liaSmallFont", w * 0.1, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(itemCount .. " " .. (tonumber(itemCount) > 1 and "Items" or "Item"), "liaSmallFont", w * 0.2, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
    end

    self.right = vgui.Create("DFrame", self)
    self.right:SetPos(w * 0.78, h * 0.35)
    self.right:SetSize(w * 0.212, h * 0.61)
    self.right:SetTitle("")
    self.right:ShowCloseButton(false)
    self.right:SetDraggable(false)
    self.right.Paint = function()
        surface.SetDrawColor(Color(30, 30, 30, 190))
        surface.DrawRect(0, 0, w, SS(215))
        surface.DrawOutlinedRect(0, 0, w, SS(215))
        surface.SetDrawColor(0, 0, 14, 150)
        surface.DrawRect(0, 0, w * 0.26, h * 0.033)
        surface.DrawOutlinedRect(0, 0, w * 0.26, h * 0.033)
        draw.DrawText(client:getChar():getName(), "liaMediumFont", w * 0.005, h * 0.003, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        local factionName = team.GetName(client:Team())
        if #factionName > 25 then factionName = string.sub(factionName, 1, 25) .. "..." end
        draw.DrawText(L("faction"), "liaSmallFont", w * 0.085, h * 0.05, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
        draw.DrawText(factionName, "liaSmallFont", w * 0.201, h * 0.05, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        local charClass = client:getChar():getClass()
        if lia.class.list[charClass] then
            draw.DrawText(L("class"), "liaSmallFont", w * 0.085, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
            draw.DrawText(lia.class.list[charClass].name, "liaSmallFont", w * 0.2, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorMoney"), "liaSmallFont", w * 0.085, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(client:getChar():getMoney()), "liaSmallFont", w * 0.2, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", w * 0.085, h * 0.11, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
            draw.DrawText(client:getChar():getInv():getItemCount() .. " " .. (tonumber(client:getChar():getInv():getItemCount()) > 1 and "Items" or "Item"), "liaSmallFont", w * 0.2, h * 0.11, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        else
            draw.DrawText(L("vendorMoney"), "liaSmallFont", w * 0.085, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
            draw.DrawText(lia.currency.get(client:getChar():getMoney()), "liaSmallFont", w * 0.2, h * 0.07, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
            draw.DrawText(L("vendorItemCount"), "liaSmallFont", w * 0.085, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_LEFT)
            draw.DrawText(client:getChar():getInv():getItemCount() .. " " .. (tonumber(client:getChar():getInv():getItemCount()) > 1 and "Items" or "Item"), "liaSmallFont", w * 0.2, h * 0.09, Color(255, 255, 255, 210), TEXT_ALIGN_RIGHT)
        end
    end

    local btnWidth = w * 0.15
    local btnHeight = h * 0.05
    local btnGap = 5
    if client:CanEditVendor() then
        local buttonY = self.right:GetY() + self.right:GetTall() - btnHeight - (w * 0.02)
        self.editor = self:Add("DButton")
        self.editor:SetSize(btnWidth, btnHeight)
        self.editor:SetPos(self.left:GetWide() - btnWidth - (w * 0.02), buttonY)
        self.editor:SetText(L("vendorEditorButton"))
        self.editor:SetFont("liaMediumFont")
        self.editor:SetTextColor(Color(255, 255, 255, 210))
        self.editor.DoClick = function() vgui.Create("VendorEditor"):SetZPos(99) end
        self.editor.Paint = function(btn, width, height) self:PaintButton(btn, width, height) end
    end

    self.leaveButton = self.right:Add("DButton")
    self.leaveButton:SetSize(btnWidth, btnHeight)
    self.leaveButton:SetPos(self.right:GetWide() - btnWidth - (w * 0.02), self.right:GetTall() - btnHeight - (w * 0.02))
    self.leaveButton:SetText(L("leave"))
    self.leaveButton:SetFont("liaMediumFont")
    self.leaveButton:SetTextColor(Color(255, 255, 255, 210))
    self.leaveButton.DoClick = function() lia.gui.vendor:Remove() end
    self.leaveButton.Paint = function(btn, width, height) self:PaintButton(btn, width, height) end
    if self.categoryList:GetCanvas():ChildCount() > 0 then
        self.categoryToggle = self.right:Add("DButton")
        self.categoryToggle:SetSize(btnWidth, btnHeight)
        self.categoryToggle:SetPos(self.leaveButton.x, self.leaveButton.y - btnHeight - btnGap)
        self.categoryToggle:SetText(L("vendorHideCategories"))
        self.categoryToggle:SetFont("liaMediumFont")
        self.categoryToggle:SetTextColor(Color(255, 255, 255, 210))
        self.categoryToggle.DoClick = function(button)
            if self.categoryList:IsVisible() then
                self.categoryList:SetVisible(false)
                button:SetText(L("vendorShowCategories"))
            else
                self.categoryList:SetVisible(true)
                button:SetText(L("vendorHideCategories"))
            end
        end

        self.categoryToggle.Paint = function(btn, width, height) self:PaintButton(btn, width, height) end
    end

    self:DrawPortraits()
end

function PANEL:DrawPortraits()
    local client = LocalPlayer()
    local function SafeSetModel(panel, model)
        if util.IsValidModel(model) then
            panel:SetModel(model)
        else
            panel:SetModel("")
        end
    end

    self.vendorModel = self:Add("DModelPanel")
    self.vendorModel:SetSize(SS(160, true), SS(170))
    self.vendorModel:SetPos((self:GetWide() / 2) / 2 - self.vendorModel:GetWide() / 2 - SS(350, true), ScrH() * 0.36 + SS(25))
    local vendorModelPath = liaVendorEnt and liaVendorEnt.GetModel and liaVendorEnt:GetModel() or ""
    SafeSetModel(self.vendorModel, vendorModelPath)
    self.vendorModel:SetFOV(20)
    self.vendorModel:SetAlpha(0)
    self.vendorModel:AlphaTo(255, 0.2)
    self.vendorModel.LayoutEntity = function()
        if self.vendorModel.Entity then
            local vendorhead = self.vendorModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if vendorhead and vendorhead >= 0 then self.vendorModel:SetLookAt(self.vendorModel.Entity:GetBonePosition(vendorhead)) end
            self.vendorModel.Entity:SetAngles(Angle(0, 45, 0))
            for k, v in ipairs(self.vendorModel.Entity:GetSequenceList()) do
                if v:lower():find("idle") and v ~= "idlenoise" then
                    self.vendorModel.Entity:ResetSequence(k)
                    break
                end
            end
        end
    end

    self.playerModel = self:Add("DModelPanel")
    self.playerModel:SetSize(SS(160, true), SS(170))
    self.playerModel:SetPos((self:GetWide() / 2) / 2 - self.playerModel:GetWide() / 2 + SS(1100, true), ScrH() * 0.36 + SS(25))
    local playerModelPath = client:GetModel()
    SafeSetModel(self.playerModel, playerModelPath)
    self.playerModel:SetFOV(20)
    self.playerModel:SetAlpha(0)
    self.playerModel:AlphaTo(255, 0.2)
    self.playerModel.LayoutEntity = function()
        if self.playerModel.Entity then
            local playerhead = self.playerModel.Entity:LookupBone("ValveBiped.Bip01_Head1")
            if playerhead and playerhead >= 0 then self.playerModel:SetLookAt(self.playerModel.Entity:GetBonePosition(playerhead)) end
            self.playerModel.Entity:SetAngles(Angle(0, 45, 0))
            for k, v in ipairs(self.playerModel.Entity:GetSequenceList()) do
                if v:lower():find("idle") and v ~= "idlenoise" then
                    self.playerModel.Entity:ResetSequence(k)
                    break
                end
            end
        end
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
        local item = lia.item.list[itemType]
        if not item then
            LiliaInformation("Invalid Item: " .. itemType)
            continue
        end

        local mode = liaVendorEnt:getTradeMode(itemType)
        if not mode then continue end
        if mode ~= VENDOR_BUYONLY then self:updateItem(itemType, self.vendor) end
        if mode ~= VENDOR_SELLONLY then
            local panel = self:updateItem(itemType, self.me)
            if panel then panel:setIsSelling(true) end
        end
    end
end

function PANEL:shouldItemBeVisible(itemType, parent)
    local mode = liaVendorEnt:getTradeMode(itemType)
    if parent == self.me and mode == VENDOR_SELLONLY then return false end
    if parent == self.vendor and mode == VENDOR_BUYONLY then return false end
    return mode ~= nil
end

function PANEL:updateItem(itemType, parent, quantity)
    local client = LocalPlayer()
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

    if not isnumber(quantity) then quantity = parent == self.me and client:getChar():getInv():getItemCount(itemType) or liaVendorEnt:getStock(itemType) end
    panel:setQuantity(quantity)
    return panel
end

function PANEL:onVendorPropEdited(vendor, key)
    if key == "model" then
        self.vendorModel:SetModel(vendor:GetModel())
    elseif key == "scale" then
        for _, panel in pairs(self.items[self.vendor]) do
            if not IsValid(panel) then continue end
            panel:updateLabel()
        end

        for _, panel in pairs(self.items[self.me]) do
            if not IsValid(panel) then continue end
            panel:updateLabel()
        end
    end
end

function PANEL:onVendorPriceUpdated(_, itemType)
    local panel = self.items[self.vendor][itemType]
    if IsValid(panel) then panel:updateLabel() end
    panel = self.items[self.me][itemType]
    if IsValid(panel) then panel:updateLabel() end
end

function PANEL:onVendorModeUpdated(_, itemType)
    self:updateItem(itemType, self.vendor)
    self:updateItem(itemType, self.me)
end

function PANEL:onItemStockUpdated(_, itemType)
    self:updateItem(itemType, self.vendor)
end

function PANEL:GetItemCategoryList()
    local categories = {}
    for itemType in SortedPairs(liaVendorEnt.items) do
        local item = lia.item.list[itemType]
        if item and item.category then categories[item.category] = true end
    end
    return categories
end

function PANEL:createCategoryList()
    local categories = self:GetItemCategoryList()
    if table.IsEmpty(categories) then return end
    local sortedCategories = {}
    for category, _ in pairs(categories) do
        table.insert(sortedCategories, category)
    end

    table.sort(sortedCategories)
    local buttonWidth = 250
    local buttonHeight = 40
    local gap = 5
    local totalButtons = #sortedCategories + 1
    local totalWidth = (buttonWidth + gap) * totalButtons - gap
    local allButton = vgui.Create("DButton")
    allButton:SetSize(buttonWidth, buttonHeight)
    allButton:SetText(L("vendorShowAll"))
    allButton:SetFont("liaBigFont")
    allButton:SetTextColor(Color(255, 255, 255))
    allButton.Paint = function(panel, w, h) self:PaintButton(panel, w, h) end
    allButton.DoClick = function()
        self.currentCategory = nil
        self:filterItemsByCategory()
    end

    self.categoryList:AddPanel(allButton)
    for _, category in ipairs(sortedCategories) do
        local categoryButton = vgui.Create("DButton")
        categoryButton:SetSize(buttonWidth, buttonHeight)
        categoryButton:SetText(string.FirstToUpper(category))
        categoryButton:SetFont("liaBigFont")
        categoryButton:SetTextColor(Color(255, 255, 255))
        categoryButton.Paint = function(panel, w, h) self:PaintButton(panel, w, h) end
        categoryButton.DoClick = function()
            self.currentCategory = category
            self:filterItemsByCategory()
        end

        self.categoryList:AddPanel(categoryButton)
    end

    self.categoryList.PerformLayout = function(scroller)
        local canvas = scroller:GetCanvas()
        canvas:SetWide(totalWidth)
        canvas:SetPos((scroller:GetWide() - totalWidth) / 2, 0)
    end
end

function PANEL:PaintButton(btn, width, height)
    if btn:IsDown() then
        surface.SetDrawColor(Color(40, 40, 40, 240))
    elseif btn:IsHovered() then
        surface.SetDrawColor(Color(30, 30, 30, 150))
    else
        surface.SetDrawColor(Color(30, 30, 30, 160))
    end

    surface.DrawRect(0, 0, width, height)
    surface.SetDrawColor(Color(0, 0, 0, 235))
    surface.DrawOutlinedRect(0, 0, width, height)
end

function PANEL:filterItemsByCategory()
    for itemType, panel in pairs(self.items[self.vendor]) do
        if IsValid(panel) then
            panel:Remove()
            self.items[self.vendor][itemType] = nil
        end
    end

    for itemType, panel in pairs(self.items[self.me]) do
        if IsValid(panel) then
            panel:Remove()
            self.items[self.me][itemType] = nil
        end
    end

    for itemType in SortedPairs(liaVendorEnt.items) do
        local item = lia.item.list[itemType]
        if item and (self.currentCategory == nil or item.category == self.currentCategory) then
            local mode = liaVendorEnt:getTradeMode(itemType)
            if mode ~= VENDOR_BUYONLY then self:updateItem(itemType, self.vendor) end
            if mode ~= VENDOR_SELLONLY then
                local panel = self:updateItem(itemType, self.me)
                if panel then panel:setIsSelling(true) end
            end
        end
    end

    if self.vendor.items then self.vendor.items:InvalidateLayout() end
    if self.me.items then self.me.items:InvalidateLayout() end
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
    surface.SetDrawColor(40, 40, 40, 220)
    surface.DrawRect(0, 0, w, h)
    surface.SetDrawColor(255, 255, 255, 50)
    surface.DrawOutlinedRect(0, 0, w, h)
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
    local useKey = input.LookupBinding("+use", true)
    if useKey then self:Remove() end
end

vgui.Register("Vendor", PANEL, "EditablePanel")