--[[
    Folder: Libraries
    File: char.md
]]
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
        Retrieve a character by ID from cache or request a load if missing.

    When Called:
        Anytime code needs a character object by ID (selection, networking, admin tools).

    Parameters:
        charID (number)
            Character database ID to fetch.
        client (Player|nil)
            Owning player; only used server-side when loading.
        callback (function|nil)
            Invoked with the character once available (server cached immediately, otherwise after load/network).

    Returns:
        table|nil
            The character object if already cached; otherwise nil while loading.

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.char.getCharacter(targetID, ply, function(char)
            if char then
                char:sync(ply)
            end
        end)
        ```
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
        Return a table of all players currently holding loaded characters.

    When Called:
        For admin panels, diagnostics, or mass operations over active characters.

    Parameters:
        None.

    Returns:
        table
            Keyed by Player with values of their active character objects.

    Realm:
        Shared

    Example Usage:
        ```lua
        for ply, char in pairs(lia.char.getAll()) do
            print(ply:Name(), char:getName())
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
        Check if a character ID currently exists in the local cache.

    When Called:
        Before loading or accessing a character to avoid duplicate work.

    Parameters:
        charID (number)
            Character database ID to test.

    Returns:
        boolean
            True if the character is cached, otherwise false.

    Realm:
        Shared

    Example Usage:
        ```lua
        if not lia.char.isLoaded(id) then
            lia.char.getCharacter(id)
        end
        ```
]]
function lia.char.isLoaded(charID)
    return lia.char.loaded[charID] ~= nil
end

--[[
    Purpose:
        Insert a character into the cache and resolve any pending requests.

    When Called:
        After successfully loading or creating a character object.

    Parameters:
        id (number)
            Character database ID.
        character (table)
            Character object to store.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.char.addCharacter(char:getID(), char)
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
        Remove a character from the local cache.

    When Called:
        After a character is deleted, unloaded, or no longer needed.

    Parameters:
        id (number)
            Character database ID to remove.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.char.removeCharacter(charID)
        ```
]]
function lia.char.removeCharacter(id)
    lia.char.loaded[id] = nil
end

--[[
    Purpose:
        Construct a character object and populate its variables with provided data or defaults.

    When Called:
        During character creation or when rebuilding a character from stored data.

    Parameters:
        data (table)
            Raw character data keyed by variable name.
        id (number|nil)
            Database ID; defaults to 0 when nil.
        client (Player|nil)
            Owning player entity, if available.
        steamID (string|nil)
            SteamID string used when no player entity is provided.

    Returns:
        table
            New character object.

    Realm:
        Shared

    Example Usage:
        ```lua
        local char = lia.char.new(row, row.id, ply)
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
        Register a hook function that runs when a specific character variable changes.

    When Called:
        When modules need to react to updates of a given character variable.

    Parameters:
        varName (string)
            Character variable name.
        hookName (string)
            Unique identifier for the hook.
        func (function)
            Callback invoked with (character, oldValue, newValue).

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.char.hookVar("money", "OnMoneyChanged", function(char, old, new)
            hook.Run("OnCharMoneyChanged", char, old, new)
        end)
        ```
]]
function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

--[[
    Purpose:
        Register a character variable and generate accessor/mutator helpers with optional networking.

    When Called:
        During schema load to declare character fields such as name, money, or custom data.

    Parameters:
        key (string)
            Variable identifier.
        data (table)
            Configuration table defining defaults, validation, networking, and callbacks.

    Returns:
        nil

    Realm:
        Shared

    Example Usage:
        ```lua
        lia.char.registerVar("title", {
            field = "title",
            fieldType = "string",
            default = "",
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
        Read character data key/value pairs stored in the chardata table.

    When Called:
        When modules need arbitrary persisted data for a character, optionally scoped to a single key.

    Parameters:
        charID (number)
            Character database ID to query.
        key (string|nil)
            Optional specific data key to return.

    Returns:
        table|any|nil
            Table of all key/value pairs, a single value when key is provided, or nil if not found/invalid.

    Realm:
        Shared

    Example Usage:
        ```lua
        local prestige = lia.char.getCharData(charID, "prestige")
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
        Retrieve raw character data from chardata without touching the cache.

    When Called:
        When a direct database read is needed, bypassing any loaded character state.

    Parameters:
        charID (number)
            Character database ID to query.
        key (string|nil)
            Optional key for a single value; omit to fetch all.

    Returns:
        any|table|false|nil
            Decoded value for the key, a table of all key/value pairs, false if a keyed lookup is missing, or nil on invalid input.

    Realm:
        Shared

    Example Usage:
        ```lua
        local allData = lia.char.getCharDataRaw(charID)
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
        Find the player entity that owns a given character ID.

    When Called:
        When needing to target or notify the current owner of a loaded character.

    Parameters:
        ID (number)
            Character database ID.

    Returns:
        Player|nil
            Player who currently has the character loaded, or nil if none.

    Realm:
        Shared

    Example Usage:
        ```lua
        local owner = lia.char.getOwnerByID(charID)
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
        Get the active character of an online player by SteamID/SteamID64.

    When Called:
        For lookups across connected players when only a Steam identifier is known.

    Parameters:
        steamID (string)
            SteamID or SteamID64 string.

    Returns:
        table|nil
            Character object if the player is online and has one loaded, else nil.

    Realm:
        Shared

    Example Usage:
        ```lua
        local char = lia.char.getBySteamID(targetSteamID)
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
        Return the team/class color for a player, falling back to team color.

    When Called:
        Whenever UI or drawing code needs a consistent color for the player's current class.

    Parameters:
        client (Player)
            Player whose color is requested.

    Returns:
        table
            Color table sourced from class definition or team color.

    Realm:
        Shared

    Example Usage:
        ```lua
        local color = lia.char.getTeamColor(ply)
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
        Create a new character row, build its object, and initialize inventories.

    When Called:
        During character creation after validation to persist and ready the new character.

    Parameters:
        data (table)
            Prepared character data including steamID, faction, and name.
        callback (function|nil)
            Invoked with the new character ID once creation finishes.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.create(payload, function(charID) print("created", charID) end)
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
        Load all characters for a player (or a specific ID) into memory and inventory.

    When Called:
        On player connect or when an admin requests to restore a specific character.

    Parameters:
        client (Player)
            Player whose characters should be loaded.
        callback (function|nil)
            Invoked with a list of loaded character IDs once complete.
        id (number|nil)
            Optional single character ID to restrict the load.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.restore(ply, function(chars) print("loaded", #chars) end)
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
        Unload and save all characters cached for a player.

    When Called:
        When a player disconnects or is cleaned up to free memory and inventories.

    Parameters:
        client (Player)
            Player whose cached characters should be unloaded.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.cleanUpForPlayer(ply)
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
        Delete a character, its data, and inventories, and notify affected players.

    When Called:
        By admin or player actions that permanently remove a character.

    Parameters:
        id (number)
            Character database ID to delete.
        client (Player|nil)
            Player requesting deletion, if any.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.delete(charID, ply)
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
                hook.Run("SyncCharList", ply)
            end
        end
    end

    --[[
    Purpose:
        Check the ban state of a character in the database.

    When Called:
        Before allowing a character to load or when displaying ban info.

    Parameters:
        charID (number)
            Character database ID.

    Returns:
        number|nil
            Ban flag/value (0 if not banned), or nil on invalid input.

    Realm:
        Server

    Example Usage:
        ```lua
        if lia.char.getCharBanned(id) ~= 0 then return end
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
        Write a character variable to the database and update any loaded instance.

    When Called:
        Whenever persistent character fields or custom data need to be changed.

    Parameters:
        charID (number)
            Character database ID.
        field (string)
            Character var or custom data key.
        value (any)
            Value to store; nil removes custom data entries.

    Returns:
        boolean
            True on success, false on immediate failure.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.setCharDatabase(charID, "money", newAmount)
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
        Save and unload a character from memory, clearing associated data vars.

    When Called:
        When a character is no longer active or needs to be freed from cache.

    Parameters:
        charID (number)
            Character database ID to unload.

    Returns:
        boolean
            True if a character was unloaded, false if none was loaded.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.unloadCharacter(charID)
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
        Unload all cached characters for a player except the currently active one.

    When Called:
        After character switches to reduce memory and inventory usage.

    Parameters:
        client (Player)
            Player whose cached characters should be reduced.
        activeCharID (number)
            Character ID to keep loaded.

    Returns:
        number
            Count of characters that were unloaded.

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.unloadUnusedCharacters(ply, newCharID)
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
        Load a single character from the database, building inventories and caching it.

    When Called:
        When a specific character is selected, restored, or fetched server-side.

    Parameters:
        charID (number)
            Character database ID to load.
        client (Player|nil)
            Owning player, used for permission checks and inventory linking.
        callback (function|nil)
            Invoked with the loaded character or nil on failure.

    Returns:
        nil

    Realm:
        Server

    Example Usage:
        ```lua
        lia.char.loadSingleCharacter(id, ply, function(char) if char then char:sync(ply) end end)
        ```
]]
    function lia.char.loadSingleCharacter(charID, client, callback)
        if lia.char.loaded[charID] then
            if callback then callback(lia.char.loaded[charID]) end
            return
        end

        if client and not table.HasValue(client.liaCharList or {}, charID) then
            lia.db.selectOne("faction", "characters", "id = " .. charID):next(function(result)
                if not (result and result.faction == FACTION_STAFF and client:hasPrivilege("createStaffCharacter")) then
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
