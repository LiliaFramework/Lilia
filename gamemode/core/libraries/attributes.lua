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
--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
    Realm: Shared
    Example Usage:

    Low Complexity:
    ```lua
    -- Simple: Load attributes from a single directory
    lia.attribs.loadFromDir("gamemode/attributes")
    ```

    Medium Complexity:
    ```lua
    -- Medium: Load attributes with conditional directory checking
    local attrDir = "gamemode/attributes"
    if file.Exists(attrDir, "LUA") then
        lia.attribs.loadFromDir(attrDir)
    end
    ```

    High Complexity:
    ```lua
    -- High: Load attributes from multiple directories with error handling
    local attributeDirs = {"gamemode/attributes", "modules/attributes", "plugins/attributes"}
    for _, dir in ipairs(attributeDirs) do
        if file.Exists(dir, "LUA") then
            lia.attribs.loadFromDir(dir)
        else
            print("Warning: Attribute directory not found: " .. dir)
        end
    end
    ```
]]
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
    --[[
        Purpose: Sets up attributes for a client's character by calling OnSetup hooks for each registered attribute
        When Called: When a client spawns or when their character is created
        Parameters: client (Player) - The client whose character attributes need to be set up
        Returns: None
        Realm: Server
        Example Usage:

        Low Complexity:
        ```lua
        -- Simple: Setup attributes for a client
        lia.attribs.setup(client)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Setup attributes with validation
        if IsValid(client) and client:IsPlayer() then
            lia.attribs.setup(client)
        end
        ```

        High Complexity:
        ```lua
        -- High: Setup attributes with custom logic and error handling
        hook.Add("PlayerSpawn", "SetupAttributes", function(client)
            if not client:getChar() then return end

            timer.Simple(0.1, function()
                if IsValid(client) then
                    lia.attribs.setup(client)
                    print("Attributes set up for " .. client:Name())
                end
            end)
        end)
        ```
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
