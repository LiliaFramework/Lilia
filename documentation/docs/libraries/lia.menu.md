# Menu Library

This page describes small menu-creation helpers.

---

## Overview

The menu library offers convenience functions for building simple context menus. Menus are defined by label/callback pairs and automatically appear at the player’s cross-hair or attached to a specified entity. Active menus are stored in `lia.menu.list` on the client.

### Menu-entry fields

Each entry in `lia.menu.list` is a table containing:

* `position` (*Vector*) – World position where the menu is drawn.

* `entity` (*Entity | nil*) – Entity the menu follows, if attached.

* `items` (*table*) – Sorted array of `{ label, callback }` pairs.

* `width` (*number*) – Pixel width used for rendering.

* `height` (*number*) – Combined pixel height of all rows.

* `onRemove` (*function | nil*) – Executed when the menu is removed.

---

### lia.menu.add

**Purpose**

Creates a context menu from a table of label/callback pairs.

**Parameters**

* `opts` (*table*): Map of label → callback.

* `pos` (*Vector | Entity | nil*): World position or entity to attach to.

* `onRemove` (*function | nil*): Function executed when the menu is removed.

**Realm**

`Client`

**Returns**

* *number*: Identifier for the created menu.

**Example Usage**

```lua
local ent = LocalPlayer():GetEyeTrace().Entity

lia.menu.add({
    ["Greet"] = function()
        print("Hi")
    end
}, ent, function()
    print("menu closed")
end)
```

---

### lia.menu.drawAll

**Purpose**

Draws every active menu on the player’s HUD.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
hook.Add("HUDPaintBackground", "DrawMenus", lia.menu.drawAll)
```

---

### lia.menu.getActiveMenu

**Purpose**

Returns the ID and callback of the menu item currently under the cursor.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *number | nil*: ID of the active menu.

* *function | nil*: Callback for the hovered item.

**Example Usage**

```lua
local id, cb = lia.menu.getActiveMenu()

if id then
    print("Hovering option", id)
end
```

---

### lia.menu.onButtonPressed

**Purpose**

Removes the menu with the given ID and runs its callback (if present).

**Parameters**

* `id` (*number*): Identifier returned by `lia.menu.add`.

* `callback` (*function | nil*): Function executed after removal.

**Realm**

`Client`

**Returns**

* *boolean*: `true` if a callback executed.

**Example Usage**

```lua
hook.Add("PlayerBindPress", "MenuClick", function(client, bind, pressed)
    if pressed and (bind:find("use") or bind:find("attack")) then
        local id, cb = lia.menu.getActiveMenu()

        if id then
            return lia.menu.onButtonPressed(id, cb)
        end
    end
end)
```

---
