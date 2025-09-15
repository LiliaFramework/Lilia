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
    local lang = lia.config and lia.config.get("Language", "english") or "english"
    local langTable = lia.lang.stored and lia.lang.stored[lang:lower()]
    local template = langTable and langTable[key]
    if not template then return tostring(key) end
    if template:find("%%d") then lia.error("String formatting with %d is not allowed in localization strings: " .. tostring(key)) end
    if template:find("%%[^%%sdfg]") then lia.error("Invalid format specifier in localization string: " .. tostring(key) .. " - " .. template) end
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
        lia.error("Format error in localization string '" .. tostring(key) .. "': " .. result)
        return tostring(key)
    end
    return result
end
lia.lang.loadFromDir("lilia/gamemode/languages")
hook.Run("OnLocalizationLoaded")
