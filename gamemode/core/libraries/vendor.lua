lia.vendor = lia.vendor or {}
lia.vendor.editor = lia.vendor.editor or {}
lia.vendor.presets = lia.vendor.presets or {}
lia.vendor.rarities = lia.vendor.rarities or {}
if SERVER then
    local function addEditor(name, reader, applier)
        lia.vendor.editor[name] = function(vendor)
            local args = {reader()}
            applier(vendor, unpack(args))
        end
    end

    addEditor("name", function() return net.ReadString() end, function(vendor, name) vendor:setName(name) end)
    addEditor("mode", function() return net.ReadString(), net.ReadInt(8) end, function(vendor, itemType, mode)
        if vendor:getNetVar("preset") ~= "none" then return end
        vendor:setTradeMode(itemType, mode)
    end)

    addEditor("price", function() return net.ReadString(), net.ReadInt(32) end, function(vendor, itemType, price)
        if vendor:getNetVar("preset") ~= "none" then return end
        vendor:setItemPrice(itemType, price)
    end)

    addEditor("stockDisable", function() return net.ReadString() end, function(vendor, itemType)
        if vendor:getNetVar("preset") ~= "none" then return end
        vendor:setMaxStock(itemType, nil)
    end)

    addEditor("stockMax", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, itemType, value)
        if vendor:getNetVar("preset") ~= "none" then return end
        vendor:setMaxStock(itemType, value)
    end)

    addEditor("stock", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, itemType, value)
        if vendor:getNetVar("preset") ~= "none" then return end
        vendor:setStock(itemType, value)
    end)

    addEditor("flag", function() return net.ReadString() end, function(vendor, flag) vendor:setFlag(flag) end)
    addEditor("welcome", function() return net.ReadString() end, function(vendor, message) vendor:setWelcomeMessage(message) end)
    addEditor("faction", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, factionID, allowed) vendor:setFactionAllowed(factionID, allowed) end)
    addEditor("class", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, classID, allowed) vendor:setClassAllowed(classID, allowed) end)
    addEditor("model", function() return net.ReadString() end, function(vendor, model) vendor:setModel(model) end)
    addEditor("skin", function() return net.ReadUInt(8) end, function(vendor, skin) vendor:setSkin(skin) end)
    addEditor("bodygroup", function() return net.ReadUInt(8), net.ReadUInt(8) end, function(vendor, index, value) vendor:setBodyGroup(index, value) end)
    addEditor("useMoney", function() return net.ReadBool() end, function(vendor, useMoney)
        if useMoney then
            vendor:setMoney(lia.config.get("vendorDefaultMoney", 500))
        else
            vendor:setMoney(nil)
        end
    end)

    addEditor("money", function() return net.ReadUInt(32) end, function(vendor, money) vendor:setMoney(money) end)
    addEditor("scale", function() return net.ReadFloat() end, function(vendor, scale) vendor:setSellScale(scale) end)
    addEditor("preset", function() return net.ReadString() end, function(vendor, preset) vendor:applyPreset(preset) end)
else
    local function addEditor(name, writer)
        lia.vendor.editor[name] = function(...)
            net.Start("VendorEdit")
            net.WriteString(name)
            writer(...)
            net.SendToServer()
        end
    end

    addEditor("name", function(name) net.WriteString(name) end)
    addEditor("mode", function(itemType, mode)
        net.WriteString(itemType)
        net.WriteInt(isnumber(mode) and mode or -1, 8)
    end)

    addEditor("price", function(itemType, price)
        net.WriteString(itemType)
        net.WriteInt(isnumber(price) and price or -1, 32)
    end)

    addEditor("stockDisable", function(itemType)
        net.WriteString(itemType)
        net.WriteUInt(0, 32)
    end)

    addEditor("stockMax", function(itemType, value)
        net.WriteString(itemType)
        net.WriteUInt(math.max(value or 1, 1), 32)
    end)

    addEditor("stock", function(itemType, value)
        net.WriteString(itemType)
        net.WriteUInt(value, 32)
    end)

    addEditor("flag", function(flag) net.WriteString(flag) end)
    addEditor("welcome", function(message) net.WriteString(message) end)
    addEditor("faction", function(factionID, allowed)
        net.WriteUInt(factionID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("class", function(classID, allowed)
        net.WriteUInt(classID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("model", function(model) net.WriteString(model) end)
    addEditor("skin", function(skin) net.WriteUInt(math.Clamp(skin or 0, 0, 255), 8) end)
    addEditor("bodygroup", function(index, value)
        net.WriteUInt(index, 8)
        net.WriteUInt(value or 0, 8)
    end)

    addEditor("useMoney", function(useMoney) net.WriteBool(useMoney) end)
    addEditor("money", function(value)
        local amt = isnumber(value) and math.max(math.Round(value), 0) or -1
        net.WriteInt(amt, 32)
    end)

    addEditor("scale", function(scale) net.WriteFloat(scale) end)
    addEditor("preset", function(preset) net.WriteString(preset) end)
end

function lia.vendor.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.vendor.rarities[name] = color
end

function lia.vendor.addPreset(name, items)
    assert(isstring(name), L("vendorPresetNameString"))
    assert(istable(items), L("vendorPresetItemsTable"))
    local validItems = {}
    for itemType, itemData in pairs(items) do
        if lia.item.list[itemType] then
            validItems[itemType] = itemData
        else
            print("[Vendor] Warning: Item '" .. itemType .. "' in preset '" .. name .. "' does not exist and will be skipped.")
        end
    end

    lia.vendor.presets[string.lower(name)] = validItems
end

function lia.vendor.getPreset(name)
    return lia.vendor.presets[string.lower(name)]
end