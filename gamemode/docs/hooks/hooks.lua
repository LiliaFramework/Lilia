--[[
    Lilia Framework Hooks

    Comprehensive hook system for the Lilia framework.
]]
--[[
    Overview:
    The Lilia framework provides an extensive hook system that allows developers
    to extend and customize the gamemode's behavior. Hooks are categorized into
    three main types: Server-side hooks, Client-side hooks, and Shared hooks.

    All hooks follow the standard Garry's Mod hook system and can be overridden
    or extended by addons and modules to customize the framework's behavior.
]]
--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AddBarField(sectionName, fieldName, labelText, minFunc, maxFunc, valueFunc)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AddSection(sectionName, color, priority, location)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AddTextField(sectionName, fieldName, labelText, valueFunc)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AddToAdminStickHUD(client, target, information)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AddWarning(charID, warned, warnedSteamID, timestamp, message, warner, warnerSteamID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AdjustCreationData(client, data, newData, originalData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AdjustPACPartData(wearer, id, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AdjustStaminaOffset(client, offset)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function AttachPart(client, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function BagInventoryReady(self, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function BagInventoryRemoved(self, inv)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanBeTransfered(targetChar, faction, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanCharBeTransfered(targetChar, faction, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanDeleteChar(client, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanDisplayCharInfo(name)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanInviteToClass(client, target)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanInviteToFaction(client, target)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanItemBeTransfered(item, fromInventory, toInventory, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanOpenBagPanel(item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanOutfitChangeModel(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPerformVendorEdit(self, vendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPersistEntity(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPickupMoney(activator, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerAccessDoor(client, self, access)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerAccessVendor(activator, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerChooseWeapon(weapon)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerCreateChar(client, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerDropItem(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerEarnSalary(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerEquipItem(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerHoldObject(client, entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerInteractItem(client, action, self, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerJoinClass(client, class, info)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerKnock(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerLock(client, door)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerModifyConfig(client, key)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerOpenScoreboard(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerRotateItem(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerSeeLogCategory(client, k)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerSpawnStorage(client, _, info)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerSwitchChar(client, currentChar, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerTakeItem(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerThrowPunch(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerTradeWithVendor(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerUnequipItem(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerUnlock(client, door)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerUseChar(client, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerUseCommand(client, command)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerUseDoor(client, door)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanPlayerViewInventory()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanRunItemAction(itemTable, k)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CanSaveData(ent, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharCleanUp(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharDeleted(client, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharForceRecognized(ply, range)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharHasFlags(self, flags)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharListColumns(columns)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharListEntry(entry, row)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharListExtraDetails(client, entry, stored)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharListLoaded(newCharList)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharListUpdated(oldCharList, newCharList)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharLoaded(id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharMenuClosed()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharMenuOpened(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharPostSave(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharPreSave(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CharRestored(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ChatAddText(markup, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ChatParsed(client, chatType, message, anonymous)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ChatboxPanelCreated(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ChatboxTextAdded(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CheckFactionLimitReached(faction, character, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ChooseCharacter(id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CommandAdded(command, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CommandRan(client, command, arg3, results)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ConfigChanged(key, value, oldValue, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ConfigUpdated(key)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ConfigureCharacterCreationSteps(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateCharacter(data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateChat()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateDefaultInventory(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateInformationButtons(pages)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateInventoryPanel(inventory, parent)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateMenuButtons(tabs)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CreateSalaryTimers()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CustomClassValidation(client, newClass)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function CustomLogHandler(message, category)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DatabaseConnected()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DeleteCharacter(id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DermaSkinChanged(newSkin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DiscordRelaySend(embed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DiscordRelayUnavailable()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DiscordRelayed(embed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoModuleIncludes(path, MODULE)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorEnabledToggled(client, door, newState)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorHiddenToggled(client, entity, newState)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorLockToggled(client, door, state)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorOwnableToggled(client, door, newState)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorPriceSet(client, door, price)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DoorTitleSet(client, door, name)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DrawCharInfo(client, character, info)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DrawDoorInfoBox(entity, infoTexts, alphaOverride)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DrawEntityInfo(entity, alpha, position)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DrawLiliaModelView(self, ent)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function DrawPlayerRagdoll(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ExitStorage()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function F1MenuClosed()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function F1MenuOpened(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function FetchSpawns()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function FilterCharModels(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function FilterDoorInfo(entity, doorData, doorInfo)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ForceRecognizeRange(ply, range, fakeName)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetAdjustedPartData(wearer, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetAllCaseClaims()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetAttributeMax(target, attrKey)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetAttributeStartingMax(client, k)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetCharMaxStamina(char)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDamageScale(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDefaultCharDesc(client, factionIndex, context)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDefaultCharName(client, factionIndex, context)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDefaultInventorySize(client, char)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDefaultInventoryType(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDisplayedDescription(ply, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDisplayedName(speaker, chatType)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDoorInfo(entity, doorData, doorInfo)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetDoorInfoForAdminStick(target, extraInfo)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetEntitySaveData(ent)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetHandsAttackSpeed(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetInjuredText(c)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetItemDropModel(itemTable, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetItemStackKey(item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetItemStacks(inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetMainMenuPosition(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetMaxPlayerChar(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetMaxSkillPoints(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetMaxStartingAttributePoints(client, count)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetModelGender(model)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetMoneyModel(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetOOCDelay(speaker)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPlayTime(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPlayerDeathSound(_, isFemale)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPlayerPainSound(_, paintype, isFemale)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPlayerPunchDamage(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPlayerPunchRagdollTime(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetPriceOverride(self, uniqueID, price, isSellingToVendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetRagdollTime(self, time)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetSalaryAmount(client, faction, class)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetTicketsByRequester(steamID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetVendorSaleScale(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetWarnings(charID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetWarningsByIssuer(steamID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function GetWeaponName(weapon)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function HUDVisibilityChanged(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function HandleItemTransferRequest(client, itemID, x, y, invID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializeStorage(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedConfig()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedItems()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedKeybinds()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedModules()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedOptions()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InitializedSchema()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InteractionMenuClosed()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InteractionMenuOpened(frame)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InterceptClickItemIcon(self, itemIcon, keyCode)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryClosed(self, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryDataChanged(instance, key, oldValue, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryDeleted(instance)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryInitialized(instance)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryItemAdded(inventory, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryItemDataChanged(item, key, _, _, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryItemIconCreated(icon, item, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryItemRemoved(self, instance, preserveItem)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryOpened(panel, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function InventoryPanelCreated(panel, inventory, parent)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function IsCharFakeRecognized(self, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function IsCharRecognized(self, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function IsRecognizedChatType(chatType)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function IsSuitableForTrunk(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function IsValid()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemCombine(client, item, target)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemDataChanged(item, key, oldValue, newValue)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemDefaultFunctions(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemDeleted(instance)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemDraggedOutOfInventory(client, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemFunctionCalled(self, method, client, entity, results)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemInitialized(item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemPaintOver(self, itemTable, w, h)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemQuantityChanged(item, oldValue, quantity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemShowEntityMenu(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ItemTransfered(context)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function KeyLock(owner, entity, time)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function KeyUnlock(owner, entity, time)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function KeybindsLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function KickedFromChar(id, isCurrentChar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function LiliaLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function LiliaTablesLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function LoadCharInformation()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function LoadData()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function LoadMainMenuInformation(info, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ModifyCharacterModel(arg1, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ModifyScoreboardModel(arg1, ply)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function NetVarChanged(arg1, key, oldValue, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnAdminStickMenuClosed()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnAdminSystemLoaded(groups, privileges)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnBackupCreated(metadata)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharAttribBoosted(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharAttribUpdated(client, self, key, arg4)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharCreated(client, character, originalData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharDelete(client, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharDisconnect(client, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharFallover(self, arg2, arg3)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharFlagsGiven(ply, self, addedFlags)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharFlagsTaken(ply, self, removedFlags)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharGetup(target, entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharKick(self, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharNetVarChanged(character, key, oldVar, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharPermakilled(self, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharRecognized(client, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharTradeVendor(client, vendor, item, isSellingToVendor, _, _, isFailed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharVarChanged(character, varName, oldVar, newVar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterCreated(character, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterDeath(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterDeleted(charID, charName, owner, admin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterFieldsUpdated()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterLoaded(character, client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterRevive(character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterSchemaValidated(validationResults)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharacterUpdated(charID, updateData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCharactersRestored(client, characters, stats)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnChatReceived(client, chatType, text, anonymous)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCheaterCaught(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCheaterStatusChanged(client, target, arg3)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnColumnAdded(arg1, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnColumnRemoved(tableName, columnName, snapshot)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnConfigUpdated(key, oldValue, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCreateItemInteractionMenu(self, menu, itemTable)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCreatePlayerRagdoll(self, entity, isDead)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnCreateStoragePanel(localInvPanel, storageInvPanel, storage)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDataSet(key, value, gamemode, map)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDatabaseConnected()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDatabaseInitialized()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDatabaseLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDatabaseReset()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDatabaseWiped()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnDeathSoundPlayed(client, deathSound)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnEntityLoaded(createdEnt, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnEntityPersistUpdated(ent, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnEntityPersisted(ent, entData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnFontsRefreshed()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnItemAdded(owner, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnItemCreated(itemTable, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnItemRegistered(ITEM)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnItemSpawned(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnItemsTransferred(fromChar, toChar, items)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnLoadTables()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnModuleTableCreated(moduleName, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnModuleTableRemoved(moduleName)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnOOCMessageSent(client, message)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnOpenVendorMenu(self, vendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPAC3PartTransfered(part)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPainSoundPlayed(client, painSound)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPickupMoney(client, moneyEntity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerDataSynced(player, lastID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerDropWeapon(_, _, entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerEnterSequence(self, sequenceName, callback, time, noFreeze)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerInteractItem(client, action, self, result, data)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerJoinClass(client, class, oldClass)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerLeaveSequence(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerLevelUp(player, oldValue, newValue)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerLostStackItem(itemTypeOrItem)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerObserve(client, state)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerPurchaseDoor(client, door, arg3)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerRagdollCreated(player, ragdoll)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerStatsTableCreated()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerSwitchClass(client, class, oldClass)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPlayerXPGain(player, gained, arg3)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPrivilegeRegistered(arg1, arg2, arg3, arg4)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnPrivilegeUnregistered(arg1, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnQuestItemLoaded(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnRecordUpserted(dbTable, data, action)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnRequestItemTransfer(self, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnRestoreCompleted(restoreLog)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnRestoreFailed(failedLog)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnSalaryAdjust(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnSalaryGiven(client, char, pay, faction, class)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnSavedItemLoaded(loadedItems)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnServerLog(client, logType, logString, category)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnSkillsChanged(character, oldValue, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTableBackedUp(tableName, snapshot)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTableRemoved(tableName, snapshot)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTableRestored(arg1, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTablesReady()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnThemeChanged(themeName, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTicketClaimed(client, requester, ticketMessage)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTicketClosed(client, requester, ticketMessage)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTicketCreated(noob, message)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTransferFailed(fromChar, toChar, items, err)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnTransferred(targetPlayer)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnUsergroupCreated(groupName, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnUsergroupPermissionsChanged(groupName, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnUsergroupRemoved(groupName)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnUsergroupRenamed(oldName, newName)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnVendorEdited(client, vendor, key)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OnlineStaffDataReceived(staffData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OpenAdminStickUI(tgt)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OptionChanged(key, old, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OptionReceived(arg1, key, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OverrideFactionDesc(uniqueID, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OverrideFactionModels(uniqueID, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OverrideFactionName(uniqueID, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function OverrideSpawnTime(client, respawnTime)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PaintItem(item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerAccessVendor(activator, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerCheatDetected(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerDisconnect(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerGagged(target, admin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerLiliaDataLoaded(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerMessageSend(speaker, chatType, text, anonymous, receivers)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerModelChanged(client, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerMuted(target, admin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerShouldAct()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerShouldPermaKill(client, inflictor, attacker)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerSpawnPointSelected(client, pos, ang)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerStaminaDepleted(player)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerStaminaGained(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerStaminaLost(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerThrowPunch(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerUngagged(target, admin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerUnmuted(target, admin)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PlayerUseDoor(client, door)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PopulateAdminStick(tempMenu, tgt)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PopulateAdminTabs(adminPages)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PopulateConfigurationButtons(pages)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PopulateInventoryItems(pnlContent, tree)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostDoorDataLoad(ent, doorData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostDrawInventory(mainPanel, parentPanel)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostLoadData()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostLoadFonts(mainFont, configuredFont)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostPlayerInitialSpawn(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostPlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostPlayerLoadout(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostPlayerSay(client, message, chatType, anonymous)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PostScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreCharDelete(id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreDoorDataSave(door, doorData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreDrawPhysgunBeam()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreLiliaLoaded()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PrePlayerInteractItem(client, action, self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PrePlayerLoadedChar(client, character, currentChar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreSalaryGive(client, char, pay, faction, class)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function PreScaleDamage(hitgroup, dmgInfo, damageScale)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function RefreshFonts()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function RegisterPreparedStatements()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function RemovePart(client, id)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function RemoveWarning(charID, index)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ResetCharacterPanel()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function RunAdminSystemCommand(cmd, _, victim, dur, reason)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SaveData()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ScoreboardClosed(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ScoreboardOpened(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ScoreboardRowCreated(slot, ply)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ScoreboardRowRemoved(self, ply)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SendPopup(noob, message)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupBagInventoryAccessRules(inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupBotPlayer(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupDatabase()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupPACDataFromItems()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupPlayerModel(arg1, character)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SetupQuickMenu(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldAllowScoreboardOverride(ply, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldBarDraw(bar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDataBeSaved()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDeleteSavedItems()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDisableThirdperson(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDrawAmmo(wpn)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDrawEntityInfo(e)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDrawPlayerInfo(e)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldDrawWepSelect(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldHideBars()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldMenuButtonShow(arg1)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldPlayDeathSound(client, deathSound)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldPlayPainSound(client, painSound)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldRespawnScreenAppear()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldShowClassOnScoreboard(clsData)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldShowFactionOnScoreboard(ply)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldShowPlayerOnScoreboard(ply)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShouldSpawnClientRagdoll(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ShowPlayerOptions(ply, initialOpts)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageCanTransferItem(client, storage, item)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageEntityRemoved(self, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageInventorySet(self, inventory, arg3)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageItemRemoved()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageOpen(storage, isCar)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageRestored(ent, inventory)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StorageUnlockPrompt(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function StoreSpawns(spawns)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function SyncCharList(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ThirdPersonToggled(newValue)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TicketFrame(requester, message, claimed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TicketSystemClaim(client, requester, ticketMessage)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TicketSystemClose(client, requester, ticketMessage)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TicketSystemCreated(noob, message)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function ToggleLock(client, door, state)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TooltipInitialize(self, panel)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TooltipLayout(self)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TooltipPaint(self, w, h)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TransferItem(itemID)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function TryViewModel(entity)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function UpdateEntityPersistence(ent)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function UpdateScoreboardColors(teamColors)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorClassUpdated(vendor, id, allowed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorEdited(liaVendorEnt, key)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorExited()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorFactionUpdated(vendor, id, allowed)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorItemMaxStockUpdated(vendor, itemType, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorItemModeUpdated(vendor, itemType, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorItemPriceUpdated(vendor, itemType, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorItemStockUpdated(vendor, itemType, value)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorOpened(vendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorSynchronized(vendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VendorTradeEvent(client, vendor, itemType, isSellingToVendor)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function VoiceToggled(enabled)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WarningIssued(client, target, reason, count, warnerSteamID, arg6)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WarningRemoved(client, targetClient, arg3, arg4, arg5, arg6)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WeaponCycleSound()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WeaponSelectSound()
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WebImageDownloaded(n, arg2)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function WebSoundDownloaded(name, path)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function calcStaminaChange(client)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function getData(default)
end

--[[
    Purpose: Loads attribute definitions from a specified directory and registers them in the attributes system
    When Called: During gamemode initialization or when loading attribute modules
    Parameters: directory (string) - The directory path to search for attribute files
    Returns: None (modifies lia.attribs.list)
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
--
function setData(value, global, ignoreMap)
end