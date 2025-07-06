# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It supports registering new inventory types and handles item transfers between them.

### Fields

* **lia.inventory.types** (table) – Registered inventory classes indexed by type ID.
* **lia.inventory.instances** (table) – Loaded inventory instances indexed by ID.

---

### lia.inventory.newType

**Purpose**

Registers a new inventory type.

**Parameters**

* `typeID` (*string*): Unique identifier.
* `invTypeStruct` (*table*): Definition matching InvTypeStructType.

**Realm**

`Shared`

**Returns**

* `nil`: None.

**Example**

```lua
-- This snippet demonstrates a common usage of lia.inventory.newType
lia.inventory.newType("bag", {className = "liaBag"})
```

---

### lia.inventory.new

**Purpose**

Instantiates a new inventory instance.

**Parameters**

* `typeID` (*string*): Inventory type identifier.

**Realm**

`Shared`

**Returns**

* `table`: The created inventory object.

**Example**

```lua
-- This snippet demonstrates a common usage of lia.inventory.new
local inv = lia.inventory.new("bag")
```

---

### lia.inventory.loadByID

**Purpose**

Loads an inventory by ID (cached or via custom loader).

**Parameters**

* `id` (*number*): Inventory ID.
* `noCache` (*boolean*): Optional flag to bypass caching.

**Realm**

`Server`

**Returns**

* `deferred`: Resolves to the inventory or `nil` if not found.

**Example**

```lua
-- Asynchronously load inventory ID 1
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

Default database loader.

**Parameters**

* `id` (*number*): Inventory ID.
* `noCache` (*boolean*): Optional flag to bypass caching.

**Realm**

`Server`

**Returns**

* `deferred`: Resolves to the inventory or `nil`.

**Example**

```lua
-- Use the built‑in SQL loader to fetch inventory 1
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

Creates and persists a new inventory instance.

**Parameters**

* `typeID` (*string*): Inventory type identifier.
* `initialData` (*table*): Optional initial data.

**Realm**

`Server`

**Returns**

* `deferred`: Resolves to the created inventory instance.

**Example**

```lua
-- Create a persistent bag inventory for character 1
lia.inventory.instance("bag", {char = 1}):next(function(inventory)
    print("New inventory", inventory:getID())
end)
```

---

### lia.inventory.loadAllFromCharID

**Purpose**

Loads all inventories for a character.

**Parameters**

* `charID` (*number*): Character ID.

**Realm**

`Server`

**Returns**

* `deferred`: Resolves to a table of the player's inventories.

**Example**

```lua
-- Retrieve all inventories owned by the local player
lia.inventory.loadAllFromCharID(client:getChar():getID()):next(function(inventories)
    PrintTable(inventories)
end)
```

---

### lia.inventory.deleteByID

**Purpose**

Deletes an inventory from both memory and persistent storage.

**Parameters**

* `id` (*number*): Inventory ID.

**Realm**

`Server`

**Returns**

* `nil`: None.

**Example**

```lua
-- This snippet demonstrates a common usage of lia.inventory.deleteByID
lia.inventory.deleteByID(1)
```

---

### lia.inventory.cleanUpForCharacter

**Purpose**

Destroys all inventories associated with a character.

**Parameters**

* `character` (*Player*): Character to clean up.

**Realm**

`Server`

**Returns**

* `nil`: None.

**Example**

```lua
-- This snippet demonstrates a common usage of lia.inventory.cleanUpForCharacter
lia.inventory.cleanUpForCharacter(client:getChar())
```

---

### lia.inventory.show

**Purpose**

Displays inventory UI client‑side.

**Parameters**

* `inventory` (*table*): Inventory to display.
* `parent` (*Panel*): Optional parent panel.

**Realm**

`Client`

**Returns**

* `Panel`: VGUI element representing the inventory.

**Example**

```lua
-- Display the local player's inventory in a panel
local inv = LocalPlayer():getChar():getInv()
if inv then
    local panel = lia.inventory.show(inv)
end
```
