# Color Library

This page lists helper functions for working with colors.

---

## Overview

The color library centralizes color utilities used throughout the UI. You can register reusable colors, adjust their channels to create variants, and fetch the main palette from the configuration.

---

### lia.color.register(name, color)

**Description:**

Registers a named color for later lookup.

**Parameters:**

* name (string) – Key used to reference the color.


* color (Color) – Color object or table.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.color.register
    lia.color.register("myRed", Color(255,0,0))
```

---

### lia.color.Adjust(color, rOffset, gOffset, bOffset, aOffset)

**Description:**

Creates a new color by applying offsets to each channel.

**Parameters:**

* color (Color) – Base color.


* rOffset (number) – Red channel delta.


* gOffset (number) – Green channel delta.


* bOffset (number) – Blue channel delta.


* aOffset (number) – Alpha channel delta (optional).


**Realm:**

* Shared


**Returns:**

* Color – Adjusted color.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.color.Adjust
    local lighter = lia.color.Adjust(Color(50,50,50), 10,10,10)
```

---

### lia.color.ReturnMainAdjustedColors()

**Description:**

Returns a table of commonly used UI colors derived from the base config color.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* table – Mapping of UI color keys to Color objects.


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.color.ReturnMainAdjustedColors
    local uiColors = lia.color.ReturnMainAdjustedColors()
```
