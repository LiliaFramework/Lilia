--[[
    Folder: Developer - Libraries
    File: lia.color.md
]]
--[[
    Color

    Color and theme helpers for Lilia UI colors, named color lookup, theme registration, active theme application, and clientside theme transitions.
]]
--[[
    Overview:
        The color library centralizes Lilia color storage under `lia.color`. It stores named colors, registers UI themes, applies the configured theme, provides utility functions for color adjustment and interpolation, and supports animated clientside transitions between themes.
]]
--[[
    Hooks:
        OnThemeChanged(string themeName, boolean useTransition)

    Purpose:
        Runs when a theme is applied or when a theme transition finishes.

    Category:
        Color

    Parameters:
        themeName (string)
            The theme identifier that was applied.

        useTransition (boolean)
            True when the theme change was requested with transition behavior. False when applied directly or when a transition completes.

    Example Usage:
        ```lua
        hook.Add("OnThemeChanged", "liaExampleOnThemeChanged", function(themeName, useTransition)
            print("[MyModule] handled OnThemeChanged")
        end)
        ```

    Realm:
        Client
]]
lia.color = lia.color or {}
lia.color.stored = lia.color.stored or {}
lia.color.themes = lia.color.themes or {}
if SERVER then
    hook.Add("OnConfigUpdated", "liaThemeSkinSpawnmenuReload", function(key, oldValue, newValue)
        if oldValue == newValue then return end
        if key ~= "Theme" and key ~= "DermaSkin" then return end
        for _, ply in player.Iterator() do
            if IsValid(ply) and ply:IsPlayer() then ply:ConCommand("spawnmenu_reload") end
        end
    end)
else
    --[[
    Purpose:
        Registers a named color value in `lia.color.stored` using a lowercase key.

    Parameters:
        name (string)
            The color name to register.

        color (Color|table)
            The color value to store for the provided name.

    Example Usage:
        ```lua
        lia.color.register("warning", Color(255, 180, 0))
        lia.color.register("panel_shadow", Color(0, 0, 0, 120))
        ```

    Realm:
        Client
]]
    function lia.color.register(name, color)
        lia.color.stored[name:lower()] = color
    end

    --[[
    Purpose:
        Returns a new color with channel offsets applied and clamped between 0 and 255.

    Parameters:
        color (Color)
            The base color to adjust.

        rOffset (number)
            The amount to add to the red channel.

        gOffset (number)
            The amount to add to the green channel.

        bOffset (number)
            The amount to add to the blue channel.

        aOffset (number|nil)
            Optional amount to add to the alpha channel.

    Returns:
        Color
            The adjusted color.

    Example Usage:
        ```lua
        local hoverColor = lia.color.adjust(lia.color.getMainColor(), 20, 20, 20)
        local transparentColor = lia.color.adjust(Color(80, 120, 180, 255), 0, 0, 0, -80)
        ```

    Realm:
        Client
]]
    function lia.color.adjust(color, rOffset, gOffset, bOffset, aOffset)
        return Color(math.Clamp(color.r + rOffset, 0, 255), math.Clamp(color.g + gOffset, 0, 255), math.Clamp(color.b + bOffset, 0, 255), math.Clamp((color.a or 255) + (aOffset or 0), 0, 255))
    end

    --[[
    Purpose:
        Returns a darker copy of the provided color.

    Parameters:
        color (Color)
            The color to darken.

        factor (number|nil)
            Optional darkening strength from 0 to 1. Defaults to 0.1.

    Returns:
        Color
            The darkened color.

    Example Usage:
        ```lua
        local shadow = lia.color.darken(lia.color.getMainColor(), 0.35)
        ```

    Realm:
        Client
]]
    function lia.color.darken(color, factor)
        factor = factor or 0.1
        local darkenFactor = 1 - math.Clamp(factor, 0, 1)
        return Color(math.floor(color.r * darkenFactor), math.floor(color.g * darkenFactor), math.floor(color.b * darkenFactor), color.a or 255)
    end

    --[[
    Purpose:
        Gets the configured theme identifier in lowercase form.

    Returns:
        string
            The lowercase configured theme identifier.

    Example Usage:
        ```lua
        local themeID = lia.color.getCurrentTheme()
        ```

    Realm:
        Client
]]
    function lia.color.getCurrentTheme()
        return lia.config.get("Theme", "Teal"):lower()
    end

    --[[
    Purpose:
        Gets the configured theme value exactly as stored in config.

    Returns:
        string
            The configured theme name or `Teal` when no value is configured.

    Example Usage:
        ```lua
        local themeName = lia.color.getCurrentThemeName()
        ```

    Realm:
        Client
]]
    function lia.color.getCurrentThemeName()
        return lia.config.get("Theme", "Teal")
    end

    --[[
    Purpose:
        Gets the main color for the currently configured theme.

    Returns:
        Color
            The current theme main color, the teal theme main color, or the built-in fallback color.

    Example Usage:
        ```lua
        surface.SetDrawColor(lia.color.getMainColor())
        ```

    Realm:
        Client
]]
    function lia.color.getMainColor()
        local currentTheme = lia.color.getCurrentTheme()
        local themeData = lia.color.themes[currentTheme]
        if themeData and themeData.maincolor then return themeData.maincolor end
        local defaultTheme = lia.color.themes["teal"]
        return defaultTheme and defaultTheme.maincolor or Color(80, 180, 180)
    end

    --[[
    Purpose:
        Applies a theme by name, optionally using a clientside transition, and runs `OnThemeChanged`.

    Parameters:
        themeName (string|nil)
            Optional theme name to apply. Uses the configured theme when omitted.

        useTransition (boolean|nil)
            Whether to start a theme transition instead of applying the theme directly.

    Example Usage:
        ```lua
        lia.color.applyTheme("dark", false)
        lia.color.applyTheme("blue", true)
        ```

    Realm:
        Client
]]
    function lia.color.applyTheme(themeName, useTransition)
        themeName = (themeName or lia.color.getCurrentTheme()):lower()
        local themeData = lia.color.themes[themeName]
        if not themeData then
            themeName = "teal"
            themeData = lia.color.themes[themeName]
            if not themeData then
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
    Purpose:
        Checks whether a theme transition is currently active.

    Returns:
        boolean
            True when a theme transition is active, otherwise false.

    Example Usage:
        ```lua
        if lia.color.isTransitionActive() then return end
        ```

    Realm:
        Client
]]
    function lia.color.isTransitionActive()
        return lia.color.transition and lia.color.transition.active or false
    end

    --[[
    Purpose:
        Starts a transition to the provided theme name through `lia.color.applyTheme`.

    Parameters:
        themeName (string)
            The theme name to transition to.

    Example Usage:
        ```lua
        lia.color.testThemeTransition("purple")
        ```

    Realm:
        Client
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
    Purpose:
        Starts an animated transition from stored color values toward a target theme.

    Parameters:
        name (string)
            The target theme name. Falls back to `Teal` when the requested theme is unavailable.

    Example Usage:
        ```lua
        lia.color.startThemeTransition("coffee")
        ```

    Realm:
        Client
]]
    function lia.color.startThemeTransition(name)
        local targetTheme = lia.color.themes[name:lower()]
        if not targetTheme then
            name = "Teal"
            targetTheme = lia.color.themes[name:lower()]
            if not targetTheme then return end
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
    Purpose:
        Checks whether a value is a color table with numeric red, green, blue, and alpha channels.

    Parameters:
        v (any)
            The value to check.

    Returns:
        boolean
            True when the value has numeric `r`, `g`, `b`, and `a` fields, otherwise false.

    Example Usage:
        ```lua
        if lia.color.isColor(lia.color.getMainColor()) then
            surface.SetDrawColor(lia.color.getMainColor())
        end
        ```

    Realm:
        Client
]]
    function lia.color.isColor(v)
        return istable(v) and isnumber(v.r) and isnumber(v.g) and isnumber(v.b) and isnumber(v.a)
    end

    --[[
    Purpose:
        Calculates a contrasting negative accent color from the provided main color.

    Parameters:
        mainColor (Color|nil)
            Optional base color. Uses the current theme main color when omitted.

    Returns:
        Color
            The calculated negative accent color.

    Example Usage:
        ```lua
        local negative = lia.color.calculateNegativeColor(lia.color.getMainColor())
        ```

    Realm:
        Client
]]
    function lia.color.calculateNegativeColor(mainColor)
        if not mainColor then mainColor = lia.color.getMainColor() end
        local r, g, b = mainColor.r, mainColor.g, mainColor.b
        local brightness = r * 0.299 + g * 0.587 + b * 0.114
        local negativeR, negativeG, negativeB
        if brightness < 128 then
            negativeR = math.Clamp(r * 0.4 + 180, 140, 200)
            negativeG = math.Clamp(g * 0.3 + 80, 60, 120)
            negativeB = math.Clamp(b * 0.2 + 60, 40, 100)
        else
            negativeR = math.Clamp(r * 0.3 + 150, 120, 180)
            negativeG = math.Clamp(g * 0.2 + 60, 40, 100)
            negativeB = math.Clamp(b * 0.15 + 50, 30, 80)
        end

        negativeR = math.Clamp(negativeR * 0.7 + r * 0.3, 0, 255)
        negativeG = math.Clamp(negativeG * 0.7 + g * 0.3, 0, 255)
        negativeB = math.Clamp(negativeB * 0.7 + b * 0.3, 0, 255)
        return Color(negativeR, negativeG, negativeB, 255)
    end

    --[[
    Purpose:
        Builds a derived color palette from the current theme main color.

    Returns:
        table
            A table containing background, sidebar, accent, text, hover, border, highlight, and negative colors.

    Example Usage:
        ```lua
        local colors = lia.color.returnMainAdjustedColors()
        surface.SetDrawColor(colors.background)
        ```

    Realm:
        Client
]]
    function lia.color.returnMainAdjustedColors()
        local base = lia.color.getMainColor()
        local background = lia.color.adjust(base, -20, -10, -50, 0)
        local brightness = background.r * 0.299 + background.g * 0.587 + background.b * 0.114
        local textColor = brightness > 128 and Color(30, 30, 30, 255) or Color(245, 245, 220, 255)
        local negativeColor = lia.color.calculateNegativeColor(base)
        return {
            background = background,
            sidebar = lia.color.adjust(base, -30, -15, -60, -55),
            accent = base,
            text = textColor,
            hover = lia.color.adjust(base, -40, -25, -70, -35),
            border = Color(255, 255, 255, 255),
            highlight = Color(255, 255, 255, 30),
            negative = negativeColor
        }
    end

    --[[
    Purpose:
        Interpolates from one color toward another using `FrameTime()` multiplied by the provided fraction.

    Parameters:
        frac (number)
            The interpolation multiplier applied to `FrameTime()`.

        col1 (Color|nil)
            The starting color. Missing channels default to 255.

        col2 (Color|nil)
            The target color. Missing channels default to 255.

    Returns:
        Color
            The interpolated color.

    Example Usage:
        ```lua
        local blended = lia.color.lerp(8, Color(0, 0, 0), lia.color.getMainColor())
        ```

    Realm:
        Client
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
    Purpose:
        Registers a theme table by lowercase theme identifier.

    Parameters:
        name (string)
            The display name or identifier for the theme.

        themeData (table)
            The theme color data to store.

    Example Usage:
        ```lua
        lia.color.registerTheme("Amber", {
            maincolor = Color(220, 150, 60),
            background = Color(30, 24, 18),
            text = Color(255, 238, 210)
        })
        ```

    Realm:
        Shared
]]
function lia.color.registerTheme(name, themeData)
    local id = name:lower()
    lia.color.themes[id] = themeData
end

--[[
    Purpose:
        Returns every registered theme identifier sorted alphabetically.

    Returns:
        table
            A sorted array of registered lowercase theme identifiers.

    Example Usage:
        ```lua
        for _, themeID in ipairs(lia.color.getAllThemes()) do
            print(themeID)
        end
        ```

    Realm:
        Shared
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

if CLIENT and not lia.color.theme then lia.color.applyTheme(lia.color.getCurrentThemeName(), false) end
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
    header_text = Color(255, 255, 255),
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
    text = Color(180, 180, 180),
    text_entry = Color(180, 180, 180),
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

lia.config.add("Theme", "@theme", "Teal", function(_, newValue)
    if CLIENT then
        if not lia.color.themes[newValue] then
            newValue = "Teal"
            if not lia.color.themes[newValue] then return end
        end

        lia.color.applyTheme(newValue, true)
    end
end, {
    desc = "@themeDesc",
    category = "@core",
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
