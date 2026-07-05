--[[
    Folder: Developer - Libraries
    File: lia.lang.md
]]
--[[
    Language

    Language helpers for loading localization files, registering translation tables, resolving localized strings, and caching formatted localization output.
]]
--[[
    Overview:
        The language library centralizes localization behavior under `lia.lang`. It loads language files from directories, stores normalized language tables, exposes available languages, formats localized strings using the configured active language, resolves string tokens prefixed with `@`, and maintains a bounded cache for repeated localization lookups.
]]
--[[
    Hooks:
        OnLocalizationLoaded()

    Purpose:
        Runs after the base language files are loaded and the global localization helper has been assigned.

    Category:
        Languages

    Parameters:
        None.

    Example Usage:
        ```lua
        hook.Add("OnLocalizationLoaded", "liaExampleOnLocalizationLoaded", function()
            print("[MyModule] handled OnLocalizationLoaded")
        end)
        ```

    Realm:
        Shared
]]
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
lia.lang.cache = lia.lang.cache or {}
lia.lang.cache.maxSize = 1000
lia.lang.cache.currentSize = 0
--[[
    Purpose:
        Loads language files from a directory and stores their localization entries under `lia.lang.stored`.

    Parameters:
        directory (string)
            The directory path containing language Lua files to include.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.lang.loadFromDir("lilia/gamemode/languages")
        ```

    Realm:
        Shared
]]
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5):lower()
        end

        lia.loader.include(directory .. "/" .. v, "shared")
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
    Purpose:
        Adds or merges localization entries into a named language table and clears the localization cache.

    Parameters:
        name (string)
            The language identifier to add entries to.

        tbl (table)
            A table of localization keys and values to register.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.lang.addTable("english", {
            welcomeMessage = "Welcome, %s."
        })
        ```

    Realm:
        Shared
]]
function lia.lang.addTable(name, tbl)
    local lowerName = tostring(name):lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][tostring(k)] = tostring(v)
    end

    lia.lang.clearCache()
end

--[[
    Purpose:
        Returns a sorted list of loaded language names.

    Parameters:
        None.

    Returns:
        table
            A sorted array of loaded language names with the first character capitalized.

    Example Usage:
        ```lua
        for _, language in ipairs(lia.lang.getLanguages()) do
            print(language)
        end
        ```

    Realm:
        Shared
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
    Purpose:
        Generates a cache key for a language lookup using the language, localization key, and formatting arguments.

    Parameters:
        lang (string)
            The language identifier used for the lookup.

        key (string)
            The localization key being resolved.

        ... (any)
            Optional formatting arguments included in the cache key.

    Returns:
        string
            The generated cache key.

    Example Usage:
        ```lua
        local cacheKey = lia.lang.generateCacheKey("english", "welcomeMessage", client:Name())
        ```

    Realm:
        Shared
]]
function lia.lang.generateCacheKey(lang, key, ...)
    local argCount = select("#", ...)
    if argCount == 0 then return lang .. ":" .. key end
    local paramStr = ""
    for i = 1, argCount do
        local arg = select(i, ...)
        paramStr = paramStr .. "|" .. tostring(arg)
    end
    return lang .. ":" .. key .. paramStr
end

--[[
    Purpose:
        Removes a portion of cached localization entries when the localization cache exceeds its configured size.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.lang.cleanupCache()
        ```

    Realm:
        Shared
]]
function lia.lang.cleanupCache()
    local cache = lia.lang.cache
    local keys = {}
    for key in pairs(cache) do
        if key ~= "maxSize" and key ~= "currentSize" then table.insert(keys, key) end
    end

    local removeCount = math.floor(#keys / 2)
    for i = 1, removeCount do
        local key = keys[i]
        cache[key] = nil
    end

    cache.currentSize = #keys - removeCount
end

--[[
    Purpose:
        Clears all cached localization results while preserving the configured maximum cache size.

    Parameters:
        None.

    Returns:
        nil

    Example Usage:
        ```lua
        lia.lang.clearCache()
        ```

    Realm:
        Shared
]]
function lia.lang.clearCache()
    lia.lang.cache = {
        maxSize = lia.lang.cache.maxSize or 1000,
        currentSize = 0
    }
end

--[[
    Purpose:
        Resolves and formats a localization string for the currently configured language.

    Parameters:
        key (string)
            The localization key to resolve.

        ... (any)
            Optional values passed to `string.format` for the resolved localization template.

    Returns:
        string
            The resolved and formatted localization string, or the key itself when no localization entry exists or formatting fails.

    Example Usage:
        ```lua
        client:notifyInfo(lia.lang.getLocalizedString("welcomeMessage", client:Name()))
        print(L("welcomeMessage", client:Name()))
        ```

    Realm:
        Shared
]]
function lia.lang.getLocalizedString(key, ...)
    local lang = lia.config.get("Language", "english") or "english"
    local cacheKey = lia.lang.generateCacheKey(lang, key, ...)
    if lia.lang.cache[cacheKey] then return lia.lang.cache[cacheKey] end
    local langTable = lia.lang.stored and lia.lang.stored[lang:lower()]
    local template = langTable and langTable[key]
    if not template then return tostring(key) end
    local count = select("#", ...)
    local args = {}
    for i = 1, count do
        local arg = select(i, ...)
        if istable(arg) then
            args[i] = table.concat(arg, ", ")
        else
            args[i] = tostring(arg or "")
        end
    end

    local needed = select(2, template:gsub("%%[^%%]", ""))
    for i = count + 1, needed do
        args[i] = ""
    end

    local success, result = pcall(string.format, template, unpack(args))
    if not success then
        lia.error(L("formatErrorInLocalizationString") .. " '" .. tostring(key) .. "': " .. result)
        return tostring(key)
    end

    lia.lang.cache[cacheKey] = result
    lia.lang.cache.currentSize = lia.lang.cache.currentSize + 1
    if lia.lang.cache.currentSize > lia.lang.cache.maxSize then lia.lang.cleanupCache() end
    return result
end

--[[
    Purpose:
        Resolves localization tokens that begin with `@` while leaving all other values unchanged.

    Parameters:
        value (any)
            The value to inspect for a localization token.

        ... (any)
            Optional formatting arguments passed to the resolved localization string.

    Returns:
        any
            The resolved localization string for `@` tokens, an empty string for an empty token, or the original value when it is not a localization token.

    Example Usage:
        ```lua
        local text = lia.lang.resolveToken("@welcomeMessage", client:Name())
        ```

    Realm:
        Shared
]]
function lia.lang.resolveToken(value, ...)
    if not isstring(value) then return value end
    if value:sub(1, 1) ~= "@" then return value end
    local key = value:sub(2)
    if key == "" then return "" end
    return lia.lang.getLocalizedString(key, ...)
end

L = lia.lang.getLocalizedString
lia.lang.loadFromDir("lilia/gamemode/languages")
hook.Run("OnLocalizationLoaded")
hook.Add("OnConfigUpdated", "lia.lang.cache", function(key, oldValue, newValue) if key == "Language" and oldValue ~= newValue then lia.lang.clearCache() end end)
