--[[
    Folder: Developer - Libraries
    File: lia.char.md
]]
--[[
    Character

    Character helpers for Lilia character creation, lookup, loading, caching, variable registration, persistence, and cleanup.
]]
--[[
    Overview:
        The character library centralizes shared character state under `lia.char`. It stores registered character variables, tracks loaded characters, resolves characters by ID or owner, creates character objects, registers character variable accessors, restores persistent data from the database, and unloads or deletes characters when needed.
]]
--[[
    Hooks:
        GetDefaultCharName(Player client, any faction, table data)

    Purpose:
        Allows schemas, plugins, or modules to provide a default character name during character creation.

    Category:
        Character

    Parameters:
        client (Player)
            The player creating the character.
        faction (any)
            The submitted faction value.
        data (table)
            The submitted character creation data.

    Example Usage:
        ```lua
        hook.Add("GetDefaultCharName", "liaExampleGetDefaultCharName", function(client, faction, data)
            return "Example Value"
        end)
        ```

    Returns:
        string|nil
            The default name to use.
        boolean|nil
            Return true as the second value to force the returned name and bypass normal name validation.

    Realm:
        Shared
]]
--[[
    Hooks:
        GetDefaultCharDesc(Player client, any faction, table data)

    Purpose:
        Allows schemas, plugins, or modules to provide a default character description during character creation.

    Category:
        Character

    Parameters:
        client (Player)
            The player creating the character.
        faction (any)
            The submitted faction value.
        data (table)
            The submitted character creation data.

    Example Usage:
        ```lua
        hook.Add("GetDefaultCharDesc", "liaExampleGetDefaultCharDesc", function(client, faction, data)
            return "Example Value"
        end)
        ```

    Returns:
        string|nil
            The default description to use.
        boolean|nil
            Return true as the second value to force the returned description and bypass normal description validation.

    Realm:
        Shared
]]
--[[
    Hooks:
        OnCharVarChanged(Character character, string key, any oldValue, any newValue)

    Purpose:
        Runs after a networked character variable changes.

    Category:
        Character

    Parameters:
        character (Character)
            The character whose variable changed.
        key (string)
            The character variable key that changed.
        oldValue (any)
            The previous value.
        newValue (any)
            The new value.

    Example Usage:
        ```lua
        hook.Add("OnCharVarChanged", "liaExampleOnCharVarChanged", function(character, key, oldValue, newValue)
            print("[MyModule] handled OnCharVarChanged")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PlayerBodyGroupChanged(Player client, table oldBodygroups, table newBodygroups)

    Purpose:
        Runs after a character bodygroup update is applied.

    Category:
        Character

    Parameters:
        client (Player)
            The player associated with the character.
        oldBodygroups (table)
            The previous bodygroup table.
        newBodygroups (table)
            The applied bodygroup table.

    Example Usage:
        ```lua
        hook.Add("PlayerBodyGroupChanged", "liaExamplePlayerBodyGroupChanged", function(client, oldBodygroups, newBodygroups)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled PlayerBodyGroupChanged for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        GetAttributeStartingMax(Player client, string attributeKey)

    Purpose:
        Allows schemas, plugins, or modules to override the maximum starting value for a specific attribute.

    Category:
        Character

    Parameters:
        client (Player)
            The player creating the character.
        attributeKey (string)
            The attribute key being validated.

    Example Usage:
        ```lua
        hook.Add("GetAttributeStartingMax", "liaExampleGetAttributeStartingMax", function(client, attributeKey)
            return 15
        end)
        ```

    Returns:
        number|nil
            The maximum allowed starting value for the attribute, or nil to use default behavior.

    Realm:
        Shared
]]
--[[
    Hooks:
        GetMaxStartingAttributePoints(Player client, number defaultPoints)

    Purpose:
        Allows schemas, plugins, or modules to override the total starting attribute points available during character creation.

    Category:
        Character

    Parameters:
        client (Player)
            The player creating the character.
        defaultPoints (number)
            The configured default starting attribute point amount.

    Example Usage:
        ```lua
        hook.Add("GetMaxStartingAttributePoints", "liaExampleGetMaxStartingAttributePoints", function(client, defaultPoints)
            return 15
        end)
        ```

    Returns:
        number|nil
            The maximum starting attribute points, or nil to use default behavior.

    Realm:
        Shared
]]
--[[
    Hooks:
        CreateDefaultInventory(Character character)

    Purpose:
        Creates the default inventory for a newly created or restored character when no inventories exist.

    Category:
        Character

    Parameters:
        character (Character)
            The character that needs a default inventory.

    Example Usage:
        ```lua
        hook.Add("CreateDefaultInventory", "liaExampleCreateDefaultInventory", function(character)
            print("[MyModule] handled CreateDefaultInventory")
        end)
        ```

    Returns:
        Promise
            A promise that resolves with the created inventory.

    Realm:
        Server
]]
--[[
    Hooks:
        CharRestored(Character character)

    Purpose:
        Runs after a character object is rebuilt from persistent data and before its inventories finish loading.

    Category:
        Character

    Parameters:
        character (Character)
            The restored character object.

    Example Usage:
        ```lua
        hook.Add("CharRestored", "liaExampleCharRestored", function(character)
            print("[MyModule] handled CharRestored")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        PreCharDelete(number id)

    Purpose:
        Runs before a character is deleted from memory and persistent storage.

    Category:
        Character

    Parameters:
        id (number)
            The ID of the character being deleted.

    Example Usage:
        ```lua
        hook.Add("PreCharDelete", "liaExamplePreCharDelete", function(id)
            print("[MyModule] handled PreCharDelete")
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharDelete(Player client, number id)

    Purpose:
        Runs after a character record and its character data are deleted.

    Category:
        Character

    Parameters:
        client (Player)
            The player associated with the deleted character, when available.
        id (number)
            The ID of the deleted character.

    Example Usage:
        ```lua
        hook.Add("OnCharDelete", "liaExampleOnCharDelete", function(client, id)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OnCharDelete for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        SyncCharList(Player client)

    Purpose:
        Runs when a player whose character list contained a deleted character needs their character list synchronized.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose character list should be synchronized.

    Example Usage:
        ```lua
        hook.Add("SyncCharList", "liaExampleSyncCharList", function(client)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled SyncCharList for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CharCleanUp(Character character)

    Purpose:
        Runs after a loaded character is saved, detached from inventories, and removed from the loaded character cache.

    Category:
        Character

    Parameters:
        character (Character)
            The unloaded character.

    Example Usage:
        ```lua
        hook.Add("CharCleanUp", "liaExampleCharCleanUp", function(character)
            print("[MyModule] handled CharCleanUp")
        end)
        ```

    Realm:
        Server
]]
lia.char = lia.char or {}
lia.char.vars = lia.char.vars or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.pendingRequests = lia.char.pendingRequests or {}
--[[
    Purpose:
        Gets a character by ID from the loaded cache. On the server, missing characters are loaded from the database. On the client, missing characters are requested from the server and resolved through the callback.

    Parameters:
        charID (number)
            The character ID to retrieve.
        client (Player|nil)
            The player requesting or owning the character. Used server-side when loading a missing character.
        callback (function|nil)
            Optional callback called with the character when it is available.

    Returns:
        Character|nil
            The loaded character when it is already available immediately.

    Example Usage:
        ```lua
        lia.char.getCharacter(charID, client, function(character)
            if character then print(character:getName()) end
        end)
        ```

    Realm:
        Shared
]]
function lia.char.getCharacter(charID, client, callback)
    if SERVER then
        if not charID then return end
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
        Gets every currently active player character.

    Parameters:
        None.

    Returns:
        table
            A table keyed by Player with Character values for players that currently have a character.

    Example Usage:
        ```lua
        for client, character in pairs(lia.char.getAll()) do
            print(client:Name(), character:getName())
        end
        ```

    Realm:
        Shared
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
        Checks whether a character ID is currently present in the loaded character cache.

    Parameters:
        charID (number)
            The character ID to check.

    Returns:
        boolean
            True if the character is loaded, otherwise false.

    Example Usage:
        ```lua
        if lia.char.isLoaded(charID) then print("Character is loaded") end
        ```

    Realm:
        Shared
]]
function lia.char.isLoaded(charID)
    return lia.char.loaded[charID] ~= nil
end

--[[
    Purpose:
        Adds a character to the loaded character cache and resolves any pending clientside request callback for that character ID.

    Parameters:
        id (number)
            The character ID to cache.
        character (Character)
            The character object to store.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.char.addCharacter(id, character)
        ```

    Realm:
        Shared
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
        Removes a character from the loaded character cache.

    Parameters:
        id (number)
            The character ID to remove.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.char.removeCharacter(id)
        ```

    Realm:
        Shared
]]
function lia.char.removeCharacter(id)
    lia.char.loaded[id] = nil
end

--[[
    Purpose:
        Creates a character object from registered character variables, supplied data, an optional ID, and an optional owning player or SteamID.

    Parameters:
        data (table)
            Character data keyed by registered character variable name.
        id (number|nil)
            The character ID. Defaults to 0 when omitted.
        client (Player|nil)
            The player associated with the character.
        steamID (string|nil)
            Fallback SteamID used when a valid player is not available.

    Returns:
        Character
            A character object using `lia.meta.character` as its metatable.

    Example Usage:
        ```lua
        local character = lia.char.new(data, id, client)
        ```

    Realm:
        Shared
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
        Registers a named callback for a character variable hook table.

    Parameters:
        varName (string)
            The character variable name to attach the hook to.
        hookName (string)
            The unique hook name for the callback.
        func (function)
            The callback function to store.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.char.hookVar("money", "TrackMoneyChange", function(character, value) end)
        ```

    Realm:
        Shared
]]
function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

--[[
    Purpose:
        Registers a character variable definition and generates matching character getter and setter methods when applicable.

    Parameters:
        key (string)
            The character variable key.
        data (table)
            Variable metadata such as default value, database field, validation, networking, display, getter, setter, and sync behavior.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.char.registerVar("example", {
            default = "value",
            field = "example",
            fieldType = "string"
        })
        ```

    Realm:
        Shared
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
    if SERVER and data.field and data.fieldType and lia.db and lia.db.tablesLoaded then
        local typeMap = {
            string = function(d) return ("%s VARCHAR(%d)"):format(d.field, d.length or 255) end,
            integer = function(d) return ("%s INT"):format(d.field) end,
            int = function(d) return ("%s INT"):format(d.field) end,
            float = function(d) return ("%s FLOAT"):format(d.field) end,
            boolean = function(d) return ("%s TINYINT(1)"):format(d.field) end,
            datetime = function(d) return ("%s DATETIME"):format(d.field) end,
            text = function(d) return ("%s TEXT"):format(d.field) end,
        }

        local builder = typeMap[data.fieldType]
        if builder then
            lia.db.fieldExists("lia_characters", data.field):next(function(exists)
                if not exists then
                    local colDef = builder(data)
                    if data.default ~= nil then colDef = colDef .. " DEFAULT '" .. tostring(data.default) .. "'" end
                    lia.db.query("ALTER TABLE lia_characters ADD COLUMN " .. colDef)
                end
            end)
        end
    end
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
        local trimmedValue = string.Trim(value or "")
        local valueWithoutSpaces = string.gsub(trimmedValue, "%s", "")
        if #valueWithoutSpaces < minLength then return false, "descMinLen", minLength end
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
        hook.Run("OnCharVarChanged", character, "model", oldVar, value)
    end,
    onGet = function(character, default) return character.vars.model or default end,
    index = 3,
    onValidate = function(_, data, client)
        local faction = lia.faction.indices[data.faction]
        if faction then
            local class = lia.faction.getCharacterCreationClass(faction, data.class)
            local models, _, forced = lia.faction.getCharacterCreationModelChoices(faction, class)
            if forced then return true end
            if not data.model or not models[data.model] then
                local canCreateStaffCharacter = data.faction == FACTION_STAFF and client and client:hasPrivilege("createStaffCharacter") or false
                lia.debug("[Permissions]", "Permission Check for char var model onValidate staff model bypass", "targetFactionIsStaff=", tostring(data.faction == FACTION_STAFF), "clientExists=", tostring(client ~= nil), "hasPrivilege(createStaffCharacter)=", tostring(client and client:hasPrivilege("createStaffCharacter") or false), "finalResult=", tostring(canCreateStaffCharacter))
                if canCreateStaffCharacter then return true end
                return false, "needModel"
            end
        else
            return false, "needModel"
        end
    end,
    onAdjust = function(client, data, value, newData)
        local faction = lia.faction.indices[data.faction]
        if faction then
            local class = lia.faction.getCharacterCreationClass(faction, data.class)
            local model = lia.faction.getCharacterCreationModelInfo(faction, class, value)
            local parsedModel = lia.faction.getModelData(value, model)
            if isstring(model) then
                newData.model = model
            elseif parsedModel then
                newData.model = parsedModel.model
                local defaultSkin = parsedModel.skin or 0
                local groups = {}
                if isstring(parsedModel.bodygroups) then
                    local i = 0
                    for digit in parsedModel.bodygroups:gmatch("%d") do
                        groups[i] = tonumber(digit)
                        i = i + 1
                    end
                elseif istable(parsedModel.bodygroups) then
                    for groupIndex, groupValue in pairs(parsedModel.bodygroups) do
                        groups[tonumber(groupIndex)] = tonumber(groupValue)
                    end
                end

                local skinAllowed, bodygroupsAllowed = lia.faction.getModelCustomizationAllowed(client, faction, data)
                if skinAllowed and data.skin ~= nil then
                    local desiredSkin = tonumber(data.skin) or defaultSkin
                    if not lia.faction.isSkinAllowedForFaction(faction, desiredSkin, model, value) then desiredSkin = lia.faction.getDefaultAllowedSkinForFaction(faction, defaultSkin, model, value) end
                    newData.skin = desiredSkin
                else
                    newData.skin = defaultSkin
                end

                local chosenGroups = groups
                if bodygroupsAllowed and istable(data.bodygroups) then
                    chosenGroups = {}
                    for k, v in pairs(data.bodygroups) do
                        local idx = tonumber(k)
                        if idx then
                            local desiredValue = tonumber(v) or 0
                            if not lia.faction.isBodygroupValueAllowed(faction, newData.model, idx, desiredValue, nil, model, value) then desiredValue = tonumber(groups[idx]) or 0 end
                            chosenGroups[idx] = desiredValue
                        end
                    end
                end

                newData.bodygroups = chosenGroups
            end
        end
    end
})

lia.char.registerVar("skin", {
    field = "skin",
    fieldType = "integer",
    default = 0,
    onValidate = function(value)
        if value == nil then return true end
        if not isnumber(value) then return false, "invalid", "skin" end
        return true
    end,
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
    onValidate = function(value)
        if value == nil then return true end
        if not istable(value) then return false, "invalid", "bodygroups" end
        return true
    end,
    onSet = function(character, value)
        local oldVar = character:getBodygroups()
        local normalizedValue = lia.util.normalizeBodygroups(value)
        character.vars.bodygroups = normalizedValue
        local client = character:getPlayer()
        local appliedGroups = character:getBodygroups()
        if IsValid(client) and client:getChar() == character then lia.util.applyBodygroups(client, appliedGroups) end
        net.Start("liaCharSet")
        net.WriteString("bodygroups")
        net.WriteType(character.vars.bodygroups)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("PlayerBodyGroupChanged", client, oldVar, appliedGroups)
        hook.Run("OnCharVarChanged", character, "bodygroups", oldVar, appliedGroups)
    end,
    onGet = function(character, default)
        local mergedGroups = lia.class.getMergedBodygroups(character)
        if next(mergedGroups) ~= nil then return mergedGroups end
        return default or {}
    end,
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
        local currentClass = character:getClass()
        local classData = currentClass and lia.class.list[currentClass]
        if currentClass and (not classData or classData.faction ~= value) then character:setClass(nil) end
        net.Start("liaCharSet")
        net.WriteString("faction")
        net.WriteType(character.vars.faction)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", character, "faction", oldVar, value)
        return true
    end,
    onGet = function(character, default)
        local factionValue = character.vars.faction
        local faction = lia.faction.teams[factionValue]
        if not faction then
            local factionIndex = tonumber(factionValue)
            if factionIndex then faction = lia.faction.indices[factionIndex] end
        end
        return faction and faction.index or default or 0
    end,
    onValidate = function(value, _, client)
        if not lia.faction.indices[value] then return false, "invalid", "faction" end
        if value == FACTION_STAFF then
            local canCreateStaffCharacter = client and client:hasPrivilege("createStaffCharacter") or false
            lia.debug("[Permissions]", "Permission Check for char var faction onValidate", "targetFactionIsStaff=", tostring(value == FACTION_STAFF), "clientExists=", tostring(client ~= nil), "hasPrivilege(createStaffCharacter)=", tostring(canCreateStaffCharacter), "finalResult=", tostring(canCreateStaffCharacter))
            if not client or not canCreateStaffCharacter then return false, "staffFactionRestricted" end
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
        local canCreateStaffCharacter = data and data.faction == FACTION_STAFF and client and client:hasPrivilege("createStaffCharacter") or false
        lia.debug("[Permissions]", "Permission Check for char var attribs onValidate staff bypass", "dataExists=", tostring(data ~= nil), "targetFactionIsStaff=", tostring(data and data.faction == FACTION_STAFF or false), "clientExists=", tostring(client ~= nil), "hasPrivilege(createStaffCharacter)=", tostring(client and client:hasPrivilege("createStaffCharacter") or false), "finalResult=", tostring(canCreateStaffCharacter))
        if canCreateStaffCharacter then return true end
        if value ~= nil then
            if istable(value) then
                local count = 0
                for k, v in pairs(value) do
                    local max = hook.Run("GetAttributeStartingMax", client, k)
                    if max and v > max then return false, L("attribTooHigh", lia.attribs.list[k].name) end
                    count = count + v
                end

                local points = hook.Run("GetMaxStartingAttributePoints", client, lia.config.get("StartingAttributePoints", 30))
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

lia.char.registerVar("classwhitelists", {
    field = "classwhitelists",
    fieldType = "text",
    default = {},
    noDisplay = true
})

lia.char.registerVar("banned", {
    field = "banned",
    fieldType = "integer",
    default = 0,
    noDisplay = true
})

--[[
    Purpose:
        Reads saved key-value character data for a character from `lia_chardata` and decodes stored values.

    Parameters:
        charID (number|string)
            The character ID whose data should be read.
        key (string|nil)
            Optional data key to return from the decoded data table.

    Returns:
        table|any|nil
            The full decoded character data table, one value when `key` is provided, or nil when the character ID is invalid.

    Example Usage:
        ```lua
        local data = lia.char.getCharData(charID)
        local value = lia.char.getCharData(charID, "rgn")
        ```

    Realm:
        Server
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
        Reads saved key-value character data directly from `lia_chardata`, optionally returning a single decoded key.

    Parameters:
        charID (number|string)
            The character ID whose data should be read.
        key (string|nil)
            Optional data key to read.

    Returns:
        table|any|false|nil
            The decoded data table when no key is provided, the decoded value for a key, false when a requested key does not exist, or nil when the character ID is invalid.

    Example Usage:
        ```lua
        local value = lia.char.getCharDataRaw(charID, "customKey")
        ```

    Realm:
        Server
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
        Finds the online player currently using a character ID.

    Parameters:
        ID (number|string)
            The character ID to search for.

    Returns:
        Player|nil
            The owning player if the character is active online.

    Example Usage:
        ```lua
        local owner = lia.char.getOwnerByID(charID)
        ```

    Realm:
        Shared
]]
function lia.char.getOwnerByID(ID)
    ID = tonumber(ID)
    for client, character in pairs(lia.char.getAll()) do
        if character and character:getID() == ID then return client end
    end
end

--[[
    Purpose:
        Finds the active character for an online player by SteamID or SteamID64.

    Parameters:
        steamID (string)
            The SteamID or SteamID64 to search for.

    Returns:
        Character|nil
            The active character belonging to the matching online player.

    Example Usage:
        ```lua
        local character = lia.char.getBySteamID("STEAM_0:1:12345")
        ```

    Realm:
        Shared
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
        Gets the display color for a player's current character class, falling back to the player's team color.

    Parameters:
        client (Player)
            The player whose character or team color should be resolved.

    Returns:
        Color
            The class color when available, otherwise the team color.

    Example Usage:
        ```lua
        local color = lia.char.getTeamColor(client)
        ```

    Realm:
        Shared
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
            Creates a new character database record, builds the character object, creates its default inventory, caches it, and stores any additional character data.

        Parameters:
            data (table)
                Character creation data including name, description, model, SteamID, faction, money, recognition, and optional extra data.
            callback (function|nil)
                Optional callback called with the new character ID after creation completes.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.char.create(data, function(charID)
                print("Created character", charID)
            end)
            ```

        Realm:
            Server
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
            Restores all characters belonging to a player, or one specific character when an ID is provided, from the character database.

        Parameters:
            client (Player)
                The player whose characters should be restored.
            callback (function|nil)
                Optional callback called with a list of restored character IDs.
            id (number|nil)
                Optional character ID to restore instead of all characters for the player.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.char.restore(client, function(characters)
                PrintTable(characters)
            end)
            ```

        Realm:
            Server
    ]]
    function lia.char.restore(client, callback, id)
        local function charDevLog(...)
            if not lia.devmode then return end
            local parts = {...}
            for i = 1, #parts do
                parts[i] = tostring(parts[i])
            end

            MsgC(Color(83, 143, 239), "[Lilia] ", Color(255, 200, 0), "[DevMode] ", Color(255, 255, 255), table.concat(parts, " "), "\n")
        end

        local restoreStarted = SysTime()
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
        if lia.devmode then charDevLog("Restoring characters for", steamID, id and ("char " .. tostring(id)) or "(all chars)") end
        lia.db.query(query, function(data)
            local characters = {}
            local results = data or {}
            local done = 0
            if lia.devmode then charDevLog("Character restore query returned", tostring(#results), "rows for", steamID) end
            if #results == 0 then
                if callback then callback(characters) end
                return
            end

            for _, v in ipairs(results) do
                local charStarted = SysTime()
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
                    if lia.devmode then charDevLog(string.format("Character %s restored with %s inventories in %.3fs", tostring(charId), tostring(#inventories), SysTime() - charStarted)) end
                    if done == #results and callback then callback(characters) end
                    if done == #results and lia.devmode then charDevLog(string.format("Finished restoring %s character(s) for %s in %.3fs", tostring(#results), steamID, SysTime() - restoreStarted)) end
                end)
            end
        end)
    end

    --[[
        Purpose:
            Unloads every loaded character listed on a player.

        Parameters:
            client (Player)
                The player whose character list should be cleaned up.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.char.cleanUpForPlayer(client)
            ```

        Realm:
            Server
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
            Deletes a character from active memory and persistent storage, removes related character data and inventories, and synchronizes affected players.

        Parameters:
            id (number)
                The character ID to delete.
            client (Player|nil)
                Optional player associated with the deletion.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.char.delete(charID, client)
            ```

        Realm:
            Server
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
                hook.Run("SyncCharList", ply)
            end
        end
    end

    --[[
        Purpose:
            Reads the ban state stored on a character record.

        Parameters:
            charID (number|string)
                The character ID to check.

        Returns:
            number|nil
                The stored banned value, or nil when the character ID is invalid or no row exists.

        Example Usage:
            ```lua
            local banned = lia.char.getCharBanned(charID)
            ```

        Realm:
            Server
    ]]
    function lia.char.getCharBanned(charID)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local result = sql.Query("SELECT banned FROM lia_characters WHERE id = " .. charIDsafe .. " LIMIT 1")
        if istable(result) and result[1] then return tonumber(result[1].banned) or 0 end
    end

    --[[
        Purpose:
            Updates a registered character variable field or custom character data value in persistent storage and mirrors the change to a loaded character when available.

        Parameters:
            charID (number|string)
                The character ID to update.
            field (string)
                The registered character variable or custom data key to update.
            value (any)
                The value to store.

        Returns:
            boolean|nil
                True when an update path completes, false when the update cannot be completed, or nil when the character ID or field is invalid.

        Example Usage:
            ```lua
            lia.char.setCharDatabase(charID, "money", 250)
            lia.char.setCharDatabase(charID, "customKey", "value")
            ```

        Realm:
            Server
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
                        if IsValid(client) and client:getChar() == character then lia.util.applyBodygroups(client, character:getBodygroups()) end
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
            Saves a loaded character, clears replicated character data for its player, cleans up inventories, removes it from the loaded cache, and runs cleanup hooks.

        Parameters:
            charID (number)
                The character ID to unload.

        Returns:
            boolean
                True when the character was unloaded, or false when the character was not loaded.

        Example Usage:
            ```lua
            lia.char.unloadCharacter(charID)
            ```

        Realm:
            Server
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
            Unloads loaded characters from a player's character list except for the active character ID.

        Parameters:
            client (Player)
                The player whose unused characters should be unloaded.
            activeCharID (number)
                The character ID that should remain loaded.

        Returns:
            number
                The number of characters unloaded.

        Example Usage:
            ```lua
            local count = lia.char.unloadUnusedCharacters(client, activeCharID)
            ```

        Realm:
            Server
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
            Loads one character from the database, validates access when needed, restores inventories, caches the character, and returns it through a callback.

        Parameters:
            charID (number)
                The character ID to load.
            client (Player|nil)
                The player requesting or owning the character.
            callback (function|nil)
                Optional callback called with the loaded character or nil when loading fails.

        Returns:
            nil
                This function does not return a value.

        Example Usage:
            ```lua
            lia.char.loadSingleCharacter(charID, client, function(character)
                if character then print(character:getName()) end
            end)
            ```

        Realm:
            Server
    ]]
    function lia.char.loadSingleCharacter(charID, client, callback)
        if lia.char.loaded[charID] then
            if callback then callback(lia.char.loaded[charID]) end
            return
        end

        if client and not table.HasValue(client.liaCharList or {}, charID) then
            lia.db.selectOne("faction", "characters", "id = " .. charID):next(function(result)
                local isStaffFaction = result and (result.faction == "staff" or tonumber(result.faction) == FACTION_STAFF) or false
                local canLoadStaffCharacter = isStaffFaction and client:hasPrivilege("createStaffCharacter")
                lia.debug("[Permissions]", "Permission Check for lia.char.getCharacter staff fallback", "dbResultExists=", tostring(result ~= nil), "targetFactionIsStaff=", tostring(isStaffFaction), "hasPrivilege(createStaffCharacter)=", tostring(client:hasPrivilege("createStaffCharacter")), "finalResult=", tostring(canLoadStaffCharacter))
                if not canLoadStaffCharacter then
                    if callback then callback(nil) end
                    return
                end

                lia.db.selectOne("*", "characters", "id = " .. charID):next(function(charResult)
                    if not charResult then
                        if callback then callback(nil) end
                        return
                    end

                    local charData = {}
                    for k, v in pairs(lia.char.vars) do
                        if v.field and charResult[v.field] then
                            local value = tostring(charResult[v.field])
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
            end)
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
