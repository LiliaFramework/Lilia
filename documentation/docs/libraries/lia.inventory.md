# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It supports registering new inventory types and handles item transfers between them.

---

### lia.inventory.newType

**Purpose**

Registers a new inventory type.

**Parameters**

* `typeID` (*string*): Unique identifier.

* `invTypeStruct` (*table*): Definition matching `InvTypeStructType`.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a simple “bag” type
lia.inventory.newType("bag", { className = "liaBag" })
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

* *table*: The created inventory object.

**Example Usage**

```lua
local inv = lia.inventory.new("bag")
```

---

### lia.inventory.loadByID

**Purpose**

Loads an inventory by ID (cached or via custom loader).

**Parameters**

* `id` (*number*): Inventory ID.

* `noCache` (*boolean*): Bypass caching when `true`.

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

Default SQL loader used by `lia.inventory.loadByID` when no custom loader is provided.

**Parameters**

* `id` (*number*): Inventory ID.

* `noCache` (*boolean*): Bypass caching when `true`.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the inventory or `nil`.

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

Creates and persists a new inventory instance.

**Parameters**

* `typeID` (*string*): Inventory type identifier.

* `initialData` (*table*): Optional initial data.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the created inventory instance.

**Example Usage**

```lua
lia.inventory.instance("bag", { char = 1 }):next(function(inventory)
    print("New inventory", inventory:getID())
end)
```

---

### lia.inventory.loadAllFromCharID

**Purpose**

Loads every inventory that belongs to a character.

**Parameters**

* `charID` (*number*): Character ID.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to a table of inventories.

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

Deletes an inventory from memory and persistent storage.

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

Destroys every inventory associated with a character.

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

Displays an inventory UI panel on the client.

**Parameters**

* `inventory` (*table*): Inventory to display.

* `parent` (*Panel*): Optional parent panel.

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
