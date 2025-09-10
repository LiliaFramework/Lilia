# Color Library

This page documents the functions for working with colors and color management.

---

## Overview

The color library (`lia.color`) provides a comprehensive system for managing colors, color registration, and color manipulation in the Lilia framework. It includes predefined colors, color adjustment functions, and theme color management.

---

### lia.color.register

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

### lia.color.Adjust

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

### lia.color.ReturnMainAdjustedColors

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

---

### lia.color.get

**Purpose**

Gets a registered color by name.

**Parameters**

* `name` (*string*): The name of the color to retrieve.

**Returns**

* `color` (*Color*): The color if found, white color otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Get a registered color
local red = lia.color.get("red")
print("Red color:", red.r, red.g, red.b)

-- Get a custom color
local myColor = lia.color.get("myRed")

-- Use in drawing
local function drawColoredText(text, colorName)
    local color = lia.color.get(colorName)
    draw.SimpleText(text, "liaMediumFont", 10, 10, color)
end

-- Use in a command
lia.command.add("testcolor", {
    arguments = {
        {name = "colorname", type = "string"}
    },
    onRun = function(client, arguments)
        local color = lia.color.get(arguments[1])
        client:notify("Color: " .. color.r .. ", " .. color.g .. ", " .. color.b)
    end
})
```

---

### lia.color.list

**Purpose**

Gets a list of all registered color names.

**Parameters**

*None*

**Returns**

* `colorNames` (*table*): Table of all registered color names.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all color names
local colors = lia.color.list()
print("Available colors:", table.concat(colors, ", "))

-- Display all colors
for _, colorName in ipairs(colors) do
    local color = lia.color.get(colorName)
    print(colorName .. ":", color.r, color.g, color.b)
end

-- Use in a color picker
local function createColorPicker()
    local colors = lia.color.list()
    local combo = vgui.Create("DComboBox")
    
    for _, colorName in ipairs(colors) do
        combo:AddChoice(colorName)
    end
    
    return combo
end
```

---

### lia.color.setTheme

**Purpose**

Sets the main theme color for the framework.

**Parameters**

* `color` (*Color*): The new theme color.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set theme color
lia.color.setTheme(Color(255, 0, 0)) -- Red theme

-- Set theme color from config
local themeColor = lia.config.get("Color")
lia.color.setTheme(themeColor)

-- Set theme color from user input
local function setCustomTheme(r, g, b)
    lia.color.setTheme(Color(r, g, b))
end

-- Use in a command
lia.command.add("settheme", {
    arguments = {
        {name = "r", type = "number"},
        {name = "g", type = "number"},
        {name = "b", type = "number"}
    },
    onRun = function(client, arguments)
        lia.color.setTheme(Color(arguments[1], arguments[2], arguments[3]))
        client:notify("Theme color updated")
    end
})
```

---

### lia.color.getTheme

**Purpose**

Gets the current theme color.

**Parameters**

*None*

**Returns**

* `themeColor` (*Color*): The current theme color.

**Realm**

Shared.

**Example Usage**

```lua
-- Get current theme color
local themeColor = lia.color.getTheme()
print("Theme color:", themeColor.r, themeColor.g, themeColor.b)

-- Use theme color in drawing
local function drawThemedUI()
    local themeColor = lia.color.getTheme()
    surface.SetDrawColor(themeColor)
    surface.DrawRect(0, 0, 100, 100)
end

-- Use in a function
local function getThemeAdjustedColors()
    local theme = lia.color.getTheme()
    return {
        background = lia.color.Adjust(theme, -20, -10, -50),
        accent = theme,
        text = Color(255, 255, 255)
    }
end
```

---

### lia.color.random

**Purpose**

Generates a random color.

**Parameters**

* `minValue` (*number*): Optional minimum RGB value (default: 0).
* `maxValue` (*number*): Optional maximum RGB value (default: 255).

**Returns**

* `randomColor` (*Color*): A random color.

**Realm**

Shared.

**Example Usage**

```lua
-- Generate a random color
local randomColor = lia.color.random()
print("Random color:", randomColor.r, randomColor.g, randomColor.b)

-- Generate a random bright color
local brightColor = lia.color.random(150, 255)

-- Generate a random dark color
local darkColor = lia.color.random(0, 100)

-- Use in a function
local function createRandomEffect()
    local color = lia.color.random()
    -- Use color for particle effect
end
```

---

### lia.color.lerp

**Purpose**

Interpolates between two colors.

**Parameters**

* `color1` (*Color*): The first color.
* `color2` (*Color*): The second color.
* `fraction` (*number*): The interpolation fraction (0-1).

**Returns**

* `lerpedColor` (*Color*): The interpolated color.

**Realm**

Shared.

**Example Usage**

```lua
-- Lerp between red and blue
local red = Color(255, 0, 0)
local blue = Color(0, 0, 255)
local purple = lia.color.lerp(red, blue, 0.5)

-- Lerp with different fractions
local color1 = Color(255, 0, 0)
local color2 = Color(0, 255, 0)
local color3 = lia.color.lerp(color1, color2, 0.25) -- 25% towards color2
local color4 = lia.color.lerp(color1, color2, 0.75) -- 75% towards color2

-- Use in animation
local function animateColor(startColor, endColor, duration)
    local startTime = CurTime()
    local function updateColor()
        local elapsed = CurTime() - startTime
        local fraction = math.min(elapsed / duration, 1)
        return lia.color.lerp(startColor, endColor, fraction)
    end
    return updateColor
end
```

---

### lia.color.toHex

**Purpose**

Converts a color to hexadecimal format.

**Parameters**

* `color` (*Color*): The color to convert.

**Returns**

* `hexString` (*string*): The hexadecimal color string.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert color to hex
local red = Color(255, 0, 0)
local hex = lia.color.toHex(red)
print("Red in hex:", hex) -- Output: "#FF0000"

-- Convert theme color to hex
local themeColor = lia.color.getTheme()
local themeHex = lia.color.toHex(themeColor)

-- Use in web interface
local function sendColorToWeb(color)
    local hex = lia.color.toHex(color)
    -- Send hex to web interface
end
```

---

### lia.color.fromHex

**Purpose**

Converts a hexadecimal color string to a Color object.

**Parameters**

* `hexString` (*string*): The hexadecimal color string.

**Returns**

* `color` (*Color*): The color object.

**Realm**

Shared.

**Example Usage**

```lua
-- Convert hex to color
local color = lia.color.fromHex("#FF0000")
print("Color from hex:", color.r, color.g, color.b)

-- Convert hex without #
local color2 = lia.color.fromHex("00FF00")

-- Use in a function
local function parseColorInput(input)
    if input:match("^#%x%x%x%x%x%x$") then
        return lia.color.fromHex(input)
    else
        return Color(255, 255, 255) -- Default white
    end
end
```