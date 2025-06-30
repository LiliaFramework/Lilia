# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It supports registering new inventory types and handles item transfers between them.

---

### lia.inventory.newType(typeID, invTypeStruct)
**Description:**

Registers a new inventory type.

**Parameters:**

* typeID (string) — unique identifier

* invTypeStruct (table) — definition matching InvTypeStructType

**Realm:**

* Shared

**Returns:**

* None

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.newType
    lia.inventory.newType("bag", {className = "liaBag"})
```

---

### lia.inventory.new(typeID)
**Description:**

Instantiates a new inventory instance.

**Parameters:**

* typeID (string)

**Realm:**

* Shared

**Returns:**

* table

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.new
    local inv = lia.inventory.new("bag")
```

---

### lia.inventory.loadByID(id, noCache)
**Description:**

Loads an inventory by ID (cached or via custom loader).

**Parameters:**

* id (number), noCache? (boolean)

**Realm:**

* Server

**Returns:**

* deferred

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.loadByID
    lia.inventory.loadByID(1):next(function(inv) print(inv) end)
```

---

### lia.inventory.loadFromDefaultStorage(id, noCache)
**Description:**

Default database loader.

**Parameters:**

* id (number), noCache? (boolean)

**Realm:**

* Server

**Returns:**

* deferred

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.loadFromDefaultStorage
    lia.inventory.loadFromDefaultStorage(1)
```

---

### lia.inventory.instance(typeID, initialData)
**Description:**

Creates & persists a new inventory instance.

**Parameters:**

* typeID (string), initialData? (table)

**Realm:**

* Server

**Returns:**

* deferred

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.instance
    lia.inventory.instance("bag", {charID = 1})
```

---

### lia.inventory.loadAllFromCharID(charID)
**Description:**

Loads all inventories for a character.

**Parameters:**

* charID (number)

**Realm:**

* Server

**Returns:**

* deferred

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.loadAllFromCharID
    lia.inventory.loadAllFromCharID(client:getChar():getID())
```

---

### lia.inventory.deleteByID(id)
**Description:**

Deletes an inventory and its data.

**Parameters:**

* id (number)

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.deleteByID
    lia.inventory.deleteByID(1)
```

---

### lia.inventory.cleanUpForCharacter(character)
**Description:**

Destroys all inventories for a character.

**Parameters:**

* character

**Realm:**

* Server

**Returns:**

* None

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.cleanUpForCharacter
    lia.inventory.cleanUpForCharacter(client:getChar())
```

---

### lia.inventory.show(inventory, parent)
**Description:**

Displays inventory UI client‑side.

**Parameters:**

* inventory, parent

**Realm:**

* Client

**Returns:**

* Panel

**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.inventory.show
    local panel = lia.inventory.show(inv)
```

