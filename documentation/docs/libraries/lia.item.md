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

Retrieves an item definition by its identifier, checking both `lia.item.base` and `lia.item.list`.

**Parameters**

* `identifier` (*string*): The unique identifier of the item.

**Realm**

`Shared`

**Returns**

* *table | nil*: The item table if found, otherwise `nil`.

**Example Usage**

```lua
local itemDef = lia.item.get("testItem")
```

---

### lia.item.getItemByID

**Purpose**

Retrieves an item instance by its numeric item ID and reports whether it is in an inventory, the world, or unknown.

**Parameters**

* `itemID` (*number*): Numeric item ID.

**Realm**

`Shared`

**Returns**

* `table | nil`: `{ item = <item>, location = <string> }` when found.
* `string | nil`: error message when not found.

**Example Usage**

```lua
local result, err = lia.item.getItemByID(42)
if result then
    print("Item location:", result.location)
else
    print("Error:", err)
end
```

---

### lia.item.getInstancedItemByID

**Purpose**

Returns the item instance table itself without location information.

**Parameters**

* `itemID` (*number*): Numeric item ID.

**Realm**

`Shared`

**Returns**

* `table | nil`: Item instance when found.
* `string | nil`: error message when not found.

**Example Usage**

```lua
local inst, err = lia.item.getInstancedItemByID(42)
if inst then
    print("Got item:", inst.name)
else
    print("Error:", err)
end
```

---

### lia.item.getItemDataByID

**Purpose**

Retrieves the `data` table of an item instance by its ID.

**Parameters**

* `itemID` (*number*): Numeric item ID.

**Realm**

`Shared`

**Returns**

* `table | nil`: Data table when found.
* `string | nil`: error message when not found.

**Example Usage**

```lua
local data, err = lia.item.getItemDataByID(42)
if data then
    print("Item data found.")
else
    print("Error:", err)
end
```

---

### lia.item.load

**Purpose**

Generates a `uniqueID` from a file path and registers the item via `lia.item.register`. Used when loading items from directories.

**Parameters**

* `path` (*string*): Path to the Lua file.

* `baseID` (*string*): Base item unique ID to inherit from. *Optional*.

* `isBaseItem` (*boolean*): Register as a base item. *Optional*.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.load("lilia/gamemode/items/base/outfit.lua", nil, true)
```

---

### lia.item.isItem

**Purpose**

Checks whether an object is recognised as an item.

**Parameters**

* `object` (*any*): Object to test.

**Realm**

`Shared`

**Returns**

* *boolean*: `true` if the object is an item.

**Example Usage**

```lua
if lia.item.isItem(myObject) then
    print("It's an item!")
end
```

---

### lia.item.getInv

**Purpose**

Returns an inventory table by its ID from `lia.inventory.instances`.

**Parameters**

* `invID` (*number*): Inventory ID.

**Realm**

`Shared`

**Returns**

* *table | nil*: Inventory or `nil`.

**Example Usage**

```lua
local inv = lia.item.getInv(5)
if inv then
    print("Got inventory with ID 5")
end
```

---

### lia.item.register

**Purpose**

Registers a new item or base item. Sets up its metatable, merges data from the specified base, and optionally includes the file.

**Parameters**

* `uniqueID` (*string*): Item unique ID.

* `baseID` (*string*): Base item ID. *Optional*.

* `isBaseItem` (*boolean*): Register as a base item. *Optional*.

* `path` (*string*): Optional file path.

* `luaGenerated` (*boolean*): `true` if generated in code.

**Realm**

`Shared`

**Returns**

* *table*: The registered item table.

**Example Usage**

```lua
lia.item.register("special_item", "base_item", false, "path/to/item.lua")
```

---

### lia.item.loadFromDir

**Purpose**

Loads item Lua files from a directory. Base items load first, then sub-folders (prefixed `base_`), then loose files. Fires the `InitializedItems` hook after completion.

**Parameters**

* `directory` (*string*): Directory path.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.loadFromDir("lilia/gamemode/items")
```

---

### lia.item.new

**Purpose**

Creates an item instance from a registered definition and stores it in `lia.item.instances`. Re-using an ID for the same uniqueID returns the existing instance.

**Parameters**

* `uniqueID` (*string*): Item definition ID.

* `id` (*number*): Numeric instance ID.

**Realm**

`Shared`

**Returns**

* *table*: Newly created (or existing) item instance.

**Example Usage**

```lua
local item = lia.item.new("testItem", 101)
print(item.id) -- 101
```

---

### lia.item.registerInv

**Purpose**

Registers an inventory type with fixed width and height.

**Parameters**

* `invType` (*string*): Inventory type name.

* `w` (*number*): Width.

* `h` (*number*): Height.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.registerInv("smallInv", 4, 4)
```

---

### lia.item.newInv

**Purpose**

Asynchronously creates a new inventory of a given type for a character owner and synchronises it to them when online.

**Parameters**

* `owner` (*number*): Character ID.

* `invType` (*string*): Registered inventory type.

* `callback` (*function*): Receives the new inventory. *Optional*.

**Realm**

`Server`

**Returns**

* *nil*: Uses a deferred internally.

**Example Usage**

```lua
lia.item.newInv(10, "smallInv", function(inv)
    print("New inventory created:", inv.id)
end)
```

---

### lia.item.createInv

**Purpose**

Creates a `GridInv` instance with given size and ID, caching it in `lia.inventory.instances`.

**Parameters**

* `w` (*number*): Width.

* `h` (*number*): Height.

* `id` (*number*): Inventory ID.

**Realm**

`Shared`

**Returns**

* *table*: The created inventory.

**Example Usage**

```lua
local inv = lia.item.createInv(6, 6, 200)
print("Inventory ID:", inv.id)
```

---

### lia.item.addWeaponOverride

**Purpose**

Overrides properties used when automatically generating weapon items from scripted weapons.

**Parameters**

* `className` (*string*): Weapon class.

* `data` (*table*): Keys such as `name`, `desc`, `category`, `model`, `class`, `width`, `height`, `weaponCategory`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.addWeaponOverride("weapon_pistol", {
    name = "Old Pistol",
    model = "models/weapons/w_pist_deagle.mdl"
})
```

---

### lia.item.addWeaponToBlacklist

**Purpose**

Prevents a weapon class from being auto-generated as an item.

**Parameters**

* `className` (*string*): Weapon class.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.addWeaponToBlacklist("weapon_physgun")
```

---

### lia.item.generateWeapons

**Purpose**

Registers item definitions for all scripted weapons that are not blacklisted. Called automatically after modules initialise.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.generateWeapons()
```

---

### lia.item.setItemDataByID

**Purpose**

Sets a key/value pair in an item’s `data` table by ID, optionally saving, notifying receivers, or skipping entity checks.

**Parameters**

* `itemID` (*number*): Item ID.

* `key` (*string*): Data key.

* `value` (*any*): New value.

* `receivers` (*table*): Player list to receive update. *Optional*.

* `noSave` (*boolean*): Do not immediately save when `true`.

* `noCheckEntity` (*boolean*): Skip entity validity check.

**Realm**

`Server`

**Returns**

* *boolean*: `true` on success, `false` otherwise.
* `string | nil`: Error message when unsuccessful.

**Example Usage**

```lua
local ok, err = lia.item.setItemDataByID(50, "durability", 90)
if not ok then
    print("Error:", err)
end
```

---

### lia.item.instance

**Purpose**

Creates a new item in the database (optionally assigning it to an inventory) and returns it via a deferred.

**Parameters**

* `index` (*number | string*): Inventory ID or uniqueID if uniqueID omitted.

* `uniqueID` (*string*): Item uniqueID when `index` is invID.

* `itemData` (*table*): Data to store. *Optional*.

* `x` (*number*): Grid X. *Optional*.

* `y` (*number*): Grid Y. *Optional*.

* `callback` (*function*): Receives the item. *Optional*.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the new item.

**Example Usage**

```lua
lia.item.instance("testItem", { quality = 1 }):next(function(item)
    print("Item created:", item.id)
end)
```

---

### lia.item.deleteByID

**Purpose**

Deletes an item from memory and the database.

**Parameters**

* `id` (*number*): Item ID.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
lia.item.deleteByID(42)
```

---

### lia.item.loadItemByID

**Purpose**

Loads one or multiple items from the database by ID and builds instances in memory.

**Parameters**

* `itemIndex` (*number | table*): Single ID or table of IDs.

**Realm**

`Server`

**Returns**

* *nil*: Runs asynchronously.

**Example Usage**

```lua
lia.item.loadItemByID({ 10, 11, 12 })
```

---

### lia.item.spawn

**Purpose**

Creates a new item instance and spawns a matching entity at a position/angle in the world.

**Parameters**

* `uniqueID` (*string*): Item definition ID.

* `position` (*Vector*): World position.

* `callback` (*function*): Receives the spawned item. *Optional*.

* `angles` (*Angle*): Spawn angles. *Optional*.

* `data` (*table*): Additional item data. *Optional*.

**Realm**

`Server`

**Returns**

* *deferred | nil*: Deferred when no callback, else `nil`.

**Example Usage**

```lua
lia.item.spawn("testItem", vector_origin, function(item)
    print("Spawned", item.uniqueID, "at", item.entity:GetPos())
end)
```

---

### lia.item.restoreInv

**Purpose**

Loads an inventory by ID, sets its dimensions, and optionally triggers a callback.

**Parameters**

* `invID` (*number*): Inventory ID.

* `w` (*number*): Width.

* `h` (*number*): Height.

* `callback` (*function*): Called once loaded. *Optional*.

**Realm**

`Server`

**Returns**

* *nil*: Runs asynchronously.

**Example Usage**

```lua
lia.item.restoreInv(101, 5, 5, function(inv)
    print("Restored inventory 101")
end)
```

---
