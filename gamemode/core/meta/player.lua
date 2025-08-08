local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --[[
    getChar

    Purpose:
        Returns the current character of the player.

    Returns:
        Character or nil - The player's current character, or nil if no character is loaded.

    Realm:
        Shared.

    Example Usage:
        local char = player:getChar()
        if char then
            print("Character name: " .. char:getName())
        end
]]
    function playerMeta:getChar()
        return lia.char.loaded[self.getNetVar(self, "char")]
    end

    --[[
    Name

    Purpose:
        Returns the display name of the player, either their character name or Steam name.

    Returns:
        string - The player's display name.

    Realm:
        Shared.

    Example Usage:
        local name = player:Name()
        print("Player name: " .. name)
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
    hasPrivilege

    Purpose:
        Checks if the player has the specified privilege.

    Parameters:
        privilegeName (string) - The name of the privilege to check.

    Returns:
        boolean - True if the player has the privilege, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasPrivilege("admin") then
            print("Player has admin privileges")
        end
]]
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

--[[
    hasValidVehicle

    Purpose:
        Checks if the player has a valid vehicle.

    Returns:
        boolean - True if the player has a valid vehicle, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasValidVehicle() then
            print("Player is in a vehicle")
        end
]]
function playerMeta:hasValidVehicle()
    return IsValid(self:getCurrentVehicle())
end

--[[
    isNoClipping

    Purpose:
        Checks if the player is currently nocliping.

    Returns:
        boolean - True if the player is nocliping, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:isNoClipping() then
            print("Player is nocliping")
        end
]]
function playerMeta:isNoClipping()
    return self:GetMoveType() == MOVETYPE_NOCLIP and not self:hasValidVehicle()
end

--[[
    hasRagdoll

    Purpose:
        Checks if the player has a ragdoll.

    Returns:
        boolean - True if the player has a ragdoll, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if player:hasRagdoll() then
            print("Player has a ragdoll")
        end
]]
function playerMeta:hasRagdoll()
    return IsValid(self.liaRagdoll)
end

--[[
    removeRagdoll

    Purpose:
        Removes the player's ragdoll if one exists.

    Returns:
        None.

    Realm:
        Shared.

    Example Usage:
        player:removeRagdoll()
]]
function playerMeta:removeRagdoll()
    if not self:hasRagdoll() then return end
    local ragdoll = self:getRagdoll()
    ragdoll.liaIgnoreDelete = true
    SafeRemoveEntity(ragdoll)
    self:setLocalVar("blur", nil)
end

--[[
    getRagdoll

    Purpose:
        Returns the player's ragdoll entity if one exists.

    Returns:
        Entity or nil - The ragdoll entity, or nil if no ragdoll exists.

    Realm:
        Shared.

    Example Usage:
        local ragdoll = player:getRagdoll()
        if ragdoll then
            print("Player has a ragdoll")
        end
]]
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:notify(message)
    lia.notices.notify(message, self)
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:notifyLocalized(message, ...)
    lia.notices.notifyLocalized(message, self, ...)
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:CanEditVendor(vendor)
    local hookResult = hook.Run("CanPerformVendorEdit", self, vendor)
    if hookResult ~= nil then return hookResult end
    return self:hasPrivilege(L("canEditVendors"))
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:isVIP()
    return groupHasType(self:GetUserGroup(), "VIP")
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:isFaction(faction)
    local character = self:getChar()
    if not character then return end
    local pFaction = character:getFaction()
    return pFaction and pFaction == faction
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:isClass(class)
    local character = self:getChar()
    if not character then return end
    local pClass = character:getClass()
    return pClass and pClass == class
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:getClass()
    local character = self:getChar()
    if character then return character:getClass() end
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:hasClassWhitelist(class)
    local char = self:getChar()
    if not char then return false end
    local wl = char:getClasswhitelists() or {}
    return wl[class] == true
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:WhitelistAllClasses()
        for class, _ in pairs(lia.class.list) do
            if lia.class.hasWhitelist(class) then self:classWhitelist(class) end
        end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:WhitelistAllFactions()
        for faction, _ in pairs(lia.faction.indices) do
            self:setWhitelisted(faction, true)
        end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:WhitelistEverything()
        self:WhitelistAllFactions()
        self:WhitelistAllClasses()
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:classWhitelist(class)
        local char = self:getChar()
        if not char then return end
        local wl = char:getClasswhitelists() or {}
        wl[class] = true
        char:setClasswhitelists(wl)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:classUnWhitelist(class)
        local char = self:getChar()
        if not char then return end
        local wl = char:getClasswhitelists() or {}
        wl[class] = nil
        char:setClasswhitelists(wl)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setWaypoint(name, vector)
        net.Start("setWaypoint")
        net.WriteString(name)
        net.WriteVector(vector)
        net.Send(self)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setWeighPoint(name, vector)
        self:setWaypoint(name, vector)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setWaypointWithLogo(name, vector, logo)
        net.Start("setWaypointWithLogo")
        net.WriteString(name)
        net.WriteVector(vector)
        net.WriteString(logo)
        net.Send(self)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getLiliaData(key, default)
        local data = self.liaData and self.liaData[key]
        if data == nil then return default end
        return data
    end

    playerMeta.getData = playerMeta.getLiliaData
    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getAllLiliaData()
        self.liaData = self.liaData or {}
        return self.liaData
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getFlags()
        local char = self:getChar()
        return char and char:getFlags() or ""
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setFlags(flags)
        local char = self:getChar()
        if char then char:setFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:giveFlags(flags)
        local char = self:getChar()
        if char then char:giveFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:takeFlags(flags)
        local char = self:getChar()
        if char then char:takeFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getPlayerFlags()
        return self:getLiliaData("playerFlags", "")
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setPlayerFlags(flags)
        self:setLiliaData("playerFlags", flags)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:hasPlayerFlags(flags)
        local pFlags = self:getPlayerFlags()
        for i = 1, #flags do
            if pFlags:find(flags:sub(i, i), 1, true) then return true end
        end
        return false
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:hasFlags(flags)
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if self:getFlags():find(flag, 1, true) or self:getPlayerFlags():find(flag, 1, true) then return true end
        end
        return hook.Run("CharHasFlags", self, flags) or false
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setRagdoll(entity)
        self.liaRagdoll = entity
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:NetworkAnimation(active, boneData)
        net.Start("AnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        net.Start("actBar")
        net.Send(self)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getSessionTime()
        return RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getTotalOnlineTime()
        local stored = self:getLiliaData("totalOnlineTime", 0)
        return stored + RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getLastOnline()
        local last = self:getLiliaData("lastOnline", os.time())
        return lia.time.TimeSince(last)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getLastOnlineTime()
        return self:getLiliaData("lastOnline", os.time())
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:IsInThirdPerson()
        local thirdPersonEnabled = lia.config.get("ThirdPersonEnabled", true)
        local tpEnabled = lia.option.get("thirdPersonEnabled", false)
        return tpEnabled and thirdPersonEnabled
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getTotalOnlineTime()
        local stored = self:getLiliaData("totalOnlineTime", 0)
        return stored + RealTime() - (lia.joinTime or 0)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getLastOnline()
        local last = self:getLiliaData("lastOnline", os.time())
        return lia.time.TimeSince(last)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getLastOnlineTime()
        return self:getLiliaData("lastOnline", os.time())
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setWeighPoint(name, vector, onReach)
        self:setWaypoint(name, vector, onReach)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getAllLiliaData()
        lia.localData = lia.localData or {}
        return lia.localData
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getFlags()
        local char = self:getChar()
        return char and char:getFlags() or ""
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setFlags(flags)
        local char = self:getChar()
        if char then char:setFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:giveFlags(flags)
        local char = self:getChar()
        if char then char:giveFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:takeFlags(flags)
        local char = self:getChar()
        if char then char:takeFlags(flags) end
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:getPlayerFlags()
        return self:getLiliaData("playerFlags", "")
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:setPlayerFlags(flags)
        self:setLiliaData("playerFlags", flags)
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:hasPlayerFlags(flags)
        local pFlags = self:getPlayerFlags()
        for i = 1, #flags do
            if pFlags:find(flags:sub(i, i), 1, true) then return true end
        end
        return false
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
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
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:hasFlags(flags)
        for i = 1, #flags do
            local flag = flags:sub(i, i)
            if self:getFlags():find(flag, 1, true) or self:getPlayerFlags():find(flag, 1, true) then return true end
        end
        return hook.Run("CharHasFlags", self, flags) or false
    end

    --[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
    function playerMeta:NetworkAnimation(active, boneData)
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then self:ManipulateBoneAngles(i, active and ang or angle_zero) end
        end
    end
end

--[[
    getDisplayedName

    Purpose:
        Returns the name to display for this character to the given client, taking into account recognition and fake names.
        If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
        If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
        If recognition is disabled, always returns the character's real name.

    Parameters:
        client (Player) - The player to check recognition against.

    Returns:
        string - The name to display for this character to the given client.

    Realm:
        Shared.

    Example Usage:
        -- Get the display name for a character as seen by a client
        local displayName = character:getDisplayedName(client)
        print("You see this character as: " .. displayName)
]]
function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end