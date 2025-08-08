--[[
# Attributes Library

This page documents the functions for working with character attributes.

---

## Overview

The attributes library loads attribute definitions from Lua files, keeps track of character values, and provides helper methods for modifying them. Each attribute is defined on a global `ATTRIBUTE` table inside its own file. When `lia.attribs.loadFromDir` is called the file is included **shared**, default values are filled in, and the definition is stored in `lia.attribs.list` using the file name (without extension or the `sh_` prefix) as the key. The loader is invoked automatically when a module is initialized, so most schemas simply place their attribute files in `schema/attributes/`.

For details on each `ATTRIBUTE` field, see the [Attribute Fields documentation](../definitions/attribute.md).
]]
lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}
--[[
    lia.attribs.loadFromDir

    Purpose:
        Loads all attribute definition files from the specified directory, registering them into lia.attribs.list.
        Each attribute file should define an ATTRIBUTE table. This function ensures the attribute's name and description
        are localized, and stores the attribute in the global attribute list.

    Parameters:
        directory (string) - The directory path to search for attribute files (should be relative to the gamemode).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Load all attributes from the "attributes" directory
        lia.attribs.loadFromDir("gamemode/schema/attributes")
]]
function lia.attribs.loadFromDir(directory)
    for _, v in ipairs(file.Find(directory .. "/*.lua", "LUA")) do
        local niceName = v:sub(1, 3) == "sh_" and v:sub(4, -5):lower() or v:sub(1, -5)
        ATTRIBUTE = lia.attribs.list[niceName] or {}
        lia.include(directory .. "/" .. v, "shared")
        ATTRIBUTE.name = ATTRIBUTE.name and L(ATTRIBUTE.name) or L("unknown")
        ATTRIBUTE.desc = ATTRIBUTE.desc and L(ATTRIBUTE.desc) or L("noDesc")
        lia.attribs.list[niceName] = ATTRIBUTE
        ATTRIBUTE = nil
    end
end

if SERVER then
    --[[
        lia.attribs.setup

        Purpose:
            Sets up all attributes for a given client by invoking the OnSetup callback for each attribute, if defined.
            This is typically called when a character is loaded or respawned, to apply attribute effects.

        Parameters:
            client (Player) - The player entity whose attributes should be set up.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Setup attributes for a player after character load
            hook.Add("PlayerLoadedChar", "SetupAttributes", function(client)
                lia.attribs.setup(client)
            end)
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