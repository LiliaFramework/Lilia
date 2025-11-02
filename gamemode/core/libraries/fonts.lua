--[[
    Font Library

    Comprehensive font management system for the Lilia framework.
]]
--[[
    Overview:
        The font library provides comprehensive functionality for managing custom fonts in the Lilia framework. It handles font registration, loading, and automatic font creation for UI elements throughout the gamemode. The library operates on both server and client sides, with the server storing font metadata and the client handling actual font creation and rendering. It includes automatic font generation for various sizes and styles, dynamic font loading based on configuration, and intelligent font name parsing for automatic font creation. The library ensures consistent typography across all UI elements and provides easy access to predefined font variants for different use cases.
]]
lia.font = lia.font or {}
lia.font.stored = lia.font.stored or {}
--[[
    Purpose:
        Loads all registered fonts into the game's font system by iterating through stored fonts and creating them

    When Called:
        Called during initialization after font registration and during font refresh operations

    Parameters:
        None

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load all fonts after registration
        lia.font.loadFonts()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load fonts after a delay to ensure config is ready
        timer.Simple(0.2, function()
            lia.font.loadFonts()
        end)
        ```

    High Complexity:
        ```lua
        -- High: Refresh fonts when configuration changes
        hook.Add("ConfigUpdated", "ReloadFonts", function(key)
            if key == "Font" then
                lia.font.registerFonts()
                timer.Simple(0.1, function()
                    lia.font.loadFonts()
                    hook.Run("RefreshFonts")
                end)
            end
        end)
        ```
]]
function lia.font.loadFonts()
    if not CLIENT then return end
    local loadedCount = 0
    local failedCount = 0
    for fontName, fontData in pairs(lia.font.stored) do
        if istable(fontData) then
            local success = pcall(function()
                surface.CreateFont(fontName, fontData)
                loadedCount = loadedCount + 1
            end)

            if not success then failedCount = failedCount + 1 end
        end
    end
end

--[[
    Purpose:
        Registers a custom font with the framework's font system

    When Called:
        Called when defining new fonts for UI elements or during font initialization

    Parameters:
        - fontName (string): The unique identifier for the font
        - fontData (table): Font configuration table containing font properties (font, size, weight, etc.)

    Returns:
        None (calls lia.error if parameters are invalid)

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register a basic font
        lia.font.register("MyFont", {
            font = "Roboto",
            size = 16
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register a font with multiple properties
        lia.font.register("MyCustomFont", {
            font     = "Arial",
            size     = 20,
            weight   = 600,
            antialias = true,
            extended = true
        })
        ```

    High Complexity:
        ```lua
        -- High: Register multiple fonts with different styles
        local fontConfig = {
            {name = "MenuTitle", size = 32, weight = 700},
            {name = "MenuText", size = 18, weight = 400},
            {name = "MenuSmall", size = 14, weight = 300}
        }

        for _, config in ipairs(fontConfig) do
            lia.font.register(config.name, {
                font      = "Montserrat",
                size      = config.size,
                weight    = config.weight,
                extended  = true,
                antialias = true
            })
        end
        ```
]]
function lia.font.register(fontName, fontData)
    if not (isstring(fontName) and istable(fontData)) then return lia.error(L("invalidFont")) end
    lia.font.stored[fontName] = SERVER and {
        font = true
    } or fontData

    if CLIENT then surface.CreateFont(fontName, fontData) end
end

--[[
    Purpose:
        Retrieves a sorted list of all registered font names in the framework

    When Called:
        Used for populating font selection menus or displaying available fonts to users

    Parameters:
        None

    Returns:
        - list (table): An alphabetically sorted table of font name strings

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get all available fonts
        local fonts = lia.font.getAvailableFonts()
        print(table.concat(fonts, ", "))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Populate a dropdown menu with available fonts
        local fontList = lia.font.getAvailableFonts()
        local dropdown = vgui.Create("DComboBox")
        for _, fontName in ipairs(fontList) do
            dropdown:AddChoice(fontName)
        end
        ```

    High Complexity:
        ```lua
        -- High: Create a font preview panel with all available fonts
        local fonts = lia.font.getAvailableFonts()
        local panel = vgui.Create("DScrollPanel")

        for i, fontName in ipairs(fonts) do
            local label = panel:Add("DLabel")
            label:SetText(fontName .. " - Preview Text")
            label:SetFont(fontName)
            label:Dock(TOP)
            label:DockMargin(5, 5, 5, 0)
        end
        ```
]]
function lia.font.getAvailableFonts()
    local list = {}
    for name in pairs(lia.font.stored) do
        list[#list + 1] = name
    end

    table.sort(list)
    return list
end

--[[
    Purpose:
        Converts a font name to its bold variant by replacing Medium with Bold in the name

    When Called:
        Used when registering bold font variants or dynamically generating bold fonts

    Parameters:
        - fontName (string): The base font name to convert to bold

    Returns:
        - (string): The bold variant of the font name

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get bold version of a font
        local boldFont = lia.font.getBoldFontName("Montserrat Medium")

        -- Returns: "Montserrat Bold"
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register both normal and bold variants
        local baseFontName = "Montserrat Medium"
        lia.font.register("NormalText", {font = baseFontName, size = 16})
        lia.font.register("BoldText", {font = lia.font.getBoldFontName(baseFontName), size = 16, weight = 700})
        ```

    High Complexity:
        ```lua
        -- High: Create matching pairs of normal and bold fonts for multiple sizes
        local baseFontName = "Montserrat Medium"
        local sizes = {14, 18, 24, 32}

        for _, size in ipairs(sizes) do
            -- Normal variant
            lia.font.register("CustomFont" .. size, {
                font   = baseFontName,
                size   = size,
                weight = 500
            })

            -- Bold variant
            lia.font.register("CustomFont" .. size .. "Bold", {
                font   = lia.font.getBoldFontName(baseFontName),
                size   = size,
                weight = 700
            })
        end
        ```
]]
function lia.font.getBoldFontName(fontName)
    if string.find(fontName, "Montserrat") then
        return fontName:gsub(" Medium", " Bold"):gsub("Montserrat$", "Montserrat Bold")
    else
        return fontName:gsub(" Medium", " Bold")
    end
end

--[[
    Purpose:
        Registers all default fonts used by the Lilia framework including size variants, bold, and italic styles

    When Called:
        Called during initialization and when the font configuration changes

    Parameters:
        - fontName (string, optional): The base font name to use. If not provided, uses the configured font setting

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register default fonts
        lia.font.registerFonts()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register fonts with a custom base font
        lia.font.registerFonts("Roboto")
        ```

    High Complexity:
        ```lua
        -- High: Register fonts and hook into completion
        lia.font.registerFonts("Montserrat Medium")

        hook.Add("PostLoadFonts", "MyFontHook", function(mainFont, configuredFont)
            print("Fonts loaded with: " .. mainFont)
            -- Perform additional font-related setup
            for i = 10, 50, 2 do
                lia.font.register("MyCustomFont" .. i, {
                    font      = mainFont,
                    size      = i,
                    extended  = true,
                    antialias = true
                })
            end
        end)
        ```
]]
function lia.font.registerFonts(fontName)
    local mainFont = fontName or lia.config.get("Font", "Montserrat Medium")
    local fontsToRegister = {
        {
            "Montserrat Regular",
            {
                font = "Montserrat",
                size = 16,
                extended = true,
                antialias = true
            }
        },
        {
            "Montserrat Medium",
            {
                font = "Montserrat Medium",
                size = 16,
                extended = true,
                antialias = true,
                weight = 500
            }
        },
        {
            "Montserrat Bold",
            {
                font = "Montserrat Bold",
                size = 16,
                extended = true,
                antialias = true,
                weight = 700
            }
        }
    }

    for _, fontInfo in ipairs(fontsToRegister) do
        local registerFontName, fontData = fontInfo[1], fontInfo[2]
        lia.font.register(registerFontName, fontData)
    end

    lia.font.register("liaHugeFont", {
        font = mainFont,
        size = 72,
        extended = true,
        weight = 1000
    })

    lia.font.register("liaBigFont", {
        font = mainFont,
        size = 36,
        extended = true,
        weight = 1000
    })

    lia.font.register("liaMediumFont", {
        font = mainFont,
        size = 25,
        extended = true,
        weight = 1000
    })

    lia.font.register("liaSmallFont", {
        font = mainFont,
        size = 17,
        extended = true,
        weight = 500
    })

    lia.font.register("liaMiniFont", {
        font = mainFont,
        size = 14,
        extended = true,
        weight = 400
    })

    lia.font.register("liaTinyFont", {
        font = mainFont,
        size = 12,
        extended = true,
        weight = 400
    })

    local fontSizes = {12, 14, 15, 16, 17, 18, 20, 22, 23, 24, 25, 26, 28, 30, 34, 36, 40, 48}
    for _, size in ipairs(fontSizes) do
        lia.font.register("LiliaFont." .. size, {
            font = mainFont,
            size = size,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("LiliaFont." .. size .. "b", {
            font = lia.font.getBoldFontName(mainFont),
            size = size,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("LiliaFont." .. size .. "i", {
            font = mainFont,
            size = size,
            extended = true,
            antialias = true,
            weight = 500,
            italic = true
        })
    end

    hook.Run("PostLoadFonts", mainFont, mainFont)
end

if CLIENT then
    local oldSurfaceSetFont = surface.SetFont
    function surface.SetFont(font)
        if isstring(font) and not lia.font.stored[font] then
            local fontData = {
                font = font,
                size = 16,
                extended = true,
                antialias = true,
                weight = 500
            }

            local baseFont, sizeStr = font:match("^([^%.]+)%.(%d+)$")
            if baseFont and sizeStr then
                fontData.font = baseFont
                fontData.size = tonumber(sizeStr) or 16
            end

            local boldMatch = font:match("^(.-)(%d+)b$")
            if boldMatch then
                fontData.font = boldMatch
                fontData.weight = 700
            end

            local italicMatch = font:match("^(.-)(%d+)i$")
            if italicMatch then fontData.italic = true end
            local shadowMatch = font:match("^(.-)(%d+)s$")
            if shadowMatch then fontData.shadow = true end
            local boldItalicMatch = font:match("^(.-)(%d+)bi$")
            if boldItalicMatch then
                fontData.font = boldItalicMatch
                fontData.weight = 700
                fontData.italic = true
            end

            local boldShadowMatch = font:match("^(.-)(%d+)bs$")
            if boldShadowMatch then
                fontData.font = boldShadowMatch
                fontData.weight = 700
                fontData.shadow = true
            end

            lia.font.register(font, fontData)
        end
        return oldSurfaceSetFont(font)
    end

    hook.Add("InitializedConfig", "liaFontsOnConfigLoad", function()
        if not lia.config.stored or not lia.config.stored.Font then
            timer.Simple(0.1, function()
                local fontName = lia.config.get("Font", "Montserrat Medium")
                lia.font.registerFonts(fontName)
                timer.Simple(0.2, function()
                    lia.font.loadFonts()
                    hook.Run("RefreshFonts")
                end)
            end)
        else
            local fontName = lia.config.get("Font", "Montserrat Medium")
            lia.font.registerFonts(fontName)
            timer.Simple(0.2, function()
                lia.font.loadFonts()
                hook.Run("RefreshFonts")
            end)
        end
    end)
end

lia.config.add("Font", "font", "Montserrat Medium", function()
    if not CLIENT then return end
    hook.Run("RefreshFonts")
end, {
    desc = "fontDesc",
    category = "categoryFonts",
    type = "Table",
    options = lia.font.getAvailableFonts()
})
