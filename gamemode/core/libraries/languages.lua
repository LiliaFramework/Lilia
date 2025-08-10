-- luacheck: globals lia file LANGUAGE NAME hook table.Merge L
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

            local formatted = {}
            for k, val in pairs(LANGUAGE) do
                formatted[tostring(k)] = tostring(val)
            end

            lia.lang.stored[niceName] = table.Merge(lia.lang.stored[niceName] or {}, formatted)
            LANGUAGE = nil
        end
    end
end

function lia.lang.AddTable(name, tbl)
    local lowerName = tostring(name):lower()
    lia.lang.stored[lowerName] = lia.lang.stored[lowerName] or {}
    for k, v in pairs(tbl) do
        lia.lang.stored[lowerName][tostring(k)] = tostring(v)
    end
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