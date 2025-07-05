# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It supports registering new inventory types and handles item transfers between them.

---

### lia.inventory.newType

**Description:**

Registers a new inventory type.

**Parameters:**

* `typeID` (`string`) — unique identifier


* `invTypeStruct` (`table`) — definition matching InvTypeStructType


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

### lia.inventory.new

**Description:**

Instantiates a new inventory instance.

**Parameters:**

* `typeID` (`string`)


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

### lia.inventory.loadByID

**Description:**

Loads an inventory by ID (cached or via custom loader).

**Parameters:**

* `id` (`number`), noCache? (boolean)


**Realm:**

* Server


**Returns:**

* deferred — resolves to the inventory or `nil` if not found


**Example Usage:**

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

**Description:**

Default database loader.

**Parameters:**

* `id` (`number`), noCache? (boolean)


**Realm:**

* Server


**Returns:**

* deferred — resolves to the inventory or `nil`


**Example Usage:**

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

**Description:**

Creates & persists a new inventory instance.

**Parameters:**

* `typeID` (`string`), initialData? (table)


**Realm:**

* Server


**Returns:**

* deferred — resolves to the created inventory instance


**Example Usage:**

```lua
    -- Create a persistent bag inventory for character 1
    lia.inventory.instance("bag", {char = 1}):next(function(inventory)
        print("New inventory", inventory:getID())
    end)
```

---

### lia.inventory.loadAllFromCharID

**Description:**

Loads all inventories for a character.

**Parameters:**

* `charID` (`number`)


**Realm:**

* Server


**Returns:**

* deferred — resolves to a table of the player's inventories


**Example Usage:**

```lua
    -- Retrieve all inventories owned by the local player
    lia.inventory.loadAllFromCharID(client:getChar():getID()):next(function(inventories)
        PrintTable(inventories)
    end)
```

---

### lia.inventory.deleteByID

**Description:**

Deletes an inventory from both memory and persistent storage.

**Parameters:**

* `id` (`number`)


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

### lia.inventory.cleanUpForCharacter

**Description:**

Destroys all inventories associated with a character.

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

### lia.inventory.show

**Description:**

Displays inventory UI client‑side.

**Parameters:**

* inventory, parent


**Realm:**

* Client


**Returns:**

* Panel — VGUI element representing the inventory


**Example Usage:**

```lua
    -- Display the local player's inventory in a panel
    local inv = LocalPlayer():getChar():getInv()
    if inv then
        local panel = lia.inventory.show(inv)
    end
```
