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

function lia.font.register(fontName, fontData)
    if not (isstring(fontName) and istable(fontData)) then return lia.error(L("invalidFont")) end
    lia.font.stored[fontName] = SERVER and {
        font = true
    } or fontData

    if CLIENT then surface.CreateFont(fontName, fontData) end
end

function lia.font.getAvailableFonts()
    local list = {}
    for name in pairs(lia.font.stored) do
        list[#list + 1] = name
    end

    table.sort(list)
    return list
end

function lia.font.getBoldFontName(fontName)
    if string.find(fontName, "Montserrat") then
        return fontName:gsub(" Medium", " Bold"):gsub("Montserrat$", "Montserrat Bold")
    else
        return fontName:gsub(" Medium", " Bold")
    end
end

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

    local fontSizes = {12, 14, 15, 16, 17, 18, 20, 22, 23, 24, 25, 26, 28, 30, 32, 34, 36, 40, 48, 72}
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
    category = "categoryInterface",
    type = "Table",
    options = lia.font.getAvailableFonts()
})
