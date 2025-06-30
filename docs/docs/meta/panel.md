# Panel Meta

Lilia's interface relies on VGUI panels with extra functionality. This document describes convenience methods available to those panels.

---

## Overview

Panel meta functions support scaled positioning, listen for inventory changes, and offer other utilities that make building responsive menus and HUD elements easier.

---

### liaListenForInventoryChanges(inventory)

**Description:**

Subscribes this panel to updates for a specific inventory.

**Parameters:**

* inventory (Inventory) – Inventory to watch for changes.

**Realm:**

* Client

**Example Usage:**

* None – This function does not return a value.

**Example:**

```lua
panel:liaListenForInventoryChanges(player:getChar():getInv())
```
---

### liaDeleteInventoryHooks(id)

**Description:**

Removes inventory update hooks created by `liaListenForInventoryChanges`.

**Parameters:**

* id (number) – ID of the inventory to stop listening to.

**Realm:**

* Client
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Remove all registered hooks for this panel
panel:liaDeleteInventoryHooks()
```
---

### SetScaledPos(x, y)

**Description:**

Positions the panel using screen scale units.

**Parameters:**

* x (number) – Horizontal position using `ScreenScale`.
* y (number) – Vertical position using `ScreenScaleH`.

**Realm:**

* Client
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Position the panel 10 units from the left and 20 units down
panel:SetScaledPos(10, 20)
```
---

### SetScaledSize(w, h)

**Description:**

Sizes the panel using screen scale units.

**Parameters:**

* w (number) – Width using `ScreenScale`.
* h (number) – Height using `ScreenScaleH`.

**Realm:**

* Client
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Set panel size to 64 by 32 scaled units
panel:SetScaledSize(64, 32)
```
---
