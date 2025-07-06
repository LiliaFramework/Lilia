# Inventory Meta

Inventories hold items for characters or in-world containers. This document lists methods for managing and syncing these item stores.

---

## Overview

Inventory meta functions handle transactions, capacity checks, retrieval by slot or ID, and persistent data storage. Inventories hold items in a grid layout and may belong to characters or world containers. The functions also manage network updates so clients remain in sync with server-side changes.

---

### getData

**Purpose**
Returns a stored data value for this inventory.

**Parameters**

* `key` (`string`): Data field key.
* `default` (`any`) – Value if the key does not exist.

**Realm**
`Shared`

**Returns**

* any: Stored value or default.

**Example**

```lua
function Inventory:getData(key, default)
    -- return any
end
```
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

* table: The newly derived inventory table.

**Example**

```lua
function Inventory:extend(className)
    -- return table
end
```
```lua
-- Define a subclass for weapon crates and register it
local WeaponInv = inv:extend("WeaponInventory")
function WeaponInv:configure()
    -- only allow weapons to be stored
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:configure()
    -- override to customize this inventory type
end
```
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
* `onChange` (`function`) – Callback receiving old and new values.

**Realm**
`Shared`

**Returns**

* None: This function does not return a value.

**Example**

```lua
function Inventory:addDataProxy(key, onChange)
    -- return nil
end
```
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
* `onlyMain` (`boolean`) – Search only the main item list.

**Realm**
`Shared`

**Returns**

* table: Table of matching item objects.

**Example**

```lua
function Inventory:getItemsByUniqueID(uniqueID, onlyMain)
    -- return table
end
```
```lua
-- Use each ammo box found in the main list
for _, box in ipairs(inv:getItemsByUniqueID("ammo_box", true)) do
    box:use()
end
```

---

### register

**Purpose**
Registers this inventory type with the lia.inventory system.

**Parameters**

* `typeID` (`string`): Unique identifier for this inventory type.

**Realm**
`Shared`

**Returns**

* None: This function does not return a value.

**Example**

```lua
function Inventory:register(typeID)
    -- persistence setup
end
```
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

* table: New inventory instance.

**Example**

```lua
function Inventory:new()
    -- return table
end
```
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

* string: Formatted as "ClassName[id]".

**Example**

```lua
function Inventory:tostring()
    -- return string
end
```
```lua
-- Print the identifier when debugging
print("Inventory: " .. inv:tostring())
```

---

### getType

**Purpose**
Retrieves the inventory type table from lia.inventory.

**Parameters**

* None

**Realm**
`Shared`

**Returns**

* table: Inventory type definition.

**Example**

```lua
function Inventory:getType()
    -- return table
end
```
```lua
-- Read slot data from the type definition
local def = inv:getType()
```

---

### onDataChanged

**Purpose**
Called when an inventory data field changes. Executes any registered proxy callbacks for that field.

**Parameters**

* `key` (`string`): Data field key.
* `oldValue` (`any`) – Previous value.
* `newValue` (`any`) – Updated value.

**Realm**
`Shared`

**Returns**

* None: This function does not return a value.

**Example**

```lua
function Inventory:onDataChanged(key, oldValue, newValue)
    -- callback after setData
end
```
```lua
-- React when a data value is updated
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

* table: Item instance table indexed by itemID.

**Example**

```lua
function Inventory:getItems()
    -- return table
end
```
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

* table: Array of matching items.

**Example**

```lua
function Inventory:getItemsOfType(itemType)
    -- return table
end
```
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

* Item|None: The first matching item or None.

**Example**

```lua
function Inventory:getFirstItemOfType(itemType)
    -- return item
end
```
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

* boolean: True if an item is found.

**Example**

```lua
function Inventory:hasItem(itemType)
    -- return boolean
end
```
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

* `itemType` (`string|None`): Item unique ID to count. Counts all if nil.

**Realm**
`Shared`

**Returns**

* number: Sum of quantities.

**Example**

```lua
function Inventory:getItemCount(itemType)
    -- return number
end
```
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

* number: Inventory identifier.

**Example**

```lua
function Inventory:getID()
    -- return number
end
```
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

* boolean: True if both inventories share the same ID.

**Example**

```lua
function Inventory:eq(other)
    -- return boolean
end
```
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
* `noReplicate` (`boolean`) – Skip network replication when true.

**Realm**
`Server`

**Returns**

* table: The inventory instance.

**Example**

```lua
function Inventory:addItem(item, noReplicate)
    -- return self
end
```
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

* table: The inventory instance.

**Example**

```lua
function Inventory:add(item)
    return self:addItem(item)
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:syncItemAdded(item)
    -- networking
end
```
```lua
inv:syncItemAdded(item)
```

---

### initializeStorage

**Purpose**
Creates a persistent inventory record in the database using the supplied initial data.

**Parameters**

* `initialData` (`table`): Values to store when creating the inventory.

**Realm**
`Server`

**Returns**

* Deferred: Resolves with the new inventory ID.

**Example**

```lua
function Inventory:initializeStorage(initialData)
    -- return Deferred
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:restoreFromStorage()
end
```
```lua
inv:restoreFromStorage()
```

---

### removeItem

**Purpose**
Removes an item by ID and optionally deletes it.

**Parameters**

* `itemID` (`number`): Unique item identifier.
* `preserveItem` (`boolean`) – Keep item in database when true.

**Realm**
`Server`

**Returns**

* Deferred: Resolves once the item removal completes.

**Example**

```lua
function Inventory:removeItem(itemID, preserveItem)
    -- return Deferred
end
```
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

* Deferred: Resolves once the item is removed.

**Example**

```lua
function Inventory:remove(itemID)
    return self:removeItem(itemID)
end
```
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
* `value` (`any`) – Value to store.

**Realm**
`Server`

**Returns**

* table: The inventory instance.

**Example**

```lua
function Inventory:setData(key, value)
    -- persistence
end
```
```lua
inv:setData("locked", true)
```

---

### canAccess

**Purpose**
Evaluates access rules to determine whether an action is permitted.

**Parameters**

* `action` (`string`): Action identifier.
* `context` (`table|None`) – Additional data such as the client.

**Realm**
`Server`

**Returns**

* boolean|nil: True, false, or nil if undecided.
* string|nil – Optional failure reason.

**Example**

```lua
function Inventory:canAccess(action, context)
    -- return boolean, reason
end
```
```lua
local allowed = inv:canAccess("take", {client = ply})
```

---

### addAccessRule

**Purpose**
Registers a function used by `canAccess` to grant or deny actions.

**Parameters**

* `rule` (`function`): Access rule function.
* `priority` (`number|None`) – Insertion position for the rule.

**Realm**
`Server`

**Returns**

* table: The inventory instance.

**Example**

```lua
function Inventory:addAccessRule(rule, priority)
    -- return self
end
```
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

* table: The inventory instance.

**Example**

```lua
function Inventory:removeAccessRule(rule)
    -- return self
end
```
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

* table: Array of Player objects.

**Example**

```lua
function Inventory:getRecipients()
    -- return table
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:onInstanced()
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:onLoaded()
end
```
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

* Deferred: Resolves with a table of loaded items.

**Example**

```lua
function Inventory:loadItems()
    -- return Deferred
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:onItemsLoaded(items)
end
```
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

* `initialData` (`table|None`): Data to populate the inventory with.

**Realm**
`Server`

**Returns**

* Deferred: Resolves with the created inventory.

**Example**

```lua
function Inventory:instance(initialData)
    -- return Deferred
end
```
```lua
WeaponInv:instance({char = charID}):next(function(inv) end)
```

---

### syncData

**Purpose**
Sends a single data field to clients.

**Parameters**

* `key` (`string`): Field to replicate.
* `recipients` (`table|None`) – Player recipients.

**Realm**
`Server`

**Returns**

* None: This function does not return a value.

**Example**

```lua
function Inventory:syncData(key, recipients)
    -- networking
end
```
```lua
-- Sync the locked state to nearby players
inv:syncData("locked", recipients)
```

---

### sync

**Purpose**
Sends the entire inventory and its items to players.

**Parameters**

* `recipients` (`table|None`): Player recipients.

**Realm**
`Server`

**Returns**

* None: This function does not return a value.

**Example**

```lua
function Inventory:sync(recipients)
    -- networking
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:delete()
    -- persistence
end
```
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

* None: This function does not return a value.

**Example**

```lua
function Inventory:destroy()
    -- cleanup
end
```
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

* `parent` (`Panel|None`): Optional parent panel.

**Realm**
`Client`

**Returns**

* Panel: The created inventory UI panel.

**Example**

```lua
function Inventory:show(parent)
    -- returns Panel
end
```
```lua
inv:show()
-- or attach to an existing panel
local ui = inv:show(parentPanel)
```

---
