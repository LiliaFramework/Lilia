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

---

### LerpColor

**Purpose**

Interpolates between two colors using the current frame time for smooth transitions.

**Parameters**

* `frac` (*number*): The interpolation fraction/speed multiplier.
* `col1` (*Color*): The starting color.
* `col2` (*Color*): The target color.

**Returns**

* `interpolatedColor` (*Color*): The interpolated color.

**Realm**

Client.

**Example Usage**

```lua
-- Smooth color transition over time
local startColor = Color(255, 0, 0) -- Red
local endColor = Color(0, 255, 0)   -- Green
local blendedColor = lia.color.LerpColor(0.5, startColor, endColor)

-- Use in a panel paint function
local panel = vgui.Create("DPanel")
panel.Paint = function(self, w, h)
    local progress = math.sin(CurTime() * 2) * 0.5 + 0.5
    local color = lia.color.LerpColor(2, Color(255, 0, 0), Color(0, 0, 255))
    surface.SetDrawColor(color)
    surface.DrawRect(0, 0, w, h)
end
```

---

### Lerp

**Purpose**

Interpolates between two colors using the current frame time for smooth transitions.

**Parameters**

* `frac` (*number*): The interpolation fraction/speed multiplier.
* `col1` (*Color*): The starting color.
* `col2` (*Color*): The target color.

**Returns**

* `interpolatedColor` (*Color*): The interpolated color.

**Realm**

Client.

**Example Usage**

```lua
-- Smooth color transition over time
local startColor = Color(255, 0, 0) -- Red
local endColor = Color(0, 255, 0)   -- Green
local blendedColor = lia.color.Lerp(0.5, startColor, endColor)

-- Use in theme transitions
local color1 = Color(100, 100, 100)
local color2 = Color(200, 200, 200)
local smoothColor = lia.color.Lerp(3, color1, color2)
```

---

### getCurrentThemeName

**Purpose**

Returns the name of the currently active theme.

**Parameters**

*None*

**Returns**

* `themeName` (*string*): The name of the current theme, or 'unknown' if not found.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the current theme name
local currentTheme = lia.color.getCurrentThemeName()
print("Current theme:", currentTheme)

-- Use in conditional logic
if lia.color.getCurrentThemeName() == "dark" then
    print("Using dark theme")
else
    print("Using light theme")
end

-- Get available themes
local themes = lia.color.getThemes()
for _, themeName in ipairs(themes) do
    if themeName == lia.color.getCurrentThemeName() then
        print("Active theme:", themeName)
    end
end
```

---

### getTheme

**Purpose**

Returns the theme data for a specific theme or the current theme if no name is provided.

**Parameters**

* `name` (*string*, optional): The name of the theme to retrieve.

**Returns**

* `themeData` (*table*): The theme data table, or nil if the theme doesn't exist.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the current theme
local currentTheme = lia.color.getTheme()
print("Background color:", currentTheme.background)

-- Get a specific theme
local darkTheme = lia.color.getTheme("dark")
if darkTheme then
    print("Dark theme accent:", darkTheme.accent)
end

-- List all colors in current theme
local theme = lia.color.getTheme()
for colorName, colorValue in pairs(theme) do
    print(colorName .. ":", colorValue)
end

-- Check if a theme exists
local blueTheme = lia.color.getTheme("blue")
if blueTheme then
    print("Blue theme is available")
end
```

---

### getAllThemes

**Purpose**

Returns a table containing the names of all registered themes.

**Parameters**

*None*

**Returns**

* `themes` (*table*): A table containing theme names as strings.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all available themes
local themes = lia.color.getAllThemes()
PrintTable(themes)

-- Check if a specific theme exists
local function hasTheme(themeName)
    local themes = lia.color.getAllThemes()
    for _, name in ipairs(themes) do
        if name == themeName then
            return true
        end
    end
    return false
end

-- Count available themes
local themeCount = #lia.color.getAllThemes()
print("Available themes:", themeCount)

-- Use in a dropdown menu
local themes = lia.color.getAllThemes()
for _, themeName in ipairs(themes) do
    print("Theme:", themeName)
end
```

---

### getCurrentThemeName

**Purpose**

Returns the name of the currently active theme.

**Parameters**

*None*

**Returns**

* `themeName` (*string*): The name of the current theme.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the current theme name
local currentTheme = lia.color.getCurrentThemeName()
print("Current theme:", currentTheme)

-- Use in conditional logic
if lia.color.getCurrentThemeName() == "Dark" then
    print("Using dark theme")
else
    print("Using light theme")
end

-- Get available themes for comparison
local themes = lia.color.getAllThemes()
for _, themeName in ipairs(themes) do
    if themeName == lia.color.getCurrentThemeName() then
        print("Active theme:", themeName)
    end
end
```

---

### isColor

**Purpose**

Checks if a value is a valid color object with r, g, b properties.

**Parameters**

* `v` (*any*): The value to check.

**Returns**

* `isValidColor` (*boolean*): True if the value is a valid color, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if a value is a color
local color = Color(255, 0, 0)
if lia.color.isColor(color) then
    print("This is a valid color")
end

-- Validate color in a function
local function processColor(input)
    if not lia.color.isColor(input) then
        error("Input must be a valid color")
    end
    -- Process the color...
end

-- Check theme colors
local theme = lia.color.getTheme()
for name, value in pairs(theme) do
    if lia.color.isColor(value) then
        print(name .. " is a color: " .. tostring(value))
    end
end

-- Filter colors from a table
local mixedTable = {Color(255, 0, 0), "string", 123, Color(0, 255, 0)}
local colors = {}
for _, value in ipairs(mixedTable) do
    if lia.color.isColor(value) then
        table.insert(colors, value)
    end
end
```

---

### isTransitioning

**Purpose**

Checks if a theme transition is currently in progress.

**Parameters**

*None*

**Returns**

* `isTransitioning` (*boolean*): True if a theme transition is active, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Check if theme is transitioning
if lia.color.isTransitioning() then
    print("Theme transition in progress")
    -- Disable certain UI updates during transition
else
    print("No theme transition active")
end

-- Wait for transition to complete
local function waitForTransition(callback)
    if not lia.color.isTransitioning() then
        callback()
        return
    end

    -- Check again next frame
    timer.Simple(0, function()
        waitForTransition(callback)
    end)
end

-- Use in UI rendering
local frame = vgui.Create("DFrame")
frame.Paint = function(self, w, h)
    if lia.color.isTransitioning() then
        -- Use a special effect during transition
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawRect(0, 0, w, h)
    end
end

-- Conditional logic based on transition state
if not lia.color.isTransitioning() then
    -- Only update certain elements when not transitioning
    updateUIElements()
end
```

---

### register

**Purpose**

Registers a new color with the color system for client-side use.

**Parameters**

* `name` (*string*): The name of the color to register (case-insensitive).
* `color` (*table*): The color data table with r, g, b values.

**Returns**

*None*

**Realm**

Client.

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

Adjusts a color by adding or subtracting RGB values with bounds checking.

**Parameters**

* `color` (*Color*): The base color to adjust.
* `rOffset` (*number*): Red channel offset (-255 to 255).
* `gOffset` (*number*): Green channel offset (-255 to 255).
* `bOffset` (*number*): Blue channel offset (-255 to 255).
* `aOffset` (*number*, optional): Alpha channel offset (-255 to 255).

**Returns**

* `adjustedColor` (*Color*): The adjusted color with values clamped to valid ranges.

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

### registerTheme

**Purpose**

Registers a new theme with the color system.

**Parameters**

* `name` (*string*): The name of the theme to register.
* `themeData` (*table*): The theme data table containing color definitions.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic theme
lia.color.registerTheme("myTheme", {
    background = Color(25, 25, 25),
    sidebar = Color(40, 40, 40),
    accent = Color(106, 108, 197),
    text = Color(255, 255, 255),
    hover = Color(60, 65, 80)
})

-- Register a theme with all required fields
lia.color.registerTheme("completeTheme", {
    background = Color(30, 30, 30),
    sidebar = Color(45, 45, 45),
    accent = Color(150, 150, 150),
    text = Color(255, 255, 255),
    hover = Color(70, 75, 90),
    border = Color(100, 100, 100),
    highlight = Color(150, 150, 150, 30)
})

-- Register a colorful theme
lia.color.registerTheme("colorful", {
    background = Color(40, 20, 60),
    sidebar = Color(60, 30, 90),
    accent = Color(255, 100, 200),
    text = Color(255, 255, 255),
    hover = Color(255, 100, 200, 100)
})

-- Check if theme was registered successfully
local themes = lia.color.getThemes()
for _, themeName in ipairs(themes) do
    if themeName == "myTheme" then
        print("Theme registered successfully!")
        break
    end
end
```

---

### setTheme

**Purpose**

Sets the active theme immediately without smooth transition.

**Parameters**

* `name` (*string*): The name of the theme to set.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Set a specific theme
lia.color.setTheme("dark")
print("Theme set to dark")

-- Set theme based on time of day
local hour = tonumber(os.date("%H"))
if hour < 6 or hour > 18 then
    lia.color.setTheme("dark")
else
    lia.color.setTheme("light")
end

-- Reset to default theme
lia.color.setTheme("default")

-- Use in configuration
lia.config.add("Theme", "theme", "default", function(oldValue, newValue)
    lia.color.setTheme(newValue)
end, {
    desc = "Select the UI theme",
    category = "Visual",
    type = "Table",
    options = lia.color.getThemes()
})

-- Apply theme on player join
hook.Add("PlayerInitialSpawn", "SetPlayerTheme", function(player)
    if player:GetInfoNum("lia_theme_preference", 0) == 1 then
        lia.color.setTheme("dark")
    end
end)
```

---

### applyTheme

**Purpose**

Applies a theme immediately without smooth transition.

**Parameters**

* `themeName` (*string*): The name of the theme to apply.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Apply a theme immediately
lia.color.applyTheme("dark")

-- Apply theme based on user preference
if GetConVar("lia_theme_dark"):GetBool() then
    lia.color.applyTheme("dark")
else
    lia.color.applyTheme("light")
end

-- Use in a menu
local themeButton = vgui.Create("DButton")
themeButton:SetText("Apply Dark Theme")
themeButton.DoClick = function()
    lia.color.applyTheme("dark")
end

-- Apply theme on player join
hook.Add("PlayerInitialSpawn", "ApplyPlayerTheme", function(player)
    if player:GetInfoNum("lia_theme_preference", 0) == 1 then
        lia.color.applyTheme("dark")
    end
end)
```

---

### darken

**Purpose**

Darkens a color by reducing its brightness.

**Parameters**

* `color` (*Color*): The color to darken.
* `amount` (*number*, optional): The amount to darken by (0-255, default: 50).

**Returns**

* `darkenedColor` (*Color*): The darkened color.

**Realm**

Shared.

**Example Usage**

```lua
-- Darken a color by default amount
local darkenedRed = lia.color.darken(Color(255, 100, 100))

-- Darken a color by specific amount
local veryDarkBlue = lia.color.darken(Color(100, 150, 255), 100)

-- Use in UI theming
local function createDarkButton(color)
    return lia.color.darken(color, 30)
end

-- Darken theme colors for hover effects
local theme = lia.color.getTheme()
local hoverColor = lia.color.darken(theme.accent, 20)

-- Progressive darkening
local colors = {}
for i = 1, 5 do
    colors[i] = lia.color.darken(Color(200, 200, 200), i * 20)
end
```

---

### getAllThemes

**Purpose**

Returns a table containing all registered themes.

**Parameters**

*None*

**Returns**

* `themes` (*table*): A table containing all theme data.

**Realm**

Shared.

**Example Usage**

```lua
-- Get all available themes
local allThemes = lia.color.getAllThemes()
PrintTable(allThemes)

-- Count available themes
local themeCount = table.Count(lia.color.getAllThemes())
print("Available themes:", themeCount)

-- List theme names
local themes = lia.color.getAllThemes()
for themeName, themeData in pairs(themes) do
    print("Theme:", themeName)
end

-- Check if a theme exists
local function hasTheme(themeName)
    local themes = lia.color.getAllThemes()
    return themes[themeName] ~= nil
end

-- Use in a dropdown menu
local themes = lia.color.getAllThemes()
for themeName, themeData in pairs(themes) do
    print("Theme:", themeName, "with", table.Count(themeData), "colors")
end
```

---

### getCurrentTheme

**Purpose**

Returns the currently active theme data.

**Parameters**

*None*

**Returns**

* `themeData` (*table*): The current theme data table.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the current theme data
local currentTheme = lia.color.getCurrentTheme()

-- Access theme colors
print("Background color:", currentTheme.background)
print("Accent color:", currentTheme.accent)
print("Text color:", currentTheme.text)

-- Use current theme in UI
local function drawWithCurrentTheme()
    local theme = lia.color.getCurrentTheme()
    surface.SetDrawColor(theme.background)
    surface.DrawRect(0, 0, 100, 100)

    draw.SimpleText("Hello", "liaMediumFont", 50, 50, theme.text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

-- Check theme properties
local theme = lia.color.getCurrentTheme()
if theme.dark then
    print("Using dark theme")
else
    print("Using light theme")
end

-- Compare with specific theme
local darkTheme = lia.color.getTheme("dark")
local currentTheme = lia.color.getCurrentTheme()

if currentTheme == darkTheme then
    print("Currently using dark theme")
end
```

---

### getMainColor

**Purpose**

Returns the main accent color of the current theme.

**Parameters**

*None*

**Returns**

* `mainColor` (*Color*): The main accent color.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the main accent color
local accentColor = lia.color.getMainColor()

-- Use in UI elements
local button = vgui.Create("DButton")
button.Paint = function(self, w, h)
    surface.SetDrawColor(accentColor)
    surface.DrawRect(0, 0, w, h)
end

-- Compare with other colors
local theme = lia.color.getCurrentTheme()
if accentColor == theme.accent then
    print("Main color matches theme accent")
end

-- Use for highlighting
local function highlightElement(element, color)
    local mainColor = lia.color.getMainColor()
    element:SetColor(mainColor)
end

-- Create variations of main color
local mainColor = lia.color.getMainColor()
local lightMain = lia.color.Adjust(mainColor, 50, 50, 50)
local darkMain = lia.color.darken(mainColor, 30)
```

---

### isTransitionActive

**Purpose**

Checks if a theme transition is currently in progress.

**Parameters**

*None*

**Returns**

* `isActive` (*boolean*): True if a transition is active, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Check if theme transition is active
if lia.color.isTransitionActive() then
    print("Theme transition in progress")
    -- Disable certain UI updates during transition
else
    print("No theme transition active")
end

-- Wait for transition to complete
local function waitForTransition(callback)
    if not lia.color.isTransitionActive() then
        callback()
        return
    end

    -- Check again next frame
    timer.Simple(0, function()
        waitForTransition(callback)
    end)
end

-- Use in UI rendering
local frame = vgui.Create("DFrame")
frame.Paint = function(self, w, h)
    if lia.color.isTransitionActive() then
        -- Use a special effect during transition
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawRect(0, 0, w, h)
    end
end

-- Conditional logic based on transition state
if not lia.color.isTransitionActive() then
    -- Only update certain elements when not transitioning
    updateUIElements()
end
```

---

### lerp

**Purpose**

Interpolates between two colors using linear interpolation.

**Parameters**

* `frac` (*number*): The interpolation fraction (0-1).
* `col1` (*Color*): The starting color.
* `col2` (*Color*): The target color.

**Returns**

* `interpolatedColor` (*Color*): The interpolated color.

**Realm**

Client.

**Example Usage**

```lua
-- Linear interpolation between two colors
local startColor = Color(255, 0, 0) -- Red
local endColor = Color(0, 255, 0)   -- Green
local blendedColor = lia.color.lerp(0.5, startColor, endColor)

-- Use in color transitions
local color1 = Color(100, 100, 100)
local color2 = Color(200, 200, 200)
local smoothColor = lia.color.lerp(0.3, color1, color2)

-- Animate color changes
local progress = 0
hook.Add("Think", "ColorAnimation", function()
    progress = (progress + FrameTime()) % 1
    local color = lia.color.lerp(progress, Color(255, 0, 0), Color(0, 0, 255))
    -- Apply color to UI element
end)

-- Multiple color interpolation
local colors = {
    Color(255, 0, 0),
    Color(0, 255, 0),
    Color(0, 0, 255)
}

local function getRainbowColor(progress)
    local segment = math.floor(progress * #colors)
    local segmentProgress = (progress * #colors) % 1
    return lia.color.lerp(segmentProgress, colors[segment + 1] or colors[1], colors[segment + 2] or colors[1])
end
```

---

### startThemeTransition

**Purpose**

Starts a smooth theme transition animation.

**Parameters**

* `themeName` (*string*): The name of the theme to transition to.
* `duration` (*number*, optional): The transition duration in seconds.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Start theme transition
lia.color.startThemeTransition("dark")

-- Transition with custom duration
lia.color.startThemeTransition("blue", 2.0)

-- Use in a menu
local themeButton = vgui.Create("DButton")
themeButton:SetText("Switch to Dark Theme")
themeButton.DoClick = function()
    lia.color.startThemeTransition("dark", 1.5)
end

-- Check if transition is in progress
lia.color.startThemeTransition("blue")
timer.Simple(0.1, function()
    if lia.color.isTransitionActive() then
        print("Theme transition started")
    end
end)

-- Chain theme transitions
lia.color.startThemeTransition("dark", 1.0)
timer.Simple(1.5, function()
    lia.color.startThemeTransition("light", 1.0)
end)

-- Cancel current transition and start new one
lia.color.startThemeTransition("dark")
timer.Simple(0.5, function()
    lia.color.startThemeTransition("blue") -- This will override the previous transition
end)
```

---

### testThemeTransition

**Purpose**

Tests a theme transition by applying it temporarily.

**Parameters**

* `themeName` (*string*): The name of the theme to test.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Test a theme transition
lia.color.testThemeTransition("dark")

-- Test with automatic revert
lia.color.testThemeTransition("blue")
timer.Simple(5, function()
    lia.color.applyTheme("default") -- Revert to default theme
end)

-- Use in theme preview
local function previewTheme(themeName)
    lia.color.testThemeTransition(themeName)

    -- Show preview for 3 seconds
    timer.Simple(3, function()
        lia.color.applyTheme("default")
        print("Theme preview ended")
    end)
end

-- Test multiple themes in sequence
local themes = {"dark", "blue", "green", "purple"}
local currentThemeIndex = 1

local function cycleThemePreview()
    if currentThemeIndex <= #themes then
        local themeName = themes[currentThemeIndex]
        lia.color.testThemeTransition(themeName)

        timer.Simple(2, function()
            currentThemeIndex = currentThemeIndex + 1
            cycleThemePreview()
        end)
    else
        -- All themes tested, revert to default
        lia.color.applyTheme("default")
    end
end

-- Use in theme selection menu
local themeButtons = {}
for themeName, themeData in pairs(lia.color.getAllThemes()) do
    local button = lia.derma.button(parentPanel)
    button:SetText("Preview " .. themeName)
    button.DoClick = function()
        lia.color.testThemeTransition(themeName)
    end
    table.insert(themeButtons, button)
end
```

---

### setThemeSmooth

**Purpose**

Sets the active theme with a smooth animated transition.

**Parameters**

* `name` (*string*): The name of the theme to transition to.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Smooth transition to dark theme
lia.color.setThemeSmooth("dark")

-- Transition based on user preference
if GetConVar("lia_theme_dark"):GetBool() then
    lia.color.setThemeSmooth("dark")
else
    lia.color.setThemeSmooth("light")
end

-- Smooth transition with custom speed
-- Note: The transition speed can be modified by changing lia.color.transition.speed

-- Use in a menu
local themeButton = vgui.Create("DButton")
themeButton:SetText("Switch to Dark Theme")
themeButton.DoClick = function()
    lia.color.setThemeSmooth("dark")
end

-- Check if transition is in progress
lia.color.setThemeSmooth("blue")
timer.Simple(0.1, function()
    if lia.color.isTransitionActive() then
        print("Theme transition started")
    end
end)

-- Chain theme transitions
lia.color.setThemeSmooth("dark")
timer.Simple(2, function()
    lia.color.setThemeSmooth("light")
end)
```

