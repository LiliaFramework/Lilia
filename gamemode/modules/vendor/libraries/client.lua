function MODULE:VendorOpened(vendor)
    local vendorUI = vgui.Create("liaVendor")
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

net.Receive("liaVendorFactionBuyScale", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local factionID = net.ReadUInt(8)
    local scale = net.ReadFloat()
    vendor.factionBuyScales = vendor.factionBuyScales or {}
    vendor.factionBuyScales[factionID] = scale
    hook.Run("VendorFactionBuyScaleUpdated", vendor, factionID, scale)
end)

net.Receive("liaVendorFactionSellScale", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    local factionID = net.ReadUInt(8)
    local scale = net.ReadFloat()
    vendor.factionSellScales = vendor.factionSellScales or {}
    vendor.factionSellScales[factionID] = scale
    hook.Run("VendorFactionSellScaleUpdated", vendor, factionID, scale)
end)

net.Receive("liaVendorSyncMessages", function()
    if not IsValid(liaVendorEnt) then return end
    local vendor = liaVendorEnt
    vendor.messages = net.ReadTable()
    hook.Run("VendorMessagesUpdated", vendor)
end)

function MODULE:AddToAdminStickHUD(_, target, information)
    if not IsValid(target) or not target.IsVendor then return end
    local name = target:getName()
    if name and name ~= "" then table.insert(information, L("vendorNameLabel") .. name) end
    local animation = lia.vendor.getVendorProperty(target, "animation")
    if animation and animation ~= "" then table.insert(information, L("animationLabel") .. animation) end
    local itemCount = 0
    if target.items then
        for _, itemData in pairs(target.items) do
            if itemData[VENDOR_STOCK] and itemData[VENDOR_STOCK] > 0 then itemCount = itemCount + 1 end
        end
    end

    table.insert(information, L("vendorItemCountLabel") .. itemCount)
    local factionNames = {}
    if target.factions then
        for factionID, _ in pairs(target.factions) do
            local faction = lia.faction.indices[factionID]
            if faction then table.insert(factionNames, faction.name) end
        end
    end

    if #factionNames > 0 then
        table.insert(information, L("allowedFactionsLabel"))
        for _, factionName in ipairs(factionNames) do
            table.insert(information, "- " .. factionName)
        end

        table.insert(information, "")
    else
        table.insert(information, L("allFactionsLabel"))
    end

    local classNames = {}
    if target.classes then
        for classID, _ in pairs(target.classes) do
            local class = lia.class.list[classID]
            if class then table.insert(classNames, class.name) end
        end
    end

    if #classNames > 0 then
        table.insert(information, L("allowedClassesLabel"))
        for _, className in ipairs(classNames) do
            table.insert(information, "- " .. className)
        end
    end
end

net.Receive("liaVendorSyncPresets", function() lia.vendor.presets = net.ReadTable() end)
net.Receive("liaVendorInitialSync", function()
    local vendorCount = net.ReadUInt(16)
    for _ = 1, vendorCount do
        local vendor = net.ReadEntity()
        if not IsValid(vendor) then continue end
        local propertyCount = net.ReadUInt(8)
        lia.vendor.stored[vendor] = lia.vendor.stored[vendor] or {}
        for _ = 1, propertyCount do
            local propertyName = net.ReadString()
            local propertyValue = net.ReadType()
            lia.vendor.stored[vendor][propertyName] = propertyValue
        end
    end
end)

net.Receive("liaVendorPropertySync", function()
    local vendor = net.ReadEntity()
    if not IsValid(vendor) then return end
    local propertyName = net.ReadString()
    local isDefault = net.ReadBool()
    if not lia.vendor.stored[vendor] then lia.vendor.stored[vendor] = {} end
    if isDefault then
        lia.vendor.stored[vendor][propertyName] = nil
        if table.IsEmpty(lia.vendor.stored[vendor]) then lia.vendor.stored[vendor] = nil end
    else
        local propertyValue = net.ReadType()
        lia.vendor.stored[vendor][propertyName] = propertyValue
    end
end)
