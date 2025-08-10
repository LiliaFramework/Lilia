# Menu Library

Client-side helpers for simple world-space context menus.

---

## Overview

The menu library offers convenience functions for building simple context menus. Menus are defined by label/callback pairs and automatically appear at the player's crosshair or follow a specified entity. Active menus are stored in `lia.menu.list` on the client. Menus fade when the player looks away and are removed if the player moves more than **96 units** away or the attached entity becomes invalid.

### Menu-entry fields

Each entry in `lia.menu.list` is a table containing:

* `position` (*Vector*) – World position where the menu is drawn.
* `entity` (*Entity | nil*) – Entity the menu follows, if attached.
* `items` (*table*) – Sorted array of `{ label, callback }` pairs.
* `width` (*number*) – Pixel width based on the longest label plus 24px padding.
* `height` (*number*) – Total height of all rows (each row is 28px).
* `onRemove` (*function | nil*) – Executed when the menu is removed.
* `alpha` (*number*) – Internal fade alpha used while drawing.
* `displayed` (*boolean | nil*) – Internal flag used for fade-in logic.
* `entPos` (*Vector | nil*) – Internal cached position for attached entities.

---

### lia.menu.add

**Purpose**

Creates a context menu from a table of label/callback pairs.

**Parameters**

* `opts` (*table*): Map of label → callback. Labels are converted to strings and sorted alphabetically.
* `pos` (*Vector | Entity | nil*): World position for the menu or entity to attach to. When an entity is supplied, the menu tracks that entity at the point under the player's crosshair. Defaults to the player's eye-trace hit position.
* `onRemove` (*function | nil*): Function executed when the menu is removed for any reason (player moves away, entity becomes invalid, manual removal, etc.).

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

Draws each active menu and handles fade-in/fade-out. Menus fade when the player looks away and are removed if the player moves too far or the attached entity becomes invalid.

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

Returns the ID and callback of the menu item currently under the player's crosshair.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *number | nil*: ID of the active menu.
* *function | nil*: Callback for the hovered item.

**Notes**

Only menus within 96 units and under the player's crosshair are considered.

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
* `cb` (*function | nil*): Function executed after removal.

**Realm**

`Client`

**Returns**

* *boolean*: `true` if `cb` executed, otherwise `false`.

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
