# Fonts Library

This page documents the functions for working with custom fonts and text rendering.

---

## Overview

The fonts library (`lia.font`) provides a comprehensive system for managing custom fonts, font registration, and text rendering in the Lilia framework, enabling rich typography and visual customization throughout the user interface. This library handles advanced font management with support for multiple font formats, automatic font loading from various sources including local files and web resources, and intelligent caching systems to optimize memory usage and loading performance. The system features sophisticated font registration mechanisms with support for font families, weight variations, style options, and fallback font chains to ensure consistent text rendering across different client configurations. It includes comprehensive text rendering functionality with support for advanced typography features including kerning, ligatures, text effects, and multi-language character support. The library provides integration with the framework's UI system, offering scalable font rendering that adapts to different screen resolutions and accessibility needs. Additional features include font validation and error handling, automatic font fallback systems, and performance monitoring tools for text rendering operations, making it essential for creating polished and professional user interfaces that enhance the overall player experience.

---

### register

**Purpose**

Registers a new font with the font system.

**Parameters**

* `fontName` (*string*): The name of the font.
* `fontData` (*table*): The font data table containing font, size, weight, etc.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Register a basic font
lia.font.register("MyFont", {
    font = "Arial",
    size = 16,
    weight = 500
})

-- Register a font with more options
lia.font.register("CustomFont", {
    font = "Roboto",
    size = 24,
    weight = 700,
    antialias = true,
    outline = true,
    shadow = true
})

-- Register a font with custom properties
lia.font.register("TitleFont", {
    font = "Impact",
    size = 32,
    weight = 900,
    antialias = true,
    outline = true,
    outlineSize = 2,
    shadow = true,
    shadowOffset = 2
})

-- Use in a function
local function createFont(name, font, size, weight)
    lia.font.register(name, {
        font = font,
        size = size,
        weight = weight or 500
    })
    print("Font registered: " .. name)
end
```

---

### getAvailableFonts

**Purpose**

Gets a list of all available fonts.

**Parameters**

*None*

**Returns**

* `fonts` (*table*): Table of available font names.

**Realm**

Client.

**Example Usage**

```lua
-- Get available fonts
local function getAvailableFonts()
    return lia.font.getAvailableFonts()
end

-- Use in a function
local function showAvailableFonts()
    local fonts = lia.font.getAvailableFonts()
    print("Available fonts:")
    for _, font in ipairs(fonts) do
        print("- " .. font)
    end
end

-- Use in a function
local function getFontCount()
    local fonts = lia.font.getAvailableFonts()
    return #fonts
end

-- Use in a function
local function checkFontExists(fontName)
    local fonts = lia.font.getAvailableFonts()
    for _, font in ipairs(fonts) do
        if font == fontName then
            return true
        end
    end
    return false
end
```

---

### refresh

**Purpose**

Refreshes the font system and reloads all fonts.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Refresh font system
local function refreshFonts()
    lia.font.refresh()
    print("Font system refreshed")
end

-- Use in a function
local function reloadFonts()
    lia.font.refresh()
    print("All fonts reloaded")
end

-- Use in a function
local function resetFontSystem()
    lia.font.refresh()
    print("Font system reset")
end

-- Use in a command
lia.command.add("refreshfonts", {
    onRun = function(client, arguments)
        lia.font.refresh()
        client:notify("Font system refreshed")
    end
})
```








