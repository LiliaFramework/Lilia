--[[
    Folder: Libraries
    File: font.md
]]
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
        Create all registered fonts on the client and count successes/failures.

    When Called:
        After registration or config load to ensure fonts exist before drawing.

    Parameters:
        None

    Returns:
        nil

    Realm:
        Client

    Example Usage:
        ```lua
            hook.Add("RefreshFonts", "ReloadAllFonts", function()
                lia.font.loadFonts()
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
        Register a single font definition and create it clientside if possible.

    When Called:
        During font setup or dynamically when encountering unknown font names.

    Parameters:
        fontName (string)
            Unique font identifier.
        fontData (table)
            surface.CreateFont data table.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            lia.font.register("liaDialogHeader", {
                font = "Montserrat Bold",
                size = 28,
                weight = 800,
                antialias = true
            })
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
        List all registered font identifiers.

    When Called:
        Populate dropdowns or config options for font selection.

    Parameters:
        None

    Returns:
        table
            Sorted array of font names.

    Realm:
        Shared

    Example Usage:
        ```lua
            for _, name in ipairs(lia.font.getAvailableFonts()) do
                print("Font:", name)
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
        Convert a base font name to its bold variant.

    When Called:
        When auto-registering bold/shadow variants of LiliaFont entries.

    Parameters:
        fontName (string)
            Base font name.

    Returns:
        string
            Best-effort bold font name.

    Realm:
        Shared

    Example Usage:
        ```lua
            local boldName = lia.font.getBoldFontName("Montserrat Medium")
            lia.font.register("DialogTitle", {font = boldName, size = 26, weight = 800})
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
        Register the full suite of Lilia fonts (regular, bold, italic, sizes).

    When Called:
        On config load or when switching the base font setting.

    Parameters:
        fontName (string|nil)
            Base font name; defaults to config Font.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
            concommand.Add("lia_reload_fonts", function()
                local base = lia.config.get("Font", "Montserrat Medium")
                lia.font.registerFonts(base)
                timer.Simple(0.1, lia.font.loadFonts)
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

    lia.font.register("LiliaFont", {
        font = mainFont,
        size = 16,
        extended = true,
        antialias = true,
        weight = 500
    })

    for size = 10, 100 do
        print("LiliaFont." .. size)
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
            local mainFont = lia.config and lia.config.get("Font", "Montserrat Medium") or "Montserrat Medium"
            local fontData = {
                font = font,
                size = 16,
                extended = true,
                antialias = true,
                weight = 500
            }

            if font == "LiliaFont" then
                fontData.font = mainFont
                fontData.size = 16
            else
                local baseFont, sizeStr = font:match("^([^%.]+)%.(%d+)$")
                if baseFont and sizeStr then
                    if baseFont == "LiliaFont" then
                        fontData.font = mainFont
                    else
                        fontData.font = baseFont
                    end

                    fontData.size = tonumber(sizeStr) or 16
                end
            end

            local boldMatch = font:match("^(.-)(%d+)b$")
            if boldMatch then
                if string.match(boldMatch, "^LiliaFont") then
                    fontData.font = lia.font.getBoldFontName(mainFont)
                else
                    fontData.font = boldMatch
                end

                fontData.weight = 700
            end

            local italicMatch = font:match("^(.-)(%d+)i$")
            if italicMatch then fontData.italic = true end
            local shadowMatch = font:match("^(.-)(%d+)s$")
            if shadowMatch then fontData.shadow = true end
            local boldItalicMatch = font:match("^(.-)(%d+)bi$")
            if boldItalicMatch then
                if string.match(boldItalicMatch, "^LiliaFont") then
                    fontData.font = lia.font.getBoldFontName(mainFont)
                else
                    fontData.font = boldItalicMatch
                end

                fontData.weight = 700
                fontData.italic = true
            end

            local boldShadowMatch = font:match("^(.-)(%d+)bs$")
            if boldShadowMatch then
                if string.match(boldShadowMatch, "^LiliaFont") then
                    fontData.font = lia.font.getBoldFontName(mainFont)
                else
                    fontData.font = boldShadowMatch
                end

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
    category = "categoryInterface",
    type = "Table",
    options = lia.font.getAvailableFonts()
})
