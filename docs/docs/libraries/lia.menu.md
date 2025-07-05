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

### lia.menu.add

**Description:**

Creates a context menu from the given options table. Each key is the label shown and each value is the function run when selected.

When an entity is supplied the menu follows that entity. Otherwise the player's eye trace position is used.

**Parameters:**

* `opts` (`table`) – Table of label/callback pairs.


* `pos` (`Vector|Entity|nil`) – Optional world position or entity to attach the menu to.

* `onRemove` (`function|nil`) – Function executed when the menu is removed.


**Realm:**

* Client


**Returns:**

* number – Identifier for the created menu entry.


**Example Usage:**

```lua
-- Attach a menu to the entity the player is looking at
local ent = LocalPlayer():GetEyeTrace().Entity
lia.menu.add({
    ["Greet"] = function() print("Hi") end
}, ent, function() print("menu closed") end)
```

---

### lia.menu.drawAll

**Description:**

Draws all active menus on the player's HUD. It should be called from HUDPaint or similar hooks.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Draw menus each frame
hook.Add("HUDPaintBackground", "DrawMenus", lia.menu.drawAll)
```

---

### lia.menu.getActiveMenu

**Description:**

Returns the ID and callback of the option currently under the cursor. Often used with PlayerBindPress to trigger selections.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* `id` (`number|nil`) – Index of the active menu.


* `callback` (`function|nil`) – Callback for the hovered item.


**Example Usage:**

```lua
-- Check which option is under the crosshair
local id, callback = lia.menu.getActiveMenu()
if id then print("hovering option", id) end
```

---

### lia.menu.onButtonPressed

**Description:**

Removes the menu with the given ID and executes its callback if present.

**Parameters:**

* `id` (`number`) – Identifier returned by lia.menu.add.


* `callback` (`function|nil`) – Function to execute after removal.


**Realm:**

* Client


**Returns:**

* boolean – True if a callback was executed.


**Example Usage:**

```lua
-- Activate menu options when Use or Attack is pressed
hook.Add("PlayerBindPress", "MenuClick", function(client, bind, pressed)
    if pressed and (bind:find("use") or bind:find("attack")) then
        local id, cb = lia.menu.getActiveMenu()
        if id then
            return lia.menu.onButtonPressed(id, cb)
        end
    end
end)
```

