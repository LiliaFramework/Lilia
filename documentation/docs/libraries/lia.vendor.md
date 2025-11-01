# Vendor Library

NPC vendor management system with editing and rarity support for the Lilia framework.

---

Overview

The vendor library provides comprehensive functionality for managing NPC vendors in the Lilia framework. It handles vendor configuration, editing, presets, and rarity systems for items sold by vendors. The library operates on both server and client sides, with the server handling vendor data processing and the client managing the editing interface. It includes support for vendor presets, item rarities, stock management, pricing, faction/class restrictions, and visual customization. The library ensures that vendors can be easily configured and managed through both code and in-game editing tools.

---

### addRarities

**Purpose**

Adds a new item rarity type with an associated color to the vendor system

**When Called**

During initialization or when defining custom item rarities for vendors

**Parameters**

* `name` (*string*): The name of the rarity (e.g., "common", "rare", "legendary"), color (Color) - The color associated with this rarity

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add a basic rarity
lia.vendor.addRarities("common", Color(255, 255, 255))

```

**Medium Complexity:**
```lua
-- Medium: Add multiple rarities with custom colors
lia.vendor.addRarities("rare", Color(0, 255, 0))
lia.vendor.addRarities("epic", Color(128, 0, 255))

```

**High Complexity:**
```lua
-- High: Add rarities with validation and error handling
local rarities = {
    { name = "common", color = Color(200, 200, 200) },
    { name = "uncommon", color = Color(0, 255, 0) },
    { name = "rare", color = Color(0, 0, 255) },
    { name = "epic", color = Color(128, 0, 255) },
    { name = "legendary", color = Color(255, 165, 0) }
}
for _, rarity in ipairs(rarities) do
    lia.vendor.addRarities(rarity.name, rarity.color)
end

```

---

### addPreset

**Purpose**

Creates a vendor preset with predefined items and their configurations

**When Called**

During initialization or when defining vendor templates with specific item sets

**Parameters**

* `name` (*string*): The name of the preset, items (table) - Table containing item types as keys and their configuration as values

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add a basic weapon vendor preset
lia.vendor.addPreset("weapon_vendor", {
    ["weapon_pistol"] = { price = 100, stock = 5 },
    ["weapon_shotgun"] = { price = 250, stock = 2 }
})

```

**Medium Complexity:**
```lua
-- Medium: Add a medical vendor preset with various items
lia.vendor.addPreset("medical_vendor", {
    ["bandage"] = { price = 25, stock = 10, mode = 1 },
    ["medkit"] = { price = 100, stock = 3, mode = 1 },
    ["painkillers"] = { price = 50, stock = 8, mode = 1 }
})

```

**High Complexity:**
```lua
-- High: Add a comprehensive vendor preset with validation
local weaponPreset = {
    ["weapon_pistol"] = { price = 100, stock = 5, mode = 1 },
    ["weapon_shotgun"] = { price = 250, stock = 2, mode = 1 },
    ["weapon_rifle"] = { price = 500, stock = 1, mode = 1 },
    ["ammo_pistol"] = { price = 10, stock = 50, mode = 1 },
    ["ammo_shotgun"] = { price = 15, stock = 30, mode = 1 }
}
lia.vendor.addPreset("gun_dealer", weaponPreset)

```

---

### getPreset

**Purpose**

Retrieves a vendor preset by name for applying to vendors

**When Called**

When applying presets to vendors or checking if a preset exists

**Parameters**

* `name` (*string*): The name of the preset to retrieve

**Returns**

* table or nil - The preset data table if found, nil otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get a preset and apply it to a vendor
local preset = lia.vendor.getPreset("weapon_vendor")
if preset then
    vendor:applyPreset("weapon_vendor")
end

```

**Medium Complexity:**
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

**High Complexity:**
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

