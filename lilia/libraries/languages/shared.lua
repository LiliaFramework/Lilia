lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}
function lia.lang.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        lia.util.include(directory .. "/" .. v, "shared")
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
