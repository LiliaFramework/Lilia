function MODULE:VendorOpened(vendor)
    local vendorUI = vgui.Create("Vendor")
    vendorUI.vendor = vendor
    hook.Run("OnOpenVendorMenu", self, vendor)
end
function MODULE:VendorExited()
    if IsValid(lia.gui.vendor) then lia.gui.vendor:Remove() end
end
net.Receive("liaVendorSync", function()
    local vendor = net.ReadEntity()
    if not IsValid(vendor) then return end
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
net.Receive("liaVendorOpen", function()
    local vendor = net.ReadEntity()
    if IsValid(vendor) then
        liaVendorEnt = vendor
        hook.Run("VendorOpened", vendor)
    end
end)
net.Receive("liaVendorExit", function()
    liaVendorEnt = nil
    hook.Run("VendorExited")
end)
net.Receive("liaVendorEdit", function()
    local key = net.ReadString()
    timer.Simple(0.25, function()
        if not IsValid(liaVendorEnt) then return end
        hook.Run("VendorEdited", liaVendorEnt, key)
    end)
end)
net.Receive("liaVendorFaction", function()
    local factionID = net.ReadUInt(8)
    if IsValid(liaVendorEnt) then liaVendorEnt.factions[factionID] = true end
end)
net.Receive("liaVendorPrice", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadInt(32)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_PRICE] = value
    hook.Run("VendorItemPriceUpdated", vendor, itemType, value)
end)
net.Receive("liaVendorMode", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadInt(8)
    if value < 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MODE] = value
    hook.Run("VendorItemModeUpdated", vendor, itemType, value)
end)
net.Receive("liaVendorStock", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_STOCK] = value
    hook.Run("VendorItemStockUpdated", vendor, itemType, value)
end)
net.Receive("liaVendorMaxStock", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local itemType = net.ReadString()
    local value = net.ReadUInt(32)
    if value == 0 then value = nil end
    vendor.items[itemType] = vendor.items[itemType] or {}
    vendor.items[itemType][VENDOR_MAXSTOCK] = value
    hook.Run("VendorItemMaxStockUpdated", vendor, itemType, value)
end)
net.Receive("liaVendorAllowFaction", function()
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
net.Receive("liaVendorAllowClass", function()
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