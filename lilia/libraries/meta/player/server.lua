local playerMeta = FindMetaTable("Player")
function playerMeta:IPAddressNoPort()
    local ipAddr = self:IPAddress()
    local ipAddrExploded = string.Explode(":", ipAddr, false)
    if table.Count(ipAddrExploded) == 2 then
        return ipAddrExploded[1]
    else
        return ipAddr
    end
end

function playerMeta:setAction(text, time, callback, startTime, finishTime)
    if time and time <= 0 then
        if callback then callback(self) end
        return
    end

    time = time or 5
    startTime = startTime or CurTime()
    finishTime = finishTime or (startTime + time)
    if text == false then
        timer.Remove("liaAct" .. self:UniqueID())
        netstream.Start(self, "actBar")
        return
    end

    netstream.Start(self, "actBar", startTime, finishTime, text)
    if callback then timer.Create("liaAct" .. self:UniqueID(), time, 1, function() if IsValid(self) then callback(self) end end) end
end

function playerMeta:PlaySound(sound, pitch)
    net.Start("LiliaPlaySound")
    net.WriteString(tostring(sound))
    net.WriteUInt(tonumber(pitch) or 100, 7)
    net.Send(self)
end

function playerMeta:OpenUI(panel)
    net.Start("OpenVGUI")
    net.WriteString(panel)
    net.Send(self)
end

function playerMeta:getPlayTime()
    local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))
    return diff + (RealTime() - (self.liaJoinTime or RealTime()))
end

function playerMeta:CreateServerRagdoll(DontSetPlayer)
    local entity = ents.Create("prop_ragdoll")
    entity:SetPos(self:GetPos())
    entity:SetAngles(self:EyeAngles())
    entity:SetModel(self:GetModel())
    entity:SetSkin(self:GetSkin())
    for _, v in ipairs(self:GetBodyGroups()) do
        entity:SetBodygroup(v.id, self:GetBodygroup(v.id))
    end

    entity:Spawn()
    if not DontSetPlayer then entity:SetNetVar("player", self) end
    entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    entity:Activate()
    hook.Run("OnCreatePlayerServerRagdoll", self)
    local velocity = self:GetVelocity()
    for i = 0, entity:GetPhysicsObjectCount() - 1 do
        local physObj = entity:GetPhysicsObjectNum(i)
        if IsValid(physObj) then
            physObj:SetVelocity(velocity)
            local index = entity:TranslatePhysBoneToBone(i)
            if index then
                local position, angles = self:GetBonePosition(index)
                physObj:SetPos(position)
                physObj:SetAngles(angles)
            end
        end
    end
    return entity
end

function playerMeta:doStaredAction(entity, callback, time, onCancel, distance)
    local uniqueID = "liaStare" .. self:UniqueID()
    local data = {}
    data.filter = self
    timer.Create(
        uniqueID,
        0.1,
        time / 0.1,
        function()
            if IsValid(self) and IsValid(entity) then
                data.start = self:GetShootPos()
                data.endpos = data.start + self:GetAimVector() * (distance or 96)
                local targetEntity = util.TraceLine(data).Entity
                if IsValid(targetEntity) and targetEntity:GetClass() == "prop_ragdoll" and IsValid(targetEntity:getNetVar("player")) then targetEntity = targetEntity:getNetVar("player") end
                if targetEntity ~= entity then
                    timer.Remove(uniqueID)
                    if onCancel then onCancel() end
                elseif callback and timer.RepsLeft(uniqueID) == 0 then
                    callback()
                end
            else
                timer.Remove(uniqueID)
                if onCancel then onCancel() end
            end
        end
    )
end

function playerMeta:notify(message)
    lia.util.notify(message, self)
end

function playerMeta:notifyLocalized(message, ...)
    lia.util.notifyLocalized(message, self, ...)
end

function playerMeta:chatNotify(message)
    lia.chat.send(client, "flip", message)
end

function playerMeta:chatNotifyLocalized(message, ...)
    message = L(message, self, ...)
    lia.chat.send(client, "flip", message)
end

function playerMeta:requestString(title, subTitle, callback, default)
    local d
    if not isfunction(callback) and default == nil then
        default = callback
        d = deferred.new()
        callback = function(value) d:resolve(value) end
    end

    self.liaStrReqs = self.liaStrReqs or {}
    local id = table.insert(self.liaStrReqs, callback)
    net.Start("liaStringReq")
    net.WriteUInt(id, 32)
    net.WriteString(title)
    net.WriteString(subTitle)
    net.WriteString(default or "")
    net.Send(self)
    return d
end

function playerMeta:isStuck()
    return     util.TraceEntity(
        {
            start = self:GetPos(),
            endpos = self:GetPos(),
            filter = self
        },
        self
    ).StartSolid
end

function playerMeta:createRagdoll(freeze)
    local entity = ents.Create("prop_ragdoll")
    entity:SetPos(self:GetPos())
    entity:SetAngles(self:EyeAngles())
    entity:SetModel(self:GetModel())
    entity:SetSkin(self:GetSkin())
    entity:Spawn()
    entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    entity:Activate()
    local velocity = self:GetVelocity()
    for i = 0, entity:GetPhysicsObjectCount() - 1 do
        local physObj = entity:GetPhysicsObjectNum(i)
        if IsValid(physObj) then
            local index = entity:TranslatePhysBoneToBone(i)
            if index then
                local position, angles = self:GetBonePosition(index)
                physObj:SetPos(position)
                physObj:SetAngles(angles)
            end

            if freeze then
                physObj:EnableMotion(false)
            else
                physObj:SetVelocity(velocity)
            end
        end
    end
    return entity
end

function playerMeta:setRagdolled(state, time, getUpGrace)
    getUpGrace = getUpGrace or time or 5
    if state then
        if IsValid(self.liaRagdoll) then self.liaRagdoll:Remove() end
        local entity = self:createRagdoll()
        entity:setNetVar("player", self)
        entity:CallOnRemove(
            "fixer",
            function()
                if IsValid(self) then
                    self:setLocalVar("blur", nil)
                    self:setLocalVar("ragdoll", nil)
                    if not entity.liaNoReset then self:SetPos(entity:GetPos()) end
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self:Freeze(false)
                    self:SetMoveType(MOVETYPE_WALK)
                    self:SetLocalVelocity(IsValid(entity) and entity.liaLastVelocity or vector_origin)
                end

                if IsValid(self) and not entity.liaIgnoreDelete then
                    if entity.liaWeapons then
                        for _, v in ipairs(entity.liaWeapons) do
                            self:Give(v)
                            if entity.liaAmmo then
                                for k2, v2 in ipairs(entity.liaAmmo) do
                                    if v == v2[1] then self:SetAmmo(v2[2], tostring(k2)) end
                                end
                            end
                        end

                        for _, v in ipairs(self:GetWeapons()) do
                            v:SetClip1(0)
                        end
                    end

                    if self:isStuck() then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for _, v in ipairs(positions) do
                            self:SetPos(v)
                            if not self:isStuck() then return end
                        end
                    end
                end
            end
        )

        self:setLocalVar("blur", 25)
        self.liaRagdoll = entity
        entity.liaWeapons = {}
        entity.liaAmmo = {}
        entity.liaPlayer = self
        if getUpGrace then entity.liaGrace = CurTime() + getUpGrace end
        if time and time > 0 then
            entity.liaStart = CurTime()
            entity.liaFinish = entity.liaStart + time
            self:setAction("@wakingUp", nil, nil, entity.liaStart, entity.liaFinish)
        end

        for _, v in ipairs(self:GetWeapons()) do
            entity.liaWeapons[#entity.liaWeapons + 1] = v:GetClass()
            local clip = v:Clip1()
            local reserve = self:GetAmmoCount(v:GetPrimaryAmmoType())
            local ammo = clip + reserve
            entity.liaAmmo[v:GetPrimaryAmmoType()] = {v:GetClass(), ammo}
        end

        self:GodDisable()
        self:StripWeapons()
        self:Freeze(true)
        self:SetNoDraw(true)
        self:SetNotSolid(true)
        self:SetMoveType(MOVETYPE_NONE)
        if time then
            local uniqueID = "liaUnRagdoll" .. self:SteamID()
            timer.Create(
                uniqueID,
                0.33,
                0,
                function()
                    if IsValid(entity) and IsValid(self) then
                        local velocity = entity:GetVelocity()
                        entity.liaLastVelocity = velocity
                        self:SetPos(entity:GetPos())
                        if velocity:Length2D() >= 8 then
                            if not entity.liaPausing then
                                self:setAction()
                                entity.liaPausing = true
                            end
                            return
                        elseif entity.liaPausing then
                            self:setAction("@wakingUp", time)
                            entity.liaPausing = false
                        end

                        time = time - 0.33
                        if time <= 0 then entity:Remove() end
                    else
                        timer.Remove(uniqueID)
                    end
                end
            )
        end

        self:setLocalVar("ragdoll", entity:EntIndex())
        hook.Run("OnCharFallover", self, entity, true)
    elseif IsValid(self.liaRagdoll) then
        self.liaRagdoll:Remove()
        hook.Run("OnCharFallover", self, entity, false)
    end
end

function playerMeta:setWhitelisted(faction, whitelisted)
    if not whitelisted then whitelisted = nil end
    local data = lia.faction.indices[faction]
    if data then
        local whitelists = self:getLiliaData("whitelists", {})
        whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
        whitelists[SCHEMA.folder][data.uniqueID] = whitelisted and true or nil
        self:setLiliaData("whitelists", whitelists)
        self:saveLiliaData()
        return true
    end
    return false
end

function playerMeta:syncVars()
    for entity, data in pairs(lia.net) do
        if entity == "globals" then
            for k, v in pairs(data) do
                netstream.Start(self, "gVar", k, v)
            end
        elseif IsValid(entity) then
            for k, v in pairs(data) do
                netstream.Start(self, "nVar", entity:EntIndex(), k, v)
            end
        end
    end
end

function playerMeta:setLocalVar(key, value)
    if checkBadType(key, value) then return end
    lia.net[self] = lia.net[self] or {}
    lia.net[self][key] = value
    netstream.Start(self, "nLcl", key, value)
end

function playerMeta:SendMessage(...)
    net.Start("SendMessage")
    net.WriteTable({...} or {})
    net.Send(self)
end

function playerMeta:SendPrint(...)
    net.Start("SendPrint")
    net.WriteTable({...} or {})
    net.Send(self)
end

function playerMeta:SendPrintTable(...)
    net.Start("SendPrintTable")
    net.WriteTable({...} or {})
    net.Send(self)
end
