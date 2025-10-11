lia.char = lia.char or {}
lia.char.vars = lia.char.vars or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.varHooks = lia.char.varHooks or {}
if SERVER then
    function lia.char.getCharacter(charID, client, callback)
        local character = lia.char.loaded[charID]
        if character then
            if callback then callback(character) end
            return character
        end

        lia.char.loadSingleCharacter(charID, client, callback)
    end
else
    lia.char.pendingRequests = lia.char.pendingRequests or {}
    function lia.char.getCharacter(charID, _, callback)
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

function lia.char.isLoaded(charID)
    return lia.char.loaded[charID] ~= nil
end

function lia.char.getAll()
    return lia.char.loaded
end

function lia.char.addCharacter(id, character)
    lia.char.loaded[id] = character
    if lia.char.pendingRequests and lia.char.pendingRequests[id] then
        lia.char.pendingRequests[id](character)
        lia.char.pendingRequests[id] = nil
    end
end

function lia.char.removeCharacter(id)
    lia.char.loaded[id] = nil
end

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
                local player = self:getPlayer()
                if player and IsValid(player) and player:IsPlayer() then
                    net.Start("liaCharSet")
                    net.WriteString(key)
                    net.WriteType(value)
                    net.WriteType(sendID and self:getID() or nil)
                    net.Send(player)
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

function lia.char.getOwnerByID(ID)
    ID = tonumber(ID)
    for client, character in pairs(lia.char.getAll()) do
        if character and character:getID() == ID then return client end
    end
end

function lia.char.getBySteamID(steamID)
    if not isstring(steamID) or steamID == "" then return end
    local lookupID = steamID
    if string.match(steamID, "^%d+$") and #steamID >= 17 then lookupID = util.SteamIDFrom64(steamID) or steamID end
    for _, client in player.Iterator() do
        if client:SteamID() == lookupID and client:getChar() then return client:getChar() end
    end
end

function lia.char.getAll()
    local charTable = {}
    for _, client in player.Iterator() do
        if client:getChar() then charTable[client] = client:getChar() end
    end
    return charTable
end

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

        for _, ply in player.Iterator() do
            if IsValid(ply) then
                net.Start("liaCharDeleted")
                net.Send(ply)
            end
        end
    end

    function lia.char.getCharBanned(charID)
        local charIDsafe = tonumber(charID)
        if not charIDsafe then return end
        local result = sql.Query("SELECT banned FROM lia_characters WHERE id = " .. charIDsafe .. " LIMIT 1")
        if istable(result) and result[1] then return tonumber(result[1].banned) or 0 end
    end

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

    function lia.char.unloadUnusedCharacters(client, activeCharID)
        local unloadedCount = 0
        for _, charID in pairs(client.liaCharList or {}) do
            if charID ~= activeCharID and lia.char.loaded[charID] and lia.char.unloadCharacter(charID) then unloadedCount = unloadedCount + 1 end
        end
        return unloadedCount
    end

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