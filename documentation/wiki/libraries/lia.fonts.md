# Fonts Library

This page lists utilities for creating fonts.

---

## Overview

The fonts library wraps `surface.CreateFont` for commonly used fonts. It registers each font once, stores the definition, and then re-creates those fonts automatically when the screen resolution or relevant config values change.

Fonts are refreshed whenever `lia.font.refresh` runs; afterward, the `PostLoadFonts` hook fires with the current UI and generic font names. Register custom fonts inside that hook so they persist across refreshes.

---

### lia.font.register

**Purpose**

Creates and stores a font via `surface.CreateFont`. The definition is kept in an internal list so the font can be regenerated later.

**Parameters**

* `fontName` (*string*): Font identifier.

* `fontData` (*table*): Font properties table (family, size, weight, etc.).

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Register a custom font after default fonts reload
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

**Purpose**

Returns an alphabetically sorted list of all font identifiers that have been registered.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *table*: Array of font-name strings.

**Example**

```lua
local fonts = lia.font.getAvailableFonts()
for _, name in ipairs(fonts) do
    print("Font:", name)
end
```

---

### lia.font.refresh

**Purpose**

Recreates every stored font definition. This function runs automatically when screen resolution changes or when the `Font` / `GenericFont` configs update. After recreating the fonts, it triggers the `PostLoadFonts` hook with the active `currentFont` and `genericFont`.

**Parameters**

* *None*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Manually trigger a font refresh
hook.Run("RefreshFonts")

-- React after fonts are reloaded
hook.Add("PostLoadFonts", "NotifyReload", function(cur, gen)
    print("Fonts loaded:", cur, gen)
end)
```

---