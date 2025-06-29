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

### SetScaledPos(x, y)

**Description:**
Positions the panel using screen scale units.

**Parameters:**
* x (number) – Horizontal position using `ScreenScale`.
* y (number) – Vertical position using `ScreenScaleH`.

**Realm:**
* Client

### SetScaledSize(w, h)

**Description:**
Sizes the panel using screen scale units.

**Parameters:**
* w (number) – Width using `ScreenScale`.
* h (number) – Height using `ScreenScaleH`.

**Realm:**
* Client
