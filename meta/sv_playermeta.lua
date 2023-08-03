--------------------------------------------------------------------------------------------------------
local playerMeta = FindMetaTable("Player")
--------------------------------------------------------------------------------------------------------
function playerMeta:getPlayTime()
    local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))
    return diff + (RealTime() - (self.liaJoinTime or RealTime()))
end
--------------------------------------------------------------------------------------------------------
    function playerMeta:setRestricted(state, noMessage)
        if state then
            self:setNetVar("restricted", true)

            if noMessage then
                self:setLocalVar("restrictNoMsg", true)
            end

            self.liaRestrictWeps = self.liaRestrictWeps or {}

            for k, v in ipairs(self:GetWeapons()) do
                self.liaRestrictWeps[k] = v:GetClass()
            end

            timer.Simple(0, function()
                self:StripWeapons()
            end)

            hook.Run("OnPlayerRestricted", self)
        else
            self:setNetVar("restricted")

            if self:getLocalVar("restrictNoMsg") then
                self:setLocalVar("restrictNoMsg")
            end

            if self.liaRestrictWeps then
                for k, v in ipairs(self.liaRestrictWeps) do
                    self:Give(v)
                end

                self.liaRestrictWeps = nil
            end

            hook.Run("OnPlayerUnRestricted", self)
        end
    end
--------------------------------------------------------------------------------------------------------
function playerMeta:setAction(text, time, callback, startTime, finishTime)
    if time and time <= 0 then
        if callback then
            callback(self)
        end
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

    if callback then
        timer.Create("liaAct" .. self:UniqueID(), time, 1, function()
            if IsValid(self) then
                callback(self)
            end
        end)
    end
end
--------------------------------------------------------------------------------------------------------
function playerMeta:doStaredAction(entity, callback, time, onCancel, distance)
    local uniqueID = "liaStare" .. self:UniqueID()
    local data = {}
    data.filter = self

    timer.Create(uniqueID, 0.1, time / 0.1, function()
        if IsValid(self) and IsValid(entity) then
            data.start = self:GetShootPos()
            data.endpos = data.start + self:GetAimVector() * (distance or 96)
            local targetEntity = util.TraceLine(data).Entity

            if IsValid(targetEntity) and targetEntity:GetClass() == "prop_ragdoll" and IsValid(targetEntity:getNetVar("player")) then
                targetEntity = targetEntity:getNetVar("player")
            end

            if targetEntity ~= entity then
                timer.Remove(uniqueID)

                if onCancel then
                    onCancel()
                end
            elseif callback and timer.RepsLeft(uniqueID) == 0 then
                callback()
            end
        else
            timer.Remove(uniqueID)

            if onCancel then
                onCancel()
            end
        end
    end)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:notify(message)
    lia.util.notify(message, self)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:notifyLocalized(message, ...)
    lia.util.notifyLocalized(message, self, ...)
end
--------------------------------------------------------------------------------------------------------
function playerMeta:requestString(title, subTitle, callback, default)
    local d

    if type(callback) ~= "function" and default == nil then
        default = callback
        d = deferred.new()

        callback = function(value)
            d:resolve(value)
        end
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
--------------------------------------------------------------------------------------------------------
function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end
--------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------
function playerMeta:setRagdolled(state, time, getUpGrace)
    getUpGrace = getUpGrace or time or 5

    if state then
        if IsValid(self.liaRagdoll) then
            self.liaRagdoll:Remove()
        end

        local entity = self:createRagdoll()
        entity:setNetVar("player", self)

        entity:CallOnRemove("fixer", function()
            if IsValid(self) then
                self:setLocalVar("blur", nil)
                self:setLocalVar("ragdoll", nil)

                if not entity.liaNoReset then
                    self:SetPos(entity:GetPos())
                end

                self:SetNoDraw(false)
                self:SetNotSolid(false)
                self:Freeze(false)
                self:SetMoveType(MOVETYPE_WALK)
                self:SetLocalVelocity(IsValid(entity) and entity.liaLastVelocity or vector_origin)
            end

            if IsValid(self) and not entity.liaIgnoreDelete then
                if entity.liaWeapons then
                    for k, v in ipairs(entity.liaWeapons) do
                        self:Give(v)

                        if entity.liaAmmo then
                            for k2, v2 in ipairs(entity.liaAmmo) do
                                if v == v2[1] then
                                    self:SetAmmo(v2[2], tostring(k2))
                                end
                            end
                        end
                    end

                    for k, v in ipairs(self:GetWeapons()) do
                        v:SetClip1(0)
                    end
                end

                if self:isStuck() then
                    entity:DropToFloor()
                    self:SetPos(entity:GetPos() + Vector(0, 0, 16))

                    local positions = lia.util.findEmptySpace(self, {entity, self})

                    for k, v in ipairs(positions) do
                        self:SetPos(v)
                        if not self:isStuck() then return end
                    end
                end
            end
        end)

        self:setLocalVar("blur", 25)
        self.liaRagdoll = entity
        entity.liaWeapons = {}
        entity.liaAmmo = {}
        entity.liaPlayer = self

        if getUpGrace then
            entity.liaGrace = CurTime() + getUpGrace
        end

        if time and time > 0 then
            entity.liaStart = CurTime()
            entity.liaFinish = entity.liaStart + time
            self:setAction("@wakingUp", nil, nil, entity.liaStart, entity.liaFinish)
        end

        for k, v in ipairs(self:GetWeapons()) do
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
            local time2 = time
            local uniqueID = "liaUnRagdoll" .. self:SteamID()

            timer.Create(uniqueID, 0.33, 0, function()
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

                    if time <= 0 then
                        entity:Remove()
                    end
                else
                    timer.Remove(uniqueID)
                end
            end)
        end

        self:setLocalVar("ragdoll", entity:EntIndex())
        hook.Run("OnCharFallover", self, entity, true)
    elseif IsValid(self.liaRagdoll) then
        self.liaRagdoll:Remove()
        hook.Run("OnCharFallover", self, entity, false)
    end
end
--------------------------------------------------------------------------------------------------------