# GridInv Meta

Grid-based inventories extend the base inventory class with slot-based item placement.

This document lists helper methods for managing grid dimensions and item arrangement.

---

## Overview

A `GridInv` instance stores items in a 2-D grid, requiring items to fit within its width and height.

It provides logic for finding free positions, transferring items, and updating ownership information.

---

### getWidth

**Purpose**

Returns the current width of the inventory grid.

If no width has been set, the value from `lia.config.get("invW")` is used.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Grid width in slots.

**Example Usage**

```lua
local width = inv:getWidth()
print("Inventory width:", width)
```

---

### getHeight

**Purpose**

Returns the current height of the inventory grid.

Defaults to `lia.config.get("invH")` when unset.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Grid height in slots.

**Example Usage**

```lua
local height = inv:getHeight()
print("Inventory height:", height)
```

---

### getSize

**Purpose**

Returns both grid dimensions at once.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`, `number`: Width and height in slots.

**Example Usage**

```lua
local w, h = inv:getSize()
print(string.format("Size: %dx%d", w, h))
```

---

### canItemFitInInventory

**Purpose**

Checks if an item would fit inside the grid bounds when placed at the given
coordinates. Coordinates start at `1` and the item must remain entirely within
the inventory. This does **not** test collisions with other items.

**Parameters**

* `item` (`Item`): Item being tested.

* `x` (`number`): X slot position (1-indexed).

* `y` (`number`): Y slot position (1-indexed).

**Realm**

`Shared`

**Returns**

* `boolean`: True if the entire item lies within the grid.

**Example Usage**

```lua
if inv:canItemFitInInventory(item, 2, 3) then
    print("Item fits at (2,3)")
end
```

---

### canAdd

**Purpose**

Determines if the inventory is large enough to hold the item's dimensions.
It accepts either an `Item` instance or a unique ID string. Width and height
values on the item must be positive numbers. The check also allows the item to
fit when rotated.

**Parameters**

* `item` (`Item|string`): Item table or unique ID to test.

**Realm**

`Shared`

**Returns**

* `boolean`: True when the item size fits inside the grid.

**Example Usage**

```lua
if inv:canAdd("pistol_ammo") then
    print("Ammo can be stored")
end
```

---

### doesItemOverlapWithOther

**Purpose**

Returns whether `testItem` placed at `(x, y)` would overlap the given existing
item. Items without stored `x`/`y` positions are ignored. Used internally when
checking placement validity.

**Parameters**

* `testItem` (`Item`): Item being placed.

* `x` (`number`): Proposed X slot.

* `y` (`number`): Proposed Y slot.

* `item` (`Item`): Existing item inside the inventory.

**Realm**

`Shared`

**Returns**

* `boolean`: True if the two items intersect.

**Example Usage**

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

**Purpose**

Checks this inventory **and all nested bags** to see if the item could be placed somewhere.

**Parameters**

* `item` (`Item|string`): Item instance or unique ID to test.

**Realm**

`Shared`

**Returns**

* `boolean`: True if a free position exists.

**Example Usage**

```lua
if inv:doesFitInventory(item) then
    print("There is room for the item")
end
```

---

### doesItemFitAtPos

**Purpose**

Determines if `testItem` can be placed at `(x, y)` without overlapping existing items and while staying inside the grid.

**Parameters**

* `testItem` (`Item`): Item to check.

* `x` (`number`): X slot position.

* `y` (`number`): Y slot position.

**Realm**

`Shared`

**Returns**

* `boolean`: True when placement is valid.

* `Item|nil`: Conflicting item if placement fails, or `nil` when a reserved
  slot blocks placement.

**Example Usage**

```lua
local ok, blocking = inv:doesItemFitAtPos(item, 2, 2)
if not ok and blocking then
    print("Item collides with", blocking:getName())
end
```

---

### findFreePosition

**Purpose**

Searches the grid sequentially for the **first** open space that can fit the given item.

**Parameters**

* `item` (`Item`): Item to place.

**Realm**

`Shared`

**Returns**

* `number|nil`, `number|nil`: X and Y slot coordinates, or `nil` if none found.

**Example Usage**

```lua
local x, y = inv:findFreePosition(item)
if x and y then
    print("Space found at", x, y)
end
```

---

### configure

**Purpose**

Called when the inventory type registers.

On the server it adds the `CanNotAddItemIfNoSpace` and
`CanAccessInventoryIfCharacterIsOwner` access rules to prevent placement of
items that do not fit and to restrict access to the owner.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
function MyInv:configure()
    self:super().configure(self)
end
```

---

### getItems

**Purpose**

Returns a table of items contained in this inventory.

When `noRecurse` is `false` (default), items inside nested bags are also
returned.

**Parameters**

* `noRecurse` (`boolean`): Skip nested bag contents when true (defaults to `false`).

**Realm**

`Shared`

**Returns**

* `table`: Item table indexed by item ID.

**Example Usage**

```lua
for id, itm in pairs(inv:getItems()) do
    print(id, itm.uniqueID)
end
```

---

### setSize

**Purpose**

Updates the stored grid dimensions **on the server**.

**Parameters**

* `w` (`number`): New width in slots.

* `h` (`number`): New height in slots.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Expand the inventory to 6×4 slots
inv:setSize(6, 4)
```

---

### wipeItems

**Purpose**

Removes **all** items from the inventory.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
inv:wipeItems()
```

---

### setOwner

**Purpose**

Sets the owning character of this inventory.

A `Player` value is automatically converted to their character ID.

Non-number values that are not players with characters are ignored. When
`fullUpdate` is `true` the inventory is synced to that owner immediately.

**Parameters**

* `owner` (`number|Player`): Character ID or `Player` to own the inventory.

* `fullUpdate` (`boolean`): Send a full sync to the owner (defaults to `false`).

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
inv:setOwner(client, true)
```

---

### add

**Purpose**

Inserts an item into the inventory at the given position.

Extra quantity that cannot fit triggers the `OnPlayerLostStackItem` hook.

Coordinates can be omitted and the first free position will be used.

When the third argument is a table it acts as item data and the second argument
is treated as a quantity to spawn. If no coordinates are supplied the first free
slot (possibly inside a nested bag) is used. Passing a quantity for a
non-stackable item simply spawns one instance.

**Parameters**

* `itemTypeOrItem` (`Item|string`): Item instance or unique ID to add.

* `xOrQuantity` (`number`): X slot or stack quantity. When used as a quantity this defaults to `1` (optional).

* `yOrData` (`number|table`): Y slot or data table. Supplying a table treats the second argument as a quantity.

* `noReplicate` (`boolean`): Skip networking new items to clients (defaults to `false`).

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves with the created item or a table of items when multiple
  are spawned or merged into existing stacks.

**Example Usage**

```lua
inv:add("pistol_ammo", 1, 1):next(function(itm)
    print("Added", itm.uniqueID)
end)
```

---

### remove

**Purpose**

Removes an item by ID **or type**.

Quantity defaults to `1` and must be a positive number.

**Parameters**

* `itemTypeOrID` (`number|string`): Item ID or unique ID.

* `quantity` (`number`): Amount to remove (defaults to `1`).

**Realm**

`Server`

**Returns**

* `Deferred`: Resolves once removal finishes.

**Example Usage**

```lua
inv:remove("pistol_ammo", 2):next(function()
    print("Ammo removed")
end)
```

---

### requestTransfer

**Purpose**

Sends a `liaTransferItem` request telling the server to move an item.
The call is ignored if the destination inventory is missing or the item already
occupies the given coordinates. When the target position falls outside the
destination's bounds, `destinationID` is sent as `nil`. The server processes
this call through the `HandleItemTransferRequest` hook.

**Parameters**

* `itemID` (`number`): ID of the item to move.

* `destinationID` (`number`): Destination inventory ID.

* `x` (`number`): Target X slot.

* `y` (`number`): Target Y slot.

**Realm**

`Client`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Move the item into another inventory
inv:requestTransfer(id, bag:getID(), 1, 2)
```

---
