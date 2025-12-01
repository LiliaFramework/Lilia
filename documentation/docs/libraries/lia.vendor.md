# Vendor Library

NPC vendor management system with editing and rarity support for the Lilia framework.

---

Overview

The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework. It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors. The library operates on both server and client sides, with the server handling vendor data processing and the client managing the editing interface. It includes support for vendor presets, item rarities, stock management, pricing, faction/class restrictions, and visual customization. The library ensures that vendors can be easily configured and managed through both code and in-game editing tools.

---

### lia.vendor.addRarities

#### 📋 Purpose
Adds a new item rarity type with an associated color to the vendor system

#### ⏰ When Called
During initialization or when defining custom item rarities for vendors

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name of the rarity (e.g., "common", "rare", "legendary") |
| `color` | **Color** | The color associated with this rarity |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a basic rarity
    lia.vendor.addRarities("common", Color(255, 255, 255))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add multiple rarities with custom colors
    lia.vendor.addRarities("rare", Color(0, 255, 0))
    lia.vendor.addRarities("epic", Color(128, 0, 255))

```

#### ⚙️ High Complexity
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

---

### lia.vendor.addPreset

#### 📋 Purpose
Creates a vendor preset with predefined items and their configurations

#### ⏰ When Called
During initialization or when defining vendor templates with specific item sets

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name of the preset |
| `items` | **table** | Table containing item types as keys and their configuration as values |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a basic weapon vendor preset
    lia.vendor.addPreset("weapon_vendor", {
        ["weapon_pistol"] = {price = 100, stock = 5},
        ["weapon_shotgun"] = {price = 250, stock = 2}
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add a medical vendor preset with various items
    lia.vendor.addPreset("medical_vendor", {
        ["bandage"]    = {price = 25, stock = 10, mode = 1},
        ["medkit"]     = {price = 100, stock = 3, mode = 1},
        ["painkillers"] = {price = 50, stock = 8, mode = 1}
    })

```

#### ⚙️ High Complexity
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

---

### lia.vendor.getPreset

#### 📋 Purpose
Retrieves a vendor preset by name for applying to vendors

#### ⏰ When Called
When applying presets to vendors or checking if a preset exists

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name of the preset to retrieve |

#### ↩️ Returns
* table or nil - The preset data table if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a preset and apply it to a vendor
    local preset = lia.vendor.getPreset("weapon_vendor")
    if preset then
        vendor:applyPreset("weapon_vendor")
    end

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.vendor.getVendorProperty

#### 📋 Purpose
Retrieves a vendor property value, either from cached storage or default values

#### ⏰ When Called
When accessing vendor properties such as name, animation, or other custom settings

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The vendor entity to get the property from |
| `property` | **string** | The name of the property to retrieve (e.g., "name", "animation") |

#### ↩️ Returns
* any - The property value if found, or the default value for the property

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a vendor's name
    local name = lia.vendor.getVendorProperty(vendor, "name")
    print("Vendor name:", name)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get multiple properties with fallbacks
    local name = lia.vendor.getVendorProperty(vendor, "name") or "Unknown Vendor"
    local animation = lia.vendor.getVendorProperty(vendor, "animation") or ""
    print(name .. " uses animation: " .. animation)

```

#### ⚙️ High Complexity
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

---

### lia.vendor.setVendorProperty

#### 📋 Purpose
Sets a vendor property value, storing it only if it differs from the default value

#### ⏰ When Called
When configuring vendor properties such as name, animation, or other custom settings

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The vendor entity to set the property on |
| `property` | **string** | The name of the property to set (e.g., "name", "animation") |
| `value` | **any** | The value to set for the property |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set a vendor's name
    lia.vendor.setVendorProperty(vendor, "name", "Bob's Weapons")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set multiple properties on a vendor
    lia.vendor.setVendorProperty(vendor, "name", "Medical Shop")
    lia.vendor.setVendorProperty(vendor, "animation", "idle")

```

#### ⚙️ High Complexity
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

---

### lia.vendor.syncVendorProperty

#### 📋 Purpose
Synchronizes a vendor property change from server to all connected clients

#### ⏰ When Called
Automatically called when vendor properties are modified on the server side

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The vendor entity whose property is being synchronized |
| `property` | **string** | The name of the property being synchronized |
| `value` | **any** | The new value of the property |
| `isDefault` | **boolean** | Whether the value is the default value (affects network transmission) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Sync a name change to clients
    lia.vendor.syncVendorProperty(vendor, "name", "New Vendor Name", false)

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

### lia.vendor.getAllVendorData

#### 📋 Purpose
Retrieves all vendor properties at once, returning both custom and default values

#### ⏰ When Called
When needing to access multiple vendor properties or save/serialize vendor data

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The vendor entity to get all properties from |

#### ↩️ Returns
* table - A table containing all vendor properties with their current values

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all vendor data for display
    local data = lia.vendor.getAllVendorData(vendor)
    print("Vendor name:", data.name)
    print("Animation:", data.animation)

```

#### 📊 Medium Complexity
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

#### ⚙️ High Complexity
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

---

