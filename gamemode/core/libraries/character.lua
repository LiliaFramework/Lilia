local characterMeta = lia.meta.character or {}
lia.char = lia.char or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.names = lia.char.names or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.vars = lia.char.vars or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
debug.getregistry().Character = lia.meta.character
if SERVER and #lia.char.names < 1 then
    lia.db.query("SELECT _id, _name FROM lia_characters", function(data)
        if data and #data > 0 then
            for _, v in pairs(data) do
                lia.char.names[v._id] = v._name
            end
        end
    end)
end

--[[
    lia.char.new(data, id, client, steamID)

    Description:
        Creates a new character instance with default variables and metatable.

    Parameters:
        data (table) – Table of character variables.
        id (number) – Character ID.
        client (Player) – Player entity.
        steamID (string) – SteamID64 string if client is not valid.

    Realm:
        Shared

    Returns:
        character (table) – New character object.
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
    if IsValid(client) or steamID then character.steamID = IsValid(client) and client:SteamID64() or steamID end
    return character
end

--[[
    lia.char.hookVar(varName, hookName, func)

    Description:
        Registers a hook function for when a character variable changes.

    Parameters:
        varName (string) – Variable name to hook.
        hookName (string) – Unique hook identifier.
        func (function) – Function to call on variable change.

    Realm:
        Shared

    Returns:
        None
]]
function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

--[[
    lia.char.registerVar(key, data)

    Description:
        Registers a character variable with metadata and generates accessor methods.

    Parameters:
        key (string) – Variable key.
        data (table) – Variable metadata including default, validation, networking, etc.

    Realm:
        Shared

    Returns:
        None
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
                netstream.Start(self.player, "charSet", key, value, sendID and self:getID() or nil)
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        else
            characterMeta["set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(nil, "charSet", key, value, self:getID())
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
    field = "_name",
    default = "John Doe",
    index = 1,
    onValidate = function(value, data, client)
        local name, override = hook.Run("GetDefaultCharName", client, data.faction, data)
        if isstring(name) and override then return true end
        if not isstring(value) or not value:find("%S") then return false, "invalid", "name" end
        local allowExistNames = lia.config.get("AllowExistNames", true)
        if CLIENT and #lia.char.names < 1 and not allowExistNames then
            netstream.Start("liaCharFetchNames")
            netstream.Hook("liaCharFetchNames", function(data) lia.char.names = data end)
        end

        if not lia.config.get("AllowExistNames", true) then
            for _, v in pairs(lia.char.names) do
                if v == value then return false, "A character with this name already exists." end
            end
        end
        return true
    end,
    onAdjust = function(client, data, value, newData)
        local name, override = hook.Run("GetDefaultCharName", client, data.faction, data)
        if isstring(name) and override then
            newData.name = name
        else
            newData.name = string.Trim(value):sub(1, 70)
        end
    end,
})

lia.char.registerVar("desc", {
    field = "_desc",
    default = "Please enter your description with a minimum of " .. lia.config.get("MinDescLen", 16) .. " characters!",
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
    field = "_model",
    default = "models/error.mdl",
    onSet = function(character, value)
        local oldVar = character:getModel()
        local client = character:getPlayer()
        if IsValid(client) and client:getChar() == character then client:SetModel(value) end
        character.vars.model = value
        netstream.Start(nil, "charSet", "model", character.vars.model, character:getID())
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
                newData.data = newData.data or {}
                newData.data.skin = model[2] or 0
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

                newData.data.groups = groups
            end
        end
    end
})

lia.char.registerVar("class", {
    noDisplay = true,
})

lia.char.registerVar("faction", {
    field = "_faction",
    default = "Citizen",
    onSet = function(character, value)
        local oldVar = character:getFaction()
        local faction = lia.faction.indices[value]
        assert(faction, tostring(value) .. " is an invalid faction index")
        local client = character:getPlayer()
        client:SetTeam(value)
        character.vars.faction = faction.uniqueID
        netstream.Start(nil, "charSet", "faction", character.vars.faction, character:getID())
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
    field = "_money",
    default = 0,
    isLocal = true,
    noDisplay = true
})

lia.char.registerVar("data", {
    default = {},
    isLocal = true,
    noDisplay = true,
    field = "_data",
    onSet = function(character, key, value, noReplication, receiver)
        local data = character:getData()
        local client = character:getPlayer()
        data[key] = value
        if not noReplication and IsValid(client) then netstream.Start(receiver or client, "charData", character:getID(), key, value) end
        character.vars.data = data
    end,
    onGet = function(character, key, default)
        local data = character.vars.data or {}
        if key then
            if not data then return default end
            local value = data[key]
            return value == nil and default or value
        else
            return default or data
        end
    end
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

            netstream.Start(receiver or client, "charVar", key, value, id)
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
    field = "_attribs",
    default = {},
    isLocal = true,
    index = 4,
    onValidate = function(value, _, client)
        if value ~= nil then
            if istable(value) then
                local count = 0
                for k, v in pairs(value) do
                    local max = hook.Run("GetAttributeStartingMax", client, k)
                    if max and v > max then return false, lia.attribs.list[k].name .. " too high" end
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

lia.char.registerVar("RecognizedAs", {
    field = "recognized_as",
    default = {},
    noDisplay = true
})

--[[
    lia.char.getCharData(charID, key)

    Description:
        Retrieves character data JSON from the database as a Lua table.

    Parameters:
        charID (number|string) – Character ID.
        key (string) – Specific data key to return (optional).

    Realm:
        Shared

    Returns:
        value (any) – Data value or full table if no key provided.
]]
function lia.char.getCharData(charID, key)
    local charIDsafe = tonumber(charID)
    if not charIDsafe then return end
    local findData = sql.Query("SELECT * FROM lia_characters WHERE _id=" .. charIDsafe)
    if not findData or not findData[1] then return false end
    local data = util.JSONToTable(findData[1]._data) or {}
    if key then return data[key] end
    return data
end

--[[
    lia.char.getCharDataRaw(charID, key)

    Description:
        Retrieves raw character database row or specific column.

    Parameters:
        charID (number|string) – Character ID.
        key (string) – Specific column name to return (optional).

    Realm:
        Shared

    Returns:
        row (table|any) – Full row table or column value.
]]
function lia.char.getCharDataRaw(charID, key)
    local charIDsafe = tonumber(charID)
    if not charIDsafe then return end
    local findData = sql.Query("SELECT * FROM lia_characters WHERE _id=" .. charIDsafe)
    if not findData or not findData[1] then return false end
    if key then return findData[1][key] end
    return findData[1]
end

--[[
    lia.char.getOwnerByID(ID)

    Description:
        Finds the player entity that owns the character with the given ID.

    Parameters:
        ID (number|string) – Character ID.

    Realm:
        Shared

    Returns:
        Player – Player entity or nil if not found.
]]
function lia.char.getOwnerByID(ID)
    ID = tonumber(ID)
    for client, character in pairs(lia.char.getAll()) do
        if character and character:getID() == ID then return client end
    end
end

--[[
    lia.char.getBySteamID(steamID)

    Description:
        Retrieves a character object by SteamID or SteamID64.

    Parameters:
        steamID (string) – SteamID or SteamID64.

    Realm:
        Shared

    Returns:
        Character – Character object or nil.
]]
function lia.char.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    for _, client in player.Iterator() do
        local sid = client:SteamID()
        local sid64 = client:SteamID64()
        if (sid == steamID or sid64 == steamID) and client:getChar() then return client:getChar() end
    end
end

--[[
    lia.char.getAll()

    Description:
        Returns a table mapping all players to their loaded character objects.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        table – Map of Player to Character.
]]
function lia.char.getAll()
    local charTable = {}
    for _, client in player.Iterator() do
        if client:getChar() then charTable[client] = client:getChar() end
    end
    return charTable
end

--[[
    lia.char.GetTeamColor(client)

    Description:
        Determines the team color for a client based on their character class or default team.

    Parameters:
        client (Player) – Player entity.

    Realm:
        Shared

    Returns:
        Color – Team or class color.
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
        lia.char.create(data, callback)

        Description:
            Inserts a new character into the database and sets up default inventory.

        Parameters:
            data (table) – Character creation data.
            callback (function) – Callback receiving new character ID.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.char.create(data, callback)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        data.money = data.money or lia.config.get("DefaultMoney")
        lia.db.insertTable({
            _name = data.name or "",
            _desc = data.desc or "",
            _model = data.model or "models/error.mdl",
            _schema = SCHEMA and SCHEMA.folder or "lilia",
            _createTime = timeStamp,
            _lastJoinTime = timeStamp,
            _steamID = data.steamID,
            _faction = data.faction or L("unknown"),
            _money = data.money,
            recognized_as = "",
            _data = data.data
        }, function(_, charID)
            local client
            for _, v in player.Iterator() do
                if v:SteamID64() == data.steamID then
                    client = v
                    break
                end
            end

            local character = lia.char.new(data, charID, client, data.steamID)
            character.vars.inv = {}
            hook.Run("CreateDefaultInventory", character):next(function(inventory)
                character.vars.inv[1] = inventory
                lia.char.loaded[charID] = character
                if callback then callback(charID) end
            end)
        end)
    end

    --[[
        lia.char.restore(client, callback, id)

        Description:
            Loads characters for a client from the database, optionally filtering by ID.

        Parameters:
            client (Player) – Player entity.
            callback (function) – Callback receiving list of character IDs.
            id (number) – Specific character ID to restore (optional).

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.char.restore(client, callback, id)
        local steamID64 = client:SteamID64()
        local fields = {"_id"}
        for _, var in pairs(lia.char.vars) do
            if var.field then fields[#fields + 1] = var.field end
        end

        fields = table.concat(fields, ", ")
        local condition = "_schema = '" .. lia.db.escape(SCHEMA.folder) .. "' AND _steamID = " .. steamID64
        if id then condition = condition .. " AND _id = " .. id end
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
                local id = tonumber(v._id)
                if not id then
                    ErrorNoHalt("[Lilia] Attempt to load character '" .. (data._name or "nil") .. "' with invalid ID!")
                    continue
                end

                local data = {}
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

                        data[k2] = value
                    end
                end

                characters[#characters + 1] = id
                local character = lia.char.new(data, id, client)
                hook.Run("CharRestored", character)
                character.vars.inv = {}
                lia.inventory.loadAllFromCharID(id):next(function(inventories)
                    if #inventories == 0 then
                        local promise = hook.Run("CreateDefaultInventory", character)
                        assert(promise ~= nil, "No default inventory available")
                        return promise:next(function(inventory)
                            assert(inventory ~= nil, "No default inventory available")
                            return {inventory}
                        end)
                    end
                    return inventories
                end, function(err)
                    lia.information("Failed to load inventories for " .. tostring(id))
                    lia.information(err)
                    if IsValid(client) then client:ChatPrint("A server error occured while loading your" .. " inventories. Check server log for details.") end
                end):next(function(inventories)
                    character.vars.inv = inventories
                    lia.char.loaded[id] = character
                    done = done + 1
                    if done == #results and callback then callback(characters) end
                end)
            end
        end)
    end

    --[[
        lia.char.cleanUpForPlayer(client)

        Description:
            Cleans up loaded characters and inventories for a player on disconnect.

        Parameters:
            client (Player) – Player entity.

        Realm:
            Server

        Returns:
            None
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
            netstream.Start(client, "charKick", nil, true)
        end
    end

    --[[
        lia.char.delete(id, client)

        Description:
            Deletes a character by ID from the database, cleans up and notifies players.

        Parameters:
            id (number) – Character ID to delete.
            client (Player) – Player entity reference.

        Realm:
            Server

        Returns:
            None
    ]]
    function lia.char.delete(id, client)
        assert(isnumber(id), "id must be a number")
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
        lia.db.query("DELETE FROM lia_characters WHERE _id = " .. id)
        lia.db.query("SELECT _invID FROM lia_inventories WHERE _charID = " .. id, function(data)
            if data then
                for _, inventory in ipairs(data) do
                    lia.inventory.deleteByID(tonumber(inventory._invID))
                end
            end
        end)

        hook.Run("OnCharDelete", client, id)
    end

    --[[
        lia.char.setCharData(charID, key, val)

        Description:
            Updates a character's JSON data field in the database and loaded object.

        Parameters:
            charID (number|string) – Character ID.
            key (string) – Data key.
            val (any) – New value.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.
    ]]
    function lia.char.setCharData(charID, key, val)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local data = lia.char.getCharData(charID)
        if not data then return false end
        data[key] = val
        local setQ = "UPDATE lia_characters SET _data=" .. sql.SQLStr(util.TableToJSON(data)) .. " WHERE _id=" .. charIDsafe
        if not sql.Query(setQ) then
            lia.information("lia.char.setCharData SQL Error, q=" .. setQ .. ", Error = " .. sql.LastError())
            return false
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setData(key, val) end
        return true
    end

    --[[
        lia.char.setCharName(charID, name)

        Description:
            Updates the character's name in the database and loaded object.

        Parameters:
            charID (number|string) – Character ID.
            name (string) – New character name.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.
    ]]
    function lia.char.setCharName(charID, name)
        local charIDsafe = tonumber(charID)
        if not name or not charID then return end
        local setQ = "UPDATE lia_characters SET _name=" .. sql.SQLStr(name) .. " WHERE _id=" .. charIDsafe
        if not sql.Query(setQ) then
            return false
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setName(name) end
        return true
    end

    --[[
        lia.char.setCharModel(charID, model, bg)

        Description:
            Updates the character's model and bodygroups in the database and in-game.

        Parameters:
            charID (number|string) – Character ID.
            model (string) – Model path.
            bg (table) – Bodygroup table list.

        Realm:
            Server

        Returns:
            boolean – True on success, false on failure.
    ]]
    function lia.char.setCharModel(charID, model, bg)
        local charIDsafe = tonumber(charID)
        if not model or not charID then return end
        local setQ = "UPDATE lia_characters SET _model=" .. sql.SQLStr(model) .. " WHERE _id=" .. charIDsafe
        if not sql.Query(setQ) then
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
end
