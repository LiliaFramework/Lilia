--[[
    Languages Library

    Internationalization (i18n) and localization system for the Lilia framework.
]]
--[[
    Overview:
        The languages library provides comprehensive internationalization (i18n) functionality for the Lilia framework. It handles loading, storing, and retrieving localized strings from language files, supporting multiple languages with fallback mechanisms. The library automatically loads language files from directories, processes them into a unified storage system, and provides string formatting with parameter substitution. It includes functions for adding custom language tables, retrieving available languages, and getting localized strings with proper error handling. The library operates on both server and client sides, ensuring consistent localization across the entire gamemode. It supports dynamic language switching and provides the global L() function for easy access to localized strings throughout the codebase.
]]
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
lia.lang.cache = lia.lang.cache or {}
lia.lang.cache.maxSize = 1000
lia.lang.cache.currentSize = 0
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

function lia.lang.addTable(name, tbl)
    local lowerName = tostring(name):lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][tostring(k)] = tostring(v)
    end

    lia.lang.clearCache()
end

function lia.lang.getLanguages()
    local languages = {}
    for key, _ in pairs(lia.lang.stored) do
        local displayName = key:sub(1, 1):upper() .. key:sub(2)
        table.insert(languages, displayName)
    end

    table.sort(languages)
    return languages
end

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

function lia.lang.clearCache()
    lia.lang.cache = {
        maxSize = lia.lang.cache.maxSize or 1000,
        currentSize = 0
    }
end

function lia.lang.getLocalizedString(key, ...)
    local lang = lia.config and lia.config.get("Language", "english") or "english"
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

L = lia.lang.getLocalizedString
lia.lang.loadFromDir("lilia/gamemode/languages")
hook.Run("OnLocalizationLoaded")
hook.Add("OnConfigChanged", "lia.lang.cache", function(key, oldValue, newValue) if key == "Language" and oldValue ~= newValue then lia.lang.clearCache() end end)
