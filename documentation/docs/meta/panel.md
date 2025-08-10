# Panel Meta

Lilia's interface relies on VGUI panels with extra functionality.

This document describes convenience methods available to those panels.

---

## Overview

Panel meta functions support scaled positioning, listen for inventory changes, and offer other utilities that make building responsive menus and HUD elements easier.

---

### liaListenForInventoryChanges

**Purpose**

Sets up hooks so this panel reacts to activity on an `Inventory`. Any existing hooks for the same inventory are removed first. When inventory events fire the panel calls its own method with the same name (or `InventoryItemDataChanged` for `ItemDataChanged`) and appends the inventory as the final argument. Each hook confirms the panel still exists and implements the handler before invoking it. Hooks are automatically removed if the inventory is deleted.

The following events are forwarded:

* `InventoryInitialized`
* `InventoryDeleted`
* `InventoryDataChanged`
* `InventoryItemAdded`
* `InventoryItemRemoved`
* `ItemDataChanged` → `InventoryItemDataChanged` (only if the item belongs to the inventory)

**Parameters**

* `inventory` (*Inventory*): Required inventory to listen to. An error is thrown if `nil`.

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function PANEL:setInventory(inv)
    self.inventory = inv
    self:liaListenForInventoryChanges(inv)
end

function PANEL:InventoryItemAdded(item, inv)
    print("Added:", item:getName(), "to", inv:getID())
end

function PANEL:InventoryItemDataChanged(item, key, oldValue, newValue, inv)
    print(item, "changed", key, "from", oldValue, "to", newValue)
end
```

---

### liaDeleteInventoryHooks

**Purpose**

Removes hooks created by `liaListenForInventoryChanges`. Useful for cleaning up when the panel is removed or no longer needs updates. Calling this on an inventory that has no hooks has no effect. If called with `nil`, all tracked inventories are cleared.

**Parameters**

* `id` (*number|nil*): Inventory ID to stop listening to. Defaults to `nil`, which removes hooks for all tracked inventories.

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function PANEL:OnRemove()
    self:liaDeleteInventoryHooks()
end

function PANEL:StopListening(id)
    self:liaDeleteInventoryHooks(id)
end
```

---

### SetScaledPos

**Purpose**

Wrapper around `SetPos` that converts the provided coordinates using
`ScreenScale` and `ScreenScaleH` for resolution‑independent layouts.

**Parameters**

* `x` (*number*): Horizontal position before scaling. Required.
* `y` (*number*): Vertical position before scaling. Required.

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
panel:SetScaledPos(10, 20)
```

---

### SetScaledSize

**Purpose**

Wrapper around `SetSize` that scales the supplied width and height using
`ScreenScale` and `ScreenScaleH`.

**Parameters**

* `w` (*number*): Unscaled width. Required.
* `h` (*number*): Unscaled height. Required.

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
panel:SetScaledSize(64, 32)
```

---
