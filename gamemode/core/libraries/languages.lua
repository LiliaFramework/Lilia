--[[
# Languages Library

This page documents the functions for working with localization and language management.

---

## Overview

The languages library provides a comprehensive localization system for managing multiple languages within the Lilia framework. It handles language file loading, translation management, and provides utilities for adding and retrieving localized strings. The library supports dynamic language switching and provides a foundation for multi-language support.
]]
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--[[
    lia.lang.loadFromDir

    Purpose:
        Loads all language definition files from the specified directory, registering their contents into lia.lang.stored.
        Each language file should define a LANGUAGE table and optionally a NAME variable for the display name.
        This function ensures all language keys and values are stored as strings and merges them into the global language table.

    Parameters:
        directory (string) - The directory path to search for language files (should be relative to the gamemode).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Load all language files from the "lilia/gamemode/languages" directory
        lia.lang.loadFromDir("lilia/gamemode/languages")
]]
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5):lower()
        end

        lia.include(directory .. "/" .. v, "shared")
        if LANGUAGE then
            if NAME then
                lia.lang.names[niceName] = NAME
                NAME = nil
            end

            local formatted = {}
            for k, val in pairs(LANGUAGE) do
                formatted[tostring(k)] = tostring(val)
            end

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, formatted)
            LANGUAGE = nil
        end
    end
end

--[[
    lia.lang.AddTable

    Purpose:
        Adds or merges a table of language key-value pairs into the specified language in lia.lang.stored.
        All keys and values are converted to strings to ensure consistency.

    Parameters:
        name (string) - The language name (e.g., "english", "german").
        tbl (table)   - The table of key-value pairs to add to the language.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Add a set of translations to the "english" language
        lia.lang.AddTable("english", {
            hello = "Hello!",
            goodbye = "Goodbye!"
        })
]]
function lia.lang.AddTable(name, tbl)
    local lowerName = tostring(name):lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][tostring(k)] = tostring(v)
    end
end

--[[
    lia.lang.getLanguages

    Purpose:
        Retrieves a sorted list of all available language display names currently loaded in lia.lang.stored.

    Parameters:
        None.

    Returns:
        languages (table) - A sorted table of language display names (first letter capitalized).

    Realm:
        Shared.

    Example Usage:
        -- Print all available languages
        for _, lang in ipairs(lia.lang.getLanguages()) do
            print(lang)
        end
]]
function lia.lang.getLanguages()
    local languages = {}
    for key, _ in pairs(lia.lang.stored) do
        local displayName = key:sub(1, 1):upper() .. key:sub(2)
        table.insert(languages, displayName)
    end

    table.sort(languages)
    return languages
end

--[[
    L

    Purpose:
        Retrieves a localized string for the given key from the current language, formatting it with any additional arguments.
        If the key is not found, returns the key itself. Arguments are inserted into the string using %s placeholders.

    Parameters:
        key (string)      - The language key to look up.
        ... (vararg)      - Optional arguments to format into the localized string.

    Returns:
        localized (string) - The formatted, localized string.

    Realm:
        Shared.

    Example Usage:
        -- Assuming "greeting" = "Hello, %s!" in the current language
        print(L("greeting", "John")) -- Output: Hello, John!
]]
function L(key, ...)
    local stored = lia.lang.stored or {}
    local lang = lia.config and lia.config.get("Language", "english") or "english"
    local template = (stored[lang:lower()] or {})[key] or tostring(key)
    local count = select("#", ...)
    local args = {}
    for i = 1, count do
        args[i] = tostring(select(i, ...) or "")
    end

    local needed = 0
    for _ in template:gmatch("%%s") do
        needed = needed + 1
    end

    for i = count + 1, needed do
        args[i] = ""
    end
    return string.format(template, unpack(args))
end

lia.lang.loadFromDir("lilia/gamemode/languages")
hook.Run("OnLocalizationLoaded")
