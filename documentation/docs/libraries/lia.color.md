# Color Library

This page documents the functions for working with colors and color management.

---

## Overview

The color library (`lia.color`) provides a comprehensive system for managing colors, color registration, and color manipulation in the Lilia framework, serving as the core visual theming system that enables consistent and customizable visual experiences throughout the user interface. This library handles sophisticated color management with support for multiple color formats, advanced color manipulation functions, and dynamic color adjustment that enables rich visual customization and thematic consistency across all framework components. The system features advanced color registration with support for custom color definitions, color validation, and automatic color discovery that allows for flexible and extensible color management throughout the framework. It includes comprehensive theme management with support for multiple themes, dynamic theme switching, and theme inheritance that enables server administrators to create unique visual identities and maintain consistent branding. The library provides robust color manipulation with support for color blending, gradient generation, and advanced color operations that enable sophisticated visual effects and dynamic color changes based on game state. Additional features include integration with the framework's UI system for automatic color application, performance optimization for complex color calculations, and comprehensive accessibility support that ensures all players can effectively use the visual interface elements, making it essential for creating visually appealing and accessible user interfaces that enhance player experience and provide clear visual feedback for all game interactions.

---

### register

**Purpose**

Registers a new color with the color system.

**Parameters**

* `name` (*string*): The name of the color to register.
* `color` (*table*): The color data table with r, g, b values.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic color
lia.color.register("myRed", {255, 0, 0})

-- Register a custom color
lia.color.register("myBlue", {100, 150, 255})

-- Register a color with alpha
lia.color.register("myGreen", {0, 255, 0, 128})

-- Register multiple colors
lia.color.register("darkRed", {139, 0, 0})
lia.color.register("lightBlue", {173, 216, 230})
lia.color.register("gold", {255, 215, 0})
```

---

### Adjust

**Purpose**

Adjusts a color by adding or subtracting RGB values.

**Parameters**

* `color` (*Color*): The base color to adjust.
* `rOffset` (*number*): Red channel offset.
* `gOffset` (*number*): Green channel offset.
* `bOffset` (*number*): Blue channel offset.
* `aOffset` (*number*): Optional alpha channel offset.

**Returns**

* `adjustedColor` (*Color*): The adjusted color.

**Realm**

Shared.

**Example Usage**

```lua
-- Make a color darker
local darkRed = lia.color.Adjust(Color(255, 0, 0), -50, -50, -50)

-- Make a color lighter
local lightBlue = lia.color.Adjust(Color(0, 0, 255), 50, 50, 50)

-- Adjust specific channels
local adjusted = lia.color.Adjust(Color(100, 100, 100), 0, 50, -25)

-- Adjust with alpha
local semiTransparent = lia.color.Adjust(Color(255, 255, 255), 0, 0, 0, -100)

-- Use in a function
local function darkenColor(color, amount)
    return lia.color.Adjust(color, -amount, -amount, -amount)
end
```

---

### ReturnMainAdjustedColors

**Purpose**

Returns a table of main theme colors with adjusted values.

**Parameters**

*None*

**Returns**

* `colors` (*table*): Table containing background, sidebar, accent, text, hover, border, and highlight colors.

**Realm**

Client.

**Example Usage**

```lua
-- Get main adjusted colors
local colors = lia.color.ReturnMainAdjustedColors()

-- Use in UI drawing
local function drawUI()
    local colors = lia.color.ReturnMainAdjustedColors()
    
    -- Draw background
    surface.SetDrawColor(colors.background)
    surface.DrawRect(0, 0, 100, 100)
    
    -- Draw text
    draw.SimpleText("Hello", "liaMediumFont", 10, 10, colors.text)
    
    -- Draw accent
    surface.SetDrawColor(colors.accent)
    surface.DrawRect(10, 50, 80, 20)
end

-- Use in a panel
local function createPanel()
    local colors = lia.color.ReturnMainAdjustedColors()
    local panel = vgui.Create("DPanel")
    
    panel.Paint = function(self, w, h)
        surface.SetDrawColor(colors.background)
        surface.DrawRect(0, 0, w, h)
        
        surface.SetDrawColor(colors.border)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    
    return panel
end
```







