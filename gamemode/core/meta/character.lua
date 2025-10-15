local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
function characterMeta:tostring()
    return L("character") .. "[" .. (self.id or 0) .. "]"
end

function characterMeta:getID()
    return self.id
end

function characterMeta:getPlayer()
    if IsValid(self.player) then return self.player end
    for _, v in player.Iterator() do
        if self.steamID then
            if v:SteamID() == self.steamID then
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
    local myReg = ourCharacter:getFakeName()
    if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
    return L("unknown")
end

function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

function characterMeta:hasFlags(flagStr)
    local flags = self:getFlags()
    for i = 1, #flagStr do
        local flag = flagStr:sub(i, i)
        if flags:find(flag, 1, true) then return true end
    end
    return false
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

function characterMeta:getAttrib(key, default)
    local att = self:getAttribs()[key] or default or 0
    local boosts = self:getVar("boosts", {})[key]
    if boosts then
        for _, v in pairs(boosts) do
            att = att + v
        end
    end
    return att
end

function characterMeta:getBoost(attribID)
    local boosts = self:getVar("boosts", {})
    return boosts[attribID]
end

function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharRecognized", self, id) ~= false
end

function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharFakeRecognized", self, id) ~= false
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
            local target = receiver or self:getPlayer()
            if IsValid(target) then
                net.Start("liaCharacterData")
                net.WriteUInt(self:getID(), 32)
                net.WriteUInt(#toNetwork, 32)
                for _, nk in ipairs(toNetwork) do
                    local data = self.dataVars[nk]
                    if istable(data) then data = pon.encode(data) end
                    net.WriteString(nk)
                    net.WriteType(data)
                end

                net.Send(target)
            end
        end

        if istable(k) then
            for nk, nv in pairs(k) do
                if nv == nil then
                    lia.db.delete("chardata", "charID = " .. self:getID() .. " AND key = '" .. lia.db.escape(nk) .. "'")
                else
                    local encoded = pon.encode({nv})
                    lia.db.upsert({
                        charID = self:getID(),
                        key = nk,
                        value = encoded
                    }, "chardata", function(success, err) if not success then lia.error(L("failedInsertCharData", err)) end end)
                end
            end
        else
            if v == nil then
                lia.db.delete("chardata", "charID = " .. self:getID() .. " AND key = '" .. lia.db.escape(k) .. "'")
            else
                local encoded = pon.encode({v})
                lia.db.upsert({
                    charID = self:getID(),
                    key = k,
                    value = encoded
                }, "chardata", function(success, err) if not success then lia.error(L("failedInsertCharData", err)) end end)
            end
        end
    end
end

function characterMeta:getData(key, default)
    self.dataVars = self.dataVars or {}
    if not key then return self.dataVars end
    local value = self.dataVars and self.dataVars[key] or default
    return value
end

function characterMeta:isBanned()
    local banned = self:getBanned()
    return banned ~= 0 and (banned == -1 or banned > os.time())
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
        local nameList = self:getFakeName()
        if name ~= nil then
            nameList[id] = name
            self:setFakeName(nameList)
        else
            self:setRecognition(recognized .. "," .. id .. ",")
        end
        return true
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
            net.Start("liaAttributeData")
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
                net.Start("liaAttributeData")
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
        local oldFlags = self:getFlags()
        self.vars.flags = flags
        net.Start("liaCharSet")
        net.WriteString("flags")
        net.WriteType(flags)
        net.WriteType(self:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", self, "flags", oldFlags, flags)
        local ply = self:getPlayer()
        if not IsValid(ply) then return end
        for i = 1, #oldFlags do
            local flag = oldFlags:sub(i, i)
            if not flags:find(flag, 1, true) then
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(ply, false) end
            end
        end

        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not oldFlags:find(flag, 1, true) then
                local info = lia.flag.list[flag]
                if info and info.callback then info.callback(ply, true) end
            end
        end
    end

    function characterMeta:giveFlags(flags)
        local addedFlags = ""
        local ply = self:getPlayer()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not self:hasFlags(flag) then
                addedFlags = addedFlags .. flag
                local info = lia.flag.list[flag]
                if info and info.callback and ply and IsValid(ply) then info.callback(ply, true) end
            end
        end

        if addedFlags ~= "" then
            self:setFlags(self:getFlags() .. addedFlags)
            if ply and IsValid(ply) then hook.Run("OnCharFlagsGiven", ply, self, addedFlags) end
        end
    end

    function characterMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        local ply = self:getPlayer()
        local removedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback and ply and IsValid(ply) then info.callback(ply, false) end
            newFlags = newFlags:gsub(flag, "")
            if not removedFlags:find(flag, 1, true) then removedFlags = removedFlags .. flag end
        end

        if newFlags ~= oldFlags then
            self:setFlags(newFlags)
            if removedFlags ~= "" then hook.Run("OnCharFlagsTaken", ply, self, removedFlags) end
        end
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
            end, nil, "id = " .. self:getID())
        end
    end

    function characterMeta:sync(receiver)
        if receiver == nil then
            for _, v in player.Iterator() do
                self:sync(v)
            end
        elseif receiver == self.player then
            local player = self:getPlayer()
            if IsValid(player) then
                local data = {}
                for k, v in pairs(self.vars) do
                    if lia.char.vars[k] ~= nil and not lia.char.vars[k].noNetworking then data[k] = v end
                end

                net.Start("liaCharInfo")
                net.WriteTable(data)
                net.WriteUInt(self:getID(), 32)
                net.Send(player)
                for _, v in pairs(lia.char.vars) do
                    if isfunction(v.onSync) then v.onSync(self, player) end
                end
            end
        else
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if not v.noNetworking and not v.isLocal then data[k] = self.vars[k] end
            end

            net.Start("liaCharInfo")
            net.WriteTable(data)
            net.WriteUInt(self:getID(), 32)
            net.WriteEntity(self:getPlayer())
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
            for k, v in pairs(self:getBodygroups()) do
                local index = tonumber(k)
                local value = tonumber(v) or 0
                if index then client:SetBodygroup(index, value) end
            end

            client:SetSkin(self:getSkin())
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
        local curChar, steamID = client:getChar(), client:SteamID()
        local isCurChar = curChar and curChar:getID() == self:getID() or false
        if self.steamID == steamID then
            if isCurChar then
                net.Start("liaRemoveFOne")
                net.Send(client)
            end

            net.Start("liaCharKick")
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
        local value
        if time then
            value = os.time() + math.max(math.ceil(time), 60)
        else
            value = -1
        end

        self:setBanned(value)
        self:save()
        self:kick()
        hook.Run("OnCharPermakilled", self, time or nil)
    end

    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    function characterMeta:destroy()
        local id = self:getID()
        lia.char.removeCharacter(id)
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
