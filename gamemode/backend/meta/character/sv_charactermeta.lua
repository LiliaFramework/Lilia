--------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character or {}
--------------------------------------------------------------------------------------------------------
charMeta.__index = charMeta
charMeta.id = charMeta.id or 0
charMeta.vars = charMeta.vars or {}
debug.getregistry().Character = lia.meta.character

--------------------------------------------------------------------------------------------------------
function charMeta:updateAttrib(key, value)
    local attribute = lia.attribs.list[key]
    local client = self:getPlayer()

    if attribute then
        local attrib = self:getAttribs()
        attrib[key] = math.min((attrib[key] or 0) + value, attribute.maxValue or lia.config.MaxAttributes

        if IsValid(client) then
            netstream.Start(client, "attrib", self:getID(), key, attrib[key])

            if attribute.setup then
                attribute.setup(attrib[key])
            end
        end
    end

    hook.Run("OnCharAttribUpdated", client, self, key, value)
end

--------------------------------------------------------------------------------------------------------
function charMeta:setAttrib(key, value)
    local attribute = lia.attribs.list[key]

    if attribute then
        local attrib = self:getAttribs()
        local client = self:getPlayer()
        attrib[key] = value

        if IsValid(client) then
            netstream.Start(client, "attrib", self:getID(), key, attrib[key])

            if attribute.setup then
                attribute.setup(attrib[key])
            end
        end
    end

    hook.Run("OnCharAttribUpdated", client, self, key, value)
end

--------------------------------------------------------------------------------------------------------
function charMeta:addBoost(boostID, attribID, boostAmount)
    local boosts = self:getVar("boosts", {})
    boosts[attribID] = boosts[attribID] or {}
    boosts[attribID][boostID] = boostAmount
    hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)

    return self:setVar("boosts", boosts, nil, self:getPlayer())
end

--------------------------------------------------------------------------------------------------------
function charMeta:removeBoost(boostID, attribID)
    local boosts = self:getVar("boosts", {})
    boosts[attribID] = boosts[attribID] or {}
    boosts[attribID][boostID] = nil
    hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)

    return self:setVar("boosts", boosts, nil, self:getPlayer())
end

--------------------------------------------------------------------------------------------------------
function charMeta:setFlags(flags)
    self:setData("f", flags)
end

--------------------------------------------------------------------------------------------------------
function charMeta:giveFlags(flags)
    local addedFlags = ""

    for i = 1, #flags do
        local flag = flags:sub(i, i)
        local info = lia.flag.list[flag]

        if info then
            if not self:hasFlags(flag) then
                addedFlags = addedFlags .. flag
            end

            if info.callback then
                info.callback(self:getPlayer(), true)
            end
        end
    end

    if addedFlags ~= "" then
        self:setFlags(self:getFlags() .. addedFlags)
    end
end

--------------------------------------------------------------------------------------------------------
function charMeta:takeFlags(flags)
    local oldFlags = self:getFlags()
    local newFlags = oldFlags

    for i = 1, #flags do
        local flag = flags:sub(i, i)
        local info = lia.flag.list[flag]

        if info and info.callback then
            info.callback(self:getPlayer(), false)
        end

        newFlags = newFlags:gsub(flag, "")
    end

    if newFlags ~= oldFlags then
        self:setFlags(newFlags)
    end
end

--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
function charMeta:setup(noNetworking)
    local client = self:getPlayer()
    if client:IsBot() then return end

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

--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------
function charMeta:delete()
    lia.char.delete(self:getID(), self:getPlayer())
end

--------------------------------------------------------------------------------------------------------
function charMeta:destroy()
    local id = self:getID()
    lia.char.loaded[id] = nil
    netstream.Start(nil, "charDel", id)
end

--------------------------------------------------------------------------------------------------------
lia.meta.character = charMeta
--------------------------------------------------------------------------------------------------------