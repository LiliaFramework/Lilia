lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--[[
    lia.lang.loadFromDir(directory)

   Description:
      Loads all Lua language files (*.lua) from the specified directory,
      includes them as shared files, and merges any defined LANGUAGE table
      into the stored language data. If a language name (NAME) is provided in the file,
      it is registered in lia.lang.names.

   Parameters:
      directory (string) - The path to the directory containing language files.

    Returns:
        nil

    Realm:
        Shared

    Internal Function:
        true
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

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, LANGUAGE)
            LANGUAGE = nil
        end
    end
end

--[[
    lia.lang.AddTable(name, tbl)

   Description:
      Adds or merges a table of language key-value pairs into the stored language table
      for a specified language. If the language already exists in the storage, the new values
      will be merged with the existing ones.

   Parameters:
      name (string) - The name of the language to update.
      tbl (table) - A table containing language key-value pairs to add.

    Returns:
        nil

    Realm:
        Shared
]]
function lia.lang.AddTable(name, tbl)
    local lowerName = name:lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][k] = v
    end
end

lia.lang.loadFromDir("lilia/gamemode/languages")
local langs = {}
for key, _ in pairs(lia.lang.stored) do
    local displayName = key:sub(1, 1):upper() .. key:sub(2)
    table.insert(langs, displayName)
end

function L(key, ...)
    local languages = lia.lang.stored or {}
    local langKey = lia.config.get("Language", "english"):lower()
    local info = languages[langKey]
    return string.format(info and info[key] or key, ...)
end

table.sort(langs)
lia.config.add("Language", "Language", "English", nil, {
    desc = "Determines the language setting for the game.",
    category = "General",
    type = "Table",
    options = langs
})

hook.Run("OnLocalizationLoaded")
