--[[
    Character Library

    Comprehensive character creation, management, and persistence system for the Lilia framework.
]]
--[[
    Overview:
        The character library provides comprehensive functionality for managing player characters in the Lilia framework. It handles character creation, loading, saving, and management across both server and client sides. The library operates character data persistence, networking synchronization, and provides hooks for character variable changes. It includes functions for character validation, database operations, inventory management, and character lifecycle management. The library ensures proper character data integrity and provides a robust system for character-based gameplay mechanics including factions, attributes, money, and custom character variables.
]]
lia.char = lia.char or {}
lia.char.vars = lia.char.vars or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.pendingRequests = lia.char.pendingRequests or {}
--[[
    Purpose:
        Retrieves a character by its ID, loading it if necessary

    When Called:
        When a character needs to be accessed by ID, either from server or client

    Parameters:
        - charID (number): The unique identifier of the character
        - client (Player): The player requesting the character (optional)
        - callback (function): Function to call when character is loaded (optional)

    Returns:
        Character object if found/loaded, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get a character by ID
        local character = lia.char.getCharacter(123)
        if character then
            print("Character name:", character:getName())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get character with callback for async loading
        lia.char.getCharacter(123, client, function(character)
            if character then
                character:setMoney(1000)
                print("Character loaded:", character:getName())
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Get multiple characters with validation and error handling
        local charIDs = {123, 456, 789}
        local loadedChars = {}

        for _, charID in ipairs(charIDs) do
            lia.char.getCharacter(charID, client, function(character)
                if character then
                    loadedChars[charID] = character
                    if table.Count(loadedChars) == #charIDs then
                        print("All characters loaded successfully")
                    end
                else
                    print("Failed to load character:", charID)
                end
            end)
        end
        ```
]]
function lia.char.getCharacter(charID, client, callback)
    if SERVER then
        local character = lia.char.loaded[charID]
        if character then
            if callback then callback(character) end
            return character
        end

        lia.char.loadSingleCharacter(charID, client, callback)
    else
        if not charID then return end
        local character = lia.char.loaded[charID]
        if character then
            if callback then callback(character) end
            return character
        end

        if callback then lia.char.pendingRequests[charID] = callback end
        net.Start("liaCharRequest")
        net.WriteUInt(charID, 32)
        net.SendToServer()
    end
end

--[[
    Purpose:
        Retrieves all currently loaded characters from all players

    When Called:
        When you need to iterate through all active characters on the server

    Parameters:
        None

    Returns:
        Table with Player objects as keys and their Character objects as values

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get all characters and count them
        local allChars = lia.char.getAll()
        print("Total active characters:", table.Count(allChars))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Find characters by faction
        local allChars = lia.char.getAll()
        local citizenChars = {}

        for player, character in pairs(allChars) do
            if character:getFaction() == "Citizen" then
                citizenChars[player] = character
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Process all characters with validation and statistics
        local allChars = lia.char.getAll()
        local stats = {
            totalChars = 0,
            totalMoney = 0,
            factions  = {}
        }

        for player, character in pairs(allChars) do
            if IsValid(player) and character then
                stats.totalChars = stats.totalChars + 1
                stats.totalMoney = stats.totalMoney + character:getMoney()

                local faction = character:getFaction()
                stats.factions[faction] = (stats.factions[faction] or 0) + 1
            end
        end
        ```
]]
function lia.char.getAll()
    local charTable = {}
    for _, client in player.Iterator() do
        if client:getChar() then charTable[client] = client:getChar() end
    end
    return charTable
end

--[[
    Purpose:
        Checks if a character with the given ID is currently loaded in memory

    When Called:
        Before attempting to access a character to avoid unnecessary loading

    Parameters:
        - charID (number): The unique identifier of the character to check

    Returns:
        Boolean - true if character is loaded, false otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if character is loaded
        if lia.char.isLoaded(123) then
            print("Character 123 is loaded")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Conditional character access
        local charID = 123
        if lia.char.isLoaded(charID) then
            local character = lia.char.getCharacter(charID)
            character:setMoney(5000)
        else
            print("Character not loaded, loading...")
            lia.char.getCharacter(charID, client, function(char)
                if char then char:setMoney(5000) end
            end)
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch character loading with status checking
        local charIDs = {123, 456, 789}
        local loadedChars = {}
        local unloadedChars = {}

        for _, charID in ipairs(charIDs) do
            if lia.char.isLoaded(charID) then
                loadedChars[charID] = lia.char.getCharacter(charID)
            else
                table.insert(unloadedChars, charID)
            end
        end

        print("Loaded:", table.Count(loadedChars), "Unloaded:", #unloadedChars)
        ```
]]
function lia.char.isLoaded(charID)
    return lia.char.loaded[charID] ~= nil
end

--[[
    Purpose:
        Adds a character to the loaded characters cache and triggers pending callbacks

    When Called:
        When a character is loaded from database or created, to make it available in memory

    Parameters:
        - id (number): The unique identifier of the character
        - character (Character): The character object to add to cache

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Add a character to cache
        local character = lia.char.new(charData, 123, client)
        lia.char.addCharacter(123, character)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Add character and handle pending requests
        local charID = 123
        local character = lia.char.new(charData, charID, client)

        -- This will trigger any pending callbacks for this character ID
        lia.char.addCharacter(charID, character)

        -- Check if there were pending requests
        if lia.char.pendingRequests[charID] then
            print("Character had pending requests that were triggered")
        end
        ```

        High Complexity:
        ```lua
        -- High: Batch character loading with callback management
        local characters = {}
        local charIDs = {123, 456, 789}

        for _, charID in ipairs(charIDs) do
            local charData = lia.char.getCharData(charID)
            if charData then
                local character = lia.char.new(charData, charID, client)
                characters[charID] = character
                lia.char.addCharacter(charID, character)
            end
        end

        print("Loaded", table.Count(characters), "characters into cache")
        ```
]]
function lia.char.addCharacter(id, character)
    lia.char.loaded[id] = character
    if lia.char.pendingRequests and lia.char.pendingRequests[id] then
        lia.char.pendingRequests[id](character)
        lia.char.pendingRequests[id] = nil
    end
end

--[[
    Purpose:
        Removes a character from the loaded characters cache

    When Called:
        When a character needs to be unloaded from memory (cleanup, deletion, etc.)

    Parameters:
        - id (number): The unique identifier of the character to remove

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Remove character from cache
        lia.char.removeCharacter(123)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Remove character with validation
        local charID = 123
        if lia.char.isLoaded(charID) then
            local character = lia.char.getCharacter(charID)
            if character then
                character:save() -- Save before removing
                lia.char.removeCharacter(charID)
                print("Character", charID, "removed from cache")
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Batch character cleanup with error handling
        local charIDs = {123, 456, 789}
        local removedCount = 0

        for _, charID in ipairs(charIDs) do
            if lia.char.isLoaded(charID) then
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Perform cleanup operations
                    character:save()
                    lia.inventory.cleanUpForCharacter(character)
                    lia.char.removeCharacter(charID)
                    removedCount = removedCount + 1
                end
            end
        end

        print("Removed", removedCount, "characters from cache")
        ```
]]
function lia.char.removeCharacter(id)
    lia.char.loaded[id] = nil
end

--[[
    Purpose:
        Creates a new character object from data with proper metatable and variable initialization

    When Called:
        When creating a new character instance from database data or character creation

    Parameters:
        - data (table): Character data containing all character variables
        - id (number): The unique identifier for the character (optional)
        - client (Player): The player who owns this character (optional)
        - steamID (string): Steam ID of the character owner (optional, used when client is invalid)

    Returns:
        Character object with proper metatable and initialized variables

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create a basic character
        local charData = {
            name    = "John Doe",
            desc    = "A citizen of the city",
            faction = "Citizen",
            model   = "models/player/Group01/male_01.mdl"
        }
        local character = lia.char.new(charData, 123, client)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create character with full data and validation
        local charData = {
            name    = "Jane Smith",
            desc    = "A skilled engineer",
            faction = "Engineer",
            model   = "models/player/Group01/female_01.mdl",
            money   = 1000,
            attribs = {strength = 5, intelligence = 8}
        }

        local character = lia.char.new(charData, 456, client)
        if character then
            character:setSkin(1)
            character:setBodygroups({[0] = 1, [1] = 2})
        end
        ```

    High Complexity:
        ```lua
        -- High: Create character from database with error handling
        local charID = 789
        local charData = lia.char.getCharData(charID)

        if charData then
            -- Validate required fields
            if not charData.name or not charData.faction then
                print("Invalid character data for ID:", charID)
                return
            end

            -- Create character with fallback SteamID
            local steamID = client and client:SteamID() or "STEAM_0:0:0"
            local character = lia.char.new(charData, charID, client, steamID)

            if character then
                -- Initialize additional data
                character.vars.inv = {}
                character.vars.loginTime = os.time()
                lia.char.addCharacter(charID, character)
            end
        end
        ```
]]
function lia.char.new(data, id, client, steamID)
    local character = setmetatable({
        vars = {}
    }, lia.meta.character)

    for k, v in pairs(lia.char.vars) do
        local value = data[k]
        if value == nil then
            value = v.default
            if istable(value) then value = table.Copy(value) end
        end

        character.vars[k] = value
    end

    character.id = id or 0
    character.player = client
    if IsValid(client) or steamID then
        if IsValid(client) and isfunction(client.SteamID) then
            character.steamID = client:SteamID()
        else
            character.steamID = steamID
        end
    end
    return character
end

--[[
    Purpose:
        Registers a hook function for a specific character variable

    When Called:
        When you need to add custom behavior when a character variable changes

    Parameters:
        - varName (string): The name of the character variable to hook
        - hookName (string): The name/identifier for this hook
        - func (function): The function to call when the variable changes

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Hook a variable change
        lia.char.hookVar("money", "onMoneyChange", function(character, oldValue, newValue)
            print("Money changed from", oldValue, "to", newValue)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Hook with validation and side effects
        lia.char.hookVar("faction", "onFactionChange", function(character, oldValue, newValue)
            local client = character:getPlayer()
            if IsValid(client) then
                -- Update player team
                client:SetTeam(lia.faction.indices[newValue].index)

                -- Notify player
                client:notify("Faction changed to: " .. newValue)

                -- Log the change
                lia.log.add("Faction change: " .. client:Name() .. " changed faction from " .. oldValue .. " to " .. newValue)
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Multiple hooks with complex logic
        local hooks = {
            money = function(character, oldValue, newValue)
                local client = character:getPlayer()
                if IsValid(client) then
                    local difference = newValue - oldValue
                    if difference > 0 then
                        client:notify("Gained $" .. difference)
                    elseif difference < 0 then
                        client:notify("Lost $" .. math.abs(difference))
                    end

                    -- Update HUD if it exists
                    if client.liaHUD then
                        client.liaHUD:updateMoney(newValue)
                    end
                end
            end,

            health = function(character, oldValue, newValue)
                if newValue <= 0 and oldValue > 0 then
                    hook.Run("OnCharacterDeath", character)
                elseif newValue > 0 and oldValue <= 0 then
                    hook.Run("OnCharacterRevive", character)
                end
            end
        }

        for varName, hookFunc in pairs(hooks) do
            lia.char.hookVar(varName, "customHook_" .. varName, hookFunc)
        end
        ```
]]
function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

--[[
    Purpose:
        Registers a new character variable with validation, networking, and database persistence

    When Called:
        During gamemode initialization to define character variables and their behavior

    Parameters:
        - key (string): The unique identifier for the character variable
        - data (table): Configuration table containing variable properties and callbacks

    Returns:
        None

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register a basic character variable
        lia.char.registerVar("level", {
            field     = "level",
            fieldType = "integer",
            default   = 1,
            index     = 5
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register variable with validation and custom behavior
        lia.char.registerVar("reputation", {
            field     = "reputation",
            fieldType = "integer",
            default   = 0,
            index     = 6,
            onValidate = function(value, data, client)
                if not isnumber(value) or value < -100 or value > 100 then
                    return false, "invalid", "reputation"
                end
                return true
            end,
            onSet = function(character, value)
                local oldValue = character:getReputation()
                character.vars.reputation = value

                -- Notify player of reputation change
                local client = character:getPlayer()
                if IsValid(client) then
                    client:notify("Reputation changed to: " .. value)
                end

                hook.Run("OnCharVarChanged", character, "reputation", oldValue, value)
            end
        })
        ```

    High Complexity:
        ```lua
        -- High: Register complex variable with full feature set
        lia.char.registerVar("skills", {
            field     = "skills",
            fieldType = "text",
            default   = {},
            index     = 7,
            isLocal   = true,
            onValidate = function(value, data, client)
                if not istable(value) then return false, "invalid", "skills" end

                local totalPoints = 0
                for skillName, level in pairs(value) do
                    if not isnumber(level) or level < 0 or level > 100 then
                        return false, "invalid", "skillLevel"
                    end
                    totalPoints = totalPoints + level
                end

                local maxPoints = hook.Run("GetMaxSkillPoints", client) or 500
                if totalPoints > maxPoints then
                    return false, "tooManySkillPoints"
                end

                return true
            end,
            onSet = function(character, value)
                local oldValue = character:getSkills()
                character.vars.skills = value

                -- Recalculate derived stats
                local client = character:getPlayer()
                if IsValid(client) then
                    hook.Run("OnSkillsChanged", character, oldValue, value)
                end
            end,
            onGet = function(character, default)
                return character.vars.skills or default or {}
            end,
            shouldDisplay = function()
                return lia.config.get("EnableSkills", true)
            end
        })
        ```
]]
function lia.char.registerVar(key, data)
    lia.char.vars[key] = data
    data.index = data.index or table.Count(lia.char.vars)
    local upperName = key:sub(1, 1):upper() .. key:sub(2)
    if SERVER and not data.isNotModifiable then
        if data.onSet then
            lia.meta.character["set" .. upperName] = data.onSet
        elseif data.noNetworking then
            lia.meta.character["set" .. upperName] = function(self, value) self.vars[key] = value end
        elseif data.isLocal then
            lia.meta.character["set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true
                if curChar and curChar == self then sendID = false end
                local oldVar = self.vars[key]
                self.vars[key] = value
                local ply = self:getPlayer()
                if ply and IsValid(ply) and ply:IsPlayer() then
                    net.Start("liaCharSet")
                    net.WriteString(key)
                    net.WriteType(value)
                    net.WriteType(sendID and self:getID() or nil)
                    net.Send(ply)
                end

                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        else
            lia.meta.character["set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                net.Start("liaCharSet")
                net.WriteString(key)
                net.WriteType(value)
                net.WriteType(self:getID())
                net.Broadcast()
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        end
    end

    if data.onGet then
        lia.meta.character["get" .. upperName] = data.onGet
    else
        lia.meta.character["get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end
            return default
        end
    end

    lia.meta.character.vars[key] = data.default
end

lia.char.registerVar("name", {
    field = "name",
    fieldType = "string",
    default = L("defaultCharName"),
    index = 1,
    onValidate = function(value, data, client)
        local name, override = hook.Run("GetDefaultCharName", client, data.faction, data)
        if isstring(name) and override then return true end
        if not isstring(value) or not value:find("%S") then return false, "invalid", "name" end
        return true
    end,
    onAdjust = function(client, data, value, newData)
        local name, override = hook.Run("GetDefaultCharName", client, data.faction, data)
        local info = lia.faction.indices[data.faction]
        local prefix = info and (isfunction(info.prefix) and info.prefix(client) or info.prefix) or ""
        if isstring(name) and override then
            if prefix ~= "" then
                newData.name = string.Trim(prefix .. " " .. name)
            else
                newData.name = name
            end
        else
            local trimmed = string.Trim(value):sub(1, 70)
            if prefix ~= "" then
                newData.name = string.Trim(prefix .. " " .. trimmed)
            else
                newData.name = trimmed
            end
        end
    end,
})

lia.char.registerVar("desc", {
    field = "desc",
    fieldType = "text",
    default = L("descMinLen", lia.config.get("MinDescLen", 16)),
    index = 2,
    onValidate = function(value, data, client)
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction, data)
        local minLength = lia.config.get("MinDescLen", 16)
        if isstring(desc) and override then return true end
        if not value or #string.Trim(value) < minLength then return false, "descMinLen", minLength end
        return true
    end,
    onAdjust = function(client, data, value, newData)
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction, data)
        if isstring(desc) and override then
            newData.desc = desc
        else
            newData.desc = value
        end
    end,
})

lia.char.registerVar("model", {
    field = "model",
    fieldType = "string",
    default = "models/error.mdl",
    onSet = function(character, value)
        local oldVar = character:getModel()
        local client = character:getPlayer()
        if IsValid(client) and client:getChar() == character then client:SetModel(value) end
        character.vars.model = value
        net.Start("liaCharSet")
        net.WriteString("model")
        net.WriteType(character.vars.model)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("PlayerModelChanged", client, value)
        hook.Run("OnCharVarChanged", character, "model", oldVar, value)
    end,
    onGet = function(character, default) return character.vars.model or default end,
    index = 3,
    onValidate = function(_, data, client)
        local faction = lia.faction.indices[data.faction]
        if faction then
            if not data.model or not faction.models[data.model] then
                if data.faction == FACTION_STAFF and client and client:hasPrivilege("createStaffCharacter") then return true end
                return false, "needModel"
            end
        else
            return false, "needModel"
        end
    end,
    onAdjust = function(_, data, value, newData)
        local faction = lia.faction.indices[data.faction]
        if faction then
            local model = faction.models[value]
            if isstring(model) then
                newData.model = model
            elseif istable(model) then
                newData.model = model[1]
                newData.skin = model[2] or 0
                local groups = {}
                if isstring(model[3]) then
                    local i = 0
                    for digit in model[3]:gmatch("%d") do
                        groups[i] = tonumber(digit)
                        i = i + 1
                    end
                elseif istable(model[3]) then
                    for groupIndex, groupValue in pairs(model[3]) do
                        groups[tonumber(groupIndex)] = tonumber(groupValue)
                    end
                end

                newData.bodygroups = groups
            end
        end
    end
})

lia.char.registerVar("skin", {
    field = "skin",
    fieldType = "integer",
    default = 0,
    onSet = function(character, value)
        local oldVar = character:getSkin()
        character.vars.skin = value
        local client = character:getPlayer()
        if IsValid(client) and client:getChar() == character then client:SetSkin(value) end
        net.Start("liaCharSet")
        net.WriteString("skin")
        net.WriteType(character.vars.skin)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", character, "skin", oldVar, value)
    end,
    onGet = function(character, default) return character.vars.skin or default or 0 end,
    noDisplay = true
})

lia.char.registerVar("bodygroups", {
    field = "bodygroups",
    fieldType = "text",
    default = {},
    onSet = function(character, value)
        local oldVar = character:getBodygroups()
        character.vars.bodygroups = value
        local client = character:getPlayer()
        if IsValid(client) and client:getChar() == character then
            for k, v in pairs(value or {}) do
                local index = tonumber(k)
                if index then client:SetBodygroup(index, v or 0) end
            end
        end

        net.Start("liaCharSet")
        net.WriteString("bodygroups")
        net.WriteType(character.vars.bodygroups)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", character, "bodygroups", oldVar, value)
    end,
    onGet = function(character, default) return character.vars.bodygroups or default or {} end,
    noDisplay = true
})

lia.char.registerVar("class", {
    field = "class",
    fieldType = "integer",
    default = 0,
    noDisplay = true,
})

lia.char.registerVar("faction", {
    field = "faction",
    fieldType = "string",
    default = "Citizen",
    onSet = function(character, value)
        local oldVar = character:getFaction()
        local faction = lia.faction.indices[value]
        assert(faction, L("invalidFactionIndex", tostring(value)))
        local client = character:getPlayer()
        client:SetTeam(value)
        character.vars.faction = faction.uniqueID
        net.Start("liaCharSet")
        net.WriteString("faction")
        net.WriteType(character.vars.faction)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", character, "faction", oldVar, value)
        return true
    end,
    onGet = function(character, default)
        local faction = lia.faction.teams[character.vars.faction]
        return faction and faction.index or default or 0
    end,
    onValidate = function(value, _, client)
        if not lia.faction.indices[value] then return false, "invalid", "faction" end
        if value == FACTION_STAFF then
            if not client or not client:hasPrivilege("createStaffCharacter") then return false, "staffFactionRestricted" end
            return true
        end

        if not client:hasWhitelist(value) then return false, "illegalAccess" end
        return true
    end,
    onAdjust = function(_, _, value, newData) newData.faction = lia.faction.indices[value].uniqueID end
})

lia.char.registerVar("money", {
    field = "money",
    fieldType = "integer",
    default = 0,
    isLocal = true,
    noDisplay = true
})

lia.char.registerVar("flags", {
    field = "charflags",
    fieldType = "string",
    default = "",
    noDisplay = true
})

lia.char.registerVar("loginTime", {
    field = "logintime",
    fieldType = "integer",
    default = 0,
    isLocal = true,
    noDisplay = true
})

lia.char.registerVar("playTime", {
    field = "playtime",
    fieldType = "integer",
    default = 0,
    noDisplay = true
})

lia.char.registerVar("var", {
    default = {},
    noDisplay = true,
    onSet = function(character, key, value, noReplication, receiver)
        local data = character:getVar()
        local client = character:getPlayer()
        data[key] = value
        if not noReplication and IsValid(client) then
            local id
            if client:getChar() and client:getChar():getID() == character:getID() then
                id = client:getChar():getID()
            else
                id = character:getID()
            end

            net.Start("liaCharVar")
            net.WriteString(key)
            net.WriteType(value)
            net.WriteType(id)
            if receiver then
                net.Send(receiver)
            else
                net.Send(client)
            end
        end

        character.vars.vars = data
    end,
    onGet = function(character, key, default)
        character.vars.vars = character.vars.vars or {}
        local data = character.vars.vars or {}
        if key then
            if not data then return default end
            local value = data[key]
            return value == nil and default or value
        else
            return default or data
        end
    end
})

lia.char.registerVar("inv", {
    noNetworking = true,
    noDisplay = true,
    onGet = function(character, index)
        if index and not isnumber(index) then return character.vars.inv or {} end
        return character.vars.inv and character.vars.inv[index or 1]
    end,
    onSync = function(character, recipient)
        net.Start("liaCharacterInvList")
        net.WriteUInt(character:getID(), 32)
        net.WriteUInt(#character.vars.inv, 32)
        for i = 1, #character.vars.inv do
            net.WriteType(character.vars.inv[i].id)
        end

        if recipient == nil then
            net.Broadcast()
        else
            net.Send(recipient)
        end
    end
})

lia.char.registerVar("attribs", {
    field = "attribs",
    fieldType = "text",
    default = {},
    isLocal = true,
    index = 4,
    onValidate = function(value, data, client)
        if data and data.faction == FACTION_STAFF and client and client:hasPrivilege("createStaffCharacter") then return true end
        if value ~= nil then
            if istable(value) then
                local count = 0
                for k, v in pairs(value) do
                    local max = hook.Run("GetAttributeStartingMax", client, k)
                    if max and v > max then return false, L("attribTooHigh", lia.attribs.list[k].name) end
                    count = count + v
                end

                local points = hook.Run("GetMaxStartingAttributePoints", client, count)
                if count > points then return false, "unknownError" end
            else
                return false, "unknownError"
            end
        end
    end,
    shouldDisplay = function()
        if table.Count(lia.attribs.list) > 1 then return true end
        return false
    end
})

lia.char.registerVar("recognition", {
    field = "recognition",
    fieldType = "text",
    default = "",
    noDisplay = true
})

lia.char.registerVar("FakeName", {
    field = "fakenames",
    fieldType = "text",
    default = {},
    noDisplay = true
})

lia.char.registerVar("lastPos", {
    field = "lastpos",
    fieldType = "text",
    default = {},
    noDisplay = true
})

lia.char.registerVar("ammo", {
    field = "ammo",
    fieldType = "text",
    default = {},
    noDisplay = true
})

lia.char.registerVar("classwhitelists", {
    field = "classwhitelists",
    fieldType = "text",
    default = {},
    noDisplay = true
})

lia.char.registerVar("markedForDeath", {
    field = "markedfordeath",
    fieldType = "boolean",
    default = false,
    noDisplay = true,
    noNetworking = true
})

lia.char.registerVar("banned", {
    field = "banned",
    fieldType = "integer",
    default = 0,
    noDisplay = true
})

--[[
    Purpose:
        Retrieves character data from the database with automatic decoding

    When Called:
        When you need to access character data directly from the database

    Parameters:
        - charID (number): The unique identifier of the character
        - key (string): Specific data key to retrieve (optional)

    Returns:
        Table of character data or specific value if key provided

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get all character data
        local charData = lia.char.getCharData(123)
        print("Character name:", charData.name)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get specific character data
        local charID = 123
        local characterName = lia.char.getCharData(charID, "name")
        local characterMoney = lia.char.getCharData(charID, "money")

        if characterName then
            print("Character", characterName, "has", characterMoney or 0, "money")
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch character data retrieval with validation
        local charIDs = {123, 456, 789}
        local charactersData = {}

        for _, charID in ipairs(charIDs) do
            local charData = lia.char.getCharData(charID)
            if charData and charData.name then
                charactersData[charID] = {
                    name      = charData.name,
                    faction   = charData.faction,
                    money     = charData.money or 0,
                    lastLogin = charData.lastJoinTime
                }
            end
        end

        print("Retrieved data for", table.Count(charactersData), "characters")
        ```
]]
function lia.char.getCharData(charID, key)
    local charIDsafe = tonumber(charID)
    if not charIDsafe then return end
    local results = sql.Query("SELECT key, value FROM lia_chardata WHERE charID = " .. charIDsafe)
    local data = {}
    if istable(results) then
        for _, row in ipairs(results) do
            local decoded = pon.decode(row.value)
            data[row.key] = decoded[1]
        end
    end

    if key then return data[key] end
    return data
end

--[[
    Purpose:
        Retrieves raw character data from database without automatic processing

    When Called:
        When you need unprocessed character data or want to handle decoding manually

    Parameters:
        - charID (number): The unique identifier of the character
        - key (string): Specific data key to retrieve (optional)

    Returns:
        Raw decoded data or specific value if key provided

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get raw character data
        local rawData = lia.char.getCharDataRaw(123)
        print("Raw data keys:", table.GetKeys(rawData))
        ```

    Medium Complexity:
        ```lua
        -- Medium: Get specific raw data with error handling
        local charID = 123
        local rawValue = lia.char.getCharDataRaw(charID, "customData")

        if rawValue ~= false then
            print("Custom data found:", rawValue)
        else
            print("No custom data found for character", charID)
        end
        ```

    High Complexity:
        ```lua
        -- High: Process multiple raw data entries
        local charID = 123
        local rawData = lia.char.getCharDataRaw(charID)
        local processedData = {}

        if rawData then
            for key, value in pairs(rawData) do
                -- Custom processing based on key type
                if key:find("^skill_") then
                    processedData[key] = tonumber(value) or 0
                elseif key:find("^item_") then
                    processedData[key] = istable(value) and value or {}
                else
                    processedData[key] = value
                end
            end

            return processedData
        end
        ```
]]
function lia.char.getCharDataRaw(charID, key)
    local charIDsafe = tonumber(charID)
    if not charIDsafe then return end
    if key then
        local row = sql.Query("SELECT value FROM lia_chardata WHERE charID = " .. charIDsafe .. " AND key = '" .. lia.db.escape(key) .. "'")
        if not row or not row[1] then return false end
        local decoded = pon.decode(row[1].value)
        return decoded[1]
    end

    local results = sql.Query("SELECT key, value FROM lia_chardata WHERE charID = " .. charIDsafe)
    local data = {}
    if istable(results) then
        for _, r in ipairs(results) do
            local decoded = pon.decode(r.value)
            data[r.key] = decoded[1]
        end
    end
    return data
end

--[[
    Purpose:
        Finds the player who owns a character with the given ID

    When Called:
        When you need to find which player is using a specific character

    Parameters:
        - ID (number): The unique identifier of the character

    Returns:
        Player object if found, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find character owner
        local owner = lia.char.getOwnerByID(123)
        if owner then
            print("Character 123 is owned by:", owner:Name())
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Find owner and perform action
        local charID = 123
        local owner = lia.char.getOwnerByID(charID)

        if IsValid(owner) then
            local character = owner:getChar()
            if character and character:getID() == charID then
                owner:notify("Your character has been updated!")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch owner lookup with validation
        local charIDs = {123, 456, 789}
        local owners = {}

        for _, charID in ipairs(charIDs) do
            local owner = lia.char.getOwnerByID(charID)
            if IsValid(owner) then
                owners[charID] = {
                    player    = owner,
                    name      = owner:Name(),
                    steamID   = owner:SteamID(),
                    character = owner:getChar()
                }
            end
        end

        print("Found owners for", table.Count(owners), "characters")
        ```
]]
function lia.char.getOwnerByID(ID)
    ID = tonumber(ID)
    for client, character in pairs(lia.char.getAll()) do
        if character and character:getID() == ID then return client end
    end
end

--[[
    Purpose:
        Finds a character by the Steam ID of its owner

    When Called:
        When you need to find a character using the player's Steam ID

    Parameters:
        - steamID (string): Steam ID of the character owner (supports both formats)

    Returns:
        Character object if found, nil otherwise

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Find character by Steam ID
        local character = lia.char.getBySteamID("STEAM_0:1:123456")
        if character then
            print("Found character:", character:getName())
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Find character with Steam ID conversion
        local steamID64 = "76561198000000000"
        local character = lia.char.getBySteamID(steamID64)

        if character then
            local owner = character:getPlayer()
            if IsValid(owner) then
                owner:notify("Character found and loaded")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch character lookup by Steam IDs
        local steamIDs = {"STEAM_0:1:123456", "76561198000000000", "STEAM_0:0:789012"}
        local foundCharacters = {}

        for _, steamID in ipairs(steamIDs) do
            local character = lia.char.getBySteamID(steamID)
            if character then
                local owner = character:getPlayer()
                foundCharacters[steamID] = {
                    character = character,
                    owner     = owner,
                    name      = character:getName(),
                    faction   = character:getFaction()
                }
            end
        end

        print("Found", table.Count(foundCharacters), "characters")
        ```
]]
function lia.char.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    local lookupID = steamID
    if string.match(steamID, "^%d+$") and #steamID >= 17 then lookupID = util.SteamIDFrom64(steamID) or steamID end
    for _, client in player.Iterator() do
        if client:SteamID() == lookupID and client:getChar() then return client:getChar() end
    end
end

--[[
    Purpose:
        Gets the team color for a player based on their character's class

    When Called:
        When you need to determine the appropriate color for a player's team/class

    Parameters:
        - client (Player): The player to get the team color for

    Returns:
        Color object representing the team/class color

    Realm:
        Shared

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get player team color
        local color = lia.char.getTeamColor(client)
        print("Team color:", color.r, color.g, color.b)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Use team color for UI elements
        local color = lia.char.getTeamColor(client)

        -- Set player name color in chat
        local nameColor = Color(color.r, color.g, color.b, 255)
        chat.AddText(nameColor, client:Name(), color_white, ": Hello!")
        ```

    High Complexity:
        ```lua
        -- High: Batch team color processing for UI
        local players = player.GetAll()
        local teamColors = {}

        for _, ply in ipairs(players) do
            if IsValid(ply) then
                local color = lia.char.getTeamColor(ply)
                local character = ply:getChar()

                teamColors[ply] = {
                    color     = color,
                    character = character,
                    faction   = character and character:getFaction() or "Unknown",
                    class     = character and character:getClass() or 0
                }
            end
        end

        -- Update scoreboard with team colors
        hook.Run("UpdateScoreboardColors", teamColors)
        ```
]]
function lia.char.getTeamColor(client)
    local char = client:getChar()
    if not char then return team.GetColor(client:Team()) end
    local classIndex = char:getClass()
    if not classIndex then return team.GetColor(client:Team()) end
    local classTbl = lia.class.list[classIndex]
    if not classTbl then return team.GetColor(client:Team()) end
    return classTbl.Color or team.GetColor(client:Team())
end

if SERVER then
    --[[
    Purpose:
        Creates a new character in the database and initializes it with default inventory

    When Called:
        When a player creates a new character through character creation

    Parameters:
        - data (table): Character data containing name, description, faction, model, etc.
        - callback (function): Function to call when character creation is complete

    Returns:
        None (uses callback for result)

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Create a basic character
        local charData = {
            name    = "John Doe",
            desc    = "A citizen of the city",
            faction = "Citizen",
            model   = "models/player/Group01/male_01.mdl",
            steamID = client:SteamID()
        }

        lia.char.create(charData, function(charID)
            print("Character created with ID:", charID)
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Create character with validation and inventory
        local charData = {
            name    = "Jane Smith",
            desc    = "A skilled engineer",
            faction = "Engineer",
            model   = "models/player/Group01/female_01.mdl",
            steamID = client:SteamID(),
            money   = 1000,
            attribs = {strength = 5, intelligence = 8}
        }

        lia.char.create(charData, function(charID)
            if charID then
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Add starting items
                    character:getInv(1):add("crowbar")
                    character:getInv(1):add("flashlight")
                    client:notify("Character created successfully!")
                end
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Create character with full validation and error handling
        local function createCharacterWithValidation(client, charData)
            -- Validate required fields
            if not charData.name or not charData.faction then
                client:notifyError("Missing required character data")
                return
            end

            -- Validate faction access
            if not client:hasWhitelist(charData.faction) then
                client:notifyError("You don't have access to this faction")
                return
            end

            -- Set default values
            charData.steamID = client:SteamID()
            charData.money = charData.money or lia.config.get("DefaultMoney", 1000)
            charData.createTime = os.date("%Y-%m-%d %H:%M:%S", os.time())

            lia.char.create(charData, function(charID)
                if charID then
                    local character = lia.char.getCharacter(charID)
                    if character then
                        -- Initialize character-specific data
                        character:setData("lastLogin", os.time())
                        character:setData("creationIP", client:IPAddress())

                        -- Add to player's character list
                        client.liaCharList = client.liaCharList or {}
                        table.insert(client.liaCharList, charID)

                        -- Notify success
                        client:notify("Character '" .. charData.name .. "' created successfully!")
                        hook.Run("OnCharacterCreated", character, client)
                    end
                else
                    client:notifyError("Failed to create character")
                end
            end)
        end
        ```
]]
    function lia.char.create(data, callback)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        data.money = data.money or lia.config.get("DefaultMoney")
        local gamemode = SCHEMA and SCHEMA.folder or "lilia"
        lia.db.insertTable({
            name = data.name or "",
            desc = data.desc or "",
            model = data.model or "models/error.mdl",
            schema = gamemode,
            createTime = timeStamp,
            lastJoinTime = timeStamp,
            steamID = data.steamID,
            faction = data.faction or L("unknown"),
            money = data.money,
            recognition = data.recognition or "",
            fakenames = ""
        }, function(_, charID)
            local client
            for _, v in player.Iterator() do
                if v:SteamID() == data.steamID then
                    client = v
                    break
                end
            end

            local character = lia.char.new(data, charID, client, data.steamID)
            character.vars.inv = {}
            hook.Run("CreateDefaultInventory", character):next(function(inventory)
                character.vars.inv[1] = inventory
                lia.char.loaded[charID] = character
                if istable(data.data) then
                    for k, v in pairs(data.data) do
                        lia.char.setCharDatabase(charID, k, v)
                    end
                end

                if callback then callback(charID) end
            end)
        end)
    end

    --[[
    Purpose:
        Restores/loads all characters for a player from the database

    When Called:
        When a player connects and needs their characters loaded

    Parameters:
        - client (Player): The player to restore characters for
        - callback (function): Function to call when restoration is complete
        - id (number): Specific character ID to restore (optional)

    Returns:
        None (uses callback for result)

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Restore all characters for player
        lia.char.restore(client, function(characters)
            print("Restored", #characters, "characters for", client:Name())
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Restore with character validation
        lia.char.restore(client, function(characters)
            if #characters > 0 then
                client.liaCharList = characters

                -- Validate each character
                for _, charID in ipairs(characters) do
                    local character = lia.char.getCharacter(charID)
                    if character then
                        -- Check if character is banned
                        if character:getBanned() > 0 then
                            print("Character", charID, "is banned")
                        end
                    end
                end

                client:notify("Characters loaded successfully!")
            else
                client:notify("No characters found")
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Restore with full error handling and statistics
        lia.char.restore(client, function(characters)
            local stats = {
                total   = #characters,
                loaded  = 0,
                banned  = 0,
                invalid = 0
            }

            client.liaCharList = characters

            for _, charID in ipairs(characters) do
                local character = lia.char.getCharacter(charID)
                if character then
                    stats.loaded = stats.loaded + 1

                    -- Check character status
                    if character:getBanned() > 0 then
                        stats.banned = stats.banned + 1
                    end

                    -- Validate character data
                    if not character:getName() or character:getName() == "" then
                        stats.invalid = stats.invalid + 1
                        print("Invalid character data for ID:", charID)
                    end
                end
            end

            -- Log statistics
            lia.log.add("Character restoration: " ..
                client:Name() .. " - Total: " .. stats.total ..
                ", Loaded: " .. stats.loaded ..
                ", Banned: " .. stats.banned ..
                ", Invalid: " .. stats.invalid
            )

            hook.Run("OnCharactersRestored", client, characters, stats)
        end)
        ```
]]
    function lia.char.restore(client, callback, id)
        local steamID = client:SteamID()
        local fields = {"id"}
        for _, var in pairs(lia.char.vars) do
            if var.field then fields[#fields + 1] = var.field end
        end

        fields = table.concat(fields, ", ")
        local gamemode = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
        local condition = "schema = '" .. lia.db.escape(gamemode) .. "' AND steamID = " .. lia.db.convertDataType(steamID)
        if id then condition = condition .. " AND id = " .. id end
        local query = "SELECT " .. fields .. " FROM lia_characters WHERE " .. condition
        lia.db.query(query, function(data)
            local characters = {}
            local results = data or {}
            local done = 0
            if #results == 0 then
                if callback then callback(characters) end
                return
            end

            for _, v in ipairs(results) do
                local charId = tonumber(v.id)
                if not charId then
                    lia.error(L("invalidCharacterID", data.name or "nil"))
                    continue
                end

                local charData = {}
                for k2, v2 in pairs(lia.char.vars) do
                    if v2.field and v[v2.field] then
                        local value = tostring(v[v2.field])
                        if isnumber(v2.default) then
                            value = tonumber(value) or v2.default
                        elseif isbool(v2.default) then
                            value = tobool(value)
                        elseif istable(v2.default) then
                            value = util.JSONToTable(value)
                        end

                        charData[k2] = value
                    end
                end

                if charData.data and charData.data.rgn then
                    charData.recognition = charData.data.rgn
                    charData.data.rgn = nil
                end

                if not lia.faction.teams[charData.faction] then
                    local defaultFaction
                    for _, fac in pairs(lia.faction.teams) do
                        if fac.isDefault then
                            defaultFaction = fac
                            break
                        end
                    end

                    if not defaultFaction then
                        local _, fac = next(lia.faction.teams)
                        defaultFaction = fac
                    end

                    if defaultFaction then
                        charData.faction = defaultFaction.uniqueID
                        lia.db.updateTable({
                            faction = defaultFaction.uniqueID
                        }, nil, "characters", "id = " .. charId)
                    end
                end

                characters[#characters + 1] = charId
                local character = lia.char.new(charData, charId, client)
                if charData.recognition then lia.char.setCharDatabase(charId, "rgn", nil) end
                hook.Run("CharRestored", character)
                character.vars.inv = {}
                lia.inventory.loadAllFromCharID(charId):next(function(inventories)
                    if #inventories == 0 then
                        local promise = hook.Run("CreateDefaultInventory", character)
                        assert(promise ~= nil, L("noDefaultInventory"))
                        return promise:next(function(inventory)
                            assert(inventory ~= nil, L("noDefaultInventory"))
                            return {inventory}
                        end)
                    end
                    return inventories
                end, function(err)
                    lia.information(L("failedLoadInventories", tostring(charId)))
                    lia.information(err)
                    if IsValid(client) then client:notifyErrorLocalized("fixInventoryError") end
                end):next(function(inventories)
                    character.vars.inv = inventories
                    lia.char.loaded[charId] = character
                    done = done + 1
                    if done == #results and callback then callback(characters) end
                end)
            end
        end)
    end

    --[[
    Purpose:
        Cleans up all loaded characters for a player when they disconnect

    When Called:
        When a player disconnects to free up memory and save data

    Parameters:
        - client (Player): The player to clean up characters for

    Returns:
        None

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Clean up player characters
        lia.char.cleanUpForPlayer(client)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Clean up with logging
        lia.char.cleanUpForPlayer(client)

        local charCount = table.Count(client.liaCharList or {})
        if charCount > 0 then
            lia.log.add("Player disconnect: " ..
                client:Name() .. " disconnected with " .. charCount .. " characters loaded"
            )
        end
        ```

    High Complexity:
        ```lua
        -- High: Clean up with statistics and validation
        local function cleanupPlayerCharacters(client)
            local charList = client.liaCharList or {}
            local stats = {
                total  = #charList,
                saved  = 0,
                errors = 0
            }

            for _, charID in ipairs(charList) do
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Save character data
                    local success = character:save()
                    if success then
                        stats.saved = stats.saved + 1
                    else
                        stats.errors = stats.errors + 1
                        print("Failed to save character", charID, "for", client:Name())
                    end
                end
            end

            -- Clean up
            lia.char.cleanUpForPlayer(client)

            -- Log statistics
            lia.log.add("Player cleanup: " ..
                client:Name() .. " - Characters: " .. stats.total ..
                ", Saved: " .. stats.saved ..
                ", Errors: " .. stats.errors
            )
        end
        ```
]]
    function lia.char.cleanUpForPlayer(client)
        for _, charID in pairs(client.liaCharList or {}) do
            if lia.char.loaded[charID] then lia.char.unloadCharacter(charID) end
        end
    end

    local function removePlayer(client)
        if client:getChar() then
            client:KillSilent()
            client:setNetVar("char", nil)
            client:Spawn()
            net.Start("liaCharKick")
            net.WriteType(nil)
            net.WriteBool(true)
            net.Send(client)
        end
    end

    --[[
    Purpose:
        Permanently deletes a character from the database and all associated data

    When Called:
        When a character needs to be permanently removed (admin action, etc.)

    Parameters:
        - id (number): The unique identifier of the character to delete
        - client (Player): The player who owns the character (optional)

    Returns:
        None

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Delete a character
        lia.char.delete(123)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Delete character with validation
        local charID = 123
        local character = lia.char.getCharacter(charID)

        if character then
            local owner = character:getPlayer()
            if IsValid(owner) then
                owner:notify("Your character '" .. character:getName() .. "' has been deleted")
            end

            lia.char.delete(charID, owner)
        end
        ```

    High Complexity:
        ```lua
        -- High: Delete character with full cleanup and logging
        local function deleteCharacterWithCleanup(charID, admin)
            local character = lia.char.getCharacter(charID)
            if not character then
                if admin then
                    admin:notifyError("Character not found")
                end
                return
            end

            local owner = character:getPlayer()
            local charName = character:getName()

            -- Log deletion
            lia.log.add("Character deletion: " ..
                "Character '" .. charName .. "' (ID: " .. charID .. ") deleted by " ..
                (IsValid(admin) and admin:Name() or "System")
            )

            -- Notify owner if online
            if IsValid(owner) then
                owner:notify("Your character '" .. charName .. "' has been deleted")
            end

            -- Perform deletion
            lia.char.delete(charID, owner)

            -- Notify admin
            if IsValid(admin) then
                admin:notify("Character '" .. charName .. "' deleted successfully")
            end

            -- Run deletion hook
            hook.Run("OnCharacterDeleted", charID, charName, owner, admin)
        end
        ```
]]
    function lia.char.delete(id, client)
        assert(isnumber(id), L("idMustBeNumber"))
        local playersToSync = {}
        for _, ply in player.Iterator() do
            if IsValid(ply) and ply.liaCharList and table.HasValue(ply.liaCharList, id) then table.insert(playersToSync, ply) end
        end

        if IsValid(client) then
            removePlayer(client)
        else
            for _, target in player.Iterator() do
                if not table.HasValue(target.liaCharList or {}, id) then continue end
                table.RemoveByValue(target.liaCharList, id)
                removePlayer(target)
            end
        end

        hook.Run("PreCharDelete", id)
        if IsValid(client) and client.liaCharList then table.RemoveByValue(client.liaCharList, id) end
        lia.char.loaded[id] = nil
        lia.db.query("DELETE FROM lia_characters WHERE id = " .. id)
        lia.db.delete("chardata", "charID = " .. id)
        lia.db.query("SELECT invID FROM lia_inventories WHERE charID = " .. id, function(data)
            if data then
                for _, inventory in ipairs(data) do
                    lia.inventory.deleteByID(tonumber(inventory.invID))
                end
            end
        end)

        hook.Run("OnCharDelete", client, id)
        if IsValid(client) and client:getChar() and client:getChar():getID() == id then
            net.Start("liaRemoveFOne")
            net.Send(client)
            net.Start("liaCharKick")
            net.WriteUInt(id, 32)
            net.WriteBool(true)
            net.Send(client)
            client:setNetVar("char", nil)
            client:Spawn()
        end

        for _, ply in ipairs(playersToSync) do
            if IsValid(ply) then
                net.Start("liaCharDeleted")
                net.Send(ply)
                lia.module.get("mainmenu"):SyncCharList(ply)
            end
        end
    end

    --[[
    Purpose:
        Checks if a character is banned and returns the ban timestamp

    When Called:
        When you need to check if a character is banned

    Parameters:
        - charID (number): The unique identifier of the character

    Returns:
        Number representing ban timestamp (0 if not banned)

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Check if character is banned
        local banTime = lia.char.getCharBanned(123)
        if banTime > 0 then
            print("Character is banned since:", os.date("%Y-%m-%d", banTime))
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Check ban status with validation
        local charID = 123
        local banTime = lia.char.getCharBanned(charID)

        if banTime > 0 then
            local character = lia.char.getCharacter(charID)
            if character then
                local owner = character:getPlayer()
                if IsValid(owner) then
                    owner:notify("Your character is banned")
                end
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch ban checking with detailed information
        local function checkCharacterBans(charIDs)
            local banInfo = {}

            for _, charID in ipairs(charIDs) do
                local banTime = lia.char.getCharBanned(charID)
                if banTime > 0 then
                    local character = lia.char.getCharacter(charID)
                    banInfo[charID] = {
                        banned     = true,
                        banTime    = banTime,
                        banDate    = os.date("%Y-%m-%d %H:%M:%S", banTime),
                        character  = character,
                        owner      = character and character:getPlayer()
                    }
                end
            end

            return banInfo
        end
        ```
]]
    function lia.char.getCharBanned(charID)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local result = sql.Query("SELECT banned FROM lia_characters WHERE id = " .. charIDsafe .. " LIMIT 1")
        if istable(result) and result[1] then return tonumber(result[1].banned) or 0 end
    end

    --[[
    Purpose:
        Sets character data in the database with proper type handling and networking

    When Called:
        When character data needs to be saved to the database

    Parameters:
        - charID (number): The unique identifier of the character
        - field (string): The field name to set
        - value (any): The value to set for the field

    Returns:
        Boolean indicating success

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Set character data
        local success = lia.char.setCharDatabase(123, "money", 1000)
        if success then
            print("Character money updated")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Set character data with validation
        local charID = 123
        local newMoney = 5000

        local character = lia.char.getCharacter(charID)
        if character then
            local oldMoney = character:getMoney()
            local success = lia.char.setCharDatabase(charID, "money", newMoney)

            if success then
                character:setMoney(newMoney)
                print("Money changed from", oldMoney, "to", newMoney)
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch character data updates with error handling
        local function updateCharacterData(charID, dataUpdates)
            local character = lia.char.getCharacter(charID)
            if not character then
                print("Character not found:", charID)
                return false
            end

            local results = {}
            local successCount = 0

            for field, value in pairs(dataUpdates) do
                local success = lia.char.setCharDatabase(charID, field, value)
                results[field] = success

                if success then
                    successCount = successCount + 1
                    -- Update loaded character if it exists
                    if character["set" .. field:sub(1, 1):upper() .. field:sub(2)] then
                        character["set" .. field:sub(1, 1):upper() .. field:sub(2)](character, value)
                    end
                else
                    print("Failed to update field:", field)
                end
            end

            print("Updated", successCount, "out of", table.Count(dataUpdates), "fields")
            return successCount == table.Count(dataUpdates)
        end
        ```
]]
    function lia.char.setCharDatabase(charID, field, value)
        local charIDsafe = tonumber(charID)
        if not charIDsafe or not field then return false end
        local varData = lia.char.vars[field]
        if varData then
            if varData.field then
                local updateData = {}
                local fieldName = varData.field
                if varData.fieldType == "text" then
                    if istable(value) then
                        updateData[fieldName] = util.TableToJSON(value)
                    else
                        updateData[fieldName] = tostring(value)
                    end
                elseif varData.fieldType == "string" then
                    updateData[fieldName] = tostring(value)
                elseif varData.fieldType == "integer" then
                    updateData[fieldName] = tonumber(value) or varData.default or 0
                elseif varData.fieldType == "boolean" then
                    updateData[fieldName] = value and 1 or 0
                else
                    if istable(value) then
                        updateData[fieldName] = util.TableToJSON(value)
                    else
                        updateData[fieldName] = tostring(value)
                    end
                end

                local promise = lia.db.updateTable(updateData, nil, "characters", "id = " .. charIDsafe)
                if deferred.isPromise(promise) then
                    promise:catch(function(err) lia.information(L("charSetDataSQLError", "UPDATE lia_characters SET " .. fieldName, err)) end)
                elseif promise == false then
                    return false
                end

                if lia.char.loaded[charIDsafe] then
                    local character = lia.char.loaded[charIDsafe]
                    if field == "model" then
                        character:setModel(value)
                        local client = character:getPlayer()
                        if IsValid(client) and client:getChar() == character then
                            client:SetModel(value)
                            client:SetupHands()
                        end
                    elseif field == "skin" then
                        character:setSkin(value)
                        local client = character:getPlayer()
                        if IsValid(client) and client:getChar() == character then client:SetSkin(value) end
                    elseif field == "bodygroups" then
                        character:setBodygroups(value)
                        local client = character:getPlayer()
                        if IsValid(client) and client:getChar() == character then
                            for k, v in pairs(value or {}) do
                                local index = tonumber(k)
                                if index then client:SetBodygroup(index, v or 0) end
                            end
                        end
                    elseif field == "faction" then
                        character:setFaction(value)
                    elseif field == "banned" then
                        character:setBanned(value)
                    elseif character["set" .. field:sub(1, 1):upper() .. field:sub(2)] then
                        character["set" .. field:sub(1, 1):upper() .. field:sub(2)](character, value)
                    else
                        character.vars[field] = value
                    end
                end
                return true
            else
                if val == nil then
                    lia.db.delete("chardata", "charID = " .. charIDsafe .. " AND key = '" .. lia.db.escape(field) .. "'")
                else
                    local encoded = pon.encode({value})
                    lia.db.upsert({
                        charID = charIDsafe,
                        key = field,
                        value = encoded
                    }, "chardata")
                end

                if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setData(field, value) end
                return true
            end
        else
            if val == nil then
                lia.db.delete("chardata", "charID = " .. charIDsafe .. " AND key = '" .. lia.db.escape(field) .. "'")
            else
                local encoded = pon.encode({value})
                lia.db.upsert({
                    charID = charIDsafe,
                    key = field,
                    value = encoded
                }, "chardata")
            end

            if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setData(field, value) end
            return true
        end
    end

    --[[
    Purpose:
        Unloads a character from memory, saving data and cleaning up resources

    When Called:
        When a character needs to be removed from memory to free up resources

    Parameters:
        - charID (number): The unique identifier of the character to unload

    Returns:
        Boolean indicating success

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Unload a character
        local success = lia.char.unloadCharacter(123)
        if success then
            print("Character unloaded successfully")
        end
        ```

    Medium Complexity:
        ```lua
        -- Medium: Unload character with validation
        local charID = 123
        local character = lia.char.getCharacter(charID)

        if character then
            local owner = character:getPlayer()
            if IsValid(owner) then
                owner:notify("Character is being unloaded")
            end

            local success = lia.char.unloadCharacter(charID)
            if success then
                print("Character", charID, "unloaded successfully")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Batch character unloading with statistics
        local function unloadCharacters(charIDs)
            local stats = {
                total    = #charIDs,
                unloaded = 0,
                errors   = 0,
                skipped  = 0
            }

            for _, charID in ipairs(charIDs) do
                if lia.char.isLoaded(charID) then
                    local character = lia.char.getCharacter(charID)
                    if character then
                        -- Check if character is in use
                        local owner = character:getPlayer()
                        if IsValid(owner) and owner:getChar() == character then
                            stats.skipped = stats.skipped + 1
                            print("Skipping active character:", charID)
                            continue
                        end

                        local success = lia.char.unloadCharacter(charID)
                        if success then
                            stats.unloaded = stats.unloaded + 1
                        else
                            stats.errors = stats.errors + 1
                        end
                    end
                end
            end

            print("Unloaded", stats.unloaded, "characters, skipped", stats.skipped, "active characters")
            return stats
        end
        ```
]]
    function lia.char.unloadCharacter(charID)
        local character = lia.char.loaded[charID]
        if not character then return false end
        character:save()
        if character.dataVars then
            local client = character:getPlayer()
            local keys = table.GetKeys(character.dataVars)
            if IsValid(client) and #keys > 0 then
                net.Start("liaCharacterData")
                net.WriteUInt(charID, 32)
                net.WriteUInt(#keys, 32)
                for _, key in ipairs(keys) do
                    net.WriteString(key)
                    net.WriteType(nil)
                end

                net.Send(client)
            end

            character.dataVars = nil
        end

        lia.inventory.cleanUpForCharacter(character)
        lia.char.loaded[charID] = nil
        hook.Run("CharCleanUp", character)
        return true
    end

    --[[
    Purpose:
        Unloads unused characters for a player, keeping only the active one

    When Called:
        When a player switches characters or to free up memory

    Parameters:
        - client (Player): The player to unload unused characters for
        - activeCharID (number): The ID of the character to keep loaded

    Returns:
        Number of characters unloaded

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Unload unused characters
        local unloadedCount = lia.char.unloadUnusedCharacters(client, 123)
        print("Unloaded", unloadedCount, "characters")
        ```

    Medium Complexity:
        ```lua
        -- Medium: Unload with validation
        local activeCharID = client:getChar() and client:getChar():getID()
        if activeCharID then
            local unloadedCount = lia.char.unloadUnusedCharacters(client, activeCharID)

            if unloadedCount > 0 then
                client:notify("Unloaded " .. unloadedCount .. " unused characters")
            end
        end
        ```

    High Complexity:
        ```lua
        -- High: Unload with detailed logging and statistics
        local function unloadUnusedCharactersWithStats(client)
            local activeChar = client:getChar()
            local activeCharID = activeChar and activeChar:getID()

            if not activeCharID then
                print("No active character for", client:Name())
                return 0
            end

            local charList = client.liaCharList or {}
            local stats = {
                total    = #charList,
                active   = activeCharID,
                unloaded = 0,
                errors   = 0
            }

            -- Unload unused characters
            stats.unloaded = lia.char.unloadUnusedCharacters(client, activeCharID)

            -- Log statistics
            lia.log.add("Character unloading: " ..
                client:Name() .. " - Total: " .. stats.total ..
                ", Active: " .. stats.active ..
                ", Unloaded: " .. stats.unloaded
            )

            return stats.unloaded
        end
        ```
]]
    function lia.char.unloadUnusedCharacters(client, activeCharID)
        local unloadedCount = 0
        for _, charID in pairs(client.liaCharList or {}) do
            if charID ~= activeCharID and lia.char.loaded[charID] and lia.char.unloadCharacter(charID) then unloadedCount = unloadedCount + 1 end
        end
        return unloadedCount
    end

    --[[
    Purpose:
        Loads a single character from the database with inventory initialization

    When Called:
        When a specific character needs to be loaded on demand

    Parameters:
        - charID (number): The unique identifier of the character to load
        - client (Player): The player requesting the character (optional)
        - callback (function): Function to call when loading is complete

    Returns:
        None (uses callback for result)

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Load a single character
        lia.char.loadSingleCharacter(123, client, function(character)
            if character then
                print("Character loaded:", character:getName())
            end
        end)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Load character with validation
        local charID = 123
        lia.char.loadSingleCharacter(charID, client, function(character)
            if character then
                -- Validate character access
                if not client.liaCharList or not table.HasValue(client.liaCharList, charID) then
                    print("Player doesn't have access to character", charID)
                    return
                end

                -- Check if character is banned
                if character:getBanned() > 0 then
                    client:notify("This character is banned")
                    return
                end

                client:notify("Character loaded successfully")
            else
                client:notify("Failed to load character")
            end
        end)
        ```

    High Complexity:
        ```lua
        -- High: Load character with full error handling and statistics
        local function loadCharacterWithValidation(charID, client)
            if not charID or not isnumber(charID) then
                if client then
                    client:notifyError("Invalid character ID")
                end
                return
            end

            -- Check if character is already loaded
            if lia.char.isLoaded(charID) then
                local character = lia.char.getCharacter(charID)
                if character then
                    print("Character already loaded:", charID)
                    return character
                end
            end

            -- Validate player access
            if client and (not client.liaCharList or not table.HasValue(client.liaCharList, charID)) then
                client:notifyError("You don't have access to this character")
                return
            end

            lia.char.loadSingleCharacter(charID, client, function(character)
                if character then
                    -- Validate character data
                    if not character:getName() or character:getName() == "" then
                        print("Invalid character data for ID:", charID)
                        return
                    end

                    -- Check ban status
                    if character:getBanned() > 0 then
                        if client then
                            client:notify("This character is banned")
                        end
                        return
                    end

                    -- Log successful load
                    lia.log.add("Character loaded: " ..
                        "Character '" .. character:getName() .. "' (ID: " .. charID .. ") loaded for " ..
                        (client and client:Name() or "System")
                    )

                    -- Run load hook
                    hook.Run("OnCharacterLoaded", character, client)

                    if client then
                        client:notify("Character '" .. character:getName() .. "' loaded successfully")
                    end
                else
                    if client then
                        client:notifyError("Failed to load character")
                    end
                    print("Failed to load character:", charID)
                end
            end)
        end
        ```
]]
    function lia.char.loadSingleCharacter(charID, client, callback)
        if lia.char.loaded[charID] then
            if callback then callback(lia.char.loaded[charID]) end
            return
        end

        if client and not table.HasValue(client.liaCharList or {}, charID) then
            if callback then callback(nil) end
            return
        end

        lia.db.selectOne("*", "characters", "id = " .. charID):next(function(result)
            if not result then
                if callback then callback(nil) end
                return
            end

            local charData = {}
            for k, v in pairs(lia.char.vars) do
                if v.field and result[v.field] then
                    local value = tostring(result[v.field])
                    if isnumber(v.default) then
                        value = tonumber(value) or v.default
                    elseif isbool(v.default) then
                        value = tobool(value)
                    elseif istable(v.default) then
                        value = util.JSONToTable(value)
                    end

                    charData[k] = value
                end
            end

            local character = lia.char.new(charData, charID, client)
            hook.Run("CharRestored", character)
            character.vars.inv = {}
            lia.inventory.loadAllFromCharID(charID):next(function(inventories)
                if #inventories == 0 then
                    local promise = hook.Run("CreateDefaultInventory", character)
                    if promise then
                        promise:next(function(inventory)
                            character.vars.inv = {inventory}
                            lia.char.loaded[charID] = character
                            if callback then callback(character) end
                        end)
                    else
                        character.vars.inv = {}
                        lia.char.loaded[charID] = character
                        if callback then callback(character) end
                    end
                else
                    character.vars.inv = inventories
                    lia.char.loaded[charID] = character
                    if callback then callback(character) end
                end
            end, function(err)
                lia.information(L("failedToLoadInventoriesForCharacter") .. " " .. charID .. ": " .. tostring(err))
                if callback then callback(nil) end
            end)
        end)
    end
end
