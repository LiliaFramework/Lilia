# Bars Library

This page describes the API for status bars displayed on the HUD.

---

## Overview

The bars library manages health, stamina, and other progress bars shown on the player's HUD. It lets you register custom bar callbacks, draws them every frame, and provides helpers for temporary action bars. Bars automatically fade out after a few seconds unless kept visible. The `BarsAlwaysVisible` configuration option overrides this behaviour, keeping bars visible whenever they have a value above zero. The hooks `ShouldHideBars` and `ShouldBarDraw` allow modules to control when bars are rendered.

Default health, armor, and stamina bars are registered automatically when the client loads.

For a breakdown of bar fields, refer to the [Bar Fields documentation](../definitions/bars.md).

---

### lia.bar.get

**Purpose**

Retrieves a bar object by its unique identifier.

**Parameters**

* `identifier` (*string*): The unique identifier of the bar to retrieve.

**Realm**

`Client`

**Returns**

* *table or nil*: The bar table if found, or `nil` if not found.

**Example Usage**

```lua
-- Retrieve the health bar and keep it visible
local bar = lia.bar.get("health")
if bar then
    bar.color = Color(0, 200, 0)
    bar.visible = true
end
```

---

### lia.bar.add

**Purpose**

Adds a new bar or replaces an existing one in the bar list.

If the identifier matches an existing bar, the old bar is removed first. Bars are drawn in order of ascending priority.

**Parameters**

* `getValue` (*function*): Callback returning the current value of the bar.

* `color` (*Color*): Fill colour for the bar. Defaults to a random pastel colour.

* `priority` (*number*): Draw order; lower values draw first. Defaults to end of list.

* `identifier` (*string*): Optional unique identifier for the bar.

**Realm**

`Client`

**Returns**

* *number*: The priority assigned to the added bar.

**Example Usage**

```lua
-- Add a custom health bar with high priority
local prio = lia.bar.add(function()
    local client = LocalPlayer()
    return client:Health() / client:GetMaxHealth()
end, Color(200, 50, 40), 1, "health")

print("Health bar priority:", prio)
```

---

### lia.bar.remove

**Purpose**

Removes a bar from the list based on its unique identifier.

**Parameters**

* `identifier` (*string*): The unique identifier of the bar to remove.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Remove the bar created in the previous example
lia.bar.remove("health")
```

---

### lia.bar.drawBar

**Purpose**

Draws a single horizontal bar at the specified screen coordinates, filling it proportionally based on `pos` and `max`.

**Parameters**

* `x` (*number*): The x-coordinate of the bar’s top-left corner.

* `y` (*number*): The y-coordinate of the bar’s top-left corner.

* `w` (*number*): Width of the bar's fill area (padding of 3px is added on each side).

* `h` (*number*): Total height of the bar.

* `pos` (*number*): Current value to display (clamped to `max`).

* `max` (*number*): Maximum possible value for the bar.

* `color` (*Color*): Colour used to fill the bar.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Draw a bar showing 75/100 progress at the top left
lia.bar.drawBar(10, 10, 200, 20, 75, 100, Color(255, 0, 0))
```

---

### lia.bar.drawAction

**Purpose**

Displays a temporary action progress bar with accompanying text for the specified duration on the HUD.

**Parameters**

* `text` (*string*): Text to display above the progress bar.

* `duration` (*number*): Duration in seconds for which the bar is displayed.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Show a reload progress bar for two seconds
lia.bar.drawAction("Reloading", 2)
```

---

### lia.bar.drawAll

**Purpose**

Iterates through all registered bars, applies smoothing to their values, and draws them on the HUD according to priority and visibility rules. The hooks `ShouldHideBars` and `ShouldBarDraw` are consulted to decide whether a bar is rendered.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Draw all registered bars each frame
hook.Add("HUDPaintBackground", "liaBarDraw", lia.bar.drawAll)
```

---
