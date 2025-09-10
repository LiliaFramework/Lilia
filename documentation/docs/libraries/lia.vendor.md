# Vendor Library

This page documents the functions for working with vendors and trading systems.

---

## Overview

The vendor library (`lia.vendor`) provides a comprehensive system for managing vendors, trading, and item commerce in the Lilia framework. It includes vendor presets, rarities, editor functions, and database operations for vendor management.

---

### lia.vendor.addRarities

**Purpose**

Adds a rarity type with a specific color to the vendor system.

**Parameters**

* `name` (*string*): The name of the rarity.
* `color` (*Color*): The color associated with the rarity.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a rarity type
local function addRarity(name, color)
    lia.vendor.addRarities(name, color)
end

-- Use in a function
local function setupRarities()
    lia.vendor.addRarities("common", Color(255, 255, 255))
    lia.vendor.addRarities("uncommon", Color(0, 255, 0))
    lia.vendor.addRarities("rare", Color(0, 0, 255))
    lia.vendor.addRarities("epic", Color(128, 0, 128))
    lia.vendor.addRarities("legendary", Color(255, 165, 0))
end
```

---

### lia.vendor.addPreset

**Purpose**

Adds a vendor preset with predefined items and their configurations.

**Parameters**

* `name` (*string*): The name of the preset.
* `items` (*table*): Table of items and their configurations.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add a vendor preset
local function addPreset(name, items)
    lia.vendor.addPreset(name, items)
end

-- Use in a function
local function createWeaponVendorPreset()
    local items = {
        ["weapon_pistol"] = {
            price = 100,
            mode = 1,
            stock = 10,
            maxStock = 50
        },
        ["weapon_shotgun"] = {
            price = 500,
            mode = 1,
            stock = 5,
            maxStock = 20
        }
    }
    lia.vendor.addPreset("weapon_vendor", items)
end
```

---

### lia.vendor.getPreset

**Purpose**

Gets a vendor preset by name.

**Parameters**

* `name` (*string*): The name of the preset.

**Returns**

* `preset` (*table*): The preset data or nil.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a vendor preset
local function getPreset(name)
    return lia.vendor.getPreset(name)
end

-- Use in a function
local function loadVendorPreset(presetName)
    local preset = lia.vendor.getPreset(presetName)
    if preset then
        print("Preset loaded: " .. presetName)
        return preset
    else
        print("Preset not found: " .. presetName)
        return nil
    end
end
```

---

### lia.vendor.loadPresets

**Purpose**

Loads vendor presets from the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Load vendor presets
local function loadPresets()
    lia.vendor.loadPresets()
end

-- Use in a function
local function initializeVendorSystem()
    lia.vendor.loadPresets()
    print("Vendor presets loaded from database")
end
```

---

### lia.vendor.savePresetToDatabase

**Purpose**

Saves a vendor preset to the database.

**Parameters**

* `name` (*string*): The name of the preset.
* `data` (*table*): The preset data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save preset to database
local function savePresetToDatabase(name, data)
    lia.vendor.savePresetToDatabase(name, data)
end

-- Use in a function
local function createAndSavePreset(name, items)
    lia.vendor.addPreset(name, items)
    lia.vendor.savePresetToDatabase(name, items)
    print("Preset saved to database: " .. name)
end
```

---

### lia.vendor.editor

**Purpose**

Provides editor functions for vendor configuration.

**Parameters**

* `name` (*string*): The editor function name.

**Returns**

* `editorFunc` (*function*): The editor function.

**Realm**

Shared.

**Example Usage**

```lua
-- Use vendor editor
local function useEditor(name, ...)
    local editor = lia.vendor.editor[name]
    if editor then
        editor(...)
    end
end

-- Use in a function
local function editVendorName(vendor, newName)
    lia.vendor.editor["name"](newName)
end
```

---

### lia.vendor.presets

**Purpose**

Stores all vendor presets.

**Parameters**

*None*

**Returns**

* `presets` (*table*): Table of all presets.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all presets
local function getAllPresets()
    return lia.vendor.presets
end

-- Use in a function
local function listAllPresets()
    for name, preset in pairs(lia.vendor.presets) do
        print("Preset: " .. name)
    end
end
```

---

### lia.vendor.rarities

**Purpose**

Stores all vendor rarities.

**Parameters**

*None*

**Returns**

* `rarities` (*table*): Table of all rarities.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all rarities
local function getAllRarities()
    return lia.vendor.rarities
end

-- Use in a function
local function listAllRarities()
    for name, color in pairs(lia.vendor.rarities) do
        print("Rarity: " .. name .. " - " .. tostring(color))
    end
end
```