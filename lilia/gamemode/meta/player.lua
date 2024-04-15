--[[--
Physical representation of connected player.

`Player`s are a type of `Entity`. They are a physical representation of a `Character` - and can possess at most one `Character`
object at a time that you can interface with.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Player) for all other methods that the `Player` class has.
]]
-- @classmod Player
local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
function playerMeta:isUser()
    return self:IsUserGroup("user")
end

function playerMeta:isStaff()
    return CAMI.PlayerHasAccess(self, "UserGroups - Staff Group", nil) or self:IsSuperAdmin()
end

function playerMeta:isVIP()
    return CAMI.PlayerHasAccess(self, "UserGroups - VIP Group", nil)
end

function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

function playerMeta:isObserving()
    if self:GetMoveType() == MOVETYPE_NOCLIP and not self:InVehicle() then
        return true
    else
        return false
    end
end

function playerMeta:isMoving()
    if not IsValid(self) or not self:Alive() then return false end
    local keydown = self:KeyDown(IN_FORWARD) or self:KeyDown(IN_BACK) or self:KeyDown(IN_MOVELEFT) or self:KeyDown(IN_MOVERIGHT)
    return keydown and self:OnGround()
end

function playerMeta:isOutside()
    local trace = util.TraceLine({
        start = self:GetPos(),
        endpos = self:GetPos() + self:GetUp() * 9999999999,
        filter = self
    })
    return trace.HitSky
end

function playerMeta:isNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP
end

function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

function playerMeta:squaredDistanceFromEnt(entity)
    return self:GetPos():DistToSqr(entity)
end

function playerMeta:distanceFromEnt(entity)
    return self:GetPos():Distance(entity)
end

function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

function playerMeta:entitiesNearPlayer(radius, playerOnly)
    local nearbyEntities = {}
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if playerOnly and not v:IsPlayer() then continue end
        table.insert(nearbyEntities, v)
    end
    return nearbyEntities
end

function playerMeta:getItemWeapon()
    local character = self:getChar()
    local inv = character:getInv()
    local items = inv:getItems()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return false end
    for _, v in pairs(items) do
        if v.class then
            if v.class == weapon:GetClass() and v:getData("equip", false) then
                return weapon, v
            else
                return false
            end
        end
    end
end

function playerMeta:addMoney(amount)
    local character = self:getChar()
    if not character then return end
    local currentMoney = character:getMoney()
    local maxMoneyLimit = lia.config.MoneyLimit or 0
    if hook.Run("WalletLimit", self) ~= nil then maxMoneyLimit = hook.Run("WalletLimit", self) end
    if maxMoneyLimit > 0 then
        local totalMoney = currentMoney + amount
        if totalMoney > maxMoneyLimit then
            local remainingMoney = totalMoney - maxMoneyLimit
            character:giveMoney(maxMoneyLimit)
            local money = lia.currency.spawn(self:getItemDropPos(), remainingMoney)
            money.client = self
            money.charID = character:getID()
        else
            character:giveMoney(amount)
        end
    else
        character:giveMoney(amount)
    end
end

function playerMeta:takeMoney(amt)
    local character = self:getChar()
    if character then character:giveMoney(-amt) end
end

function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > (self:GetWalkSpeed() + 10)
end

function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman") or lia.anim.getModelClass(model) == "citizen_female"
end

function playerMeta:getItemDropPos()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = self:GetShootPos() + self:GetAimVector() * 86
    data.filter = self
    local trace = util.TraceLine(data)
    data.start = trace.HitPos
    data.endpos = data.start + trace.HitNormal * 46
    data.filter = {}
    trace = util.TraceLine(data)
    return trace.HitPos
end

function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
    end
    return false
end

function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

function playerMeta:getTracedEntity()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 96
    data.filter = self
    local target = util.TraceLine(data).Entity
    return target
end

function playerMeta:getTrace()
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * 200
    data.filter = {self, self}
    data.mins = -Vector(4, 4, 4)
    data.maxs = Vector(4, 4, 4)
    local trace = util.TraceHull(data)
    return trace
end

function playerMeta:getClassData()
    local character = self:getChar()
    if character then
        local class = character:getClass()
        if class then
            local classData = lia.class.list[class]
            return classData
        end
    end
end

function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

function playerMeta:RequestString(title, subTitle, callback, default)
    local time = math.floor(os.time())
    self.StrReqs = self.StrReqs or {}
    self.StrReqs[time] = callback
    net.Start("StringRequest")
    net.WriteUInt(time, 32)
    net.WriteString(title)
    net.WriteString(subTitle)
    net.WriteString(default)
    net.Send(self)
end

if SERVER then
    function playerMeta:ipAddressNoPort()
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

    function playerMeta:getPermFlags()
        return self:getLiliaData("permflags", "")
    end

    function playerMeta:setPermFlags(val)
        self:setLiliaData("permflags", val or "")
        self:saveLiliaData()
    end

    function playerMeta:givePermFlags(flags)
        local curFlags = self:getPermFlags()
        for i = 1, #flags do
            local flag = flags[i]
            if not self:hasPermFlag(flag) and not self:hasFlagBlacklist(flag) then curFlags = curFlags .. flag end
        end

        self:setPermFlags(curFlags)
        if self.liaCharList then
            for _, v in pairs(self.liaCharList) do
                local char = lia.char.loaded[v]
                if char then char:giveFlags(flags) end
            end
        end
    end

    function playerMeta:takePermFlags(flags)
        local curFlags = self:getPermFlags()
        for i = 1, #flags do
            curFlags = curFlags:gsub(flags[i], "")
        end

        self:setPermFlags(curFlags)
        if self.liaCharList then
            for _, v in pairs(self.liaCharList) do
                local char = lia.char.loaded[v]
                if char then char:takeFlags(flags) end
            end
        end
    end

    function playerMeta:hasPermFlag(flag)
        if not flag or #flag ~= 1 then return end
        local curFlags = self:getPermFlags()
        for i = 1, #curFlags do
            if curFlags[i] == flag then return true end
        end
        return false
    end

    function playerMeta:getFlagBlacklist()
        return self:getLiliaData("flagblacklist", "")
    end

    function playerMeta:setFlagBlacklist(flags)
        self:setLiliaData("flagblacklist", flags)
        self:saveLiliaData()
    end

    function playerMeta:addFlagBlacklist(flags, blacklistInfo)
        local curBlack = self:getFlagBlacklist()
        for i = 1, #flags do
            local curFlag = flags[i]
            if not self:hasFlagBlacklist(curFlag) then curBlack = curBlack .. flags[i] end
        end

        self:setFlagBlacklist(curBlack)
        self:takePermFlags(flags)
        if blacklistInfo then
            local blacklistLog = self:getLiliaData("flagblacklistlog", {})
            blacklistInfo.starttime = os.time()
            blacklistInfo.time = blacklistInfo.time or 0
            blacklistInfo.endtime = blacklistInfo.time <= 0 and 0 or (os.time() + blacklistInfo.time)
            blacklistInfo.admin = blacklistInfo.admin or "N/A"
            blacklistInfo.adminsteam = blacklistInfo.adminsteam or "N/A"
            blacklistInfo.active = true
            blacklistInfo.flags = blacklistInfo.flags or ""
            blacklistInfo.reason = blacklistInfo.reason or "N/A"
            table.insert(blacklistLog, blacklistInfo)
            self:setLiliaData("flagblacklistlog", blacklistLog)
            self:saveLiliaData()
        end
    end

    function playerMeta:removeFlagBlacklist(flags)
        local curBlack = self:getFlagBlacklist()
        for i = 1, #flags do
            local curFlag = flags[i]
            curBlack = curBlack:gsub(curFlag, "")
        end

        self:setFlagBlacklist(curBlack)
    end

    function playerMeta:hasFlagBlacklist(flag)
        local flags = self:getFlagBlacklist()
        for i = 1, #flags do
            if flags[i] == flag then return true end
        end
        return false
    end

    function playerMeta:hasAnyFlagBlacklist(flags)
        for i = 1, #flags do
            if self:hasFlagBlacklist(flags[i]) then return true end
        end
        return false
    end

    function playerMeta:playSound(sound, pitch)
        net.Start("LiliaPlaySound")
        net.WriteString(tostring(sound))
        net.WriteUInt(tonumber(pitch) or 100, 7)
        net.Send(self)
    end

    function playerMeta:openUI(panel)
        net.Start("OpenVGUI")
        net.WriteString(panel)
        net.Send(self)
    end

    playerMeta.OpenUI = playerMeta.openUI
    function playerMeta:openPage(url)
        net.Start("OpenPage")
        net.WriteString(url)
        net.Send(self)
    end

    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(self.lastJoin)) - os.time(lia.util.dateToNumber(self.firstJoin))
        return diff + (RealTime() - (self.liaJoinTime or RealTime()))
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    function playerMeta:createServerRagdoll(DontSetPlayer)
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
        timer.Create(uniqueID, 0.1, time / 0.1, function()
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
        end)
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
            entity:CallOnRemove("fixer", function()
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
            end)

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
                        if time <= 0 then entity:Remove() end
                    else
                        timer.Remove(uniqueID)
                    end
                end)
            end

            self:setLocalVar("ragdoll", entity:EntIndex())
            hook.Run("OnCharFallover", self, entity, true)
        elseif IsValid(self.liaRagdoll) then
            self.liaRagdoll:Remove()
            hook.Run("OnCharFallover", self, nil, false)
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

    playerMeta.SetLocalVar = playerMeta.setLocalVar
    function playerMeta:notifyP(tx)
        self:notify(tx)
        self:ChatPrint(tx)
    end

    function playerMeta:sendMessage(...)
        net.Start("SendMessage")
        net.WriteTable({...} or {})
        net.Send(self)
    end

    function playerMeta:sendPrint(...)
        net.Start("SendPrint")
        net.WriteTable({...} or {})
        net.Send(self)
    end

    function playerMeta:sendPrintTable(...)
        net.Start("SendPrintTable")
        net.WriteTable({...} or {})
        net.Send(self)
    end
else
    function playerMeta:getPlayTime()
        local diff = os.time(lia.util.dateToNumber(lia.lastJoin)) - os.time(lia.util.dateToNumber(lia.firstJoin))
        return diff + (RealTime() - lia.joinTime or 0)
    end

    playerMeta.GetPlayTime = playerMeta.getPlayTime
    function playerMeta:openUI(panel)
        return vgui.Create(panel)
    end

    playerMeta.OpenUI = playerMeta.openUI
    function playerMeta:setWeighPoint(name, vector, OnReach)
        hook.Add("HUDPaint", "WeighPoint", function()
            local dist = self:GetPos():Distance(vector)
            local spos = vector:ToScreen()
            local howclose = math.Round(math.floor(dist) / 40)
            if not spos then return end
            render.SuppressEngineLighting(true)
            surface.SetFont("WB_Large")
            draw.DrawText(name .. "\n" .. howclose .. " Meters\n", "CenterPrintText", spos.x, spos.y, Color(123, 57, 209), TEXT_ALIGN_CENTER)
            render.SuppressEngineLighting(false)
            if howclose <= 3 then RunConsoleCommand("weighpoint_stop") end
        end)

        concommand.Add("weighpoint_stop", function()
            hook.Add("HUDPaint", "WeighPoint", function() end)
            if IsValid(OnReach) then OnReach() end
        end)
    end
end

playerMeta.IsUser = playerMeta.isUser
playerMeta.IsStaff = playerMeta.isStaff
playerMeta.IsVIP = playerMeta.isVIP
playerMeta.IsStaffOnDuty = playerMeta.isStaffOnDuty
playerMeta.IsObserving = playerMeta.isObserving
playerMeta.IsOutside = playerMeta.isOutside
playerMeta.IsNoClipping = playerMeta.isNoClipping
playerMeta.SquaredDistanceFromEnt = playerMeta.squaredDistanceFromEnt
playerMeta.DistanceFromEnt = playerMeta.distanceFromEnt
playerMeta.IsNearPlayer = playerMeta.isNearPlayer
playerMeta.EntitiesNearPlayer = playerMeta.entitiesNearPlayer
playerMeta.GetItemWeapon = playerMeta.getItemWeapon
playerMeta.AddMoney = playerMeta.addMoney
playerMeta.TakeMoney = playerMeta.takeMoney
playerMeta.GetMoney = playerMeta.getMoney
playerMeta.CanAfford = playerMeta.canAfford
playerMeta.IsRunning = playerMeta.isRunning
playerMeta.IsFemale = playerMeta.isFemale
playerMeta.GetItemDropPos = playerMeta.getItemDropPos
playerMeta.HasWhitelist = playerMeta.hasWhitelist
playerMeta.GetTracedEntity = playerMeta.getTracedEntity
playerMeta.GetTrace = playerMeta.getTrace
playerMeta.GetClassData = playerMeta.getClassData
playerMeta.HasSkillLevel = playerMeta.hasSkillLevel
playerMeta.MeetsRequiredSkills = playerMeta.meetsRequiredSkills
playerMeta.GetEyeEnt = playerMeta.getEyeEnt
playerMeta.IpAddressNoPort = playerMeta.ipAddressNoPort
playerMeta.SetAction = playerMeta.setAction
playerMeta.GetPermFlags = playerMeta.getPermFlags
playerMeta.SetPermFlags = playerMeta.setPermFlags
playerMeta.GivePermFlags = playerMeta.givePermFlags
playerMeta.TakePermFlags = playerMeta.takePermFlags
playerMeta.HasPermFlag = playerMeta.hasPermFlag
playerMeta.GetFlagBlacklist = playerMeta.getFlagBlacklist
playerMeta.SetFlagBlacklist = playerMeta.setFlagBlacklist
playerMeta.AddFlagBlacklist = playerMeta.addFlagBlacklist
playerMeta.RemoveFlagBlacklist = playerMeta.removeFlagBlacklist
playerMeta.HasFlagBlacklist = playerMeta.hasFlagBlacklist
playerMeta.HasAnyFlagBlacklist = playerMeta.hasAnyFlagBlacklist
playerMeta.PlaySound = playerMeta.playSound
playerMeta.OpenPage = playerMeta.openPage
playerMeta.CreateServerRagdoll = playerMeta.createServerRagdoll
playerMeta.DoStaredAction = playerMeta.doStaredAction
playerMeta.Notify = playerMeta.notify
playerMeta.NotifyLocalized = playerMeta.notifyLocalized
playerMeta.ChatNotify = playerMeta.chatNotify
playerMeta.ChatNotifyLocalized = playerMeta.chatNotifyLocalized
playerMeta.SetRagdolled = playerMeta.setRagdolled
playerMeta.SetWhitelisted = playerMeta.setWhitelisted
playerMeta.SyncVars = playerMeta.syncVars
playerMeta.NotifyP = playerMeta.notifyP
playerMeta.SendMessage = playerMeta.sendMessage
playerMeta.SendPrint = playerMeta.sendPrint
playerMeta.SendPrintTable = playerMeta.sendPrintTable
playerMeta.SetWeighPoint = playerMeta.setWeighPoint