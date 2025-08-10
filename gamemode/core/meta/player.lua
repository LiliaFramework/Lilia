local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    function playerMeta:getChar()
        return lia.char.getCharacter(self.getNetVar(self, "char"), self)
    end

    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.GetCharacter = playerMeta.getChar
    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

function playerMeta:hasPrivilege(privilegeName)
    local override = hook.Run("PlayerHasPrivilege", self, privilegeName)
    if override ~= nil then return override end
    return lia.administrator.hasAccess(self, privilegeName)
end

function playerMeta:getCurrentVehicle()
    local vehicle = self:GetVehicle()
    if vehicle and IsValid(vehicle) then return vehicle end
    return nil
end

function playerMeta:hasValidVehicle()
    return IsValid(self:getCurrentVehicle())
end

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

--[[
    isStuck

    Purpose:
        Checks if the player is stuck in geometry.

    Returns:
        boolean - True if the player is stuck, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isStuck() then
            print("Player is stuck in geometry")
        end
]]
function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

--[[
    isNearPlayer

    Purpose:
        Checks if the player is near another entity within the specified radius.

    Parameters:
        radius (number) - The radius to check within.
        entity (Entity) - The entity to check distance to.

    Returns:
        boolean - True if the player is within the radius, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isNearPlayer(100, otherPlayer) then
            print("Player is nearby")
        end
]]
function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

--[[
    entitiesNearPlayer

    Purpose:
        Returns all entities near the player within the specified radius.

    Parameters:
        radius (number) - The radius to search within.
        playerOnly (boolean) - If true, only return player entities.

    Returns:
        table - Array of nearby entities.

    Realm:
        Shared.

    Example Usage:
        local nearby = player:entitiesNearPlayer(200, true)
        print("Found " .. #nearby .. " players nearby")
]]
function playerMeta:entitiesNearPlayer(radius, playerOnly)
    local nearbyEntities = {}
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if not playerOnly or v:IsPlayer() then table.insert(nearbyEntities, v) end
    end
    return nearbyEntities
end

--[[
    getItemWeapon

    Purpose:
        Returns the player's currently equipped weapon and its corresponding inventory item.

    Returns:
        Weapon, Item or nil - The weapon and item, or nil if not found.

    Realm:
        Shared.

    Example Usage:
        local weapon, item = player:getItemWeapon()
        if weapon then
            print("Equipped weapon: " .. weapon:GetClass())
        end
]]
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

--[[
    isRunning

    Purpose:
        Checks if the player is currently running.

    Returns:
        boolean - True if the player is running, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isRunning() then
            print("Player is running")
        end
]]
function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > self:GetWalkSpeed() + 10
end

--[[
    isFemale

    Purpose:
        Checks if the player's model is female.

    Returns:
        boolean - True if the player's model is female, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isFemale() then
            print("Player is female")
        end
]]
function playerMeta:isFemale()
    local model = self:GetModel():lower()
    return model:find("female") or model:find("alyx") or model:find("mossman")
end

--[[
    IsFamilySharedAccount

    Purpose:
        Checks if the player's Steam account is family shared.

    Returns:
        boolean - True if the account is family shared, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:IsFamilySharedAccount() then
            print("Player has family shared account")
        end
]]
function playerMeta:IsFamilySharedAccount()
    return util.SteamIDFrom64(self:OwnerSteamID64()) ~= self:SteamID()
end

--[[
    getItemDropPos

    Purpose:
        Calculates the position where items should be dropped in front of the player.

    Returns:
        Vector - The calculated drop position.

    Realm:
        Shared.

    Example Usage:
        local dropPos = player:getItemDropPos()
        print("Item will be dropped at: " .. tostring(dropPos))
]]
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
    getItems

    Purpose:
        Returns all items in the player's inventory.

    Returns:
        table or nil - Array of inventory items, or nil if no character or inventory exists.

    Realm:
        Shared.

    Example Usage:
        local items = player:getItems()
        if items then
            print("Player has " .. #items .. " items")
        end
]]
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--[[
    getTracedEntity

    Purpose:
        Returns the entity that the player is looking at within a specified distance.

    Parameters:
        distance (number) - The maximum distance to trace. Defaults to 96.

    Returns:
        Entity or nil - The traced entity, or nil if no entity is found.

    Realm:
        Shared.

    Example Usage:
        local entity = player:getTracedEntity(150)
        if entity then
            print("Player is looking at: " .. entity:GetClass())
        end
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
    getTrace

    Purpose:
        Performs a hull trace from the player's shoot position in the direction they are looking.

    Parameters:
        distance (number) - The maximum distance to trace. Defaults to 200.

    Returns:
        table - The trace result table containing hit information.

    Realm:
        Shared.

    Example Usage:
        local trace = player:getTrace(300)
        if trace.Hit then
            print("Hit something at: " .. tostring(trace.HitPos))
        end
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
    getEyeEnt

    Purpose:
        Returns the entity the player is looking at within a specified distance using eye trace.

    Parameters:
        distance (number) - The maximum distance to check. Defaults to 150.

    Returns:
        Entity or nil - The entity being looked at, or nil if out of range.

    Realm:
        Shared.

    Example Usage:
        local entity = player:getEyeEnt(200)
        if entity then
            print("Looking at: " .. entity:GetClass())
        end
]]
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

--[[
    notify

    Purpose:
        Sends a notification message to the player.

    Parameters:
        message (string) - The message to display to the player.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:notify("Welcome to the server!")
]]
function playerMeta:notify(message)
    lia.notices.notify(message, self)
end

--[[
    notifyLocalized

    Purpose:
        Sends a localized notification message to the player.

    Parameters:
        message (string) - The localization key for the message.
        ... (any) - Additional arguments to format the localized message.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:notifyLocalized("welcome_message", player:Name())
]]
function playerMeta:notifyLocalized(message, ...)
    lia.notices.notifyLocalized(message, self, ...)
end

--[[
    CanEditVendor

    Purpose:
        Checks if the player can edit the specified vendor.

    Parameters:
        vendor (Entity) - The vendor entity to check permissions for.

    Returns:
        boolean - True if the player can edit the vendor, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:CanEditVendor(vendorEntity) then
            print("Player can edit this vendor")
        end
]]
function playerMeta:CanEditVendor(vendor)
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

--[[
    isStaff

    Purpose:
        Checks if the player is a staff member based on their user group.

    Returns:
        boolean - True if the player is staff, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isStaff() then
            print("Player is a staff member")
        end
]]
function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

--[[
    isVIP

    Purpose:
        Checks if the player is a VIP member based on their user group.

    Returns:
        boolean - True if the player is VIP, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isVIP() then
            print("Player is a VIP member")
        end
]]
function playerMeta:isVIP()
    return groupHasType(self:GetUserGroup(), "VIP")
end

--[[
    isStaffOnDuty

    Purpose:
        Checks if the player is currently on duty as staff.

    Returns:
        boolean - True if the player is on duty as staff, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isStaffOnDuty() then
            print("Player is on duty as staff")
        end
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    isFaction

    Purpose:
        Checks if the player belongs to the specified faction.

    Parameters:
        faction (string) - The faction name to check against.

    Returns:
        boolean or nil - True if the player belongs to the faction, false or nil otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isFaction("police") then
            print("Player is a police officer")
        end
]]
function playerMeta:isFaction(faction)
    local character = self:getChar()
    if not character then return end
    local pFaction = character:getFaction()
    return pFaction and pFaction == faction
end

--[[
    isClass

    Purpose:
        Checks if the player belongs to the specified class.

    Parameters:
        class (string) - The class name to check against.

    Returns:
        boolean or nil - True if the player belongs to the class, false or nil otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isClass("medic") then
            print("Player is a medic")
        end
]]
function playerMeta:isClass(class)
    local character = self:getChar()
    if not character then return end
    local pClass = character:getClass()
    return pClass and pClass == class
end

--[[
    hasWhitelist

    Purpose:
        Checks if the player has a whitelist for the specified faction.

    Parameters:
        faction (string) - The faction name to check whitelist for.

    Returns:
        boolean - True if the player has a whitelist for the faction, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasWhitelist("police") then
            print("Player has police whitelist")
        end
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
    getClass

    Purpose:
        Returns the player's current class.

    Returns:
        string or nil - The player's class name, or nil if no character exists.

    Realm:
        Shared.

    Example Usage:
        local class = player:getClass()
        if class then
            print("Player's class: " .. class)
        end
]]
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

--[[
    hasClassWhitelist

    Purpose:
        Checks if the player has a whitelist for the specified class.

    Parameters:
        class (string) - The class name to check whitelist for.

    Returns:
        boolean - True if the player has a whitelist for the class, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasClassWhitelist("medic") then
            print("Player has medic class whitelist")
        end
]]
function playerMeta:hasClassWhitelist(class)
    local char = self:getChar()
    if not char then return false end
    local wl = char:getClasswhitelists() or {}
    return wl[class] == true
end

--[[
    getClassData

    Purpose:
        Returns the data for the player's current class.

    Returns:
        table or nil - The class data table, or nil if no character or class exists.

    Realm:
        Shared.

    Example Usage:
        local classData = player:getClassData()
        if classData then
            print("Class description: " .. classData.description)
        end
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
    getDarkRPVar

    Purpose:
        Returns DarkRP variable values for the player. Currently only supports "money" variable.

    Parameters:
        var (string) - The DarkRP variable name to retrieve. Only "money" is currently supported.

    Returns:
        number or nil - The value of the requested variable, or nil if not supported.

    Realm:
        Shared.

    Example Usage:
        local money = player:getDarkRPVar("money")
        if money then
            print("Player has " .. money .. " money")
        end
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    getMoney

    Purpose:
        Returns the player's current money amount from their character.

    Returns:
        number - The player's current money amount, or 0 if no character exists.

    Realm:
        Shared.

    Example Usage:
        local money = player:getMoney()
        print("Player has " .. money .. " money")
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    canAfford

    Purpose:
        Checks if the player can afford a specified amount of money.

    Parameters:
        amount (number) - The amount of money to check.

    Returns:
        boolean - True if the player can afford the amount, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:canAfford(1000) then
            print("Player can afford 1000")
        end
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    hasSkillLevel

    Purpose:
        Checks if the player has a skill level at or above the specified level.

    Parameters:
        skill (string) - The skill name to check.
        level (number) - The minimum skill level required.

    Returns:
        boolean - True if the player has the required skill level, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasSkillLevel("strength", 5) then
            print("Player has strength level 5 or higher")
        end
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    meetsRequiredSkills

    Purpose:
        Checks if the player meets all the required skill levels for a set of skills.

    Parameters:
        requiredSkillLevels (table) - Table of skill names mapped to required levels.

    Returns:
        boolean - True if the player meets all required skill levels, false otherwise.

    Realm:
        Shared.

    Example Usage:
        local required = {strength = 5, agility = 3}
        if player:meetsRequiredSkills(required) then
            print("Player meets all skill requirements")
        end
]]
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--[[
    forceSequence

    Purpose:
        Forces the player to play a specific animation sequence.

    Parameters:
        sequenceName (string) - The name of the sequence to play.
        callback (function) - Optional callback function to execute when sequence ends.
        time (number) - Optional duration for the sequence. Defaults to sequence duration.
        noFreeze (boolean) - If false, freezes player movement during sequence.

    Returns:
        number or boolean - Duration of the sequence if successful, false if failed.

    Realm:
        Shared.

    Example Usage:
        local duration = player:forceSequence("sit", function() print("Sit sequence finished") end)
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
    leaveSequence

    Purpose:
        Stops the current forced sequence and restores normal player movement.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:leaveSequence()
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
    restoreStamina

    Purpose:
        Restores the player's stamina by the specified amount.

    Parameters:
        amount (number) - The amount of stamina to restore.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:restoreStamina(50)
    ]]
    function playerMeta:restoreStamina(amount)
        local char = self:getChar()
        local current = self:getLocalVar("stamina", char and char:getMaxStamina() or lia.config.get("DefaultStamina", 100))
        local maxStamina = char and char:getMaxStamina() or lia.config.get("DefaultStamina", 100)
        local value = math.Clamp(current + amount, 0, maxStamina)
        self:setLocalVar("stamina", value)
        if value >= maxStamina * 0.5 and self:getNetVar("brth", false) then
            self:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    --[[
    consumeStamina

    Purpose:
        Consumes the specified amount of stamina from the player.

    Parameters:
        amount (number) - The amount of stamina to consume.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:consumeStamina(25)
    ]]
    function playerMeta:consumeStamina(amount)
        local char = self:getChar()
        local current = self:getLocalVar("stamina", char and char:getMaxStamina() or lia.config.get("DefaultStamina", 100))
        local value = math.Clamp(current - amount, 0, char and char:getMaxStamina() or lia.config.get("DefaultStamina", 100))
        self:setLocalVar("stamina", value)
        if value == 0 and not self:getNetVar("brth", false) then
            self:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", self)
        end
    end

    --[[
    addMoney

    Purpose:
        Adds the specified amount of money to the player's character.

    Parameters:
        amount (number) - The amount of money to add.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:addMoney(1000)
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
            self:notifyLocalized("moneyLimitReached", lia.currency.get(maxMoneyLimit), lia.currency.plural, lia.currency.get(excessMoney), lia.currency.plural)
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
    end

    --[[
    takeMoney

    Purpose:
        Removes the specified amount of money from the player's character.

    Parameters:
        amount (number) - The amount of money to remove.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:takeMoney(500)
    ]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    --[[
    WhitelistAllClasses

    Purpose:
        Grants the player access to all available classes.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:WhitelistAllClasses()
    ]]
    function playerMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            self:classWhitelist(class)
        end
    end

    --[[
    WhitelistAllFactions

    Purpose:
        Grants the player access to all available factions.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:WhitelistAllFactions()
    ]]
    function playerMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    --[[
    WhitelistEverything

    Purpose:
        Grants the player access to all available factions and classes.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:WhitelistEverything()
    ]]
    function playerMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    --[[
    classWhitelist

    Purpose:
        Grants the player access to a specific class.

    Parameters:
        class (string) - The class name to whitelist.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:classWhitelist("medic")
    ]]
    function playerMeta:classWhitelist(class)
        local char = self:getChar()
        if not char then return end
        local wl = char:getClasswhitelists() or {}
        wl[class] = true
        char:setClasswhitelists(wl)
    end

    --[[
    classUnWhitelist

    Purpose:
        Removes the player's access to a specific class.

    Parameters:
        class (string) - The class name to remove whitelist for.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:classUnWhitelist("medic")
    ]]
    function playerMeta:classUnWhitelist(class)
        local char = self:getChar()
        if not char then return end
        local wl = char:getClasswhitelists() or {}
        wl[class] = nil
        char:setClasswhitelists(wl)
    end

    --[[
    setWhitelisted

    Purpose:
        Sets the whitelist status for a specific faction for the player.

    Parameters:
        faction (string) - The faction name to set whitelist for.
        whitelisted (boolean) - Whether to whitelist or remove whitelist.

    Returns:
        boolean - True if the operation was successful, false otherwise.

    Realm:
        Server.

    Example Usage:
        player:setWhitelisted("police", true)
    ]]
    function playerMeta:setWhitelisted(faction, whitelisted)
        if not whitelisted then whitelisted = nil end
        local data = lia.faction.indices[faction]
        if data then
            local whitelists = self:getLiliaData("whitelists", {})
            whitelists[SCHEMA.folder] = whitelists[SCHEMA.folder] or {}
            whitelists[SCHEMA.folder][data.uniqueID] = whitelisted and true or nil
            self:setLiliaData("whitelists", whitelists)
            return true
        end
        return false
    end

    --[[
    loadLiliaData

    Purpose:
        Loads the player's Lilia data from the database.

    Parameters:
        callback (function) - Optional callback function to execute after loading.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:loadLiliaData(function(data) print("Data loaded") end)
    ]]
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
                local isCheater = self:getLiliaData("cheater", false)
                self:setNetVar("cheater", isCheater and true or nil)
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

    --[[
    saveLiliaData

    Purpose:
        Saves the player's Lilia data to the database, including online time tracking and other persistent data.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:saveLiliaData()
    ]]
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

    --[[
    setLiliaData

    Purpose:
        Sets a key-value pair in the player's Lilia data and optionally syncs it to the client and saves to database.

    Parameters:
        key (string) - The data key to set.
        value (any) - The value to store.
        noNetworking (boolean) - If true, doesn't sync to client.
        noSave (boolean) - If true, doesn't save to database.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setLiliaData("customFlag", true)
    ]]
    function playerMeta:setLiliaData(key, value, noNetworking, noSave)
        self.liaData = self.liaData or {}
        self.liaData[key] = value
        if not noNetworking then
            net.Start("liaData")
            net.WriteString(key)
            net.WriteType(value)
            net.Send(self)
        end

        if not noSave then self:saveLiliaData() end
    end

    --[[
    setWaypoint

    Purpose:
        Sets a waypoint for the player at the specified location.

    Parameters:
        name (string) - The name of the waypoint.
        vector (Vector) - The position where the waypoint should be set.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setWaypoint("Home", Vector(100, 200, 300))
    ]]
    function playerMeta:setWaypoint(name, vector)
        net.Start("setWaypoint")
        net.WriteString(name)
        net.WriteVector(vector)
        net.Send(self)
    end

    --[[
    setWeighPoint

    Purpose:
        Sets a waypoint for the player (alias for setWaypoint).

    Parameters:
        name (string) - The name of the waypoint.
        vector (Vector) - The position where the waypoint should be set.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setWeighPoint("Home", Vector(100, 200, 300))
    ]]
    function playerMeta:setWeighPoint(name, vector)
        self:setWaypoint(name, vector)
    end

    --[[
    setWaypointWithLogo

    Purpose:
        Sets a waypoint for the player with a custom logo/icon.

    Parameters:
        name (string) - The name of the waypoint.
        vector (Vector) - The position where the waypoint should be set.
        logo (string) - The logo/icon identifier for the waypoint.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setWaypointWithLogo("Store", Vector(500, 600, 700), "store_icon")
    ]]
    function playerMeta:setWaypointWithLogo(name, vector, logo)
        net.Start("setWaypointWithLogo")
        net.WriteString(name)
        net.WriteVector(vector)
        net.WriteString(logo)
        net.Send(self)
    end

    --[[
    getLiliaData

    Purpose:
        Retrieves a value from the player's Lilia data storage.

    Parameters:
        key (string) - The data key to retrieve.
        default (any) - The default value to return if the key doesn't exist.

    Returns:
        any - The stored value or the default value if not found.

    Realm:
        Shared.

    Example Usage:
        local customFlag = player:getLiliaData("customFlag", false)
    ]]
    function playerMeta:getLiliaData(key, default)
        local data = self.liaData and self.liaData[key]
        if data == nil then return default end
        return data
    end

    playerMeta.getData = playerMeta.getLiliaData
    --[[
    getAllLiliaData

    Purpose:
        Returns all of the player's Lilia data as a table.

    Returns:
        table - The complete Lilia data table for the player.

    Realm:
        Shared.

    Example Usage:
        local allData = player:getAllLiliaData()
        for key, value in pairs(allData) do
            print(key .. ": " .. tostring(value))
        end
    ]]
    function playerMeta:getAllLiliaData()
        self.liaData = self.liaData or {}
        return self.liaData
    end

    --[[
    getFlags

    Purpose:
        Returns the flags associated with the player's character.

    Returns:
        string - The character's flags, or empty string if no character exists.

    Realm:
        Shared.

    Example Usage:
        local flags = player:getFlags()
        if flags:find("a") then
            print("Player has admin flag")
        end
    ]]
    function playerMeta:getFlags()
        local char = self:getChar()
        return char and char:getFlags() or ""
    end

    --[[
    setFlags

    Purpose:
        Sets the flags for the player's character.

    Parameters:
        flags (string) - The flags to set for the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:setFlags("a")
        print("Player now has admin flag")
]]
    function playerMeta:setFlags(flags)
        local char = self:getChar()
        if char then char:setFlags(flags) end
    end

    --[[
    giveFlags

    Purpose:
        Gives flags to the player's character.

    Parameters:
        flags (string) - The flags to give to the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:giveFlags("a")
        print("Player now has admin flag")
]]
    function playerMeta:giveFlags(flags)
        local char = self:getChar()
        if char then char:giveFlags(flags) end
    end

    --[[
    takeFlags

    Purpose:
        Removes flags from the player's character.

    Parameters:
        flags (string) - The flags to remove from the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:takeFlags("a")
        print("Player no longer has admin flag")
]]
    function playerMeta:takeFlags(flags)
        local char = self:getChar()
        if char then char:takeFlags(flags) end
    end

    --[[
    getPlayerFlags

    Purpose:
        Returns the player's personal flags.

    Returns:
        string - The player's personal flags.

    Realm:
        Shared.

    Example Usage:
        local flags = player:getPlayerFlags()
        print("Player flags: " .. flags)
]]
    function playerMeta:getPlayerFlags()
        return self:getLiliaData("playerFlags", "")
    end

    --[[
    setPlayerFlags

    Purpose:
        Sets the player's personal flags.

    Parameters:
        flags (string) - The flags to set.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:setPlayerFlags("v")
        print("Player now has VIP flag")
]]
    function playerMeta:setPlayerFlags(flags)
        self:setLiliaData("playerFlags", flags)
    end

    --[[
    hasPlayerFlags

    Purpose:
        Checks if the player has specific personal flags.

    Parameters:
        flags (string) - the flags to check for.

    Returns:
        boolean - True if the player has any of the specified flags.

    Realm:
        Shared.

    Example Usage:
        if player:hasPlayerFlags("v") then
            print("Player has VIP flag")
        end
]]
    function playerMeta:hasPlayerFlags(flags)
        local pFlags = self:getPlayerFlags()
        for i = 1, #flags do
            if pFlags:find(flags:sub(i, i), 1, true) then return true end
        end
        return false
    end

    --[[
    givePlayerFlags

    Purpose:
        Gives personal flags to the player.

    Parameters:
        flags (string) - The flags to give.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:givePlayerFlags("v")
        print("Player now has VIP flag")
]]
    function playerMeta:givePlayerFlags(flags)
        local addedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not self:hasPlayerFlags(flag) then
                local info = lia.flag.list[flag]
                if info and info.callback and not self:hasFlags(flag) then info.callback(self, true) end
                addedFlags = addedFlags .. flag
            end
        end

        if addedFlags ~= "" then self:setPlayerFlags(self:getPlayerFlags() .. addedFlags) end
    end

    --[[
    takePlayerFlags

    Purpose:
        Removes personal flags from the player.

    Parameters:
        flags (string) - The flags to remove.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:takePlayerFlags("v")
        print("Player no longer has VIP flag")
]]
    function playerMeta:takePlayerFlags(flags)
        local oldFlags = self:getPlayerFlags()
        local newFlags = oldFlags
        local char = self:getChar()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            newFlags = newFlags:gsub(flag, "")
            local hasChar = char and char:hasFlags(flag)
            if info and info.callback and not hasChar then info.callback(self, false) end
        end

        if newFlags ~= oldFlags then self:setPlayerFlags(newFlags) end
    end

    --[[
    hasFlags

    Purpose:
        Checks if the player has specific flags (character or personal).

    Parameters:
        flags (string) - The flags to check for.

    Returns:
        boolean - True if the player has any of the specified flags.

    Realm:
        Shared.

    Example Usage:
        if player:hasFlags("a") then
            print("Player has admin flag")
        end
]]
    function playerMeta:hasFlags(flags)
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if self:getFlags():find(flag, 1, true) or self:getPlayerFlags():find(flag, 1, true) then return true end
        end
        return hook.Run("CharHasFlags", self, flags) or false
    end

    --[[
    setRagdoll

    Purpose:
        Sets the player's ragdoll entity.

    Parameters:
        entity (Entity) - The ragdoll entity to set.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setRagdoll(ragdollEntity)
]]
    function playerMeta:setRagdoll(entity)
        self.liaRagdoll = entity
    end

    --[[
    NetworkAnimation

    Purpose:
        Networks animation status to all clients.

    Parameters:
        active (boolean) - Whether the animation is active.
        boneData (table) - The bone data for the animation.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:NetworkAnimation(true, boneData)
]]
    function playerMeta:NetworkAnimation(active, boneData)
        net.Start("AnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    end

    --[[
    banPlayer

    Purpose:
        Bans the player from the server.

    Parameters:
        reason (string) - The reason for the ban.
        duration (number) - The duration of the ban in seconds.
        banner (Player) - The player who issued the ban.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:banPlayer("Breaking rules", 3600, adminPlayer)
]]
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

    --[[
    setAction

    Purpose:
        Sets an action bar for the player with optional callback.

    Parameters:
        text (string) - The text to display in the action bar.
        time (number) - The duration of the action bar.
        callback (function) - Optional callback function when action completes.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setAction("Loading...", 5, function() print("Action complete") end)
]]
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

    --[[
    doStaredAction

    Purpose:
        Performs an action that requires the player to stare at an entity.

    Parameters:
        entity (Entity) - The entity to stare at.
        callback (function) - Function to call when action completes.
        time (number) - Time required to complete the action.
        onCancel (function) - Function to call if action is cancelled.
        distance (number) - Maximum distance to perform action.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:doStaredAction(targetEntity, function() print("Action done") end, 3)
]]
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

    --[[
    stopAction

    Purpose:
        Stops the current action bar.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:stopAction()
]]
    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        net.Start("actBar")
        net.Send(self)
    end

    --[[
    requestDropdown

    Purpose:
        Requests a dropdown selection from the player.

    Parameters:
        title (string) - The title of the dropdown.
        subTitle (string) - The subtitle of the dropdown.
        options (table) - The options to choose from.
        callback (function) - Function to call when selection is made.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:requestDropdown("Choose", "Select an option", {"Option 1", "Option 2"}, callback)
]]
    function playerMeta:requestDropdown(title, subTitle, options, callback)
        net.Start("RequestDropdown")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.Send(self)
        self.dropdownCallback = callback
    end

    --[[
    requestOptions

    Purpose:
        Requests multiple option selections from the player.

    Parameters:
        title (string) - The title of the request.
        subTitle (string) - The subtitle of the request.
        options (table) - The options to choose from.
        limit (number) - Maximum number of selections allowed.
        callback (function) - Function to call when selection is made.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:requestOptions("Choose", "Select options", {"A", "B", "C"}, 2, callback)
]]
    function playerMeta:requestOptions(title, subTitle, options, limit, callback)
        net.Start("OptionsRequest")
        net.WriteString(title)
        net.WriteString(subTitle)
        net.WriteTable(options)
        net.WriteUInt(limit, 32)
        net.Send(self)
        self.optionsCallback = callback
    end

    --[[
    requestString

    Purpose:
        Requests a string input from the player.

    Parameters:
        title (string) - The title of the request.
        subTitle (string) - The subtitle of the request.
        callback (function) - Function to call when string is entered.
        default (string) - Default value for the input.

    Returns:
        Deferred object or nil.

    Realm:
        Server.

    Example Usage:
        local deferred = player:requestString("Name", "Enter your name", callback, "Default")
]]
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

    --[[
    requestArguments

    Purpose:
        Requests multiple arguments from the player.

    Parameters:
        title (string) - The title of the request.
        argTypes (table) - The types of arguments to request.
        callback (function) - Function to call when arguments are entered.

    Returns:
        Deferred object or nil.

    Realm:
        Server.

    Example Usage:
        local deferred = player:requestArguments("Input", {"string", "number"}, callback)
]]
    function playerMeta:requestArguments(title, argTypes, callback)
        local d
        if not isfunction(callback) then
            d = deferred.new()
            callback = function(value) d:resolve(value) end
        end

        self.liaArgReqs = self.liaArgReqs or {}
        local id = table.insert(self.liaArgReqs, callback)
        net.Start("ArgumentsRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title or "")
        net.WriteTable(argTypes)
        net.Send(self)
        return d
    end

    --[[
    binaryQuestion

    Purpose:
        Asks the player a yes/no question.

    Parameters:
        question (string) - The question to ask.
        option1 (string) - The first option text.
        option2 (string) - The second option text.
        manualDismiss (boolean) - Whether the player can manually dismiss.
        callback (function) - Function to call when answer is given.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:binaryQuestion("Continue?", "Yes", "No", false, callback)
]]
    function playerMeta:binaryQuestion(question, option1, option2, manualDismiss, callback)
        net.Start("BinaryQuestionRequest")
        net.WriteString(question)
        net.WriteString(option1)
        net.WriteString(option2)
        net.WriteBool(manualDismiss)
        net.Send(self)
        self.binaryQuestionCallback = callback
    end

    --[[
    requestButtons

    Purpose:
        Requests button selection from the player.

    Parameters:
        title (string) - The title of the request.
        buttons (table) - Table of button data with text and callbacks.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:requestButtons("Choose", {{text = "Button 1", callback = func1}, {text = "Button 2", callback = func2}})
]]
    function playerMeta:requestButtons(title, buttons)
        self.buttonRequests = self.buttonRequests or {}
        local labels = {}
        local callbacks = {}
        for i, data in ipairs(buttons) do
            labels[i] = data.text or data[1] or ""
            callbacks[i] = data.callback or data[2]
        end

        local id = table.insert(self.buttonRequests, callbacks)
        net.Start("ButtonRequest")
        net.WriteUInt(id, 32)
        net.WriteString(title or "")
        net.WriteUInt(#labels, 8)
        for _, lbl in ipairs(labels) do
            net.WriteString(lbl)
        end

        net.Send(self)
    end

    --[[
    getPlayTime

    Purpose:
        Returns the player's total play time.

    Returns:
        number - The player's total play time in seconds.

    Realm:
        Shared.

    Example Usage:
        local playTime = player:getPlayTime()
        print("Player has played for " .. playTime .. " seconds")
]]
    function playerMeta:getPlayTime()
        local hookResult = hook.Run("getPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(self.lastJoin)) - os.time(lia.time.toNumber(self.firstJoin))
        return diff + RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    getSessionTime

    Purpose:
        Returns the player's current session time.

    Returns:
        number - The current session time in seconds.

    Realm:
        Shared.

    Example Usage:
        local sessionTime = player:getSessionTime()
        print("Current session: " .. sessionTime .. " seconds")
]]
    function playerMeta:getSessionTime()
        return RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    getTotalOnlineTime

    Purpose:
        Returns the player's total online time including current session.

    Returns:
        number - The total online time in seconds.

    Realm:
        Shared.

    Example Usage:
        local totalTime = player:getTotalOnlineTime()
        print("Total online time: " .. totalTime .. " seconds")
]]
    function playerMeta:getTotalOnlineTime()
        local stored = self:getLiliaData("totalOnlineTime", 0)
        return stored + RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    getLastOnline

    Purpose:
        Returns a human-readable string of when the player was last online.

    Returns:
        string - Human-readable time since last online.

    Realm:
        Shared.

    Example Usage:
        local lastOnline = player:getLastOnline()
        print("Last online: " .. lastOnline)
]]
    function playerMeta:getLastOnline()
        local last = self:getLiliaData("lastOnline", os.time())
        return lia.time.TimeSince(last)
    end

    --[[
    getLastOnlineTime

    Purpose:
        Returns the timestamp of when the player was last online.

    Returns:
        number - Unix timestamp of last online time.

    Realm:
        Shared.

    Example Usage:
        local lastTime = player:getLastOnlineTime()
        print("Last online timestamp: " .. lastTime)
]]
    function playerMeta:getLastOnlineTime()
        return self:getLiliaData("lastOnline", os.time())
    end

    --[[
    createRagdoll

    Purpose:
        Creates a ragdoll entity for the player.

    Parameters:
        freeze (boolean) - Whether to freeze the ragdoll physics.
        isDead (boolean) - Whether this ragdoll represents a dead player.

    Returns:
        Entity - The created ragdoll entity.

    Realm:
        Server.

    Example Usage:
        local ragdoll = player:createRagdoll(false, true)
]]
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

    --[[
    setRagdolled

    Purpose:
        Sets the player's ragdoll state.

    Parameters:
        state (boolean) - Whether to ragdoll the player.
        time (number) - Time before auto-recovery.
        getUpGrace (number) - Grace period for getting up.
        getUpMessage (string) - Message to show during recovery.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        player:setRagdolled(true, 5, 2, "Getting up...")
]]
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

    --[[
    syncVars

    Purpose:
        Synchronizes all networked variables for this player with the client.
        Sends global variables and entity-specific variables through networking.

    Parameters:
        None.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Sync all variables for a player
        player:syncVars()
]]
    function playerMeta:syncVars()
        for entity, data in pairs(lia.net) do
            if entity == "globals" then
                for k, v in pairs(data) do
                    net.Start("gVar")
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            elseif IsValid(entity) then
                for k, v in pairs(data) do
                    net.Start("nVar")
                    net.WriteUInt(entity:EntIndex(), 16)
                    net.WriteString(k)
                    net.WriteType(v)
                    net.Send(self)
                end
            end
        end
    end

    --[[
    setLocalVar

    Purpose:
        Sets a local variable for this player and synchronizes it to the client.
        The variable is stored locally and sent through networking.

    Parameters:
        key (string) - The key/name of the variable.
        value (any) - The value to store.

    Returns:
        None.

    Realm:
        Server.

    Example Usage:
        -- Set a local variable for a player
        player:setLocalVar("customFlag", true)
]]
    function playerMeta:setLocalVar(key, value)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        lia.net[self][key] = value
        net.Start("nLcl")
        net.WriteString(key)
        net.WriteType(value)
        net.Send(self)
        hook.Run("LocalVarChanged", self, key, oldValue, value)
    end
else
    --[[
    CanOverrideView

    Purpose:
        Determines if the player can override their view (third person).
        Checks various conditions like ragdoll state, vehicle status, and configuration.

    Parameters:
        None.

    Returns:
        boolean - True if the player can override their view, false otherwise.

    Realm:
        Client.

    Example Usage:
        if player:CanOverrideView() then
            print("Player can use third person view")
        end
]]
    function playerMeta:CanOverrideView()
        local ragdoll = Entity(self:getLocalVar("ragdoll", 0))
        local isInVehicle = self:hasValidVehicle()
        if IsValid(lia.gui.char) then return false end
        if isInVehicle then return false end
        if hook.Run("ShouldDisableThirdperson", self) == true then return false end
        return lia.option.get("thirdPersonEnabled", false) and lia.config.get("ThirdPersonEnabled", true) and IsValid(self) and self:getChar() and not IsValid(ragdoll)
    end

    --[[
    IsInThirdPerson

    Purpose:
        Checks if the player is currently in third person view mode.
        Considers both global configuration and player preferences.

    Parameters:
        None.

    Returns:
        boolean - True if third person is enabled, false otherwise.

    Realm:
        Client.

    Example Usage:
        if player:IsInThirdPerson() then
            print("Player is in third person view")
        end
]]
    function playerMeta:IsInThirdPerson()
        local thirdPersonEnabled = lia.config.get("ThirdPersonEnabled", true)
        local tpEnabled = lia.option.get("thirdPersonEnabled", false)
        return tpEnabled and thirdPersonEnabled
    end

    --[[
    getPlayTime

    Purpose:
        Gets the total play time for this player, including current session.
        Considers character login time and previous play time.

    Parameters:
        None.

    Returns:
        number - Total play time in seconds.

    Realm:
        Shared.

    Example Usage:
        local playTime = player:getPlayTime()
        print("Total play time: " .. playTime .. " seconds")
]]
    function playerMeta:getPlayTime()
        local hookResult = hook.Run("getPlayTime", self)
        if hookResult ~= nil then return hookResult end
        local char = self:getChar()
        if char then
            local loginTime = char:getLoginTime() or os.time()
            return char:getPlayTime() + os.time() - loginTime
        end

        local diff = os.time(lia.time.toNumber(lia.lastJoin)) - os.time(lia.time.toNumber(lia.firstJoin))
        return diff + RealTime() - (lia.joinTime or 0)
    end

    --[[
    getTotalOnlineTime

    Purpose:
        Gets the total time this player has been online across all sessions.
        Includes stored time and current session time.

    Parameters:
        None.

    Returns:
        number - Total online time in seconds.

    Realm:
        Shared.

    Example Usage:
        local totalTime = player:getTotalOnlineTime()
        print("Total online time: " .. totalTime .. " seconds")
]]
    function playerMeta:getTotalOnlineTime()
        local stored = self:getLiliaData("totalOnlineTime", 0)
        return stored + RealTime() - (lia.joinTime or 0)
    end

    --[[
    getLastOnline

    Purpose:
        Gets a human-readable string representing when the player was last online.
        Returns relative time (e.g., "2 hours ago").

    Parameters:
        None.

    Returns:
        string - Human-readable time since last online.

    Realm:
        Shared.

    Example Usage:
        local lastOnline = player:getLastOnline()
        print("Last online: " .. lastOnline)
]]
    function playerMeta:getLastOnline()
        local last = self:getLiliaData("lastOnline", os.time())
        return lia.time.TimeSince(last)
    end

    --[[
    getLastOnlineTime

    Purpose:
        Gets the timestamp when the player was last online.
        Returns the raw timestamp value.

    Parameters:
        None.

    Returns:
        number - Unix timestamp of last online time.

    Realm:
        Shared.

    Example Usage:
        local lastTime = player:getLastOnlineTime()
        print("Last online timestamp: " .. lastTime)
]]
    function playerMeta:getLastOnlineTime()
        return self:getLiliaData("lastOnline", os.time())
    end

    --[[
    setWaypoint

    Purpose:
        Sets a waypoint for the player at the specified location.
        Creates a HUD element that shows the waypoint and distance.

    Parameters:
        name (string) - The name of the waypoint.
        vector (Vector) - The position where the waypoint should be set.
        onReach (function, optional) - Callback function when waypoint is reached.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Set a waypoint with callback when reached
        player:setWaypoint("Home", Vector(100, 200, 300), function()
            print("Reached home!")
        end)
]]
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
                draw.DrawText(name .. "\n" .. L("meters", howclose) .. "\n", "liaBigFont", spos.x, spos.y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
                render.SuppressEngineLighting(false)
            end

            if howclose <= 3 then RunConsoleCommand("weighpoint_stop") end
        end)

        concommand.Add("weighpoint_stop", function()
            hook.Remove("HUDPaint", "WeighPoint")
            if onReach and isfunction(onReach) then onReach() end
        end)
    end

    --[[
    setWeighPoint

    Purpose:
        Sets a weight-based waypoint for the player.
        Similar to setWaypoint but with weight considerations.

    Parameters:
        name (string) - The name/description of the waypoint.
        vector (Vector) - The position of the waypoint.
        onReach (function, optional) - Callback function when waypoint is reached.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Set a weight-based waypoint
        player:setWeighPoint("Heavy Item", Vector(500, 600, 700))
]]
    function playerMeta:setWeighPoint(name, vector, onReach)
        self:setWaypoint(name, vector, onReach)
    end

    --[[
    setWaypointWithLogo

    Purpose:
        Sets a waypoint with a custom logo/icon for the player.
        The logo will be displayed alongside the waypoint.

    Parameters:
        name (string) - The name/description of the waypoint.
        vector (Vector) - The position of the waypoint.
        logo (string) - The logo/icon identifier.
        onReach (function, optional) - Callback function when waypoint is reached.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Set a waypoint with custom logo
        player:setWaypointWithLogo("Shop", Vector(1000, 2000, 3000), "shop_icon")
]]
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

                draw.DrawText(name .. "\n" .. L("meters", howClose), "liaBigFont", spos.x, spos.y - 10, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            end

            if howClose <= 3 then RunConsoleCommand("waypoint_withlogo_stop_" .. waypointID) end
        end)

        concommand.Add("waypoint_withlogo_stop_" .. waypointID, function()
            hook.Remove("HUDPaint", waypointID)
            concommand.Remove("waypoint_withlogo_stop_" .. waypointID)
            if onReach and isfunction(onReach) then onReach(self) end
        end)
    end

    --[[
    getLiliaData

    Purpose:
        Retrieves a value from the player's local Lilia data storage.
        This is the client-side version of getLiliaData.

    Parameters:
        key (string) - The data key to retrieve.
        default (any) - The default value to return if the key doesn't exist.

    Returns:
        any - The stored value or the default value if not found.

    Realm:
        Client.

    Example Usage:
        -- Get player's local settings
        local settings = player:getLiliaData("settings", {})
        if settings then
            print("Player has custom settings")
        end
]]
    function playerMeta:getLiliaData(key, default)
        local data = lia.localData and lia.localData[key]
        if data == nil then
            return default
        else
            return data
        end
    end

    playerMeta.getData = playerMeta.getLiliaData
    --[[
    getAllLiliaData

    Purpose:
        Retrieves all stored Lilia data for this player.
        Returns a table containing all key-value pairs.

    Parameters:
        None.

    Returns:
        table - All stored Lilia data.

    Realm:
        Shared.

    Example Usage:
        local allData = player:getAllLiliaData()
        for key, value in pairs(allData) do
            print(key .. ": " .. tostring(value))
        end
]]
    function playerMeta:getAllLiliaData()
        lia.localData = lia.localData or {}
        return lia.localData
    end

    --[[
    getFlags

    Purpose:
        Gets the flags associated with this player's character.
        Returns the character flags if available, otherwise returns an empty string.

    Parameters:
        None.

    Returns:
        string - The character flags or empty string if no character.

    Realm:
        Shared.

    Example Usage:
        local flags = player:getFlags()
        print("Player flags: " .. flags)
]]
    function playerMeta:getFlags()
        local char = self:getChar()
        return char and char:getFlags() or ""
    end

    --[[
    setFlags

    Purpose:
        Sets the flags for this player's character.
        Updates the character flags if a character exists.

    Parameters:
        flags (string) - The flags to set for the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Set player character flags
        player:setFlags("abc")
]]
    function playerMeta:setFlags(flags)
        local char = self:getChar()
        if char then char:setFlags(flags) end
    end

    --[[
    giveFlags

    Purpose:
        Adds flags to this player's character.
        Appends the new flags to existing character flags.

    Parameters:
        flags (string) - The flags to add to the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Give additional flags to player
        player:giveFlags("d")
]]
    function playerMeta:giveFlags(flags)
        local char = self:getChar()
        if char then char:giveFlags(flags) end
    end

    --[[
    takeFlags

    Purpose:
        Removes flags from this player's character.
        Removes the specified flags from existing character flags.

    Parameters:
        flags (string) - The flags to remove from the character.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Remove flags from player
        player:takeFlags("a")
]]
    function playerMeta:takeFlags(flags)
        local char = self:getChar()
        if char then char:takeFlags(flags) end
    end

    --[[
    getPlayerFlags

    Purpose:
        Gets the player-specific flags stored in Lilia data.
        Returns flags that are specific to the player, not the character.

    Parameters:
        None.

    Returns:
        string - The player flags or empty string if none set.

    Realm:
        Shared.

    Example Usage:
        local playerFlags = player:getPlayerFlags()
        print("Player flags: " .. playerFlags)
]]
    function playerMeta:getPlayerFlags()
        return self:getLiliaData("playerFlags", "")
    end

    --[[
    setPlayerFlags

    Purpose:
        Sets the player-specific flags in Lilia data.
        Stores flags that are specific to the player, not the character.

    Parameters:
        flags (string) - The player flags to set.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Set player-specific flags
        player:setPlayerFlags("xyz")
]]
    function playerMeta:setPlayerFlags(flags)
        self:setLiliaData("playerFlags", flags)
    end

    --[[
    hasPlayerFlags

    Purpose:
        Checks if the player has any of the specified player flags.
        Checks player-specific flags stored in Lilia data.

    Parameters:
        flags (string) - A string of flag characters to check.

    Returns:
        boolean - True if the player has at least one of the specified flags, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasPlayerFlags("x") then
            print("Player has flag 'x'")
        end
]]
    function playerMeta:hasPlayerFlags(flags)
        local pFlags = self:getPlayerFlags()
        for i = 1, #flags do
            if pFlags:find(flags:sub(i, i), 1, true) then return true end
        end
        return false
    end

    --[[
    givePlayerFlags

    Purpose:
        Adds player-specific flags to this player.
        Adds new flags that the player doesn't already have and runs callbacks.

    Parameters:
        flags (string) - The player flags to add.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Give additional player flags
        player:givePlayerFlags("xyz")
]]
    function playerMeta:givePlayerFlags(flags)
        local addedFlags = ""
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if not self:hasPlayerFlags(flag) then
                local info = lia.flag.list[flag]
                if info and info.callback and not self:hasFlags(flag) then info.callback(self, true) end
                addedFlags = addedFlags .. flag
            end
        end

        if addedFlags ~= "" then self:setPlayerFlags(self:getPlayerFlags() .. addedFlags) end
    end

    --[[
    takePlayerFlags

    Purpose:
        Removes player-specific flags from this player.
        Removes specified flags and runs callbacks for removed flags.

    Parameters:
        flags (string) - The player flags to remove.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        -- Remove player flags
        player:takePlayerFlags("x")
]]
    function playerMeta:takePlayerFlags(flags)
        local oldFlags = self:getPlayerFlags()
        local newFlags = oldFlags
        local char = self:getChar()
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            local info = lia.flag.list[flag]
            newFlags = newFlags:gsub(flag, "")
            local hasChar = char and char:hasFlags(flag)
            if info and info.callback and not hasChar then info.callback(self, false) end
        end

        if newFlags ~= oldFlags then self:setPlayerFlags(newFlags) end
    end

    --[[
    hasFlags

    Purpose:
        Checks if the player has any of the specified flags.
        Checks both character flags and player flags, and runs hook callbacks.

    Parameters:
        flags (string) - A string of flag characters to check.

    Returns:
        boolean - True if the player has at least one of the specified flags, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasFlags("a") then
            print("Player has flag 'a'")
        end
]]
    function playerMeta:hasFlags(flags)
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if self:getFlags():find(flag, 1, true) or self:getPlayerFlags():find(flag, 1, true) then return true end
        end
        return hook.Run("CharHasFlags", self, flags) or false
    end

    --[[
    NetworkAnimation

    Purpose:
        Applies bone angle manipulations for animations on the client side.
        This is the client-side version of NetworkAnimation.

    Parameters:
        active (boolean) - Whether the animation is active.
        boneData (table) - The bone data containing bone names and angles.

    Returns:
        None.

    Realm:
        Client.

    Example Usage:
        -- Apply bone animation data
        player:NetworkAnimation(true, {
            ["ValveBiped.Bip01_Head1"] = Angle(0, 45, 0)
        })
]]
    function playerMeta:NetworkAnimation(active, boneData)
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then self:ManipulateBoneAngles(i, active and ang or angle_zero) end
        end
    end
end

--[[
    playTimeGreaterThan

    Purpose:
        Checks if the player's total play time is greater than the specified time.
        Compares the player's accumulated play time against the given threshold.

    Parameters:
        time (number) - The time threshold to compare against in seconds.

    Returns:
        boolean - True if the player's play time is greater than the specified time, false otherwise.

    Realm:
        Shared.

    Example Usage:
        -- Check if player has played for more than 1 hour
        if player:playTimeGreaterThan(3600) then
            print("Player has been playing for more than 1 hour")
        end
]]
function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end