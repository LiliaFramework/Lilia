--[[
    Folder: Meta
    File:  character.md
]]
--[[
    Character

    Character management system for the Lilia framework.
]]
--[[
    Overview:
        The character meta table provides comprehensive functionality for managing character data, attributes, and operations in the Lilia framework. It handles character creation, data persistence, attribute management, recognition systems, and character-specific operations. The meta table operates on both server and client sides, with the server managing character storage and validation while the client provides character data access and display. It includes integration with the database system for character persistence, inventory management for character items, and faction/class systems for character roles. The meta table ensures proper character data synchronization, attribute calculations with boosts, recognition between characters, and comprehensive character lifecycle management from creation to deletion.
]]
local characterMeta = lia.meta.character or {}
characterMeta.__index = characterMeta
characterMeta.id = characterMeta.id or 0
characterMeta.vars = characterMeta.vars or {}
--[[
    Purpose:
        Returns this character's unique numeric identifier.

    When Called:
        Use when persisting, comparing, or networking character state.

    Parameters:
        None.

    Returns:
        number
            Character ID.

    Realm:
        Shared

    Example Usage:
        ```lua
            local id = char:getID()
        ```
]]
function characterMeta:getID()
    return self.id
end

--[[
    Purpose:
        Retrieves the player entity associated with this character.

    When Called:
        Use whenever you need the live player controlling this character.

    Parameters:
        None.

    Returns:
        Player|nil
            Player that owns the character, or nil if not found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local ply = char:getPlayer()
        ```
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
        Returns the name to show to a viewing client, honoring recognition rules.

    When Called:
        Use when rendering a character's name to another player.

    Parameters:
        client (Player)
            The viewer whose recognition determines the name.

    Returns:
        string
            Display name or a localized "unknown" placeholder.

    Realm:
        Shared

    Example Usage:
        ```lua
            local name = targetChar:getDisplayedName(viewer)
        ```
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
        Checks if the character has at least the given amount of money.

    When Called:
        Use before charging a character to ensure they can afford a cost.

    Parameters:
        amount (number)
            The amount to verify.

    Returns:
        boolean
            True if the character's balance is equal or higher.

    Realm:
        Shared

    Example Usage:
        ```lua
            if char:hasMoney(100) then purchase() end
        ```
]]
function characterMeta:hasMoney(amount)
    amount = tonumber(amount) or 0
    if amount < 0 then return false end
    return self:getMoney() >= amount
end

--[[
    Purpose:
        Determines whether the character possesses any flag in the string.

    When Called:
        Use when gating actions behind one or more privilege flags.

    Parameters:
        flagStr (string)
            One or more flag characters to test.

    Returns:
        boolean
            True if at least one provided flag is present.

    Realm:
        Shared

    Example Usage:
        ```lua
            if char:hasFlags("ab") then grantAccess() end
        ```
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
        Gets the character's attribute value including any active boosts.

    When Called:
        Use when calculating rolls or stats that depend on attributes.

    Parameters:
        key (string)
            Attribute identifier.
        default (number)
            Fallback value if the attribute is missing.

    Returns:
        number
            Attribute level plus stacked boosts.

    Realm:
        Shared

    Example Usage:
        ```lua
            local strength = char:getAttrib("str", 0)
        ```
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
        Determines whether this character recognizes another character.

    When Called:
        Use when deciding if a viewer should see a real name or remain unknown.

    Parameters:
        id (number|table)
            Character ID or object implementing getID.

    Returns:
        boolean
            True if recognition is allowed by hooks.

    Realm:
        Shared

    Example Usage:
        ```lua
            if viewerChar:doesRecognize(targetChar) then showName() end
        ```
]]
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharRecognized", self, id) ~= false
end

--[[
    Purpose:
        Checks if the character recognizes another under a fake name.

    When Called:
        Use when evaluating disguise or alias recognition logic.

    Parameters:
        id (number|table)
            Character ID or object implementing getID.

    Returns:
        boolean
            True if fake recognition passes custom hooks.

    Realm:
        Shared

    Example Usage:
        ```lua
            local canFake = char:doesFakeRecognize(otherChar)
        ```
]]
function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("IsCharFakeRecognized", self, id) ~= false
end

--[[
    Purpose:
        Stores custom data on the character and optionally replicates it.

    When Called:
        Use when adding persistent or networked character metadata.

    Parameters:
        k (string|table)
            Key to set or table of key/value pairs.
        v (any)
            Value to store when k is a string.
        noReplication (boolean)
            Skip networking when true.
        receiver (Player|nil)
            Specific client to receive the update instead of owner.
    Realm:
        Shared

    Example Usage:
        ```lua
            char:setData("lastLogin", os.time())
        ```
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
        Retrieves previously stored custom character data.

    When Called:
        Use when you need saved custom fields or default fallbacks.

    Parameters:
        key (string|nil)
            Specific key to fetch or nil for the whole table.
        default (any)
            Value to return if the key is unset.

    Returns:
        any
            Stored value, default, or entire data table.

    Realm:
        Shared

    Example Usage:
        ```lua
            local note = char:getData("note", "")
        ```
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
        Reports whether the character is currently banned.

    When Called:
        Use when validating character selection or spawning.

    Parameters:
        None.

    Returns:
        boolean
            True if banned permanently or until a future time.

    Realm:
        Shared

    Example Usage:
        ```lua
            if char:isBanned() then denyJoin() end
        ```
]]
function characterMeta:isBanned()
    local banned = self:getBanned()
    return banned ~= 0 and (banned == -1 or banned > os.time())
end

if SERVER then
    --[[
    Purpose:
        Marks another character as recognized, optionally storing a fake name.

    When Called:
        Invoke when a player learns or is assigned recognition of someone.

    Parameters:
        character (number|table)
            Target character ID or object implementing getID.
        name (string|nil)
            Optional alias to remember instead of real recognition.

    Returns:
        boolean
            True after recognition is recorded.

    Realm:
        Server

    Example Usage:
        ```lua
            char:recognize(otherChar)
        ```
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
        Attempts to place the character into the specified class.

    When Called:
        Use during class selection or forced reassignment.

    Parameters:
        class (number)
            Class ID to join.
        isForced (boolean)
            Skip eligibility checks when true.

    Returns:
        boolean
            True if the class change succeeded.

    Realm:
        Server

    Example Usage:
        ```lua
            local ok = char:joinClass(newClassID)
        ```
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
        Removes the character from its current class, falling back to default.

    When Called:
        Use when a class is invalid, revoked, or explicitly left.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            char:kickClass()
        ```
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
        Increases an attribute by the given amount, respecting maximums.

    When Called:
        Use when awarding experience toward an attribute.

    Parameters:
        key (string)
            Attribute identifier.
        value (number)
            Amount to add.
    Realm:
        Server

    Example Usage:
        ```lua
            char:updateAttrib("stm", 5)
        ```
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
        Directly sets an attribute to a specific value and syncs it.

    When Called:
        Use when loading characters or forcing an attribute level.

    Parameters:
        key (string)
            Attribute identifier.
        value (number)
            New attribute level.
    Realm:
        Server

    Example Usage:
        ```lua
            char:setAttrib("str", 15)
        ```
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
        Adds a temporary boost to an attribute and propagates it.

    When Called:
        Use when buffs or debuffs modify an attribute value.

    Parameters:
        boostID (string)
            Unique identifier for the boost source.
        attribID (string)
            Attribute being boosted.
        boostAmount (number)
            Amount to add (can be negative).

    Returns:
        boolean
            Result from setVar update.

    Realm:
        Server

    Example Usage:
        ```lua
            char:addBoost("stimpack", "end", 2)
        ```
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
        Removes a previously applied attribute boost.

    When Called:
        Use when a buff expires or is cancelled.

    Parameters:
        boostID (string)
            Identifier of the boost source.
        attribID (string)
            Attribute to adjust.

    Returns:
        boolean
            Result from setVar update.

    Realm:
        Server

    Example Usage:
        ```lua
            char:removeBoost("stimpack", "end")
        ```
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
        Clears all attribute boosts and notifies listeners.

    When Called:
        Use when resetting a character's temporary modifiers.

    Parameters:
        None.

    Returns:
        boolean
            Result from resetting the boost table.

    Realm:
        Server

    Example Usage:
        ```lua
            char:clearAllBoosts()
        ```
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
        Replaces the character's flag string and synchronizes it.

    When Called:
        Use when setting privileges wholesale (e.g., admin changes).

    Parameters:
        flags (string)
            Complete set of flags to apply.
    Realm:
        Server

    Example Usage:
        ```lua
            char:setFlags("abc")
        ```
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
        Adds one or more flags to the character if they are missing.

    When Called:
        Use when granting new permissions or perks.

    Parameters:
        flags (string)
            Concatenated flag characters to grant.
    Realm:
        Server

    Example Usage:
        ```lua
            char:giveFlags("z")
        ```
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
        Removes specific flags from the character and triggers callbacks.

    When Called:
        Use when revoking privileges or perks.

    Parameters:
        flags (string)
            Concatenated flag characters to remove.
    Realm:
        Server

    Example Usage:
        ```lua
            char:takeFlags("z")
        ```
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
        Persists the character's current variables to the database.

    When Called:
        Use during saves, character switches, or shutdown to keep data.

    Parameters:
        callback (function|nil)
            Invoked after the save completes.
    Realm:
        Server

    Example Usage:
        ```lua
            char:save(function() print("saved") end)
        ```
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
        Sends character data to a specific player or all players.

    When Called:
        Use after character creation, load, or when vars change.

    Parameters:
        receiver (Player|nil)
            Target player to sync to; nil broadcasts to everyone.
    Realm:
        Server

    Example Usage:
        ```lua
            char:sync(client)
        ```
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
        Applies the character state to the owning player and optionally syncs.

    When Called:
        Use right after a character is loaded or swapped in.

    Parameters:
        noNetworking (boolean)
            Skip inventory and char networking when true.
    Realm:
        Server

    Example Usage:
        ```lua
            char:setup()
        ```
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
    Purpose:
        Forces the owning player off this character and cleans up state.

    When Called:
        Use when removing access, kicking, or swapping characters.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            char:kick()
        ```
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
        Bans the character for a duration or permanently and kicks them.

    When Called:
        Use for disciplinary actions like permakill or timed bans.

    Parameters:
        time (number|nil)
            Ban duration in seconds; nil makes it permanent.
    Realm:
        Server

    Example Usage:
        ```lua
            char:ban(3600)
        ```
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
        Deletes the character from persistent storage.

    When Called:
        Use when a character is intentionally removed by the player or admin.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            char:delete()
        ```
]]
    function characterMeta:delete()
        lia.char.delete(self:getID(), self:getPlayer())
    end

    --[[
    Purpose:
        Removes the character from the active cache without DB interaction.

    When Called:
        Use when unloading a character instance entirely.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            char:destroy()
        ```
]]
    function characterMeta:destroy()
        local id = self:getID()
        lia.char.removeCharacter(id)
    end

    --[[
    Purpose:
        Adds money to the character through the owning player object.

    When Called:
        Use when rewarding or refunding currency.

    Parameters:
        amount (number)
            Amount to add (can be negative to deduct).

    Returns:
        boolean
            False if no valid player exists; otherwise result of addMoney.

    Realm:
        Server

    Example Usage:
        ```lua
            char:giveMoney(250)
        ```
]]
    function characterMeta:giveMoney(amount)
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        return client:addMoney(amount)
    end

    --[[
    Purpose:
        Deducts money from the character and logs the transaction.

    When Called:
        Use when charging a player for purchases or penalties.

    Parameters:
        amount (number)
            Amount to remove; the absolute value is used.

    Returns:
        boolean
            True after the deduction process runs.

    Realm:
        Server

    Example Usage:
        ```lua
            char:takeMoney(50)
        ```
]]
    function characterMeta:takeMoney(amount)
        amount = math.abs(amount)
        self:giveMoney(-amount)
        lia.log.add(self:getPlayer(), "money", -amount)
        return true
    end

    --[[
    Purpose:
        Checks whether this character matches the player's main character ID.

    When Called:
        Use when showing main character indicators or restrictions.

    Parameters:
        None.

    Returns:
        boolean
            True if this character is the player's main selection.

    Realm:
        Server

    Example Usage:
        ```lua
            if char:isMainCharacter() then highlight() end
        ```
]]
    function characterMeta:isMainCharacter()
        local client = self:getPlayer()
        if not IsValid(client) then return false end
        local mainCharID = client:getMainCharacter()
        return mainCharID == self:getID()
    end
end

lia.meta.character = characterMeta
