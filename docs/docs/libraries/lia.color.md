# Color Library

This page lists helper functions for working with colors.

---

## Overview

The color library centralizes color utilities used throughout the UI. You can register reusable colors, adjust their channels to create variants, and fetch the main palette from the configuration. Many common color names are pre-registered and can be used with the global `Color()` function. Custom registrations are stored in `lia.color.stored`.

---

### lia.color.register

**Description:**

Registers a named color for later lookup or use with `Color(name)`.

**Parameters:**

* `name` (`string`) – Key used to reference the color.


* `color` (`Color|table`) – Color object or `{r, g, b}` table.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- Register a custom purple shade and fetch it later
    lia.color.register("myPurple", {128, 0, 180})
    local c = Color("myPurple")
```

---

### lia.color.Adjust

**Description:**

Returns a new Color based on the input color with the given channel offsets.

**Parameters:**

* `color` (`Color|table`) – Base color to modify.


* `rOffset` (`number`) – Red channel delta.


* `gOffset` (`number`) – Green channel delta.


* `bOffset` (`number`) – Blue channel delta.


* `aOffset` (`number|nil`) – Alpha channel delta (optional).


**Realm:**

* Shared


**Returns:**

* Color – Adjusted color.


**Example Usage:**

```lua

    -- Darken the default red by 30 points
    local darkRed = lia.color.Adjust(Color("red"), -30, 0, 0)
```

---

### lia.color.ReturnMainAdjustedColors

**Description:**

Builds a UI palette derived from the config's base color.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* table – Contains `background`, `sidebar`, `accent`, `text`, `hover`, `border` and `highlight` colors.


**Example Usage:**

```lua

    local colors = lia.color.ReturnMainAdjustedColors()
    surface.SetDrawColor(colors.background)
```

### Color(name)

The global `Color()` function is overridden to accept a registered color name.
Passing a string will look up the color in `lia.color.stored` and return a
`Color` object. Unrecognized names default to white.

**Realm:**

* Shared

**Returns:**

* Color – The color object matching the name.


