--[[
    Folder: Developer - Libraries
    File: lia.font.md
]]
--[[
    Font

    Font registration and loading helpers for Lilia UI and HUD text.
]]
--[[
    Overview:
        The font library centralizes registered font definitions under `lia.font`. It registers default Montserrat faces, creates configurable Lilia UI and HUD font aliases, exposes available font faces for configuration, reloads stored fonts on the client, and lazily creates missing `surface.SetFont` font variants when they are first requested.
]]
--[[
    Hooks:
        PostLoadFonts(string mainFont, string fontName)

    Purpose:
        Runs after `lia.font.registerFonts` finishes registering the standard font aliases and generated size variants.

    Category:
        Fonts

    Parameters:
        mainFont (string)
            The configured main interface font used for Lilia font aliases.

        fontName (string)
            The second font argument passed by this library. It currently receives the same value as `mainFont`.

    Example Usage:
        ```lua
        hook.Add("PostLoadFonts", "liaExamplePostLoadFonts", function(mainFont, fontName)
            print("[MyModule] handled PostLoadFonts")
        end)
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        RefreshFonts()

    Purpose:
        Runs when font-dependent UI should reload or repaint after font configuration is initialized or changed.

    Category:
        Fonts

    Example Usage:
        ```lua
        hook.Add("RefreshFonts", "liaExampleRefreshFonts", function()
            print("[MyModule] handled RefreshFonts")
        end)
        ```

    Realm:
        Client
]]
lia.font = lia.font or {}
lia.font.stored = lia.font.stored or {}
--[[
    Purpose:
        Recreates every stored font definition on the client using `surface.CreateFont`.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.font.loadFonts()
        ```

    Realm:
        Client
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
        Registers a font definition under `lia.font.stored` and creates it immediately on the client.

    Parameters:
        fontName (string)
            The name used to reference the font through Garry's Mod font APIs.

        fontData (table)
            The font definition table passed to `surface.CreateFont` on the client.

    Returns:
        nil|any
            Returns the result of `lia.error(L("invalidFont"))` when the font name or data is invalid. Otherwise, this function has no explicit return value.

    Example Usage:
        ```lua
        lia.font.register("LiliaCustomFont", {
            font = "Montserrat Medium",
            size = 20,
            extended = true,
            antialias = true,
            weight = 500
        })
        ```

    Realm:
        Shared
]]
function lia.font.register(fontName, fontData)
    if not (isstring(fontName) and istable(fontData)) then return lia.error(L("invalidFont")) end
    if #fontName > 63 then return end
    if fontData.font and #fontData.font > 63 then return end
    lia.font.stored[fontName] = SERVER and {
        font = true
    } or fontData

    if CLIENT then surface.CreateFont(fontName, fontData) end
end

local function isConfigDerivedFontName(fontName)
    return isstring(fontName) and (fontName:StartWith("lia") or fontName:StartWith("LiliaFont") or fontName:StartWith("LiliaHUDFont") or fontName:StartWith("HUDFont"))
end

--[[
    Purpose:
        Returns unique registered font face names that can be shown as selectable font configuration options.

    Parameters:
        None.

    Returns:
        table
            A sorted list of unique font face names, excluding Lilia-generated configuration aliases.

    Example Usage:
        ```lua
        local fonts = lia.font.getAvailableFonts()
        ```

    Realm:
        Shared
]]
function lia.font.getAvailableFonts()
    local list = {}
    local seen = {}
    for name, fontData in pairs(lia.font.stored) do
        if istable(fontData) and not isConfigDerivedFontName(name) then
            local fontFace = fontData.font
            if isstring(fontFace) and fontFace ~= "" and not seen[fontFace] then
                seen[fontFace] = true
                list[#list + 1] = fontFace
            end
        end
    end

    table.sort(list)
    return list
end

--[[
    Purpose:
        Derives the bold font face name for a given font name.

    Parameters:
        fontName (string)
            The base font face name to convert to its bold variant.

    Returns:
        string
            The derived bold font face name.

    Example Usage:
        ```lua
        local boldFont = lia.font.getBoldFontName("Montserrat Medium")
        ```

    Realm:
        Shared
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
        Registers the default Montserrat faces, core Lilia font aliases, HUD font aliases, and generated size variants.

    Parameters:
        fontName (string|nil)
            Optional main interface font. When omitted, the value from the `Font` configuration is used.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.font.registerFonts("Montserrat Medium")
        ```

    Realm:
        Shared
]]
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
    local function getManagedFontData(fontName)
        if not isstring(fontName) or #fontName > 63 then return end
        local mainFont = lia.config.get("Font", "Montserrat Medium") or "Montserrat Medium"
        local hudFont = lia.config.get("HUDFont", "Montserrat Medium") or "Montserrat Medium"
        local baseName
        local size = 16
        local suffix = ""
        if fontName == "LiliaFont" then
            baseName = "LiliaFont"
        elseif fontName == "LiliaHUDFont" then
            baseName = "LiliaHUDFont"
        elseif fontName == "HUDFont" then
            baseName = "HUDFont"
        else
            local sizeString
            baseName, sizeString, suffix = fontName:match("^(LiliaFont)%.(%d+)([bis]*)$")
            if not baseName then baseName, sizeString, suffix = fontName:match("^(LiliaHUDFont)%.(%d+)([bis]*)$") end
            if not baseName then baseName, sizeString, suffix = fontName:match("^(HUDFont)%.(%d+)([bis]*)$") end
            if not baseName then return end
            size = tonumber(sizeString)
            if not size or size < 1 then return end
        end

        local fontFace = baseName == "LiliaFont" and mainFont or hudFont
        local bold = suffix:find("b", 1, true) ~= nil
        local italic = suffix:find("i", 1, true) ~= nil
        local shadow = suffix:find("s", 1, true) ~= nil
        if bold then fontFace = lia.font.getBoldFontName(fontFace) end
        return {
            font = fontFace,
            size = size,
            extended = true,
            antialias = true,
            weight = bold and 700 or 500,
            italic = italic,
            shadow = shadow
        }
    end

    function surface.SetFont(fontName)
        if isstring(fontName) and not lia.font.stored[fontName] then
            local fontData = getManagedFontData(fontName)
            if fontData then lia.font.register(fontName, fontData) end
        end
        return oldSurfaceSetFont(fontName)
    end

    hook.Add("InitializedConfig", "liaFontsOnConfigLoad", function()
        local function initializeFonts()
            local fontName = lia.config.get("Font", "Montserrat Medium")
            lia.font.registerFonts(fontName)
            timer.Simple(0.2, function()
                lia.font.loadFonts()
                hook.Run("RefreshFonts")
            end)
        end

        if not lia.config.stored or not lia.config.stored.Font then
            timer.Simple(0.1, initializeFonts)
        else
            initializeFonts()
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

hook.Add("OnConfigUpdated", "liaFontsOnConfigUpdate", function(key, oldValue, newValue)
    if not CLIENT or oldValue == newValue or key ~= "Font" then return end
    lia.font.registerFonts(newValue or "Montserrat Medium")
    timer.Simple(0.1, function()
        lia.font.loadFonts()
        hook.Run("RefreshFonts")
    end)
end)

hook.Add("OnConfigUpdated", "liaHUDFontsOnConfigUpdate", function(key, oldValue, newValue)
    if not CLIENT or oldValue == newValue or key ~= "HUDFont" then return end
    lia.font.registerFonts(lia.config.get("Font", "Montserrat Medium"))
    timer.Simple(0.1, function()
        lia.font.loadFonts()
        hook.Run("RefreshFonts")
    end)
end)
