# Item Library

Comprehensive item registration, instantiation, and management system for the Lilia framework.

---

Overview

The item library provides comprehensive functionality for managing items in the Lilia framework. It handles item registration, instantiation, inventory management, and item operations such as dropping, taking, rotating, and transferring items between players. The library operates on both server and client sides, with server-side functions handling database operations, item spawning, and data persistence, while client-side functions manage item interactions and UI operations. It includes automatic weapon and ammunition generation from Garry's Mod weapon lists, inventory type registration, and item entity management. The library ensures proper item lifecycle management from creation to deletion, with support for custom item functions, hooks, and data persistence.

---

### lia.item.get

#### 📋 Purpose
Retrieves an item definition by its unique identifier from either base items or registered items

#### ⏰ When Called
When you need to get an item definition for registration, instantiation, or reference

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | The unique identifier of the item to retrieve |

#### ↩️ Returns
* table - The item definition table, or nil if not found

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a basic item definition
    local itemDef = lia.item.get("base_weapons")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get item definition with validation
    local itemDef = lia.item.get("weapon_pistol")
    if itemDef then
        print("Found item:", itemDef.name)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get item definition and check inheritance
    local itemDef = lia.item.get("custom_rifle")
    if itemDef and itemDef.base == "base_weapons" then
        local baseDef = lia.item.get(itemDef.base)
        print("Item inherits from:", baseDef.name)
    end

```

---

### lia.item.getItemByID

#### 📋 Purpose
Retrieves an item instance by its ID along with location information

#### ⏰ When Called
When you need to find an item instance and know where it's located (inventory or world)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the item instance |

#### ↩️ Returns
* table - Contains 'item' (the item instance) and 'location' (string: "inventory", "world", or "unknown"), or nil, error message

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get item with location
    local result = lia.item.getItemByID(123)
    if result then
        print("Item location:", result.location)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get item and handle different locations
    local result = lia.item.getItemByID(456)
    if result then
        if result.location == "inventory" then
            print("Item is in inventory")
        elseif result.location == "world" then
            print("Item is in world")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get item and perform location-specific actions
    local result = lia.item.getItemByID(789)
    if result then
        local item = result.item
        if result.location == "inventory" then
            local inv = lia.item.getInv(item.invID)
            if inv then
                print("Item in inventory:", inv:getName())
            end
        elseif result.location == "world" and IsValid(item.entity) then
            print("Item entity position:", item.entity:GetPos())
        end
    end

```

---

### lia.item.getInstancedItemByID

#### 📋 Purpose
Retrieves an item instance by its ID without location information

#### ⏰ When Called
When you only need the item instance and don't care about its location

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the item instance |

#### ↩️ Returns
* table - The item instance, or nil, error message

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get item instance
    local item = lia.item.getInstancedItemByID(123)
    if item then
        print("Item name:", item.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get item and access properties
    local item = lia.item.getInstancedItemByID(456)
    if item then
        print("Item ID:", item.id)
        print("Item uniqueID:", item.uniqueID)
        print("Item quantity:", item.quantity)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get item and perform operations
    local item = lia.item.getInstancedItemByID(789)
    if item then
        if item.player and IsValid(item.player) then
            local char = item.player:getChar()
            if char then
                print("Item owner:", char:getName())
            end
        end
        if item:getData("customProperty") then
            print("Custom property:", item:getData("customProperty"))
        end
    end

```

---

### lia.item.getItemDataByID

#### 📋 Purpose
Retrieves the data table of an item instance by its ID

#### ⏰ When Called
When you need to access the custom data stored in an item instance

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the item instance |

#### ↩️ Returns
* table - The item's data table, or nil, error message

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get item data
    local data = lia.item.getItemDataByID(123)
    if data then
        print("Item has data")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get item data and access specific fields
    local data = lia.item.getItemDataByID(456)
    if data then
        if data.x and data.y then
            print("Item position:", data.x, data.y)
        end
        if data.rotated then
            print("Item is rotated")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get item data and perform complex operations
    local data = lia.item.getItemDataByID(789)
    if data then
        local customData = data.customData or {}
        for key, value in pairs(customData) do
            if istable(value) then
                print("Complex data for", key, ":", util.TableToJSON(value))
            else
                print("Simple data for", key, ":", value)
            end
        end
        if data.lastUsed then
            local timeDiff = os.time() - data.lastUsed
            print("Item last used", timeDiff, "seconds ago")
        end
    end

```

---

### lia.item.load

#### 📋 Purpose
Loads an item definition from a file path and registers it

#### ⏰ When Called
During item loading process, typically called by lia.item.loadFromDir

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | The file path to the item definition |
| `baseID` | **string, optional** | Base item to inherit from |
| `isBaseItem` | **boolean, optional** | Whether this is a base item |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load a basic item file
    lia.item.load("lilia/gamemode/items/weapon_pistol.lua")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load item with base inheritance
    lia.item.load("lilia/gamemode/items/custom_rifle.lua", "base_weapons")

```

#### ⚙️ High Complexity
```lua
    -- High: Load base item and derived items
    lia.item.load("lilia/gamemode/items/base/weapons.lua", nil, true)
    lia.item.load("lilia/gamemode/items/weapons/assault_rifle.lua", "base_weapons")

```

---

### lia.item.isItem

#### 📋 Purpose
Checks if an object is a valid item instance

#### ⏰ When Called
When you need to validate that an object is an item before performing operations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `object` | **any** | The object to check |

#### ↩️ Returns
* boolean - True if the object is an item, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if object is an item
    if lia.item.isItem(someObject) then
        print("This is an item!")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Validate item before operations
    local function processItem(item)
        if not lia.item.isItem(item) then
            print("Invalid item provided")
            return false
        end
        print("Processing item:", item.name)
        return true
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Check multiple objects and filter items
    local function filterItems(objects)
        local items = {}
        for _, obj in ipairs(objects) do
            if lia.item.isItem(obj) then
                table.insert(items, obj)
            end
        end
        return items
    end

```

---

### lia.item.getInv

#### 📋 Purpose
Retrieves an inventory instance by its ID

#### ⏰ When Called
When you need to access an inventory instance for item operations

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invID` | **number** | The unique ID of the inventory |

#### ↩️ Returns
* table - The inventory instance, or nil if not found

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get inventory by ID
    local inv = lia.item.getInv(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get inventory and check if valid
    local inv = lia.item.getInv(456)
    if inv then
        print("Inventory size:", inv:getWidth(), "x", inv:getHeight())
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Get inventory and perform operations
    local inv = lia.item.getInv(789)
    if inv then
        local items = inv:getItems()
        for _, item in pairs(items) do
            print("Item in inventory:", item.name)
        end
    end

```

---

### lia.item.register

#### 📋 Purpose
Registers a new item definition with the item system

#### ⏰ When Called
During item loading or when creating custom items programmatically

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the item |
| `baseID` | **string, optional** | Base item to inherit from |
| `isBaseItem` | **boolean, optional** | Whether this is a base item |
| `path` | **string, optional** | File path for loading |
| `luaGenerated` | **boolean, optional** | Whether this is generated from Lua code |

#### ↩️ Returns
* table - The registered item definition

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic item
    lia.item.register("my_item", "base_stackable")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register item with custom properties
    local ITEM = lia.item.register("custom_weapon", "base_weapons")
    ITEM.name = "Custom Weapon"
    ITEM.desc = "A custom weapon"
    ITEM.model = "models/weapons/w_pistol.mdl"

```

#### ⚙️ High Complexity
```lua
    -- High: Register complex item with inheritance
    local ITEM = lia.item.register("advanced_rifle", "base_weapons", false, nil, true)
    ITEM.name = "Advanced Rifle"
    ITEM.desc = "A high-tech assault rifle"
    ITEM.model = "models/weapons/w_rif_ak47.mdl"
    ITEM.width = 3
    ITEM.height = 1
    ITEM.category = "weapons"
    ITEM.functions = table.Copy(ITEM.functions)
    ITEM.functions.customAction = {
        name   = "Custom Action",
        onRun  = function(item) print("Custom action executed") end
    }

```

---

### lia.item.overrideItem

#### 📋 Purpose
Overrides functions or properties of an existing item definition

#### ⏰ When Called
When you need to modify an existing item's behavior without modifying core files

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier of the item to override |
| `overrides` | **table** | Table containing function/property overrides |

#### ↩️ Returns
* table - The item definition with overrides applied

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.item.overrideItem("base_weapons", {
        paintOver = function(item, w, h)
            surface.DrawRect(0, 0, w, h)
        end
    })

```

#### 📊 Medium Complexity
```lua
    lia.item.overrideItem("base_weapons", {
        paintOver = function(item, w, h)
            if item:getData("equip") then
                surface.SetDrawColor(110, 255, 110, 100)
                surface.DrawRect(w - 14, h - 14, 8, 8)
            end
        end,
        getDesc = function(item)
            return item:getData("desc") or item.desc
        end
    })

```

#### ⚙️ High Complexity
```lua
    lia.item.overrideItem("base_weapons", {
        paintOver = function(item, w, h)
            -- Custom rendering logic
        end,
        getDesc = function(item)
            -- Custom description logic
        end,
        functions = {
            customAction = {
                name = "Custom Action",
                onRun = function(item)
                    -- Custom action logic
                end
            }
        }
    })

```

---

### lia.item.loadFromDir

#### 📋 Purpose
Loads all item definitions from a directory structure

#### ⏰ When Called
During gamemode initialization to load all items from the items directory

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | The directory path to load items from |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load items from default directory
    lia.item.loadFromDir("lilia/gamemode/items")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load items from custom directory
    lia.item.loadFromDir("addons/myaddon/items")

```

#### ⚙️ High Complexity
```lua
    -- High: Load items from multiple directories
    local itemDirs = {
        "lilia/gamemode/items",
        "addons/customitems/items",
        "gamemodes/mygamemode/items"
    }
    for _, dir in ipairs(itemDirs) do
        if file.Exists(dir, "LUA") then
            lia.item.loadFromDir(dir)
        end
    end

```

---

### lia.item.new

#### 📋 Purpose
Creates a new item instance from an item definition

#### ⏰ When Called
When you need to create a specific instance of an item with a unique ID

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier of the item definition |
| `id` | **number** | The unique ID for this item instance |

#### ↩️ Returns
* table - The new item instance, or error if item definition not found

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a new item instance
    local item = lia.item.new("weapon_pistol", 123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create item with validation
    local item = lia.item.new("custom_rifle", 456)
    if item then
        print("Created item:", item.name)
        print("Item ID:", item.id)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create item and set up initial data
    local item = lia.item.new("stackable_item", 789)
    if item then
        item.data.customProperty = "initial_value"
        item.data.createdBy      = "system"
        item.data.createdAt      = os.time()
        print("Item created with custom data")
    end

```

---

### lia.item.registerInv

#### 📋 Purpose
Registers a new inventory type with specified dimensions

#### ⏰ When Called
During initialization to register custom inventory types

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invType` | **string** | The inventory type identifier |
| `w` | **number** | Width of the inventory |
| `h` | **number** | Height of the inventory |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic inventory type
    lia.item.registerInv("player", 5, 4)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register inventory with custom properties
    lia.item.registerInv("storage_box", 8, 6)

```

#### ⚙️ High Complexity
```lua
    -- High: Register multiple inventory types
    local inventoryTypes = {
        {type = "player", w = 5, h = 4},
        {type = "storage", w = 10, h = 8},
        {type = "vehicle", w = 6, h = 3}
    }
    for _, inv in ipairs(inventoryTypes) do
        lia.item.registerInv(inv.type, inv.w, inv.h)
    end

```

---

### lia.item.newInv

#### 📋 Purpose
Creates a new inventory instance for a specific owner

#### ⏰ When Called
When you need to create a new inventory instance for a player or entity

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `owner` | **number** | The character ID of the owner |
| `invType` | **string** | The inventory type |
| `callback` | **function, optional** | Function to call when inventory is created |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create inventory for player
    lia.item.newInv(player:getChar():getID(), "player")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create inventory with callback
    lia.item.newInv(charID, "storage", function(inv)
        print("Inventory created:", inv.id)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Create inventory and populate with items
    lia.item.newInv(charID, "player", function(inv)
        -- Add starting items
        lia.item.instance(inv.id, "weapon_pistol", {}, 1, 1)
        lia.item.instance(inv.id, "ammo_pistol", {}, 2, 1)
        print("Player inventory created and populated")
    end)

```

---

### lia.item.createInv

#### 📋 Purpose
Creates a new inventory instance with specified dimensions and ID

#### ⏰ When Called
When you need to create a custom inventory with specific dimensions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `w` | **number** | Width of the inventory |
| `h` | **number** | Height of the inventory |
| `id` | **number** | The ID for the inventory |

#### ↩️ Returns
* table - The created inventory instance

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create basic inventory
    local inv = lia.item.createInv(5, 4, 123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create inventory and validate
    local inv = lia.item.createInv(8, 6, 456)
    if inv then
        print("Created inventory:", inv.id)
        print("Size:", inv:getWidth(), "x", inv:getHeight())
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create inventory and set up data
    local inv = lia.item.createInv(10, 8, 789)
    if inv then
        inv:setData("name", "Custom Storage")
        inv:setData("owner", "system")
        inv:setData("createdAt", os.time())
        print("Custom inventory created with metadata")
    end

```

---

### lia.item.addWeaponOverride

#### 📋 Purpose
Adds override data for a specific weapon class during automatic weapon generation

#### ⏰ When Called
Before calling lia.item.generateWeapons to customize weapon properties

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `className` | **string** | The weapon class name |
| `data` | **table** | Override data containing name, desc, model, etc. |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Override weapon name
    lia.item.addWeaponOverride("weapon_pistol", {
        name = "Custom Pistol"
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Override multiple weapon properties
    lia.item.addWeaponOverride("weapon_ak47", {
        name     = "AK-47 Assault Rifle",
        desc     = "A powerful assault rifle",
        model    = "models/weapons/w_rif_ak47.mdl",
        category = "assault_rifles"
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Override multiple weapons with custom properties
    local weaponOverrides = {
        ["weapon_pistol"] = {
            name          = "Combat Pistol",
            desc          = "A reliable sidearm",
            model         = "models/weapons/w_pistol.mdl",
            width         = 1,
            height        = 1,
            weaponCategory = "sidearm"
        },
        ["weapon_ak47"] = {
            name          = "AK-47",
            desc          = "Soviet assault rifle",
            model         = "models/weapons/w_rif_ak47.mdl",
            width         = 3,
            height        = 1,
            weaponCategory = "primary"
        }
    }
    for className, data in pairs(weaponOverrides) do
        lia.item.addWeaponOverride(className, data)
    end

```

---

### lia.item.addWeaponToBlacklist

#### 📋 Purpose
Adds a weapon class to the blacklist to prevent it from being automatically generated

#### ⏰ When Called
Before calling lia.item.generateWeapons to exclude specific weapons

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `className` | **string** | The weapon class name to blacklist |

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Blacklist a single weapon
    lia.item.addWeaponToBlacklist("weapon_crowbar")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Blacklist multiple weapons
    lia.item.addWeaponToBlacklist("weapon_crowbar")
    lia.item.addWeaponToBlacklist("weapon_physcannon")
    lia.item.addWeaponToBlacklist("weapon_physgun")

```

#### ⚙️ High Complexity
```lua
    -- High: Blacklist weapons based on conditions
    local weaponsToBlacklist = {
        "weapon_crowbar",
        "weapon_physcannon",
        "weapon_physgun",
        "weapon_tool",
        "weapon_camera"
    }
    for _, weaponClass in ipairs(weaponsToBlacklist) do
        lia.item.addWeaponToBlacklist(weaponClass)
    end

```

---

### lia.item.generateWeapons

#### 📋 Purpose
Automatically generates item definitions for all weapons in Garry's Mod

#### ⏰ When Called
During gamemode initialization or when weapons need to be regenerated

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Generate all weapons
    lia.item.generateWeapons()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Generate weapons with custom overrides
    lia.item.addWeaponOverride("weapon_pistol", {
        name = "Custom Pistol",
        desc = "A modified pistol"
    })
    lia.item.generateWeapons()

```

#### ⚙️ High Complexity
```lua
    -- High: Generate weapons with blacklist and overrides
    local blacklistedWeapons = {
        "weapon_crowbar",
        "weapon_physcannon",
        "weapon_physgun"
    }
    for _, weapon in ipairs(blacklistedWeapons) do
        lia.item.addWeaponToBlacklist(weapon)
    end
    local weaponOverrides = {
        ["weapon_pistol"] = {name = "Combat Pistol"},
        ["weapon_ak47"]   = {name = "AK-47", width = 3}
    }
    for className, data in pairs(weaponOverrides) do
        lia.item.addWeaponOverride(className, data)
    end
    lia.item.generateWeapons()

```

---

### lia.item.generateAmmo

#### 📋 Purpose
Automatically generates item definitions for ammunition entities (ARC9 and ARCCW)

#### ⏰ When Called
During gamemode initialization or when ammunition items need to be regenerated

#### ↩️ Returns
* void

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Generate all ammunition items
    lia.item.generateAmmo()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Generate ammunition with custom overrides
    lia.item.addWeaponOverride("arc9_ammo_9mm", {
        name = "9mm Ammunition",
        desc = "Standard pistol ammunition"
    })
    lia.item.generateAmmo()

```

#### ⚙️ High Complexity
```lua
    -- High: Generate ammunition with filtering and overrides
    local ammoOverrides = {
        ["arc9_ammo_9mm"] = {
            name   = "9mm Rounds",
            desc   = "Standard pistol ammunition",
            width  = 2,
            height = 1
        },
        ["arccw_ammo_rifle"] = {
            name   = "Rifle Ammunition",
            desc   = "High-powered rifle rounds",
            width  = 3,
            height = 1
        }
    }
    for className, data in pairs(ammoOverrides) do
        lia.item.addWeaponOverride(className, data)
    end
    lia.item.generateAmmo()

```

---

### lia.item.setItemDataByID

#### 📋 Purpose
Sets data for an item instance by its ID on the server

#### ⏰ When Called
When you need to modify item data from server-side code

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the item instance |
| `key` | **string** | The data key to set |
| `value` | **any** | The value to set |
| `receivers` | **table, optional** | Players to sync to |
| `noSave` | **boolean, optional** | Whether to skip database save |
| `noCheckEntity` | **boolean, optional** | Whether to skip entity validation |

#### ↩️ Returns
* boolean, string - Success status and error message if failed

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set item data
    lia.item.setItemDataByID(123, "customProperty", "value")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set item data with validation
    local success, error = lia.item.setItemDataByID(456, "lastUsed", os.time())
    if success then
        print("Item data updated successfully")
    else
        print("Failed to update item data:", error)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Set item data with custom sync and save options
    local function updateItemData(itemID, data, players)
        local success, error = lia.item.setItemDataByID(
            itemID,
            "customData",
            data,
            players,
            false, -- Save to database
            true   -- Skip entity check
        )
        return success, error
    end

```

---

### lia.item.instance

#### 📋 Purpose
Creates a new item instance in a specific inventory with database persistence

#### ⏰ When Called
When you need to create a new item instance that will be saved to the database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | **string/number** | Inventory ID or character ID |
| `uniqueID` | **string** | Item definition ID |
| `itemData` | **table, optional** | Initial item data |
| `x` | **number, optional** | X position in inventory |
| `y` | **number, optional** | Y position in inventory |
| `callback` | **function, optional** | Function to call when item is created |

#### ↩️ Returns
* Promise - Resolves with the created item instance

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create item in inventory
    lia.item.instance(invID, "weapon_pistol")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create item with position and callback
    lia.item.instance(invID, "weapon_pistol", {}, 1, 1, function(item)
        print("Created item:", item.name)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Create item with complex data and error handling
    local promise = lia.item.instance(charID, "custom_item", {
        customProperty = "value",
        createdBy      = "admin",
        createdAt       = os.time()
    }, 2, 3, function(item)
        print("Item created with ID:", item.id)
    end)
    promise:next(function(item)
        print("Successfully created item")
    end):catch(function(error)
        print("Failed to create item:", error)
    end)

```

---

### lia.item.deleteByID

#### 📋 Purpose
Deletes an item instance by its ID from both memory and database

#### ⏰ When Called
When you need to permanently remove an item from the game

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique ID of the item instance to delete |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Delete an item
    lia.item.deleteByID(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Delete item with validation
    local item = lia.item.getInstancedItemByID(456)
    if item then
        print("Deleting item:", item.name)
        lia.item.deleteByID(456)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Delete multiple items with error handling
    local function deleteItems(itemIDs)
        for _, id in ipairs(itemIDs) do
            local item = lia.item.getInstancedItemByID(id)
            if item then
                print("Deleting item:", item.name, "ID:", id)
                lia.item.deleteByID(id)
            else
                print("Item not found:", id)
            end
        end
    end

```

---

### lia.item.loadItemByID

#### 📋 Purpose
Loads item instances from the database by their IDs

#### ⏰ When Called
During server startup or when specific items need to be restored from database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemIndex` | **number/table** | Single item ID or table of item IDs to load |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load a single item
    lia.item.loadItemByID(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load multiple items
    lia.item.loadItemByID({123, 456, 789})

```

#### ⚙️ High Complexity
```lua
    -- High: Load items with validation and error handling
    local function loadPlayerItems(player)
        local char = player:getChar()
        if char then
            local inv = char:getInv()
            if inv then
                -- Load all items for this character
                lia.db.query("SELECT itemID FROM lia_items WHERE invID = " .. inv.id, function(results)
                    if results then
                        local itemIDs = {}
                        for _, row in ipairs(results) do
                            table.insert(itemIDs, tonumber(row.itemID))
                        end
                        lia.item.loadItemByID(itemIDs)
                    end
                end)
            end
        end
    end

```

---

### lia.item.spawn

#### 📋 Purpose
Spawns an item entity in the world at a specific position

#### ⏰ When Called
When you need to create an item that exists as a world entity

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The item definition ID |
| `position` | **Vector** | World position to spawn at |
| `callback` | **function, optional** | Function to call when item is spawned |
| `angles` | **Angle, optional** | Rotation angles for the entity |
| `data` | **table, optional** | Initial item data |

#### ↩️ Returns
* Promise - Resolves with the spawned item instance

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Spawn item at position
    lia.item.spawn("weapon_pistol", Vector(0, 0, 0))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Spawn item with angles and callback
    lia.item.spawn("weapon_pistol", Vector(100, 200, 50), function(item)
        print("Spawned item:", item.name)
    end, Angle(0, 90, 0))

```

#### ⚙️ High Complexity
```lua
    -- High: Spawn item with complex data and error handling
    local promise = lia.item.spawn("custom_item", Vector(0, 0, 0), function(item)
        if item then
            item:setData("spawnedBy", "admin")
            item:setData("spawnTime", os.time())
            print("Item spawned successfully")
        end
    end, Angle(0, 0, 0), {
        customProperty = "value",
        durability     = 100
    })
    promise:next(function(item)
        print("Item spawned at:", item.entity:GetPos())
    end):catch(function(error)
        print("Failed to spawn item:", error)
    end)

```

---

### lia.item.restoreInv

#### 📋 Purpose
Restores an inventory from the database with specified dimensions

#### ⏰ When Called
During server startup or when restoring inventories from database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invID` | **number** | The inventory ID to restore |
| `w` | **number** | Width of the inventory |
| `h` | **number** | Height of the inventory |
| `callback` | **function, optional** | Function to call when inventory is restored |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Restore inventory
    lia.item.restoreInv(123, 5, 4)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Restore inventory with callback
    lia.item.restoreInv(456, 8, 6, function(inv)
        print("Restored inventory:", inv.id)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Restore multiple inventories with error handling
    local function restorePlayerInventories(player)
        local char = player:getChar()
        if char then
            local inventories = {
                {id = char:getInv().id, w = 5, h = 4},
                {id = char:getStorage().id, w = 10, h = 8}
            }
            for _, invData in ipairs(inventories) do
                lia.item.restoreInv(invData.id, invData.w, invData.h, function(inv)
                    if inv then
                        print("Restored inventory:", inv.id)
                    else
                        print("Failed to restore inventory:", invData.id)
                    end
                end)
            end
        end
    end

```

---

