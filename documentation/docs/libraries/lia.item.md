# Item Library

This page covers item definition helpers.

---

## Overview

The item library contains utilities for retrieving item definitions and creating new items. It also provides shared item methods used throughout the framework.

---

### lia.item.base

**Purpose**

Table of all base item definitions indexed by unique ID.

**Realm**

`Shared`

**Example Usage**

```lua
local baseOutfit = lia.item.base["base_outfit"]
```

---

### lia.item.list

**Purpose**

Holds all registered item definitions accessible by their unique ID.

**Realm**

`Shared`

**Example Usage**

```lua
for id, item in pairs(lia.item.list) do
    print(id, item.name)
end
```

---

### lia.item.instances

**Purpose**

Stores item instances keyed by numeric ID.

**Realm**

`Shared`

**Example Usage**

```lua
local inst = lia.item.instances[5]
```

---

### lia.item.inventories

**Purpose**

Alias of `lia.inventory.instances` for convenience.

**Realm**

`Shared`

**Example Usage**

```lua
local inv = lia.item.inventories[1]
```

---

### lia.item.inventoryTypes

**Purpose**

Contains registered inventory classes by type name.

**Realm**

`Shared`

**Example Usage**

```lua
print(lia.item.inventoryTypes["GridInv"])
```

---

### lia.item.WeaponOverrides

**Purpose**

Maps weapon class names to property overrides used when generating weapon items.

**Realm**

`Shared`

**Example Usage**

```lua
lia.item.WeaponOverrides["weapon_pistol"] = { name = "Old Pistol" }
```

---

### lia.item.WeaponsBlackList

**Purpose**

Set of weapon classes excluded from automatic item generation.

**Realm**

`Shared`

**Example Usage**

```lua
lia.item.WeaponsBlackList["weapon_physgun"] = true
```

---

### lia.item.holdTypeToWeaponCategory

**Purpose**

Translates SWEP hold types to default weapon categories.

**Realm**

`Shared`

**Example Usage**

```lua
local cat = lia.item.holdTypeToWeaponCategory["smg"]
```

---

### lia.item.holdTypeSizeMapping

**Purpose**

Default width and height values for generated weapons by hold type.

**Realm**

`Shared`

**Example Usage**

```lua
local size = lia.item.holdTypeSizeMapping["smg"]
print(size.width, size.height)
```

---

### lia.item.get

**Purpose**

Retrieves an item definition table by its identifier, searching both base and regular item lists.


**Parameters**

* `identifier` (*string*): The unique identifier of the item.



**Returns**

* *table or nil*: The item definition table if found, otherwise none.



**Realm**

`Shared.`


**Example Usage**

```lua
local itemDef = lia.item.get("weapon_ak47")
if itemDef then
print("AK47 item found:", itemDef.name)
end
```

---

### lia.item.getItemByID

**Purpose**

Retrieves an instanced item by its unique item ID, along with its location (inventory or world).


**Parameters**

* `itemID` (*number*): The unique ID of the item instance.



**Returns**

* *table or nil, string*: Table containing the item and its location, or nil and an error message.



**Realm**

`Shared.`


**Example Usage**

```lua
local result, err = lia.item.getItemByID(1234)
if result then
print("Item found in location:", result.location)
else
print("Error:", err)
end
```

---

### lia.item.getInstancedItemByID

**Purpose**

Retrieves an instanced item object by its unique item ID.


**Parameters**

* `itemID` (*number*): The unique ID of the item instance.



**Returns**

* *table or nil, string*: The item instance table if found, or nil and an error message.



**Realm**

`Shared.`


**Example Usage**

```lua
local item, err = lia.item.getInstancedItemByID(5678)
if item then
print("Item name:", item.name)
else
print("Error:", err)
end
```

---

### lia.item.getItemDataByID

**Purpose**

Retrieves the data table of an instanced item by its unique item ID.


**Parameters**

* `itemID` (*number*): The unique ID of the item instance.



**Returns**

* *table or nil, string*: The data table of the item if found, or nil and an error message.



**Realm**

`Shared.`


**Example Usage**

```lua
local data, err = lia.item.getItemDataByID(4321)
if data then
PrintTable(data)
else
print("Error:", err)
end
```

---

### lia.item.load

**Purpose**

Loads an item definition file and registers it as a base or regular item, depending on parameters.


**Parameters**

* `path` (*string*): The file path to the item definition.
* `baseID` (*string*): The base item ID to inherit from (optional).
* `isBaseItem` (*bool*): Whether this is a base item definition (optional).



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
lia.item.load("lilia/gamemode/items/weapons/sh_ak47.lua", "base_weapons")
```

---

### lia.item.isItem

**Purpose**

Checks if the given object is an item instance.


**Parameters**

* `object` (*any*): The object to check.



**Returns**

* *boolean*: True if the object is an item, false otherwise.



**Realm**

`Shared.`


**Example Usage**

```lua
if lia.item.isItem(myItem) then
print("This is a valid item instance.")
end
```

---

### lia.item.getInv

**Purpose**

Retrieves an inventory instance by its ID.


**Parameters**

* `invID` (*number*): The unique ID of the inventory.



**Returns**

* *table or nil*: The inventory instance if found, otherwise none.



**Realm**

`Shared.`


**Example Usage**

```lua
local inv = lia.item.getInv(1001)
if inv then
print("Inventory found with size:", inv:getSize())
end
```

---

### lia.item.register

**Purpose**

Registers a new item definition, either as a base or regular item, and sets up its metatable and properties.


**Parameters**

* `uniqueID` (*string*): The unique identifier for the item.
* `baseID` (*string*): The base item ID to inherit from (optional).
* `isBaseItem` (*bool*): Whether this is a base item (optional).
* `path` (*string*): The file path to the item definition (optional).
* `luaGenerated` (*bool*): If true, the item is generated in Lua and not loaded from file (optional).



**Returns**

* *table*: The registered item definition.



**Realm**

`Shared.`


**Example Usage**

```lua
local myItem = lia.item.register("custom_pistol", "base_weapons", false, "lilia/gamemode/items/weapons/sh_custom_pistol.lua")
print("Registered item:", myItem.uniqueID)
```

---

### lia.item.loadFromDir

**Purpose**

Loads all item definition files from the specified directory, including base items and category folders.
Registers each item using lia.item.load and triggers the "InitializedItems" hook after loading.


**Parameters**

* `directory` (*string*): The directory path to search for item files (should be relative to the gamemode).



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
-- Load all items from the "lilia/gamemode/items" directory
lia.item.loadFromDir("lilia/gamemode/items")
```

---

### lia.item.new

**Purpose**

Creates a new instanced item from a registered item definition and assigns it a unique ID.


**Parameters**

* `uniqueID` (*string*): The unique identifier of the item definition.
* `id` (*number*): The unique instance ID for the item.



**Returns**

* *table*: The new item instance.



**Realm**

`Shared.`


**Example Usage**

```lua
local item = lia.item.new("weapon_ak47", 1234)
print("Created item instance with ID:", item.id)
```

---

### lia.item.registerInv

**Purpose**

Registers a new inventory type with specified width and height, extending the GridInv metatable.


**Parameters**

* `invType` (*string*): The unique identifier for the inventory type.
* `w` (*number*): The width of the inventory grid.
* `h` (*number*): The height of the inventory grid.



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
lia.item.registerInv("backpack", 4, 4)
```

---

### lia.item.newInv

**Purpose**

Creates a new inventory instance of a given type for a specified owner, and calls a callback when ready.


**Parameters**

* `owner` (*number*): The character ID of the owner.
* `invType` (*string*): The inventory type identifier.
* `callback` (*function*): Function to call with the created inventory (optional).



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
lia.item.newInv(1, "backpack", function(inv)
print("New backpack inventory created for char 1:", inv.id)
end)
```

---

### lia.item.createInv

**Purpose**

Creates a new inventory instance with specified width, height, and ID, and registers it globally.


**Parameters**

* `w` (*number*): The width of the inventory grid.
* `h` (*number*): The height of the inventory grid.
* `id` (*number*): The unique ID for the inventory instance.



**Returns**

* *table*: The created inventory instance.



**Realm**

`Shared.`


**Example Usage**

```lua
local inv = lia.item.createInv(3, 3, 2001)
print("Created inventory with ID:", inv.id)
```

---

### lia.item.addWeaponOverride

**Purpose**

Adds or updates a weapon override for a specific weapon class, customizing its item properties.


**Parameters**

* `className` (*string*): The weapon class name.
* `data` (*table*): Table of override properties (e.g., name, desc, model, etc).



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
lia.item.addWeaponOverride("weapon_custom", {
name = "Custom Blaster",
desc = "A unique blaster weapon.",
model = "models/weapons/w_blaster.mdl"
})
```

---

### lia.item.addWeaponToBlacklist

**Purpose**

Adds a weapon class to the blacklist, preventing it from being auto-generated as an item.


**Parameters**

* `className` (*string*): The weapon class name to blacklist.



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
lia.item.addWeaponToBlacklist("weapon_physcannon")
```

---

### lia.item.generateWeapons

**Purpose**

Automatically generates item definitions for all weapons found in the game's weapon list,
except those blacklisted or with "_base" in their class name. Applies any registered overrides.


**Parameters**

* None.



**Returns**

* None.



**Realm**

`Shared.`


**Example Usage**

```lua
-- Generate all weapon items (usually called automatically)
lia.item.generateWeapons()
```

---

### lia.item.setItemDataByID

**Purpose**

Sets a specific data key-value pair for an instanced item by its ID, optionally syncing to receivers.


**Parameters**

* `itemID` (*number*): The unique ID of the item instance.
* `key` (*string*): The data key to set.
* `value` (*any*): The value to assign.
* `receivers` (*table*): List of players to sync to (optional).
* `noSave` (*bool*): If true, do not save to database (optional).
* `noCheckEntity` (*bool*): If true, skip entity checks (optional).



**Returns**

* *boolean, string*: True on success, or false and an error message.



**Realm**

`Server.`


**Example Usage**

```lua
local success, err = lia.item.setItemDataByID(1234, "durability", 80)
if success then
print("Durability updated!")
else
print("Error:", err)
end
```

---

### lia.item.instance

**Purpose**

Creates a new item instance in the database and in memory, optionally calling a callback when ready.


**Parameters**

* `index` (*number|string*): Inventory ID or uniqueID (see usage).
* `uniqueID` (*string*): The unique identifier of the item definition.
* `itemData` (*table*): Table of item data (optional).
* `x` (*number*): X position in inventory (optional).
* `y` (*number*): Y position in inventory (optional).
* `callback` (*function*): Function to call with the created item (optional).



**Returns**

* *deferred*: A deferred object that resolves to the created item.



**Realm**

`Server.`


**Example Usage**

```lua
lia.item.instance(0, "weapon_ak47", {durability = 100}, 1, 1, function(item)
print("Spawned AK47 item with ID:", item.id)
end)
```

---

### lia.item.deleteByID

**Purpose**

Deletes an item instance by its ID, removing it from memory and the database.


**Parameters**

* `id` (*number*): The unique ID of the item instance.



**Returns**

* None.



**Realm**

`Server.`


**Example Usage**

```lua
lia.item.deleteByID(1234)
```

---

### lia.item.loadItemByID

**Purpose**

Loads one or more item instances from the database by their IDs and restores them in memory.


**Parameters**

* `itemIndex` (*number|table*): A single item ID or a table of item IDs.



**Returns**

* None.



**Realm**

`Server.`


**Example Usage**

```lua
lia.item.loadItemByID({1001, 1002, 1003})
```

---

### lia.item.spawn

**Purpose**

Spawns a new item instance in the world at a given position and angle, optionally calling a callback.


**Parameters**

* `uniqueID` (*string*): The unique identifier of the item definition.
* `position` (*Vector*): The world position to spawn the item at.
* `callback` (*function*): Function to call with the spawned item (optional).
* `angles` (*Angle*): The angles to spawn the item with (optional).
* `data` (*table*): Table of item data (optional).



**Returns**

* *deferred*: A deferred object that resolves to the spawned item.



**Realm**

`Server.`


**Example Usage**

```lua
lia.item.spawn("weapon_ak47", Vector(0,0,0), function(item)
print("Spawned AK47 at origin with ID:", item.id)
end)
```

---

### lia.item.restoreInv

**Purpose**

Restores an inventory by its ID, setting its width and height, and calls a callback when ready.


**Parameters**

* `invID` (*number*): The unique ID of the inventory.
* `w` (*number*): The width to set.
* `h` (*number*): The height to set.
* `callback` (*function*): Function to call with the restored inventory (optional).



**Returns**

* None.



**Realm**

`Server.`


**Example Usage**

```lua
lia.item.restoreInv(1001, 4, 4, function(inv)
print("Restored inventory with size:", inv:getSize())
end)
```

---
