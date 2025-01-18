
-- @library lia.lang
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--- Loads language files from a directory.
-- @realm shared
-- @string directory Directory to load language files from
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
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

--- Adds a table of phrases to a language.
-- @realm shared
-- @string name The name of the language to add the phrases to.
-- @tab tbl The table of phrases to add.
function lia.lang.AddTable(name, tbl)
    lia.lang.stored[name] = table.Merge(lia.lang.stored[name] or {}, tbl)
end

--- Retrieves a localized string based on the specified key and the default language setting.
-- @string key The key corresponding to the desired localized string.
-- @tab ... Additional parameters to format the localized string.
-- @return The formatted localized string.
-- @realm shared
function L(key, ...)
    local languages = lia.lang.stored
    local langKey = lia.config.Language
    local info = languages[langKey] or languages.english
    return string.format(info and info[key] or key, ...)
end

lia.lang.loadFromDir("lilia/gamemode/languages")
