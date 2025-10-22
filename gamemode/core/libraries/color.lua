--[[
    Color Library

    Comprehensive color and theme management system for the Lilia framework.
]]

--[[
    Overview:
    The color library provides comprehensive functionality for managing colors and themes
    in the Lilia framework. It handles color registration, theme management, color
    manipulation, and smooth theme transitions. The library operates primarily on the
    client side, with theme registration available on both server and client. It includes
    predefined color names, theme switching capabilities, color adjustment functions,
    and smooth animated transitions between themes. The library ensures consistent
    color usage across the entire gamemode interface and provides tools for creating
    custom themes and color schemes.
]]
lia.color = lia.color or {}
lia.color.stored = lia.color.stored or {}
lia.color.themes = lia.color.themes or {}
if CLIENT then
    --[[
        Purpose: Registers a named color for use throughout the gamemode
        When Called: When defining custom colors or extending the color palette
        Parameters:
            name (string) - The name identifier for the color
            color (table) - Color table with r, g, b, a values or array format
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Register a basic color
        lia.color.register("myred", {255, 0, 0})
        ```

        Medium Complexity:
        ```lua
        -- Medium: Register color with alpha channel
        lia.color.register("semitransparent", {255, 255, 255, 128})
        ```

        High Complexity:
        ```lua
        -- High: Register multiple colors from configuration
        local colorConfig = {
            primary = {100, 150, 200},
            secondary = {200, 100, 150},
            accent = {150, 200, 100}
        }
        for name, color in pairs(colorConfig) do
            lia.color.register(name, color)
        end
        ```
    ]]
    function lia.color.register(name, color)
        lia.color.stored[name:lower()] = color
    end

    --[[
        Purpose: Adjusts color values by adding offsets to each channel
        When Called: When creating color variations or adjusting existing colors
        Parameters:
            color (Color) - The base color to adjust
            rOffset (number) - Red channel offset (-255 to 255)
            gOffset (number) - Green channel offset (-255 to 255)
            bOffset (number) - Blue channel offset (-255 to 255)
            aOffset (number, optional) - Alpha channel offset (-255 to 255)
        Returns: Color - New adjusted color with clamped values
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Brighten a color
        local brightRed = lia.color.adjust(Color(100, 0, 0), 50, 0, 0)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Create color variations
        local baseColor = Color(128, 128, 128)
        local lighter = lia.color.adjust(baseColor, 30, 30, 30)
        local darker = lia.color.adjust(baseColor, -30, -30, -30)
        ```

        High Complexity:
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
    ]]
    function lia.color.adjust(color, rOffset, gOffset, bOffset, aOffset)
        return Color(math.Clamp(color.r + rOffset, 0, 255), math.Clamp(color.g + gOffset, 0, 255), math.Clamp(color.b + bOffset, 0, 255), math.Clamp((color.a or 255) + (aOffset or 0), 0, 255))
    end

    --[[
        Purpose: Darkens a color by multiplying RGB values by a factor
        When Called: When creating darker variations of colors for shadows or depth
        Parameters:
            color (Color) - The color to darken
            factor (number, optional) - Darkening factor (0-1), defaults to 0.1
        Returns: Color - New darkened color with preserved alpha
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Darken a color slightly
        local darkBlue = lia.color.darken(Color(0, 0, 255))
        ```

        Medium Complexity:
        ```lua
        -- Medium: Create shadow effect
        local baseColor = Color(100, 150, 200)
        local shadowColor = lia.color.darken(baseColor, 0.5)
        ```

        High Complexity:
        ```lua
        -- High: Dynamic darkening based on distance
        local function getShadowColor(baseColor, distance)
            local darkenFactor = math.min(distance / 1000, 0.8)
            return lia.color.darken(baseColor, darkenFactor)
        end
        ```
    ]]
    function lia.color.darken(color, factor)
        factor = factor or 0.1
        local darkenFactor = 1 - math.Clamp(factor, 0, 1)
        return Color(math.floor(color.r * darkenFactor), math.floor(color.g * darkenFactor), math.floor(color.b * darkenFactor), color.a or 255)
    end

    --[[
        Purpose: Gets the current active theme name in lowercase
        When Called: When checking which theme is currently active
        Parameters: None
        Returns: string - Current theme name in lowercase
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Check current theme
        local currentTheme = lia.color.getCurrentTheme()
        print("Current theme:", currentTheme)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Conditional theme-based logic
        if lia.color.getCurrentTheme() == "dark" then
            -- Apply dark theme specific settings
        end
        ```

        High Complexity:
        ```lua
        -- High: Theme-based UI customization
        local function getThemeSpecificColor(colorName)
            local theme = lia.color.getCurrentTheme()
            local themeColors = {
                dark = {primary = Color(100, 100, 100)},
                light = {primary = Color(200, 200, 200)}
            }
            return themeColors[theme] and themeColors[theme][colorName] or Color(255, 255, 255)
        end
        ```
    ]]
    function lia.color.getCurrentTheme()
        return lia.config.get("Theme", "Teal"):lower()
    end

    --[[
        Purpose: Gets the current active theme name with proper capitalization
        When Called: When displaying theme name to users or for configuration
        Parameters: None
        Returns: string - Current theme name with proper capitalization
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Display theme name
        local themeName = lia.color.getCurrentThemeName()
        print("Active theme:", themeName)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Theme selection menu
        local function createThemeMenu()
            local currentTheme = lia.color.getCurrentThemeName()
            local menu = vgui.Create("DFrame")
            menu:SetTitle("Current Theme: " .. currentTheme)
        end
        ```

        High Complexity:
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
    ]]
    function lia.color.getCurrentThemeName()
        return lia.config.get("Theme", "Teal")
    end

    --[[
        Purpose: Gets the main color from the current theme
        When Called: When needing the primary accent color for UI elements
        Parameters: None
        Returns: Color - The main color from current theme or default teal
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Get main theme color
        local mainColor = lia.color.getMainColor()
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use main color for UI elements
        local function createThemedButton(text)
            local button = vgui.Create("DButton")
            button:SetText(text)
            button:SetTextColor(lia.color.getMainColor())
            return button
        end
        ```

        High Complexity:
        ```lua
        -- High: Dynamic color scheme generation
        local function generateColorScheme()
            local mainColor = lia.color.getMainColor()
            return {
                primary = mainColor,
                secondary = lia.color.adjust(mainColor, -50, -50, -50),
                accent = lia.color.adjust(mainColor, 50, 50, 50),
                background = lia.color.darken(mainColor, 0.8)
            }
        end
        ```
    ]]
    function lia.color.getMainColor()
        local currentTheme = lia.color.getCurrentTheme()
        local themeData = lia.color.themes[currentTheme]
        if themeData and themeData.maincolor then return themeData.maincolor end
        local defaultTheme = lia.color.themes["teal"]
        return defaultTheme and defaultTheme.maincolor or Color(80, 180, 180)
    end

    --[[
        Purpose: Applies a theme to the interface with optional smooth transition
        When Called: When switching themes or initializing the color system
        Parameters:
            themeName (string, optional) - Name of theme to apply, defaults to current theme
            useTransition (boolean, optional) - Whether to use smooth transition animation
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Apply theme without transition
        lia.color.applyTheme("dark")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Apply theme with smooth transition
        lia.color.applyTheme("light", true)
        ```

        High Complexity:
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
    ]]
    function lia.color.applyTheme(themeName, useTransition)
        themeName = themeName or lia.color.getCurrentTheme()
        local themeData = lia.color.themes[themeName]
        if not themeData then
            themeName = "Teal"
            themeData = lia.color.themes[themeName]
            if not themeData then
                ErrorNoHalt("[Lilia] " .. L("themeNoValidThemesFallback") .. "\n")
                lia.color.theme = {
                    maincolor = Color(80, 180, 180),
                    background = Color(24, 32, 32),
                    text = Color(210, 235, 235)
                }

                hook.Run("OnThemeChanged", themeName, useTransition)
                return
            else
                lia.config.set("Theme", themeName)
            end
        end

        if themeData then
            if useTransition and CLIENT then
                lia.color.startThemeTransition(themeName)
            else
                lia.color.theme = table.Copy(themeData)
            end

            hook.Run("OnThemeChanged", themeName, useTransition)
        end
    end

    --[[
        Purpose: Checks if a theme transition animation is currently active
        When Called: When checking transition state before starting new transitions
        Parameters: None
        Returns: boolean - True if transition is active, false otherwise
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Check if transition is running
        if lia.color.isTransitionActive() then
            print("Theme transition in progress")
        end
        ```

        Medium Complexity:
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

        High Complexity:
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
    ]]
    function lia.color.isTransitionActive()
        return lia.color.transition and lia.color.transition.active or false
    end

    --[[
        Purpose: Tests a theme transition by applying it with animation
        When Called: When previewing theme changes or testing transitions
        Parameters:
            themeName (string) - Name of theme to test transition to
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Test theme transition
        lia.color.testThemeTransition("dark")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Preview multiple themes
        local function previewTheme(themeName)
            lia.color.testThemeTransition(themeName)
            timer.Simple(2, function()
                lia.color.applyTheme(lia.color.getCurrentTheme(), true)
            end)
        end
        ```

        High Complexity:
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
    ]]
    function lia.color.testThemeTransition(themeName)
        lia.color.applyTheme(themeName, true)
    end

    lia.color.transition = {
        active = false,
        to = nil,
        progress = 0,
        speed = 3,
        colorBlend = 8
    }

    --[[
        Purpose: Starts a smooth animated transition to a new theme
        When Called: When applying themes with transition animation enabled
        Parameters:
            name (string) - Name of the theme to transition to
        Returns: None
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Start theme transition
        lia.color.startThemeTransition("dark")
        ```

        Medium Complexity:
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

        High Complexity:
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
    ]]
    function lia.color.startThemeTransition(name)
        local targetTheme = lia.color.themes[name:lower()]
        if not targetTheme then
            name = "Teal"
            targetTheme = lia.color.themes[name:lower()]
            if not targetTheme then
                ErrorNoHalt("[Lilia] " .. L("warning") .. ": " .. L("themeNoValidThemes") .. "\n")
                return
            end
        end

        lia.color.transition.to = table.Copy(targetTheme)
        lia.color.transition.active = true
        lia.color.transition.progress = 0
        if not hook.GetTable().LiliaThemeTransition then
            hook.Add("Think", "LiliaThemeTransition", function()
                if not lia.color.transition.active then return end
                local dt = FrameTime()
                lia.color.transition.progress = math.min(lia.color.transition.progress + (lia.color.transition.speed * dt), 1)
                local to = lia.color.transition.to
                if not to then
                    lia.color.transition.active = false
                    hook.Remove("Think", "LiliaThemeTransition")
                    return
                end

                for k, v in pairs(to) do
                    if lia.color.isColor(v) then
                        local current = lia.color.stored[k]
                        if current and lia.color.isColor(current) then
                            lia.color.stored[k] = lia.color.lerp(lia.color.transition.colorBlend, current, v)
                        else
                            lia.color.stored[k] = v
                        end
                    elseif istable(v) and #v > 0 then
                        if not lia.color.stored[k] then lia.color.stored[k] = {} end
                        for i = 1, #v do
                            local vi = v[i]
                            if lia.color.isColor(vi) then
                                local currentVal = lia.color.stored[k] and lia.color.stored[k][i]
                                if currentVal and lia.color.isColor(currentVal) then
                                    lia.color.stored[k][i] = lia.color.lerp(lia.color.transition.colorBlend, currentVal, vi)
                                else
                                    lia.color.stored[k][i] = vi
                                end
                            else
                                lia.color.stored[k][i] = vi
                            end
                        end
                    else
                        lia.color.stored[k] = v
                    end
                end

                if lia.color.transition.progress >= 0.999 then
                    for k, v in pairs(to) do
                        lia.color.stored[k] = v
                    end

                    lia.color.transition.active = false
                    hook.Remove("Think", "LiliaThemeTransition")
                    hook.Run("OnThemeChanged", name, false)
                end
            end)
        end
    end

    --[[
        Purpose: Checks if a value is a valid color object
        When Called: When validating color data or processing theme transitions
        Parameters:
            v (any) - Value to check if it's a color
        Returns: boolean - True if value is a valid color, false otherwise
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Check if value is color
        if lia.color.isColor(someValue) then
            print("It's a color!")
        end
        ```

        Medium Complexity:
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

        High Complexity:
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
    ]]
    function lia.color.isColor(v)
        return istable(v) and isnumber(v.r) and isnumber(v.g) and isnumber(v.b) and isnumber(v.a)
    end

    --[[
        Purpose: Returns a set of adjusted colors based on the main theme color
        When Called: When creating UI color schemes or theme-based color palettes
        Parameters: None
        Returns: table - Table containing adjusted colors (background, sidebar, accent, text, hover, border, highlight)
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Get theme colors
        local colors = lia.color.returnMainAdjustedColors()
        local bgColor = colors.background
        ```

        Medium Complexity:
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

        High Complexity:
        ```lua
        -- High: Dynamic UI system with theme colors
        local function createAdvancedUI()
            local colors = lia.color.returnMainAdjustedColors()

            local ui = {
                background = colors.background,
                primary = colors.accent,
                secondary = colors.sidebar,
                text = colors.text,
                hover = colors.hover,
                border = colors.border,
                highlight = colors.highlight
            }

            -- Apply colors to multiple UI elements
            for _, element in ipairs(uiElements) do
                element:SetColor(ui.primary)
                element:SetTextColor(ui.text)
            end

            return ui
        end
        ```
    ]]
    function lia.color.returnMainAdjustedColors()
        local base = lia.color.getMainColor()
        local background = lia.color.adjust(base, -20, -10, -50, 0)
        local brightness = background.r * 0.299 + background.g * 0.587 + background.b * 0.114
        local textColor = brightness > 128 and Color(30, 30, 30, 255) or Color(245, 245, 220, 255)
        return {
            background = background,
            sidebar = lia.color.adjust(base, -30, -15, -60, -55),
            accent = base,
            text = textColor,
            hover = lia.color.adjust(base, -40, -25, -70, -35),
            border = Color(255, 255, 255, 255),
            highlight = Color(255, 255, 255, 30)
        }
    end

    --[[
        Purpose: Interpolates between two colors using frame time for smooth transitions
        When Called: During theme transitions to smoothly blend between colors
        Parameters:
            frac (number) - Interpolation factor/speed multiplier
            col1 (Color) - Starting color
            col2 (Color) - Target color
        Returns: Color - Interpolated color between col1 and col2
        Realm: Client
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Lerp between colors
        local blendedColor = lia.color.lerp(5, Color(255, 0, 0), Color(0, 255, 0))
        ```

        Medium Complexity:
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

        High Complexity:
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
    ]]
    function lia.color.lerp(frac, col1, col2)
        local ft = FrameTime() * frac
        local r1 = col1 and col1.r or 255
        local g1 = col1 and col1.g or 255
        local b1 = col1 and col1.b or 255
        local a1 = col1 and col1.a or 255
        local r2 = col2 and col2.r or 255
        local g2 = col2 and col2.g or 255
        local b2 = col2 and col2.b or 255
        local a2 = col2 and col2.a or 255
        return Color(Lerp(ft, r1, r2), Lerp(ft, g1, g2), Lerp(ft, b1, b2), Lerp(ft, a1, a2))
    end

    local oldColor = Color
    function Color(r, g, b, a)
        if isstring(r) then
            local c = lia.color.stored[r:lower()]
            if c and istable(c) and c.r and c.g and c.b and c.a then return oldColor(c.r, c.g, c.b, c.a) end
            return oldColor(255, 255, 255, 255)
        end
        return oldColor(r, g, b, a)
    end

    lia.color.register("black", {0, 0, 0})
    lia.color.register("white", {255, 255, 255})
    lia.color.register("gray", {128, 128, 128})
    lia.color.register("dark_gray", {64, 64, 64})
    lia.color.register("light_gray", {192, 192, 192})
    lia.color.register("red", {255, 0, 0})
    lia.color.register("dark_red", {139, 0, 0})
    lia.color.register("green", {0, 255, 0})
    lia.color.register("dark_green", {0, 100, 0})
    lia.color.register("blue", {0, 0, 255})
    lia.color.register("dark_blue", {0, 0, 139})
    lia.color.register("yellow", {255, 255, 0})
    lia.color.register("orange", {255, 165, 0})
    lia.color.register("purple", {128, 0, 128})
    lia.color.register("pink", {255, 192, 203})
    lia.color.register("brown", {165, 42, 42})
    lia.color.register("maroon", {128, 0, 0})
    lia.color.register("navy", {0, 0, 128})
    lia.color.register("olive", {128, 128, 0})
    lia.color.register("teal", {0, 128, 128})
    lia.color.register("cyan", {0, 255, 255})
    lia.color.register("magenta", {255, 0, 255})
    hook.Add("InitializedConfig", "ApplyTheme", function() lia.color.applyTheme() end)
end

--[[
    Purpose: Registers a new theme with color definitions
    When Called: When creating custom themes or extending the theme system
    Parameters:
        name (string) - Name of the theme to register
        themeData (table) - Table containing color definitions for the theme
    Returns: None
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Register a basic theme
    lia.color.registerTheme("MyTheme", {
        maincolor = Color(100, 150, 200),
        background = Color(20, 20, 20),
        text = Color(255, 255, 255)
    })
    ```

    Medium Complexity:
    ```lua
    -- Medium: Register theme with full color set
    lia.color.registerTheme("CustomDark", {
        header = Color(40, 40, 40),
        background = Color(25, 25, 25),
        button = Color(54, 54, 54),
        maincolor = Color(106, 108, 197),
        text = Color(255, 255, 255),
        accent = Color(106, 108, 197)
    })
    ```

    High Complexity:
    ```lua
    -- High: Dynamic theme generation
    local function generateThemeFromConfig(config)
        local themeData = {
            maincolor = Color(config.primary.r, config.primary.g, config.primary.b),
            background = Color(config.background.r, config.background.g, config.background.b),
            text = Color(config.text.r, config.text.g, config.text.b),
            accent = Color(config.accent.r, config.accent.g, config.accent.b),
            panel = {
                Color(config.panel1.r, config.panel1.g, config.panel1.b),
                Color(config.panel2.r, config.panel2.g, config.panel2.b),
                Color(config.panel3.r, config.panel3.g, config.panel3.b)
            }
        }

        lia.color.registerTheme(config.name, themeData)
    end
    ```
]]
function lia.color.registerTheme(name, themeData)
    local id = name:lower()
    lia.color.themes[id] = themeData
end

--[[
    Purpose: Gets a list of all available theme names
    When Called: When building theme selection menus or validating theme names
    Parameters: None
    Returns: table - Array of theme names in alphabetical order
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Get all themes
    local themes = lia.color.getAllThemes()
    print("Available themes:", table.concat(themes, ", "))
    ```

    Medium Complexity:
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

    High Complexity:
    ```lua
    -- High: Theme validation and management system
    local function validateAndManageThemes()
        local themes = lia.color.getAllThemes()
        local validThemes = {}

        for _, themeName in ipairs(themes) do
            local themeData = lia.color.themes[themeName]
            if themeData and themeData.maincolor then
                table.insert(validThemes, {
                    name = themeName,
                    displayName = themeName:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest)
                        return first:upper() .. rest:lower()
                    end),
                    mainColor = themeData.maincolor
                })
            end
        end

        return validThemes
    end
    ```
]]
function lia.color.getAllThemes()
    local themes = {}
    for id, _ in pairs(lia.color.themes) do
        themes[#themes + 1] = id
    end

    table.sort(themes)
    return themes
end

lia.color.registerTheme("Teal", {
    header = Color(36, 54, 54),
    header_text = Color(109, 159, 159),
    background = Color(24, 32, 32),
    background_alpha = Color(24, 32, 32, 210),
    background_panelpopup = Color(20, 28, 28),
    button = Color(38, 66, 66),
    button_shadow = Color(18, 32, 32, 35),
    button_hovered = Color(70, 140, 140),
    category = Color(34, 62, 62),
    category_opened = Color(34, 62, 62, 0),
    theme = Color(60, 140, 140),
    maincolor = Color(60, 140, 140),
    panel = {Color(34, 62, 62), Color(38, 66, 66), Color(50, 110, 110)},
    panel_alpha = {ColorAlpha(Color(34, 62, 62), 110), ColorAlpha(Color(38, 66, 66), 110), ColorAlpha(Color(50, 110, 110), 110)},
    focus_panel = Color(48, 72, 72),
    hover = Color(60, 140, 140, 90),
    window_shadow = Color(18, 32, 32, 90),
    gray = Color(150, 180, 180, 200),
    text = Color(210, 235, 235),
    text_entry = Color(210, 235, 235),
    accent = Color(60, 140, 140),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Dark", {
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background = Color(25, 25, 25),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20, 150),
    button = Color(54, 54, 54),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 62),
    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),
    theme = Color(106, 108, 197),
    maincolor = Color(106, 108, 197),
    panel = {Color(60, 60, 60), Color(50, 50, 50), Color(80, 80, 80)},
    panel_alpha = {ColorAlpha(Color(60, 60, 60), 150), ColorAlpha(Color(50, 50, 50), 150), ColorAlpha(Color(80, 80, 80), 150)},
    toggle = Color(56, 56, 56),
    focus_panel = Color(46, 46, 46),
    hover = Color(60, 65, 80),
    window_shadow = Color(0, 0, 0, 100),
    gray = Color(150, 150, 150, 220),
    text = Color(255, 255, 255),
    text_entry = Color(255, 255, 255),
    accent = Color(106, 108, 197),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Dark Mono", {
    header = Color(40, 40, 40),
    header_text = Color(100, 100, 100),
    background = Color(25, 25, 25),
    background_alpha = Color(25, 25, 25, 210),
    background_panelpopup = Color(20, 20, 20, 150),
    button = Color(54, 54, 54),
    button_shadow = Color(0, 0, 0, 25),
    button_hovered = Color(60, 60, 62),
    category = Color(50, 50, 50),
    category_opened = Color(50, 50, 50, 0),
    theme = Color(121, 121, 121),
    maincolor = Color(121, 121, 121),
    panel = {Color(60, 60, 60), Color(50, 50, 50), Color(80, 80, 80)},
    panel_alpha = {ColorAlpha(Color(60, 60, 60), 150), ColorAlpha(Color(50, 50, 50), 150), ColorAlpha(Color(80, 80, 80), 150)},
    toggle = Color(56, 56, 56),
    focus_panel = Color(46, 46, 46),
    hover = Color(60, 65, 80),
    window_shadow = Color(0, 0, 0, 100),
    gray = Color(150, 150, 150, 220),
    text = Color(255, 255, 255),
    text_entry = Color(255, 255, 255),
    accent = Color(121, 121, 121),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Blue", {
    header = Color(36, 48, 66),
    header_text = Color(109, 129, 159),
    background = Color(24, 28, 38),
    background_alpha = Color(24, 28, 38, 210),
    background_panelpopup = Color(20, 24, 32, 150),
    button = Color(38, 54, 82),
    button_shadow = Color(18, 22, 32, 35),
    button_hovered = Color(47, 69, 110),
    category = Color(34, 48, 72),
    category_opened = Color(34, 48, 72, 0),
    theme = Color(80, 160, 220),
    maincolor = Color(80, 160, 220),
    panel = {Color(34, 48, 72), Color(38, 54, 82), Color(70, 120, 180)},
    panel_alpha = {ColorAlpha(Color(34, 48, 72), 110), ColorAlpha(Color(38, 54, 82), 110), ColorAlpha(Color(70, 120, 180), 110)},
    toggle = Color(34, 44, 66),
    focus_panel = Color(48, 72, 90),
    hover = Color(80, 160, 220, 90),
    window_shadow = Color(18, 22, 32, 100),
    gray = Color(150, 170, 190, 200),
    text = Color(210, 220, 235),
    text_entry = Color(210, 220, 235),
    accent = Color(80, 160, 220),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Red", {
    header = Color(54, 36, 36),
    header_text = Color(159, 109, 109),
    background = Color(32, 24, 24),
    background_alpha = Color(32, 24, 24, 210),
    background_panelpopup = Color(28, 20, 20, 150),
    button = Color(66, 38, 38),
    button_shadow = Color(32, 18, 18, 35),
    button_hovered = Color(97, 50, 50),
    category = Color(62, 34, 34),
    category_opened = Color(62, 34, 34, 0),
    theme = Color(180, 80, 80),
    maincolor = Color(180, 80, 80),
    panel = {Color(62, 34, 34), Color(66, 38, 38), Color(140, 70, 70)},
    panel_alpha = {ColorAlpha(Color(62, 34, 34), 110), ColorAlpha(Color(66, 38, 38), 110), ColorAlpha(Color(140, 70, 70), 110)},
    toggle = Color(60, 34, 34),
    focus_panel = Color(72, 48, 48),
    hover = Color(180, 80, 80, 90),
    window_shadow = Color(32, 18, 18, 100),
    gray = Color(180, 150, 150, 200),
    text = Color(235, 210, 210),
    text_entry = Color(235, 210, 210),
    accent = Color(180, 80, 80),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Light", {
    header = Color(240, 240, 240),
    header_text = Color(150, 150, 150),
    background = Color(255, 255, 255),
    background_alpha = Color(255, 255, 255, 170),
    background_panelpopup = Color(245, 245, 245, 150),
    button = Color(235, 235, 235),
    button_shadow = Color(0, 0, 0, 15),
    button_hovered = Color(196, 199, 218),
    category = Color(240, 240, 245),
    category_opened = Color(240, 240, 245, 0),
    theme = Color(106, 108, 197),
    maincolor = Color(106, 108, 197),
    panel = {Color(250, 250, 255), Color(240, 240, 245), Color(230, 230, 235)},
    panel_alpha = {ColorAlpha(Color(250, 250, 255), 120), ColorAlpha(Color(240, 240, 245), 120), ColorAlpha(Color(230, 230, 235), 120)},
    toggle = Color(220, 220, 230),
    focus_panel = Color(245, 245, 255),
    hover = Color(235, 240, 255),
    window_shadow = Color(0, 0, 0, 50),
    gray = Color(130, 130, 130, 220),
    text = Color(20, 20, 20),
    text_entry = Color(20, 20, 20),
    accent = Color(106, 108, 197),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Green", {
    header = Color(36, 54, 40),
    header_text = Color(109, 159, 109),
    background = Color(24, 32, 26),
    background_alpha = Color(24, 32, 26, 210),
    background_panelpopup = Color(20, 28, 22, 150),
    button = Color(38, 66, 48),
    button_shadow = Color(18, 32, 22, 35),
    button_hovered = Color(48, 88, 62),
    category = Color(34, 62, 44),
    category_opened = Color(34, 62, 44, 0),
    theme = Color(80, 180, 120),
    maincolor = Color(80, 180, 120),
    panel = {Color(34, 62, 44), Color(38, 66, 48), Color(70, 140, 90)},
    panel_alpha = {ColorAlpha(Color(34, 62, 44), 110), ColorAlpha(Color(38, 66, 48), 110), ColorAlpha(Color(70, 140, 90), 110)},
    toggle = Color(34, 60, 44),
    focus_panel = Color(48, 72, 58),
    hover = Color(80, 180, 120, 90),
    window_shadow = Color(18, 32, 22, 100),
    gray = Color(150, 180, 150, 200),
    text = Color(210, 235, 210),
    text_entry = Color(210, 235, 210),
    accent = Color(80, 180, 120),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Orange", {
    header = Color(70, 35, 10),
    header_text = Color(250, 230, 210),
    background = Color(255, 250, 240),
    background_alpha = Color(255, 250, 240, 220),
    background_panelpopup = Color(255, 245, 235, 160),
    button = Color(184, 122, 64),
    button_shadow = Color(20, 10, 0, 30),
    button_hovered = Color(197, 129, 65),
    category = Color(255, 245, 235),
    category_opened = Color(255, 245, 235, 0),
    theme = Color(245, 130, 50),
    maincolor = Color(245, 130, 50),
    panel = {Color(255, 250, 240), Color(250, 220, 180), Color(235, 150, 90)},
    panel_alpha = {ColorAlpha(Color(255, 250, 240), 120), ColorAlpha(Color(250, 220, 180), 120), ColorAlpha(Color(235, 150, 90), 120)},
    toggle = Color(143, 121, 104),
    focus_panel = Color(255, 240, 225),
    hover = Color(255, 165, 80, 90),
    window_shadow = Color(20, 8, 0, 100),
    gray = Color(180, 161, 150, 200),
    text = Color(45, 20, 10),
    text_entry = Color(45, 20, 10),
    accent = Color(245, 130, 50),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Purple", {
    header = Color(40, 36, 56),
    header_text = Color(150, 140, 180),
    background = Color(25, 22, 30),
    background_alpha = Color(25, 22, 30, 210),
    background_panelpopup = Color(28, 24, 40, 150),
    button = Color(58, 52, 76),
    button_shadow = Color(8, 6, 20, 30),
    button_hovered = Color(74, 64, 105),
    category = Color(46, 40, 60),
    category_opened = Color(46, 40, 60, 0),
    theme = Color(138, 114, 219),
    maincolor = Color(138, 114, 219),
    panel = {Color(56, 48, 76), Color(44, 36, 64), Color(120, 90, 200)},
    panel_alpha = {ColorAlpha(Color(56, 48, 76), 150), ColorAlpha(Color(44, 36, 64), 150), ColorAlpha(Color(120, 90, 200), 150)},
    toggle = Color(43, 39, 53),
    focus_panel = Color(48, 42, 62),
    hover = Color(138, 114, 219, 90),
    window_shadow = Color(8, 6, 20, 100),
    gray = Color(140, 128, 148, 220),
    text = Color(245, 240, 255),
    text_entry = Color(245, 240, 255),
    accent = Color(138, 114, 219),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Coffee", {
    header = Color(67, 48, 36),
    header_text = Color(210, 190, 170),
    background = Color(45, 32, 25),
    background_alpha = Color(45, 32, 25, 215),
    background_panelpopup = Color(38, 28, 22, 150),
    button = Color(84, 60, 45),
    button_shadow = Color(20, 10, 5, 40),
    button_hovered = Color(100, 75, 55),
    category = Color(72, 54, 42),
    category_opened = Color(72, 54, 42, 0),
    theme = Color(150, 110, 75),
    maincolor = Color(150, 110, 75),
    panel = {Color(68, 50, 40), Color(90, 65, 50), Color(150, 110, 75)},
    panel_alpha = {ColorAlpha(Color(68, 50, 40), 110), ColorAlpha(Color(90, 65, 50), 110), ColorAlpha(Color(150, 110, 75), 110)},
    toggle = Color(53, 40, 31),
    focus_panel = Color(70, 55, 40),
    hover = Color(150, 110, 75, 90),
    window_shadow = Color(15, 10, 5, 100),
    gray = Color(180, 150, 130, 200),
    text = Color(235, 225, 210),
    text_entry = Color(235, 225, 210),
    accent = Color(150, 110, 75),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Ice", {
    header = Color(190, 225, 250),
    header_text = Color(68, 104, 139),
    background = Color(235, 245, 255),
    background_alpha = Color(235, 245, 255, 200),
    background_panelpopup = Color(220, 235, 245, 150),
    button = Color(145, 185, 225),
    button_shadow = Color(80, 110, 140, 40),
    button_hovered = Color(170, 210, 255),
    category = Color(200, 225, 245),
    category_opened = Color(200, 225, 245, 0),
    theme = Color(100, 170, 230),
    maincolor = Color(100, 170, 230),
    panel = {Color(146, 186, 211), Color(107, 157, 190), Color(74, 132, 184)},
    panel_alpha = {ColorAlpha(Color(146, 186, 211), 120), ColorAlpha(Color(107, 157, 190), 120), ColorAlpha(Color(74, 132, 184), 120)},
    toggle = Color(168, 194, 219),
    focus_panel = Color(205, 230, 245),
    hover = Color(100, 170, 230, 80),
    window_shadow = Color(60, 100, 140, 100),
    gray = Color(92, 112, 133, 200),
    text = Color(20, 35, 50),
    text_entry = Color(20, 35, 50),
    accent = Color(100, 170, 230),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Wine", {
    header = Color(59, 42, 53),
    header_text = Color(246, 242, 246),
    background = Color(31, 23, 22),
    background_alpha = Color(31, 23, 22, 210),
    background_panelpopup = Color(36, 28, 28, 150),
    button = Color(79, 50, 60),
    button_shadow = Color(10, 6, 18, 30),
    button_hovered = Color(90, 52, 65),
    category = Color(79, 50, 60),
    category_opened = Color(79, 50, 60, 0),
    theme = Color(148, 61, 91),
    maincolor = Color(148, 61, 91),
    panel = {Color(79, 50, 60), Color(63, 44, 48), Color(160, 85, 143)},
    panel_alpha = {ColorAlpha(Color(79, 50, 60), 150), ColorAlpha(Color(63, 44, 48), 150), ColorAlpha(Color(160, 85, 143), 150)},
    toggle = Color(63, 40, 47),
    focus_panel = Color(70, 48, 58),
    hover = Color(192, 122, 217, 90),
    window_shadow = Color(10, 6, 20, 100),
    gray = Color(170, 150, 160, 200),
    text = Color(246, 242, 246),
    text_entry = Color(246, 242, 246),
    accent = Color(148, 61, 91),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Violet", {
    header = Color(49, 50, 68),
    header_text = Color(238, 244, 255),
    background = Color(22, 24, 35),
    background_alpha = Color(22, 24, 35, 210),
    background_panelpopup = Color(36, 40, 56, 150),
    button = Color(58, 64, 84),
    button_shadow = Color(8, 6, 18, 30),
    button_hovered = Color(64, 74, 104),
    category = Color(58, 64, 84),
    category_opened = Color(58, 64, 84, 0),
    theme = Color(159, 180, 255),
    maincolor = Color(159, 180, 255),
    panel = {Color(58, 64, 84), Color(48, 52, 72), Color(109, 136, 255)},
    panel_alpha = {ColorAlpha(Color(58, 64, 84), 150), ColorAlpha(Color(48, 52, 72), 150), ColorAlpha(Color(109, 136, 255), 150)},
    toggle = Color(46, 51, 66),
    focus_panel = Color(56, 62, 86),
    hover = Color(159, 180, 255, 90),
    window_shadow = Color(8, 6, 20, 100),
    gray = Color(147, 147, 184, 200),
    text = Color(238, 244, 255),
    text_entry = Color(238, 244, 255),
    accent = Color(159, 180, 255),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Moss", {
    header = Color(42, 50, 36),
    header_text = Color(232, 244, 235),
    background = Color(14, 16, 12),
    background_alpha = Color(14, 16, 12, 210),
    background_panelpopup = Color(24, 28, 22, 150),
    button = Color(64, 82, 60),
    button_shadow = Color(6, 8, 6, 30),
    button_hovered = Color(74, 99, 68),
    category = Color(46, 64, 44),
    category_opened = Color(46, 64, 44, 0),
    theme = Color(110, 160, 90),
    maincolor = Color(110, 160, 90),
    panel = {Color(40, 56, 40), Color(66, 86, 66), Color(110, 160, 90)},
    panel_alpha = {ColorAlpha(Color(40, 56, 40), 150), ColorAlpha(Color(66, 86, 66), 150), ColorAlpha(Color(110, 160, 90), 150)},
    toggle = Color(35, 44, 34),
    focus_panel = Color(46, 58, 44),
    hover = Color(110, 160, 90, 90),
    window_shadow = Color(0, 0, 0, 100),
    gray = Color(148, 165, 140, 220),
    text = Color(232, 244, 235),
    text_entry = Color(232, 244, 235),
    accent = Color(110, 160, 90),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.color.registerTheme("Coral", {
    header = Color(52, 32, 36),
    header_text = Color(255, 243, 242),
    background = Color(18, 14, 16),
    background_alpha = Color(18, 14, 16, 210),
    background_panelpopup = Color(30, 22, 24, 150),
    button = Color(116, 66, 61),
    button_shadow = Color(8, 4, 6, 30),
    button_hovered = Color(134, 73, 68),
    category = Color(74, 40, 42),
    category_opened = Color(74, 40, 42, 0),
    theme = Color(255, 120, 90),
    maincolor = Color(255, 120, 90),
    panel = {Color(66, 38, 40), Color(120, 60, 56), Color(240, 120, 90)},
    panel_alpha = {ColorAlpha(Color(66, 38, 40), 150), ColorAlpha(Color(120, 60, 56), 150), ColorAlpha(Color(240, 120, 90), 150)},
    toggle = Color(58, 39, 37),
    focus_panel = Color(72, 42, 44),
    hover = Color(255, 120, 90, 90),
    window_shadow = Color(0, 0, 0, 100),
    gray = Color(167, 136, 136, 220),
    text = Color(255, 243, 242),
    text_entry = Color(255, 243, 242),
    accent = Color(255, 120, 90),
    chat = Color(255, 239, 150),
    chatListen = Color(168, 240, 170)
})

lia.config.add("Theme", "theme", "Teal", function(_, newValue)
    if CLIENT then
        if not lia.color.themes[newValue] then
            newValue = "Teal"
            if not lia.color.themes[newValue] then
                ErrorNoHalt("[Lilia] " .. L("warning") .. ": " .. L("themeInvalidTheme", tostring(newValue)) .. "\n")
                return
            end
        end

        lia.color.applyTheme(newValue, true)
    end
end, {
    desc = "themeDesc",
    category = "categoryVisuals",
    type = "Table",
    options = function()
        local themes = {}
        local themeIDs = lia.color.getAllThemes()
        for _, themeID in ipairs(themeIDs) do
            local displayName = themeID:gsub("_", " "):gsub("(%a)([%w]*)", function(first, rest) return first:upper() .. rest:lower() end)
            themes[displayName] = themeID
        end
        return themes
    end
})
