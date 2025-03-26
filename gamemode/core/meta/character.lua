﻿local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
debug.getregistry().Character = lia.meta.character
function characterMeta:tostring()
    return "character[" .. (self.id or 0) .. "]"
end

function characterMeta:eq(other)
    return self:getID() == other:getID()
end

function characterMeta:getID()
    return self.id
end

function characterMeta:hasClassWhitelist(class)
    local wl = self:getData("whitelist", {})
    return wl[class] ~= nil
end

function characterMeta:isFaction(faction)
    return self:getChar():getFaction() == faction
end

function characterMeta:isClass(class)
    return self:getChar():getClass() == class
end

function characterMeta:getPlayer()
    if IsValid(self.player) then return self.player end
    for _, v in player.Iterator() do
        if self.steamID then
            if v:SteamID64() == self.steamID then
                self.player = v
                return v
            end
        else
            local character = v:getChar()
            if character and character:getID() == self:getID() then
                self.player = v
                return v
            end
        end
    end
end

function characterMeta:getDisplayedName(client)
    local isRecognitionEnabled = lia.config.get("RecognitionEnabled", true)
    if not isRecognitionEnabled then return self:getName() end
    if not IsValid(self:getPlayer()) or not IsValid(client) then return L("unknown") end
    local ourCharacter = client:getChar()
    if not self or not ourCharacter then return L("unknown") end
    if self:getPlayer() == client then return self:getName() end
    local characterID = self:getID()
    if ourCharacter:doesRecognize(characterID) then return self:getName() end
    local myReg = ourCharacter:getRecognizedAs()
    if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
    return L("unknown")
end

function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

function characterMeta:getFlags()
    return self:getData("f", "")
end

function characterMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

function characterMeta:getItemWeapon(requireEquip)
    if requireEquip == nil then requireEquip = true end
    local client = self:getPlayer()
    local inv = self:getInv()
    local items = inv:getItems()
    local weapon = client:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    for _, v in pairs(items) do
        if v.class and v.class == weapon:GetClass() and requireEquip and v:getData("equip", false) then return true end
    end
    return false
end

function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharFakeRecognized", self, id) ~= false
end

if SERVER then
    function characterMeta:recognize(character, name)
        local id
        if isnumber(character) then
            id = character
        elseif character and character.getID then
            id = character:getID()
        end

        local recognized = self:getData("rgn", "")
        local nameList = self:getRecognizedAs()
        if name ~= nil then
            nameList[id] = name
            self:setRecognizedAs(nameList)
        else
            self:setData("rgn", recognized .. "," .. id .. ",")
        end
        return true
    end

    function characterMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if not lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    function characterMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    function characterMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    function characterMeta:classWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = true
        self:setData("whitelist", wl)
    end

    function characterMeta:classUnWhitelist(class)
        local wl = self:getData("whitelist", {})
        wl[class] = false
        self:setData("whitelist", wl)
    end

    function characterMeta:joinClass(class, isForced)
        if not class then
            self:kickClass()
            return false
        end

        local client = self:getPlayer()
        local classData = lia.class.list[class]
        if not classData or classData.faction ~= client:Team() then
            self:KickClass()
            return false
        end

        local oldClass = self:getClass()
        local hadOldClass = oldClass and oldClass ~= -1
        if isForced or lia.class.canBe(client, class) then
            self:setClass(class)
            if lia.config.get("PermaClass", true) then self:setData("pclass", class) end
            if hadOldClass then
                hook.Run("OnPlayerSwitchClass", client, class, oldClass)
            else
                hook.Run("OnPlayerJoinClass", client, class, oldClass)
            end
            return true
        else
            return false
        end
    end

    function characterMeta:kickClass()
        local client = self:getPlayer()
        if not client then return end
        local validDefaultClass
        for k, v in pairs(lia.class.list) do
            if v.faction == client:Team() and v.isDefault then
                validDefaultClass = k
                break
            end
        end

        if validDefaultClass then
            self:joinClass(validDefaultClass)
            hook.Run("OnPlayerJoinClass", client, validDefaultClass)
        else
            self:setClass(nil)
        end
    end

    function characterMeta:setFlags(flags)
        self:setData("f", flags)
    end

    function characterMeta:giveFlags(flags)
        local addedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info then
                if not self:hasFlags(flag) then addedFlags = addedFlags .. flag end
                if info.callback then info.callback(self:getPlayer(), true) end
            end
        end

        if addedFlags ~= "" then self:setFlags(self:getFlags() .. addedFlags) end
    end

    function characterMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback then info.callback(self:getPlayer(), false) end
            newFlags = newFlags:gsub(flag, "")
        end

        if newFlags ~= oldFlags then self:setFlags(newFlags) end
    end

    function characterMeta:save(callback)
        if self.isBot then return end
        local data = {}
        for k, v in pairs(lia.char.vars) do
            if v.field and self.vars[k] ~= nil then data[v.field] = self.vars[k] end
        end

        local shouldSave = hook.Run("CharPreSave", self)
        if shouldSave ~= false then
            lia.db.updateTable(data, function()
                if callback then callback() end
                hook.Run("CharPostSave", self)
            end, nil, "_id = " .. self:getID())
        end
    end

    function characterMeta:sync(receiver)
        if receiver == nil then
            for _, v in player.Iterator() do
                self:sync(v)
            end
        elseif receiver == self.player then
            local data = {}
            for k, v in pairs(self.vars) do
                if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then data[k] = v end
            end

            netstream.Start(self.player, "charInfo", data, self:getID())
            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, self.player) end
            end
        else
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then data[k] = self.vars[k] end
            end

            netstream.Start(receiver, "charInfo", data, self:getID(), self.player)
            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, receiver) end
            end
        end
    end

    function characterMeta:setup(noNetworking)
        local client = self:getPlayer()
        if IsValid(client) then
            local model = self:getModel()
            if isstring(model) then
                client:SetModel(model)
            elseif istable(model) then
                client:SetModel(model[1])
            end

            client:SetTeam(self:getFaction())
            client:setNetVar("char", self:getID())
            for k, v in pairs(self:getData("groups", {})) do
                client:SetBodygroup(k, v)
            end

            client:SetSkin(self:getData("skin", 0))
            if not noNetworking then
                for _, v in ipairs(self:getInv(true)) do
                    if istable(v) then v:sync(client) end
                end

                self:sync()
            end

            hook.Run("CharLoaded", self:getID())
            self.firstTimeLoaded = true
        end
    end

    function characterMeta:kick()
        local client = self:getPlayer()
        client:KillSilent()
        local curChar, steamID = client:getChar(), client:SteamID64()
        local isCurChar = curChar and curChar:getID() == self:getID() or false
        if self.steamID == steamID then
            netstream.Start(client, "charKick", id, isCurChar)
            if isCurChar then
                client:setNetVar("char", nil)
                client:Spawn()
            end
        end

        hook.Run("OnCharKick", self, client)
    end

    function characterMeta:ban(time)
        time = tonumber(time)
        if time then time = os.time() + math.max(math.ceil(time), 60) end
        self:setData("banned", time or true)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    function characterMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
    end

    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        return client:addMoney(amount)
    end

    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end
end

lia.meta.character = characterMeta