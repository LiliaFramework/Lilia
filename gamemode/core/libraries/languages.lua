lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
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

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, LANGUAGE)
            LANGUAGE = nil
        end
    end
end

function lia.lang.AddTable(name, tbl)
    local lowerName = name:lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][k] = v
        lia.lang.stored[lowerName][k:lower()] = v
    end
end

lia.lang.loadFromDir("lilia/gamemode/languages")
local langs = {}
for key, _ in pairs(lia.lang.stored) do
    local displayName = key:sub(1, 1):upper() .. key:sub(2)
    table.insert(langs, displayName)
end

function L(key, ...)
    if not key then lia.error("L called without a translation key", 2) end
    local k = key:lower()
    local langs = lia.lang.stored or {}
    local lang = (lia.config.get("Language", "english") or "english"):lower()
    local info = langs[lang]
    local str = info and info[k]
    if not str then lia.error(("Missing translation for '%s' in language '%s'"):format(k, lang), 2) end
    return string.format(str, ...)
end

table.sort(langs)
lia.config.add("Language", "Language", "English", nil, {
    desc = "Determines the language setting for the game.",
    category = "General",
    type = "Table",
    options = langs
})

hook.Run("OnLocalizationLoaded")