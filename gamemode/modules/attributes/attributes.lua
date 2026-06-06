lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        lia.loader.include(directory .. "/" .. v, "shared")
        lia.attribs.register(niceName, ATTRIBUTE)
        ATTRIBUTE = nil
    end
end

function lia.attribs.register(uniqueID, data)
    assert(isstring(uniqueID), "uniqueID must be a string")
    assert(istable(data), "data must be a table")
    local attribute = lia.attribs.list[uniqueID] or {}
    for k, v in pairs(data) do
        attribute[k] = v
    end

    attribute.uniqueID = uniqueID
    attribute.name = attribute.name and lia.lang.resolveToken(attribute.name) or lia.lang.resolveToken("@unknown")
    attribute.desc = attribute.desc and lia.lang.resolveToken(attribute.desc) or lia.lang.resolveToken("@noDesc")
    lia.attribs.list[uniqueID] = attribute
    return attribute
end

if SERVER then
    function lia.attribs.setup(client)
        local character = client:getChar()
        if not character then return end
        for attribID, attribData in pairs(lia.attribs.list) do
            local value = character:getAttrib(attribID, 0)
            if attribData.OnSetup then attribData:OnSetup(client, value) end
        end
    end
end
