# Item Library

Comprehensive item registration, instantiation, and management system for the Lilia framework.

---

Overview

The item library provides comprehensive functionality for managing items in the Lilia framework. It handles item registration, instantiation, inventory management, and item operations such as dropping, taking, rotating, and transferring items between players. The library operates on both server and client sides, with server-side functions handling database operations, item spawning, and data persistence, while client-side functions manage item interactions and UI operations. It includes automatic weapon and ammunition generation from Garry's Mod weapon lists, inventory type registration, and item entity management. The library ensures proper item lifecycle management from creation to deletion, with support for custom item functions, hooks, and data persistence.

---

### lia.item.get

#### 📋 Purpose
Retrieves an item definition (base or regular item) by its unique identifier.

#### ⏰ When Called
Called when needing to access item definitions for registration, validation, or manipulation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **string** | The unique identifier of the item to retrieve. |

#### ↩️ Returns
* table or nil
The item definition table if found, nil if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local weaponItem = lia.item.get("weapon_pistol")
    if weaponItem then
        print("Found weapon:", weaponItem.name)
    end

```

---

### lia.item.getItemByID

#### 📋 Purpose
Retrieves an instanced item by its ID and determines its current location.

#### ⏰ When Called
Called when needing to access specific item instances, typically for manipulation or inspection.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the instanced item to retrieve. |

#### ↩️ Returns
* table or nil, string
A table containing the item and its location ("inventory", "world", or "unknown"), or nil and an error message if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local itemData, errorMsg = lia.item.getItemByID(123)
    if itemData then
        print("Item found at:", itemData.location)
        -- Use itemData.item for item operations
    else
        print("Error:", errorMsg)
    end

```

---

### lia.item.getInstancedItemByID

#### 📋 Purpose
Retrieves an instanced item directly by its ID without location information.

#### ⏰ When Called
Called when needing to access item instances for direct manipulation without location context.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the instanced item to retrieve. |

#### ↩️ Returns
* table or nil, string
The item instance if found, or nil and an error message if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local item, errorMsg = lia.item.getInstancedItemByID(123)
    if item then
        item:setData("customValue", "example")
    else
        print("Error:", errorMsg)
    end

```

---

### lia.item.getItemDataByID

#### 📋 Purpose
Retrieves the data table of an instanced item by its ID.

#### ⏰ When Called
Called when needing to access or inspect the custom data stored on an item instance.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the instanced item to retrieve data from. |

#### ↩️ Returns
* table or nil, string
The item's data table if found, or nil and an error message if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local data, errorMsg = lia.item.getItemDataByID(123)
    if data then
        print("Item durability:", data.durability or "N/A")
    else
        print("Error:", errorMsg)
    end

```

---

### lia.item.load

#### 📋 Purpose
Loads and registers an item from a file path by extracting the unique ID and registering it.

#### ⏰ When Called
Called during item loading process to register items from files in the items directory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `path` | **string** | The file path of the item to load. |
| `baseID` | **string, optional** | The base item ID to inherit from. |
| `isBaseItem` | **boolean, optional** | Whether this is a base item definition. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load a regular item
    lia.item.load("lilia/gamemode/items/food_apple.lua")
    -- Load a base item
    lia.item.load("lilia/gamemode/items/base/sh_food.lua", nil, true)

```

---

### lia.item.isItem

#### 📋 Purpose
Checks if an object is a valid Lilia item instance.

#### ⏰ When Called
Called to validate that an object is an item before performing item-specific operations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `object` | **any** | The object to check if it's an item. |

#### ↩️ Returns
* boolean
True if the object is a valid item, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local someObject = getSomeObject()
    if lia.item.isItem(someObject) then
        someObject:setData("used", true)
    else
        print("Object is not an item")
    end

```

---

### lia.item.getInv

#### 📋 Purpose
Retrieves an inventory instance by its ID.

#### ⏰ When Called
Called when needing to access inventory objects for item operations or inspection.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invID` | **number** | The unique ID of the inventory to retrieve. |

#### ↩️ Returns
* table or nil
The inventory instance if found, nil if not found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local inventory = lia.item.getInv(5)
    if inventory then
        print("Inventory size:", inventory:getWidth(), "x", inventory:getHeight())
    end

```

---

### lia.item.addRarities

#### 📋 Purpose
Adds a new item rarity tier with an associated color for visual identification.

#### ⏰ When Called
Called during item system initialization to define available rarity levels for items.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name of the rarity tier (e.g., "Common", "Rare", "Legendary"). |
| `color` | **Color** | The color associated with this rarity tier. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.item.addRarities("Mythical", Color(255, 0, 255))
    lia.item.addRarities("Divine", Color(255, 215, 0))

```

---

### lia.item.register

#### 📋 Purpose
Registers an item definition with the Lilia item system, setting up inheritance and default functions.

#### ⏰ When Called
Called during item loading to register item definitions, either from files or programmatically generated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier for the item. |
| `baseID` | **string, optional** | The base item ID to inherit from (defaults to lia.meta.item). |
| `isBaseItem` | **boolean, optional** | Whether this is a base item definition. |
| `path` | **string, optional** | The file path for loading the item (used for shared loading). |
| `luaGenerated` | **boolean, optional** | Whether the item is generated programmatically rather than loaded from a file. |

#### ↩️ Returns
* table
The registered item definition table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Register a base item
    lia.item.register("base_weapon", nil, true, "path/to/base_weapon.lua")
    -- Register a regular item
    lia.item.register("weapon_pistol", "base_weapon", false, "path/to/weapon_pistol.lua")

```

---

### lia.item.overrideItem

#### 📋 Purpose
Queues property overrides for an item that will be applied when the item is initialized.

#### ⏰ When Called
Called during item system setup to modify item properties before they are finalized.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique ID of the item to override. |
| `overrides` | **table** | A table of properties to override on the item. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.item.overrideItem("weapon_pistol", {
        name = "Custom Pistol",
        width = 2,
        height = 1,
        price = 500
    })

```

---

### lia.item.loadFromDir

#### 📋 Purpose
Loads all items from a directory structure, organizing base items and regular items.

#### ⏰ When Called
Called during gamemode initialization to load all item definitions from the items directory.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | The directory path containing the item files to load. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load all items from the gamemode's items directory
    lia.item.loadFromDir("lilia/gamemode/items")

```

---

### lia.item.new

#### 📋 Purpose
Creates a new item instance from an item definition with a specific ID.

#### ⏰ When Called
Called when instantiating items from the database or creating new items programmatically.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique ID of the item definition to instantiate. |
| `id` | **number** | The unique instance ID for this item. |

#### ↩️ Returns
* table
The newly created item instance.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Create a new pistol item instance
    local pistol = lia.item.new("weapon_pistol", 123)
    pistol:setData("durability", 100)

```

---

### lia.item.registerInv

#### 📋 Purpose
Registers a new inventory type with specified dimensions.

#### ⏰ When Called
Called during inventory system initialization to define different inventory types.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invType` | **string** | The unique type identifier for this inventory. |
| `w` | **number** | The width of the inventory in grid units. |
| `h` | **number** | The height of the inventory in grid units. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Register a backpack inventory type
    lia.item.registerInv("backpack", 4, 6)
    -- Register a safe inventory type
    lia.item.registerInv("safe", 8, 8)

```

---

### lia.item.newInv

#### 📋 Purpose
Creates a new inventory instance for a character and syncs it with the appropriate player.

#### ⏰ When Called
Called when creating new inventories for characters, such as during character creation or item operations.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `owner` | **number** | The character ID that owns this inventory. |
| `invType` | **string** | The type of inventory to create. |
| `callback` | **function, optional** | Function called when the inventory is created and ready. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Create a backpack inventory for character ID 5
    lia.item.newInv(5, "backpack", function(inventory)
        print("Backpack created with ID:", inventory:getID())
    end)

```

---

### lia.item.createInv

#### 📋 Purpose
Creates a new inventory instance with specified dimensions and registers it.

#### ⏰ When Called
Called when creating inventories programmatically, such as for containers or special storage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `w` | **number** | The width of the inventory in grid units. |
| `h` | **number** | The height of the inventory in grid units. |
| `id` | **number** | The unique ID for this inventory instance. |

#### ↩️ Returns
* table
The created inventory instance.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Create a 4x6 container inventory
    local container = lia.item.createInv(4, 6, 1001)
    print("Container created with ID:", container.id)

```

---

### lia.item.addWeaponOverride

#### 📋 Purpose
Adds custom override data for weapon items during auto-generation.

#### ⏰ When Called
Called during weapon item generation to customize properties of specific weapons.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `className` | **string** | The weapon class name to override. |
| `data` | **table** | The override data containing weapon properties. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.item.addWeaponOverride("weapon_pistol", {
        name = "Custom Pistol",
        width = 2,
        height = 1,
        price = 500,
        model = "models/weapons/custom_pistol.mdl"
    })

```

---

### lia.item.addWeaponToBlacklist

#### 📋 Purpose
Adds a weapon class to the blacklist to prevent it from being auto-generated as an item.

#### ⏰ When Called
Called during weapon generation setup to exclude certain weapons from item creation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `className` | **string** | The weapon class name to blacklist. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Prevent admin tools from being generated as items
    lia.item.addWeaponToBlacklist("weapon_physgun")
    lia.item.addWeaponToBlacklist("gmod_tool")

```

---

### lia.item.generateWeapons

#### 📋 Purpose
Auto-generates item definitions for all weapons in the game's weapons list.

#### ⏰ When Called
Called during gamemode initialization if auto-weapon generation is enabled.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Generate weapon items (usually called automatically)
    if lia.config.get("AutoWeaponItemGeneration", true) then
        lia.item.generateWeapons()
    end

```

---

### lia.item.generateAmmo

#### 📋 Purpose
Auto-generates item definitions for ammunition entities from compatible weapon mods.

#### ⏰ When Called
Called during gamemode initialization if auto-ammo generation is enabled.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Generate ammo items (usually called automatically)
    if lia.config.get("AutoAmmoItemGeneration", true) then
        lia.item.generateAmmo()
    end

```

---

### lia.item.setItemDataByID

#### 📋 Purpose
Sets data on an item instance by its ID and synchronizes the changes.

#### ⏰ When Called
Called when needing to modify item data server-side and sync to clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemID` | **number** | The unique ID of the item instance. |
| `key` | **string** | The data key to set. |
| `value` | **any** | The value to set for the key. |
| `receivers` | **table, optional** | Specific players to sync the data to. |
| `noSave` | **boolean, optional** | Whether to skip saving to database. |
| `noCheckEntity` | **boolean, optional** | Whether to skip entity validation. |

#### ↩️ Returns
* boolean, string
True if successful, false and error message if failed.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local success, errorMsg = lia.item.setItemDataByID(123, "durability", 75)
    if success then
        print("Item durability updated")
    else
        print("Error:", errorMsg)
    end

```

---

### lia.item.instance

#### 📋 Purpose
Creates a new item instance in the database and returns the created item.

#### ⏰ When Called
Called when creating new items that need to be persisted to the database.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `index` | **number|string** | The inventory ID or unique ID if first parameter is string. |
| `uniqueID` | **string|table** | The item definition unique ID or item data if index is string. |
| `itemData` | **table, optional** | The item data to set on creation. |
| `x` | **number, optional** | The X position in inventory. |
| `y` | **number, optional** | The Y position in inventory. |
| `callback` | **function, optional** | Function called when item is created. |

#### ↩️ Returns
* table
A deferred promise that resolves with the created item.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Create a pistol in inventory 5 at position 1,1
    lia.item.instance(5, "weapon_pistol", {}, 1, 1):next(function(item)
        print("Created item with ID:", item:getID())
    end)

```

---

### lia.item.deleteByID

#### 📋 Purpose
Deletes an item instance by its ID from memory and/or database.

#### ⏰ When Called
Called when permanently removing items from the game world.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique ID of the item to delete. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Delete item with ID 123
    lia.item.deleteByID(123)

```

---

### lia.item.loadItemByID

#### 📋 Purpose
Loads item instances from the database by their IDs and recreates them in memory.

#### ⏰ When Called
Called during server startup or when needing to restore items from the database.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `itemIndex` | **number|table** | Single item ID or array of item IDs to load. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Load a single item
    lia.item.loadItemByID(123)
    -- Load multiple items
    lia.item.loadItemByID({123, 456, 789})

```

---

### lia.item.spawn

#### 📋 Purpose
Creates and spawns an item entity in the world at the specified position.

#### ⏰ When Called
Called when dropping items or creating item entities in the game world.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique ID of the item to spawn. |
| `position` | **Vector** | The position to spawn the item at. |
| `callback` | **function, optional** | Function called when item is spawned. |
| `angles` | **Angle, optional** | The angles to set on the spawned item. |
| `data` | **table, optional** | The item data to set on creation. |

#### ↩️ Returns
* table or nil
A deferred promise that resolves with the spawned item, or nil if synchronous.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Spawn a pistol at a position
    lia.item.spawn("weapon_pistol", Vector(0, 0, 0), function(item)
        print("Spawned item:", item:getName())
    end)

```

---

### lia.item.restoreInv

#### 📋 Purpose
Restores an inventory from the database and sets its dimensions.

#### ⏰ When Called
Called when loading saved inventories from the database.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `invID` | **number** | The unique ID of the inventory to restore. |
| `w` | **number** | The width of the inventory. |
| `h` | **number** | The height of the inventory. |
| `callback` | **function, optional** | Function called when inventory is restored. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Restore a 4x6 inventory
    lia.item.restoreInv(5, 4, 6, function(inventory)
        print("Restored inventory with", inventory:getItemCount(), "items")
    end)

```

---

