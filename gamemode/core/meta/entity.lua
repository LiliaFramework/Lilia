--[[
    Folder: Meta
    File:  entity.md
]]
--[[
    Entity Meta

    Entity management system for the Lilia framework.
]]
--[[
    Overview:
        The entity meta table provides comprehensive functionality for extending Garry's Mod entities with Lilia-specific features and operations. It handles entity identification, sound management, door access control, vehicle ownership, network variable synchronization, and entity-specific operations. The meta table operates on both server and client sides, with the server managing entity data and validation while the client provides entity interaction and display. It includes integration with the door system for access control, vehicle system for ownership management, network system for data synchronization, and sound system for audio playback. The meta table ensures proper entity identification, access control validation, network data synchronization, and comprehensive entity interaction management for doors, vehicles, and other game objects.
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
        Detour of Entity:EmitSound that plays a sound from this entity, handling web sound URLs and fallbacks.
        This function overrides the base game's EmitSound method to add support for web-sourced audio streams.

    When Called:
        Use whenever an entity needs to emit a sound that may be streamed.

    Parameters:
        soundName (string)
            File path or URL to play.
        soundLevel (number)
            Sound level for attenuation.
        pitchPercent (number)
            Pitch modifier.
        volume (number)
            Volume from 0-100.
        channel (number)
            Optional sound channel.
        flags (number)
            Optional emit flags.
        dsp (number)
            Optional DSP effect index.

    Returns:
        boolean
            True when handled by websound logic; otherwise base emit result.

    Realm:
        Shared

    Example Usage:
        ```lua
            ent:EmitSound("lilia/websounds/example.mp3", 75)
        ```
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
        Indicates whether this entity is a physics prop.

    When Called:
        Use when filtering interactions to physical props only.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity class is prop_physics.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isProp() then handleProp(ent) end
        ```
]]
function entityMeta:isProp()
    if not IsValid(self) then return false end
    return self:GetClass() == "prop_physics"
end

--[[
    Purpose:
        Checks if the entity represents a Lilia item.

    When Called:
        Use when distinguishing item entities from other entities.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity class is lia_item.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isItem() then pickUpItem(ent) end
        ```
]]
function entityMeta:isItem()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_item"
end

--[[
    Purpose:
        Checks if the entity is a Lilia money pile.

    When Called:
        Use when processing currency pickups or interactions.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity class is lia_money.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isMoney() then ent:Remove() end
        ```
]]
function entityMeta:isMoney()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_money"
end

--[[
    Purpose:
        Determines whether the entity belongs to supported vehicle classes.

    When Called:
        Use when applying logic specific to Simfphys/LVS vehicles.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity is a recognized vehicle type.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isSimfphysCar() then configureVehicle(ent) end
        ```
]]
function entityMeta:isSimfphysCar()
    if not IsValid(self) then return false end
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

--[[
    Purpose:
        Verifies whether a client has a specific level of access to a door.

    When Called:
        Use when opening menus or performing actions gated by door access.

    Parameters:
        client (Player)
            Player requesting access.
        access (number)
            Required access level, defaults to DOOR_GUEST.

    Returns:
        boolean
            True if the client meets the access requirement.

    Realm:
        Shared

    Example Usage:
        ```lua
            if door:checkDoorAccess(ply, DOOR_OWNER) then openDoor() end
        ```
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
        Assigns vehicle ownership metadata to a player.

    When Called:
        Use when a player purchases or claims a vehicle entity.

    Parameters:
        client (Player)
            Player to set as owner.
    Realm:
        Shared

    Example Usage:
        ```lua
            vehicle:keysOwn(ply)
        ```
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
        Locks a vehicle entity via its Fire interface.

    When Called:
        Use when a player locks their owned vehicle.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            vehicle:keysLock()
        ```
]]
function entityMeta:keysLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("lock") end
end

--[[
    Purpose:
        Unlocks a vehicle entity via its Fire interface.

    When Called:
        Use when giving a player access back to their vehicle.

    Parameters:
        None.
    Realm:
        Shared

    Example Usage:
        ```lua
            vehicle:keysUnLock()
        ```
]]
function entityMeta:keysUnLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("unlock") end
end

--[[
    Purpose:
        Retrieves the owning player for a door or vehicle, if any.

    When Called:
        Use when displaying ownership information.

    Parameters:
        None.

    Returns:
        Player|nil
            Owner entity or nil if unknown.

    Realm:
        Shared

    Example Usage:
        ```lua
            local owner = door:getDoorOwner()
        ```
]]
function entityMeta:getDoorOwner()
    if not IsValid(self) then return nil end
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

--[[
    Purpose:
        Returns whether the entity is flagged as locked through net vars.

    When Called:
        Use when deciding if interactions should be blocked.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity's locked net var is set.

    Realm:
        Shared

    Example Usage:
        ```lua
            if door:isLocked() then denyUse() end
        ```
]]
function entityMeta:isLocked()
    if not IsValid(self) then return false end
    return self:getNetVar("locked", false)
end

--[[
    Purpose:
        Checks the underlying lock state of a door entity.

    When Called:
        Use when syncing lock visuals or handling use attempts.

    Parameters:
        None.

    Returns:
        boolean
            True if the door reports itself as locked.

    Realm:
        Shared

    Example Usage:
        ```lua
            local locked = door:isDoorLocked()
        ```
]]
function entityMeta:isDoorLocked()
    if not IsValid(self) then return false end
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

--[[
    Purpose:
        Infers whether the entity's model is tagged as female.

    When Called:
        Use for gender-specific animations or sounds.

    Parameters:
        None.

    Returns:
        boolean
            True if GetModelGender returns "female".

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isFemale() then setFemaleVoice(ent) end
        ```
]]
function entityMeta:isFemale()
    if not IsValid(self) then return false end
    return hook.Run("GetModelGender", self:GetModel()) == "female"
end

--[[
    Purpose:
        Finds the paired door entity associated with this door.

    When Called:
        Use when syncing double-door behavior or ownership.

    Parameters:
        None.

    Returns:
        Entity|nil
            Partner door entity when found.

    Realm:
        Shared

    Example Usage:
        ```lua
            local partner = door:getDoorPartner()
        ```
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
        Sends a networked variable for this entity to one or more clients.

    When Called:
        Use immediately after changing lia.net values to sync them.

    Parameters:
        key (string)
            Net variable name to send.
        receiver (Player|nil)
            Optional player to send to; broadcasts when nil.
    Realm:
        Server

    Example Usage:
        ```lua
            ent:sendNetVar("locked", ply)
        ```
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
        Clears all stored net vars for this entity and notifies clients.

    When Called:
        Use when an entity is being removed or reset.

    Parameters:
        receiver (Player|nil)
            Optional target to notify; broadcasts when nil.
    Realm:
        Server

    Example Usage:
        ```lua
            ent:clearNetVars()
        ```
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
        Resets stored door access data and closes any open menus.

    When Called:
        Use when clearing door permissions or transferring ownership.

    Parameters:
        None.
    Realm:
        Server

    Example Usage:
        ```lua
            door:removeDoorAccessData()
        ```
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
        Sets the locked net var state for this entity.

    When Called:
        Use when toggling lock status server-side.

    Parameters:
        state (boolean)
            Whether the entity should be considered locked.
    Realm:
        Server

    Example Usage:
        ```lua
            door:setLocked(true)
        ```
]]
    function entityMeta:setLocked(state)
        if not IsValid(self) then return end
        self:setNetVar("locked", state)
    end

    --[[
    Purpose:
        Marks an entity as non-ownable for keys/door systems.

    When Called:
        Use when preventing selling or owning of a door/vehicle.

    Parameters:
        state (boolean)
            True to make the entity non-ownable.
    Realm:
        Server

    Example Usage:
        ```lua
            door:setKeysNonOwnable(true)
        ```
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
        Stores a networked variable for this entity and notifies listeners.

    When Called:
        Use when updating shared entity state that clients need.

    Parameters:
        key (string)
            Net variable name.
        value (any)
            Value to store and broadcast.
        receiver (Player|nil)
            Optional player to send to; broadcasts when nil.
    Realm:
        Server

    Example Usage:
        ```lua
            ent:setNetVar("color", Color(255, 0, 0))
        ```
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
        Saves a local (server-only) variable on the entity.

    When Called:
        Use for transient server state that should not be networked.

    Parameters:
        key (string)
            Local variable name.
        value (any)
            Value to store.
    Realm:
        Server

    Example Usage:
        ```lua
            ent:setLocalVar("cooldown", CurTime())
        ```
]]
    function entityMeta:setLocalVar(key, value)
        if not IsValid(self) then return end
        lia.net.locals[self] = lia.net.locals[self] or {}
        lia.net.locals[self][key] = value
    end

    --[[
    Purpose:
        Reads a server-side local variable stored on the entity.

    When Called:
        Use when retrieving transient server-only state.

    Parameters:
        key (string)
            Local variable name.
        default (any)
            Value to return if unset.

    Returns:
        any
            Stored local value or default.

    Realm:
        Server

    Example Usage:
        ```lua
            local cooldown = ent:getLocalVar("cooldown", 0)
        ```
]]
    function entityMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        if lia.net.locals[self] and lia.net.locals[self][key] ~= nil then return lia.net.locals[self][key] end
        return default
    end
else
    --[[
    Purpose:
        Plays a web sound locally on the client, optionally following the entity.

    When Called:
        Use when the client must play a streamed sound attached to an entity.

    Parameters:
        soundPath (string)
            URL or path to the sound.
        volume (number)
            Volume from 0-1.
        shouldFollow (boolean)
            Whether the sound follows the entity.
        maxDistance (number)
            Maximum audible distance.
        startDelay (number)
            Delay before playback starts.
        minDistance (number)
            Minimum distance for attenuation.
        pitch (number)
            Playback rate multiplier.
        soundLevel (number)
            Optional sound level for attenuation.
        dsp (number)
            Optional DSP effect index.
    Realm:
        Client

    Example Usage:
        ```lua
            ent:playFollowingSound(url, 1, true, 1200)
        ```
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
        Determines whether this entity should be treated as a door.

    When Called:
        Use when applying door-specific logic on an entity.

    Parameters:
        None.

    Returns:
        boolean
            True if the entity class matches common door types.

    Realm:
        Shared

    Example Usage:
        ```lua
            if ent:isDoor() then handleDoor(ent) end
        ```
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
        Retrieves a networked variable stored on this entity.

    When Called:
        Use when reading shared entity state on either server or client.

    Parameters:
        key (string)
            Net variable name.
        default (any)
            Fallback value if none is set.

    Returns:
        any
            Stored net var or default.

    Realm:
        Shared

    Example Usage:
        ```lua
            local locked = ent:getNetVar("locked", false)
        ```
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
