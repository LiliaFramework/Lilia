function MODULE:VendorOpened(vendor)
    local vendorUI = vgui.Create("Vendor")
    vendorUI.vendor = vendor
    hook.Run("OnOpenVendorMenu", self, vendor)
end

function MODULE:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end

net.Receive("VendorSync", function()
    local vendor = net.ReadEntity()
    if not IsValid(vendor) then return end
    vendor.money = net.ReadInt(32)
    if vendor.money < 0 then vendor.money = nil end
    local count = net.ReadUInt(16)
    vendor.items = {}
    for _ = 1, count do
        local itemType = net.ReadString()
        local price = net.ReadInt(32)
        local stock = net.ReadInt(32)
        local maxStock = net.ReadInt(32)
        local mode = net.ReadInt(8)
        if price < 0 then price = nil end
        if stock < 0 then stock = nil end
        if maxStock <= 0 then maxStock = nil end
        if mode < 0 then mode = nil end
        vendor.items[itemType] = {
            [VENDOR_PRICE] = price,
            [VENDOR_STOCK] = stock,
            [VENDOR_MAXSTOCK] = maxStock,
            [VENDOR_MODE] = mode
        }
    end

    hook.Run("VendorSynchronized", vendor)
end)

net.Receive("VendorOpen", function()
    local vendor = net.ReadEntity()
    if IsValid(vendor) then
        liaVendorEnt = vendor
        hook.Run("VendorOpened", vendor)
    end
end)

net.Receive("VendorExit", function()
    liaVendorEnt = nil
    hook.Run("VendorExited")
end)

net.Receive("VendorEdit", function()
    local key = net.ReadString()
    timer.Simple(0.25, function()
        if not IsValid(liaVendorEnt) then return end
        hook.Run("VendorEdited", liaVendorEnt, key)
    end)
end)

net.Receive("VendorFaction", function()
    local factionID = net.ReadUInt(8)
    if IsValid(liaVendorEnt) then liaVendorEnt.factions[factionID] = true end
end)

net.Receive("VendorMoney", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local money = net.ReadInt(32)
    if money < 0 then money = nil end
    local old = vendor.money
    vendor.money = money
    hook.Run("VendorMoneyUpdated", vendor, money, old)
end)

net.Receive("VendorPrice", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadInt(32)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_PRICE] = value
    hook.Run("VendorItemPriceUpdated", vendor, itemType, value)
end)

net.Receive("VendorMode", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadInt(8)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MODE] = value
    hook.Run("VendorItemModeUpdated", vendor, itemType, value)
end)

net.Receive("VendorStock", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_STOCK] = value
    hook.Run("VendorItemStockUpdated", vendor, itemType, value)
end)

net.Receive("VendorMaxStock", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    if value == 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MAXSTOCK] = value
    hook.Run("VendorItemMaxStockUpdated", vendor, itemType, value)
end)

net.Receive("VendorAllowFaction", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local id = net.ReadUInt(8)
    local allowed = net.ReadBool()
    if allowed then
        vendor.factions[id] = true
    else
        vendor.factions[id] = nil
    end

    hook.Run("VendorFactionUpdated", vendor, id, allowed)
end)

net.Receive("VendorAllowClass", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local id = net.ReadUInt(8)
    local allowed = net.ReadBool()
    if allowed then
        vendor.classes[id] = true
    else
        vendor.classes[id] = nil
    end

    hook.Run("VendorClassUpdated", vendor, id, allowed)
end)