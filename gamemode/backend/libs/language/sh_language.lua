--------------------------------------------------------------------------------------------------------
lia.lang = lia.lang or {}
lia.lang.names = lia.lang.names or {}
lia.lang.stored = lia.lang.stored or {}

--------------------------------------------------------------------------------------------------------
function lia.lang.loadFromDir(directory)
    for k, v in ipairs(file.Find(directory .. "/sh_*.lua", "LUA")) do
        local niceName = v:sub(4, -5):lower()
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
--------------------------------------------------------------------------------------------------------