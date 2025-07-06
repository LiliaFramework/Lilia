# Panel Meta

Lilia's interface relies on VGUI panels with extra functionality. This document describes convenience methods available to those panels.

---

## Overview

Panel meta functions support scaled positioning, listen for inventory changes, and offer other utilities that make building responsive menus and HUD elements easier.

---

### liaListenForInventoryChanges

**Purpose**

Registers this panel to automatically receive inventory events for the provided inventory. The following events are forwarded to methods on the panel: `InventoryInitialized`, `InventoryDeleted`, `InventoryDataChanged`, `InventoryItemAdded`, and `InventoryItemRemoved`. `ItemDataChanged` is forwarded to `InventoryItemDataChanged` when the changed item belongs to this inventory.

Hooks are automatically removed when the inventory is deleted, but you should also call `liaDeleteInventoryHooks` in `OnRemove` to avoid stale hooks.

**Parameters**


* `inventory` (Inventory): Inventory to listen for updates.

**Realm**
`Client`

**Returns**


* `None`: This function does not return a value.

**Example**


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

### liaDeleteInventoryHooks

**Purpose**

Removes hooks added by `liaListenForInventoryChanges`. Supply an inventory ID to stop listening for just that inventory or omit the argument to clear all hooks.

**Parameters**


* `id` (number|nil): ID of the inventory to stop listening to, or nil to remove all.

**Realm**
`Client`

**Returns**


* `None`: This function does not return a value.

**Example**


```lua
function PANEL:OnRemove()
    -- Always clear listeners to avoid stale hooks
    self:liaDeleteInventoryHooks()
end
function PANEL:StopListening(id)
    -- Remove hooks for a specific inventory ID
    self:liaDeleteInventoryHooks(id)
end
```

---


### SetScaledPos

**Purpose**

Sets the panel position using `ScreenScale(x)` and `ScreenScaleH(y)`.

**Parameters**


* `x` (number): Horizontal position in screen scale units.

* `y` (number): Vertical position in screen scale units.

**Realm**
`Client`

**Returns**


* `None`: This function does not return a value.

**Example**


```lua
-- Position with screen scaling
panel:SetScaledPos(10, 20)
```

---

### SetScaledSize

**Purpose**

Sets the panel size using `ScreenScale(w)` and `ScreenScaleH(h)`.

**Parameters**


* `w` (number): Width in screen scale units.

* `h` (number): Height in screen scale units.

**Realm**
`Client`

**Returns**


* `None`: This function does not return a value.

**Example**


```lua
-- Size with screen scaling
panel:SetScaledSize(64, 32)
```

---
