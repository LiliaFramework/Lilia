# Color Library

Comprehensive color and theme management system for the Lilia framework.

---

Overview

The color library provides comprehensive functionality for managing colors and themes in the Lilia framework. It handles color registration, theme management, color manipulation, and smooth theme transitions. The library operates primarily on the client side, with theme registration available on both server and client. It includes predefined color names, theme switching capabilities, color adjustment functions, and smooth animated transitions between themes. The library ensures consistent color usage across the entire gamemode interface and provides tools for creating custom themes and color schemes.

---

### lia.color.register

#### 📋 Purpose
Registers a named color for use throughout the gamemode

#### ⏰ When Called
When defining custom colors or extending the color palette

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | The name identifier for the color |
| `color` | **table** | Color table with r, g, b, a values or array format |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic color
    lia.color.register("myred", {255, 0, 0})

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register color with alpha channel
    lia.color.register("semitransparent", {255, 255, 255, 128})

```

#### ⚙️ High Complexity
```lua
    -- High: Register multiple colors from configuration
    local colorConfig = {
        primary   = {100, 150, 200},
        secondary = {200, 100, 150},
        accent    = {150, 200, 100}
    }
    for name, color in pairs(colorConfig) do
        lia.color.register(name, color)
    end

```

---

### lia.color.adjust

#### 📋 Purpose
Adjusts color values by adding offsets to each channel

#### ⏰ When Called
When creating color variations or adjusting existing colors

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | **Color** | The base color to adjust |
| `rOffset` | **number** | Red channel offset (-255 to 255) |
| `gOffset` | **number** | Green channel offset (-255 to 255) |
| `bOffset` | **number** | Blue channel offset (-255 to 255) |
| `aOffset` | **number, optional** | Alpha channel offset (-255 to 255) |

#### ↩️ Returns
* Color - New adjusted color with clamped values

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Brighten a color
    local brightRed = lia.color.adjust(Color(100, 0, 0), 50, 0, 0)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create color variations
    local baseColor = Color(128, 128, 128)
    local lighter = lia.color.adjust(baseColor, 30, 30, 30)
    local darker = lia.color.adjust(baseColor, -30, -30, -30)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic color adjustment based on conditions
    local function adjustColorForTime(color, timeOfDay)
        local multiplier = math.sin(timeOfDay * math.pi / 12) * 0.3
        return lia.color.adjust(color,
            multiplier * 50,
            multiplier * 30,
            multiplier * 20,
            multiplier * 100
        )
    end

```

---

### lia.color.darken

#### 📋 Purpose
Darkens a color by multiplying RGB values by a factor

#### ⏰ When Called
When creating darker variations of colors for shadows or depth

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `color` | **Color** | The color to darken |
| `factor` | **number, optional** | Darkening factor (0-1), defaults to 0.1 |

#### ↩️ Returns
* Color - New darkened color with preserved alpha

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Darken a color slightly
    local darkBlue = lia.color.darken(Color(0, 0, 255))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create shadow effect
    local baseColor = Color(100, 150, 200)
    local shadowColor = lia.color.darken(baseColor, 0.5)

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic darkening based on distance
    local function getShadowColor(baseColor, distance)
        local darkenFactor = math.min(distance / 1000, 0.8)
        return lia.color.darken(baseColor, darkenFactor)
    end

```

---

### lia.color.getCurrentTheme

#### 📋 Purpose
Gets the current active theme name in lowercase

#### ⏰ When Called
When checking which theme is currently active

#### ↩️ Returns
* string - Current theme name in lowercase

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check current theme
    local currentTheme = lia.color.getCurrentTheme()
    print("Current theme:", currentTheme)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Conditional theme-based logic
    if lia.color.getCurrentTheme() == "dark" then
        -- Apply dark theme specific settings
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Theme-based UI customization
    local function getThemeSpecificColor(colorName)
        local theme = lia.color.getCurrentTheme()
        local themeColors = {
            dark  = {primary = Color(100, 100, 100)},
            light = {primary = Color(200, 200, 200)}
        }
        return themeColors[theme] and themeColors[theme][colorName] or Color(255, 255, 255)
    end

```

---

### lia.color.getCurrentThemeName

#### 📋 Purpose
Gets the current active theme name with proper capitalization

#### ⏰ When Called
When displaying theme name to users or for configuration

#### ↩️ Returns
* string - Current theme name with proper capitalization

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display theme name
    local themeName = lia.color.getCurrentThemeName()
    print("Active theme:", themeName)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Theme selection menu
    local function createThemeMenu()
        local currentTheme = lia.color.getCurrentThemeName()
        local menu = vgui.Create("DFrame")
        menu:SetTitle("Current Theme: " .. currentTheme)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Theme validation and fallback
    local function validateTheme()
        local themeName = lia.color.getCurrentThemeName()
        local availableThemes = lia.color.getAllThemes()
        if not table.HasValue(availableThemes, themeName:lower()) then
            lia.config.set("Theme", "Teal")
            return "Teal"
        end
        return themeName
    end

```

---

### lia.color.getMainColor

#### 📋 Purpose
Gets the main color from the current theme

#### ⏰ When Called
When needing the primary accent color for UI elements

#### ↩️ Returns
* Color - The main color from current theme or default teal

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get main theme color
    local mainColor = lia.color.getMainColor()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Use main color for UI elements
    local function createThemedButton(text)
        local button = vgui.Create("DButton")
        button:SetText(text)
        button:SetTextColor(lia.color.getMainColor())
        return button
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic color scheme generation
    local function generateColorScheme()
        local mainColor = lia.color.getMainColor()
        return {
            primary    = mainColor,
            secondary  = lia.color.adjust(mainColor, -50, -50, -50),
            accent     = lia.color.adjust(mainColor, 50, 50, 50),
            background = lia.color.darken(mainColor, 0.8)
        }
    end

```

---

### lia.color.applyTheme

#### 📋 Purpose
Applies a theme to the interface with optional smooth transition

#### ⏰ When Called
When switching themes or initializing the color system

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `themeName` | **string, optional** | Name of theme to apply, defaults to current theme |
| `useTransition` | **boolean, optional** | Whether to use smooth transition animation |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Apply theme without transition
    lia.color.applyTheme("dark")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Apply theme with smooth transition
    lia.color.applyTheme("light", true)

```

#### ⚙️ High Complexity
```lua
    -- High: Theme switching with validation and fallback
    local function switchTheme(themeName)
        local availableThemes = lia.color.getAllThemes()
        if not table.HasValue(availableThemes, themeName:lower()) then
            themeName = "teal"
        end
        lia.color.applyTheme(themeName, true)
        lia.config.set("Theme", themeName)
        -- Notify other systems of theme change
        hook.Run("OnThemeChanged", themeName, true)
    end

```

---

### lia.color.isTransitionActive

#### 📋 Purpose
Checks if a theme transition animation is currently active

#### ⏰ When Called
When checking transition state before starting new transitions

#### ↩️ Returns
* boolean - True if transition is active, false otherwise

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if transition is running
    if lia.color.isTransitionActive() then
        print("Theme transition in progress")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Prevent multiple transitions
    local function safeThemeSwitch(themeName)
        if lia.color.isTransitionActive() then
            print("Please wait for current transition to finish")
            return
        end
        lia.color.applyTheme(themeName, true)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Queue theme changes during transitions
    local themeQueue = {}
    local function queueThemeChange(themeName)
        if lia.color.isTransitionActive() then
            table.insert(themeQueue, themeName)
        else
            lia.color.applyTheme(themeName, true)
        end
    end
    hook.Add("OnThemeChanged", "ProcessThemeQueue", function()
        if #themeQueue > 0 and not lia.color.isTransitionActive() then
            local nextTheme = table.remove(themeQueue, 1)
            lia.color.applyTheme(nextTheme, true)
        end
    end)

```

---

### lia.color.testThemeTransition

#### 📋 Purpose
Tests a theme transition by applying it with animation

#### ⏰ When Called
When previewing theme changes or testing transitions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `themeName` | **string** | Name of theme to test transition to |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Test theme transition
    lia.color.testThemeTransition("dark")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Preview multiple themes
    local function previewTheme(themeName)
        lia.color.testThemeTransition(themeName)
        timer.Simple(2, function()
            lia.color.applyTheme(lia.color.getCurrentTheme(), true)
        end)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Theme preview system with cycling
    local previewThemes = {"dark", "light", "blue", "red"}
    local currentPreview = 1
    local function cycleThemePreview()
        if lia.color.isTransitionActive() then return end
        local theme = previewThemes[currentPreview]
        lia.color.testThemeTransition(theme)
        currentPreview = (currentPreview % #previewThemes) + 1
        timer.Simple(3, cycleThemePreview)
    end

```

---

### lia.color.startThemeTransition

#### 📋 Purpose
Starts a smooth animated transition to a new theme

#### ⏰ When Called
When applying themes with transition animation enabled

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Name of the theme to transition to |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Start theme transition
    lia.color.startThemeTransition("dark")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Transition with validation
    local function transitionToTheme(themeName)
        if lia.color.isTransitionActive() then
            print("Transition already in progress")
            return
        end
        local availableThemes = lia.color.getAllThemes()
        if table.HasValue(availableThemes, themeName:lower()) then
            lia.color.startThemeTransition(themeName)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Custom transition with progress tracking
    local function customThemeTransition(themeName, callback)
        lia.color.startThemeTransition(themeName)
        local function checkProgress()
            if not lia.color.isTransitionActive() then
                if callback then callback() end
                return
            end
            timer.Simple(0.1, checkProgress)
        end
        checkProgress()
    end

```

---

### lia.color.isColor

#### 📋 Purpose
Checks if a value is a valid color object

#### ⏰ When Called
When validating color data or processing theme transitions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `v` | **any** | Value to check if it's a color |

#### ↩️ Returns
* boolean - True if value is a valid color, false otherwise

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if value is color
    if lia.color.isColor(someValue) then
        print("It's a color!")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Validate color data
    local function processColorData(data)
        if lia.color.isColor(data) then
            return data
        else
            return Color(255, 255, 255)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Recursive color validation in nested tables
    local function validateThemeData(themeData)
        for key, value in pairs(themeData) do
            if istable(value) and #value > 0 then
                for i, item in ipairs(value) do
                    if not lia.color.isColor(item) then
                        error("Invalid color at " .. key .. "[" .. i .. "]")
                    end
                end
            elseif lia.color.isColor(value) then
                -- Valid color
            else
                error("Invalid color at " .. key)
            end
        end
    end

```

---

### lia.color.returnMainAdjustedColors

#### 📋 Purpose
Returns a set of adjusted colors based on the main theme color

#### ⏰ When Called
When creating UI color schemes or theme-based color palettes

#### ↩️ Returns
* table - Table containing adjusted colors (background, sidebar, accent, text, hover, border, highlight)

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get theme colors
    local colors = lia.color.returnMainAdjustedColors()
    local bgColor = colors.background

```

#### 📊 Medium Complexity
```lua
    -- Medium: Apply colors to UI elements
    local function createThemedPanel()
        local colors = lia.color.returnMainAdjustedColors()
        local panel = vgui.Create("DPanel")
        panel:SetBackgroundColor(colors.background)
        panel.Paint = function(self, w, h)
            draw.RoundedBox(4, 0, 0, w, h, colors.background)
            draw.RoundedBox(4, 0, 0, w, 2, colors.accent)
        end
        return panel
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic UI system with theme colors
    local function createAdvancedUI()
        local colors = lia.color.returnMainAdjustedColors()
        local ui = {
            background = colors.background,
            primary    = colors.accent,
            secondary  = colors.sidebar,
            text       = colors.text,
            hover      = colors.hover,
            border     = colors.border,
            highlight  = colors.highlight
        }
        -- Apply colors to multiple UI elements
        for _, element in ipairs(uiElements) do
            element:SetColor(ui.primary)
            element:SetTextColor(ui.text)
        end
        return ui
    end

```

---

### lia.color.lerp

#### 📋 Purpose
Interpolates between two colors using frame time for smooth transitions

#### ⏰ When Called
During theme transitions to smoothly blend between colors

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `frac` | **number** | Interpolation factor/speed multiplier |
| `col1` | **Color** | Starting color |
| `col2` | **Color** | Target color |

#### ↩️ Returns
* Color - Interpolated color between col1 and col2

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Lerp between colors
    local blendedColor = lia.color.lerp(5, Color(255, 0, 0), Color(0, 255, 0))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Smooth color transition
    local function fadeBetweenColors(startColor, endColor, duration)
        local startTime = CurTime()
        hook.Add("Think", "ColorFade", function()
            local elapsed = CurTime() - startTime
            local progress = math.min(elapsed / duration, 1)
            if progress >= 1 then
                hook.Remove("Think", "ColorFade")
            end
            local currentColor = lia.color.lerp(10, startColor, endColor)
            -- Use currentColor for UI elements
        end)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Multi-color gradient system
    local function createColorGradient(colors, steps)
        local gradient = {}
        for i = 1, steps do
            local t = (i - 1) / (steps - 1)
            local colorIndex = math.floor(t * (#colors - 1)) + 1
            local nextIndex = math.min(colorIndex + 1, #colors)
            local localT = (t * (#colors - 1)) - (colorIndex - 1)
            gradient[i] = lia.color.lerp(1, colors[colorIndex], colors[nextIndex])
        end
        return gradient
    end

```

---

### lia.color.registerTheme

#### 📋 Purpose
Registers a new theme with color definitions

#### ⏰ When Called
When creating custom themes or extending the theme system

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Name of the theme to register |
| `themeData` | **table** | Table containing color definitions for the theme |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic theme
    lia.color.registerTheme("MyTheme", {
        maincolor   = Color(100, 150, 200),
        background  = Color(20, 20, 20),
        text        = Color(255, 255, 255)
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register theme with full color set
    lia.color.registerTheme("CustomDark", {
        header     = Color(40, 40, 40),
        background = Color(25, 25, 25),
        button     = Color(54, 54, 54),
        maincolor  = Color(106, 108, 197),
        text       = Color(255, 255, 255),
        accent     = Color(106, 108, 197)
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic theme generation
    local function generateThemeFromConfig(config)
        local themeData = {
            maincolor  = Color(config.primary.r, config.primary.g, config.primary.b),
            background = Color(config.background.r, config.background.g, config.background.b),
            text       = Color(config.text.r, config.text.g, config.text.b),
            accent     = Color(config.accent.r, config.accent.g, config.accent.b),
            panel      = {
                Color(config.panel1.r, config.panel1.g, config.panel1.b),
                Color(config.panel2.r, config.panel2.g, config.panel2.b),
                Color(config.panel3.r, config.panel3.g, config.panel3.b)
            }
        }
        lia.color.registerTheme(config.name, themeData)
    end

```

---

### lia.color.getAllThemes

#### 📋 Purpose
Gets a list of all available theme names

#### ⏰ When Called
When building theme selection menus or validating theme names

#### ↩️ Returns
* table - Array of theme names in alphabetical order

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all themes
    local themes = lia.color.getAllThemes()
    print("Available themes:", table.concat(themes, ", "))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create theme selection menu
    local function createThemeMenu()
        local themes = lia.color.getAllThemes()
        local menu = vgui.Create("DFrame")
        for _, themeName in ipairs(themes) do
            local button = vgui.Create("DButton", menu)
            button:SetText(themeName)
            button.DoClick = function()
                lia.color.applyTheme(themeName, true)
            end
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Theme validation and management system
    local function validateAndManageThemes()
        local themes = lia.color.getAllThemes()
        local validThemes = {}
        for _, themeName in ipairs(themes) do
            local themeData = lia.color.themes[themeName]
            if themeData and themeData.maincolor then
                table.insert(validThemes, {
                    name        = themeName,
                    displayName = themeName:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end),
                    mainColor   = themeData.maincolor
                })
            end
        end
        return validThemes
    end

```

---

