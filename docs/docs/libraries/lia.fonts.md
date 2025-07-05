# Fonts Library

This page lists utilities for creating fonts.

---

## Overview

The fonts library wraps `surface.CreateFont` for commonly used fonts. It avoids duplication by registering fonts once and allowing them to be recalled by name. Every call to `surface.CreateFont` is intercepted so the data is stored and automatically refreshed when the screen resolution or relevant configuration options change.

Fonts are refreshed automatically whenever `RefreshFonts` is run and the `PostLoadFonts` hook will then be called with the current font choices. Register custom fonts inside this hook so they persist across refreshes.

---

### lia.font.register

**Description:**

Creates and stores a font using `surface.CreateFont`. The font is kept in the internal list so it can be recreated later. Invalid parameters raise an error.

**Parameters:**

* `fontName` (`string`) – Font identifier.


* `fontData` (`table`) – Font properties table.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Register a new font after the default fonts have loaded
hook.Add("PostLoadFonts", "ExampleFont", function()
    lia.font.register("MyFont", {
        font = "Arial",
        size = 16,
        weight = 500
    })
end)
```

---

### lia.font.getAvailableFonts

**Description:**

Returns an alphabetically sorted table of the font names that have been registered.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* table – Array of font name strings.


**Example Usage:**

```lua
local fonts = lia.font.getAvailableFonts()
for _, name in ipairs(fonts) do
    print("Font:", name)
end
```

---

### lia.font.refresh

**Description:**

Recreates all stored fonts from the internal list. This runs automatically when the screen resolution changes or when the `Font` or `GenericFont` configs update. Once complete it fires `PostLoadFonts` with `currentFont` and `genericFont`.

**Parameters:**

* None


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Force fonts to reload
hook.Run("RefreshFonts")

-- React after fonts load
hook.Add("PostLoadFonts", "NotifyReload", function(cur, gen)
    print("Fonts loaded:", cur, gen)
end)
```
