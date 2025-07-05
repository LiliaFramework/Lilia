# Panel Meta

Lilia's interface relies on VGUI panels with extra functionality. This document describes convenience methods available to those panels.

---

## Overview

Panel meta functions support scaled positioning, listen for inventory changes, and offer other utilities that make building responsive menus and HUD elements easier.

---

### liaListenForInventoryChanges(inventory)

**Description:**

Registers this panel to automatically receive inventory events for the provided inventory. When hooks such as `InventoryItemAdded`, `InventoryItemRemoved`, or `InventoryDeleted` fire, the panel's methods of the same name are called. `ItemDataChanged` events are forwarded to `InventoryItemDataChanged` when the item belongs to the watched inventory.

**Parameters:**

* inventory (Inventory) – Inventory to listen for updates.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
function PANEL:setInventory(inv)
    self.inventory = inv
    self:liaListenForInventoryChanges(inv)
end

function PANEL:InventoryItemAdded(item)
    print("Added item:", item:getName())
end
```

---

### liaDeleteInventoryHooks(id)

**Description:**

Removes hooks added by `liaListenForInventoryChanges`. Supply an inventory ID to stop listening for just that inventory or omit the argument to clear all hooks.

**Parameters:**

* id (number|nil) – ID of the inventory to stop listening to, or nil to remove all.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
function PANEL:OnRemove()
    -- Always clear listeners to avoid stale hooks
    self:liaDeleteInventoryHooks()
end
```
---


### SetScaledPos(x, y)

**Description:**

Sets the panel position using `ScreenScale(x)` and `ScreenScaleH(y)`.

**Parameters:**

* x (number) – Horizontal position in screen scale units.
* y (number) – Vertical position in screen scale units.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Position with screen scaling
panel:SetScaledPos(10, 20)
```

---

### SetScaledSize(w, h)

**Description:**

Sets the panel size using `ScreenScale(w)` and `ScreenScaleH(h)`.

**Parameters:**

* w (number) – Width in screen scale units.
* h (number) – Height in screen scale units.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua
-- Size with screen scaling
panel:SetScaledSize(64, 32)
```

---
