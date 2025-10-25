--[[
    Player Meta
    Player management system for the Lilia framework.
]]
--[[
    Overview:
    The player meta table provides comprehensive functionality for managing player data, interactions, and operations in the Lilia framework. It handles player character access, notification systems, permission checking, data management, interaction systems, and player-specific operations. The meta table operates on both server and client sides, with the server managing player data and validation while the client provides player interaction and display. It includes integration with the character system for character access, notification system for player messages, permission system for access control, data system for player persistence, and interaction system for player actions. The meta table ensures proper player data synchronization, permission validation, notification delivery, and comprehensive player management from connection to disconnection.
]]
local playerMeta = FindMetaTable("Player")
local vectorMeta = FindMetaTable("Vector")
do
    playerMeta.steamName = playerMeta.steamName or playerMeta.Name
    playerMeta.SteamName = playerMeta.steamName
    --[[
        Purpose: Retrieves the player's current character object
        When Called: When accessing the player's character data or performing character-related operations
        Parameters: None
        Returns: table|nil - The character object if player has a character, nil otherwise
        Realm: Shared
        Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player's character
        local char = player:getChar()
        if char then
            print("Player has character:", char:getName())
        end
        ```
        Medium Complexity:
        ```lua
        -- Medium: Check character and access properties
        local char = player:getChar()
        if char and char.getData then
            local money = char:getData("money", 0)
            char:setData("money", money + 100)
        end
        ```
        High Complexity:
        ```lua
        -- High: Full character validation and operations
        local char = player:getChar()
        if char and char.getInventory and char.getData then
            local inventory = char:getInventory()
            local faction = char:getData("faction", "citizen")
            if inventory and faction ~= "citizen" then
                inventory:add("weapon_pistol", 1)
            end
        end
        ```
    ]]
    function playerMeta:getChar()
        return lia.char.getCharacter(self.getNetVar(self, "char"), self)
    end

    --[[
        Purpose: Retrieves the player's current character object
        When Called: When accessing the player's character data or performing character-related operations
        Parameters: None
        Returns: table|nil - The character object if player has a character, nil otherwise
        Realm: Shared
        Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player's character
        local char = player:getChar()
        if char then
            print("Player has character:", char:getName())
        end
        ```
        Medium Complexity:
        ```lua
        -- Medium: Check character and access properties
        local char = player:getChar()
        if char and char.getData then
            local money = char:getData("money", 0)
            char:setData("money", money + 100)
        end
        ```
        High Complexity:
        ```lua
        -- High: Full character validation and operations
        local char = player:getChar()
        if char and char.getInventory and char.getData then
            local inventory = char:getInventory()
            local faction = char:getData("faction", "citizen")
            if inventory and faction ~= "citizen" then
                inventory:add("weapon_pistol", 1)
            end
        end
        ```
    ]]
    function playerMeta:tostring()
        local character = self:getChar()
        if character and character.getName then
            return character:getName()
        else
            return self:SteamName()
        end
    end

    --[[
        Purpose: Converts the player to a string representation using character name or Steam name
        When Called: When converting player to string for display, logging, or comparison purposes
        Parameters: None
        Returns: string - The player's character name if available, otherwise their Steam name
        Realm: Shared
        Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Convert player to string for display
        local playerName = player:tostring()
        print("Player name:", playerName)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Use in logging with fallback
        local playerName = player:tostring()
        lia.log.add("Player " .. playerName .. " performed action")
        ```
        High Complexity:
        ```lua
        -- High: Use in complex display logic with validation
        local playerName = player:tostring()
        if playerName and playerName ~= "" then
            local displayText = string.format("[%s] %s", player:SteamID(), playerName)
            chat.AddText(Color(255, 255, 255), displayText)
        end
        ```
    ]]
    function playerMeta:Name()
        local character = self.getChar(self)
        return character and character.getName(character) or self.steamName(self)
    end

    playerMeta.Nick = playerMeta.Name
    playerMeta.GetName = playerMeta.Name
end

--[[
    Purpose: Makes the player perform a gesture animation and synchronizes it across clients
    When Called: When triggering player animations for roleplay, emotes, or visual effects
    Parameters:
        a (number) - Gesture slot (0-15)
        b (number) - Gesture weight (0-255)
        c (boolean) - Whether to restart the gesture
    Returns: None
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Make player wave
    player:doGesture(ACT_GMOD_GESTURE_WAVE, 1, true)
    ```
    Medium Complexity:
    ```lua
    -- Medium: Conditional gesture based on player state
    if player:IsOnGround() then
        player:doGesture(ACT_GMOD_GESTURE_BOW, 2, true)
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex gesture system with validation
    local gesture = ACT_GMOD_GESTURE_AGREE
    local weight = math.Clamp(emotionLevel, 1, 5)
    local restart = not player:IsPlayingGesture(gesture)
    if player:Alive() and not player:InVehicle() then
        player:doGesture(gesture, weight, restart)
    end
    ```
]]
function playerMeta:doGesture(a, b, c)
    self:AnimRestartGesture(a, b, c)
    if SERVER then
        net.Start("liaSyncGesture")
        net.WriteEntity(self)
        net.WriteUInt(a, 8)
        net.WriteUInt(b, 8)
        net.WriteBool(c)
        net.Broadcast()
    end
end

--[[
    Purpose: Checks if the player has a specific administrative privilege
    When Called: When validating player permissions for commands, features, or access control
    Parameters:
        privilegeName (string) - The name of the privilege to check
    Returns: boolean - True if player has the privilege, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Check if player is admin
    if player:hasPrivilege("admin") then
        print("Player is an admin")
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Conditional access based on privilege
    if player:hasPrivilege("moderator") then
        player:SetHealth(100)
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex permission system with multiple checks
    local requiredPrivs = {"admin", "superadmin"}
    local hasAccess = false
    for _, priv in ipairs(requiredPrivs) do
        if player:hasPrivilege(priv) then
            hasAccess = true
            break
        end
    end
    if hasAccess then
        -- Grant special access
    end
    ```
]]
function playerMeta:hasPrivilege(privilegeName)
    if not isstring(privilegeName) then
        lia.error(L("hasPrivilegeExpectedString", tostring(privilegeName)))
        return false
    end
    return lia.administrator.hasAccess(self, privilegeName)
end

--[[
    Purpose: Removes the player's ragdoll entity and clears associated blur effect
    When Called: When cleaning up player ragdoll after respawn, revival, or state changes
    Parameters: None
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Remove player's ragdoll
    player:removeRagdoll()
    ```
    Medium Complexity:
    ```lua
    -- Medium: Remove ragdoll with validation
    if player:getNetVar("ragdoll") then
        player:removeRagdoll()
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex ragdoll cleanup with state management
    local ragdoll = player:getNetVar("ragdoll")
    if IsValid(ragdoll) and ragdoll:GetCreationTime() < CurTime() - 5 then
        player:removeRagdoll()
        player:setNetVar("deathTime", nil)
    end
    ```
]]
function playerMeta:removeRagdoll()
    local ragdoll = self:getNetVar("ragdoll")
    if not IsValid(ragdoll) then return end
    ragdoll.liaIgnoreDelete = true
    SafeRemoveEntity(ragdoll)
    self:setNetVar("blur", nil)
end

--[[
    Purpose: Checks if the player is stuck inside a solid object or wall
    When Called: When detecting collision issues, implementing anti-stuck systems, or validating player position
    Parameters: None
    Returns: boolean - True if player is stuck, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Check if player is stuck
    if player:isStuck() then
        print("Player is stuck!")
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Handle stuck player with teleport
    if player:isStuck() then
        player:SetPos(Vector(0, 0, 0))
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex stuck detection with logging and recovery
    if player:isStuck() then
        local oldPos = player:GetPos()
        player:SetPos(player:GetPos() + Vector(0, 0, 50))
        if player:isStuck() then
            player:SetPos(Vector(0, 0, 0))
            lia.log.add("Player " .. player:Name() .. " was stuck and teleported")
        end
    end
    ```
]]
function playerMeta:isStuck()
    return util.TraceEntity({
        start = self:GetPos(),
        endpos = self:GetPos(),
        filter = self
    }, self).StartSolid
end

--[[
    Purpose: Checks if the player is within a specified radius of another entity
    When Called: When implementing proximity-based features, interaction systems, or distance validation
    Parameters:
        radius (number) - The maximum distance to check
        entity (Entity) - The entity to check distance against
    Returns: boolean - True if player is within radius, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Check if player is near another player
    if player:isNearPlayer(100, otherPlayer) then
        print("Players are close!")
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Proximity-based interaction
    local npc = ents.FindByClass("npc_citizen")[1]
    if player:isNearPlayer(50, npc) then
        player:notify("Press E to talk to NPC")
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex proximity system with multiple entities
    local nearbyEntities = {}
    for _, ent in ipairs(ents.FindInSphere(player:GetPos(), 200)) do
        if player:isNearPlayer(100, ent) and ent:IsPlayer() then
            table.insert(nearbyEntities, ent)
        end
    end
    ```
]]
function playerMeta:isNearPlayer(radius, entity)
    local squaredRadius = radius * radius
    local squaredDistance = self:GetPos():DistToSqr(entity:GetPos())
    return squaredDistance <= squaredRadius
end

--[[
    Purpose: Gets all entities within a specified radius of the player
    When Called: When implementing area-of-effect systems, proximity detection, or entity scanning
    Parameters:
        radius (number) - The radius to search within
        playerOnly (boolean, optional) - If true, only returns player entities
    Returns: table - Array of entities within the radius
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Get all nearby entities
    local nearby = player:entitiesNearPlayer(100)
    print("Found " .. #nearby .. " entities nearby")
    ```
    Medium Complexity:
    ```lua
    -- Medium: Get only nearby players
    local nearbyPlayers = player:entitiesNearPlayer(150, true)
    for _, ply in ipairs(nearbyPlayers) do
        ply:notify("You are near " .. player:Name())
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex entity filtering and processing
    local nearby = player:entitiesNearPlayer(200, false)
    local weapons = {}
    for _, ent in ipairs(nearby) do
        if ent:IsWeapon() and ent:GetOwner() == player then
            table.insert(weapons, ent)
        end
    end
    ```
]]
function playerMeta:entitiesNearPlayer(radius, playerOnly)
    local nearbyEntities = {}
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if not playerOnly or v:IsPlayer() then table.insert(nearbyEntities, v) end
    end
    return nearbyEntities
end

--[[
    Purpose: Gets the weapon entity and corresponding item data for the player's active weapon
    When Called: When accessing weapon properties, validating equipped items, or implementing weapon systems
    Parameters: None
    Returns: weapon (Entity|nil), item (table|nil) - The weapon entity and item data if found
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Get player's active weapon item
    local weapon, item = player:getItemWeapon()
    if weapon then
        print("Player has weapon:", weapon:GetClass())
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Check weapon and modify properties
    local weapon, item = player:getItemWeapon()
    if weapon and item then
        local durability = item:getData("durability", 100)
        if durability < 50 then
            player:notify("Weapon is damaged!")
        end
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex weapon system with inventory management
    local weapon, item = player:getItemWeapon()
    if weapon and item then
        local ammo = item:getData("ammo", 0)
        local maxAmmo = item:getData("maxAmmo", 30)
        if ammo < maxAmmo * 0.1 then
            item:setData("ammo", maxAmmo)
            player:notify("Weapon reloaded!")
        end
    end
    ```
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
    Purpose: Checks if the player is currently running (moving faster than walk speed)
    When Called: When implementing movement-based features, stamina systems, or speed validation
    Parameters: None
    Returns: boolean - True if player is running, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Check if player is running
    if player:isRunning() then
        print("Player is running!")
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Running-based stamina system
    if player:isRunning() then
        local stamina = player:getData("stamina", 100)
        player:setData("stamina", math.max(0, stamina - 1))
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex movement system with effects
    if player:isRunning() then
        local speed = player:GetVelocity():Length2D()
        local maxSpeed = player:GetRunSpeed()
        local speedRatio = speed / maxSpeed
        if speedRatio > 0.8 then
            player:setNetVar("exhausted", true)
        end
    end
    ```
]]
function playerMeta:isRunning()
    return vectorMeta.Length2D(self:GetVelocity()) > self:GetWalkSpeed() + 10
end

--[[
    Purpose: Checks if the player is using a family shared Steam account
    When Called: When implementing account validation, anti-cheat systems, or account restrictions
    Parameters: None
    Returns: boolean - True if player is using family shared account, false otherwise
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Check if account is family shared
    if player:isFamilySharedAccount() then
        print("Player is using family shared account")
    end
    ```
    Medium Complexity:
    ```lua
    -- Medium: Restrict features for family shared accounts
    if player:isFamilySharedAccount() then
        player:notify("Some features are restricted for family shared accounts")
        return false
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex account validation with logging
    if player:isFamilySharedAccount() then
        local ownerID = util.SteamIDFrom64(player:OwnerSteamID64())
        lia.log.add("Family shared account detected: " .. player:SteamID() .. " (Owner: " .. ownerID .. ")")
        player:setData("isFamilyShared", true)
    end
    ```
]]
function playerMeta:isFamilySharedAccount()
    return util.SteamIDFrom64(self:OwnerSteamID64()) ~= self:SteamID()
end

--[[
    Purpose: Calculates the position where items should be dropped in front of the player
    When Called: When implementing item dropping, inventory management, or item placement systems
    Parameters: None
    Returns: Vector - The calculated drop position
    Realm: Shared
    Example Usage:
    Low Complexity:
    ```lua
    -- Simple: Get drop position for item
    local dropPos = player:getItemDropPos()
    local item = ents.Create("lia_item")
    item:SetPos(dropPos)
    ```
    Medium Complexity:
    ```lua
    -- Medium: Drop item with validation
    local dropPos = player:getItemDropPos()
    if dropPos and dropPos:Distance(player:GetPos()) < 100 then
        local item = lia.item.create("weapon_pistol", 1)
        item:spawn(dropPos)
    end
    ```
    High Complexity:
    ```lua
    -- High: Complex item dropping with physics and effects
    local dropPos = player:getItemDropPos()
    local item = lia.item.create("weapon_pistol", 1)
    item:spawn(dropPos)
    local phys = item:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(player:GetAimVector() * 100)
    end
    ```
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
    playerMeta:getParts()
    Purpose: Retrieves the player's current PAC (Player Accessory Control) parts
    When Called: When accessing player's PAC parts data
    Parameters: None
    Returns: table - Table of active PAC part IDs
    Realm: Shared
    Example Usage:
    ```lua
        -- Low: Basic part checking
        local parts = player:getParts()
        if parts["hat_001"] then
            player:notify("You have a hat equipped")
        end
    ```
    Medium Complexity:
    ```lua
        -- Medium: Part validation and management
        local parts = player:getParts()
        local partCount = 0
        for partID, _ in pairs(parts) do
            partCount = partCount + 1
        end
        if partCount > 5 then
            player:notifyWarning("You have too many accessories equipped")
        end
    ```
    High Complexity:
    ```lua
        -- High: Complex part system with validation and effects
        local parts = player:getParts()
        local validParts = {}
        local invalidParts = {}
        for partID, _ in pairs(parts) do
            if lia.pac.isValidPart(partID) then
                table.insert(validParts, partID)
            else
                table.insert(invalidParts, partID)
                player:removePart(partID)
            end
        end
        if #invalidParts > 0 then
            player:notifyError("Removed " .. #invalidParts .. " invalid parts")
        end
    ```
]]
function playerMeta:getParts()
    return self:getNetVar("parts", {})
end

if SERVER then
    --[[
        playerMeta:syncParts()
        Purpose: Synchronizes the player's PAC parts with all clients
        When Called: When player's PAC parts need to be synchronized
        Parameters: None
        Returns: None
        Realm: Server
        Example Usage:
        ```lua
        -- Low: Basic part synchronization
        player:syncParts()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Sync parts after validation
        local parts = player:getParts()
        local validParts = {}
        for partID, _ in pairs(parts) do
            if lia.pac.isValidPart(partID) then
                validParts[partID] = true
            end
        end
        player:setNetVar("parts", validParts)
        player:syncParts()
        ```
        High Complexity:
        ```lua
        -- High: Complex synchronization with logging and validation
        local parts = player:getParts()
        local syncCount = 0
        local removedParts = {}
        for partID, _ in pairs(parts) do
            if not lia.pac.isValidPart(partID) then
                table.insert(removedParts, partID)
                parts[partID] = nil
            else
                syncCount = syncCount + 1
            end
        end
        player:setNetVar("parts", parts)
        player:syncParts()
        if #removedParts > 0 then
            lia.log.add("Player " .. player:Name() .. " had " .. #removedParts .. " invalid parts removed")
        end
        ```
    ]]
    function playerMeta:syncParts()
        net.Start("liaPacSync")
        net.Send(self)
    end

    --[[
        playerMeta:addPart(partID)
        Purpose: Adds a PAC part to the player and synchronizes it with all clients
        When Called: When a player equips a new PAC accessory
        Parameters:
            - partID (string): The unique identifier of the PAC part to add
        Returns: None
        Realm: Server
        Example Usage:
        ```lua
        -- Low: Basic part addition
        player:addPart("hat_001")
        ```
        Medium Complexity:
        ```lua
        -- Medium: Part addition with validation and limits
        local parts = player:getParts()
        local partCount = 0
        for _, _ in pairs(parts) do
            partCount = partCount + 1
        end
        if partCount < 10 and lia.pac.isValidPart(partID) then
            player:addPart(partID)
            player:notifySuccess("Part equipped: " .. partID)
        else
            player:notifyError("Cannot equip more parts or invalid part ID")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex part system with permissions and effects
        local partID = "premium_hat_001"
        local char = player:getChar()
        if char and char:hasFlags("P") then
            if lia.pac.isValidPart(partID) then
                local parts = player:getParts()
                if not parts[partID] then
                    player:addPart(partID)
                    player:notifySuccess("Premium part equipped!")
                    lia.log.add("Player " .. player:Name() .. " equipped premium part: " .. partID)
                    -- Apply special effects
                    player:setData("premiumPartEquipped", true)
                    player:notifyInfo("Premium effects activated!")
                else
                    player:notifyWarning("Part already equipped")
                end
            else
                player:notifyError("Invalid part ID")
            end
        else
            player:notifyError("Insufficient permissions for this part")
        end
        ```
    ]]
    function playerMeta:addPart(partID)
        if self:getParts()[partID] then return end
        net.Start("liaPacPartAdd")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = true
        self:setNetVar("parts", parts)
    end

    --[[
        playerMeta:removePart(partID)
        Purpose: Removes a PAC part from the player and synchronizes the change with all clients
        When Called: When a player unequips a PAC accessory
        Parameters:
            - partID (string): The unique identifier of the PAC part to remove
        Returns: None
        Realm: Server
        Example Usage:
        ```lua
        -- Low: Basic part removal
        player:removePart("hat_001")
        ```
        Medium Complexity:
        ```lua
        -- Medium: Part removal with validation and cleanup
        local parts = player:getParts()
        if parts[partID] then
            player:removePart(partID)
            player:notifySuccess("Part removed: " .. partID)
            -- Clean up related data
            player:setData("part_" .. partID .. "_equipped", false)
        else
            player:notifyWarning("Part not equipped")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex part removal with effects and logging
        local partID = "premium_hat_001"
        local parts = player:getParts()
        if parts[partID] then
            player:removePart(partID)
            -- Remove special effects
            if partID:find("premium_") then
                player:setData("premiumPartEquipped", false)
                player:notifyInfo("Premium effects deactivated")
            end
            -- Log the removal
            lia.log.add("Player " .. player:Name() .. " removed part: " .. partID)
            -- Check if any premium parts remain
            local hasPremiumParts = false
            for id, _ in pairs(parts) do
                if id:find("premium_") then
                    hasPremiumParts = true
                    break
                end
            end
            if not hasPremiumParts then
                player:notifyWarning("No premium parts remaining")
            end
        else
            player:notifyError("Part not found")
        end
        ```
    ]]
    function playerMeta:removePart(partID)
        net.Start("liaPacPartRemove")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = nil
        self:setNetVar("parts", parts)
    end

    --[[
        playerMeta:resetParts()
        Purpose: Removes all PAC parts from the player and synchronizes the reset with all clients
        When Called: When a player wants to remove all accessories or during cleanup
        Parameters: None
        Returns: None
        Realm: Server
        Example Usage:
        ```lua
        -- Low: Basic parts reset
        player:resetParts()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Reset parts with validation and notification
        local parts = player:getParts()
        local partCount = 0
        for _, _ in pairs(parts) do
            partCount = partCount + 1
        end
        if partCount > 0 then
            player:resetParts()
            player:notifySuccess("All parts removed (" .. partCount .. " parts)")
        else
            player:notifyInfo("No parts to remove")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex parts reset with logging and cleanup
        local parts = player:getParts()
        local removedParts = {}
        local premiumParts = 0
        -- Count and categorize parts before removal
        for partID, _ in pairs(parts) do
            table.insert(removedParts, partID)
            if partID:find("premium_") then
                premiumParts = premiumParts + 1
            end
        end
        if #removedParts > 0 then
            player:resetParts()
            -- Clean up related data
            player:setData("premiumPartEquipped", false)
            player:setData("lastPartReset", os.time())
            -- Log the reset
            lia.log.add("Player " .. player:Name() .. " reset " .. #removedParts .. " parts (Premium: " .. premiumParts .. ")")
            -- Notify with details
            if premiumParts > 0 then
                player:notifyWarning("Reset " .. #removedParts .. " parts including " .. premiumParts .. " premium items")
            else
                player:notifySuccess("Reset " .. #removedParts .. " parts")
            end
            -- Trigger cleanup hooks
            hook.Run("OnPlayerResetParts", player, removedParts)
        else
            player:notifyInfo("No parts to reset")
        end
        ```
    ]]
    function playerMeta:resetParts()
        net.Start("liaPacPartReset")
        net.WriteEntity(self)
        net.Broadcast()
        self:setNetVar("parts", {})
    end

    --[[
    Purpose: Restores stamina to the player's character
    When Called: When implementing stamina recovery, rest systems, or character healing for the player
    Parameters:
        amount (number) - The amount of stamina to restore
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Restore stamina
        player:restoreStamina(25)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Restore stamina with notification
        local amount = 50
        player:restoreStamina(amount)
        player:notify("Stamina restored by " .. amount)
        ```
        High Complexity:
        ```lua
        -- High: Complex stamina system with effects
        local char = player:getChar()
        if char then
            local currentStamina = player:getNetVar("stamina", 100)
            local maxStamina = hook.Run("GetCharMaxStamina", char) or 100
            local restoreAmount = math.min(amount, maxStamina - currentStamina)
            player:restoreStamina(restoreAmount)
            if restoreAmount > 0 then
                player:notifySuccess("Stamina restored: " .. restoreAmount .. "/" .. maxStamina)
            end
        end
        ```
    ]]
    function playerMeta:restoreStamina(amount)
        local char = self:getChar()
        local current = self:getNetVar("stamina", char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100))
        local maxStamina = char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100)
        local value = math.Clamp(current + amount, 0, maxStamina)
        self:setNetVar("stamina", value)
        if value >= maxStamina * 0.25 and self:getNetVar("brth", false) then
            self:setNetVar("brth", nil)
            hook.Run("PlayerStaminaGained", self)
        end
    end

    --[[
    Purpose: Consumes stamina from the player's character
    When Called: When implementing stamina usage, movement costs, or action requirements for the player
    Parameters:
        amount (number) - The amount of stamina to consume
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Consume stamina
        player:consumeStamina(10)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Consume stamina with validation
        local cost = 15
        local currentStamina = player:getNetVar("stamina", 100)
        if currentStamina >= cost then
            player:consumeStamina(cost)
            player:notify("Stamina used: " .. cost)
        else
            player:notifyError("Not enough stamina!")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex stamina system with effects
        local char = player:getChar()
        if char then
            local currentStamina = player:getNetVar("stamina", 100)
            local maxStamina = hook.Run("GetCharMaxStamina", char) or 100
            local staminaRatio = currentStamina / maxStamina
            if staminaRatio < 0.25 then
                player:setNetVar("brth", true)
                hook.Run("PlayerStaminaDepleted", player)
            end
            player:consumeStamina(amount)
        end
        ```
    ]]
    function playerMeta:consumeStamina(amount)
        local char = self:getChar()
        local current = self:getNetVar("stamina", char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100))
        local value = math.Clamp(current - amount, 0, char and (hook.Run("GetCharMaxStamina", char) or lia.config.get("DefaultStamina", 100)) or lia.config.get("DefaultStamina", 100))
        self:setNetVar("stamina", value)
        if value == 0 and not self:getNetVar("brth", false) then
            self:setNetVar("brth", true)
            hook.Run("PlayerStaminaLost", self)
        end
    end

    --[[
    Purpose: Adds money to the player's character
    When Called: When implementing economic systems, rewards, or financial transactions for the player
    Parameters:
        amount (number) - The amount of money to add
    Returns: boolean - True if money was added successfully, false otherwise
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Add money to player
        player:addMoney(100)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Add money with notification
        local amount = 500
        if player:addMoney(amount) then
            player:notify("You received $" .. amount)
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex economic system with logging
        local amount = 1000
        local char = player:getChar()
        if char then
            local oldMoney = char:getMoney()
            if player:addMoney(amount) then
                local newMoney = char:getMoney()
                player:notifySuccess("Money added: $" .. amount .. " (Total: $" .. newMoney .. ")")
                lia.log.add("Player " .. player:Name() .. " received $" .. amount)
            end
        end
        ```
    ]]
    function playerMeta:addMoney(amount)
        local character = self:getChar()
        if not character then return false end
        local currentMoney = character:getMoney()
        local totalMoney = currentMoney + amount
        character:setMoney(totalMoney)
        lia.log.add(self, "money", amount)
        return true
    end

    --[[
    Purpose: Takes money from the player's character
    When Called: When implementing economic systems, penalties, or financial transactions for the player
    Parameters:
        amount (number) - The amount of money to take
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Take money from player
        player:takeMoney(50)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Take money with validation
        local cost = 100
        if player:canAfford(cost) then
            player:takeMoney(cost)
            player:notify("You paid $" .. cost)
        else
            player:notifyError("You can't afford this!")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex economic system with logging
        local amount = 200
        local char = player:getChar()
        if char then
            local oldMoney = char:getMoney()
            if oldMoney >= amount then
                player:takeMoney(amount)
                local newMoney = char:getMoney()
                player:notifyWarning("Money taken: $" .. amount .. " (Remaining: $" .. newMoney .. ")")
                lia.log.add("Player " .. player:Name() .. " lost $" .. amount)
            else
                player:notifyError("Insufficient funds!")
            end
        end
        ```
    ]]
    function playerMeta:takeMoney(amount)
        local character = self:getChar()
        if character then character:giveMoney(-amount) end
    end

    --[[
    Purpose: Loads Lilia data for the player from the database
    When Called: When initializing player data, loading saved information, or database operations for the player
    Parameters:
        callback (function, optional) - Function to call when data is loaded
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Load player data
        player:loadLiliaData()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Load data with callback
        player:loadLiliaData(function(data)
            player:notify("Data loaded with " .. table.Count(data) .. " entries")
        end)
        ```
        High Complexity:
        ```lua
        -- High: Complex data loading with validation
        player:loadLiliaData(function(data)
            if data then
                local settings = data.settings or {}
                local level = data.level or 1
                local experience = data.experience or 0
                player:notifyInfo("Welcome back! Level: " .. level .. ", XP: " .. experience)
                -- Apply saved settings
                if settings.theme then
                    player:setData("theme", settings.theme)
                end
            end
        end)
        ```
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
    Purpose: Saves Lilia data for the player to the database
    When Called: When saving player data, updating database information, or data persistence for the player
    Parameters: None
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Save player data
        player:saveLiliaData()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Save data with validation
        if player:IsValid() and not player:IsBot() then
            player:saveLiliaData()
            player:notify("Data saved successfully")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex data saving with logging
        if player:IsValid() and not player:IsBot() then
            local dataSize = table.Count(player.liaData or {})
            player:saveLiliaData()
            lia.log.add("Player " .. player:Name() .. " data saved (" .. dataSize .. " entries)")
            player:notifyInfo("Data saved with " .. dataSize .. " entries")
        end
        ```
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
    Purpose: Sets a Lilia data value for the player with optional networking and saving control
    When Called: When storing player data, implementing data management, or updating player information
    Parameters:
        key (string) - The data key to set
        value (any) - The value to store
        noNetworking (boolean, optional) - Whether to skip networking the change
        noSave (boolean, optional) - Whether to skip saving to database
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set player data
        player:setLiliaData("level", 5)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Set data with networking
        player:setLiliaData("settings", {theme = "dark"}, false, true)
        ```
        High Complexity:
        ```lua
        -- High: Complex data management with validation
        local key = "achievements"
        local value = player:getLiliaData("achievements", {})
        table.insert(value, "first_login")
        player:setLiliaData(key, value, false, false)
        player:notifySuccess("Achievement unlocked: First Login!")
        ```
    ]]
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

    --[[
    Purpose: Bans the player from the server with a reason and duration
    When Called: When implementing administrative actions, moderation systems, or player punishment for the player
    Parameters:
        reason (string, optional) - The reason for the ban (default: generic reason)
        duration (number, optional) - The duration of the ban in seconds (0 for permanent)
        banner (Player, optional) - The player who issued the ban
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Ban player
        player:banPlayer("Cheating")
        ```
        Medium Complexity:
        ```lua
        -- Medium: Ban with duration
        local duration = 86400 -- 24 hours
        player:banPlayer("Griefing", duration, admin)
        ```
        High Complexity:
        ```lua
        -- High: Complex ban system with logging
        local reason = "Multiple violations"
        local duration = 604800 -- 7 days
        local banner = admin
        player:banPlayer(reason, duration, banner)
        lia.log.add("Player " .. player:Name() .. " banned by " .. banner:Name() .. " for: " .. reason)
        ```
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
    Purpose: Sets an action for the player with optional duration and callback
    When Called: When implementing player actions, progress bars, or timed activities for the player
    Parameters:
        text (string) - The action text to display
        time (number, optional) - The duration of the action in seconds
        callback (function, optional) - Function to call when action completes
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set action
        player:setAction("Loading...")
        ```
        Medium Complexity:
        ```lua
        -- Medium: Set action with duration
        player:setAction("Crafting item...", 5)
        ```
        High Complexity:
        ```lua
        -- High: Complex action system with callback
        local actionText = "Repairing weapon..."
        local duration = 10
        local callback = function(ply)
            ply:notifySuccess("Weapon repaired!")
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) then
                weapon:SetHealth(100)
            end
        end
        player:setAction(actionText, duration, callback)
        ```
    ]]
    function playerMeta:setAction(text, time, callback)
        if time and time <= 0 then
            if callback then callback(self) end
            return
        end

        time = time or 5
        if not text then
            timer.Remove("liaAct" .. self:SteamID64())
            net.Start("liaActBar")
            net.WriteBool(false)
            net.Send(self)
            return
        end

        net.Start("liaActBar")
        net.WriteBool(true)
        net.WriteString(text)
        net.WriteFloat(time)
        net.Send(self)
        if callback then timer.Create("liaAct" .. self:SteamID64(), time, 1, function() if IsValid(self) then callback(self) end end) end
    end

    --[[
    Purpose: Makes the player perform an action by staring at an entity for a specified duration
    When Called: When implementing interaction systems, examination mechanics, or focused actions for the player
    Parameters:
        entity (Entity) - The entity to stare at
        callback (function) - Function to call when action completes
        time (number) - The duration to stare at the entity
        onCancel (function, optional) - Function to call if action is cancelled
        distance (number, optional) - Maximum distance to check (default: 96)
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Stare at entity
        player:doStaredAction(ent, function() print("Action completed") end, 3)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Stare with cancellation
        local onCancel = function() player:notify("Action cancelled") end
        player:doStaredAction(ent, function() player:notify("Action completed") end, 5, onCancel)
        ```
        High Complexity:
        ```lua
        -- High: Complex interaction system with validation
        local entity = player:getTracedEntity()
        if IsValid(entity) then
            local callback = function()
                player:notifySuccess("Examination complete!")
                local data = entity:getData("examinationData", {})
                player:notifyInfo("Entity data: " .. table.Count(data) .. " entries")
            end
            local onCancel = function()
                player:notifyWarning("Examination interrupted")
            end
            player:doStaredAction(entity, callback, 10, onCancel, 150)
        end
        ```
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
    Purpose: Stops the player's current action and clears action timers
    When Called: When interrupting player actions, implementing action cancellation, or cleaning up player state
    Parameters: None
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Stop player action
        player:stopAction()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Stop action with notification
        player:stopAction()
        player:notify("Action stopped")
        ```
        High Complexity:
        ```lua
        -- High: Complex action management with cleanup
        if player:getNetVar("actionActive", false) then
            player:stopAction()
            player:setNetVar("actionActive", false)
            player:notifyWarning("Action interrupted")
            -- Clean up any action-related data
            player:setData("actionProgress", 0)
        end
        ```
    ]]
    function playerMeta:stopAction()
        timer.Remove("liaAct" .. self:SteamID64())
        timer.Remove("liaStare" .. self:SteamID64())
        net.Start("liaActBar")
        net.Send(self)
    end

    --[[
    Purpose: Gets the player's total play time in seconds
    When Called: When calculating play time, implementing time-based features, or displaying player statistics
    Parameters: None
    Returns: number - The player's total play time in seconds
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player play time
        local playTime = player:getPlayTime()
        print("Play time:", playTime)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Display play time in hours
        local playTime = player:getPlayTime()
        local hours = math.floor(playTime / 3600)
        player:notify("You have played for " .. hours .. " hours")
        ```
        High Complexity:
        ```lua
        -- High: Complex play time system with rewards
        local playTime = player:getPlayTime()
        local hours = math.floor(playTime / 3600)
        local days = math.floor(hours / 24)
        if days >= 7 then
            player:notifySuccess("Veteran player! " .. days .. " days played")
            player:giveFlags("v")
        elseif hours >= 24 then
            player:notifyInfo("Experienced player! " .. hours .. " hours played")
        end
        ```
    ]]
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

    --[[
    Purpose: Gets the player's current session time in seconds
    When Called: When calculating session duration, implementing session-based features, or displaying current session statistics
    Parameters: None
    Returns: number - The player's current session time in seconds
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get session time
        local sessionTime = player:getSessionTime()
        print("Session time:", sessionTime)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Display session time in minutes
        local sessionTime = player:getSessionTime()
        local minutes = math.floor(sessionTime / 60)
        player:notify("You have been online for " .. minutes .. " minutes")
        ```
        High Complexity:
        ```lua
        -- High: Complex session system with rewards
        local sessionTime = player:getSessionTime()
        local hours = math.floor(sessionTime / 3600)
        if hours >= 2 then
            player:notifySuccess("Long session! " .. hours .. " hours online")
            -- Give session bonus
            player:addMoney(100 * hours)
        end
        ```
    ]]
    function playerMeta:getSessionTime()
        return RealTime() - (self.liaJoinTime or RealTime())
    end

    --[[
    Purpose: Creates a ragdoll entity for the player with their current appearance and state
    When Called: When implementing death systems, ragdoll creation, or player state changes
    Parameters:
        freeze (boolean, optional) - Whether to freeze the ragdoll
        isDead (boolean, optional) - Whether the player is dead (affects ragdoll storage)
    Returns: Entity - The created ragdoll entity
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Create ragdoll
        local ragdoll = player:createRagdoll()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Create ragdoll for death
        local ragdoll = player:createRagdoll(false, true)
        player:notify("Ragdoll created")
        ```
        High Complexity:
        ```lua
        -- High: Complex ragdoll system with effects
        local ragdoll = player:createRagdoll(false, true)
        if IsValid(ragdoll) then
            ragdoll:setNetVar("player", player)
            ragdoll:setNetVar("deathTime", os.time())
            -- Apply death effects
            if player:IsOnFire() then
                ragdoll:Ignite(8)
            end
            hook.Run("OnPlayerRagdollCreated", player, ragdoll)
        end
        ```
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
        if self:IsOnFire() then entity:Ignite(8) end
        if isDead then self:setNetVar("ragdoll", entity) end
        local handsWeapon = self:GetActiveWeapon()
        if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
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
    Purpose: Sets the player's ragdoll state (knocked down or standing up)
    When Called: When implementing knockdown systems, unconsciousness, or player state management
    Parameters:
        state (boolean) - Whether to ragdoll the player (true) or stand them up (false)
        baseTime (number, optional) - Base time for ragdoll duration (default: 10)
        getUpGrace (number, optional) - Grace period for getting up
        getUpMessage (string, optional) - Message to display when getting up (default: "Waking up")
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Ragdoll player
        player:setRagdolled(true)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Ragdoll with custom time
        player:setRagdolled(true, 15, 5, "Getting up...")
        ```
        High Complexity:
        ```lua
        -- High: Complex ragdoll system with effects
        local state = true
        local duration = 20
        local grace = 10
        local message = "Recovering from injury..."
        player:setRagdolled(state, duration, grace, message)
        player:notifyWarning("You are unconscious for " .. duration .. " seconds")
        ```
    ]]
    function playerMeta:setRagdolled(state, baseTime, getUpGrace, getUpMessage)
        getUpMessage = getUpMessage or L("wakingUp")
        local ragdoll = self:getNetVar("ragdoll")
        local time = hook.Run("GetRagdollTime", self, time) or baseTime or 10
        if state then
            self.liaStoredHealth = self:Health()
            self.liaStoredMaxHealth = self:GetMaxHealth()
            local handsWeapon = self:GetActiveWeapon()
            if IsValid(handsWeapon) and handsWeapon:GetClass() == "lia_hands" and handsWeapon:IsHoldingObject() then handsWeapon:DropObject() end
            if IsValid(ragdoll) then SafeRemoveEntity(ragdoll) end
            local entity = self:createRagdoll()
            entity:setNetVar("player", self)
            entity:CallOnRemove("fixer", function()
                if IsValid(self) then
                    self:setNetVar("blur", nil)
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

            self:setNetVar("blur", 25)
            self:setNetVar("ragdoll", entity)
            entity.liaWeapons = {}
            entity.liaAmmo = {}
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

            if IsValid(entity) then
                entity:SetCollisionGroup(COLLISION_GROUP_NONE)
                entity:SetCustomCollisionCheck(false)
            end
        elseif IsValid(self:getNetVar("ragdoll")) then
            SafeRemoveEntity(self:getNetVar("ragdoll"))
            hook.Run("OnCharFallover", self, nil, false)
        end
    end

    --[[
    Purpose: Synchronizes network variables to the player client
    When Called: When initializing player connection, updating network state, or ensuring client-server synchronization
    Parameters: None
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Sync variables to player
        player:syncVars()
        ```
        Medium Complexity:
        ```lua
        -- Medium: Sync variables with validation
        if player:IsValid() and player:IsConnected() then
            player:syncVars()
            player:notify("Variables synchronized")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex synchronization with logging
        local varCount = 0
        for entity, data in pairs(lia.net) do
            if entity == "globals" then
                varCount = varCount + table.Count(data)
            elseif IsValid(entity) then
                varCount = varCount + table.Count(data)
            end
        end
        player:syncVars()
        lia.log.add("Synced " .. varCount .. " variables to " .. player:Name())
        ```
    ]]
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
    end

    --[[
    Purpose: Sets a network variable for the player that synchronizes to the client
    When Called: When updating player state, implementing networked properties, or client-server communication
    Parameters:
        key (string) - The network variable key
        value (any) - The value to set
    Returns: None
    Realm: Server (only called on server side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set network variable
        player:setNetVar("health", 100)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Set network variable with validation
        local health = math.Clamp(newHealth, 0, 100)
        player:setNetVar("health", health)
        player:notify("Health updated to " .. health)
        ```
        High Complexity:
        ```lua
        -- High: Complex network variable system with hooks
        local oldValue = player:getNetVar("level", 1)
        local newValue = oldValue + 1
        player:setNetVar("level", newValue)
        hook.Run("OnPlayerLevelUp", player, oldValue, newValue)
        player:notifySuccess("Level up! " .. oldValue .. " → " .. newValue)
        ```
    ]]
    function playerMeta:setNetVar(key, value)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        lia.net[self][key] = value
        net.Start("liaNetLocal")
        net.WriteString(key)
        net.WriteType(value)
        net.Send(self)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end
else
    --[[
    Purpose: Checks if the player can override their view (third person mode)
    When Called: When implementing camera systems, view controls, or third person functionality for the player
    Parameters: None
    Returns: boolean - True if player can override view, false otherwise
    Realm: Client (only called on client side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player can override view
        if player:canOverrideView() then
            print("Player can use third person")
        end
        ```
        Medium Complexity:
        ```lua
        -- Medium: Conditional view override
        if player:canOverrideView() then
            player:notify("Third person mode available")
        else
            player:notify("Third person mode disabled")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex view system with validation
        if player:canOverrideView() then
            local ragdoll = player:getNetVar("ragdoll")
            local inVehicle = IsValid(player:GetVehicle())
            if not IsValid(ragdoll) and not inVehicle then
                player:notifyInfo("Third person mode enabled")
                -- Enable third person camera
                player:setData("thirdPerson", true)
            end
        end
        ```
    ]]
    function playerMeta:canOverrideView()
        local ragdoll = self:getNetVar("ragdoll")
        local isInVehicle = IsValid(self:GetVehicle())
        if IsValid(lia.gui.char) then return false end
        if isInVehicle then return false end
        if hook.Run("ShouldDisableThirdperson", self) == true then return false end
        return lia.option.get("thirdPersonEnabled", false) and lia.config.get("ThirdPersonEnabled", true) and IsValid(self) and self:getChar() and not IsValid(ragdoll)
    end

    --[[
    Purpose: Checks if the player is currently in third person mode
    When Called: When implementing camera systems, view controls, or third person functionality for the player
    Parameters: None
    Returns: boolean - True if player is in third person mode, false otherwise
    Realm: Client (only called on client side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player is in third person
        if player:isInThirdPerson() then
            print("Player is in third person mode")
        end
        ```
        Medium Complexity:
        ```lua
        -- Medium: Conditional third person handling
        if player:isInThirdPerson() then
            player:notify("Third person mode active")
        else
            player:notify("First person mode active")
        end
        ```
        High Complexity:
        ```lua
        -- High: Complex camera system with effects
        if player:isInThirdPerson() then
            local distance = lia.option.get("thirdPersonDistance", 100)
            local angle = lia.option.get("thirdPersonAngle", 0)
            -- Apply third person camera effects
            player:setData("cameraDistance", distance)
            player:setData("cameraAngle", angle)
        end
        ```
    ]]
    function playerMeta:isInThirdPerson()
        local thirdPersonEnabled = lia.config.get("ThirdPersonEnabled", true)
        local tpEnabled = lia.option.get("thirdPersonEnabled", false)
        return tpEnabled and thirdPersonEnabled
    end

    --[[
    Purpose: Gets the player's total play time in seconds (client-side version)
    When Called: When calculating play time, implementing time-based features, or displaying player statistics
    Parameters: None
    Returns: number - The player's total play time in seconds
    Realm: Client (only called on client side)
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player play time
        local playTime = player:getPlayTime()
        print("Play time:", playTime)
        ```
        Medium Complexity:
        ```lua
        -- Medium: Display play time in hours
        local playTime = player:getPlayTime()
        local hours = math.floor(playTime / 3600)
        player:notify("You have played for " .. hours .. " hours")
        ```
        High Complexity:
        ```lua
        -- High: Complex play time system with rewards
        local playTime = player:getPlayTime()
        local hours = math.floor(playTime / 3600)
        local days = math.floor(hours / 24)
        if days >= 7 then
            player:notifySuccess("Veteran player! " .. days .. " days played")
        elseif hours >= 24 then
            player:notifyInfo("Experienced player! " .. hours .. " hours played")
        end
        ```
    ]]
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
