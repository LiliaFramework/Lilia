lia.vendor = lia.vendor or {}
lia.vendor.stored = lia.vendor.stored or {}
lia.vendor.editor = lia.vendor.editor or {}
lia.vendor.presets = lia.vendor.presets or {}
lia.vendor.defaults = {
    name = L("vendorDefaultName"),
    desc = "",
    preset = "none",
    animation = "idle_all_01",
    stockEnabled = false,
    items = {},
    factions = {},
    classes = {},
    factionBuyScales = {},
    factionSellScales = {}
}

if SERVER then
    local function getTextValue(value)
        if value == nil or value == "" then return L("none") end
        return tostring(value)
    end

    local function getModeText(mode)
        if mode == VENDOR_SELLANDBUY then return L("buyOnlynSell") end
        if mode == VENDOR_BUYONLY then return L("buyOnly") end
        if mode == VENDOR_SELLONLY then return L("sellOnly") end
        return L("none")
    end

    local function getEnabledText(enabled)
        return enabled and L("enabled") or L("disabled")
    end

    local function getItemName(itemType)
        local itemTable = lia.item.list[itemType]
        return itemTable and itemTable.getName and itemTable:getName() or (itemTable and itemTable.name or itemType)
    end

    local function addEditor(name, reader, applier)
        lia.vendor.editor[name] = function(vendor, client)
            local args = {reader()}
            applier(vendor, client, unpack(args))
        end
    end

    addEditor("name", function() return net.ReadString() end, function(vendor, client, name)
        local oldName = vendor:getName()
        if not name or name == "" then name = lia.vendor.defaults.name or L("vendorDefaultName") end
        vendor:setName(name)
        client:notifyLocalized("vendorNameChanged", getTextValue(oldName), getTextValue(name))
    end)

    addEditor("desc", function() return net.ReadString() end, function(vendor, client, desc)
        local oldDesc = vendor:getDescription()
        vendor:setDescription(desc or "")
        client:notifyLocalized("vendorDescriptionChanged", getTextValue(oldDesc), getTextValue(desc))
    end)

    addEditor("mode", function() return net.ReadString(), net.ReadInt(8) end, function(vendor, client, itemType, mode)
        local itemName = getItemName(itemType)
        local oldMode = vendor:getTradeMode(itemType)
        vendor:setTradeMode(itemType, mode)
        client:notifyLocalized("vendorModeChanged", itemName, getModeText(oldMode), getModeText(mode))
    end)

    addEditor("buyPrice", function() return net.ReadString(), net.ReadInt(32) end, function(vendor, client, itemType, price)
        local itemName = getItemName(itemType)
        local oldPrice = vendor:getPrice(itemType, false, client)
        vendor:setItemBuyPrice(itemType, price)
        local newPrice = vendor:getPrice(itemType, false, client)
        client:notifyLocalized("vendorBuyPriceChanged", itemName, lia.currency.get(oldPrice), lia.currency.get(newPrice))
    end)

    addEditor("sellPrice", function() return net.ReadString(), net.ReadInt(32) end, function(vendor, client, itemType, price)
        local itemName = getItemName(itemType)
        local oldPrice = vendor:getPrice(itemType, true, client)
        vendor:setItemSellPrice(itemType, price)
        local newPrice = vendor:getPrice(itemType, true, client)
        client:notifyLocalized("vendorSellPriceChanged", itemName, lia.currency.get(oldPrice), lia.currency.get(newPrice))
    end)

    addEditor("stockDisable", function() return net.ReadString() end, function(vendor, client, itemType)
        local itemName = getItemName(itemType)
        local oldMax = vendor:getMaxStock(itemType)
        vendor:setMaxStock(itemType, nil)
        client:notifyLocalized("vendorStockDisabledChanged", itemName, oldMax or 0)
    end)

    addEditor("stockMax", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, client, itemType, value)
        local itemName = getItemName(itemType)
        local oldMax = vendor:getMaxStock(itemType) or 0
        vendor:setMaxStock(itemType, value)
        client:notifyLocalized("vendorStockMaxChanged", itemName, oldMax, value)
    end)

    addEditor("stock", function() return net.ReadString(), net.ReadUInt(32) end, function(vendor, client, itemType, value)
        local itemName = getItemName(itemType)
        local oldStock = vendor:getStock(itemType) or 0
        vendor:setStock(itemType, value)
        local newStock = vendor:getStock(itemType) or 0
        client:notifyLocalized("vendorStockCurrentChanged", itemName, oldStock, newStock)
    end)

    addEditor("stockEnabled", function() return net.ReadBool() end, function(vendor, client, enabled)
        local oldEnabled = lia.vendor.getVendorProperty(vendor, "stockEnabled")
        lia.vendor.setVendorProperty(vendor, "stockEnabled", enabled and true or false)
        client:notifyLocalized("vendorStockEnabledChanged", getEnabledText(oldEnabled), getEnabledText(enabled))
    end)

    addEditor("faction", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, client, factionID, allowed)
        local faction = lia.faction.indices[factionID]
        vendor:setFactionAllowed(factionID, allowed)
        client:notifyLocalized("vendorFactionChanged", faction and L(faction.name) or tostring(factionID), getEnabledText(allowed))
    end)

    addEditor("class", function() return net.ReadUInt(8), net.ReadBool() end, function(vendor, client, classID, allowed)
        local class = lia.class.list[classID]
        vendor:setClassAllowed(classID, allowed)
        client:notifyLocalized("vendorClassChanged", class and L(class.name) or tostring(classID), getEnabledText(allowed))
    end)

    addEditor("model", function() return net.ReadString() end, function(vendor, client, model)
        local oldModel = vendor:GetModel()
        vendor:setModel(model)
        client:notifyLocalized("vendorModelChanged", getTextValue(oldModel), getTextValue(model))
    end)

    addEditor("skin", function() return net.ReadUInt(8) end, function(vendor, client, skin)
        local oldSkin = vendor:GetSkin()
        vendor:setSkin(skin)
        client:notifyLocalized("vendorSkinChanged", oldSkin, skin)
    end)

    addEditor("bodygroup", function() return net.ReadUInt(8), net.ReadUInt(8) end, function(vendor, client, index, value)
        local oldValue = vendor:GetBodygroup(index)
        vendor:setBodyGroup(index, value)
        client:notifyLocalized("vendorBodygroupChanged", index, oldValue, value)
    end)

    addEditor("useMoney", function() return net.ReadBool() end, function(vendor, client, useMoney)
        local oldValue = vendor.getMoney and vendor:getMoney() ~= nil or false
        if useMoney then
            vendor:setMoney(lia.config.get("vendorDefaultMoney", 500))
        else
            vendor:setMoney(nil)
        end

        client:notifyLocalized("vendorUseMoneyChanged", getEnabledText(oldValue), getEnabledText(useMoney))
    end)

    addEditor("money", function() return net.ReadUInt(32) end, function(vendor, client, money)
        local oldMoney = vendor.getMoney and vendor:getMoney() or 0
        vendor:setMoney(money)
        client:notifyLocalized("vendorMoneyChanged", lia.currency.get(oldMoney), lia.currency.get(money))
    end)

    addEditor("preset", function() return net.ReadString() end, function(vendor, client, preset)
        local oldPreset = lia.vendor.getVendorProperty(vendor, "preset")
        vendor:applyPreset(preset)
        client:notifyLocalized("vendorPresetChanged", getTextValue(oldPreset), getTextValue(preset))
    end)

    addEditor("animation", function()
        local anim = net.ReadString()
        return anim
    end, function(vendor, client, animation)
        local oldAnimation = lia.vendor.getVendorProperty(vendor, "animation")
        vendor:setAnimation(animation)
        client:notifyLocalized("vendorAnimationChanged", getTextValue(oldAnimation), getTextValue(animation))
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
    addEditor("desc", function(desc) net.WriteString(desc or "") end)
    addEditor("mode", function(itemType, mode)
        net.WriteString(itemType)
        net.WriteInt(isnumber(mode) and mode or -1, 8)
    end)

    addEditor("buyPrice", function(itemType, price)
        net.WriteString(itemType)
        net.WriteInt(isnumber(price) and price or -1, 32)
    end)

    addEditor("sellPrice", function(itemType, price)
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

    addEditor("stockEnabled", function(enabled) net.WriteBool(enabled and true or false) end)
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
