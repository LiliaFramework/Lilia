# Menu Library

This page describes small menu creation helpers.

---

## Overview

The menu library offers convenience functions for building simple context menus. Menus are defined by label/callback pairs and automatically appear at the player's crosshair or attached to a specified entity. Active menus are stored in `lia.menu.list` on the client.

### Menu Entry Fields

Each entry inside `lia.menu.list` is a table with the following fields:

* `position` (Vector) – World position the menu is drawn at.

* `entity` (Entity|nil) – Entity to follow if attached.

* `items` (table) – Sorted array of `{label, callback}` pairs.

* `width` (number) – Calculated pixel width for rendering.

* `height` (number) – Total pixel height of all rows.

* `onRemove` (function|nil) – Executed when the menu is removed.

---
### lia.menu.add

**Purpose**

Creates a context menu from a table of label/callback pairs.

**Parameters**

* `opts` (*table*): Table of label to callback mappings.
* `pos` (*Vector|Entity|nil*): World position or entity to attach to.
* `onRemove` (*function|nil*): Function executed when the menu is removed.

**Realm**

`Client`

**Returns**

* `number`: Identifier for the created menu.

**Example**

```lua
local ent = LocalPlayer():GetEyeTrace().Entity
lia.menu.add({
    ["Greet"] = function() print("Hi") end
}, ent, function() print("menu closed") end)
```

---

### lia.menu.drawAll

**Purpose**

Draws all active menus on the player's HUD.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `nil`: Nothing.

**Example**

```lua
hook.Add("HUDPaintBackground", "DrawMenus", lia.menu.drawAll)
```
hook.Add("HUDPaintBackground", "DrawMenus", lia.menu.drawAll)
```

---

### lia.menu.getActiveMenu

**Purpose**

Returns the ID and callback of the option currently under the cursor.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `id` (*number|nil*): Index of the active menu.
* `callback` (*function|nil*): Callback for the hovered item.

**Example**

```lua
local id, callback = lia.menu.getActiveMenu()
if id then print("hovering option", id) end
```

---

### lia.menu.onButtonPressed

**Purpose**

Removes the menu with the given ID and runs its callback if available.

**Parameters**

* `id` (*number*): Identifier returned by `lia.menu.add`.
* `callback` (*function|nil*): Function executed after removal.

**Realm**

`Client`

**Returns**

* `boolean`: True if a callback was executed.

**Example**

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

#### Library Conventions

1. **Namespace**
   When formatting libraries, make sure to only document lia.* functions of that type. For example if you are documenting workshop.lua, you'd document lia.workshop functions .

2. **Shared Definitions**
   Omit any parameters or fields already documented in `docs/definitions.lua`.

3. **Internal-Only Functions**
   If this function is not meant to be used outside the internal scope of the gamemode, such as lia.module.load, add the “Internal function” note (see above).
