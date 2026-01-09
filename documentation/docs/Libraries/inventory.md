# Inventory Library

Comprehensive inventory system management with multiple storage types for the Lilia framework.

---

Overview

The inventory library provides comprehensive functionality for managing inventory systems in the Lilia framework. It handles inventory type registration, instance creation, storage management, and database persistence. The library operates on both server and client sides, with the server managing inventory data persistence, loading, and storage registration, while the client handles inventory panel display and user interaction. It supports multiple inventory types, storage containers, vehicle trunks, and character-based inventory management. The library ensures proper data validation, caching, and cleanup for optimal performance.

---

### lia.inventory.newType

#### 📋 Purpose
Registers a new inventory type with the specified ID and structure.

#### ⏰ When Called
Called during gamemode initialization or when defining custom inventory types that extend the base inventory system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | Unique identifier for the inventory type. |
| `invTypeStruct` | **table** | Table containing the inventory type definition with required fields like className, config, and methods. |

#### ↩️ Returns
* nil
No return value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.inventory.newType("grid", {
        className = "GridInv",
        config = {w = 10, h = 10},
        add = function(self, item) end,
        remove = function(self, item) end,
        sync = function(self, client) end
    })

```

---

### lia.inventory.new

#### 📋 Purpose
Creates a new inventory instance of the specified type.

#### ⏰ When Called
Called when instantiating inventories during loading, character creation, or when creating new storage containers.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | The inventory type identifier that was previously registered with newType. |

#### ↩️ Returns
* table
A new inventory instance with items table and copied config from the type definition.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local myInventory = lia.inventory.new("grid")
    -- Creates a new grid-based inventory instance

```

---

### lia.inventory.loadByID

#### 📋 Purpose
Loads an inventory instance by its ID, checking cache first and falling back to storage loading.

#### ⏰ When Called
Called when accessing inventories by ID, typically during character loading, item operations, or storage access.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique inventory ID to load. |
| `noCache` | **boolean** | Optional flag to bypass cache and force loading from storage. |

#### ↩️ Returns
* Deferred
A deferred object that resolves to the loaded inventory instance, or rejects if loading fails.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.loadByID(123):next(function(inventory)
        print("Loaded inventory:", inventory.id)
    end)

```

---

### lia.inventory.loadFromDefaultStorage

#### 📋 Purpose
Loads an inventory from the default database storage, including associated data and items.

#### ⏰ When Called
Called by loadByID when no custom storage loader is found, or when directly loading from database storage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The inventory ID to load from database storage. |
| `noCache` | **boolean** | Optional flag to bypass cache and force fresh loading. |

#### ↩️ Returns
* Deferred
A deferred object that resolves to the fully loaded inventory instance with data and items.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.loadFromDefaultStorage(456, true):next(function(inventory)
        -- Inventory loaded with fresh data, bypassing cache
    end)

```

---

### lia.inventory.instance

#### 📋 Purpose
Creates a new inventory instance with persistent storage initialization.

#### ⏰ When Called
Called when creating new inventories that need database persistence, such as character inventories or storage containers.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `typeID` | **string** | The inventory type identifier. |
| `initialData` | **table** | Optional initial data to store with the inventory instance. |

#### ↩️ Returns
* Deferred
A deferred object that resolves to the created inventory instance after storage initialization.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.instance("grid", {char = 1}):next(function(inventory)
        -- New inventory created and stored in database
    end)

```

---

### lia.inventory.loadAllFromCharID

#### 📋 Purpose
Loads all inventories associated with a specific character ID.

#### ⏰ When Called
Called during character loading to restore all inventory data for a character.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number|string** | The character ID to load inventories for (will be converted to number). |

#### ↩️ Returns
* Deferred
A deferred object that resolves to an array of loaded inventory instances.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.loadAllFromCharID(42):next(function(inventories)
        for _, inv in ipairs(inventories) do
            print("Loaded inventory:", inv.id)
        end
    end)

```

---

### lia.inventory.deleteByID

#### 📋 Purpose
Permanently deletes an inventory and all its associated data from the database.

#### ⏰ When Called
Called when removing inventories, such as during character deletion or storage cleanup.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The inventory ID to delete. |

#### ↩️ Returns
* nil
No return value.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.deleteByID(123)
    -- Inventory 123 and all its data/items are permanently removed

```

---

### lia.inventory.cleanUpForCharacter

#### 📋 Purpose
Destroys all inventories associated with a character during cleanup.

#### ⏰ When Called
Called during character deletion or when cleaning up character data to prevent memory leaks.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `character` | **table** | The character object whose inventories should be destroyed. |

#### ↩️ Returns
* nil
No return value.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.cleanUpForCharacter(player:getChar())
    -- All inventories for this character are destroyed

```

---

### lia.inventory.checkOverflow

#### 📋 Purpose
Checks for items that no longer fit in an inventory after resizing and moves them to overflow storage.

#### ⏰ When Called
Called when inventory dimensions change (like when upgrading inventory size) to handle items that no longer fit.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inv` | **table** | The inventory instance to check for overflow. |
| `character` | **table** | The character object to store overflow items on. |
| `oldW` | **number** | The previous width of the inventory. |
| `oldH` | **number** | The previous height of the inventory. |

#### ↩️ Returns
* boolean
True if overflow items were found and moved, false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.inventory.checkOverflow(inventory, player:getChar(), 5, 5) then
        -- Items were moved to overflow storage
    end

```

---

### lia.inventory.registerStorage

#### 📋 Purpose
Registers a storage container configuration for entities with the specified model.

#### ⏰ When Called
Called during gamemode initialization to define storage containers like lockers, crates, or other inventory-holding entities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | The model path of the entity that will have storage capability. |
| `data` | **table** | Configuration table containing name, invType, invData, and other storage properties. |

#### ↩️ Returns
* table
The registered storage data table.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.registerStorage("models/props_c17/lockers001a.mdl", {
        name = "Locker",
        invType = "grid",
        invData = {w = 4, h = 6}
    })

```

---

### lia.inventory.getStorage

#### 📋 Purpose
Retrieves the storage configuration for a specific model.

#### ⏰ When Called
Called when checking if an entity model has storage capabilities or retrieving storage properties.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `model` | **string** | The model path to look up storage configuration for. |

#### ↩️ Returns
* table|nil
The storage configuration table if found, nil otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local storage = lia.inventory.getStorage("models/props_c17/lockers001a.mdl")
    if storage then
        print("Storage name:", storage.name)
    end

```

---

### lia.inventory.registerTrunk

#### 📋 Purpose
Registers a vehicle trunk configuration for vehicles with the specified class.

#### ⏰ When Called
Called during gamemode initialization to define vehicle trunk storage capabilities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vehicleClass` | **string** | The vehicle class name that will have trunk capability. |
| `data` | **table** | Configuration table containing name, invType, invData, and trunk-specific properties. |

#### ↩️ Returns
* table
The registered trunk data table with trunk flags set.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.inventory.registerTrunk("vehicle_class", {
        name = "Car Trunk",
        invType = "grid",
        invData = {w = 8, h = 4}
    })

```

---

### lia.inventory.getTrunk

#### 📋 Purpose
Retrieves the trunk configuration for a specific vehicle class.

#### ⏰ When Called
Called when checking if a vehicle class has trunk capabilities or retrieving trunk properties.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `vehicleClass` | **string** | The vehicle class name to look up trunk configuration for. |

#### ↩️ Returns
* table|nil
The trunk configuration table if found and it's a trunk, nil otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local trunk = lia.inventory.getTrunk("vehicle_class")
    if trunk then
        print("Trunk capacity:", trunk.invData.w, "x", trunk.invData.h)
    end

```

---

### lia.inventory.getAllTrunks

#### 📋 Purpose
Retrieves all registered trunk configurations.

#### ⏰ When Called
Called when listing all available vehicle trunk types or for administrative purposes.

#### ↩️ Returns
* table
A table containing all registered trunk configurations keyed by vehicle class.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local trunks = lia.inventory.getAllTrunks()
    for class, config in pairs(trunks) do
        print("Trunk for", class, ":", config.name)
    end

```

---

### lia.inventory.getAllStorage

#### 📋 Purpose
Retrieves all registered storage configurations, optionally excluding trunks.

#### ⏰ When Called
Called when listing all available storage types or for administrative purposes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `includeTrunks` | **boolean** | Optional flag to include (true) or exclude (false) trunk configurations. Defaults to true. |

#### ↩️ Returns
* table
A table containing all registered storage configurations, optionally filtered.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Get all storage including trunks
    local allStorage = lia.inventory.getAllStorage(true)
    -- Get only non-trunk storage
    local storageOnly = lia.inventory.getAllStorage(false)

```

---

### lia.inventory.show

#### 📋 Purpose
Creates and displays an inventory panel for the specified inventory.

#### ⏰ When Called
Called when opening inventory interfaces, such as character inventories, storage containers, or other inventory UIs.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory` | **table** | The inventory instance to display in the panel. |
| `parent` | **Panel** | Optional parent panel for the inventory panel. |

#### ↩️ Returns
* Panel
The created inventory panel instance.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local panel = lia.inventory.show(myInventory)
    -- Opens the inventory UI for myInventory

```

---

### lia.inventory.showDual

#### 📋 Purpose
Creates and displays two inventory panels side by side for dual inventory interactions.

#### ⏰ When Called
Called when opening dual inventory interfaces, such as trading, transferring items between inventories, or accessing storage.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `inventory1` | **table** | The first inventory instance to display. |
| `inventory2` | **table** | The second inventory instance to display. |
| `parent` | **Panel** | Optional parent panel for the inventory panels. |

#### ↩️ Returns
* table
An array containing both created inventory panel instances {panel1, panel2}.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    local panels = lia.inventory.showDual(playerInv, storageInv)
    -- Opens dual inventory UI for trading between player and storage

```

---

