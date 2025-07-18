# Panel Meta

Lilia's interface relies on VGUI panels with extra functionality.

This document describes convenience methods available to those panels.

---

## Overview

Panel meta functions support scaled positioning, listen for inventory changes, and offer other utilities that make building responsive menus and HUD elements easier.

---

### liaListenForInventoryChanges

**Purpose**

Registers this panel to forward inventory events from the given inventory to matching panel methods.

**Parameters**

* `inventory` (*Inventory*): Inventory whose events will be forwarded.

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

function PANEL:InventoryItemAdded(item)
    print("Added item:", item:getName())
end
```

---

### liaDeleteInventoryHooks

**Purpose**

Removes hooks previously added by `liaListenForInventoryChanges`.

**Parameters**

* `id` (*number|nil*): ID of the inventory to stop listening to, or nil to remove all listeners.

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

Sets the panel position using `ScreenScale( x )` and `ScreenScaleH( y )`.

**Parameters**

* `x` (*number*): Horizontal position in screen-scale units.

* `y` (*number*): Vertical position in screen-scale units.

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

Sets the panel size using `ScreenScale( w )` and `ScreenScaleH( h )`.

**Parameters**

* `w` (*number*): Width in screen-scale units.

* `h` (*number*): Height in screen-scale units.

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
panel:SetScaledSize(64, 32)
```

---
