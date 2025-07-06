# GridInv Meta

Grid-based inventories extend the base inventory class with slot-based item placement. This document lists helper methods for managing grid dimensions and item arrangement.

---

## Overview

A `GridInv` instance stores items in a 2D grid, requiring items to fit within its width and height. It provides logic for finding free positions, transferring items, and updating ownership information.

### getWidth

Description: Returns the current width of the inventory grid. If no width has been set, the value from `lia.config.invW` is used.
Parameters:
- None
Realm: Shared
Returns:
- number: Grid width in slots.
- *Example:**

```lua
local width = inv:getWidth()
print("Inventory width:", width)
```

---

### getHeight

Description: Returns the current height of the inventory grid. Defaults to `lia.config.invH` when unset.
Parameters:
- None
Realm: Shared
Returns:
- number: Grid height in slots.
- *Example:**

```lua
local height = inv:getHeight()
print("Inventory height:", height)
```

---

### getSize

Description: Returns both grid dimensions at once.
Parameters:
- None
Realm: Shared
Returns:
- number, number: Width and height in slots.
- *Example:**

```lua
local w, h = inv:getSize()
print(string.format("Size: %dx%d", w, h))
```

---

### canItemFitInInventory

Description: Checks if an item would fit inside the grid bounds when placed at the given coordinates. This does not test collisions with other items.
Parameters:
- `item` (`Item`): Item being tested.
- `x` (`number`) – X slot position.

- `y` (`number`) – Y slot position.

Realm: Shared
Returns:
- boolean: True if the entire item lies within the grid.
- *Example:**

```lua
if inv:canItemFitInInventory(item, 2, 3) then
    print("Item fits at (2,3)")
end
```

---

### canAdd

Description: Determines if the inventory is large enough to hold the item's dimensions. Accepts either an Item object or a unique ID.
Parameters:
- `item` (`Item|string`): Item table or unique ID to test.
Realm: Shared
Returns:
- boolean: True when the item size fits inside the grid.
- *Example:**

```lua
if inv:canAdd("pistol_ammo") then
    print("Ammo can be stored")
end
```

---

### doesItemOverlapWithOther

Description: Returns whether `testItem` placed at `(x, y)` would overlap the given existing item. Used internally when checking placement validity.
Parameters:
- `testItem` (`Item`): Item being placed.
- `x` (`number`) – Proposed X slot.

- `y` (`number`) – Proposed Y slot.

- `item` (`Item`) – Existing item inside the inventory.

Realm: Shared
Returns:
- boolean: True if the two items intersect.
- *Example:**

```lua
for _, existing in pairs(inv:getItems(true)) do
    if inv:doesItemOverlapWithOther(newItem, 1, 1, existing) then
        print("Spot is blocked")
        break
    end
end
```

---

### doesFitInventory

Description: Checks this inventory and all nested bags to see if the item could be placed somewhere.
Parameters:
- `item` (`Item`): Item to test.
Realm: Shared
Returns:
- boolean: True if a free position exists.
- *Example:**

```lua
if inv:doesFitInventory(item) then
    print("There is room for the item")
end
```

---

### doesItemFitAtPos

Description: Determines if `testItem` can be placed at `(x, y)` without overlapping existing items and while staying inside the grid.
Parameters:
- `testItem` (`Item`): Item to check.
- `x` (`number`) – X slot position.

- `y` (`number`) – Y slot position.

Realm: Shared
Returns:
- boolean: True when placement is valid.
- Item|nil – Conflicting item if placement fails.

- *Example:**

```lua
local ok, blocking = inv:doesItemFitAtPos(item, 2, 2)
if not ok and blocking then
    print("Item collides with", blocking:getName())
end
```

---

### findFreePosition

Description: Searches the grid sequentially for the first open space that can fit the given item.
Parameters:
- `item` (`Item`): Item to place.
Realm: Shared
Returns:
- number|nil, number|nil: X and Y slot coordinates or nil if none found.
- *Example:**

```lua
local x, y = inv:findFreePosition(item)
if x and y then
    print("Space found at", x, y)
end
```

---

### configure

Description: Called when the inventory type registers. On the server it adds default access rules preventing players from placing items that do not fit and restricting access to the owner.
Parameters:
- None
Realm: Shared
Returns:
- None: This function does not return a value.
- *Example:**

```lua
function MyInv:configure()
    self:super().configure(self)
end
```

---

### getItems

Description: Returns a table of items contained in this inventory. When `noRecurse` is false, items inside nested bags are also returned.
Parameters:
- `noRecurse` (`boolean`): Skip nested bag contents when true.
Realm: Shared
Returns:
- table: Item table indexed by item ID.
- *Example:**

```lua
for id, itm in pairs(inv:getItems()) do
    print(id, itm.uniqueID)
end
```

---

### setSize

Description: Updates the stored grid dimensions on the server.
Parameters:
- `w` (`number`): New width in slots.
- `h` (`number`) – New height in slots.

Realm: Server
Returns:
- None: This function does not return a value.
- *Example:**

```lua
-- Expand the inventory to 6x4 slots
inv:setSize(6, 4)
```

---

### wipeItems

Description: Removes all items from the inventory.
Parameters:
- None
Realm: Server
Returns:
- None: This function does not return a value.
- *Example:**

```lua
inv:wipeItems()
```

---

### setOwner

Description: Sets the owning character of this inventory. A player value is automatically converted to their character ID. When `fullUpdate` is true the inventory is synced to that owner immediately.
Parameters:
- `owner` (`number|Player`): Character ID or Player to own the inventory.
- `fullUpdate` (`boolean`) – Send a full sync to the owner.

Realm: Server
Returns:
- None: This function does not return a value.
- *Example:**

```lua
inv:setOwner(client, true)
```

---

### add

Description: Inserts an item into the inventory at the given position. Extra quantity that cannot fit triggers the `OnPlayerLostStackItem` hook.
Parameters:
- `item` (`Item|string`): Item instance or unique ID to add.
- `x` (`number`) – X slot, optional.

- `y` (`number`) – Y slot, optional.

Realm: Server
Returns:
- Deferred: Resolves with the newly added item(s).
- *Example:**

```lua
inv:add("pistol_ammo", 1, 1):next(function(itm)
    print("Added", itm.uniqueID)
end)
```

---

### remove

Description: Removes an item by ID or type. Quantity defaults to `1`.
Parameters:
- `itemID` (`number|string`): Item ID or unique ID.
- `quantity` (`number`) – Amount to remove.

Realm: Server
Returns:
- Deferred: Resolves once removal finishes.
- *Example:**

```lua
inv:remove("pistol_ammo", 2):next(function()
    print("Ammo removed")
end)
```

---

### requestTransfer

Description: Sends a `liaTransferItem` request telling the server to move an item. The server processes this call through the `HandleItemTransferRequest` hook.
Parameters:
- `itemID` (`number`): ID of the item to move.
- `destID` (`number`) – Destination inventory ID.

- `x` (`number`) – Target X slot.

- `y` (`number`) – Target Y slot.

Realm: Client
Returns:
- None: This function does not return a value.
- *Example:**

```lua
-- Move the item into another inventory
inv:requestTransfer(id, bag:getID(), 1, 2)
```
