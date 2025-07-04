# GridInv Meta

Grid-based inventories extend the base inventory class with slot-based item placement. This document lists helper methods for managing grid dimensions and item arrangement.

---

## Overview

A `GridInv` instance stores items in a 2D grid, requiring items to fit within its width and height. It provides logic for finding free positions, transferring items, and updating ownership information.

### getWidth()

**Description:**

Returns the current width of the inventory grid. If no width has been set,
the value from `lia.config.invW` is used.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Grid width in slots.

**Example:**

```lua
local w = inv:getWidth()
``` 
---

### getHeight()

**Description:**

Returns the current height of the inventory grid. Defaults to
`lia.config.invH` when unset.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Grid height in slots.

**Example:**

```lua
local h = inv:getHeight()
```
---

### getSize()

**Description:**

Returns both grid dimensions at once.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number, number – Width and height in slots.

**Example:**

```lua
local w, h = inv:getSize()
```
---

### findFreePosition(item)

**Description:**

Searches the grid sequentially for the first open space that can fit the given
item.

**Parameters:**

* item (Item) – Item to place.

**Realm:**

* Shared

**Returns:**

* number|nil, number|nil – X and Y slot coordinates or nil if none found.

**Example:**

```lua
local x, y = inv:findFreePosition(item)
```
---

### setSize(w, h)

**Description:**

Updates the stored grid dimensions on the server.

**Parameters:**

* w (number) – New width in slots.
* h (number) – New height in slots.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
inv:setSize(6, 4)
```
---

### add(item, x, y)

**Description:**

Inserts an item into the inventory at the given position. Extra quantity that
cannot fit triggers the `OnPlayerLostStackItem` hook.

**Parameters:**

* item (Item|string) – Item instance or unique ID to add.
* x (number) – X slot, optional.
* y (number) – Y slot, optional.

**Realm:**

* Server

**Returns:**

* Deferred – Resolves with the newly added item(s).

**Example:**

```lua
inv:add("pistol_ammo", 1, 1)
```
---

### remove(itemID, quantity)

**Description:**

Removes an item by ID or type. Quantity defaults to `1`.

**Parameters:**

* itemID (number|string) – Item ID or unique ID.
* quantity (number) – Amount to remove.

**Realm:**

* Server

**Returns:**

* Deferred – Resolves once removal finishes.

**Example:**

```lua
inv:remove("pistol_ammo", 2)
```
---

### requestTransfer(itemID, destID, x, y)

**Description:**

Sends a `liaTransferItem` request telling the server to move an item. The
server processes this call through the `HandleItemTransferRequest` hook.

**Parameters:**

* itemID (number) – ID of the item to move.
* destID (number) – Destination inventory ID.
* x (number) – Target X slot.
* y (number) – Target Y slot.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Move the item into another inventory
inv:requestTransfer(id, bag:getID(), 1, 2)
```
---

