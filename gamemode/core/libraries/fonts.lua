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
    if #fontName > 63 then return end
    if fontData.font and #fontData.font > 63 then return end
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
    local hudFont = lia.config.get("HUDFont", "Montserrat Medium")
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

    lia.font.register("LiliaHUDFont", {
        font = hudFont,
        size = 16,
        extended = true,
        antialias = true,
        weight = 500
    })

    lia.font.register("HUDFont", {
        font = hudFont,
        size = 16,
        extended = true,
        antialias = true,
        weight = 500
    })

    for size = 1, 100 do
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

        lia.font.register("LiliaHUDFont." .. size, {
            font = hudFont,
            size = size,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("HUDFont." .. size, {
            font = hudFont,
            size = size,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("LiliaHUDFont." .. size .. "b", {
            font = lia.font.getBoldFontName(hudFont),
            size = size,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("HUDFont." .. size .. "b", {
            font = lia.font.getBoldFontName(hudFont),
            size = size,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("LiliaHUDFont." .. size .. "i", {
            font = hudFont,
            size = size,
            extended = true,
            antialias = true,
            weight = 500,
            italic = true
        })

        lia.font.register("HUDFont." .. size .. "i", {
            font = hudFont,
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
        if isstring(font) and not lia.font.stored[font] and #font <= 63 then
            local mainFont = lia.config and lia.config.get("Font", "Montserrat Medium") or "Montserrat Medium"
            local hudFont = lia.config and lia.config.get("HUDFont", "Montserrat Medium") or "Montserrat Medium"
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
            elseif font == "HUDFont" or font == "LiliaHUDFont" then
                fontData.font = hudFont
                fontData.size = 16
            else
                local baseFont, sizeStr = font:match("^([^%.]+)%.(%d+)$")
                if baseFont and sizeStr then
                    if baseFont == "LiliaFont" then
                        fontData.font = mainFont
                    elseif baseFont == "HUDFont" or baseFont == "LiliaHUDFont" then
                        fontData.font = hudFont
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
                elseif string.match(boldMatch, "^HUDFont") or string.match(boldMatch, "^LiliaHUDFont") then
                    fontData.font = lia.font.getBoldFontName(hudFont)
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
                elseif string.match(boldItalicMatch, "^HUDFont") or string.match(boldItalicMatch, "^LiliaHUDFont") then
                    fontData.font = lia.font.getBoldFontName(hudFont)
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
                elseif string.match(boldShadowMatch, "^HUDFont") or string.match(boldShadowMatch, "^LiliaHUDFont") then
                    fontData.font = lia.font.getBoldFontName(hudFont)
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

lia.config.add("Font", "@font", "Montserrat Medium", function()
    if not CLIENT then return end
    hook.Run("RefreshFonts")
end, {
    desc = "@fontDesc",
    category = "@core",
    type = "Table",
    options = function()
        if lia.font and isfunction(lia.font.getAvailableFonts) then return lia.font.getAvailableFonts() end
        return {"Montserrat Medium"}
    end
})

hook.Add("OnConfigUpdated", "liaHUDFontsOnConfigUpdate", function(key, oldValue, newValue)
    if not CLIENT or oldValue == newValue or key ~= "HUDFont" then return end
    lia.font.registerFonts(lia.config.get("Font", "Montserrat Medium"))
    timer.Simple(0.1, function()
        lia.font.loadFonts()
        hook.Run("RefreshFonts")
    end)
end)
