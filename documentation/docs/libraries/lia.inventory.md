# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It maintains a registry of inventory types in `lia.inventory.types` and caches loaded inventories in `lia.inventory.instances`. New inventory types can be registered and item transfers between inventories are handled automatically.

---

### lia.inventory.newType

**Purpose**

Registers a new inventory type with comprehensive validation. The function checks that the structure matches `InvTypeStructType`, validates all nested table structures, and ensures no duplicate types are registered.

**Parameters**

* `typeID` (*string*): Unique identifier. Must not already be registered.
* `invTypeStruct` (*table*): Definition matching `InvTypeStructType`. Must include `__index`, `typeID`, and `className`; server-side definitions may also provide `add`, `remove`, and `sync` functions.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Throws**

* Error if `typeID` is already registered
* Error if `invTypeStruct` is not a table
* Error if structure validation fails

**Example Usage**

```lua
lia.inventory.newType("backpack", {
    __index = "table",
    add = function(self, item) print("Added", item) end,
    remove = function(self, item) print("Removed", item) end,
    sync = function(self) print("Sync") end,
    typeID = "backpack",
    className = "liaBackpack",
    config = {width = 5, height = 5}
})
```

### lia.inventory.new

**Purpose**

Instantiates a new inventory of a registered type. The instance starts with
an empty `items` table and a copy of the type's `config` table.

**Parameters**

* `typeID` (*string*): Inventory type identifier. Must refer to a registered
  type or an error is thrown.

**Realm**

`Shared`

**Returns**

* *table*: The created inventory object.

**Example Usage**

```lua
local inv = lia.inventory.new("bag")
```

---

### lia.inventory.loadByID

**Purpose**

Loads an inventory by ID, using a cached instance when available or falling back to any custom loader defined by the inventory type.

**Parameters**

* `id` (*number*): Non-negative inventory ID. Throws an error if invalid.

* `noCache` (*boolean*): Optional. When `true`, bypasses the cache. Defaults to `false`.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the inventory or `nil` if not found.

**Example Usage**

```lua
lia.inventory.loadByID(1):next(function(inv)
    if inv then
        print("Loaded inventory", inv)
    else
        print("Inventory not found")
    end
end)
```

---

### lia.inventory.loadFromDefaultStorage

**Purpose**

Default SQL loader used by `lia.inventory.loadByID` when no custom loader is provided. Populates inventory data and items from the database, caches the result, and returns any cached instance unless `noCache` is `true`.

**Parameters**

* `id` (*number*): Non-negative inventory ID.

* `noCache` (*boolean*): Optional. When `true`, bypasses the cache. Defaults to `false`.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the inventory or `nil` if not found. Returns `nil` if the inventory type is missing.

**Example Usage**

```lua
lia.inventory.loadFromDefaultStorage(1):next(function(inv)
    if inv then
        print("Loaded inventory", inv)
    else
        print("Inventory not found")
    end
end)
```

---

### lia.inventory.instance

**Purpose**

Creates and persists a new inventory instance with validation, allocating storage and caching the result.

**Parameters**

* `typeID` (*string*): Inventory type identifier. Must refer to a registered type.
* `initialData` (*table*): Optional initial data. Defaults to an empty table and must be a table if provided.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the created inventory instance.

**Throws**

* Error if `typeID` is invalid or not registered
* Error if `initialData` is provided but not a table

**Example Usage**

```lua
lia.inventory.instance("bag", { char = 1 }):next(function(inventory)
    print("New inventory", inventory.id)
end)
```

---

### lia.inventory.loadAllFromCharID

**Purpose**

Loads every inventory that belongs to a character with comprehensive error handling. If `charID` cannot be converted to a number, the returned deferred is rejected with a detailed error message.

**Parameters**

* `charID` (*number* or convertible): Character ID. Must be numeric or convertible to a number.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to a table of inventories or rejects with an error message if `charID` is invalid.

**Throws**

* Error if `charID` cannot be converted to a number (includes original value and type in error message)

**Example Usage**

```lua
local charID = client:getChar():getID()

lia.inventory.loadAllFromCharID(charID):next(function(inventories)
    PrintTable(inventories)
end)
```

---

### lia.inventory.deleteByID

**Purpose**

Deletes an inventory and all associated data and items from both memory and
persistent storage.

**Parameters**

* `id` (*number*): Inventory ID.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.inventory.deleteByID(1)
```

---

### lia.inventory.cleanUpForCharacter

**Purpose**

Destroys every inventory associated with a character by calling `destroy` on
each inventory returned from `character:getInv(true)`.

**Parameters**

* `character` (*table*): Character object (e.g. from `client:getChar()`).

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.inventory.cleanUpForCharacter(client:getChar())
```

---

### lia.inventory.show

**Purpose**

Displays an inventory UI panel on the client. If a panel for the inventory
already exists it is removed. Hooks `CreateInventoryPanel`, `InventoryOpened`
and `InventoryClosed` are triggered.

**Parameters**

* `inventory` (*table*): Inventory to display.

* `parent` (*Panel*): Optional parent panel. Defaults to `nil`.

**Realm**

`Client`

**Returns**

* *Panel*: The created VGUI panel.

**Example Usage**

```lua
local inv = LocalPlayer():getChar():getInv()

if inv then
    local panel = lia.inventory.show(inv)
end
```

---

### lia.inventory.registerStorage

**Purpose**

Registers a storage model with associated inventory data for use in the game world. This allows entities with specific models to have inventory functionality.

**Parameters**

* `model` (*string*): The model path of the entity. Must be a string.
* `data` (*table*): Storage configuration table containing:
  - `name` (*string*): Display name for the storage
  - `invType` (*string*): Inventory type identifier
  - `invData` (*table*): Initial inventory data/configuration

**Realm**

`Server`

**Returns**

* *table*: The registered storage data

**Example Usage**

```lua
lia.inventory.registerStorage("models/props_c17/lockers001a.mdl", {
    name = "Locker",
    invType = "GridInv",
    invData = {w = 5, h = 5}
})
```

---

### lia.inventory.getStorage

**Purpose**

Retrieves storage configuration data for a specific model.

**Parameters**

* `model` (*string*): The model path to look up. Optional, returns nil if not provided.

**Realm**

`Server`

**Returns**

* *table* or *nil*: Storage configuration data if found, nil otherwise

**Example Usage**

```lua
local storageData = lia.inventory.getStorage("models/props_c17/lockers001a.mdl")
if storageData then
    print("Storage name:", storageData.name)
end
```

---

### lia.inventory.registerTrunk

**Purpose**

Registers a vehicle trunk with inventory functionality. Automatically sets default dimensions from config values if not specified and marks the storage as a trunk.

**Parameters**

* `vehicleClass` (*string*): The vehicle class name. Must be a string.
* `data` (*table*): Trunk configuration table containing:
  - `name` (*string*): Display name for the trunk
  - `invType` (*string*): Inventory type identifier
  - `invData` (*table*): Initial inventory data/configuration (w and h default to config values)

**Realm**

`Server`

**Returns**

* *table*: The registered trunk data

**Example Usage**

```lua
lia.inventory.registerTrunk("prop_vehicle_jeep", {
    name = "Jeep Trunk",
    invType = "GridInv",
    invData = {w = 8, h = 4}
})
```

---

### lia.inventory.getTrunk

**Purpose**

Retrieves trunk configuration data for a specific vehicle class.

**Parameters**

* `vehicleClass` (*string*): The vehicle class to look up. Optional, returns nil if not provided.

**Realm**

`Server`

**Returns**

* *table* or *nil*: Trunk configuration data if found and it's marked as a trunk, nil otherwise

**Example Usage**

```lua
local trunkData = lia.inventory.getTrunk("prop_vehicle_jeep")
if trunkData then
    print("Trunk name:", trunkData.name)
end
```

---

### lia.inventory.getAllTrunks

**Purpose**

Retrieves all registered trunk configurations.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* *table*: Table of all trunk configurations keyed by vehicle class

**Example Usage**

```lua
local allTrunks = lia.inventory.getAllTrunks()
for vehicleClass, trunkData in pairs(allTrunks) do
    print(vehicleClass .. " has trunk: " .. trunkData.name)
end
```

---

### lia.inventory.getAllStorage

**Purpose**

Retrieves all registered storage configurations, with optional filtering to exclude trunks.

**Parameters**

* `includeTrunks` (*boolean*): Optional. When `false`, excludes trunks from the result. Defaults to `true`.

**Realm**

`Server`

**Returns**

* *table*: Table of all storage configurations (optionally excluding trunks) keyed by model/vehicle class

**Example Usage**

```lua
-- Get all storage including trunks
local allStorage = lia.inventory.getAllStorage()

-- Get only non-trunk storage
local storageOnly = lia.inventory.getAllStorage(false)

for key, data in pairs(storageOnly) do
    print("Storage: " .. data.name)
end
```

