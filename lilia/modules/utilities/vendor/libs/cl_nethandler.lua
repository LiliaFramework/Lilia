local function addNetHandler(name, handler)
    assert(isfunction(handler), "handler is not a function")
    net.Receive("Vendor" .. name, function()
        if not IsValid(liaVendorEnt) then return end
        handler(liaVendorEnt)
    end)
end

addNetHandler("Money", function(vendor)
    local money = net.ReadInt(32)
    if money < 0 then money = nil end
    vendor.money = money
    hook.Run("VendorMoneyUpdated", vendor, money, vendor.money)
end)

addNetHandler("Price", function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadInt(32)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_PRICE] = value
    hook.Run("VendorItemPriceUpdated", vendor, itemType, value)
end)

addNetHandler("Mode", function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadInt(8)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MODE] = value
    hook.Run("VendorItemModeUpdated", vendor, itemType, value)
end)

addNetHandler("Stock", function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_STOCK] = value
    hook.Run("VendorItemStockUpdated", vendor, itemType, value)
end)

addNetHandler("MaxStock", function(vendor)
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    if value == 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MAXSTOCK] = value
    hook.Run("VendorItemMaxStockUpdated", vendor, itemType, value)
end)

addNetHandler("AllowFaction", function(vendor)
    local id = net.ReadUInt(8)
    local allowed = net.ReadBool()
    if allowed then
        vendor.factions[id] = true
    else
        vendor.factions[id] = nil
    end

    hook.Run("VendorFactionUpdated", vendor, id, allowed)
end)

addNetHandler("AllowClass", function(vendor)
    local id = net.ReadUInt(8)
    local allowed = net.ReadBool()
    if allowed then
        vendor.classes[id] = true
    else
        vendor.classes[id] = nil
    end

    hook.Run("VendorClassUpdated", vendor, id, allowed)
end)
