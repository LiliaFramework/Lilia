lia.font = lia.font or {}
lia.font.stored = lia.font.stored or {}
function lia.font.register(fontName, fontData)
    if not (isstring(fontName) and istable(fontData)) then return lia.error(L("invalidFont")) end
    lia.font.stored[fontName] = fontData
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

lia.font.register("ConfigFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 26,
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("ConfigFontLarge", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 36,
    weight = 700,
    extended = true,
    antialias = true
})

lia.font.register("DescriptionFontLarge", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 24,
    weight = 500,
    extended = true,
    antialias = true
})

lia.font.register("ticketsystem", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 15,
    weight = 400
})

lia.font.register("VendorItemNameFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 24,
    weight = 700
})

lia.font.register("VendorItemDescFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 18,
    weight = 500
})

lia.font.register("liaCharSubTitleFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 16 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 500,
    antialias = true
})

lia.font.register("liaBigTitle", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 30,
    weight = 800
})

lia.font.register("liaHugeText", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 48,
    weight = 600
})

lia.font.register("liaBigBtn", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 28,
    weight = 900
})

lia.font.register("liaToolTipText", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 20,
    extended = true,
    weight = 500
})

lia.font.register("liaHugeFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 72 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 1000
})

lia.font.register("liaBigFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 36 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 1000
})

lia.font.register("liaMediumFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 25 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 1000
})

lia.font.register("liaSmallFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or math.max(ScreenScaleH(6), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 500
})

lia.font.register("liaMiniFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or math.max(ScreenScaleH(5), 14) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 400
})

lia.font.register("liaMediumLightFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 25 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 200
})

lia.font.register("liaGenericFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or 20 * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 1000
})

lia.font.register("liaChatFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or math.max(ScreenScaleH(7), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 200
})

lia.font.register("liaChatFontItalics", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or math.max(ScreenScaleH(7), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 200,
    italic = true
})

lia.font.register("Montserrat Regular", {
    font = "Montserrat",
    size = SERVER and 0 or 16,
    extended = true,
    antialias = true
})

lia.font.register("Montserrat Medium", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 16,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Montserrat Bold", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 16,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.12", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 12,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.12b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 12,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.14", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 14,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.14b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 14,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.16", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 16,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.16b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 16,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.18", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 18,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.18b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 18,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.20", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 20,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.20b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 20,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.24", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 24,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.24b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 24,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.28", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 28,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.28b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 28,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.36", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 36,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.36b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 36,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("Fated.40", {
    font = "Montserrat Medium",
    size = SERVER and 0 or 40,
    extended = true,
    antialias = true,
    weight = 500
})

lia.font.register("Fated.40b", {
    font = "Montserrat Bold",
    size = SERVER and 0 or 40,
    extended = true,
    antialias = true,
    weight = 700
})

lia.font.register("liaItemDescFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    size = SERVER and 0 or math.max(ScreenScaleH(6), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    shadow = true,
    weight = 500
})

lia.font.register("liaItemBoldFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    shadow = true,
    size = SERVER and 0 or math.max(ScreenScaleH(8), 20) * math.min(ScrW() / 1920, ScrH() / 1080),
    extended = true,
    weight = 800
})

lia.font.register("liaCharSubTitleFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    weight = 200,
    size = SERVER and 0 or math.floor(12 * ScrH() / 1080 + 10),
    additive = true
})

lia.font.register("liaCharButtonFont", {
    font = lia.config.get("Font", "Montserrat Medium"),
    weight = 200,
    size = SERVER and 0 or math.floor(24 * ScrH() / 1080 + 10),
    additive = true
})

if CLIENT then
    function lia.font.refresh()
        -- Clear stored fonts and re-register with current configuration
        lia.font.stored = {}
        -- Get the current font configuration
        local currentFont = lia.config.get("Font", "Montserrat Medium")
        -- Force VGUI to refresh font cache
        if vgui and vgui.RefreshFonts then vgui.RefreshFonts() end
        -- Clear surface font cache to force re-creation
        if surface and surface.ClearFontCache then surface.ClearFontCache() end
        lia.font.register("ConfigFont", {
            font = currentFont,
            size = SERVER and 0 or 26,
            weight = 500,
            extended = true,
            antialias = true
        })

        lia.font.register("ConfigFontLarge", {
            font = currentFont,
            size = SERVER and 0 or 36,
            weight = 700,
            extended = true,
            antialias = true
        })

        lia.font.register("DescriptionFontLarge", {
            font = currentFont,
            size = SERVER and 0 or 24,
            weight = 500,
            extended = true,
            antialias = true
        })

        lia.font.register("ticketsystem", {
            font = currentFont,
            size = SERVER and 0 or 15,
            weight = 400
        })

        lia.font.register("VendorItemNameFont", {
            font = currentFont,
            size = SERVER and 0 or 24,
            weight = 700
        })

        lia.font.register("VendorItemDescFont", {
            font = currentFont,
            size = SERVER and 0 or 18,
            weight = 500
        })

        lia.font.register("liaCharSubTitleFont", {
            font = currentFont,
            size = SERVER and 0 or 16 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 500,
            antialias = true
        })

        lia.font.register("liaBigTitle", {
            font = currentFont,
            size = SERVER and 0 or 30,
            weight = 800
        })

        lia.font.register("liaHugeText", {
            font = currentFont,
            size = SERVER and 0 or 48,
            weight = 600
        })

        lia.font.register("liaBigBtn", {
            font = currentFont,
            size = SERVER and 0 or 28,
            weight = 900
        })

        lia.font.register("liaToolTipText", {
            font = currentFont,
            size = SERVER and 0 or 20,
            extended = true,
            weight = 500
        })

        lia.font.register("liaHugeFont", {
            font = currentFont,
            size = SERVER and 0 or 72 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 1000
        })

        lia.font.register("liaBigFont", {
            font = currentFont,
            size = SERVER and 0 or 36 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 1000
        })

        lia.font.register("liaMediumFont", {
            font = currentFont,
            size = SERVER and 0 or 25 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 1000
        })

        lia.font.register("liaSmallFont", {
            font = currentFont,
            size = SERVER and 0 or math.max(ScreenScaleH(6), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 500
        })

        lia.font.register("liaMiniFont", {
            font = currentFont,
            size = SERVER and 0 or math.max(ScreenScaleH(5), 14) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 400
        })

        lia.font.register("liaMediumLightFont", {
            font = currentFont,
            size = SERVER and 0 or 25 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 200
        })

        lia.font.register("liaGenericFont", {
            font = currentFont,
            size = SERVER and 0 or 20 * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 1000
        })

        lia.font.register("liaChatFont", {
            font = currentFont,
            size = SERVER and 0 or math.max(ScreenScaleH(7), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 200
        })

        lia.font.register("liaChatFontItalics", {
            font = currentFont,
            size = SERVER and 0 or math.max(ScreenScaleH(7), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 200,
            italic = true
        })

        lia.font.register("Montserrat Regular", {
            font = "Montserrat",
            size = SERVER and 0 or 16,
            extended = true,
            antialias = true
        })

        lia.font.register("Montserrat Medium", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 16,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Montserrat Bold", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 16,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.12", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 12,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.12b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 12,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.14", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 14,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.14b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 14,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.16", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 16,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.16b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 16,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.18", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 18,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.18b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 18,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.20", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 20,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.20b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 20,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.24", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 24,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.24b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 24,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.28", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 28,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.28b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 28,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.36", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 36,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.36b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 36,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("Fated.40", {
            font = "Montserrat Medium",
            size = SERVER and 0 or 40,
            extended = true,
            antialias = true,
            weight = 500
        })

        lia.font.register("Fated.40b", {
            font = "Montserrat Bold",
            size = SERVER and 0 or 40,
            extended = true,
            antialias = true,
            weight = 700
        })

        lia.font.register("liaItemDescFont", {
            font = currentFont,
            size = SERVER and 0 or math.max(ScreenScaleH(6), 17) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            shadow = true,
            weight = 500
        })

        lia.font.register("liaItemBoldFont", {
            font = currentFont,
            shadow = true,
            size = SERVER and 0 or math.max(ScreenScaleH(8), 20) * math.min(ScrW() / 1920, ScrH() / 1080),
            extended = true,
            weight = 800
        })

        lia.font.register("liaCharSubTitleFont", {
            font = currentFont,
            weight = 200,
            size = SERVER and 0 or math.floor(12 * ScrH() / 1080 + 10),
            additive = true
        })

        lia.font.register("liaCharButtonFont", {
            font = currentFont,
            weight = 200,
            size = SERVER and 0 or math.floor(24 * ScrH() / 1080 + 10),
            additive = true
        })

        hook.Run("PostLoadFonts", currentFont, currentFont)
        -- Force all VGUI elements to refresh their font references
        local function refreshVGUIElement(element)
            if not IsValid(element) then return end
            -- Force element to re-render with new fonts
            if element.SetFont and element.GetFont then
                local elementFont = element:GetFont()
                if elementFont and elementFont ~= "" then element:SetFont(elementFont) end
            end

            -- Recursively refresh child elements
            for _, child in pairs(element:GetChildren()) do
                refreshVGUIElement(child)
            end
        end

        -- Refresh all root VGUI elements
        for _, element in pairs(vgui.GetWorldPanel():GetChildren()) do
            refreshVGUIElement(element)
        end
    end

    local oldSurfaceSetFont = surface.SetFont
    function surface.SetFont(font)
        if isstring(font) and not lia.font.stored[font] then
            local fontData = {
                font = font,
                size = SERVER and 0 or 16,
                extended = true,
                antialias = true,
                weight = 500
            }

            local baseFont, sizeStr = font:match("^([^%.]+)%.(%d+)$")
            if baseFont and sizeStr then
                fontData.font = baseFont
                fontData.size = SERVER and 0 or tonumber(sizeStr) or 16
            end

            local boldMatch = font:match("^(.-)(%d+)b$")
            if boldMatch then
                fontData.font = boldMatch
                fontData.weight = 700
            end

            lia.font.register(font, fontData)
        end
        return oldSurfaceSetFont(font)
    end

    hook.Add("OnScreenSizeChanged", "liaFontsRefreshFonts", lia.font.refresh)
    hook.Add("RefreshFonts", "liaFontsRefresh", lia.font.refresh)
    hook.Add("OnReloaded", "liaFontsRefreshOnReload", lia.font.refresh)
    hook.Add("InitializedConfig", "liaFontsRefreshOnConfigLoad", lia.font.refresh)
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

hook.Run("PostLoadFonts", lia.config.get("Font", "Montserrat Medium"), lia.config.get("Font", "Montserrat Medium"))
-- Console command to manually refresh fonts for testing
if CLIENT then
    concommand.Add("lia_refresh_fonts", function()
        lia.information("Refreshing fonts...")
        local currentFont = lia.config.get("Font", "Montserrat Medium")
        lia.information("Current font setting: " .. currentFont)
        lia.font.refresh()
        lia.information("Fonts refreshed!")
        lia.information("Available fonts: " .. table.concat(lia.font.getAvailableFonts(), ", "))
    end)

    -- Debug command to check font status
    concommand.Add("lia_debug_fonts", function()
        local currentFont = lia.config.get("Font", "Montserrat Medium")
        lia.information("=== Font Debug Info ===")
        lia.information("Current font setting: " .. currentFont)
        lia.information("Stored fonts count: " .. table.Count(lia.font.stored))
        lia.information("Available fonts: " .. table.concat(lia.font.getAvailableFonts(), ", "))
        -- Test a specific font
        surface.SetFont("ConfigFontLarge")
        local w, h = surface.GetTextSize("Test Text")
        lia.information("ConfigFontLarge test - Width: " .. w .. " Height: " .. h)
    end)
end
