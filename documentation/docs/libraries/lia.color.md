# Color Library

This page lists helper functions for working with colors.

---

## Overview

The color library centralizes color utilities used throughout the UI. It provides helpers for registering reusable colors, adjusting their channels to create variants, and fetching the main palette from the configuration. Many common color names are pre-registered and stored in `lia.color.stored`. Registered names can also be passed to the client-side global `Color` function to retrieve the corresponding color (unknown names return pure white).

---

### lia.color.register

**Purpose**

Registers a named color for later lookup by string name.

**Parameters**

* `name` (*string*): Key used to reference the color. Names are stored in lowercase.

* `color` (*Color | table*): Color object or table containing RGB(A) channel values.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a custom purple shade and fetch it later
lia.color.register("myPurple", {128, 0, 180})
local c = Color("mypurple")
```

---

### lia.color.Adjust

**Purpose**

Creates a new `Color` based on the input color with the given channel offsets. `rOffset`, `gOffset`, and `bOffset` must be numbers. Each component is clamped between 0 and 255. If the base color lacks an alpha channel, `255` is assumed. `aOffset` defaults to `0`.

**Parameters**

* `color` (*Color*): Base color to modify. Must provide `r`, `g`, `b`, and optional `a` fields.

* `rOffset` (*number*): Red channel delta.

* `gOffset` (*number*): Green channel delta.

* `bOffset` (*number*): Blue channel delta.

* `aOffset` (*number | nil*): Alpha channel delta. Defaults to `0`.

**Realm**

`Client`

**Returns**

* *Color*: Adjusted color.

**Example Usage**

```lua
-- Darken the default red by 30 points
local darkRed = lia.color.Adjust(Color("red"), -30, 0, 0)

-- Raise the alpha of a blue color
local moreOpaque = lia.color.Adjust(Color("blue"), 0, 0, 0, 50)
```

---

### lia.color.ReturnMainAdjustedColors

**Purpose**

Builds and returns a UI palette derived from the config’s base color obtained via `lia.config.get("Color")`.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *table*: Contains the following `Color` values derived from the base color returned by `lia.config.get("Color")`:
  * `background`: `lia.color.Adjust(base, -20, -10, -50, 0)`
  * `sidebar`: `lia.color.Adjust(base, -30, -15, -60, -55)`
  * `accent`: `base`
  * `text`: `Color(245, 245, 220, 255)`
  * `hover`: `lia.color.Adjust(base, -40, -25, -70, -35)`
  * `border`: `Color(255, 255, 255, 255)`
  * `highlight`: `Color(255, 255, 255, 30)`

**Example Usage**

```lua
local colors = lia.color.ReturnMainAdjustedColors()
surface.SetDrawColor(colors.background)
```

