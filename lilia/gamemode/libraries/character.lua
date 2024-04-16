
--[[--
Character creation and management.

**NOTE:** For the most part you shouldn't use this library unless you know what you're doing. You can very easily corrupt
character data using these functions!
]]
-- @module lia.char
local charMeta = lia.meta.character or {}
lia.char = lia.char or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.names = lia.char.names or {}
lia.char.varHooks = lia.char.varHooks or {}
lia.char.vars = lia.char.vars or {}
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character

if SERVER then
    if #lia.char.names < 1 then
        lia.db.query("SELECT _id, _name FROM lia_characters", function(data)
            if data and #data > 0 then
                for _, v in pairs(data) do
                    lia.char.names[v._id] = v._name
                end
            end
        end)
    end

    netstream.Hook("liaCharFetchNames", function(client) netstream.Start(client, "liaCharFetchNames", lia.char.names) end)
    hook.Add("liaCharDeleted", "liaCharRemoveName", function(client, character)
        lia.char.names[character:getID()] = nil
        netstream.Start(client, "liaCharFetchNames", lia.char.names)
    end)
else
    netstream.Hook("liaCharFetchNames", function(data) lia.char.names = data end)
    if #lia.char.names < 1 then netstream.Start("liaCharFetchNames") end
end

--- Creates a new empty `Character` object. If you are looking to create a usable character, see `lia.char.create`.
-- @realm shared
-- @internal
-- @tab data Character vars to assign
-- @number id Unique ID of the character
-- @player client Player that will own the character
-- @string[opt=client:SteamID64()] steamID SteamID64 of the player that will own the character
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

function lia.char.hookVar(varName, hookName, func)
    lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}
    lia.char.varHooks[varName][hookName] = func
end

function lia.char.registerVar(key, data)
    lia.char.vars[key] = data
    data.index = data.index or table.Count(lia.char.vars)
    local upperName = key:sub(1, 1):upper() .. key:sub(2)
    if SERVER and not data.isNotModifiable then
        if data.onSet then
            charMeta["set" .. upperName] = data.onSet
            charMeta["Set" .. upperName] = data.onSet
        elseif data.noNetworking then
            charMeta["set" .. upperName] = function(self, value) self.vars[key] = value end
            charMeta["Set" .. upperName] = function(self, value) self.vars[key] = value end
        elseif data.isLocal then
            charMeta["set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true
                if curChar and curChar == self then sendID = false end
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(self.player, "charSet", key, value, sendID and self:getID() or nil)
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end

            charMeta["Set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true
                if curChar and curChar == self then sendID = false end
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(self.player, "charSet", key, value, sendID and self:getID() or nil)
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        else
            charMeta["set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(nil, "charSet", key, value, self:getID())
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end

            charMeta["Set" .. upperName] = function(self, value)
                local oldVar = self.vars[key]
                self.vars[key] = value
                netstream.Start(nil, "charSet", key, value, self:getID())
                hook.Run("OnCharVarChanged", self, key, oldVar, value)
            end
        end
    end

    if data.onGet then
        charMeta["get" .. upperName] = data.onGet
        charMeta["Get" .. upperName] = data.onGet
    else
        charMeta["get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end
            return default
        end

        charMeta["Get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end
            return default
        end
    end

    charMeta.vars[key] = data.default
end
	--- Default character vars
	-- @classmod Character

	--- Sets this character's name. This is automatically networked.
	-- @realm server
	-- @string name New name for the character
	-- @function setName/SetName

	--- Returns this character's name
	-- @realm shared
	-- @treturn string This character's current name
	-- @function getName/GetName

lia.char.registerVar("name", {
    field = "_name",
    default = "John Doe",
    index = 1,
    onValidate = function(value, data, client)
        local name, override = hook.Run("GetDefaultCharName", client, data.faction, data)
        if isstring(name) and override then return true end
        if not isstring(value) or not value:find("%S") then return false, "invalid", "name" end
        local allowExistNames = lia.config.AllowExistNames
        if CLIENT and #lia.char.names < 1 and not allowExistNames then
            netstream.Start("liaCharFetchNames")
            netstream.Hook("liaCharFetchNames", function(data) lia.char.names = data end)
        end

        if not lia.config.AllowExistNames then
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
	--- Sets this character's physical description. This is automatically networked.
	-- @realm server
	-- @string description New description for this character
	-- @function setDesc/SetDescription

	--- Returns this character's physical description.
	-- @realm shared
	-- @treturn string This character's current description
	-- @function getDesc/GetDescription
lia.char.registerVar("desc", {
    field = "_desc",
    default = "Please Enter Your Description With The Minimum Of " .. lia.config.MinDescLen .. " Characters!",
    index = 2,
    onValidate = function(value, data, client)
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction)
        local minLength = lia.config.MinDescLen
        if isstring(desc) and override then return true end
        if not value or #value:gsub("%s", "") < minLength then return false, "descMinLen", minLength end
        return true
    end,
    onAdjust = function(client, data, _, newData)
        local desc, override = hook.Run("GetDefaultCharDesc", client, data.faction)
        if isstring(desc) and override then newData.desc = desc end
    end,
})
	--- Sets this character's model. This sets the player's current model to the given one, and saves it to the character.
	-- It is automatically networked.
	-- @realm server
	-- @string model New model for the character
	-- @function setModel/SetModel

	--- Returns this character's model.
	-- @realm shared
	-- @treturn string This character's current model
	-- @function getModel/GetModel
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
    onDisplay = function(panel, y)
        local scroll = panel:Add("DScrollPanel")
        scroll:SetSize(panel:GetWide(), 260)
        scroll:SetPos(0, y)
        local layout = scroll:Add("DIconLayout")
        layout:Dock(FILL)
        layout:SetSpaceX(1)
        layout:SetSpaceY(1)
        local faction = lia.faction.indices[panel.faction]
        if faction then
            for k, v in SortedPairs(faction.models) do
                local icon = layout:Add("SpawnIcon")
                icon:SetSize(64, 128)
                icon:InvalidateLayout(true)
                icon.DoClick = function(_) panel.payload.model = k end
                icon.PaintOver = function(_, w, h)
                    if panel.payload.model == k then
                        local color = lia.config.Color
                        surface.SetDrawColor(color.r, color.g, color.b, 200)
                        for i = 1, 3 do
                            local i2 = i * 2
                            surface.DrawOutlinedRect(i, i, w - i2, h - i2)
                        end

                        surface.SetDrawColor(color.r, color.g, color.b, 75)
                        surface.SetMaterial(lia.util.getMaterial("vgui/gradient-d"))
                        surface.DrawTexturedRect(0, 0, w, h)
                    end
                end

                if isstring(v) then
                    icon:SetModel(v)
                else
                    icon:SetModel(v[1], v[2] or 0, v[3])
                end
            end
        end
        return scroll
    end,
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
                    for value in model[3]:gmatch("%d") do
                        groups[i] = tonumber(value)
                        i = i + 1
                    end
                elseif istable(model[3]) then
                    for _, v in pairs(model[3]) do
                        groups[tonumber(k)] = tonumber(v)
                    end
                end

                newData.data.groups = groups
            end
        end
    end
})
	-- setClass shouldn't be used here, character:joinClass should be used instead
	--- Returns this character's current class.
	-- @realm shared
	-- @treturn number Index of the class this character is in
	-- @function getClass
lia.char.registerVar("class", {
    noDisplay = true,
})

	--- Sets this character's faction. Note that this doesn't do the initial setup for the player after the faction has been
	-- changed, so you'll have to update some character vars manually.
	-- @realm server
	-- @number faction Index of the faction to transfer this character to
	-- @function setFaction/SetFaction

	--- Returns this character's faction.
	-- @realm shared
	-- @treturn number Index of the faction this character is currently in
	-- @function getFaction/GetFaction
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
	--- Sets this character's current money. Money is only networked to the player that owns this character.
	-- @realm server
	-- @number money New amount of money this character should have
	-- @function setMoney/SetMoney

	--- Returns this character's money. This is only valid on the server and the owning client.
	-- @realm shared
	-- @treturn number Current money of this character
	-- @function getMoney/GetMoney
lia.char.registerVar("money", {
    field = "_money",
    default = 0,
    isLocal = true,
    noDisplay = true
})
	--- Sets a data field on this character. This is useful for storing small bits of data that you need persisted on this
	-- character. This is networked only to the owning client. If you are going to be accessing this data field frequently with
	-- a getter/setter, consider using `lia.char.registerVar` instead.
	-- @realm server
	-- @string key Name of the field that holds the data
	-- @param value Any value to store in the field, as long as it's supported by GMod's JSON parser
	-- @function setData/SetData

	--- Returns a data field set on this character. If it doesn't exist, it will return the given default or `nil`. This is only
	-- valid on the server and the owning client.
	-- @realm shared
	-- @string key Name of the field that's holding the data
	-- @param default Value to return if the given key doesn't exist, or is `nil`
	-- @return[1] Data stored in the field
	-- @treturn[2] nil If the data doesn't exist, or is `nil`
	-- @function getData/GetData
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

do
    local playerMeta = FindMetaTable("Player")
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
	--- Returns this player's currently possessed `Character` object if it exists.
	-- @realm shared
	-- @treturn[1] Character Currently loaded character
	-- @treturn[2] nil If this player has no character loaded
    function playerMeta:getChar()
        return lia.char.loaded[self.getNetVar(self, "char")]
    end

	--- Returns this player's current name.
	-- @realm shared
	-- @treturn[1] string Name of this player's currently loaded character
	-- @treturn[2] string Steam name of this player if the player has no character loaded
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.GetCharacter = playerMeta.getChar
    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

function lia.char.getCharData(charID, key)
    local charIDsafe = tonumber(charID)
    if not charIDsafe then return end
    local findData = sql.Query("SELECT * FROM lia_characters WHERE _id=" .. charIDsafe)
    if not findData or not findData[1] then return false end
    local data = util.JSONToTable(findData[1]._data) or {}
    if key then return data[key] end
    return data
end

if SERVER then
	--- Creates a character object with its assigned properties and saves it to the database.
	-- @realm server
	-- @tab data Properties to assign to this character. If fields are missing from the table, then it will use the default
	-- value for that property
	-- @func callback Function to call after the character saves

    function lia.char.create(data, callback)
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        data.money = data.money or lia.config.DefaultMoney
        lia.db.insertTable({
            _name = data.name or "",
            _desc = data.desc or "",
            _model = data.model or "models/error.mdl",
            _schema = SCHEMA and SCHEMA.folder or "lilia",
            _createTime = timeStamp,
            _lastJoinTime = timeStamp,
            _steamID = data.steamID,
            _faction = data.faction or "Unknown",
            _money = data.money,
            recognized_as = "",
            _data = data.data
        }, function(_, charID)
            local client
            for _, v in ipairs(player.GetAll()) do
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
	--- Loads all of a player's characters into memory.
	-- @realm server
	-- @player client Player to load the characters for
	-- @func[opt=nil] callback Function to call when the characters have been loaded
	-- @bool[opt=false] bNoCache Whether or not to skip the cache; players that leave and join again later will already have
	-- their characters loaded which will skip the database query and load quicker
	-- @number[opt=nil] id The ID of a specific character to load instead of all of the player's characters

    function lia.char.restore(client, callback, _, id)
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
                hook.Run("CharacterRestored", character)
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
                    print("Failed to load inventories for " .. tostring(id))
                    print(err)
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

    function lia.char.cleanUpForPlayer(client)
        for _, charID in pairs(client.liaCharList or {}) do
            local character = lia.char.loaded[charID]
            if not character then return end
            netstream.Start(nil, "charDel", character:getID())
            lia.inventory.cleanUpForCharacter(character)
            lia.char.loaded[charID] = nil
            hook.Run("CharacterCleanUp", character)
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

    function lia.char.delete(id, client)
        assert(isnumber(id), "id must be a number")
        if IsValid(client) then
            removePlayer(client)
        else
            for _, target in ipairs(player.GetAll()) do
                if not table.HasValue(target.liaCharList or {}, id) then continue end
                table.RemoveByValue(target.liaCharList, id)
                removePlayer(target)
            end
        end

        hook.Run("PreCharacterDelete", id)
        for index, charID in pairs(client.liaCharList) do
            if charID == id then
                table.remove(client.liaCharList, index)
                break
            end
        end

        lia.char.loaded[id] = nil
        netstream.Start(nil, "charDel", id)
        lia.db.query("DELETE FROM lia_characters WHERE _id = " .. id)
        lia.db.query("SELECT _invID FROM lia_inventories WHERE _charID = " .. id, function(data)
            if data then
                for _, inventory in ipairs(data) do
                    lia.inventory.deleteByID(tonumber(inventory._invID))
                end
            end
        end)

        hook.Run("OnCharacterDelete", client, id)
    end

    function lia.char.setCharData(charID, key, val)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local data = lia.char.getCharData(charID)
        if not data then return false end
        data[key] = val
        local setQ = "UPDATE lia_characters SET _data=" .. sql.SQLStr(util.TableToJSON(data)) .. " WHERE _id=" .. charIDsafe
        if sql.Query(setQ) == false then
            print("lia.setCharData SQL Error, q=" .. setQ .. ", Error = " .. sql.LastError())
            return false
        end

        if lia.char.loaded[charIDsafe] then lia.char.loaded[charIDsafe]:setData(key, val) end
        return true
    end
end