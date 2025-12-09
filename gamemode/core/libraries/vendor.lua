--[[
    Vendor Library

    NPC vendor management system with editing and rarity support for the Lilia framework.
]]
--[[
    Overview:
        The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework. It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors. The library operates on both server and client sides, with the server handling vendor data processing and the client managing the editing interface. It includes support for vendor presets, item rarities, stock management, pricing, faction/class restrictions, and visual customization. The library ensures that vendors can be easily configured and managed through both code and in-game editing tools.
]]
lia.vendor = lia.vendor or {}
lia.vendor.stored = lia.vendor.stored or {}
lia.vendor.editor = lia.vendor.editor or {}
lia.vendor.presets = lia.vendor.presets or {}
lia.vendor.defaults = {
    name = L("vendorDefaultName"),
    preset = "none",
    animation = "",
    items = {},
    factions = {},
    classes = {},
    factionBuyScales = {},
    factionSellScales = {}
}

if SERVER then
    local function addEditor(name, reader, applier)
        lia.vendor.editor[name] = function(vendor, client)
            local args = {reader()}
            applier(vendor, client, unpack(args))
        end
    end

    addEditor("name", function() return net.ReadString() end, function(vendor, client, name)
        if not name or name == "" then name = lia.vendor.defaults.name or "Jane Doe" end
        vendor:setName(name)
        client:notifyLocalized("vendorNameChanged")
    end)

    addEditor("mode", function() return net.ReadString(), net.ReadInt(8) end, function(vendor, _, itemType, mode) vendor:setTradeMode(itemType, mode) end)
    addEditor("price", function() return net.ReadString(), net.ReadInt(32) end, function(vendor, _, itemType, price) vendor:setItemPrice(itemType, price) end)
    addEditor("stockDisable", function() return net.ReadString() end, function(vendor, _, itemType) vendor:setMaxStock(itemType, nil) end)
    addEditor("stockMax", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, _, itemType, value) vendor:setMaxStock(itemType, value) end)
    addEditor("stock", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, _, itemType, value) vendor:setStock(itemType, value) end)
    addEditor("faction", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, _, factionID, allowed) vendor:setFactionAllowed(factionID, allowed) end)
    addEditor("class", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, _, classID, allowed) vendor:setClassAllowed(classID, allowed) end)
    addEditor("factionBuyScale", function() return net.ReadUInt(8), net.ReadFloat() end, function(vendor, _, factionID, scale) vendor:setFactionBuyScale(factionID, scale) end)
    addEditor("factionSellScale", function() return net.ReadUInt(8), net.ReadFloat() end, function(vendor, _, factionID, scale) vendor:setFactionSellScale(factionID, scale) end)
    addEditor("model", function() return net.ReadString() end, function(vendor, client, model)
        vendor:setModel(model)
        client:notifyLocalized("vendorModelChanged")
    end)

    addEditor("skin", function() return net.ReadUInt(8) end, function(vendor, client, skin)
        vendor:setSkin(skin)
        client:notifyLocalized("vendorSkinChanged")
    end)

    addEditor("bodygroup", function() return net.ReadUInt(8), net.ReadUInt(8) end, function(vendor, client, index, value)
        vendor:setBodyGroup(index, value)
        client:notifyLocalized("vendorBodygroupChanged")
    end)

    addEditor("useMoney", function() return net.ReadBool() end, function(vendor, _, useMoney)
        if useMoney then
            vendor:setMoney(lia.config.get("vendorDefaultMoney", 500))
        else
            vendor:setMoney(nil)
        end
    end)

    addEditor("money", function() return net.ReadUInt(32) end, function(vendor, _, money) vendor:setMoney(money) end)
    addEditor("scale", function() return net.ReadFloat() end, function(vendor, _, scale) vendor:setSellScale(scale) end)
    addEditor("preset", function() return net.ReadString() end, function(vendor, _, preset) vendor:applyPreset(preset) end)
    addEditor("animation", function()
        local anim = net.ReadString()
        return anim
    end, function(vendor, client, animation)
        vendor:setAnimation(animation)
        client:notifyLocalized("vendorAnimationChanged")
    end)
else
    local function addEditor(name, writer)
        lia.vendor.editor[name] = function(...)
            net.Start("liaVendorEdit")
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

    addEditor("faction", function(factionID, allowed)
        net.WriteUInt(factionID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("class", function(classID, allowed)
        net.WriteUInt(classID, 8)
        net.WriteBool(allowed)
    end)

    addEditor("factionBuyScale", function(factionID, scale)
        net.WriteUInt(factionID, 8)
        net.WriteFloat(scale)
    end)

    addEditor("factionSellScale", function(factionID, scale)
        net.WriteUInt(factionID, 8)
        net.WriteFloat(scale)
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
    addEditor("animation", function(animation) net.WriteString(animation or "") end)
end

function lia.vendor.addPreset(name, items)
    assert(isstring(name), L("vendorPresetNameString"))
    assert(istable(items), L("vendorPresetItemsTable"))
    local validItems = {}
    for itemType, itemData in pairs(items) do
        if lia.item.list[itemType] then validItems[itemType] = itemData end
    end

    lia.vendor.presets[string.lower(name)] = validItems
end

function lia.vendor.getPreset(name)
    return lia.vendor.presets[string.lower(name)]
end

function lia.vendor.getVendorProperty(entity, property)
    if not IsValid(entity) then return lia.vendor.defaults[property] end
    local cached = lia.vendor.stored[entity]
    if cached and cached[property] ~= nil then return cached[property] end
    return lia.vendor.defaults[property]
end

function lia.vendor.setVendorProperty(entity, property, value)
    if not IsValid(entity) then return end
    local defaultValue = lia.vendor.defaults[property]
    local isDefault
    if istable(defaultValue) then
        isDefault = table.IsEmpty(value) or (table.Count(value) == 0)
    else
        isDefault = value == defaultValue
    end

    if not lia.vendor.stored[entity] then lia.vendor.stored[entity] = {} end
    if isDefault then
        lia.vendor.stored[entity][property] = nil
        if table.IsEmpty(lia.vendor.stored[entity]) then lia.vendor.stored[entity] = nil end
    else
        lia.vendor.stored[entity][property] = value
    end

    if SERVER then lia.vendor.syncVendorProperty(entity, property, value, isDefault) end
end

function lia.vendor.syncVendorProperty(entity, property, value, isDefault)
    if not SERVER then return end
    net.Start("liaVendorPropertySync")
    net.WriteEntity(entity)
    net.WriteString(property)
    if isDefault then
        net.WriteBool(true)
    else
        net.WriteBool(false)
        net.WriteTable({value})
    end

    net.Broadcast()
end

function lia.vendor.getAllVendorData(entity)
    if not IsValid(entity) then return {} end
    local data = {}
    for property, _ in pairs(lia.vendor.defaults) do
        data[property] = lia.vendor.getVendorProperty(entity, property)
    end
    return data
end
