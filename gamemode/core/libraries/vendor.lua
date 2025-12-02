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
lia.vendor.rarities = lia.vendor.rarities or {}
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

--[[
    Purpose:
        Adds a new item rarity type with an associated color to the vendor system

    When Called:
        During initialization or when defining custom item rarities for vendors

    Parameters:
        name (string)
            The name of the rarity (e.g., "common", "rare", "legendary")
        color (Color)
            The color associated with this rarity

    Returns:
        nil

    Realm:
        Shared

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
    Purpose:
        Creates a vendor preset with predefined items and their configurations

    When Called:
        During initialization or when defining vendor templates with specific item sets

    Parameters:
        name (string)
            The name of the preset
        items (table)
            Table containing item types as keys and their configuration as values

    Returns:
        nil

    Realm:
        Shared

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
            ["bandage"]    = {price = 25, stock = 10, mode = 1},
            ["medkit"]     = {price = 100, stock = 3, mode = 1},
            ["painkillers"] = {price = 50, stock = 8, mode = 1}
        })
        ```

    High Complexity:
        ```lua
        -- High: Add a comprehensive vendor preset with validation
        local weaponPreset = {
            ["weapon_pistol"]  = {price = 100, stock = 5, mode = 1},
            ["weapon_shotgun"] = {price = 250, stock = 2, mode = 1},
            ["weapon_rifle"]   = {price = 500, stock = 1, mode = 1},
            ["ammo_pistol"]    = {price = 10, stock = 50, mode = 1},
            ["ammo_shotgun"]   = {price = 15, stock = 30, mode = 1}
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
    Purpose:
        Retrieves a vendor preset by name for applying to vendors

    When Called:
        When applying presets to vendors or checking if a preset exists

    Parameters:
        name (string)
            The name of the preset to retrieve

    Returns:
        table or nil - The preset data table if found, nil otherwise

    Realm:
        Shared

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

--[[
    Purpose:
        Retrieves a vendor property value, either from cached storage or default values

    When Called:
        When accessing vendor properties such as name, animation, or other custom settings

    Parameters:
        entity (Entity)
            The vendor entity to get the property from
        property (string)
            The name of the property to retrieve (e.g., "name", "animation")

    Returns:
        any - The property value if found, or the default value for the property

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a vendor's name
        local name = lia.vendor.getVendorProperty(vendor, "name")
        print("Vendor name:", name)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get multiple properties with fallbacks
        local name = lia.vendor.getVendorProperty(vendor, "name") or "Unknown Vendor"
        local animation = lia.vendor.getVendorProperty(vendor, "animation") or ""
        print(name .. " uses animation: " .. animation)
        ```

    High Complexity:
        ```lua
        -- High: Build vendor info dynamically based on properties
        local properties = {"name", "animation", "preset"}
        local vendorInfo = {}

        for _, prop in ipairs(properties) do
            vendorInfo[prop] = lia.vendor.getVendorProperty(vendor, prop)
        end

        if vendorInfo.name and vendorInfo.name ~= "" then
            print("Vendor '" .. vendorInfo.name .. "' configured successfully")
        end
        ```
]]
function lia.vendor.getVendorProperty(entity, property)
    if not IsValid(entity) then return lia.vendor.defaults[property] end
    local cached = lia.vendor.stored[entity]
    if cached and cached[property] ~= nil then return cached[property] end
    return lia.vendor.defaults[property]
end

--[[
    Purpose:
        Sets a vendor property value, storing it only if it differs from the default value

    When Called:
        When configuring vendor properties such as name, animation, or other custom settings

    Parameters:
        entity (Entity)
            The vendor entity to set the property on
        property (string)
            The name of the property to set (e.g., "name", "animation")
        value (any)
            The value to set for the property

    Returns:
        nil

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set a vendor's name
        lia.vendor.setVendorProperty(vendor, "name", "Bob's Weapons")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set multiple properties on a vendor
        lia.vendor.setVendorProperty(vendor, "name", "Medical Shop")
        lia.vendor.setVendorProperty(vendor, "animation", "idle")
        ```

    High Complexity:
        ```lua
        -- High: Configure vendor with validation and error handling
        local vendorConfigs = {
            {property = "name", value = "Armory"},
            {property = "animation", value = "alert"},
            {property = "preset", value = "weapon_vendor"}
        }

        for _, config in ipairs(vendorConfigs) do
            if config.value and config.value ~= "" then
                lia.vendor.setVendorProperty(vendor, config.property, config.value)
                print("Set " .. config.property .. " to " .. tostring(config.value))
            else
                print("Skipped empty value for " .. config.property)
            end
        end
        ```
]]
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

--[[
    Purpose:
        Synchronizes a vendor property change from server to all connected clients

    When Called:
        Automatically called when vendor properties are modified on the server side

    Parameters:
        entity (Entity)
            The vendor entity whose property is being synchronized
        property (string)
            The name of the property being synchronized
        value (any)
            The new value of the property
        isDefault (boolean)
            Whether the value is the default value (affects network transmission)

    Returns:
        nil

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Sync a name change to clients
        lia.vendor.syncVendorProperty(vendor, "name", "New Vendor Name", false)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Sync multiple properties after batch changes
        local changes = {
            {property = "name", value = "Shop", isDefault = false},
            {property = "animation", value = "idle", isDefault = false}
        }

        for _, change in ipairs(changes) do
            lia.vendor.syncVendorProperty(vendor, change.property, change.value, change.isDefault)
        end
        ```

    High Complexity:
        ```lua
        -- High: Sync property with validation and logging
        local function syncPropertyWithValidation(vendor, property, value)
            if not IsValid(vendor) then
                print("Invalid vendor entity")
                return false
            end

            local defaultValue = lia.vendor.defaults[property]
            local isDefault = (istable(defaultValue) and table.IsEmpty(value)) or (value == defaultValue)

            lia.vendor.syncVendorProperty(vendor, property, value, isDefault)
            print("Synchronized property '" .. property .. "' for vendor " .. vendor:EntIndex())
            return true
        end
        ```
]]
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

--[[
    Purpose:
        Retrieves all vendor properties at once, returning both custom and default values

    When Called:
        When needing to access multiple vendor properties or save/serialize vendor data

    Parameters:
        entity (Entity)
            The vendor entity to get all properties from

    Returns:
        table - A table containing all vendor properties with their current values

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get all vendor data for display
        local data = lia.vendor.getAllVendorData(vendor)
        print("Vendor name:", data.name)
        print("Animation:", data.animation)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check if vendor has custom settings
        local data = lia.vendor.getAllVendorData(vendor)
        local defaults = lia.vendor.defaults
        local hasCustomSettings = false

        for property, value in pairs(data) do
            if value ~= defaults[property] then
                hasCustomSettings = true
                print("Custom " .. property .. ": " .. tostring(value))
            end
        end

        if not hasCustomSettings then
            print("Vendor uses all default settings")
        end
        ```

    High Complexity:
        ```lua
        -- High: Serialize vendor data for persistence
        local function serializeVendor(vendor)
            local data = lia.vendor.getAllVendorData(vendor)
            local serialized = {}

            -- Only save non-default values and essential data
            for property, value in pairs(data) do
                if property == "name" or property == "animation" or
                   (value ~= lia.vendor.defaults[property] and property ~= "preset") then
                    serialized[property] = value
                end
            end

            -- Add entity-specific data
            serialized.items = vendor.items or {}
            serialized.factions = vendor.factions or {}
            serialized.classes = vendor.classes or {}

            return util.TableToJSON(serialized)
        end

        local jsonData = serializeVendor(vendor)
        file.Write("vendor_backup.json", jsonData)
        ```
]]
function lia.vendor.getAllVendorData(entity)
    if not IsValid(entity) then return {} end
    local data = {}
    for property, _ in pairs(lia.vendor.defaults) do
        data[property] = lia.vendor.getVendorProperty(entity, property)
    end
    return data
end
