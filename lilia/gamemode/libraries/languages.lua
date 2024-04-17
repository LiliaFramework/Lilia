--[[--
Multi-language phrase support.

Lilia has support for multiple languages, and you can easily leverage this system for use in your own schema, plugins, etc.
Languages will be loaded from the schema and any plugins in `languages/sh_languagename.lua`, where `languagename` is the id of a
language (`english` for English, `french` for French, etc). The structure of a language file is a table of phrases with the key
as its phrase ID and the value as its translation for that language. An example
LANGUAGE = {
    welcomeMessage = "Welcome to the game!",
    gameOver = "Game over! You won the game!",
    victory = "%s achieved victory!",
}

The phrases defined in these language files can be used with the `L` global function:
	print(L("welcomeMessage"))
	> "Welcome to the game!"

All phrases are formatted with `string.format`, so if you wish to add some info in a phrase you can use standard Lua string
formatting arguments:
	print(L("victory", "Nicholas"))
	> Nicholas achieved victory!
]]
-- @module lia.lang
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
--- Loads language files from a directory.
-- @realm shared
-- @internal
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

if SERVER then
    local playerMeta = FindMetaTable("Player")
    local ClientGetInfo = playerMeta.GetInfo
    --- Retrieves a localized string based on the specified key and client's language setting.
    -- @param key The key corresponding to the desired localized string.
    -- @param client The client for whom the localized string is intended.
    -- @param ... Additional parameters to format the localized string.
    -- @return The formatted localized string.
    -- @realm server
    function L(key, client, ...)
        local languages = lia.lang.stored
        local langKey = ClientGetInfo(client, "lia_language")
        local info = languages[langKey] or languages.english
        return string.format(info and info[key] or key, ...)
    end
    --- Retrieves a localized string based on the specified key and client's language setting.
    -- Similar to L(), but returns nil if the key is not found in the language table.
    -- @param key The key corresponding to the desired localized string.
    -- @param client The client for whom the localized string is intended.
    -- @param ... Additional parameters to format the localized string.
    -- @return The formatted localized string, or nil if the key is not found.
    -- @realm server
    function L2(key, client, ...)
        local languages = lia.lang.stored
        local langKey = ClientGetInfo(client, "lia_language")
        local info = languages[langKey] or languages.english
        if info and info[key] then return string.format(info[key], ...) end
    end
    --- Retrieves a localized string based on the specified key and language key.
    -- @param key The key corresponding to the desired localized string.
    -- @param langKey The language key to use for localization.
    -- @param ... Additional parameters to format the localized string.
    -- @return The formatted localized string, or the key if not found.
    -- @realm server
    function L3(key, langKey, ...)
        local languages = lia.lang.stored
        if langKey then
            local info = languages[langKey] or languages.english
            return string.format(info and info[key] or key, ...)
        else
            return key
        end
    end
else
    LIA_CVAR_LANG = CreateClientConVar("lia_language", "english", true, true)
    --- Creates a client-side ConVar to store the language setting and retrieves a localized string based on it.
    -- @param key The key corresponding to the desired localized string.
    -- @param ... Additional parameters to format the localized string.
    -- @return The formatted localized string.
    -- @realm client
    function L(key, ...)
        local languages = lia.lang.stored
        local langKey = LIA_CVAR_LANG:GetString()
        local info = languages[langKey] or languages.english
        return string.format(info and info[key] or key, ...)
    end
    --- Retrieves a localized string based on the specified key and client's language setting.
    -- Similar to L(), but returns nil if the key is not found in the language table.
    -- @param key The key corresponding to the desired localized string.
    -- @param ... Additional parameters to format the localized string.
    -- @return The formatted localized string, or nil if the key is not found.
    -- @realm client
    function L2(key, ...)
        local langKey = LIA_CVAR_LANG:GetString()
        local info = lia.lang.stored[langKey]
        if info and info[key] then return string.format(info[key], ...) end
    end
end

lia.lang.loadFromDir("lilia/gamemode/config/languages")