# GridInv Meta

Grid-based inventories extend the base inventory class with slot-based item placement. This document lists helper methods for managing grid dimensions and item arrangement.

---

## Overview

A `GridInv` instance stores items in a 2D grid, requiring items to fit within its width and height. It provides logic for finding free positions, transferring items, and updating ownership information.

### getWidth()

**Description:**

Returns the current width of the inventory grid.

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

Returns the current height of the inventory grid.

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

### findFreePosition(item)

**Description:**

Searches the grid for open space that can fit the given item.

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

Changes the grid dimensions on the server.

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

### requestTransfer(itemID, destID, x, y)

**Description:**

Asks the server to move an item to another inventory at the given position.

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
inv:requestTransfer(id, otherID, 1, 2)
```
---

