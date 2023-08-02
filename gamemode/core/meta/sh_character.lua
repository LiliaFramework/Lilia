local charMeta = lia.meta.character or {}
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character

function charMeta:__tostring()
    return "character[" .. (self.id or 0) .. "]"
end

function charMeta:__eq(other)
    return self:getID() == other:getID()
end

function charMeta:getID()
    return self.id
end

function charMeta:GetID()
    return self.id
end

if SERVER then
    function charMeta:save(callback)
        if self.isBot then return end
        local data = {}

        for k, v in pairs(lia.char.vars) do
            if v.field and self.vars[k] ~= nil then
                data[v.field] = self.vars[k]
            end
        end

        local shouldSave = hook.Run("CharacterPreSave", self)

        if shouldSave ~= false then
            lia.db.updateTable(data, function()
                if callback then
                    callback()
                end

                hook.Run("CharacterPostSave", self)
            end, nil, "_id = " .. self:getID())
        end
    end

    function charMeta:Save(callback)
        if self.isBot then return end
        local data = {}

        for k, v in pairs(lia.char.vars) do
            if v.field and self.vars[k] ~= nil then
                data[v.field] = self.vars[k]
            end
        end

        local shouldSave = hook.Run("CharacterPreSave", self)

        if shouldSave ~= false then
            lia.db.updateTable(data, function()
                if callback then
                    callback()
                end

                hook.Run("CharacterPostSave", self)
            end, nil, "_id = " .. self:getID())
        end
    end

    function charMeta:sync(receiver)
        if receiver == nil then
            for k, v in ipairs(player.GetAll()) do
                self:sync(v)
            end
        elseif receiver == self.player then
            local data = {}

            for k, v in pairs(self.vars) do
                if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then
                    data[k] = v
                end
            end

            netstream.Start(self.player, "charInfo", data, self:getID())

            for k, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then
                    v.onSync(self, self.player)
                end
            end
        else
            local data = {}

            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then
                    data[k] = self.vars[k]
                end
            end

            netstream.Start(receiver, "charInfo", data, self:getID(), self.player)

            for k, v in pairs(lia.char.vars) do
                if type(v.onSync) == "function" then
                    v.onSync(self, receiver)
                end
            end
        end
    end

    function charMeta:Sync(receiver)
        if receiver == nil then
            for k, v in ipairs(player.GetAll()) do
                self:sync(v)
            end
        elseif receiver == self.player then
            local data = {}

            for k, v in pairs(self.vars) do
                if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then
                    data[k] = v
                end
            end

            netstream.Start(self.player, "charInfo", data, self:getID())

            for k, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then
                    v.onSync(self, self.player)
                end
            end
        else
            local data = {}

            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then
                    data[k] = self.vars[k]
                end
            end

            netstream.Start(receiver, "charInfo", data, self:getID(), self.player)

            for k, v in pairs(lia.char.vars) do
                if type(v.onSync) == "function" then
                    v.onSync(self, receiver)
                end
            end
        end
    end

    function charMeta:setup(noNetworking)
        local client = self:getPlayer()

        if IsValid(client) then
            client:SetModel(isstring(self:getModel()) and self:getModel() or self:getModel()[1])
            client:SetTeam(self:getFaction())
            client:setNetVar("char", self:getID())

            for k, v in pairs(self:getData("groups", {})) do
                client:SetBodygroup(k, v)
            end

            client:SetSkin(self:getData("skin", 0))

            if not noNetworking then
                for k, v in ipairs(self:getInv(true)) do
                    if istable(v) then
                        v:sync(client)
                    end
                end

                self:sync()
            end

            hook.Run("CharacterLoaded", self:getID())
            self.firstTimeLoaded = true
        end
    end

    function charMeta:Setup(noNetworking)
        local client = self:getPlayer()

        if IsValid(client) then
            client:SetModel(isstring(self:getModel()) and self:getModel() or self:getModel()[1])
            client:SetTeam(self:getFaction())
            client:setNetVar("char", self:getID())

            for k, v in pairs(self:getData("groups", {})) do
                client:SetBodygroup(k, v)
            end

            client:SetSkin(self:getData("skin", 0))

            if not noNetworking then
                for k, v in ipairs(self:getInv(true)) do
                    if istable(v) then
                        v:sync(client)
                    end
                end

                self:sync()
            end

            hook.Run("CharacterLoaded", self:getID())
            self.firstTimeLoaded = true
        end
    end

    function charMeta:kick()
        local client = self:getPlayer()
        client:KillSilent()
        local steamID = client:SteamID64()
        local id = self:getID()
        local isCurrentChar = self and self:getID() == id

        if self and self.steamID == steamID then
            netstream.Start(client, "charKick", id, isCurrentChar)

            if isCurrentChar then
                client:setNetVar("char", nil)
                client:Spawn()
            end
        end
    end

    function charMeta:Kick()
        local client = self:getPlayer()
        client:KillSilent()
        local steamID = client:SteamID64()
        local id = self:getID()
        local isCurrentChar = self and self:getID() == id

        if self and self.steamID == steamID then
            netstream.Start(client, "charKick", id, isCurrentChar)

            if isCurrentChar then
                client:setNetVar("char", nil)
                client:Spawn()
            end
        end
    end

    function charMeta:ban(time)
        time = tonumber(time)

        if time then
            time = os.time() + math.max(math.ceil(time), 60)
        end

        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    function charMeta:Ban(time)
        time = tonumber(time)

        if time then
            time = os.time() + math.max(math.ceil(time), 60)
        end

        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    function charMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    function charMeta:Delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    function charMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
        netstream.Start(nil, "charDel", id)
    end
end

function charMeta:getPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID

        for k, v in ipairs(player.GetAll()) do
            if v:SteamID64() == steamID then
                self.player = v
                return v
            end
        end
    else
        for k, v in ipairs(player.GetAll()) do
            local char = v:getChar()

            if char and (char:getID() == self:getID()) then
                self.player = v
                return v
            end
        end
    end
end

function charMeta:GetPlayer()
    if IsValid(self.player) then
        return self.player
    elseif self.steamID then
        local steamID = self.steamID

        for k, v in ipairs(player.GetAll()) do
            if v:SteamID64() == steamID then
                self.player = v
                return v
            end
        end
    else
        for k, v in ipairs(player.GetAll()) do
            local char = v:getChar()

            if char and (char:getID() == self:getID()) then
                self.player = v
                return v
            end
        end
    end
end

function lia.char.registerVar(key, data)
    lia.char.vars[key] = data
    data.index = data.index or table.Count(lia.char.vars)
    local upperName = key:sub(1, 1):upper() .. key:sub(2)

    if SERVER and not data.isNotModifiable then
        if data.onSet then
            charMeta["set" .. upperName] = data.onSet
        elseif data.noNetworking then
            charMeta["set" .. upperName] = function(self, value)
                self.vars[key] = value
            end
        elseif data.isLocal then
            charMeta["set" .. upperName] = function(self, value)
                local curChar = self:getPlayer() and self:getPlayer():getChar()
                local sendID = true

                if curChar and curChar == self then
                    sendID = false
                end

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
        end
    end

    if data.onGet then
        charMeta["get" .. upperName] = data.onGet
    else
        charMeta["get" .. upperName] = function(self, default)
            local value = self.vars[key]
            if value ~= nil then return value end
            if default == nil then return lia.char.vars[key] and lia.char.vars[key].default or nil end

            return default
        end
    end

    charMeta.vars[key] = data.default
end

lia.meta.character = charMeta
