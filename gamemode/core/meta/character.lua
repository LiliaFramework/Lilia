local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
--[[
    tostring

    Purpose:
        Returns a string representation of the character, including its ID.

    Returns:
        string - The string representation of the character.

    Realm:
        Shared.

    Example Usage:
        print(character:tostring()) -- Output: "Character[1]"
]]
function characterMeta:tostring()
    return L("character") .. "[" .. (self.id or 0) .. "]"
end

--[[
    eq

    Purpose:
        Checks if this character is equal to another character by comparing their IDs.

    Parameters:
        other (Character) - The character to compare with.

    Returns:
        boolean - True if the characters have the same ID, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:eq(otherCharacter) then
            print("Characters are the same.")
        end
]]
function characterMeta:eq(other)
    return self:getID() == other:getID()
end

--[[
    getID

    Purpose:
        Returns the unique ID of this character.

    Returns:
        number - The character's ID.

    Realm:
        Shared.

    Example Usage:
        local id = character:getID()
        print("Character ID:", id)
]]
function characterMeta:getID()
    return self.id
end

--[[
    getPlayer

    Purpose:
        Returns the player entity associated with this character.

    Returns:
        Player or nil - The player entity, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local ply = character:getPlayer()
        if ply then print("Player found!") end
]]
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

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    local myReg = ourCharacter:getFakeName()
    if ourCharacter:doesFakeRecognize(characterID) and myReg[characterID] then return myReg[characterID] end
    return L("unknown")
end

--[[
    hasMoney

    Purpose:
        Checks if the character has at least the specified amount of money.

    Parameters:
        amount (number) - The amount to check.

    Returns:
        boolean - True if the character has at least the specified amount, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:hasMoney(100) then
            print("Character has enough money.")
        end
]]
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--[[
    hasFlags

    Purpose:
        Checks if the character has any of the specified flags.

    Parameters:
        flagStr (string) - A string of flag characters to check.

    Returns:
        boolean - True if the character has any of the specified flags, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:hasFlags("a") then
            print("Character has flag 'a'.")
        end
]]
function characterMeta:hasFlags(flagStr)
    local flags = self:getFlags()
    for i = 1, #flagStr do
        if flags:find(flagStr:sub(i, i), 1, true) then return true end
    end
    return false
end

--[[
    getItemWeapon

    Purpose:
        Checks if the character's currently equipped weapon matches an item in their inventory.

    Parameters:
        requireEquip (boolean) - Whether the item must be equipped (default: true).

    Returns:
        boolean - True if the weapon is found and equipped (if required), false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:getItemWeapon() then
            print("Character's weapon matches an inventory item.")
        end
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
    getMaxStamina

    Purpose:
        Returns the maximum stamina value for this character, possibly modified by hooks.

    Returns:
        number - The maximum stamina value.

    Realm:
        Shared.

    Example Usage:
        local maxStamina = character:getMaxStamina()
        print("Max stamina:", maxStamina)
]]
function characterMeta:getMaxStamina()
    local maxStamina = hook.Run("getCharMaxStamina", self) or lia.config.get("DefaultStamina", 100)
    return maxStamina
end

--[[
    getStamina

    Purpose:
        Returns the current stamina value for this character.

    Returns:
        number - The current stamina value.

    Realm:
        Shared.

    Example Usage:
        local stamina = character:getStamina()
        print("Current stamina:", stamina)
]]
function characterMeta:getStamina()
    local stamina = self:getPlayer():getLocalVar("stamina", 100) or lia.config.get("DefaultStamina", 100)
    return stamina
end

--[[
    hasClassWhitelist

    Purpose:
        Checks if the character has a whitelist for the specified class.

    Parameters:
        class (string or number) - The class to check.

    Returns:
        boolean - True if the character is whitelisted for the class, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:hasClassWhitelist("medic") then
            print("Character is whitelisted for medic class.")
        end
]]
function characterMeta:hasClassWhitelist(class)
    local wl = self:getClasswhitelists() or {}
    return wl[class] == true
end

--[[
    isFaction

    Purpose:
        Checks if the character belongs to the specified faction.

    Parameters:
        faction (number) - The faction index to check.

    Returns:
        boolean - True if the character is in the faction, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:isFaction(2) then
            print("Character is in faction 2.")
        end
]]
function characterMeta:isFaction(faction)
    return self:getFaction() == faction
end

--[[
    isClass

    Purpose:
        Checks if the character is in the specified class.

    Parameters:
        class (number) - The class index to check.

    Returns:
        boolean - True if the character is in the class, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:isClass(1) then
            print("Character is in class 1.")
        end
]]
function characterMeta:isClass(class)
    return self:getClass() == class
end

--[[
    getAttrib

    Purpose:
        Returns the value of the specified attribute for this character, including any boosts.

    Parameters:
        key (string) - The attribute key.
        default (number) - The default value if the attribute is not set.

    Returns:
        number - The attribute value including boosts.

    Realm:
        Shared.

    Example Usage:
        local strength = character:getAttrib("str", 0)
        print("Strength:", strength)
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
    getBoost

    Purpose:
        Returns the boost table for the specified attribute.

    Parameters:
        attribID (string) - The attribute key.

    Returns:
        table or nil - The boost table for the attribute, or nil if none.

    Realm:
        Shared.

    Example Usage:
        local boost = character:getBoost("str")
        if boost then print("Strength is boosted!") end
]]
function characterMeta:getBoost(attribID)
    local boosts = self:getBoosts()
    return boosts[attribID]
end

--[[
    getBoosts

    Purpose:
        Returns the table of all attribute boosts for this character.

    Returns:
        table - The boosts table.

    Realm:
        Shared.

    Example Usage:
        local boosts = character:getBoosts()
        PrintTable(boosts)
]]
function characterMeta:getBoosts()
    return self:getVar("boosts", {})
end

--[[
    doesRecognize

    Purpose:
        Checks if this character recognizes another character by ID.

    Parameters:
        id (number or Character) - The character ID or character object.

    Returns:
        boolean - True if recognized, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:doesRecognize(otherChar) then
            print("Character recognizes the other character.")
        end
]]
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

--[[
    doesFakeRecognize

    Purpose:
        Checks if this character fake-recognizes another character by ID.

    Parameters:
        id (number or Character) - The character ID or character object.

    Returns:
        boolean - True if fake-recognized, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:doesFakeRecognize(otherChar) then
            print("Character fake-recognizes the other character.")
        end
]]
function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharFakeRecognized", self, id) ~= false
end

--[[
    setData

    Purpose:
        Sets custom data for this character, optionally replicating to clients and saving to the database.

    Parameters:
        k (string or table) - The key or table of key-value pairs to set.
        v (any) - The value to set (if k is a string).
        noReplication (boolean) - If true, do not replicate to clients.
        receiver (Player) - The player to send the data to (optional).

    Returns:
        nil

    Realm:
        Shared (writes to database on server).

    Example Usage:
        character:setData("customKey", 123)
        character:setData({foo = "bar", baz = 42})
]]
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

--[[
    getData

    Purpose:
        Gets custom data for this character.

    Parameters:
        key (string) - The key to retrieve (optional).
        default (any) - The default value if the key is not set.

    Returns:
        any - The value for the key, or the entire dataVars table if no key is given.

    Realm:
        Shared.

    Example Usage:
        local value = character:getData("customKey", 0)
        local allData = character:getData()
]]
function characterMeta:getData(key, default)
    self.dataVars = self.dataVars or {}
    if not key then return self.dataVars end
    local value = self.dataVars and self.dataVars[key] or default
    return value
end

--[[
    isBanned

    Purpose:
        Checks if the character is currently banned.

    Returns:
        boolean - True if banned, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if character:isBanned() then
            print("Character is banned.")
        end
]]
function characterMeta:isBanned()
    local banned = self:getBanned()
    return banned ~= 0 and (banned == -1 or banned > os.time())
end

if SERVER then
    --[[
        recognize

        Purpose:
            Adds a character to this character's recognition list, or sets a fake name for them.

        Parameters:
            character (number or Character) - The character or character ID to recognize.
            name (string or nil) - The fake name to assign, or nil to just recognize.

        Returns:
            boolean - Always true.

        Realm:
            Server.

        Example Usage:
            character:recognize(otherChar)
            character:recognize(otherChar, "Alias Name")
    ]]
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

    --[[
        WhitelistAllClasses

        Purpose:
            Whitelists this character for all available classes.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:WhitelistAllClasses()
    ]]
    function characterMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if not lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    --[[
        WhitelistAllFactions

        Purpose:
            Whitelists this character for all available factions.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:WhitelistAllFactions()
    ]]
    function characterMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    --[[
        WhitelistEverything

        Purpose:
            Whitelists this character for all factions and classes.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:WhitelistEverything()
    ]]
    function characterMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    --[[
        classWhitelist

        Purpose:
            Adds a class to this character's whitelist.

        Parameters:
            class (string or number) - The class to whitelist.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:classWhitelist("medic")
    ]]
    function characterMeta:classWhitelist(class)
        local wl = self:getClasswhitelists() or {}
        wl[class] = true
        self:setClasswhitelists(wl)
    end

    --[[
        classUnWhitelist

        Purpose:
            Removes a class from this character's whitelist.

        Parameters:
            class (string or number) - The class to remove from the whitelist.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:classUnWhitelist("medic")
    ]]
    function characterMeta:classUnWhitelist(class)
        local wl = self:getClasswhitelists() or {}
        wl[class] = nil
        self:setClasswhitelists(wl)
    end

    --[[
        joinClass

        Purpose:
            Attempts to set the character's class to the specified class.

        Parameters:
            class (number) - The class index to join.
            isForced (boolean) - If true, force the join regardless of requirements.

        Returns:
            boolean - True if the class was joined, false otherwise.

        Realm:
            Server.

        Example Usage:
            character:joinClass(2)
    ]]
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

    --[[
        kickClass

        Purpose:
            Removes the character from their current class and assigns a default class if available.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:kickClass()
    ]]
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

    --[[
        updateAttrib

        Purpose:
            Increases the value of the specified attribute for this character, up to the maximum allowed.

        Parameters:
            key (string) - The attribute key.
            value (number) - The amount to add.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:updateAttrib("str", 1)
    ]]
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

    --[[
        setAttrib

        Purpose:
            Sets the value of the specified attribute for this character.

        Parameters:
            key (string) - The attribute key.
            value (number) - The value to set.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:setAttrib("str", 10)
    ]]
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

    --[[
        addBoost

        Purpose:
            Adds a boost to the specified attribute for this character.

        Parameters:
            boostID (string) - The unique ID for the boost.
            attribID (string) - The attribute key.
            boostAmount (number) - The amount of the boost.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:addBoost("buff1", "str", 5)
    ]]
    function characterMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
        removeBoost

        Purpose:
            Removes a boost from the specified attribute for this character.

        Parameters:
            boostID (string) - The unique ID for the boost.
            attribID (string) - The attribute key.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:removeBoost("buff1", "str")
    ]]
    function characterMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
        setFlags

        Purpose:
            Sets the character's flags to the specified string, updating callbacks as needed.

        Parameters:
            flags (string) - The new flags string.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:setFlags("ab")
    ]]
    function characterMeta:setFlags(flags)
        local oldFlags = self:getFlags()
        self.vars.flags = flags
        net.Start("charSet")
        net.WriteString("flags")
        net.WriteType(flags)
        net.WriteType(self:getID())
        net.Broadcast()
        hook.Run("OnCharVarChanged", self, "flags", oldFlags, flags)
        local ply = self:getPlayer()
        if not IsValid(ply) then return end
        for i = 1, #oldFlags do
            local flag = oldFlags:sub(i, i)
            if not flags:find(flag, 1, true) and not ply:getPlayerFlags():find(flag, 1, true) then
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

    --[[
        giveFlags

        Purpose:
            Adds the specified flags to the character, calling any associated callbacks.

        Parameters:
            flags (string) - The flags to add.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:giveFlags("c")
    ]]
    function characterMeta:giveFlags(flags)
        local addedFlags = ""
        local ply = self:getPlayer()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not self:hasFlags(flag) then
                addedFlags = addedFlags .. flag
                local info = lia.flag.list[flag]
                if info and info.callback and IsValid(ply) then info.callback(ply, true) end
            end
        end

        if addedFlags ~= "" then self:setFlags(self:getFlags() .. addedFlags) end
    end

    --[[
        takeFlags

        Purpose:
            Removes the specified flags from the character, calling any associated callbacks.

        Parameters:
            flags (string) - The flags to remove.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:takeFlags("a")
    ]]
    function characterMeta:takeFlags(flags)
        local oldFlags = self:getFlags()
        local newFlags = oldFlags
        local ply = self:getPlayer()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            if info and info.callback and IsValid(ply) then
                local hasOther = ply:getPlayerFlags():find(flag, 1, true)
                if not hasOther then info.callback(ply, false) end
            end

            newFlags = newFlags:gsub(flag, "")
        end

        if newFlags ~= oldFlags then self:setFlags(newFlags) end
    end

    --[[
        save

        Purpose:
            Saves the character's data to the database.

        Parameters:
            callback (function) - Optional callback to call after saving.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:save(function() print("Character saved!") end)
    ]]
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

    --[[
        sync

        Purpose:
            Synchronizes the character's data with the specified receiver, or all players if none specified.

        Parameters:
            receiver (Player) - The player to sync to (optional).

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:sync()
            character:sync(specificPlayer)
    ]]
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

    --[[
        setup

        Purpose:
            Sets up the player entity to match this character's data (model, team, bodygroups, etc).

        Parameters:
            noNetworking (boolean) - If true, do not sync inventory and character data to clients.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:setup()
    ]]
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
            PrintTable(self:getBodygroups(), 1)
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

    --[[
        kick

        Purpose:
            Kicks the player from their character, killing them silently and notifying the client.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:kick()
    ]]
    function characterMeta:kick()
        local client = self:getPlayer()
        client:KillSilent()
        local curChar, steamID = client:getChar(), client:SteamID()
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

    --[[
        ban

        Purpose:
            Bans the character for a specified time or permanently.

        Parameters:
            time (number or nil) - The ban duration in seconds, or nil for permanent ban.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:ban(3600) -- Ban for 1 hour
            character:ban()     -- Permanent ban
    ]]
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

    --[[
        delete

        Purpose:
            Deletes this character from the database and notifies the player.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:delete()
    ]]
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --[[
        destroy

        Purpose:
            Removes this character from the loaded character table.

        Returns:
            nil

        Realm:
            Server.

        Example Usage:
            character:destroy()
    ]]
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.loaded[id] = nil
    end

    --[[
        giveMoney

        Purpose:
            Gives the specified amount of money to the character's player.

        Parameters:
            amount (number) - The amount to give.

        Returns:
            boolean - True if successful, false otherwise.

        Realm:
            Server.

        Example Usage:
            character:giveMoney(100)
    ]]
    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        return client:addMoney(amount)
    end

    --[[
        takeMoney

        Purpose:
            Takes the specified amount of money from the character's player.

        Parameters:
            amount (number) - The amount to take.

        Returns:
            boolean - Always true.

        Realm:
            Server.

        Example Usage:
            character:takeMoney(50)
    ]]
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end
end

lia.meta.character = characterMeta
