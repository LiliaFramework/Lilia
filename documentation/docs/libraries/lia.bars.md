# Bars Library

This page describes the API for status bars displayed on the HUD.

---

## Overview

The bars library manages status bars displayed on the player's HUD. Modules register callbacks that return a value between 0 and 1, and the library draws the bars each frame. Values are smoothed over time and a bar remains visible for five seconds after its value changes. The `BarsAlwaysVisible` option keeps bars visible while their value is above zero, and a bar can be forced to display by setting `bar.visible` to `true`. The hooks `ShouldHideBars` and `ShouldBarDraw` allow modules to control when bars are rendered.

Health and armor bars are registered automatically when the client loads, with priorities 1 and 3 respectively. Other modules may add additional bars such as stamina.

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

If the identifier matches an existing bar, the old bar is removed first. Bars are drawn in order of ascending priority and, when priorities are equal, in the order they were added.

**Parameters**

* `getValue` (*function*): Callback returning the bar's current value between 0 and 1.

* `color` (*Color*): Fill colour for the bar. Defaults to a random bright colour with each channel between 150 and 255.

* `priority` (*number*): Draw order; lower values draw first. Defaults to the next slot (`#lia.bar.list + 1`).

* `identifier` (*string*): Optional unique identifier for the bar. When omitted, the bar cannot later be retrieved or removed by identifier.

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

* *nil*: This function does not return a value. If no bar with the given identifier exists, the function exits without error.

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

* `w` (*number*): Nominal width of the bar. The background panel is drawn at `w + 6` pixels wide to provide a 3px border on each side, and the fill area uses up to `w - 6` pixels.

* `h` (*number*): Total height of the bar, including the 3px border at the top and bottom.

* `pos` (*number*): Current value to display. Values above `max` are clamped and negative widths are treated as zero.

* `max` (*number*): Maximum possible value for the bar. Supplying `0` or a negative value results in a division error.

* `color` (*Color*): Colour used to fill the bar. The alpha channel is ignored and assumed fully opaque.

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

Displays a temporary action progress bar with accompanying text for the specified duration on the HUD. The bar shrinks over time, is filled using `lia.config.get("Color")`, and repeated calls remove the previous `HUDPaint` hook before adding a new one so only one action bar is visible at a time.

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

Iterates through all registered bars, sorts them by priority and insertion order, smooths their values with `math.Approach` using a step of `FrameTime() * 0.6`, and draws them with a width of `ScrW() * 0.35` and a height of `14` starting at screen position `(4, 4)` with `2` pixels of vertical spacing. Bars remain for five seconds after their value changes or while smoothing toward a new target unless `BarsAlwaysVisible` is enabled or `bar.visible` is true. The hooks `ShouldHideBars` and `ShouldBarDraw` are consulted to decide whether a bar is rendered. By default, this function is bound to the `HUDPaintBackground` hook as `liaBarDraw`.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Manually draw all bars in a custom hook
hook.Add("HUDPaint", "MyDrawBars", lia.bar.drawAll)
```
