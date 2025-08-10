# Inventory Library

This page documents inventory handling functions.

---

## Overview

The inventory library manages item containers and grid inventories. It maintains a registry of inventory types in `lia.inventory.types` and caches loaded inventories in `lia.inventory.instances`. New inventory types can be registered and item transfers between inventories are handled automatically.

---

### lia.inventory.newType

**Purpose**

Registers a new inventory type and validates that the structure matches
`InvTypeStructType` before storing it for later use.

**Parameters**

* `typeID` (*string*): Unique identifier. Must not already be registered.

* `invTypeStruct` (*table*): Definition matching `InvTypeStructType`. Must include `__index`, `typeID`, and `className`; server-side definitions may also provide `add`, `remove`, and `sync` functions.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

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

Creates and persists a new inventory instance, allocating storage and caching
the result.

**Parameters**

* `typeID` (*string*): Inventory type identifier. Must refer to a registered type.

* `initialData` (*table*): Optional initial data. Defaults to an empty table and must be a table if provided.

**Realm**

`Server`

**Returns**

* *deferred*: Resolves to the created inventory instance.

**Example Usage**

```lua
lia.inventory.instance("bag", { char = 1 }):next(function(inventory)
    print("New inventory", inventory.id)
end)
```

---

### lia.inventory.loadAllFromCharID

**Purpose**

Loads every inventory that belongs to a character. If `charID` cannot be converted to a number the returned deferred is rejected and an error is logged.

**Parameters**

* `charID` (*number*): Character ID. Must be numeric.

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

