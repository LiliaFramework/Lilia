lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
function lia.lang.loadFromDir(directory)
    for _, filename in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if filename:sub(1, 3) == "sh_" then
            niceName = filename:sub(4, -5):lower()
        else
            niceName = filename:sub(1, -5):lower()
        end

        lia.include(directory .. "/" .. filename, "shared")
        if LANGUAGE then
            if NAME then
                lia.lang.names[niceName] = NAME
                NAME = nil
            end

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, LANGUAGE)
            LANGUAGE = nil
        end
    end
end

function lia.lang.AddTable(name, tbl)
    local lowerName = name:lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for key, value in pairs(tbl) do
        lia.lang.stored[lowerName][key] = value
        lia.lang.stored[lowerName][key:lower()] = value
    end
end

lia.lang.loadFromDir("lilia/gamemode/languages")
local languageOptions = {}
for langName in pairs(lia.lang.stored) do
    local displayName = langName:sub(1, 1):upper() .. langName:sub(2)
    table.insert(languageOptions, displayName)
end

function L(key, ...)
    if not key then lia.error("L called without a translation key", 2) end
    local lookupKey = key:lower()
    local storedTranslations = lia.lang.stored
    local selectedLanguage = (lia.config.get("Language", "english") or "english"):lower()
    local translationsForLanguage = storedTranslations[selectedLanguage]
    local str = translationsForLanguage and translationsForLanguage[lookupKey]
    if not str then lia.error(("Missing translation for '%s' in language '%s'"):format(lookupKey, selectedLanguage), 2) end
    return string.format(str, ...)
end

table.sort(languageOptions)
lia.config.add("Language", "Language", "English", nil, {
    desc = "Determines the language setting for the game.",
    category = "General",
    type = "Table",
    options = languageOptions
})

hook.Run("OnLocalizationLoaded")