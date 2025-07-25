﻿local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
function characterMeta:tostring()
    return "character[" .. (self.id or 0) .. "]"
end

function characterMeta:eq(other)
    return self:getID() == other:getID()
end

function characterMeta:getID()
    return self.id
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

function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("getCharMaxStamina", self) or lia.config.get("DefaultStamina", 100)
    return maxStamina
end

function characterMeta:getStamina()
    local stamina = self:getPlayer():getLocalVar("stamina", 100) or lia.config.get("DefaultStamina", 100)
    return stamina
end

function characterMeta:hasClassWhitelist(class)
    local wl = self:getData("whitelist", {})
    return wl[class] ~= nil
end

function characterMeta:isFaction(faction)
    return self:getFaction() == faction
end

function characterMeta:isClass(class)
    return self:getClass() == class
end

function characterMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getBoosts()[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

function characterMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

function characterMeta:getBoosts()
    return self:getVar("boosts", {})
end

function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharFakeRecognized", self, id) ~= false
end

function characterMeta:setData(k, v, noReplication, receiver)
    if not self.dataVars then self.dataVars = {} end
    local toNetwork = {}
    if istable(k) then
        for nk, nv in pairs(k) do
            self.dataVars[nk] = nv
            toNetwork[#toNetwork + 1] = nk
        end
    else
        self.dataVars[k] = v
        toNetwork[1] = k
    end

    if SERVER then
        if not noReplication and #toNetwork > 0 then
            net.Start("liaCharacterData")
            net.WriteUInt(self:getID(), 32)
            net.WriteUInt(#toNetwork, 32)
            for _, nk in ipairs(toNetwork) do
                local data = self.dataVars[nk]
                if istable(data) then data = pon.encode(data) end
                net.WriteString(nk)
                net.WriteType(data)
            end

            net.Send(receiver or self:getPlayer())
        end

        if istable(k) then
            for nk, nv in pairs(k) do
                if nv == nil then
                    lia.db.delete("chardata", "_charID = " .. self:getID() .. " AND _key = '" .. lia.db.escape(nk) .. "'")
                else
                    local encoded = pon.encode({nv})
                    lia.db.upsert({
                        _charID = self:getID(),
                        _key = nk,
                        _value = encoded
                    }, "chardata", function(success, err) if not success then print("Failed to insert character data: " .. err) end end)
                end
            end
        else
            if v == nil then
                lia.db.delete("chardata", "_charID = " .. self:getID() .. " AND _key = '" .. lia.db.escape(k) .. "'")
            else
                local encoded = pon.encode({v})
                lia.db.upsert({
                    _charID = self:getID(),
                    _key = k,
                    _value = encoded
                }, "chardata", function(success, err) if not success then print("Failed to insert character data: " .. err) end end)
            end
        end
    end
end

function characterMeta:getData(key, default)
    if not key then return self.dataVars end
    local value = self.dataVars and self.dataVars[key] or default
    return value
end

if SERVER then
    function characterMeta:recognize(character, name)
        local id
        if isnumber(character) then
            id = character
        elseif character and character.getID then
            id = character:getID()
        end

        local recognized = self:getRecognition()
        local nameList = self:getRecognizedAs()
        if name ~= nil then
            nameList[id] = name
            self:setRecognizedAs(nameList)
        else
            self:setRecognition(recognized .. "," .. id .. ",")
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
            self:kickClass()
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

    function characterMeta:updateAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if not attribute then return end
        local attrib = self:getAttribs()
        local currentLevel = attrib[key] or 0
        local maxLevel = hook.Run("GetAttributeMax", client, key) or math.huge
        attrib[key] = math.min(currentLevel + value, maxLevel)
        if IsValid(client) then
            net.Start("attrib")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(attrib[key])
            net.Send(client)
            hook.Run("OnCharAttribUpdated", client, self, key, attrib[key])
        end
    end

    function characterMeta:setAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = value
            if IsValid(client) then
                net.Start("attrib")
                net.WriteUInt(self:getID(), 32)
                net.WriteString(key)
                net.WriteType(attrib[key])
                net.Send(client)
                hook.Run("OnCharAttribUpdated", client, self, key, attrib[key])
            end
        end
    end

    function characterMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    function characterMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
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

            net.Start("charInfo")
            net.WriteTable(data)
            net.WriteUInt(self:getID(), 32)
            net.Send(self.player)
            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, self.player) end
            end
        else
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then data[k] = self.vars[k] end
            end

            net.Start("charInfo")
            net.WriteTable(data)
            net.WriteUInt(self:getID(), 32)
            net.WriteEntity(self.player)
            net.Send(receiver)
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
            PrintTable(self:getData("groups", {}), 1)
            for k, v in pairs(self:getData("groups", {})) do
                local index = tonumber(k)
                local value = tonumber(v) or 0
                if index then client:SetBodygroup(index, value) end
            end

            client:SetSkin(self:getData("skin", 0))
            hook.Run("SetupPlayerModel", client, self)
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
            net.Start("charKick")
            net.WriteUInt(self:getID(), 32)
            net.WriteBool(isCurChar)
            net.Send(client)
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