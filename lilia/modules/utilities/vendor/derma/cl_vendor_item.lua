local MODULE = MODULE
local PANEL = {}
function PANEL:Init()
    self:Dock(TOP)
    self:SetTall(150)
    self:SetPaintBackground(false)
    self.suffix = ""
    self.icon = self:Add("liaItemIcon")
    self.icon:SetSize(96, 96)
    self.icon:Dock(LEFT)
    self.icon.Paint = function() end
    self.name = self:Add("DLabel")
    self.name:SetTextColor(color_white)
    self.name:SetExpensiveShadow(1, color_black)
    self.name:SetFont("VendorSmallFont")
    self.name:SetContentAlignment(5)
    self.name:Dock(TOP)
    self.name:DockMargin(10, 20, 10, 0)
    self.description = self:Add("DLabel")
    self.description:SetTextColor(color_white)
    self.description:SetExpensiveShadow(1, color_black)
    self.description:SetFont("VendorTinyFont")
    self.description:SetContentAlignment(5)
    self.description:Dock(TOP)
    self.description:DockMargin(10, 10, 10, 0)
    self.price = self:Add("DLabel")
    self.price:SetTextColor(color_white)
    self.price:SetExpensiveShadow(1, color_black)
    self.price:SetFont("VendorTinyFont")
    self.price:SetContentAlignment(5)
    self.price:Dock(TOP)
    self.price:DockMargin(10, 5, 10, 10)
    self:SetCursor("hand")
    self.isSelling = false
    self.action = self:Add("DButton")
    self.action:Dock(TOP)
    self.action:SetSize(475, 30)
    self.action:SetFont("VendorSmallFont")
    self.action:SetTextColor(color_white)
    self.action:SetContentAlignment(5)
    self.action.Paint = function(_, w, h)
        surface.SetDrawColor(255, 255, 255, 20)
        surface.DrawLine(0, 0, 0, h)
        surface.DrawLine(0, 0, w, 0)
        surface.DrawLine(w - 1, 0, w - 1, h)
        surface.DrawLine(0, h - 1, w, h - 1)
    end
end

function PANEL:updatePrice()
    self:updateLabel()
end

function PANEL:setIsSelling(isSelling)
    self.isSelling = isSelling
    self:updatePrice()
    self:updateAction()
end

local function clickEffects()
    LocalPlayer():EmitSound(unpack(MODULE.VendorClick))
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
    self.action:SetText(L(self.isSelling and "sell" or "buy"):upper())
    self.action:SetFont("VendorSmallFont")
    self.action.DoClick = self.isSelling and function() self:sellItemToVendor() end or function() self:buyItemFromVendor() end
    self.action.item = self.item
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
end

function PANEL:updateLabel()
    if not self.item then return end
    local price = liaVendorEnt:getPrice(self.item.uniqueID, self.isSelling)
    local priceText
    if price == 0 then
        priceText = "Free"
    else
        priceText = string.format("%s %s", price, price > 1 and lia.currency.plural or lia.currency.singular)
    end

    self.name:SetText(string.format("%s", self.suffix .. self.item:getName()))
    self.description:SetText(self.item:getDesc())
    self.price:SetText(priceText)
    self.name:SizeToContents()
    self.description:SizeToContents()
    self.price:SizeToContents()
    local priceX, _ = self.price:GetPos()
    local panelHeight = self:GetTall()
    self.action:SetPos(priceX, panelHeight - 40)
    self:InvalidateLayout()
end

vgui.Register("VendorItem", PANEL, "DPanel")
