lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName
        if v:sub(1, 3) == "sh_" then
            niceName = v:sub(4, -5):lower()
        else
            niceName = v:sub(1, -5)
        end

        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
        ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    function lia.attribs.setup(client)
        local character = client:getChar()
        if character then
            for k, v in pairs(lia.attribs.list) do
                if v.OnSetup then v:OnSetup(client, character:getAttrib(k, 0)) end
            end
        end
    end
end
