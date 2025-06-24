local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
--[[
    characterMeta:tostring()

    Description:
        Returns a printable identifier for this character.

    Realm:
        Shared

    Returns:
        string – Format "character[id]".
]]
function characterMeta:tostring()
    return "character[" .. (self.id or 0) .. "]"
end

--[[
    characterMeta:eq(other)

    Description:
        Compares two characters by ID for equality.

    Parameters:
        other (Character) – Character to compare.

    Realm:
        Shared

    Returns:
        boolean – True if both share the same ID.
]]
function characterMeta:eq(other)
    return self:getID() == other:getID()
end

--[[
    characterMeta:getID()

    Description:
        Returns the unique database ID for this character.

    Realm:
        Shared

    Returns:
        number – Character identifier.
]]
function characterMeta:getID()
    return self.id
end

--[[
    characterMeta:getPlayer()

    Description:
        Returns the player entity currently controlling this character.

    Realm:
        Shared

    Returns:
        Player|nil – Owning player or nil.
]]
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

--[[
    characterMeta:getDisplayedName(client)

    Description:
        Returns the character's name as it should be shown to the given player.

    Parameters:
        client (Player) – Player requesting the name.

    Realm:
        Shared

    Returns:
        string – Localized or recognized character name.
]]
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

--[[
    characterMeta:hasMoney(amount)

    Description:
        Checks if the character has at least the given amount of money.

    Parameters:
        amount (number) – Amount to check for.

    Realm:
        Shared

    Returns:
        boolean – True if the character's funds are sufficient.
]]
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--[[
    characterMeta:getFlags()

    Description:
        Retrieves the string of permission flags for this character.

    Realm:
        Shared

    Returns:
        string – Concatenated flag characters.
]]
function characterMeta:getFlags()
    return self:getData("f", "")
end

--[[
    characterMeta:hasFlags(flags)

    Description:
        Checks if the character possesses any of the specified flags.

    Parameters:
        flags (string) – String of flag characters to check.

    Realm:
        Shared

    Returns:
        boolean – True if at least one flag is present.
]]
function characterMeta:hasFlags(flags)
    for i = 1, #flags do
        if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

--[[
    characterMeta:getItemWeapon(requireEquip)

    Description:
        Checks the player's active weapon against items in the inventory.

    Parameters:
        requireEquip (boolean) – Only match equipped items if true.

    Realm:
        Shared

    Returns:
        boolean – True if the active weapon corresponds to an item.
]]
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

--[[
    characterMeta:getMaxStamina()

    Description:
        Returns the maximum stamina value for this character.

    Realm:
        Shared

    Returns:
        number – Maximum stamina points.
]]
function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("getCharMaxStamina", self) or lia.config.get("DefaultStamina", 100)
    return maxStamina
end

--[[
    characterMeta:getStamina()

    Description:
        Retrieves the character's current stamina value.

    Realm:
        Shared

    Returns:
        number – Current stamina.
]]
function characterMeta:getStamina()
    local stamina = self:getPlayer():getLocalVar("stamina", 100) or lia.config.get("DefaultStamina", 100)
    return stamina
end

--[[
    characterMeta:hasClassWhitelist(class)

    Description:
        Checks if the character has whitelisted the given class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – True if the class is whitelisted.
]]
function characterMeta:hasClassWhitelist(class)
    local wl = self:getData("whitelist", {})
    return wl[class] ~= nil
end

--[[
    characterMeta:isFaction(faction)

    Description:
        Returns true if the character's faction matches.

    Parameters:
        faction (number) – Faction index.

    Realm:
        Shared

    Returns:
        boolean – Whether the faction matches.
]]
function characterMeta:isFaction(faction)
    return self:getFaction() == faction
end

--[[
    characterMeta:isClass(class)

    Description:
        Returns true if the character's class equals the specified class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – Whether the classes match.
]]
function characterMeta:isClass(class)
    return self:getClass() == class
end

--[[
    characterMeta:getAttrib(key, default)

    Description:
        Retrieves the value of an attribute including boosts.

    Parameters:
        key (string) – Attribute identifier.
        default (number) – Default value when attribute is missing.

    Realm:
        Shared

    Returns:
        number – Final attribute value.
]]
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

--[[
    characterMeta:getBoost(attribID)

    Description:
        Returns the boost table for the given attribute.

    Parameters:
        attribID (string) – Attribute identifier.

    Realm:
        Shared

    Returns:
        table|nil – Table of boosts or nil.
]]
function characterMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

--[[
    characterMeta:getBoosts()

    Description:
        Retrieves all attribute boosts for this character.

    Realm:
        Shared

    Returns:
        table – Mapping of attribute IDs to boost tables.
]]
function characterMeta:getBoosts()
    return self:getVar("boosts", {})
end

--[[
    characterMeta:doesRecognize(id)

    Description:
        Determines if this character recognizes another character.

    Parameters:
        id (number|Character) – Character ID or object to check.

    Realm:
        Shared

    Returns:
        boolean – True if recognized.
]]
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

--[[
    characterMeta:doesFakeRecognize(id)

    Description:
        Checks if the character has a fake recognition entry for another.

    Parameters:
        id (number|Character) – Character identifier.

    Realm:
        Shared

    Returns:
        boolean – True if fake recognized.
]]
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
            netstream.Start(client, "attrib", self:getID(), key, attrib[key])
            if attribute.setup then attribute.setup(attrib[key]) end
        end
    end

    function characterMeta:setAttrib(key, value)
        local client = self:getPlayer()
        local attribute = lia.attribs.list[key]
        if attribute then
            local attrib = self:getAttribs()
            attrib[key] = value
            if IsValid(client) then
                netstream.Start(client, "attrib", self:getID(), key, attrib[key])
                if attribute.setup then attribute.setup(attrib[key]) end
            end
        end

        hook.Run("OnCharAttribUpdated", client, self, key, value)
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
