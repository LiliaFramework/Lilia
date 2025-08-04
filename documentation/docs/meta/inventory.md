# Inventory Meta

Inventories hold items for characters or in-world containers.

This document lists methods for managing and syncing these item stores.

---

## Overview

Inventory-meta functions handle transactions, capacity checks, retrieval by slot or ID, and persistent data storage.

Inventories keep items in a grid layout and may belong to characters or world containers.

The helpers also manage network updates so clients remain in sync with server-side changes.

---

### getData

**Purpose**

Returns a stored data value for this inventory.

**Parameters**

* `key` (`string`): Data field key.

* `default` (`any`): Value to return when the key is absent.

**Realm**

`Shared`

**Returns**

* `any`: Stored value or default.

**Example Usage**

```lua
-- Read how many times the container was opened
local opens = inv:getData("openCount", 0)
```

---

### extend

**Purpose**

Creates a subclass of the inventory meta table with a new class name.

**Parameters**

* `className` (`string`): Name of the subclass meta table.

**Realm**

`Shared`

**Returns**

* `table`: The newly derived inventory table.

**Example Usage**

```lua
-- Define a subclass for weapon crates and register it
local WeaponInv = inv:extend("WeaponInventory")

function WeaponInv:configure()
    self:addAccessRule(function(_, action, ctx)
        if action == "add" then
            return ctx.item.isWeapon == true
        end
    end)
end

WeaponInv:register("weapon_inv")
```

---

### configure

**Purpose**

Stub for inventory configuration; meant to be overridden.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Called from a subclass to register custom access rules
function WeaponInv:configure()
    self:addAccessRule(function(_, action, ctx)
        if action == "add" then
            return ctx.item.isWeapon
        end
    end)
end
```

---

### addDataProxy

**Purpose**

Adds a proxy function that is called when a data field changes.

**Parameters**

* `key` (`string`): Data field to watch.

* `onChange` (`function`): Callback receiving old and new values.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Track changes to the "locked" data field
inv:addDataProxy("locked", function(old, new)
    print("Locked state changed", old, new)
    hook.Run("ChestLocked", inv, new)
end)
```

---

### getItemsByUniqueID

**Purpose**

Returns all items in the inventory matching the given unique ID.

**Parameters**

* `uniqueID` (`string`): Item unique identifier.

* `onlyMain` (`boolean`): Search only the main item list.

**Realm**

`Shared`

**Returns**

* `table`: Table of matching item objects.

**Example Usage**

```lua
-- Use each ammo box found in the main list
for _, box in ipairs(inv:getItemsByUniqueID("ammo_box", true)) do
    box:use()
end
```

---

### register

**Purpose**

Registers this inventory type with the `lia.inventory` system.

**Parameters**

* `typeID` (`string`): Unique identifier for this inventory type.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Register and then immediately create the inventory type
WeaponInv:register("weapon_inv")
local chestInv = WeaponInv:new()
```

---

### new

**Purpose**

Creates a new inventory of this type.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table`: New inventory instance.

**Example Usage**

```lua
-- Create an inventory and attach it to a spawned chest entity
local chest = ents.Create("prop_physics")
chest:SetModel("models/props_junk/wood_crate001a.mdl")
chest:Spawn()

chest.inv = WeaponInv:new()
```

---

### tostring

**Purpose**

Returns a printable representation of this inventory.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Formatted as `"ClassName[id]"`.

**Example Usage**

```lua
-- Print the identifier when debugging
print("Inventory: " .. inv:tostring())
```

---

### getType

**Purpose**

Retrieves the inventory type table from `lia.inventory`.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table`: Inventory type definition.

**Example Usage**

```lua
-- Read slot data from the type definition
local def = inv:getType()
```

---

### onDataChanged

**Purpose**

Called when an inventory data field changes and executes any registered proxy callbacks.

**Parameters**

* `key` (`string`): Data field key.

* `oldValue` (`any`): Previous value.

* `newValue` (`any`): Updated value.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
function WeaponInv:onDataChanged(key, old, new)
    print(key .. " changed from", old, "to", new)
end
```

---

### getItems

**Purpose**

Returns all items stored in this inventory.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table`: Item instance table indexed by itemID.

**Example Usage**

```lua
-- Sum the weight of all items
local totalWeight = 0

for _, itm in pairs(inv:getItems()) do
    totalWeight = totalWeight + itm.weight
end

print("Weight:", totalWeight)
```

---

### getItemsOfType

**Purpose**

Collects all items that match the given unique ID.

**Parameters**

* `itemType` (`string`): Item unique identifier.

**Realm**

`Shared`

**Returns**

* `table`: Array of matching items.

**Example Usage**

```lua
-- List all medkits currently in the inventory
local kits = inv:getItemsOfType("medkit")
```

---

### getFirstItemOfType

**Purpose**

Retrieves the first item matching the given unique ID.

**Parameters**

* `itemType` (`string`): Item unique identifier.

**Realm**

`Shared`

**Returns**

* `Item|nil`: The first matching item or `nil`.

**Example Usage**

```lua
-- Grab the first pistol found in the inventory
local pistol = inv:getFirstItemOfType("pistol")
```

---

### hasItem

**Purpose**

Determines whether the inventory contains an item type.

**Parameters**

* `itemType` (`string`): Item unique identifier.

**Realm**

`Shared`

**Returns**

* `boolean`: True if an item is found.

**Example Usage**

```lua
-- See if any health potion exists
if inv:hasItem("health_potion") then
    print("You have a potion ready!")
end
```

---

### getItemCount

**Purpose**

Counts the total quantity of a specific item type.

**Parameters**

* `itemType` (`string|nil`): Item unique ID to count; counts all if `nil`.

**Realm**

`Shared`

**Returns**

* `number`: Sum of quantities.

**Example Usage**

```lua
-- Count the total number of bullets
local ammoTotal = inv:getItemCount("bullet")
print("Ammo remaining:", ammoTotal)
```

---

### getID

**Purpose**

Returns the unique database ID of this inventory.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Inventory identifier.

**Example Usage**

```lua
-- Store the inventory ID on its container entity
entity:setNetVar("invID", inv:getID())
```

---

### eq

**Purpose**

Compares two inventories by ID for equality.

**Parameters**

* `other` (`Inventory`): Other inventory to compare.

**Realm**

`Shared`

**Returns**

* `boolean`: True if both inventories share the same ID.

**Example Usage**

```lua
-- Check if two chests share the same inventory record
if inv:eq(other) then
    print("Duplicate inventory")
end
```

---

### addItem

**Purpose**

Inserts an item instance into this inventory and persists it.

**Parameters**

* `item` (`Item`): Item to add.

* `noReplicate` (`boolean`): Skip network replication when true.

**Realm**

`Server`

**Returns**

* `table`: The inventory instance.

**Example Usage**

```lua
-- Add a looted item to the inventory
if not inv:hasItem(item.uniqueID) then
    inv:addItem(item, false)
end
```

---

### add

**Purpose**

Alias for `addItem` that inserts an item into the inventory.

**Parameters**

* `item` (`Item`): Item to add.

**Realm**

`Server`

**Returns**

* `table`: The inventory instance.

**Example Usage**

```lua
inv:add(item)
```

---

### syncItemAdded

**Purpose**

Replicates a newly added item to all clients that can access the inventory.

**Parameters**

* `item` (`Item`): Item instance that was added.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
inv:syncItemAdded(item)
```

---

### initializeStorage

**Purpose**

Creates a persistent inventory record in the database using supplied initial data.

**Parameters**

* `initialData` (`table`): Values to store when creating the inventory.

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves with the new inventory ID.

**Example Usage**

```lua
WeaponInv:initializeStorage({char = charID, locked = true}):next(function(id)
    print("Created inventory", id)
end)
```

---

### restoreFromStorage

**Purpose**

Stub called when loading an inventory from custom storage systems.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
inv:restoreFromStorage()
```

---

### removeItem

**Purpose**

Removes an item by ID and optionally deletes it.

**Parameters**

* `itemID` (`number`): Unique item identifier.

* `preserveItem` (`boolean`): Keep item in database when true.

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves once the item removal completes.

**Example Usage**

```lua
-- Remove an item but keep it saved for later
inv:removeItem(itemID, true):next(function()
    print("Item stored for later")
end)
```

---

### remove

**Purpose**

Alias for `removeItem` that removes an item from the inventory.

**Parameters**

* `itemID` (`number`): Unique item identifier.

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves once the item is removed.

**Example Usage**

```lua
inv:remove(itemID):next(function()
    print("Removed from the container")
end)
```

---

### setData

**Purpose**

Sets a data field on the inventory and replicates the change to clients.

**Parameters**

* `key` (`string`): Data field name.

* `value` (`any`): Value to store.

**Realm**

`Server`

**Returns**

* `table`: The inventory instance.

**Example Usage**

```lua
inv:setData("locked", true)
```

---

### canAccess

**Purpose**

Evaluates access rules to determine whether an action is permitted.

**Parameters**

* `action` (`string`): Action identifier.

* `context` (`table|nil`): Additional data such as the client.

**Realm**

`Server`

**Returns**

* `boolean|nil`: True, false, or `nil` if undecided.

* `string|nil`: Optional failure reason.

**Example Usage**

```lua
local allowed = inv:canAccess("take", {client = ply})
```

---

### addAccessRule

**Purpose**

Registers a function used by `canAccess` to grant or deny actions.

**Parameters**

* `rule` (`function`): Access rule function.

* `priority` (`number|nil`): Insertion position for the rule.

**Realm**

`Server`

**Returns**

* `table`: The inventory instance.

**Example Usage**

```lua
inv:addAccessRule(function(inv, action, ctx)
    return ctx.client:IsAdmin()
end)
```

---

### removeAccessRule

**Purpose**

Unregisters a previously added access rule.

**Parameters**

* `rule` (`function`): The rule to remove.

**Realm**

`Server`

**Returns**

* `table`: The inventory instance.

**Example Usage**

```lua
inv:removeAccessRule(myRule)
```

---

### getRecipients

**Purpose**

Returns a list of players that should receive network updates for this inventory.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `table`: Array of `Player` objects.

**Example Usage**

```lua
local receivers = inv:getRecipients()
```

---

### onInstanced

**Purpose**

Called after a new inventory is created in the database.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
function WeaponInv:onInstanced()
    print("Created inventory", self:getID())
end
```

---

### onLoaded

**Purpose**

Called after an inventory is loaded from the database.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
function WeaponInv:onLoaded()
    print("Loaded inventory", self:getID())
end
```

---

### loadItems

**Purpose**

Loads all items belonging to this inventory from storage.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves with a table of loaded items.

**Example Usage**

```lua
inv:loadItems():next(function(items)
    print("Loaded", table.Count(items), "items")
end)
```

---

### onItemsLoaded

**Purpose**

Hook called after `loadItems` finishes loading all items.

**Parameters**

* `items` (`table`): Loaded items indexed by ID.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
function WeaponInv:onItemsLoaded(items)
    print("Ready with", #items, "items")
end
```

---

### instance

**Purpose**

Creates and stores a new inventory instance of this type.

**Parameters**

* `initialData` (`table|nil`): Data to populate the inventory with.

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves with the created inventory.

**Example Usage**

```lua
WeaponInv:instance({char = charID}):next(function(inv)
    -- use inventory
end)
```

---

### syncData

**Purpose**

Sends a single data field to clients.

**Parameters**

* `key` (`string`): Field to replicate.

* `recipients` (`table|nil`): Player recipients.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Sync the locked state to nearby players
inv:syncData("locked", recipients)
```

---

### sync

**Purpose**

Sends the entire inventory and its items to players.

**Parameters**

* `recipients` (`table|nil`): Player recipients.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Send all items to the owner after they join
inv:sync({owner})
```

---

### delete

**Purpose**

Removes this inventory record from the database.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Permanently delete a chest inventory on cleanup
inv:delete()
print("Inventory removed from database")
```

---

### destroy

**Purpose**

Destroys all items and removes network references.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Clear all items when the container entity is removed
inv:destroy()
print("Inventory destroyed")
```

---

### show

**Purpose**

Opens the inventory user interface on the client.

**Parameters**

* `parent` (`Panel|nil`): Optional parent panel.

**Realm**

`Client`

**Returns**

* `Panel`: The created inventory UI panel.

**Example Usage**

```lua
-- Open as a stand-alone window
inv:show()

-- Or attach to an existing panel
local ui = inv:show(parentPanel)
```

---
