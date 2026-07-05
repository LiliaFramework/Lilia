--[[
    Folder: Developer - Meta Tables
    File: entity.md
]]
--[[
    Entity

    Entity metadata helpers for sound playback, ownership, locks, doors, vehicles, and networked variables.
]]
--[[
    Overview:
        The entity meta table extends Garry's Mod entities with helpers for custom sound emission, vehicle ownership, lock state checks, door behavior, and replicated per-entity variables used by the framework.
]]
local entityMeta = FindMetaTable("Entity")
local baseEmitSound = entityMeta.EmitSound
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

--[[
    Purpose:
        Extends `Entity:EmitSound` to support URL-based and cached web sounds.

    Parameters:
        soundName (string)
            The sound path, web URL, or registered websound identifier.
        soundLevel (number)
            The sound level used for distance calculations.
        pitchPercent (number)
            The playback pitch.
        volume (number)
            The playback volume.
        channel (number)
            The sound channel.
        flags (number)
            Additional sound flags.
        dsp (number)
            The DSP preset.

    Returns:
        boolean
            `true` when the sound is handled by the custom websound path.
        any
            Falls back to the base `EmitSound` return value otherwise.

    Example Usage:
        ```lua
        entity:EmitSound("https://example.com/radio.mp3", 75, 100, 1)
        ```

    Realm:
        Shared
]]
function entityMeta:EmitSound(soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
    if isstring(soundName) and (soundName:find("^https?://") or soundName:find("^lilia/websounds/") or soundName:find("^websounds/")) then
        if SERVER then
            net.Start("liaEmitUrlSound")
            net.WriteEntity(self)
            net.WriteString(soundName)
            net.WriteFloat(volume or 100)
            net.WriteFloat(soundLevel or 100)
            net.WriteBool(false)
            net.Broadcast()
            return true
        else
            local maxDistance = soundLevel and soundLevel * 13.33 or 1000
            self:playFollowingSound(soundName, volume or 100, true, maxDistance)
            return true
        end
    end

    if SERVER and isstring(soundName) then
        local name = soundName:gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", "")
        if string.StartWith(name, "sound/") then name = name:sub(7) end
        if lia.websound and lia.websound.stored and lia.websound.stored[name] then
            net.Start("liaEmitUrlSound")
            net.WriteEntity(self)
            net.WriteString("lilia/websounds/" .. name)
            net.WriteFloat(volume or 100)
            net.WriteFloat(soundLevel or 100)
            net.WriteBool(false)
            net.Broadcast()
            return true
        end
    end

    if CLIENT and isstring(soundName) and lia.websound.get(soundName) then
        local maxDistance = soundLevel and soundLevel * 13.33 or 1000
        self:playFollowingSound(soundName, volume or 100, true, maxDistance)
        return true
    end
    return baseEmitSound(self, soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
end

--[[
    Purpose:
        Checks whether the entity is a physics prop.

    Returns:
        boolean
            `true` if the entity class is `prop_physics`.

    Example Usage:
        ```lua
        if entity:isProp() then print("prop") end
        ```

    Realm:
        Shared
]]
function entityMeta:isProp()
    if not IsValid(self) then return false end
    return self:GetClass() == "prop_physics"
end

--[[
    Purpose:
        Checks whether the entity is a Lilia item entity.

    Returns:
        boolean
            `true` if the entity class is `lia_item`.

    Example Usage:
        ```lua
        if entity:isItem() then print("item") end
        ```

    Realm:
        Shared
]]
function entityMeta:isItem()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_item"
end

--[[
    Purpose:
        Checks whether the entity is a money entity.

    Returns:
        boolean
            `true` if the entity class is `lia_money`.

    Example Usage:
        ```lua
        if entity:isMoney() then print("money") end
        ```

    Realm:
        Shared
]]
function entityMeta:isMoney()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_money"
end

--[[
    Purpose:
        Determines whether the entity should be treated as a simfphys or LVS vehicle.

    Returns:
        boolean
            `true` if the entity matches a known supported vehicle class or flag.

    Example Usage:
        ```lua
        if entity:isSimfphysCar() then print("vehicle") end
        ```

    Realm:
        Shared
]]
function entityMeta:isSimfphysCar()
    if not IsValid(self) then return false end
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

--[[
    Purpose:
        Checks whether a player has the requested access level on a door.

    Parameters:
        client (Player)
            The player whose access is being checked.
        access (number)
            The minimum door access level to require. Defaults to `DOOR_GUEST`.

    Returns:
        boolean
            `true` if the player is allowed to access the door.

    Example Usage:
        ```lua
        if door:checkDoorAccess(client, DOOR_TENANT) then return end
        ```

    Realm:
        Shared
]]
--[[
    Hooks:
        CanPlayerAccessDoor(Player client, Entity door, number access)

    Purpose:
        Allows modules to explicitly grant door access before the normal Lilia door access table is checked.

    Category:
        Doors

    Parameters:
        client (Player)
            The player attempting to access the door.

        door (Entity)
            The door entity being checked.

        access (number)
            The required access level, such as `DOOR_GUEST` or `DOOR_TENANT`.

    Returns:
        boolean|nil
            Return true to grant access immediately. Returning nil allows the default door access checks to continue.

    Example Usage:
        ```lua
        hook.Add("CanPlayerAccessDoor", "liaExampleCanPlayerAccessDoor", function(client, door, access)
            if access == DOOR_TENANT and client:IsAdmin() then
                return true
            end
        end)
        ```

    Realm:
        Shared
]]
function entityMeta:checkDoorAccess(client, access)
    if not IsValid(self) then return false end
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

--[[
    Purpose:
        Assigns ownership metadata to a vehicle for the given player.

    Parameters:
        client (Player)
            The player who should own the vehicle.

    Returns:
        nil

    Example Usage:
        ```lua
        vehicle:keysOwn(client)
        ```

    Realm:
        Server
]]
function entityMeta:keysOwn(client)
    if not IsValid(self) then return end
    if self:IsVehicle() then
        self:CPPISetOwner(client)
        self:setNetVar("owner", client:getChar():getID())
        self.ownerID = client:getChar():getID()
        self:setNetVar("ownerName", client:getChar():getName())
    end
end

--[[
    Purpose:
        Locks a vehicle entity.

    Returns:
        nil

    Example Usage:
        ```lua
        vehicle:keysLock()
        ```

    Realm:
        Shared
]]
function entityMeta:keysLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("lock") end
end

--[[
    Purpose:
        Unlocks a vehicle entity.

    Returns:
        nil

    Example Usage:
        ```lua
        vehicle:keysUnLock()
        ```

    Realm:
        Shared
]]
function entityMeta:keysUnLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("unlock") end
end

--[[
    Purpose:
        Gets the CPPI owner of a vehicle entity.

    Returns:
        Player|nil
            The vehicle owner when available.

    Example Usage:
        ```lua
        local owner = vehicle:getDoorOwner()
        ```

    Realm:
        Shared
]]
function entityMeta:getDoorOwner()
    if not IsValid(self) then return nil end
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

--[[
    Purpose:
        Reads the locked state from the entity's internal variables.

    Returns:
        boolean|nil
            The current locked state, depending on entity type.

    Example Usage:
        ```lua
        if entity:isLocked() then return end
        ```

    Realm:
        Shared
]]
function entityMeta:isLocked()
    if self:IsVehicle() then return self:GetInternalVariable("VehicleLocked") end
    return self:GetInternalVariable("m_bLocked")
end

--[[
    Purpose:
        Checks whether a door is currently locked.

    Returns:
        boolean
            `true` if the door reports a locked state.

    Example Usage:
        ```lua
        if door:isDoorLocked() then return end
        ```

    Realm:
        Shared
]]
function entityMeta:isDoorLocked()
    if not IsValid(self) then return false end
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

--[[
    Purpose:
        Determines whether the entity model is considered female.

    Returns:
        boolean
            `true` if the model gender hook resolves to `female`.

    Example Usage:
        ```lua
        if entity:isFemale() then print("female model") end
        ```

    Realm:
        Shared
]]
function entityMeta:isFemale()
    if not IsValid(self) then return false end
    return hook.Run("GetModelGender", self:GetModel()) == "female"
end

--[[
    Purpose:
        Finds the paired door entity for a door or door-owned prop.

    Returns:
        Entity|nil
            The partner door entity when one can be found.

    Example Usage:
        ```lua
        local partner = door:getDoorPartner()
        ```

    Realm:
        Shared
]]
function entityMeta:getDoorPartner()
    if SERVER then
        return self.liaPartner
    else
        if not IsValid(self) then return nil end
        local owner = self:GetOwner() or self.liaDoorOwner
        if IsValid(owner) and owner:isDoor() then return owner end
        for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
            if v:GetOwner() == self then
                self.liaDoorOwner = v
                return v
            end
        end
    end
end

if SERVER then
    --[[
    Purpose:
        Sends one networked entity variable to one client or everyone.

    Parameters:
        key (string)
            The netvar key to send.
        receiver (Player)
            Optional client to receive the update.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:sendNetVar("locked", client)
        ```

    Realm:
        Server
]]
    function entityMeta:sendNetVar(key, receiver)
        if not IsValid(self) then return end
        net.Start("liaNetVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(lia.net[self] and lia.net[self][key])
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
    Purpose:
        Clears stored networked variables for the entity and notifies clients.

    Parameters:
        receiver (Player)
            Optional client to receive the clear message.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:clearNetVars()
        ```

    Realm:
        Server
]]
    function entityMeta:clearNetVars(receiver)
        if not IsValid(self) then return end
        lia.net[self] = nil
        if lia.net.locals[self] then lia.net.locals[self] = nil end
        if lia.shuttingDown then return end
        net.Start("liaNetDel")
        net.WriteUInt(self:EntIndex(), 16)
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
    Purpose:
        Removes stored door access data and refreshes affected clients.

    Returns:
        nil

    Example Usage:
        ```lua
        door:removeDoorAccessData()
        ```

    Realm:
        Server
]]
    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                net.Start("liaDoorMenu")
                net.Send(k)
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    --[[
    Purpose:
        Stores a replicated locked flag on the entity.

    Parameters:
        state (boolean)
            The locked state to replicate.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:setLocked(true)
        ```

    Realm:
        Server
]]
    function entityMeta:setLocked(state)
        if not IsValid(self) then return end
        self:setNetVar("locked", state)
    end

    --[[
    Purpose:
        Marks a door or entity as not being sellable/ownable through the keys system.

    Parameters:
        state (boolean)
            Whether the entity should be non-ownable.

    Returns:
        nil

    Example Usage:
        ```lua
        door:setKeysNonOwnable(true)
        ```

    Realm:
        Server
]]
    function entityMeta:setKeysNonOwnable(state)
        if not IsValid(self) then return end
        if self:isDoor() then
            lia.doors.setData(self, {
                noSell = state
            })
        else
            self:setNetVar("noSell", state)
        end
    end

    --[[
    Purpose:
        Stores a networked variable for the entity and dispatches the update.

    Parameters:
        key (string)
            The netvar key.
        value (any)
            The value to store.
        receiver (Player)
            Optional client to receive the update.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:setNetVar("ownerName", client:Name())
        ```

    Realm:
        Server
]]
    function entityMeta:setNetVar(key, value, receiver)
        if not IsValid(self) then return end
        if lia.net.checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    --[[
    Purpose:
        Stores a server-only local variable for the entity.

    Parameters:
        key (string)
            The local variable key.
        value (any)
            The value to store.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:setLocalVar("cachedDoorName", "Lobby")
        ```

    Realm:
        Server
]]
    function entityMeta:setLocalVar(key, value)
        if not IsValid(self) then return end
        lia.net.locals[self] = lia.net.locals[self] or {}
        lia.net.locals[self][key] = value
    end

    --[[
    Purpose:
        Retrieves a server-only local variable from the entity.

    Parameters:
        key (string)
            The local variable key.
        default (any)
            The fallback value when the key is missing.

    Returns:
        any
            The stored value or the provided default.

    Example Usage:
        ```lua
        local name = entity:getLocalVar("cachedDoorName", "Unknown")
        ```

    Realm:
        Server
]]
    function entityMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        if lia.net.locals[self] and lia.net.locals[self][key] ~= nil then return lia.net.locals[self][key] end
        return default
    end
else
    --[[
    Purpose:
        Plays a local or remote sound and keeps it positioned on the entity.

    Parameters:
        soundPath (string)
            The file path or URL to play.
        volume (number)
            Playback volume from `0` to `1`.
        shouldFollow (boolean)
            Whether the sound should continue following the entity.
        maxDistance (number)
            Maximum audible distance.
        startDelay (number)
            Optional delay before playback starts.
        minDistance (number)
            Minimum fade distance.
        pitch (number)
            Optional playback rate multiplier.
        soundLevel (number)
            Reserved for compatibility with callers.
        dsp (number)
            Optional DSP preset.

    Returns:
        nil

    Example Usage:
        ```lua
        entity:playFollowingSound("https://example.com/ambience.mp3", 0.8, true, 1200)
        ```

    Realm:
        Client
]]
    function entityMeta:playFollowingSound(soundPath, volume, shouldFollow, maxDistance, startDelay, minDistance, pitch, soundLevel, dsp)
        local v = math.Clamp(tonumber(volume) or 1, 0, 1)
        local follow = shouldFollow ~= false
        local fmin, fmax = tonumber(minDistance) or 0, tonumber(maxDistance) or 1200
        local function getAnchor()
            if IsValid(self) and self:IsVehicle() and IsValid(self:GetParent()) then return self:GetParent() end
            return self
        end

        if not isstring(soundPath) then return end
        local function currentDistance()
            local anchor = getAnchor()
            local pos = anchor.WorldSpaceCenter and anchor:WorldSpaceCenter() or anchor:GetPos()
            local lp = LocalPlayer and LocalPlayer() or nil
            if not IsValid(lp) then return 0 end
            return lp:GetPos():Distance(pos)
        end

        local function computeFadeFactor(dist)
            if fmax <= 0 then return 1 end
            if dist >= fmax then return 0 end
            if fmax > fmin then
                local fadeStart = fmax * 0.8
                if dist >= fadeStart then
                    local t = math.Clamp((dist - fadeStart) / (fmax - fadeStart), 0, 1)
                    return 1 - t * t
                end
            end
            return 1
        end

        local function attachAndPlay(ch, manualAttenuation)
            if not IsValid(ch) then return end
            played = true
            local anchor = getAnchor()
            if manualAttenuation then
                ch:Set3DEnabled(false)
            else
                ch:Set3DEnabled(true)
                ch:Set3DFadeDistance(fmin, fmax)
            end

            ch:SetPos(anchor.WorldSpaceCenter and anchor:WorldSpaceCenter() or anchor:GetPos())
            local initDist = currentDistance()
            local fade = computeFadeFactor(initDist)
            if manualAttenuation or fade < 1 then
                ch:SetVolume(v * math.Clamp(fade, 0, 1))
            else
                ch:SetVolume(v)
            end

            if pitch and pitch ~= 1 then ch:SetPlaybackRate(pitch) end
            if dsp and dsp > 0 then ch:SetDSP(dsp) end
            if startDelay and startDelay > 0 then
                timer.Simple(startDelay, function() if IsValid(ch) then ch:Play() end end)
            else
                ch:Play()
            end

            if follow then
                local id = "lia_ws_follow_" .. self:EntIndex() .. "_" .. tostring(ch)
                hook.Add("Think", id, function()
                    if not IsValid(ch) or not IsValid(self) then
                        if IsValid(ch) then ch:Stop() end
                        hook.Remove("Think", id)
                        return
                    end

                    local anchor2 = getAnchor()
                    if IsValid(ch) then ch:SetPos(anchor2.WorldSpaceCenter and anchor2:WorldSpaceCenter() or anchor2:GetPos()) end
                    local lp = LocalPlayer and LocalPlayer() or nil
                    if not IsValid(lp) then return end
                    local pos = anchor2.WorldSpaceCenter and anchor2:WorldSpaceCenter() or anchor2:GetPos()
                    local dist = lp:GetPos():Distance(pos)
                    local fadeFactor = computeFadeFactor(dist)
                    if IsValid(ch) then
                        if manualAttenuation or fadeFactor < 1 then
                            ch:SetVolume(v * math.Clamp(fadeFactor, 0, 1))
                        else
                            ch:SetVolume(v)
                        end
                    end
                end)
            end
        end

        local function playLocalFile(path)
            sound.PlayFile(path, "mono 3d", function(ch)
                if IsValid(ch) then
                    attachAndPlay(ch, false)
                    return
                end

                local isWav = string.EndsWith(string.lower(path), ".wav")
                if isWav then
                    sound.PlayFile(path, "", function(ch3) if IsValid(ch3) then attachAndPlay(ch3, true) end end)
                    return
                end

                sound.PlayFile(path, "3d", function(ch2)
                    if IsValid(ch2) then
                        attachAndPlay(ch2, false)
                        return
                    end

                    sound.PlayFile(path, "", function(ch3) if IsValid(ch3) then attachAndPlay(ch3, true) end end)
                end)
            end)
        end

        if soundPath:find("^https?://") then
            sound.PlayURL(soundPath, "mono 3d", function(ch)
                if IsValid(ch) then
                    attachAndPlay(ch)
                    return
                end

                sound.PlayURL(soundPath, "3d", function(ch2)
                    if IsValid(ch2) then
                        attachAndPlay(ch2)
                        return
                    end
                end)
            end)
            return
        end

        if soundPath:find("^lilia/websounds/") or soundPath:find("^websounds/") or soundPath:find("^lilia/websounds/") or soundPath:find("^data/websounds/") then
            playLocalFile(soundPath)
            return
        end

        if lia.websound.get(soundPath) then
            playLocalFile(soundPath)
            return
        end
    end
end

--[[
    Purpose:
        Determines whether the entity should be treated as a door.

    Returns:
        boolean
            `true` if the entity class matches the expected door patterns.

    Example Usage:
        ```lua
        if entity:isDoor() then print("door") end
        ```

    Realm:
        Shared
]]
function entityMeta:isDoor()
    if not IsValid(self) then return false end
    if SERVER then
        if not IsValid(self) then return false end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_"}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    else
        return self:GetClass():find("door")
    end
end

--[[
    Purpose:
        Gets a networked variable stored on the entity.

    Parameters:
        key (string)
            The netvar key.
        default (any)
            The fallback value when the key is missing.

    Returns:
        any
            The stored value or the provided default.

    Example Usage:
        ```lua
        local ownerName = entity:getNetVar("ownerName", "Unowned")
        ```

    Realm:
        Shared
]]
function entityMeta:getNetVar(key, default)
    if not IsValid(self) then return default end
    if SERVER then
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    else
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end
end
