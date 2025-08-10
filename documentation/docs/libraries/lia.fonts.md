# Fonts Library

This page lists utilities for creating fonts.

---

## Overview

The fonts library wraps and overrides `surface.CreateFont` to cache each definition in `lia.font.stored`. Fonts are automatically re-created when the screen resolution changes or when relevant config values update.

Registered fonts rely on two config options:

* `Font` – Core UI font family. Default: `PoppinsMedium`.
* `GenericFont` – Secondary UI font family. Default: `PoppinsMedium`.

Changing either option emits the `RefreshFonts` hook, which runs `lia.font.refresh` to rebuild every stored font. Afterward the `PostLoadFonts` hook fires with the current UI and generic font names. Register custom fonts inside that hook so they persist across refreshes.

### Configuration

Two configuration entries are provided by this library:

| Name         | Default         | Type  | Description                                      |
|--------------|-----------------|-------|--------------------------------------------------|
| `Font`       | `PoppinsMedium` | Table | Primary UI font family. Options come from `lia.font.getAvailableFonts()`. Changing this value triggers a font refresh. |
| `GenericFont`| `PoppinsMedium` | Table | Secondary UI font family. Options come from `lia.font.getAvailableFonts()`. Changing this value triggers a font refresh. |

Both callbacks simply run `hook.Run("RefreshFonts")` on the client, ensuring fonts rebuild whenever these settings change.

---

### lia.font.register

**Purpose**

Creates and stores a font via `surface.CreateFont`. Arguments must be a string name and a table of font properties; otherwise `lia.error(L("invalidFont"))` is invoked and the call aborts. Each call caches the definition so the font can be regenerated later.

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

Returns an alphabetically sorted array of keys from `lia.font.stored`. If no fonts have been registered, an empty table is returned.

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

Wipes `lia.font.stored` and re-creates each cached font via `surface.CreateFont`. The library hooks this function to both `OnScreenSizeChanged` and the custom `RefreshFonts` event, so it runs when the resolution changes or when the `Font`/`GenericFont` configs update. After recreating the fonts, it triggers `PostLoadFonts` with the active `currentFont` and `genericFont` names.

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
