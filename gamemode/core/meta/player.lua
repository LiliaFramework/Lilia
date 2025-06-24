local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --[[
        playerMeta:getChar()

        Description:
            Returns the currently loaded character object for this player.

        Realm:
            Shared

        Returns:
            Character|nil – The player's active character.
    ]]
    function playerMeta:getChar()
        return lia.char.loaded[self.getNetVar(self, "char")]
    end

    --[[
        playerMeta:Name()

        Description:
            Returns either the character's roleplay name or the player's Steam name.

        Realm:
            Shared

        Returns:
            string – Display name.
    ]]
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.GetCharacter = playerMeta.getChar
    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

--[[
    playerMeta:hasPrivilege(privilegeName)

    Description:
        Wrapper for CAMI privilege checks.

    Parameters:
        privilegeName (string) – Privilege identifier.

    Realm:
        Shared

    Returns:
        boolean – Result from CAMI.PlayerHasAccess.
]]
function playerMeta:hasPrivilege(privilegeName)
    return CAMI.PlayerHasAccess(self, privilegeName)
end

--[[
    playerMeta:getCurrentVehicle()

    Description:
        Safely returns the vehicle the player is currently using.

    Realm:
        Shared

    Returns:
        Entity|nil – Vehicle entity or nil.
]]
function playerMeta:getCurrentVehicle()
    local vehicle = self:GetVehicle()
    if vehicle and IsValid(vehicle) then return vehicle end
    return nil
end

--[[
    playerMeta:hasValidVehicle()

    Description:
        Determines if the player is currently inside a valid vehicle.

    Realm:
        Shared

    Returns:
        boolean – True if a vehicle entity is valid.
]]
function playerMeta:hasValidVehicle()
    return IsValid(self:getCurrentVehicle())
end

--[[
    playerMeta:isNoClipping()

    Description:
        Returns true if the player is in noclip mode and not inside a vehicle.

    Realm:
        Shared

    Returns:
        boolean – Whether the player is noclipping.
]]
function playerMeta:isNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP and not self:hasValidVehicle()
end

function playerMeta:hasRagdoll()
    return IsValid(self.liaRagdoll)
end

function playerMeta:removeRagdoll()
    if not self:hasRagdoll() then return end
    local ragdoll = self:getRagdoll()
    ragdoll.liaIgnoreDelete = true
    SafeRemoveEntity(ragdoll)
    self:setLocalVar("blur", nil)
end

function playerMeta:getRagdoll()
    if not self:hasRagdoll() then return end
    return self.liaRagdoll
end

function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
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

function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > self:GetWalkSpeed() + 10
end

function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman")
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

--[[
    playerMeta:getItems()

    Description:
        Returns the player's inventory item list if a character is loaded.

    Realm:
        Shared

    Returns:
        table|nil – Table of items or nil if absent.
]]
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--[[
    playerMeta:getTracedEntity(distance)

    Description:
        Performs a simple trace from the player's shoot position.

    Parameters:
        distance (number) – Trace length in units.

    Realm:
        Shared

    Returns:
        Entity|nil – The entity hit or nil.
]]
function playerMeta:getTracedEntity(distance)
    if not distance then distance = 96 end
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * distance
    data.filter = self
    local targetEntity = util.TraceLine(data).Entity
    return targetEntity
end

--[[
    playerMeta:getTrace(distance)

    Description:
        Returns a hull trace in front of the player.

    Parameters:
        distance (number) – Hull length in units.

    Realm:
        Shared

    Returns:
        table – Trace result.
]]
function playerMeta:getTrace(distance)
    if not distance then distance = 200 end
    local data = {}
    data.start = self:GetShootPos()
    data.endpos = data.start + self:GetAimVector() * distance
    data.filter = {self, self}
    data.mins = -Vector(4, 4, 4)
    data.maxs = Vector(4, 4, 4)
    local trace = util.TraceHull(data)
    return trace
end

--[[
    playerMeta:getEyeEnt(distance)

    Description:
        Returns the entity the player is looking at within a distance.

    Parameters:
        distance (number) – Maximum distance.

    Realm:
        Shared

    Returns:
        Entity|nil – The entity or nil if too far.
]]
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

--[[
    playerMeta:notify(message)

    Description:
        Sends a plain notification message to the player.

    Parameters:
        message (string) – Text to display.

    Realm:
        Server
]]
function playerMeta:notify(message)
    lia.notices.notify(message, self)
end

--[[
    playerMeta:notifyLocalized(message, ...)

    Description:
        Sends a localized notification to the player.

    Parameters:
        message (string) – Translation key.
        ... – Additional parameters for localization.

    Realm:
        Server
]]
function playerMeta:notifyLocalized(message, ...)
    lia.notices.notifyLocalized(message, self, ...)
end

--[[
    playerMeta:CanEditVendor(vendor)

    Description:
        Determines whether the player can edit the given vendor.

    Parameters:
        vendor (Entity) – Vendor entity to check.

    Realm:
        Server

    Returns:
        boolean – True if allowed to edit.
]]
function playerMeta:CanEditVendor(vendor)
    local hookResult = hook.Run("CanPerformVendorEdit", self, vendor)
    if hookResult ~= nil then return hookResult end
    return self:hasPrivilege("Staff Permissions - Can Edit Vendors")
end

--[[
    playerMeta:isUser()

    Description:
        Convenience wrapper to check if the player is in the "user" group.

    Realm:
        Shared

    Returns:
        boolean – Whether usergroup is "user".
]]
function playerMeta:isUser()
    return self:IsUserGroup("user")
end

--[[
    playerMeta:isStaff()

    Description:
        Returns true if the player belongs to a staff group.

    Realm:
        Shared

    Returns:
        boolean – Result from the privilege check.
]]
function playerMeta:isStaff()
    return self:hasPrivilege("UserGroups - Staff Group")
end

--[[
    playerMeta:isVIP()

    Description:
        Checks whether the player is in the VIP group.

    Realm:
        Shared

    Returns:
        boolean – Result from privilege check.
]]
function playerMeta:isVIP()
    return self:hasPrivilege("UserGroups - VIP Group")
end

--[[
    playerMeta:isStaffOnDuty()

    Description:
        Determines if the player is currently in the staff faction.

    Realm:
        Shared

    Returns:
        boolean – True if staff faction is active.
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    playerMeta:isFaction(faction)

    Description:
        Checks if the player's character belongs to the given faction.

    Parameters:
        faction (number) – Faction index to compare.

    Realm:
        Shared

    Returns:
        boolean – True if the factions match.
]]
function playerMeta:isFaction(faction)
    local character = self:getChar()
    if not character then return end
    local pFaction = character:getFaction()
    return pFaction and pFaction == faction
end

--[[
    playerMeta:isClass(class)

    Description:
        Returns true if the player's character is of the given class.

    Parameters:
        class (number) – Class index to compare.

    Realm:
        Shared

    Returns:
        boolean – Whether the character matches the class.
]]
function playerMeta:isClass(class)
    local character = self:getChar()
    if not character then return end
    local pClass = character:getClass()
    return pClass and pClass == class
end

--[[
    playerMeta:hasWhitelist(faction)

    Description:
        Determines if the player has whitelist access for a faction.

    Parameters:
        faction (number) – Faction index.

    Realm:
        Shared

    Returns:
        boolean – True if whitelisted.
]]
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

--[[
    playerMeta:getClass()

    Description:
        Retrieves the class index of the player's character.

    Realm:
        Shared

    Returns:
        number|nil – Class index or nil.
]]
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

--[[
    playerMeta:hasClassWhitelist(class)

    Description:
        Checks if the player's character is whitelisted for a class.

    Parameters:
        class (number) – Class index.

    Realm:
        Shared

    Returns:
        boolean – True if class whitelist exists.
]]
function playerMeta:hasClassWhitelist(class)
    local char = self:getChar()
    if not char then return false end
    local wl = char:getData("whitelist", {})
    return wl[class] ~= nil
end

--[[
    playerMeta:getClassData()

    Description:
        Returns the class table of the player's current class.

    Realm:
        Shared

    Returns:
        table|nil – Class definition table.
]]
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

--[[
    playerMeta:getDarkRPVar(var)

    Description:
        Compatibility helper for retrieving money with DarkRP-style calls.

    Parameters:
        var (string) – Currently only supports "money".

    Realm:
        Shared

    Returns:
        number|nil – Money amount or nil.
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    playerMeta:getMoney()

    Description:
        Convenience function to get the character's money amount.

    Realm:
        Shared

    Returns:
        number – Current funds or 0.
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    playerMeta:canAfford(amount)

    Description:
        Checks if the player has enough money for a purchase.

    Parameters:
        amount (number) – Cost to test.

    Realm:
        Shared

    Returns:
        boolean – True if funds are sufficient.
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    playerMeta:hasSkillLevel(skill, level)

    Description:
        Verifies the player's character meets an attribute level.

    Parameters:
        skill (string) – Attribute ID.
        level (number) – Required level.

    Realm:
        Shared

    Returns:
        boolean – Whether the character satisfies the requirement.
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    playerMeta:meetsRequiredSkills(requiredSkillLevels)

    Description:
        Checks a table of skill requirements against the player.

    Parameters:
        requiredSkillLevels (table) – Mapping of attribute IDs to levels.

    Realm:
        Shared

    Returns:
        boolean – True if all requirements are met.
]]
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--[[
    playerMeta:forceSequence(sequenceName, callback, time, noFreeze)

    Description:
        Plays an animation sequence and optionally freezes the player.

    Parameters:
        sequenceName (string) – Sequence to play.
        callback (function|nil) – Called when finished.
        time (number|nil) – Duration override.
        noFreeze (boolean) – Don't freeze movement when true.

    Realm:
        Shared

    Returns:
        number|boolean – Duration or false on failure.
]]
function playerMeta:forceSequence(sequenceName, callback, time, noFreeze)
    hook.Run("OnPlayerEnterSequence", self, sequenceName, callback, time, noFreeze)
    if not sequenceName then
        net.Start("seqSet")
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
        net.Start("seqSet")
        net.WriteEntity(self)
        net.WriteBool(true)
        net.WriteInt(seqId, 16)
        net.Broadcast()
        return dur
    end
    return false
end

--[[
    playerMeta:leaveSequence()

    Description:
        Stops any forced sequence and restores player movement.

    Realm:
        Shared
]]
function playerMeta:leaveSequence()
    hook.Run("OnPlayerLeaveSequence", self)
    net.Start("seqSet")
    net.WriteEntity(self)
    net.WriteBool(false)
    net.Broadcast()
    self:SetMoveType(MOVETYPE_WALK)
    self.liaForceSeq = nil
    if isfunction(self.liaSeqCallback) then self.liaSeqCallback() end
    self.liaSeqCallback = nil
end

if SERVER then
    --[[
        playerMeta:restoreStamina(amount)

        Description:
            Increases the player's stamina value.

        Parameters:
            amount (number) – Amount to restore.

        Realm:
            Server
    ]]
    function playerMeta:restoreStamina(amount)
        local current = self:getLocalVar("stamina", 0)
        local maxStamina = self:getChar():getMaxStamina()
        local value = math.Clamp(current + amount, 0, maxStamina)
        self:setLocalVar("stamina", value)
        if value >= maxStamina * 0.5 and self:getNetVar("brth", false) then
            self:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    --[[
        playerMeta:consumeStamina(amount)

        Description:
            Reduces the player's stamina value.

        Parameters:
            amount (number) – Amount to subtract.

        Realm:
            Server
    ]]
    function playerMeta:consumeStamina(amount)
        local current = self:getLocalVar("stamina", 0)
        local value = math.Clamp(current - amount, 0, self:getChar():getMaxStamina())
        self:setLocalVar("stamina", value)
        if value == 0 and not self:getNetVar("brth", false) then
            self:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", self)
        end
    end

    --[[
        playerMeta:addMoney(amount)

        Description:
            Adds funds to the player's character, clamping to limits.

        Parameters:
            amount (number) – Money to add.

        Realm:
            Server
    ]]
    function playerMeta:addMoney(amount)
        local character = self:getChar()
        if not character then return false end
        local currentMoney = character:getMoney()
        local maxMoneyLimit = lia.config.get("MoneyLimit") or 0
        local totalMoney = currentMoney + amount
        if maxMoneyLimit > 0 and isnumber(maxMoneyLimit) and totalMoney > maxMoneyLimit then
            local excessMoney = totalMoney - maxMoneyLimit
            character:setMoney(maxMoneyLimit)
            self:notifyLocalized("moneyLimit", lia.currency.get(maxMoneyLimit), lia.currency.plural, lia.currency.get(excessMoney), lia.currency.plural)
            local money = lia.currency.spawn(self:getItemDropPos(), excessMoney)
            if IsValid(money) then
                money.client = self
                money.charID = character:getID()
            end

            lia.log.add(self, "money", maxMoneyLimit - currentMoney)
        else
            character:setMoney(totalMoney)
            lia.log.add(self, "money", amount)
        end
        return true
    end

    --[[
        playerMeta:takeMoney(amount)

        Description:
            Removes money from the player's character.

        Parameters:
            amount (number) – Amount to subtract.

        Realm:
            Server
    ]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    function playerMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    function playerMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    function playerMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    function playerMeta:classWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = true
        self:getChar():setData("whitelist", wl)
    end

    function playerMeta:classUnWhitelist(class)
        local wl = self:getChar():getData("whitelist", {})
        wl[class] = false
        self:getChar():setData("whitelist", wl)
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

    function playerMeta:loadLiliaData(callback)
        local name = self:steamName()
        local steamID64 = self:SteamID64()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.query("SELECT _data, _firstJoin, _lastJoin FROM lia_players WHERE _steamID = " .. steamID64, function(data)
            if IsValid(self) and data and data[1] and data[1]._data then
                lia.db.updateTable({
                    _lastJoin = timeStamp,
                }, nil, "players", "_steamID = " .. steamID64)

                self.firstJoin = data[1]._firstJoin or timeStamp
                self.lastJoin = data[1]._lastJoin or timeStamp
                self.liaData = util.JSONToTable(data[1]._data)
                if callback then callback(self.liaData) end
            else
                lia.db.insertTable({
                    _steamID = steamID64,
                    _steamName = name,
                    _firstJoin = timeStamp,
                    _lastJoin = timeStamp,
                    _data = {}
                }, nil, "players")

                if callback then callback({}) end
            end
        end)
    end

    function playerMeta:saveLiliaData()
        if self:IsBot() then return end
        local name = self:steamName()
        local steamID64 = self:SteamID64()
        local timeStamp = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.db.updateTable({
            _steamName = name,
            _lastJoin = timeStamp,
            _data = self.liaData
        }, nil, "players", "_steamID = " .. steamID64)
    end

    function playerMeta:setLiliaData(key, value, noNetworking)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then netstream.Start(self, "liaData", key, value) end
    end

    function playerMeta:setWaypoint(name, vector)
        net.Start("setWaypoint")
        net.WriteString(name)
        net.WriteVector(vector)
        net.Send(self)
    end

    function playerMeta:setWeighPoint(name, vector)
        self:setWaypoint(name, vector)
    end

    function playerMeta:setWaypointWithLogo(name, vector, logo)
        net.Start("setWaypointWithLogo")
        net.WriteString(name)
        net.WriteVector(vector)
        net.WriteString(logo)
        net.Send(self)
    end

    function playerMeta:getLiliaData(key, default)
        local data = self.liaData and self.liaData[key]
        return data and default or data
    end

    playerMeta.getData = playerMeta.getLiliaData
    function playerMeta:getAllLiliaData()
        self.liaData = self.liaData or {}
        return self.liaData
    end

    function playerMeta:setRagdoll(entity)
        self.liaRagdoll = entity
    end

    function playerMeta:NetworkAnimation(active, boneData)
        net.Start("AnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    end

    function playerMeta:setAction(text, time, callback)
        if time and time <= 0 then
            if callback then callback(self) end
            return
        end

        time = time or 5
        if not text then
            timer.Remove("liaAct" .. self:SteamID64())
            net.Start("actBar")
            net.WriteBool(false)
            net.Send(self)
            return
        end

        net.Start("actBar")
        net.WriteBool(true)
        net.WriteString(text)
        net.WriteFloat(time)
        net.Send(self)
        if callback then timer.Create("liaAct" .. self:SteamID64(), time, 1, function() if IsValid(self) then callback(self) end end) end
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

    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        net.Start("actBar")
        net.Send(self)
    end

    function playerMeta:requestDropdown(title, subTitle, options, callback)
        net.Start("RequestDropdown")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.Send(self)
        self.dropdownCallback = callback
    end

    function playerMeta:requestOptions(title, subTitle, options, limit, callback)
        net.Start("OptionsRequest")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.WriteUInt(limit, 32)
        net.Send(self)
        self.optionsCallback = callback
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
        net.Start("StringRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteString(default or "")
        net.Send(self)
        return d
    end

    function playerMeta:binaryQuestion(question, option1, option2, manualDismiss, callback)
        net.Start("BinaryQuestionRequest")
        net.WriteString(question)
        net.WriteString(option1)
        net.WriteString(option2)
        net.WriteBool(manualDismiss)
        net.Send(self)
        self.binaryQuestionCallback = callback
    end

    function playerMeta:getPlayTime()
        local diff = os.time(lia.time.toNumber(self.lastJoin)) - os.time(lia.time.toNumber(self.firstJoin))
        return diff + RealTime() - (self.liaJoinTime or RealTime())
    end

    function playerMeta:createRagdoll(freeze, isDead)
        local entity = ents.Create("prop_ragdoll")
        entity:SetPos(self:GetPos())
        entity:SetAngles(self:EyeAngles())
        entity:SetModel(self:GetModel())
        entity:SetSkin(self:GetSkin())
        entity:Spawn()
        local numBodyGroups = entity:GetNumBodyGroups() or 0
        for i = 0, numBodyGroups - 1 do
            entity:SetBodygroup(i, self:GetBodygroup(i))
        end

        entity:SetCollisionGroup(COLLISION_GROUP_WEAPON)
        entity:Activate()
        if isDead then self.liaRagdoll = entity end
        hook.Run("OnCreatePlayerRagdoll", self, entity, isDead)
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

    function playerMeta:setRagdolled(state, time, getUpGrace, getUpMessage)
        getUpMessage = getUpMessage or L("wakingUp")
        local hasRagdoll = self:hasRagdoll()
        local ragdoll = self:getRagdoll()
        if state then
            if hasRagdoll then SafeRemoveEntity(ragdoll) end
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
                            self:Give(v, true)
                            if entity.liaAmmo then
                                for _, data in ipairs(entity.liaAmmo) do
                                    if v == data[1] then self:SetAmmo(data[2], tostring(data[1])) end
                                end
                            end
                        end
                    end

                    if self:isStuck() then
                        entity:DropToFloor()
                        self:SetPos(entity:GetPos() + Vector(0, 0, 16))
                        local positions = lia.util.findEmptySpace(self, {entity, self})
                        for _, pos in ipairs(positions) do
                            self:SetPos(pos)
                            if not self:isStuck() then return end
                        end
                    end
                end
            end)

            self:setLocalVar("blur", 25)
            self:setRagdoll(entity)
            entity.liaWeapons = {}
            entity.liaAmmo = {}
            entity.liaPlayer = self
            if getUpGrace then entity.liaGrace = CurTime() + getUpGrace end
            if time and time > 0 then
                entity.liaStart = CurTime()
                entity.liaFinish = entity.liaStart + time
                self:setAction(getUpMessage, time)
            end

            for _, w in ipairs(self:GetWeapons()) do
                entity.liaWeapons[#entity.liaWeapons + 1] = w:GetClass()
                local clip = w:Clip1()
                local reserve = self:GetAmmoCount(w:GetPrimaryAmmoType())
                local ammo = clip + reserve
                entity.liaAmmo[w:GetPrimaryAmmoType()] = {w:GetClass(), ammo}
            end

            self:GodDisable()
            self:StripWeapons()
            self:Freeze(true)
            self:SetNoDraw(true)
            self:SetNotSolid(true)
            self:SetMoveType(MOVETYPE_NONE)
            if time then
                local uniqueID = "liaUnRagdoll" .. self:SteamID64()
                timer.Create(uniqueID, 0.33, 0, function()
                    if not IsValid(entity) or not IsValid(self) then
                        timer.Remove(uniqueID)
                        return
                    end

                    local velocity = entity:GetVelocity()
                    entity.liaLastVelocity = velocity
                    self:SetPos(entity:GetPos())
                    time = time - 0.33
                    if time <= 0 then SafeRemoveEntity(entity) end
                end)
            end

            self:setLocalVar("ragdoll", entity:EntIndex())
            if IsValid(entity) then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
                entity:SetCustomCollisionCheck(false)
            end
        elseif hasRagdoll then
            SafeRemoveEntity(self.liaRagdoll)
            hook.Run("OnCharFallover", self, nil, false)
        end
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
else
    function playerMeta:getPlayTime()
        local diff = os.time(lia.time.toNumber(lia.lastJoin)) - os.time(lia.time.toNumber(lia.firstJoin))
        return diff + RealTime() - (lia.joinTime or 0)
    end

    function playerMeta:setWaypoint(name, vector, onReach)
        hook.Add("HUDPaint", "WeighPoint", function()
            if not IsValid(self) then
                hook.Remove("HUDPaint", "WeighPoint")
                return
            end

            local dist = self:GetPos():Distance(vector)
            local spos = vector:ToScreen()
            local howclose = math.Round(dist / 40)
            if spos.visible then
                render.SuppressEngineLighting(true)
                surface.SetFont("liaBigFont")
                draw.DrawText(name .. "\n" .. howclose .. " Meters\n", "liaBigFont", spos.x, spos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                render.SuppressEngineLighting(false)
            end

            if howclose <= 3 then RunConsoleCommand("weighpoint_stop") end
        end)

        concommand.Add("weighpoint_stop", function()
            hook.Remove("HUDPaint", "WeighPoint")
            if onReach and isfunction(onReach) then onReach() end
        end)
    end

    function playerMeta:setWeighPoint(name, vector, onReach)
        self:setWaypoint(name, vector, onReach)
    end

    function playerMeta:setWaypointWithLogo(name, vector, logo, onReach)
        if not isstring(name) or not isvector(vector) then return end
        local logoMaterial
        if logo and isstring(logo) then
            logoMaterial = Material(logo, "smooth mips noclamp")
            if not logoMaterial or logoMaterial:IsError() then logoMaterial = nil end
        end

        if not logoMaterial then return end
        local waypointID = "Waypoint_WithLogo_" .. tostring(self:SteamID64()) .. "_" .. tostring(math.random(100000, 999999))
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
                    local logoSize = 32
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(logoMaterial)
                    surface.DrawTexturedRect(spos.x - logoSize / 2, spos.y - logoSize / 2 - 40, logoSize, logoSize)
                end

                draw.DrawText(name .. "\n" .. howClose .. " Meters", "liaBigFont", spos.x, spos.y - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end

            if howClose <= 3 then RunConsoleCommand("waypoint_withlogo_stop_" .. waypointID) end
        end)

        concommand.Add("waypoint_withlogo_stop_" .. waypointID, function()
            hook.Remove("HUDPaint", waypointID)
            concommand.Remove("waypoint_withlogo_stop_" .. waypointID)
            if onReach and isfunction(onReach) then onReach(self) end
        end)
    end

    function playerMeta:getLiliaData(key, default)
        local data = lia.localData and lia.localData[key]
        if data == nil then
            return default
        else
            return data
        end
    end

    playerMeta.getData = playerMeta.getLiliaData
    function playerMeta:getAllLiliaData()
        lia.localData = lia.localData or {}
        return lia.localData
    end

    function playerMeta:NetworkAnimation(active, boneData)
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then self:ManipulateBoneAngles(i, active and ang or Angle(0, 0, 0)) end
        end
    end
end