local RarityColors = {
    ["Common"] = Color(255, 255, 255),
    ["Uncommon"] = Color(30, 255, 0),
    ["Rare"] = Color(0, 112, 221),
    ["Epic"] = Color(163, 53, 238),
    ["Legendary"] = Color(255, 128, 0),
}

local VendorClick = {"buttons/button15.wav", 30, 250}
local PANEL = {}
function PANEL:Init()
    self:SetSize(600, 200)
    self:Dock(TOP)
    self:SetPaintBackground(false)
    self:SetCursor("hand")
    self.background = self:Add("DPanel")
    self.background:Dock(FILL)
    self.background.Paint = function(_, w, h)
        surface.SetDrawColor(40, 40, 40, 220)
        surface.DrawRect(0, 0, w, h)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.iconFrame = self.background:Add("DPanel")
    self.iconFrame:SetSize(96, 96)
    self.iconFrame:Dock(LEFT)
    self.iconFrame:DockMargin(10, 10, 10, 10)
    self.iconFrame.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 80)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    self.icon = self.iconFrame:Add("liaItemIcon")
    self.icon:SetSize(96, 96)
    self.icon:Dock(FILL)
    self.icon.Paint = function() end
    self.textContainer = self.background:Add("DPanel")
    self.textContainer:Dock(FILL)
    self.textContainer:DockMargin(0, 10, 10, 10)
    self.textContainer:SetPaintBackground(false)
    self.name = self.textContainer:Add("DLabel")
    self.name:SetFont(L("vendorItemName"))
    self.name:SetExpensiveShadow(1, color_black)
    self.name:Dock(TOP)
    self.name:SetContentAlignment(5)
    self.description = self.textContainer:Add("DLabel")
    self.description:SetFont(L("vendorItemDesc"))
    self.description:SetTextColor(Color(200, 200, 200))
    self.description:Dock(TOP)
    self.description:DockMargin(0, 5, 0, 0)
    self.description:SetWrap(true)
    self.description:SetContentAlignment(7)
    self.description:SetAutoStretchVertical(true)
    self.spacer = self.textContainer:Add("DPanel")
    self.spacer:Dock(FILL)
    self.spacer:SetPaintBackground(false)
    self.action = self.textContainer:Add("DButton")
    self.action:SetHeight(30)
    self.action:Dock(BOTTOM)
    self.action:DockMargin(0, 5, 0, 0)
    self.action:SetFont(L("vendorActionButton"))
    self.action:SetTextColor(color_white)
    self.action.Paint = function(_, w, h) self:PaintButton(self.action, w, h) end
    self.isSelling = false
    self.suffix = ""
end

function PANEL:setIsSelling(isSelling)
    self.isSelling = isSelling
    self:updateLabel()
    self:updateAction()
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

function PANEL:updateAction()
    if not self.action or not self.item then return end
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local typeOfTransaction = self.isSelling and "Sell" or "Buy"
    local priceSuffix
    if price == 0 then
        priceSuffix = "Free"
    elseif price > 1 then
        priceSuffix = string.format("%s %s", price, lia.currency.plural)
    else
        priceSuffix = string.format("%s %s", price, lia.currency.singular)
    end

    local actionText = string.format("%s (%s)", typeOfTransaction, priceSuffix)
    self.action:SetText(actionText)
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

        self.suffix = tostring(quantity) .. "x "
    else
        self.suffix = ""
    end

    self:updateLabel()
end

function PANEL:setItemType(itemType)
    local item = lia.item.list[itemType]
    assert(item, tostring(itemType) .. " is not a valid item")
    self.item = item
    self.icon:SetModel(item.model, item.skin or 0)
    self:updateLabel()
    self:updateAction()
    local rarity = item.rarity or "Common"
    local nameColor = RarityColors[rarity] or color_white
    self.name:SetTextColor(nameColor)
end

function PANEL:updateLabel()
    if not self.item then return end
    local nameText = (self.suffix ~= "" and self.suffix or "") .. self.item:getName()
    self.name:SetText(nameText)
    self.description:SetText(self.item:getDesc() or "")
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local typeOfTransaction = self.isSelling and "Sell" or "Buy"
    local priceSuffix
    if price == 0 then
        priceSuffix = "Free"
    elseif price > 1 then
        priceSuffix = string.format("%s %s", price, lia.currency.plural)
    else
        priceSuffix = string.format("%s %s", price, lia.currency.singular)
    end

    local actionText = string.format("%s (%s)", typeOfTransaction, priceSuffix)
    self.action:SetText(actionText)
end

vgui.Register("VendorItem", PANEL, "DPanel")
