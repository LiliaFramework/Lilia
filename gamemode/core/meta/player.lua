--[[
    Player Meta

    Player management system for the Lilia framework.
]]
--[[
    Overview:
        The player meta table provides comprehensive functionality for managing player data, interactions, and operations in the Lilia framework. It handles player character access, notification systems, permission checking, data management, interaction systems, and player-specific operations. The meta table operates on both server and client sides, with the server managing player data and validation while the client provides player interaction and display. It includes integration with the character system for character access, notification system for player messages, permission system for access control, data system for player persistence, and interaction system for player actions. The meta table ensures proper player data synchronization, permission validation, notification delivery, and comprehensive player management from connection to disconnection.
]]
local playerMeta = FindMetaTable("Player")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    function playerMeta:getChar()
        return lia.char.getCharacter(self.getNetVar(self, "char"), self)
    end

    function playerMeta:tostring()
        local character = self:getChar()
        if character and character.getName then
            return character:getName()
        else
            return self:SteamName()
        end
    end

    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    netstream.Start(self:GetPos(), "liaSyncGesture", self, a, b, c)
end

function playerMeta:setAction(text, time, callback)
    if time and time <= 0 then
        if callback then callback(self) end
        return
    end

    time = time or 5
    if not text then
        if SERVER then
            timer.Remove("liaAct" .. self:SteamID64())
            net.Start("liaActBar")
            net.WriteBool(false)
            net.Send(self)
        else
            if IsValid(lia.gui.actionPanel) then
                lia.gui.actionPanel:Remove()
                lia.gui.actionPanel = nil
            end
        end
        return
    end

    if SERVER then
        net.Start("liaActBar")
        net.WriteBool(true)
        net.WriteString(text)
        net.WriteFloat(time)
        net.Send(self)
        if callback then timer.Create("liaAct" .. self:SteamID64(), time, 1, function() if IsValid(self) then callback(self) end end) end
    else
        lia.bar.drawAction(text, time)
        if callback then timer.Simple(time, function() if IsValid(self) then callback(self) end end) end
    end
end

function playerMeta:doStaredAction(entity, callback, time, onCancel, distance)
    local uniqueID = "liaStare" .. self:SteamID64()
    local data = {}
    data.filter = self
    timer.Create(uniqueID, 0.1, time / 0.1, function()
        if IsValid(self) and IsValid(entity) then
            data.start = self:GetShootPos()
            data.endpos = data.start + self:GetAimVector() * (distance or 96)
            local targetEntity = self:getTracedEntity()
            if IsValid(targetEntity) and targetEntity:GetClass() == "prop_ragdoll" then
                for _, ply in player.Iterator() do
                    if ply:GetRagdollEntity() == targetEntity then
                        targetEntity = ply
                        break
                    end
                end
            end

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

function playerMeta:stopAction()
    timer.Remove("liaAct" .. self:SteamID64())
    timer.Remove("liaStare" .. self:SteamID64())
    net.Start("liaActBar")
    net.Send(self)
end

function playerMeta:hasPrivilege(privilegeName)
    if not isstring(privilegeName) then
        lia.error(L("hasPrivilegeExpectedString", tostring(privilegeName)))
        return false
    end
    return lia.administrator.hasAccess(self, privilegeName)
end

function playerMeta:removeRagdoll()
    local ragdoll = self:GetRagdollEntity()
    if not IsValid(ragdoll) then return end
    ragdoll.liaIgnoreDelete = true
    SafeRemoveEntity(ragdoll)
end

function playerMeta:getItemWeapon()
    local character = self:getChar()
    local inv = character:getInv()
    local items = inv:getItems()
    local weapon = self:GetActiveWeapon()
    if not IsValid(weapon) then return nil end
    for _, v in pairs(items) do
        if v.class then
            if v.class == weapon:GetClass() and v:getData("equip", false) then
                return weapon, v
            else
                return nil
            end
        end
    end
end

function playerMeta:isFamilySharedAccount()
    return util.SteamIDFrom64(self:OwnerSteamID64()) ~= self:SteamID()
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

function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

function playerMeta:getTracedEntity(distance)
    if not distance then distance = 96 end
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * distance
    data.filter = self
    local targetEntity = util.TraceLine(data).Entity
    return targetEntity
end

function playerMeta:notify(message, notifType)
    if SERVER then
        lia.notices.notify(self, message, notifType or "default")
    else
        lia.notices.notify(nil, message, notifType or "default")
    end
end

function playerMeta:notifyLocalized(message, notifType, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, message, notifType or "default", ...)
    else
        lia.notices.notifyLocalized(nil, message, notifType or "default", ...)
    end
end

function playerMeta:notifyError(message)
    if SERVER then
        lia.notices.notify(self, message, "error")
    else
        lia.notices.notify(nil, message, "error")
    end
end

function playerMeta:notifyWarning(message)
    if SERVER then
        lia.notices.notify(self, message, "warning")
    else
        lia.notices.notify(nil, message, "warning")
    end
end

function playerMeta:notifyInfo(message)
    if SERVER then
        lia.notices.notify(self, message, "info")
    else
        lia.notices.notify(nil, message, "info")
    end
end

function playerMeta:notifySuccess(message)
    if SERVER then
        lia.notices.notify(self, message, "success")
    else
        lia.notices.notify(nil, message, "success")
    end
end

function playerMeta:notifyMoney(message)
    if SERVER then
        lia.notices.notify(self, message, "money")
    else
        lia.notices.notify(nil, message, "money")
    end
end

function playerMeta:notifyAdmin(message)
    if SERVER then
        lia.notices.notify(self, message, "admin")
    else
        lia.notices.notify(nil, message, "admin")
    end
end

function playerMeta:notifyErrorLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "error", ...)
    else
        lia.notices.notifyLocalized(nil, key, "error", ...)
    end
end

function playerMeta:notifyWarningLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "warning", ...)
    else
        lia.notices.notifyLocalized(nil, key, "warning", ...)
    end
end

function playerMeta:notifyInfoLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "info", ...)
    else
        lia.notices.notifyLocalized(nil, key, "info", ...)
    end
end

function playerMeta:notifySuccessLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "success", ...)
    else
        lia.notices.notifyLocalized(nil, key, "success", ...)
    end
end

function playerMeta:notifyMoneyLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "money", ...)
    else
        lia.notices.notifyLocalized(nil, key, "money", ...)
    end
end

function playerMeta:notifyAdminLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "admin", ...)
    else
        lia.notices.notifyLocalized(nil, key, "admin", ...)
    end
end

function playerMeta:canEditVendor(vendor)
    local hookResult = hook.Run("CanPerformVendorEdit", self, vendor)
    if hookResult ~= nil then return hookResult end
    return self:hasPrivilege("canEditVendors")
end

local function groupHasType(groupName, t)
    local groups = lia.administrator.groups or {}
    local visited = {}
    t = t:lower()
    while groupName and not visited[groupName] do
        visited[groupName] = true
        local data = groups[groupName]
        if not data then break end
        local info = data._info or {}
        for _, typ in ipairs(info.types or {}) do
            if tostring(typ):lower() == t then return true end
        end

        groupName = info.inheritance
    end
    return false
end

function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

function playerMeta:isVIP()
    local userGroup = self:GetUserGroup()
    if userGroup == "superadmin" or userGroup == "admin" then return true end
    local hasVIP = groupHasType(userGroup, "VIP")
    return hasVIP
end

function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

function playerMeta:hasWhitelist(faction)
    local data = lia.faction.indices[faction]
    if data then
        if data.isDefault then return true end
        if not data.uniqueID then return false end
        local liaData = self:getLiliaData("whitelists", {})
        return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] or false
    end
    return false
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

function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
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

function playerMeta:forceSequence(sequenceName, callback, time, noFreeze)
    hook.Run("OnPlayerEnterSequence", self, sequenceName, callback, time, noFreeze)
    if not sequenceName then
        net.Start("liaSeqSet")
        net.WriteEntity(self)
        net.WriteBool(false)
        net.Broadcast()
        return
    end

    local seqId = self:LookupSequence(sequenceName)
    if seqId and seqId > 0 then
        local dur = time or self:SequenceDuration(seqId)
        if isfunction(callback) then
            self.liaSeqCallback = callback
        else
            self.liaSeqCallback = nil
        end

        self.liaForceSeq = seqId
        if not noFreeze then self:SetMoveType(MOVETYPE_NONE) end
        if dur > 0 then timer.Create("liaSeq" .. self:EntIndex(), dur, 1, function() if IsValid(self) then self:leaveSequence() end end) end
        net.Start("liaSeqSet")
        net.WriteEntity(self)
        net.WriteBool(true)
        net.WriteInt(seqId, 16)
        net.Broadcast()
        return dur
    end
    return false
end

function playerMeta:leaveSequence()
    hook.Run("OnPlayerLeaveSequence", self)
    net.Start("liaSeqSet")
    net.WriteEntity(self)
    net.WriteBool(false)
    net.Broadcast()
    self:SetMoveType(MOVETYPE_WALK)
    self.liaForceSeq = nil
    if isfunction(self.liaSeqCallback) then self.liaSeqCallback() end
    self.liaSeqCallback = nil
end

function playerMeta:getFlags()
    local char = self:getChar()
    return char and char:getFlags() or ""
end

function playerMeta:giveFlags(flags)
    local char = self:getChar()
    if char then char:giveFlags(flags) end
end

function playerMeta:takeFlags(flags)
    local char = self:getChar()
    if char then char:takeFlags(flags) end
end

function playerMeta:networkAnimation(active, boneData)
    if SERVER then
        net.Start("liaAnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    else
        if not self.liaBoneCache then self.liaBoneCache = {} end
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then
                local targetAng = active and ang or angle_zero
                local cachedAng = self.liaBoneCache[i]
                local shouldUpdate = true
                if cachedAng then
                    local diff = math.abs(cachedAng.p - targetAng.p) + math.abs(cachedAng.y - targetAng.y) + math.abs(cachedAng.r - targetAng.r)
                    shouldUpdate = diff > 0.001
                end

                if shouldUpdate then
                    self:ManipulateBoneAngles(i, targetAng)
                    self.liaBoneCache[i] = targetAng
                end
            end
        end
    end
end

function playerMeta:getAllLiliaData()
    if SERVER then
        self.liaData = self.liaData or {}
        return self.liaData
    else
        lia.localData = lia.localData or {}
        return lia.localData
    end
end

function playerMeta:setWaypoint(name, vector, logo, onReach)
    if SERVER then
        net.Start("liaSetWaypoint")
        net.WriteString(name)
        net.WriteVector(vector)
        net.WriteString(logo or "")
        net.Send(self)
    else
        if not isstring(name) or not isvector(vector) then return end
        local logoMaterial
        if logo and isstring(logo) and logo ~= "" then
            logoMaterial = Material(logo, "smooth mips noclamp")
            if not logoMaterial or logoMaterial:IsError() then logoMaterial = nil end
        end

        if logo and not logoMaterial then return end
        local waypointID = "Waypoint_" .. tostring(self:SteamID64()) .. "_" .. tostring(math.random(100000, 999999))
        hook.Add("HUDPaint", waypointID, function()
            if not IsValid(self) then
                hook.Remove("HUDPaint", waypointID)
                return
            end

            local dist = self:GetPos():Distance(vector)
            local spos = vector:ToScreen()
            local howClose = math.Round(dist / 40)
            if spos.visible then
                if logoMaterial then
                    local logoSize = 24
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(logoMaterial)
                    surface.DrawTexturedRect(spos.x - logoSize / 2, spos.y - logoSize / 2 - 25, logoSize, logoSize)
                end

                surface.SetFont("LiliaFont.17")
                local nameText = name
                local metersText = L("meters", howClose)
                local nameTw, nameTh = surface.GetTextSize(nameText)
                local metersTw, metersTh = surface.GetTextSize(metersText)
                local containerTw = math.max(nameTw, metersTw)
                local containerTh = nameTh + metersTh + 6
                local bx, by = math.Round(spos.x - containerTw * 0.5 - 8), math.Round(spos.y - 8)
                local bw, bh = containerTw + 16, containerTh + 12
                local theme = lia.color.theme or {
                    background_panelpopup = Color(30, 30, 30, 180),
                    theme = Color(255, 255, 255),
                    text = Color(255, 255, 255)
                }

                local fadeAlpha = 1
                local headerColor = Color(theme.background_panelpopup.r, theme.background_panelpopup.g, theme.background_panelpopup.b, math.Clamp(theme.background_panelpopup.a * fadeAlpha, 0, 255))
                local accentColor = Color(theme.theme.r, theme.theme.g, theme.theme.b, math.Clamp(theme.theme.a * fadeAlpha, 0, 255))
                local textColor = Color(theme.text.r, theme.text.g, theme.text.b, math.Clamp(theme.text.a * fadeAlpha, 0, 255))
                lia.util.drawBlurAt(bx, by, bw, bh - 6, 6, 0.2, math.floor(fadeAlpha * 255))
                lia.derma.rect(bx, by, bw, bh - 6):Radii(16, 16, 0, 0):Color(headerColor):Shape(lia.derma.SHAPE_IOS):Draw()
                lia.derma.rect(bx, by + bh - 6, bw, 6):Radii(0, 0, 16, 16):Color(accentColor):Draw()
                draw.SimpleText(nameText, "LiliaFont.17", math.Round(spos.x), math.Round(spos.y - 1), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(metersText, "LiliaFont.17", math.Round(spos.x), math.Round(spos.y - 1 + nameTh + 3), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
            end

            if howClose <= 3 then RunConsoleCommand("waypoint_stop_" .. waypointID) end
        end)

        concommand.Add("waypoint_stop_" .. waypointID, function()
            hook.Remove("HUDPaint", waypointID)
            concommand.Remove("waypoint_stop_" .. waypointID)
            if onReach and isfunction(onReach) then onReach(self) end
            if SERVER then
                if self.waypointOnReach and isfunction(self.waypointOnReach) then
                    self.waypointOnReach(self)
                    self.waypointOnReach = nil
                end
            else
                net.Start("liaWaypointReached")
                net.SendToServer()
            end
        end)
    end
end

function playerMeta:getLiliaData(key, default)
    local data
    if SERVER then
        data = self.liaData and self.liaData[key]
    else
        data = lia.localData and lia.localData[key]
    end

    if data == nil then
        return default
    else
        return data
    end
end

function playerMeta:hasFlags(flags)
    for i = 1, #flags do
        local flag = flags:sub(i, i)
        if self:getFlags():find(flag, 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end

function playerMeta:requestOptions(title, subTitle, options, limit, callback)
    if SERVER then
        self.liaOptionsReqs = self.liaOptionsReqs or {}
        local id = table.insert(self.liaOptionsReqs, {
            callback = callback,
            allowed = options or {},
            limit = tonumber(limit) or 1
        })

        net.Start("liaOptionsRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options or {})
        net.WriteUInt(tonumber(limit) or 1, 32)
        net.Send(self)
    else
        lia.derma.requestOptions(title, subTitle, options, tonumber(limit) or 1, callback)
    end
end

function playerMeta:requestString(title, subTitle, callback, default)
    local d
    if not isfunction(callback) and default == nil then
        default = callback
        d = deferred.new()
        callback = function(value) d:resolve(value) end
    end

    if SERVER then
        self.liaStrReqs = self.liaStrReqs or {}
        local id = table.insert(self.liaStrReqs, callback)
        net.Start("liaStringRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteString(default or "")
        net.Send(self)
        return d
    else
        lia.derma.requestString(title, subTitle, callback, default or "")
        return d
    end
end

function playerMeta:requestArguments(title, argTypes, callback)
    local d
    if not isfunction(callback) then
        d = deferred.new()
        callback = function(value) d:resolve(value) end
    end

    if SERVER then
        self.liaArgReqs = self.liaArgReqs or {}
        local id = table.insert(self.liaArgReqs, {
            callback = callback,
            spec = argTypes or {}
        })

        net.Start("liaArgumentsRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title or "")
        net.WriteTable(argTypes or {})
        net.Send(self)
        return d
    else
        lia.derma.requestArguments(title, argTypes, callback)
        return d
    end
end

function playerMeta:requestBinaryQuestion(question, option1, option2, manualDismiss, callback)
    local title = ""
    if isstring(question) and isstring(option1) and isstring(option2) and (isbool(manualDismiss) or isfunction(manualDismiss)) then
        title = ""
    elseif isstring(question) and isstring(option1) and isstring(option2) and isstring(manualDismiss) and isfunction(callback) then
        title = question
        question = option1
        option1 = option2
        option2 = manualDismiss
        manualDismiss = false
    end

    if SERVER then
        self.liaBinaryReqs = self.liaBinaryReqs or {}
        local id = table.insert(self.liaBinaryReqs, callback)
        net.Start("liaBinaryQuestionRequest")
        net.WriteUInt(id, 32)
        net.WriteString(question)
        net.WriteString(option1)
        net.WriteString(option2)
        net.WriteBool(manualDismiss)
        net.Send(self)
    else
        lia.derma.requestBinaryQuestion(title, question, function(result) if callback then callback(result and 0 or 1) end end, option1, option2)
    end
end

function playerMeta:requestPopupQuestion(question, buttons)
    if SERVER then
        self.liaPopupReqs = self.liaPopupReqs or {}
        local callbacks = {}
        for i, buttonInfo in ipairs(buttons) do
            if istable(buttonInfo) then callbacks[i] = buttonInfo[2] end
        end

        local id = table.insert(self.liaPopupReqs, callbacks)
        net.Start("liaPopupQuestionRequest")
        net.WriteUInt(id, 32)
        net.WriteString(question)
        net.WriteUInt(#buttons, 8)
        for _, buttonInfo in ipairs(buttons) do
            local buttonText = istable(buttonInfo) and buttonInfo[1] or tostring(buttonInfo)
            net.WriteString(buttonText)
        end

        net.Send(self)
    else
        lia.derma.requestPopupQuestion(question, buttons)
    end
end

function playerMeta:requestButtons(title, buttons)
    if SERVER then
        self.buttonRequests = self.buttonRequests or {}
        local labels = {}
        local callbacks = {}
        for i, data in ipairs(buttons) do
            labels[i] = data.text or data[1] or ""
            callbacks[i] = data.callback or data[2]
        end

        local id = table.insert(self.buttonRequests, callbacks)
        net.Start("liaButtonRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title or "")
        net.WriteUInt(#labels, 8)
        for _, lbl in ipairs(labels) do
            net.WriteString(lbl)
        end

        net.Send(self)
    else
        lia.derma.requestButtons(title, buttons)
    end
end

function playerMeta:requestDropdown(title, subTitle, options, callback)
    if SERVER then
        self.liaDropdownReqs = self.liaDropdownReqs or {}
        local id = table.insert(self.liaDropdownReqs, {
            callback = callback,
            allowed = options or {}
        })

        net.Start("liaRequestDropdown")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options or {})
        net.Send(self)
    else
        lia.derma.requestDropdown(title, subTitle, options, callback)
    end
end

if SERVER then
    function playerMeta:restoreStamina(amount)
        local char = self:getChar()
        local maxStamina = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local current = self:getLocalVar("stamina", maxStamina)
        local value = math.Clamp(current + amount, 0, maxStamina)
        if current ~= value then self:setLocalVar("stamina", value) end
        if value >= maxStamina * 0.25 and self:getLocalVar("brth", false) then
            self:setLocalVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    function playerMeta:consumeStamina(amount)
        local char = self:getChar()
        local max = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local current = self:getLocalVar("stamina", max)
        local value = math.Clamp(current - amount, 0, max)
        if current ~= value then
            self:setLocalVar("stamina", value)
            if value == 0 and not self:getLocalVar("brth", false) then
                self:setLocalVar("brth", true)
                hook.Run("PlayerStaminaLost", self)
            end
        end
    end

    function playerMeta:addMoney(amount)
        local character = self:getChar()
        if not character then return false end
        local currentMoney = character:getMoney()
        local totalMoney = currentMoney + amount
        character:setMoney(totalMoney)
        lia.log.add(self, "money", amount)
        return true
    end

    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    function playerMeta:loadLiliaData(callback)
        local name = self:steamName()
        local steamID = self:SteamID()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.query("SELECT data, firstJoin, lastJoin, lastIP, lastOnline, totalOnlineTime FROM lia_players WHERE steamID = " .. lia.db.convertDataType(steamID), function(data)
            if IsValid(self) and data and data[1] and data[1].data then
                lia.db.updateTable({
                    lastJoin = timeStamp,
                }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID))

                self.firstJoin = data[1].firstJoin or timeStamp
                self.lastJoin = data[1].lastJoin or timeStamp
                self.liaData = util.JSONToTable(data[1].data)
                self.totalOnlineTime = tonumber(data[1].totalOnlineTime) or self:getLiliaData("totalOnlineTime", 0)
                local default = os.time(lia.time.toNumber(self.lastJoin))
                self.lastOnline = tonumber(data[1].lastOnline) or self:getLiliaData("lastOnline", default)
                self.lastIP = data[1].lastIP or self:getLiliaData("lastIP")
                if callback then callback(self.liaData) end
            else
                lia.db.insertTable({
                    steamID = steamID,
                    steamName = name,
                    firstJoin = timeStamp,
                    lastJoin = timeStamp,
                    userGroup = "user",
                    data = {},
                    lastIP = "",
                    lastOnline = os.time(lia.time.toNumber(timeStamp)),
                    totalOnlineTime = 0
                }, nil, "players")

                if callback then callback({}) end
            end
        end)
    end

    function playerMeta:saveLiliaData()
        if self:IsBot() then return end
        local name = self:steamName()
        local steamID = self:SteamID()
        local currentTime = os.time()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", currentTime)
        local stored = self:getLiliaData("totalOnlineTime", 0)
        local session = RealTime() - (self.liaJoinTime or RealTime())
        self:setLiliaData("totalOnlineTime", stored + session, true, true)
        self:setLiliaData("lastOnline", currentTime, true, true)
        lia.db.updateTable({
            steamName = name,
            lastJoin = timeStamp,
            data = self.liaData,
            lastIP = self:getLiliaData("lastIP", ""),
            lastOnline = currentTime,
            totalOnlineTime = stored + session
        }, nil, "players", "steamID = " .. lia.db.convertDataType(steamID))
    end

    function playerMeta:setLiliaData(key, value, noNetworking, noSave)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then
            net.Start("liaDataSync")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        if not noSave then self:saveLiliaData() end
    end

    function playerMeta:banPlayer(reason, duration, banner)
        local steamID = self:SteamID()
        lia.db.insertTable({
            player = self:Name(),
            playerSteamID = steamID,
            reason = reason or L("genericReason"),
            bannerName = IsValid(banner) and banner:Name() or "",
            bannerSteamID = IsValid(banner) and banner:SteamID() or "",
            timestamp = os.time(),
            evidence = ""
        }, nil, "bans")

        self:Kick(L("banMessage", duration or 0, reason or L("genericReason")))
    end

    function playerMeta:getPlayTime()
        local hookResult = hook.Run("GetPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(self.lastJoin)) - os.time(lia.time.toNumber(self.firstJoin))
        return diff + RealTime() - (self.liaJoinTime or RealTime())
    end

    local function isStuck(client)
        return util.TraceEntity({
            start = client:GetPos(),
            endpos = client:GetPos(),
            filter = client
        }, client).StartSolid
    end

    function playerMeta:setRagdolled(state, baseTime, getUpGrace, getUpMessage)
        getUpMessage = getUpMessage or L("wakingUp")
        local ragdoll = self:GetRagdollEntity()
        local time = hook.Run("GetRagdollTime", self, time) or baseTime or 10
        if state then
            local handsWeapon = self:GetActiveWeapon()
            if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
            if IsValid(ragdoll) then SafeRemoveEntity(ragdoll) end
            self:CreateRagdoll()
            local entity = self:GetRagdollEntity()
            entity.liaWeapons = {}
            entity.liaAmmo = {}
            entity.liaWeaponClips = {}
            local processedAmmoTypes = {}
            for _, w in ipairs(self:GetWeapons()) do
                local weaponClass = w:GetClass()
                entity.liaWeapons[#entity.liaWeapons + 1] = weaponClass
                local ammoType = w:GetPrimaryAmmoType()
                local clip = w:Clip1()
                entity.liaWeaponClips[weaponClass] = clip
                -- Save reserve ammo only once per ammo type (since it's shared)
                if ammoType and ammoType > 0 and not processedAmmoTypes[ammoType] then
                    local reserve = self:GetAmmoCount(ammoType)
                    entity.liaAmmo[ammoType] = reserve
                    processedAmmoTypes[ammoType] = true
                end
            end

            entity:CallOnRemove("fixer", function()
                if IsValid(self) then
                    if self.liaStoredHealth then self:SetHealth(math.max(self.liaStoredHealth, 1)) end
                    if not entity.liaNoReset then self:SetPos(entity:GetPos()) end
                    self:SetNoDraw(false)
                    self:SetNotSolid(false)
                    self:Freeze(false)
                    self:SetMoveType(MOVETYPE_WALK)
                    self:SetLocalVelocity(IsValid(entity) and entity.liaLastVelocity or vector_origin)
                    self.liaStoredHealth = nil
                    self.liaStoredMaxHealth = nil
                end

                if IsValid(self) and not entity.liaIgnoreDelete then
                    if entity.liaWeapons then
                        -- First, restore all weapons
                        for _, weaponClass in ipairs(entity.liaWeapons) do
                            self:Give(weaponClass, true)
                        end

                        -- Then restore clips for each weapon
                        if entity.liaWeaponClips then
                            for _, weapon in ipairs(self:GetWeapons()) do
                                local weaponClass = weapon:GetClass()
                                local clip = entity.liaWeaponClips[weaponClass]
                                if clip and clip > 0 then weapon:SetClip1(clip) end
                            end
                        end

                        -- Finally, restore reserve ammo for each ammo type
                        if entity.liaAmmo then
                            for ammoType, reserve in pairs(entity.liaAmmo) do
                                if reserve and reserve > 0 then self:SetAmmo(reserve, ammoType) end
                            end
                        end
                    end

                    if isStuck(self) then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for _, pos in ipairs(positions) do
                            self:SetPos(pos)
                            if not isStuck(self) then return end
                        end
                    end
                end
            end)

            if getUpGrace then entity.liaGrace = CurTime() + getUpGrace end
            if time and time > 0 then
                entity.liaStart = CurTime()
                entity.liaFinish = entity.liaStart + time
                self:setAction(getUpMessage, time)
            end

            self:GodEnable()
            self:StripWeapons()
            self:Freeze(true)
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetMoveType(MOVETYPE_NONE)
            if time then
                local uniqueID = "liaUnRagdoll" .. self:SteamID64()
                timer.Create(uniqueID, 1.0, 0, function()
                    if not IsValid(entity) or not IsValid(self) then
                        timer.Remove(uniqueID)
                        return
                    end

                    local velocity = entity:GetVelocity()
                    entity.liaLastVelocity = velocity
                    self:SetPos(entity:GetPos())
                    time = time - 1.0
                    if time <= 0 then
                        timer.Remove(uniqueID)
                        self:setRagdolled(false)
                    end
                end)
            end

            if IsValid(entity) then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
                entity:SetCustomCollisionCheck(false)
            end
        else
            ragdoll = self:GetRagdollEntity()
            if IsValid(ragdoll) then
                -- Restore weapons and ammo before removing ragdoll
                if ragdoll.liaWeapons then
                    -- First, restore all weapons
                    for _, weaponClass in ipairs(ragdoll.liaWeapons) do
                        self:Give(weaponClass, true)
                    end

                    -- Then restore clips for each weapon
                    if ragdoll.liaWeaponClips then
                        for _, weapon in ipairs(self:GetWeapons()) do
                            local weaponClass = weapon:GetClass()
                            local clip = ragdoll.liaWeaponClips[weaponClass]
                            if clip and clip > 0 then weapon:SetClip1(clip) end
                        end
                    end

                    -- Finally, restore reserve ammo for each ammo type
                    if ragdoll.liaAmmo then
                        for ammoType, reserve in pairs(ragdoll.liaAmmo) do
                            if reserve and reserve > 0 then self:SetAmmo(reserve, ammoType) end
                        end
                    end
                end

                self:removeRagdoll()
                self:GodDisable()
                self:Freeze(false)
                self:SetNoDraw(false)
                self:SetNotSolid(false)
                self:SetMoveType(MOVETYPE_WALK)
                hook.Run("OnCharFallover", self, nil, false)
            end
        end
    end

    function playerMeta:syncVars()
        for entity, data in pairs(lia.net) do
            if entity == "globals" then
                for k, v in pairs(data) do
                    net.Start("liaGlobalVar")
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            elseif IsValid(entity) then
                for k, v in pairs(data) do
                    net.Start("liaNetVar")
                    net.WriteUInt(entity:EntIndex(), 16)
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            end
        end

        if lia.net.locals[self] then
            for k, v in pairs(lia.net.locals[self]) do
                net.Start("liaNetLocal")
                net.WriteString(k)
                net.WriteType(v)
                net.Send(self)
            end
        end
    end

    function playerMeta:setNetVar(key, value)
        if lia.net.checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue == value then return end
        lia.net[self][key] = value
        net.Start("liaNetVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(value)
        net.Broadcast()
        if not self:IsBot() then
            net.Start("liaNetLocal")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    function playerMeta:setLocalVar(key, value)
        if not IsValid(self) then return end
        if lia.net.checkBadType(key, value) then return end
        lia.net.locals[self] = lia.net.locals[self] or {}
        local oldValue = lia.net.locals[self][key]
        if oldValue == value and not istable(value) then return end
        lia.net.locals[self][key] = value
        if not lia.shuttingDown then
            net.Start("liaNetLocal")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        if lia.net.locals[self] and lia.net.locals[self][key] ~= nil then return lia.net.locals[self][key] end
        return default
    end
else
    function playerMeta:getLocalVar(key, default)
        if not IsValid(self) then return default end
        local idx = self:EntIndex()
        if lia.net[idx] and lia.net[idx][key] ~= nil then return lia.net[idx][key] end
        return default
    end

    function playerMeta:getPlayTime()
        local hookResult = hook.Run("GetPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(lia.lastJoin)) - os.time(lia.time.toNumber(lia.firstJoin))
        return diff + RealTime() - (lia.joinTime or 0)
    end
end