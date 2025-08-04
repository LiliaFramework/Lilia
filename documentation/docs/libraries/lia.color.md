# Color Library

This page lists helper functions for working with colors.

---

## Overview

The color library centralizes color utilities used throughout the UI. You can register reusable colors, adjust their channels to create variants, and fetch the main palette from the configuration. Many common color names are pre-registered and stored in `lia.color.stored`.

---

### lia.color.register

**Purpose**

Registers a named color for later lookup by string name.

**Parameters**

* `name` (*string*): Key used to reference the color.

* `color` (*Color | table*): Color object or `{ r, g, b }` table with the channel values in order.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Register a custom purple shade and fetch it later
lia.color.register("myPurple", { 128, 0, 180 })
local c = lia.color.stored.myPurple
```

---

### lia.color.Adjust

**Purpose**

Creates a new `Color` based on the input color with the given channel offsets.

**Parameters**

* `color` (*Color | table*): Base color to modify.

* `rOffset` (*number*): Red channel delta.

* `gOffset` (*number*): Green channel delta.

* `bOffset` (*number*): Blue channel delta.

* `aOffset` (*number | nil*): Alpha channel delta (optional).

**Realm**

`Shared`

**Returns**

* *Color*: Adjusted color.

**Example Usage**

```lua
-- Darken the default red by 30 points
local darkRed = lia.color.Adjust(lia.color.stored.red, -30, 0, 0)
```

---

### lia.color.ReturnMainAdjustedColors

**Purpose**

Builds and returns a UI palette derived from the config’s base color.

**Parameters**

* *None*

**Realm**

`Shared`

**Returns**

* *table*: Contains `background`, `sidebar`, `accent`, `text`, `hover`, `border`, and `highlight` colors.

**Example Usage**

```lua
local colors = lia.color.ReturnMainAdjustedColors()
surface.SetDrawColor(colors.background)
```
