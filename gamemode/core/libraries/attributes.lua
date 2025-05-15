lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[
    lia.attribs.loadFromDir(directory)

    Description:
        Loads attribute definitions from all Lua files in the given directory.
        Files beginning with "sh_" are treated as shared and loaded on both client and server.
        Each file must return an ATTRIBUTE table, which is then stored in lia.attribs.list
        under a key derived from the filename (without the "sh_" prefix or ".lua" extension).

    Parameters:
        directory (string) – Path to the folder containing attribute Lua files.

    Realm:
        Shared

    Returns:
        None
]]
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        if MODULE then ATTRIBUTE.module = MODULE.uniqueID end
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or l("unknown")
        ATTRIBUTE.desc = ATTRIBUTE.desc or L("noDesc")
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    --[[
        lia.attribs.setup(client)

        Description:
            Initializes attributes for a given client’s character.
            Iterates over all entries in lia.attribs.list, retrieves the character’s
            attribute value, and calls the attribute’s OnSetup callback if it exists.

        Parameters:
            client (Player) – The player whose character attributes should be set up.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.attribs.setup(client)
        local character = client:getChar()
        if not character then return end
        for attribID, attribData in pairs(lia.attribs.list) do
            local value = character:getAttrib(attribID, 0)
            if attribData.OnSetup then attribData:OnSetup(client, value) end
        end
    end
end
