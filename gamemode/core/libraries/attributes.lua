lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[
    lia.attribs.loadFromDir(directory)

    Description:
        Loads attribute definitions from the given folder. Files prefixed
        with "sh_" are treated as shared and loaded on both client and
        server. The ATTRIBUTE table returned from each file is stored in
        lia.attribs.list using the filename, without prefix or extension,
        as the key.

    Parameters:
        directory (string) – Path to the folder containing attribute Lua files.

    Realm:
        Shared

    Returns:
        None

    Example:
        lia.attribs.loadFromDir("schema/attributes")
]]
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name or L("unknown")
        ATTRIBUTE.desc = ATTRIBUTE.desc or L("noDesc")
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    --[[
        lia.attribs.setup(client)

        Description:
            Initializes attribute data for a client's character. Each attribute in
            lia.attribs.list is read from the character and, if the attribute has
            an OnSetup callback, it is executed with the current value.

        Parameters:
            client (Player) – The player whose character attributes should be set up.

        Realm:
            Server

        Returns:
            None

        Example:
            lia.attribs.setup(client)
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
