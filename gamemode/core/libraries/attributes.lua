--[[
    Attributes Library

    Character attribute management system for the Lilia framework.
]]
--[[
    Overview:
        The attributes library provides functionality for managing character attributes in the Lilia framework. It handles loading attribute definitions from files, registering attributes in the system, and setting up attributes for characters during spawn. The library operates on both server and client sides, with the server managing attribute setup during character spawning and the client handling attribute-related UI elements. It includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior.
]]
lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        lia.loader.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name and L(ATTRIBUTE.name) or L("unknown")
        ATTRIBUTE.desc = ATTRIBUTE.desc and L(ATTRIBUTE.desc) or L("noDesc")
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
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
