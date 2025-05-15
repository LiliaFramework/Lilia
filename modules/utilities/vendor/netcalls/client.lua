net.Receive("VendorSync", function()
    local vendor = net.ReadEntity()
    if not IsValid(vendor) then return end
    vendor.money = net.ReadInt(32)
    if vendor.money < 0 then vendor.money = nil end
    local count = net.ReadUInt(16)
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
