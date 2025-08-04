# Fonts Library

This page lists utilities for creating fonts.

---

## Overview

The fonts library wraps `surface.CreateFont` for commonly used fonts. It registers each font once, stores the definition in `lia.font.stored`, and then re-creates those fonts automatically when the screen resolution or relevant config values change.

Registered fonts rely on two config options:

* `Font` – Core UI font family.
* `GenericFont` – Secondary UI font family.

Changing either option triggers `lia.font.refresh` to rebuild every stored font.

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

**Example Usage**

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
### Default fonts

The base gamemode registers the following fonts for use in menus and panels:

- `AddonInfo_Header`
- `AddonInfo_Text`
- `AddonInfo_Small`
- `ConfigFont`
- `MediumConfigFont`
- `SmallConfigFont`
- `ConfigFontBold`
- `ConfigFontLarge`
- `DescriptionFontLarge`
- `ticketsystem`
- `VendorButtonFont`
- `VendorMediumFont`
- `VendorSmallFont`
- `VendorTinyFont`
- `VendorLightFont`
- `VendorItemNameFont`
- `VendorItemDescFont`
- `VendorItemStatsFont`
- `VendorItemPriceFont`
- `VendorActionButtonFont`
- `liaCharLargeFont`
- `liaCharMediumFont`
- `liaCharSmallFont`
- `liaCharSubTitleFont`
- `lia3D2DFont`
- `liaTitleFont`
- `liaSubTitleFont`
- `liaBigTitle`
- `liaBigText`
- `liaHugeText`
- `liaBigBtn`
- `liaMenuButtonFont`
- `liaMenuButtonLightFont`
- `liaToolTipText`
- `liaDynFontSmall`
- `liaDynFontMedium`
- `liaDynFontBig`
- `liaCleanTitleFont`
- `liaHugeFont`
- `liaBigFont`
- `liaMediumFont`
- `liaSmallFont`
- `liaMiniFont`
- `liaMediumLightFont`
- `liaGenericFont`
- `liaGenericLightFont`
- `liaChatFont`
- `liaChatFontItalics`
- `liaChatFontBold`
- `liaItemDescFont`
- `liaSmallBoldFont`
- `liaItemBoldFont`
- `liaNoticeFont`
- `liaCharTitleFont`
- `liaCharDescFont`
- `liaCharButtonFont`
- `liaCharSmallButtonFont`
- `PoppinsSmall`
- `PoppinsMedium`
- `PoppinsBig`

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

**Example Usage**

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

**Example Usage**

```lua
-- Manually trigger a font refresh
hook.Run("RefreshFonts")

-- React after fonts are reloaded
hook.Add("PostLoadFonts", "NotifyReload", function(cur, gen)
    print("Fonts loaded:", cur, gen)
end)
```

---
