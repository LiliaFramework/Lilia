--[[
    Hooks:
        OnPlayerSwitchClass(client, class, oldClass)

    Purpose:
        Runs after a character switches from one class to another through `joinClass`.

    Category:
        Character

    Parameters:
        client (Player)
            The player whose character switched classes.

        class (number|string)
            The new class identifier assigned to the character.

        oldClass (number|string)
            The previous class identifier.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnPlayerSwitchClass", "liaExampleOnPlayerSwitchClass", function(client, class, oldClass)
            print(client:Nick(), oldClass, class)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharAttribUpdated(client, self, key, value)

    Purpose:
        Runs after a character attribute has been updated and synced to the owning client.

    Category:
        Character

    Parameters:
        client (Player)
            The player who owns the character.

        self (Character)
            The character whose attribute changed.

        key (string)
            The attribute identifier that changed.

        value (number)
            The new attribute value.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharAttribUpdated", "liaExampleOnCharAttribUpdated", function(client, self, key, value)
            print("Attribute updated:", key, value)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharAttribBoosted(client, self, attribID, boostID, boostAmount)

    Purpose:
        Runs after an attribute boost has been added, removed, or cleared.

    Category:
        Character

    Parameters:
        client (Player)
            The player who owns the character, if valid.

        self (Character)
            The character whose boost data changed.

        attribID (string)
            The boosted attribute identifier.

        boostID (string)
            The boost source identifier.

        boostAmount (number|boolean)
            The applied boost amount, or `true` when a boost was removed.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharAttribBoosted", "liaExampleOnCharAttribBoosted", function(client, self, attribID, boostID, boostAmount)
            print("Boost changed:", attribID, boostID)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharFlagsGiven(ply, self, addedFlags)

    Purpose:
        Runs after new flags have been granted to a character.

    Category:
        Character

    Parameters:
        ply (Player)
            The player who owns the character.

        self (Character)
            The character that received new flags.

        addedFlags (string)
            The flag characters that were added.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharFlagsGiven", "liaExampleOnCharFlagsGiven", function(ply, self, addedFlags)
            print("Flags granted:", addedFlags)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharFlagsTaken(ply, self, removedFlags)

    Purpose:
        Runs after flags have been removed from a character.

    Category:
        Character

    Parameters:
        ply (Player)
            The player who owns the character.

        self (Character)
            The character that lost flags.

        removedFlags (string)
            The flag characters that were removed.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharFlagsTaken", "liaExampleOnCharFlagsTaken", function(ply, self, removedFlags)
            print("Flags removed:", removedFlags)
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        CharPostSave(self)

    Purpose:
        Runs after a character's field-backed variables have been persisted to the database.

    Category:
        Character

    Parameters:
        self (Character)
            The character that was saved.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("CharPostSave", "liaExampleCharPostSave", function(self)
            print("Saved character", self:getID())
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharKick(self, client)

    Purpose:
        Runs after a character has been kicked back to character selection.

    Category:
        Character

    Parameters:
        self (Character)
            The character that was kicked.

        client (Player)
            The player removed from the character.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharKick", "liaExampleOnCharKick", function(self, client)
            print("Kicked character", self:getID())
        end)
        ```

    Realm:
        Server
]]
--[[
    Hooks:
        OnCharPermakilled(self, time)

    Purpose:
        Runs after a character has been banned by `ban`, including permanent bans.

    Category:
        Character

    Parameters:
        self (Character)
            The character that was banned.

        time (number|nil)
            The temporary ban duration passed to `ban`, or nil for a permanent ban.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnCharPermakilled", "liaExampleOnCharPermakilled", function(self, time)
            print("Character banned", self:getID(), time)
        end)
        ```

    Realm:
        Server
]]
--[[
    Folder: Developer - Meta Tables
    File: character.md
]]
--[[
    Character

    Character metadata helpers for lookup, recognition, persistence, and state management.
]]
--[[
    Overview:
        The character meta table wraps a loaded character instance and exposes helpers for identity lookup, attribute and flag access, recognition state, character data storage, networking, and server-side lifecycle actions such as syncing, saving, banning, and deletion.
]]
local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
--[[
    Purpose:
        Returns the numeric ID assigned to this character.

    Returns:
        number
            The character ID.

    Example Usage:
        ```lua
        local charID = character:getID()
        print("Character ID:", charID)
        ```

    Realm:
        Shared
]]
function characterMeta:getID()
    return self.id
end

--[[
    Purpose:
        Resolves and caches the player currently using this character, if any.

    Returns:
        Player|nil
            The owning player when found.

    Example Usage:
        ```lua
        local owner = character:getPlayer()
        if IsValid(owner) then print(owner:Nick()) end
        ```

    Realm:
        Shared
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
    Purpose:
        Returns the name this character should display to a specific viewer.

    Parameters:
        client (Player)
            The player viewing this character.

    Returns:
        string
            The true name, a fake recognized name, or the localized unknown label.

    Example Usage:
        ```lua
        local shownName = targetCharacter:getDisplayedName(viewer)
        viewer:ChatPrint(shownName)
        ```

    Realm:
        Shared
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
    Purpose:
        Checks whether the character has at least the requested amount of money.

    Parameters:
        amount (number)
            The required amount.

    Returns:
        boolean
            `true` if the character has enough money.

    Example Usage:
        ```lua
        if character:hasMoney(500) then
            print("Character can afford this purchase.")
        end
        ```

    Realm:
        Shared
]]
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--[[
    Purpose:
        Checks whether the character owns any of the supplied flags.

    Parameters:
        flagStr (string)
            One or more flag characters to test.

    Returns:
        boolean
            `true` if any requested flag is present.

    Example Usage:
        ```lua
        if character:hasFlags("pet") then
            print("Character has at least one of those flags.")
        end
        ```

    Realm:
        Shared
]]
function characterMeta:hasFlags(flagStr)
    local flags = self:getFlags()
    for i = 1, #flagStr do
        local flag = flagStr:sub(i, i)
        if flags:find(flag, 1, true) then return true end
    end
    return false
end

--[[
    Purpose:
        Returns an attribute value after applying any active boosts for that attribute.

    Parameters:
        key (string)
            The attribute ID.
        default (number)
            Fallback value when the attribute is unset.

    Returns:
        number
            The current effective attribute value.

    Example Usage:
        ```lua
        local strength = character:getAttrib("str", 0)
        print("Strength:", strength)
        ```

    Realm:
        Shared
]]
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

--[[
    Purpose:
        Checks whether this character normally recognizes another character ID.

    Parameters:
        id (number|table)
            A character ID or character object.

    Returns:
        boolean
            `true` unless a hook explicitly rejects recognition.

    Example Usage:
        ```lua
        if viewerCharacter:doesRecognize(targetCharacter) then
            print("This character is recognized.")
        end
        ```

    Realm:
        Shared
]]
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharRecognized", self, id) ~= false
end

--[[
    Purpose:
        Checks whether this character uses a fake recognized name for another character.

    Parameters:
        id (number|table)
            A character ID or character object.

    Returns:
        boolean
            `true` unless a hook explicitly rejects fake recognition.

    Example Usage:
        ```lua
        if viewerCharacter:doesFakeRecognize(targetCharacter) then
            print("A fake recognized name is being used.")
        end
        ```

    Realm:
        Shared
]]
function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharFakeRecognized", self, id) ~= false
end

--[[
    Purpose:
        Stores arbitrary character data, optionally replicating it and persisting it on the server.

    Parameters:
        k (string|table)
            A single key or a table of key-value pairs.
        v (any)
            The value for a single key update.
        noReplication (boolean)
            Whether to skip sending the updated data over the network.
        receiver (Player)
            An optional player to receive replicated data.

    Returns:
        nil

    Example Usage:
        ```lua
        character:setData("title", "Quartermaster")
        character:setData({
            rank = "Captain",
            callsign = "Echo-3"
        })
        ```

    Realm:
        Shared
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

--[[
    Purpose:
        Retrieves stored character data, checking the cache first and the database on the server when needed.

    Parameters:
        key (string|nil)
            The key to fetch, or `nil` to return the full data table.
        default (any)
            The fallback value if the key is missing.

    Returns:
        any
            The stored value, the full data table, or the fallback.

    Example Usage:
        ```lua
        local title = character:getData("title", "Citizen")
        local allData = character:getData()
        ```

    Realm:
        Shared
]]
function characterMeta:getData(key, default)
    self.dataVars = self.dataVars or {}
    if not key then return self.dataVars end
    local value = self.dataVars and self.dataVars[key]
    if value == nil then
        if SERVER then
            local charID = self:getID()
            if charID then
                local dbValue = lia.char.getCharData(charID, key)
                if dbValue ~= nil then
                    self.dataVars[key] = dbValue
                    return dbValue
                end
            end
        end
        return default
    end
    return value
end

--[[
    Purpose:
        Checks whether the character is currently banned.

    Returns:
        boolean
            `true` if the ban is permanent or still active.

    Example Usage:
        ```lua
        if character:isBanned() then
            print("This character cannot be selected right now.")
        end
        ```

    Realm:
        Shared
]]
function characterMeta:isBanned()
    local banned = self:getBanned()
    return banned ~= 0 and (banned == -1 or banned > os.time())
end

if SERVER then
    --[[
    Purpose:
        Marks another character as recognized, optionally storing a fake display name.

    Parameters:
        character (number|table)
            A character ID or character object to recognize.
        name (string|nil)
            A fake name to store instead of normal recognition.

    Returns:
        boolean
            `true` after the recognition data is updated.

    Example Usage:
        ```lua
        observerCharacter:recognize(targetCharacter)
        observerCharacter:recognize(targetCharacter, "John Doe")
        ```

    Realm:
        Server
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
    Purpose:
        Moves the character into a class if the class exists and passes eligibility checks.

    Parameters:
        class (string|number|nil)
            The class identifier to join.
        isForced (boolean)
            Whether to bypass `lia.class.canBe`.

    Returns:
        boolean
            `true` if the class was joined.

    Example Usage:
        ```lua
        local joined = character:joinClass(CLASS_MEDIC)
        print("Joined class:", joined)
        ```

    Realm:
        Server
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
    Purpose:
        Removes the character from its current class and falls back to the faction default when possible.

    Returns:
        nil

    Example Usage:
        ```lua
        character:kickClass()
        ```

    Realm:
        Server
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
    Purpose:
        Adds to an attribute without exceeding the configured maximum, then syncs it to the owner.

    Parameters:
        key (string)
            The attribute ID.
        value (number)
            The amount to add.

    Returns:
        nil

    Example Usage:
        ```lua
        character:updateAttrib("stm", 5)
        ```

    Realm:
        Server
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
            net.Start("liaAttributeData")
            net.WriteUInt(self:getID(), 32)
            net.WriteString(key)
            net.WriteType(attrib[key])
            net.Send(client)
            hook.Run("OnCharAttribUpdated", client, self, key, attrib[key])
        end
    end

    --[[
    Purpose:
        Sets an attribute to an exact value and syncs it to the owner.

    Parameters:
        key (string)
            The attribute ID.
        value (number)
            The new raw value.

    Returns:
        nil

    Example Usage:
        ```lua
        character:setAttrib("str", 15)
        ```

    Realm:
        Server
]]
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

    --[[
    Purpose:
        Adds or replaces a temporary boost on an attribute.

    Parameters:
        boostID (string)
            A unique identifier for the boost source.
        attribID (string)
            The attribute being boosted.
        boostAmount (number)
            The amount to apply.

    Returns:
        any
            The result of `setVar`.

    Example Usage:
        ```lua
        character:addBoost("adrenaline", "stm", 10)
        ```

    Realm:
        Server
]]
    function characterMeta:addBoost(boostID, attribID, boostAmount)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = boostAmount
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
    Purpose:
        Removes one temporary boost from an attribute.

    Parameters:
        boostID (string)
            The boost identifier to remove.
        attribID (string)
            The attribute the boost belongs to.

    Returns:
        any
            The result of `setVar`.

    Example Usage:
        ```lua
        character:removeBoost("adrenaline", "stm")
        ```

    Realm:
        Server
]]
    function characterMeta:removeBoost(boostID, attribID)
        local boosts = self:getVar("boosts", {})
        boosts[attribID] = boosts[attribID] or {}
        boosts[attribID][boostID] = nil
        hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)
        return self:setVar("boosts", boosts, nil, self:getPlayer())
    end

    --[[
    Purpose:
        Clears every active attribute boost on the character.

    Returns:
        any
            The result of `setVar`.

    Example Usage:
        ```lua
        character:clearAllBoosts()
        ```

    Realm:
        Server
]]
    function characterMeta:clearAllBoosts()
        local client = self:getPlayer()
        local boosts = self:getVar("boosts", {})
        for attribID, attribBoosts in pairs(boosts) do
            for boostID, _ in pairs(attribBoosts) do
                hook.Run("OnCharAttribBoosted", client, self, attribID, boostID, true)
            end
        end
        return self:setVar("boosts", {}, nil, client)
    end

    --[[
    Purpose:
        Replaces the character's entire flag string and triggers flag callbacks.

    Parameters:
        flags (string)
            The complete set of flags to store.

    Returns:
        nil

    Example Usage:
        ```lua
        character:setFlags("pet")
        ```

    Realm:
        Server
]]
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

    --[[
    Purpose:
        Adds any missing flags from the supplied string.

    Parameters:
        flags (string)
            The flags to grant.

    Returns:
        nil

    Example Usage:
        ```lua
        character:giveFlags("ab")
        ```

    Realm:
        Server
]]
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

    --[[
    Purpose:
        Removes any matching flags from the supplied string.

    Parameters:
        flags (string)
            The flags to revoke.

    Returns:
        nil

    Example Usage:
        ```lua
        character:takeFlags("b")
        ```

    Realm:
        Server
]]
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

    --[[
    Purpose:
        Persists the character's field-backed variables to the database.

    Parameters:
        callback (function|nil)
            Runs after a successful save.

    Returns:
        nil

    Example Usage:
        ```lua
        character:save(function()
            print("Character saved.")
        end)
        ```

    Realm:
        Server
]]
    function characterMeta:save(callback)
        if self.isBot then return end
        local shouldSave = hook.Run("CharPreSave", self)
        if shouldSave ~= false then
            local data = {}
            for k, v in pairs(lia.char.vars) do
                if v.field and self.vars[k] ~= nil then data[v.field] = self.vars[k] end
            end

            lia.db.updateTable(data, function()
                if callback then callback() end
                hook.Run("CharPostSave", self)
            end, nil, "id = " .. self:getID())
        end
    end

    --[[
    Purpose:
        Sends this character's networked state to one player or every player.

    Parameters:
        receiver (Player|nil)
            The player to sync to, or `nil` to sync to everyone.

    Returns:
        nil

    Example Usage:
        ```lua
        character:sync()
        character:sync(adminPlayer)
        ```

    Realm:
        Server
]]
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
            local ply = self:getPlayer()
            if IsValid(ply) then
                lia.net[ply] = lia.net[ply] or {}
                local oldVal = lia.net[ply]["char"]
                lia.net[ply]["char"] = self:getID()
                net.Start("liaNetVar")
                net.WriteUInt(ply:EntIndex(), 16)
                net.WriteString("char")
                net.WriteType(self:getID())
                net.Send(receiver)
                hook.Run("NetVarChanged", ply, "char", oldVal, self:getID())
            end

            for _, v in pairs(lia.char.vars) do
                if isfunction(v.onSync) then v.onSync(self, receiver) end
            end
        end
    end

    --[[
    Purpose:
        Applies the character to its owning player and optionally syncs inventories and character vars.

    Parameters:
        noNetworking (boolean)
            Whether to skip syncing inventories and character data.

    Returns:
        nil

    Example Usage:
        ```lua
        character:setup()
        ```

    Realm:
        Server
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
            lia.util.applyBodygroups(client, self:getBodygroups())
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
    Purpose:
        Removes the owning player from this character and returns them to the selection state.

    Returns:
        nil

    Example Usage:
        ```lua
        character:kick()
        ```

    Realm:
        Server
]]
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

    --[[
    Purpose:
        Bans the character until a timestamp or permanently, then saves and kicks it.

    Parameters:
        time (number|nil)
            Ban duration in seconds. `nil` creates a permanent ban.

    Returns:
        nil

    Example Usage:
        ```lua
        character:ban(3600)
        character:ban()
        ```

    Realm:
        Server
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
    Purpose:
        Deletes the character through the character library.

    Returns:
        nil

    Example Usage:
        ```lua
        character:delete()
        ```

    Realm:
        Server
]]
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --[[
    Purpose:
        Removes the character from the loaded character cache.

    Returns:
        nil

    Example Usage:
        ```lua
        character:destroy()
        ```

    Realm:
        Server
]]
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.removeCharacter(id)
    end

    --[[
    Purpose:
        Gives money to the owning player through the player money helper.

    Parameters:
        amount (number)
            The amount to add.

    Returns:
        boolean
            `false` if the player is not valid, otherwise the result of `addMoney`.

    Example Usage:
        ```lua
        character:giveMoney(250)
        ```

    Realm:
        Server
]]
    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        return client:addMoney(amount)
    end

    --[[
    Purpose:
        Removes money from the owning player by applying a negative money change.

    Parameters:
        amount (number)
            The amount to remove.

    Returns:
        boolean
            Always returns `true`.

    Example Usage:
        ```lua
        character:takeMoney(100)
        ```

    Realm:
        Server
]]
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end

    --[[
    Purpose:
        Checks whether this character is set as the player's main character.

    Returns:
        boolean
            `true` when the owner's main character ID matches this character.

    Example Usage:
        ```lua
        if character:isMainCharacter() then
            print("This is the player's main character.")
        end
        ```

    Realm:
        Server
]]
    function characterMeta:isMainCharacter()
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        local mainCharID = client:getMainCharacter()
        return mainCharID == self:getID()
    end
end

lia.meta.character = characterMeta
