local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local baseEmitSound = entityMeta.EmitSound
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

function entityMeta:EmitSound(soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
    if isstring(soundName) and (soundName:find("^https?://") or soundName:find("^lilia/websounds/") or soundName:find("^websounds/")) then
        if SERVER then
            net.Start("EmitURLSound")
            net.WriteEntity(self)
            net.WriteString(soundName)
            net.WriteFloat(volume or 100)
            net.WriteFloat(soundLevel or 100)
            net.WriteBool(false)
            net.Broadcast()
            return true
        else
            local maxDistance = soundLevel and soundLevel * 13.33 or 1000
            self:PlayFollowingSound(soundName, volume or 100, true, maxDistance)
            return true
        end
    end

    if CLIENT and isstring(soundName) and lia.websound.get(soundName) then
        local maxDistance = soundLevel and soundLevel * 13.33 or 1000
        self:PlayFollowingSound(soundName, volume or 100, true, maxDistance)
        return true
    end
    return baseEmitSound(self, soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
end

function entityMeta:isProp()
    if not IsValid(self) then return false end
    return self:GetClass() == "prop_physics"
end

function entityMeta:isItem()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_item"
end

function entityMeta:isMoney()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_money"
end

function entityMeta:isSimfphysCar()
    if not IsValid(self) then return false end
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

function entityMeta:isLiliaPersistent()
    if not IsValid(self) then return false end
    if self.GetPersistent and self:GetPersistent() then return true end
    return self.IsPersistent or self.IsPersistent
end

function entityMeta:checkDoorAccess(client, access)
    if not IsValid(self) then return false end
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

function entityMeta:keysOwn(client)
    if not IsValid(self) then return end
    if self:IsVehicle() then
        self:CPPISetOwner(client)
        self:setNetVar("owner", client:getChar():getID())
        self.ownerID = client:getChar():getID()
        self:setNetVar("ownerName", client:getChar():getName())
    end
end

function entityMeta:keysLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("lock") end
end

function entityMeta:keysUnLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("unlock") end
end

function entityMeta:getDoorOwner()
    if not IsValid(self) then return nil end
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

function entityMeta:isLocked()
    if not IsValid(self) then return false end
    return self:getNetVar("locked", false)
end

function entityMeta:isDoorLocked()
    if not IsValid(self) then return false end
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

function entityMeta:getEntItemDropPos(offset)
    if not IsValid(self) then return Vector(0, 0, 0), Angle(0, 0, 0) end
    if not offset then offset = 64 end
    local trResult = util.TraceLine({
        start = self:EyePos(),
        endpos = self:EyePos() + self:GetAimVector() * offset,
        mask = MASK_SHOT,
        filter = {self}
    })
    return trResult.HitPos + trResult.HitNormal * 5, trResult.HitNormal:Angle()
end

function entityMeta:isFemale()
    if not IsValid(self) then return false end
    return hook.Run("GetModelGender", self:GetModel()) == "female"
end

function entityMeta:isNearEntity(radius, otherEntity)
    if not IsValid(self) then return false end
    if otherEntity == self then return true end
    if not radius then radius = 96 end
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end
        if IsValid(otherEntity) and v == otherEntity or v:GetClass() == self:GetClass() then return true end
    end
    return false
end

function entityMeta:GetCreator()
    if not IsValid(self) then return nil end
    return self:getNetVar("creator", nil)
end

if SERVER then
    function entityMeta:SetCreator(client)
        if not IsValid(self) then return end
        self:setNetVar("creator", client)
    end

    function entityMeta:sendNetVar(key, receiver)
        if not IsValid(self) then return end
        net.Start("nVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(lia.net[self] and lia.net[self][key])
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    function entityMeta:clearNetVars(receiver)
        if not IsValid(self) then return end
        lia.net[self] = nil
        if lia.shuttingDown then return end
        timer.Simple(0, function()
            if not IsValid(self) then return end
            net.Start("nDel")
            net.WriteUInt(self:EntIndex(), 16)
            if receiver then
                net.Send(receiver)
            else
                net.Broadcast()
            end
        end)
    end

    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                net.Start("doorMenu")
                net.Send(k)
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    function entityMeta:setLocked(state)
        if not IsValid(self) then return end
        self:setNetVar("locked", state)
    end

    function entityMeta:setKeysNonOwnable(state)
        if not IsValid(self) then return end
        self:setNetVar("noSell", state)
    end

    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_"}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    function entityMeta:getDoorPartner()
        return self.liaPartner
    end

    function entityMeta:setNetVar(key, value, receiver)
        if not IsValid(self) then return end
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
else
    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        return self:GetClass():find("door")
    end

    function entityMeta:getDoorPartner()
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

    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    function entityMeta:PlayFollowingSound(soundPath, volume, shouldFollow, maxDistance, startDelay, minDistance, pitch, _, dsp)
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

        if soundPath:find("^lilia/websounds/") or soundPath:find("^websounds/") or soundPath:find("^data/lilia/websounds/") or soundPath:find("^data/websounds/") then
            playLocalFile(soundPath)
            return
        end

        if lia.websound.get(soundPath) then
            playLocalFile(soundPath)
            return
        end
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end
