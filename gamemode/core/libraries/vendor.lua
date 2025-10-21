--[[
    Vendor Library

    NPC vendor management system with editing and rarity support for the Lilia framework.
]]
--[[
    Overview:
    The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework.
    It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors.
    The library operates on both server and client sides, with the server handling vendor data processing
    and the client managing the editing interface. It includes support for vendor presets, item rarities,
    stock management, pricing, faction/class restrictions, and visual customization. The library ensures
    that vendors can be easily configured and managed through both code and in-game editing tools.
]]
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
    addEditor("animation", function()
        local anim = net.ReadString()
        return anim
    end, function(vendor, animation) vendor:setAnimation(animation) end)
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
    addEditor("animation", function(animation) net.WriteString(animation or "") end)
end

--[[
    Purpose: Adds a new item rarity type with an associated color to the vendor system
    When Called: During initialization or when defining custom item rarities for vendors
    Parameters: name (string) - The name of the rarity (e.g., "common", "rare", "legendary"), color (Color) - The color associated with this rarity
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Add a basic rarity
    lia.vendor.addRarities("common", Color(255, 255, 255))
    ```

    Medium Complexity:
    ```lua
    -- Medium: Add multiple rarities with custom colors
    lia.vendor.addRarities("rare", Color(0, 255, 0))
    lia.vendor.addRarities("epic", Color(128, 0, 255))
    ```

    High Complexity:
    ```lua
    -- High: Add rarities with validation and error handling
    local rarities = {
        {name = "common", color = Color(200, 200, 200)},
        {name = "uncommon", color = Color(0, 255, 0)},
        {name = "rare", color = Color(0, 0, 255)},
        {name = "epic", color = Color(128, 0, 255)},
        {name = "legendary", color = Color(255, 165, 0)}
    }

    for _, rarity in ipairs(rarities) do
        lia.vendor.addRarities(rarity.name, rarity.color)
    end
    ```
]]
function lia.vendor.addRarities(name, color)
    assert(isstring(name), L("vendorRarityNameString"))
    assert(IsColor(color), L("vendorColorMustBeColor"))
    lia.vendor.rarities[name] = color
end

--[[
    Purpose: Creates a vendor preset with predefined items and their configurations
    When Called: During initialization or when defining vendor templates with specific item sets
    Parameters: name (string) - The name of the preset, items (table) - Table containing item types as keys and their configuration as values
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Add a basic weapon vendor preset
    lia.vendor.addPreset("weapon_vendor", {
        ["weapon_pistol"] = {price = 100, stock = 5},
        ["weapon_shotgun"] = {price = 250, stock = 2}
    })
    ```

    Medium Complexity:
    ```lua
    -- Medium: Add a medical vendor preset with various items
    lia.vendor.addPreset("medical_vendor", {
        ["bandage"] = {price = 25, stock = 10, mode = 1},
        ["medkit"] = {price = 100, stock = 3, mode = 1},
        ["painkillers"] = {price = 50, stock = 8, mode = 1}
    })
    ```

    High Complexity:
    ```lua
    -- High: Add a comprehensive vendor preset with validation
    local weaponPreset = {
        ["weapon_pistol"] = {price = 100, stock = 5, mode = 1},
        ["weapon_shotgun"] = {price = 250, stock = 2, mode = 1},
        ["weapon_rifle"] = {price = 500, stock = 1, mode = 1},
        ["ammo_pistol"] = {price = 10, stock = 50, mode = 1},
        ["ammo_shotgun"] = {price = 15, stock = 30, mode = 1}
    }

    lia.vendor.addPreset("gun_dealer", weaponPreset)
    ```
]]
function lia.vendor.addPreset(name, items)
    assert(isstring(name), L("vendorPresetNameString"))
    assert(istable(items), L("vendorPresetItemsTable"))
    local validItems = {}
    for itemType, itemData in pairs(items) do
        if lia.item.list[itemType] then validItems[itemType] = itemData end
    end

    lia.vendor.presets[string.lower(name)] = validItems
end

--[[
    Purpose: Retrieves a vendor preset by name for applying to vendors
    When Called: When applying presets to vendors or checking if a preset exists
    Parameters: name (string) - The name of the preset to retrieve
    Returns: table or nil - The preset data table if found, nil otherwise
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get a preset and apply it to a vendor
    local preset = lia.vendor.getPreset("weapon_vendor")
    if preset then
        vendor:applyPreset("weapon_vendor")
    end
    ```

    Medium Complexity:
    ```lua
    -- Medium: Check if preset exists and validate items
    local presetName = "medical_vendor"
    local preset = lia.vendor.getPreset(presetName)
    if preset then
        print("Preset '" .. presetName .. "' found with " .. table.Count(preset) .. " items")
    else
        print("Preset '" .. presetName .. "' not found")
    end
    ```

    High Complexity:
    ```lua
    -- High: Get preset and dynamically configure vendor based on preset data
    local presetName = "gun_dealer"
    local preset = lia.vendor.getPreset(presetName)

    if preset then
        for itemType, itemData in pairs(preset) do
            vendor:setItemPrice(itemType, itemData.price)
            vendor:setStock(itemType, itemData.stock)
            if itemData.mode then
                vendor:setTradeMode(itemType, itemData.mode)
            end
        end
        vendor:setName("Gun Dealer")
    end
    ```
]]
function lia.vendor.getPreset(name)
    return lia.vendor.presets[string.lower(name)]
end
