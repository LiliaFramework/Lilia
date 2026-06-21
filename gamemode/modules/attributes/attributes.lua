--[[
    Folder: Developer - Libraries
    File: lia.attribs.md
]]
--[[
    Attributes

    Attribute helpers for loading, registering, and setting up character attributes.
]]
--[[
    Overview:
        The attributes library centralizes shared attribute behavior under `lia.attribs`. It stores registered attribute definitions, loads attribute files from a directory, registers attribute metadata, resolves localized names and descriptions, and runs server-side setup callbacks for character attributes.
]]
lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[
    Purpose:
        Loads and registers all attribute definition files from a directory.

    Parameters:
        directory (string)
            The Lua directory containing attribute definition files.

    Returns:
        None

    Example Usage:
        ```lua
        lia.attribs.loadFromDir("schema/attributes")
        ```

    Realm:
        Shared
]]
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        lia.loader.include(directory .. "/" .. v, "shared")
        lia.attribs.register(niceName, ATTRIBUTE)
        ATTRIBUTE = nil
    end
end

--[[
    Purpose:
        Registers an attribute definition and stores it in the attribute list.

    Parameters:
        uniqueID (string)
            The unique identifier used to store and reference the attribute.

        data (table)
            The attribute data to merge into the registered attribute definition.

    Returns:
        table
            The registered attribute table.

    Example Usage:
        ```lua
        lia.attribs.register("strength", {
            name = "strength",
            desc = "strengthDesc"
        })
        ```

    Realm:
        Shared
]]
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
    --[[
    Purpose:
        Runs setup behavior for each registered attribute on a player's active character.

    Parameters:
        client (Player)
            The player whose character attributes are being initialized.

    Returns:
        None

    Example Usage:
        ```lua
        lia.attribs.setup(client)
        ```

    Realm:
        Server
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
