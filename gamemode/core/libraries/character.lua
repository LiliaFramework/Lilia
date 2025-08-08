--[[
# Character Library

This page documents the functions for working with character data and management.

---

## Overview

The character library provides functions for creating, managing, and manipulating character data within the Lilia framework. It handles character creation, loading, saving, and provides various utility functions for working with character variables and metadata. Characters are the core data structure that represents a player's in-game identity and progress.

The library features include:
- **Character Lifecycle Management**: Complete creation, loading, saving, and deletion of character data
- **Variable System**: Dynamic character variables with hooks for change detection and validation
- **Database Integration**: Automatic persistence of character data with optimized query handling
- **Multi-Character Support**: Players can have multiple characters with independent data and progression
- **Character Validation**: Built-in validation for character data integrity and consistency
- **Hook System**: Extensive hook system for custom character logic and data manipulation
- **Networking**: Efficient client-server synchronization of character data and changes
- **Memory Management**: Optimized memory usage with lazy loading and caching strategies
- **Error Handling**: Robust error handling for database failures and data corruption
- **Performance Optimization**: Efficient query patterns and data structure management
- **Cross-Realm Support**: Works seamlessly on both client and server sides
- **Plugin Integration**: Easy integration with external character-related addons and systems

The character system is the foundation of the role-playing experience in Lilia, providing a flexible and extensible framework for character progression, customization, and data management. It supports complex character attributes, relationships, and persistent data across server sessions.
]]
local characterMeta = lia.meta.character or {}
lia.char = lia.char or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.names = lia.char.names or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.vars = lia.char.vars or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
if SERVER and #lia.char.names < 1 then
    lia.db.query("SELECT id, name FROM lia_characters", function(data)
        if data and #data > 0 then
            for _, v in pairs(data) do
                lia.char.names[v.id] = v.name
            end
        end
    end)
end

--[[
    lia.char.new

    Purpose:
        Creates a new character object with the provided data, ID, client, and SteamID.
        Initializes all registered character variables with their default values if not provided in data.

    Parameters:
        data (table)      - Table containing character variable values.
        id (number)       - The unique ID for the character.
        client (Player)   - The player entity associated with the character.
        steamID (string)  - The SteamID of the player (optional if client is valid).

    Returns:
        character (table) - The newly created character object.

    Realm:
        Shared.

    Example Usage:
        local charData = {
            name = "John Doe",
            desc = "A mysterious wanderer.",
            model = "models/player/kleiner.mdl",
            faction = "Citizen"
        }
        local newChar = lia.char.new(charData, 1234, somePlayer, somePlayer:SteamID())
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
    lia.char.hookVar

    Purpose:
        Registers a hook function to be called when a specific character variable changes.

    Parameters:
        varName (string)  - The name of the character variable to hook.
        hookName (string) - The unique name for this hook.
        func (function)   - The function to call when the variable changes.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        lia.char.hookVar("money", "OnMoneyChanged", function(character, oldValue, newValue)
            print("Money changed from", oldValue, "to", newValue)
        end)
]]
function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

--[[
    lia.char.registerVar

    Purpose:
        Registers a new character variable with the system, defining its behavior, default value, and networking.

    Parameters:
        key (string)  - The variable's unique key.
        data (table)  - Table describing the variable's properties (default, onSet, onGet, etc).

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        lia.char.registerVar("karma", {
            field = "karma",
            fieldType = "integer",
            default = 0,
            onSet = function(character, value)
                character.vars.karma = value
            end,
            onGet = function(character, default)
                return character.vars.karma or default or 0
            end
        })
]]
function lia.char.registerVar(key, data)
    lia.char.vars[key] = data
    data.index = data.index or table.Count(lia.char.vars)
    local upperName = key:sub(1, 1):upper() .. key:sub(2)
    if SERVER and not data.isNotModifiable then
        if data.onSet then
            characterMeta["set" .. upperName] = data.onSet
        elseif data.noNetworking then
            characterMeta["set" .. upperName] = function(self, value) self.vars[key] = value end
        elseif data.isLocal then
            characterMeta["set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true
                if curChar and curChar == self then sendID = false end
                local oldVar = self.vars[key]
                self.vars[key] = value
                net.Start("charSet")
                net.WriteString(key)
                net.WriteType(value)
                net.WriteType(sendID and self:getID() or nil)
                net.Send(self.player)
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        else
            characterMeta["set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                net.Start("charSet")
                net.WriteString(key)
                net.WriteType(value)
                net.WriteType(self:getID())
                net.Broadcast()
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        end
    end

    if data.onGet then
        characterMeta["get" .. upperName] = data.onGet
    else
        characterMeta["get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end
            return default
        end
    end

    characterMeta.vars[key] = data.default
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
        local allowExistNames = lia.config.get("AllowExistNames", true)
        if CLIENT and #lia.char.names < 1 and not allowExistNames then
            net.Start("liaCharFetchNames")
            net.SendToServer()
            net.Receive("liaCharFetchNames", function() lia.char.names = net.ReadTable() end)
        end

        if not lia.config.get("AllowExistNames", true) then
            for _, v in pairs(lia.char.names) do
                if v == value then return false, "nameAlreadyExists" end
            end
        end
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
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction)
        local minLength = lia.config.get("MinDescLen", 16)
        if isstring(desc) and override then return true end
        if not value or #value:gsub("%s", "") < minLength then return false, "descMinLen", minLength end
        return true
    end,
    onAdjust = function(client, data, value, newData)
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction)
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
        net.Start("charSet")
        net.WriteString("model")
        net.WriteType(character.vars.model)
        net.WriteType(character:getID())
        net.Broadcast()
        hook.Run("PlayerModelChanged", client, value)
        hook.Run("OnCharVarChanged", character, "model", oldVar, value)
    end,
    onGet = function(character, default) return character.vars.model or default end,
    index = 3,
    onValidate = function(_, data)
        local faction = lia.faction.indices[data.faction]
        if faction then
            if not data.model or not faction.models[data.model] then return false, "needModel" end
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
        net.Start("charSet")
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

        net.Start("charSet")
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
        net.Start("charSet")
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
    isLocal = true,
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

            net.Start("charVar")
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
    onValidate = function(value, _, client)
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
    shouldDisplay = function() return table.Count(lia.attribs.list) > 0 end
})

lia.char.registerVar("recognition", {
    field = "recognition",
    fieldType = "text",
    default = "",
    isLocal = true,
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
    isLocal = true,
    noDisplay = true
})

lia.char.registerVar("ammo", {
    field = "ammo",
    fieldType = "text",
    default = {},
    isLocal = true,
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
    lia.char.getCharData

    Purpose:
        Retrieves character-specific data from the database for a given character ID.
        If a key is provided, returns only that key's value; otherwise, returns all data as a table.

    Parameters:
        charID (number or string) - The character's unique ID.
        key (string)              - (Optional) The specific data key to retrieve.

    Returns:
        value (any) or data (table) - The value for the key, or a table of all key-value pairs.

    Realm:
        Shared.

    Example Usage:
        -- Get all custom data for character ID 1234
        local allData = lia.char.getCharData(1234)
        -- Get only the "reputation" value for character ID 1234
        local rep = lia.char.getCharData(1234, "reputation")
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
    lia.char.getCharDataRaw

    Purpose:
        Retrieves raw character data from the database for a given character ID.
        If a key is provided, returns only that key's value; otherwise, returns all data as a table.

    Parameters:
        charID (number or string) - The character's unique ID.
        key (string)              - (Optional) The specific data key to retrieve.

    Returns:
        value (any) or data (table) - The value for the key, or a table of all key-value pairs.

    Realm:
        Shared.

    Example Usage:
        -- Get all raw data for character ID 5678
        local allRaw = lia.char.getCharDataRaw(5678)
        -- Get only the "notes" value for character ID 5678
        local notes = lia.char.getCharDataRaw(5678, "notes")
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
    lia.char.getOwnerByID

    Purpose:
        Finds and returns the player entity that owns a character with the given ID.

    Parameters:
        ID (number or string) - The character's unique ID.

    Returns:
        client (Player) - The player entity who owns the character, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local owner = lia.char.getOwnerByID(1234)
        if owner then
            print("Character 1234 belongs to", owner:Nick())
        end
]]
function lia.char.getOwnerByID(ID)
    ID = tonumber(ID)
    for client, character in pairs(lia.char.getAll()) do
        if character and character:getID() == ID then return client end
    end
end

--[[
    lia.char.getBySteamID

    Purpose:
        Retrieves the character object associated with a given SteamID.

    Parameters:
        steamID (string) - The SteamID or SteamID64 of the player.

    Returns:
        character (table) - The character object, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local char = lia.char.getBySteamID("STEAM_0:1:12345678")
        if char then
            print("Found character:", char:getName())
        end
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
    lia.char.getAll

    Purpose:
        Returns a table of all currently loaded characters, indexed by their player entity.

    Parameters:
        None.

    Returns:
        charTable (table) - Table of [Player] = character pairs.

    Realm:
        Shared.

    Example Usage:
        for client, char in pairs(lia.char.getAll()) do
            print(client:Nick(), "has character", char:getName())
        end
]]
function lia.char.getAll()
    local charTable = {}
    for _, client in player.Iterator() do
        if client:getChar() then charTable[client] = client:getChar() end
    end
    return charTable
end

--[[
    lia.char.GetTeamColor

    Purpose:
        Returns the color associated with a player's character's class, or their team color if not available.

    Parameters:
        client (Player) - The player entity.

    Returns:
        color (Color) - The color for the character's class or team.

    Realm:
        Shared.

    Example Usage:
        local color = lia.char.GetTeamColor(somePlayer)
        chat.AddText(color, somePlayer:Nick() .. " says hello!")
]]
function lia.char.GetTeamColor(client)
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
        lia.char.create

        Purpose:
            Creates a new character in the database and initializes its inventory and data.
            Calls the callback with the new character's ID when finished.

        Parameters:
            data (table)      - Table containing character creation data (name, desc, model, etc).
            callback (function) - Function to call with the new character's ID.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            local data = {
                name = "Jane Doe",
                desc = "A brave explorer.",
                model = "models/player/alyx.mdl",
                steamID = somePlayer:SteamID(),
                faction = "Citizen"
            }
            lia.char.create(data, function(charID)
                print("Created character with ID:", charID)
            end)
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
                        lia.char.setCharData(charID, k, v)
                    end
                end

                if callback then callback(charID) end
            end)
        end)
    end

    --[[
        lia.char.restore

        Purpose:
            Restores all characters for a given client from the database, loading their inventories and data.
            Calls the callback with a table of character IDs when finished.

        Parameters:
            client (Player)     - The player entity whose characters to restore.
            callback (function) - Function to call with the table of character IDs.
            id (number)         - (Optional) Only restore the character with this ID.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            lia.char.restore(somePlayer, function(charIDs)
                print("Restored characters:", table.concat(charIDs, ", "))
            end)
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
                if charData.recognition then lia.char.setCharData(charId, "rgn", nil) end
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
                    if IsValid(client) then client:notifyLocalized("fixInventoryError") end
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
        lia.char.cleanUpForPlayer

        Purpose:
            Cleans up all character data and inventories for a given player, removing them from memory.

        Parameters:
            client (Player) - The player entity whose characters to clean up.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            lia.char.cleanUpForPlayer(somePlayer)
    ]]
    function lia.char.cleanUpForPlayer(client)
        for _, charID in pairs(client.liaCharList or {}) do
            local character = lia.char.loaded[charID]
            if not character then return end
            lia.inventory.cleanUpForCharacter(character)
            lia.char.loaded[charID] = nil
            hook.Run("CharCleanUp", character)
        end
    end

    local function removePlayer(client)
        if client:getChar() then
            client:KillSilent()
            client:setNetVar("char", nil)
            client:Spawn()
            net.Start("charKick")
            net.WriteType(nil)
            net.WriteBool(true)
            net.Send(client)
        end
    end

    --[[
        lia.char.delete

        Purpose:
            Deletes a character from the database and cleans up all associated data and inventories.
            Optionally removes the player from their character if a client is provided.

        Parameters:
            id (number)      - The unique ID of the character to delete.
            client (Player)  - (Optional) The player entity to remove from the character.

        Returns:
            None.

        Realm:
            Server.

        Example Usage:
            -- Delete character with ID 1234 and remove the player from it
            lia.char.delete(1234, somePlayer)
            -- Delete character with ID 5678 (no player specified)
            lia.char.delete(5678)
    ]]
    function lia.char.delete(id, client)
        assert(isnumber(id), L("idMustBeNumber"))
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
        for index, charID in pairs(client.liaCharList) do
            if charID == id then
                table.remove(client.liaCharList, index)
                break
            end
        end

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
    end

    --[[
        lia.char.setCharData

        Purpose:
            Sets or removes a custom data key-value pair for a character in the database.
            Also updates the in-memory character if loaded.

        Parameters:
            charID (number or string) - The character's unique ID.
            key (string)              - The data key to set.
            val (any)                 - The value to set. If nil, the key is removed.

        Returns:
            true (boolean) - Returns true on success.

        Realm:
            Server.

        Example Usage:
            -- Set a custom "reputation" value for character 1234
            lia.char.setCharData(1234, "reputation", 50)
            -- Remove the "notes" key from character 1234
            lia.char.setCharData(1234, "notes", nil)
    ]]
    function lia.char.setCharData(charID, key, val)
        local charIDsafe = tonumber(charID)
        if not charIDsafe or not key then return end
        if val == nil then
            lia.db.delete("chardata", "charID = " .. charIDsafe .. " AND key = '" .. lia.db.escape(key) .. "'")
        else
            local encoded = pon.encode({val})
            lia.db.upsert({
                charID = charIDsafe,
                key = key,
                value = encoded
            }, "chardata")
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setData(key, val) end
        return true
    end

    --[[
        lia.char.setCharName

        Purpose:
            Sets the name of a character in the database and updates the in-memory character if loaded.

        Parameters:
            charID (number or string) - The character's unique ID.
            name (string)             - The new name to set.

        Returns:
            true (boolean) or false - Returns true on success, false on failure.

        Realm:
            Server.

        Example Usage:
            lia.char.setCharName(1234, "New Name")
    ]]
    function lia.char.setCharName(charID, name)
        local charIDsafe = tonumber(charID)
        if not name or not charID then return end
        local promise = lia.db.updateTable({
            name = name
        }, nil, "characters", "id = " .. charIDsafe)

        if deferred.isPromise(promise) then
            promise:catch(function(err) lia.information(L("charSetDataSQLError", "UPDATE lia_characters SET name", err)) end)
        elseif promise == false then
            return false
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setName(name) end
        return true
    end

    --[[
        lia.char.setCharModel

        Purpose:
            Sets the model and bodygroups of a character in the database and updates the in-memory character if loaded.

        Parameters:
            charID (number or string) - The character's unique ID.
            model (string)            - The new model to set.
            bg (table)                - (Optional) Table of bodygroup data.

        Returns:
            true (boolean) or false - Returns true on success, false on failure.

        Realm:
            Server.

        Example Usage:
            -- Set model and bodygroups for character 1234
            lia.char.setCharModel(1234, "models/player/barney.mdl", {
                {id = 1, value = 2},
                {id = 2, value = 0}
            })
    ]]
    function lia.char.setCharModel(charID, model, bg)
        local charIDsafe = tonumber(charID)
        if not model or not charID then return end
        local promise = lia.db.updateTable({
            model = model
        }, nil, "characters", "id = " .. charIDsafe)

        if deferred.isPromise(promise) then
            promise:catch(function(err) lia.information(L("charSetDataSQLError", "UPDATE lia_characters SET model", err)) end)
        elseif promise == false then
            return false
        end

        local groups = {}
        for _, v in pairs(bg or {}) do
            groups[v.id] = v.value
        end

        lia.char.setCharData(charID, "groups", groups)
        if lia.char.loaded[charIDsafe] then
            lia.char.loaded[charIDsafe]:setModel(model)
            local client = lia.char.loaded[charIDsafe]:getPlayer()
            if IsValid(client) and client:getChar() == lia.char.loaded[charIDsafe] then
                for _, v in pairs(bg or {}) do
                    client:SetBodygroup(v.id, v.value)
                end

                client:SetupHands()
            end
        end
        return true
    end

    --[[
        lia.char.getCharBanned

        Purpose:
            Retrieves the banned status of a character from the database.

        Parameters:
            charID (number or string) - The character's unique ID.

        Returns:
            banned (number) - 0 if not banned, or the ban value.

        Realm:
            Server.

        Example Usage:
            local banned = lia.char.getCharBanned(1234)
            if banned > 0 then
                print("Character 1234 is banned!")
            end
    ]]
    function lia.char.getCharBanned(charID)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local result = sql.Query("SELECT banned FROM lia_characters WHERE id = " .. charIDsafe .. " LIMIT 1")
        if istable(result) and result[1] then return tonumber(result[1].banned) or 0 end
    end

    --[[
        lia.char.setCharBanned

        Purpose:
            Sets the banned status of a character in the database and updates the in-memory character if loaded.

        Parameters:
            charID (number or string) - The character's unique ID.
            value (number or string)  - The ban value to set (0 for unbanned).

        Returns:
            true (boolean) or false - Returns true on success, false on failure.

        Realm:
            Server.

        Example Usage:
            -- Ban character 1234
            lia.char.setCharBanned(1234, 1)
            -- Unban character 1234
            lia.char.setCharBanned(1234, 0)
    ]]
    function lia.char.setCharBanned(charID, value)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        value = tonumber(value) or 0
        local promise = lia.db.updateTable({
            banned = value
        }, nil, "characters", "id = " .. charIDsafe)

        if deferred.isPromise(promise) then
            promise:catch(function(err) lia.information(L("charSetDataSQLError", "UPDATE lia_characters SET banned", err)) end)
        elseif promise == false then
            return false
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setBanned(value) end
        return true
    end
end