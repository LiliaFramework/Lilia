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
    Purpose: Gets all items from the player's character inventory
    When Called: When accessing player inventory, implementing item systems, or inventory management
    Parameters: None
    Returns: table|nil - Array of items in the player's inventory, nil if no character
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player's items
        local items = player:getItems()
        if items then
            print("Player has " .. #items .. " items")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Search for specific items
        local items = player:getItems()
        if items then
            for _, item in ipairs(items) do
                if item.uniqueID == "weapon_pistol" then
                    print("Player has a pistol!")
                end
            end
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex inventory analysis and management
        local items = player:getItems()
        if items then
            local weaponCount = 0
            local totalValue = 0
            for _, item in ipairs(items) do
                if item.isWeapon then
                    weaponCount = weaponCount + 1
                end
                totalValue = totalValue + (item:getData("value", 0))
            end
            player:notify("Weapons: " .. weaponCount .. ", Total Value: $" .. totalValue)
        end
        ```
]]
function playerMeta:getItems()
    local character = self:getChar()
    if character then
        local inv = character:getInv()
        if inv then return inv:getItems() end
    end
end

--[[
    Purpose: Gets the entity that the player is looking at within a specified distance
    When Called: When implementing interaction systems, targeting, or line-of-sight detection
    Parameters:
        distance (number, optional) - Maximum trace distance (default: 96)
    Returns: Entity|nil - The traced entity if found, nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get what player is looking at
        local ent = player:getTracedEntity()
        if IsValid(ent) then
            print("Player is looking at:", ent:GetClass())
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Interaction with traced entity
        local ent = player:getTracedEntity(150)
        if IsValid(ent) and ent:IsPlayer() then
            player:notify("Looking at player: " .. ent:Name())
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex interaction system with validation
        local ent = player:getTracedEntity(200)
        if IsValid(ent) then
            local distance = player:GetPos():Distance(ent:GetPos())
            if distance < 100 and ent:GetClass() == "lia_item" then
                local item = ent:getItem()
                if item then
                    player:notify("Item: " .. item:getName() .. " (Value: $" .. item:getData("value", 0) .. ")")
                end
            end
        end
        ```
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
    Purpose: Performs a hull trace from the player's position to detect collisions and surfaces
    When Called: When implementing collision detection, surface analysis, or spatial queries
    Parameters:
        distance (number, optional) - Maximum trace distance (default: 200)
    Returns: table - Trace result containing hit information, position, and entity data
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check what's in front of player
        local trace = player:getTrace()
        if trace.Hit then
            print("Hit something at:", trace.HitPos)
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Surface detection and interaction
        local trace = player:getTrace(150)
        if trace.Hit and trace.HitWorld then
            player:notify("Looking at world surface")
        elseif trace.Hit and IsValid(trace.Entity) then
            player:notify("Looking at: " .. trace.Entity:GetClass())
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex spatial analysis with physics
        local trace = player:getTrace(300)
        if trace.Hit then
            local hitPos = trace.HitPos
            local hitNormal = trace.HitNormal
            local distance = trace.Fraction * 300
            if IsValid(trace.Entity) then
                local phys = trace.Entity:GetPhysicsObject()
                if IsValid(phys) then
                    phys:ApplyForceCenter(hitNormal * 1000)
                end
            end
        end
        ```
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
    Purpose: Gets the entity that the player is looking at within a specified distance using eye trace
    When Called: When implementing precise targeting, interaction systems, or line-of-sight detection
    Parameters:
        distance (number, optional) - Maximum distance to check (default: 150)
    Returns: Entity|nil - The entity if within distance, nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get entity player is looking at
        local ent = player:getEyeEnt()
        if IsValid(ent) then
            print("Looking at:", ent:GetClass())
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Distance-based interaction
        local ent = player:getEyeEnt(100)
        if IsValid(ent) and ent:IsPlayer() then
            player:notify("Looking at player: " .. ent:Name())
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex targeting system with validation
        local ent = player:getEyeEnt(200)
        if IsValid(ent) then
            local distance = ent:GetPos():Distance(player:GetPos())
            if distance <= 150 and ent:GetClass() == "lia_item" then
                local item = ent:getItem()
                if item and item:getData("interactable", true) then
                    player:notify("Press E to interact with " .. item:getName())
                end
            end
        end
        ```
]]
function playerMeta:getEyeEnt(distance)
    distance = distance or 150
    local e = self:GetEyeTrace().Entity
    return e:GetPos():Distance(self:GetPos()) <= distance and e or nil
end

--[[
    Purpose: Sends a notification message to the player
    When Called: When displaying messages, alerts, or status updates to the player
    Parameters:
        message (string) - The message to display
        notifType (string, optional) - The type of notification (default: "default")
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send basic notification
        player:notify("Hello, player!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send typed notification
        player:notify("You found a weapon!", "success")
        player:notify("Health is low!", "warning")
        ```

        High Complexity:
        ```lua
        -- High: Complex notification system with conditions
        local health = player:Health()
        if health < 25 then
            player:notify("Critical health! Seek medical attention!", "error")
        elseif health < 50 then
            player:notify("Health is low", "warning")
        else
            player:notify("Health is good", "success")
        end
        ```
]]
function playerMeta:notify(message, notifType)
    if SERVER then
        lia.notices.notify(self, message, notifType or "default")
    else
        lia.notices.notify(nil, message, notifType or "default")
    end
end

--[[
    Purpose: Sends a localized notification message to the player with string formatting
    When Called: When displaying translated messages, alerts, or status updates to the player
    Parameters:
        message (string) - The localization key for the message
        notifType (string, optional) - The type of notification (default: "default")
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized notification
        player:notifyLocalized("welcome_message")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized notification with formatting
        player:notifySuccessLocalized("item_found")
        player:notifyWarningLocalized("health_low")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized notification system
        local itemName = item:getName()
        local itemValue = item:getData("value", 0)
        local currency = lia.currency.get("money")
        player:notifySuccessLocalized("item_sold")
        ```
]]
function playerMeta:notifyLocalized(message, notifType, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, message, notifType or "default", ...)
    else
        lia.notices.notifyLocalized(nil, message, notifType or "default", ...)
    end
end

--[[
    Purpose: Sends an error notification message to the player
    When Called: When displaying error messages, failures, or critical alerts to the player
    Parameters:
        message (string) - The error message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send error notification
        player:notifyError("Something went wrong!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send error with context
        if not player:hasPrivilege("admin") then
            player:notifyError("You don't have permission to do that!")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex error handling with logging
        local success, err = pcall(function()
            -- Some risky operation
            player:SetHealth(100)
        end)
        if not success then
            player:notifyError("Failed to heal player: " .. tostring(err))
            lia.log.add("Heal error for " .. player:Name() .. ": " .. tostring(err))
        end
        ```
]]
function playerMeta:notifyError(message)
    if SERVER then
        lia.notices.notify(self, message, "error")
    else
        lia.notices.notify(nil, message, "error")
    end
end

--[[
    Purpose: Sends a warning notification message to the player
    When Called: When displaying warning messages, cautions, or important alerts to the player
    Parameters:
        message (string) - The warning message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send warning notification
        player:notifyWarning("Be careful!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send warning with condition
        if player:Health() < 25 then
            player:notifyWarning("Health is critically low!")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex warning system with multiple conditions
        local health = player:Health()
        local armor = player:Armor()
        if health < 50 and armor < 25 then
            player:notifyWarning("You are vulnerable! Health: " .. health .. ", Armor: " .. armor)
        elseif health < 25 then
            player:notifyWarning("Critical health! Seek medical attention immediately!")
        end
        ```
]]
function playerMeta:notifyWarning(message)
    if SERVER then
        lia.notices.notify(self, message, "warning")
    else
        lia.notices.notify(nil, message, "warning")
    end
end

--[[
    Purpose: Sends an informational notification message to the player
    When Called: When displaying informational messages, tips, or general updates to the player
    Parameters:
        message (string) - The informational message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send info notification
        player:notifyInfo("Welcome to the server!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send info with context
        player:notifyInfo("You have " .. player:GetAmmoCount("Pistol") .. " pistol rounds")
        ```

        High Complexity:
        ```lua
        -- High: Complex info system with data
        local char = player:getChar()
        if char then
            local money = char:getData("money", 0)
            local level = char:getData("level", 1)
            player:notifyInfo("Level " .. level .. " | Money: $" .. money)
        end
        ```
]]
function playerMeta:notifyInfo(message)
    if SERVER then
        lia.notices.notify(self, message, "info")
    else
        lia.notices.notify(nil, message, "info")
    end
end

--[[
    Purpose: Sends a success notification message to the player
    When Called: When displaying success messages, achievements, or positive feedback to the player
    Parameters:
        message (string) - The success message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send success notification
        player:notifySuccess("Task completed!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send success with context
        player:notifySuccess("You earned $" .. amount .. "!")
        ```

        High Complexity:
        ```lua
        -- High: Complex success system with rewards
        local char = player:getChar()
        if char then
            local exp = char:getData("experience", 0)
            local newExp = exp + 100
            char:setData("experience", newExp)
            player:notifySuccess("Gained 100 XP! Total: " .. newExp)
        end
        ```
]]
function playerMeta:notifySuccess(message)
    if SERVER then
        lia.notices.notify(self, message, "success")
    else
        lia.notices.notify(nil, message, "success")
    end
end

--[[
    Purpose: Sends a money-related notification message to the player
    When Called: When displaying financial transactions, currency changes, or economic updates to the player
    Parameters:
        message (string) - The money-related message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send money notification
        player:notifyMoney("You received $100!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send money notification with context
        local amount = 500
        player:notifyMoney("Payment received: $" .. amount)
        ```

        High Complexity:
        ```lua
        -- High: Complex money system with character data
        local char = player:getChar()
        if char then
            local oldMoney = char:getData("money", 0)
            local newMoney = oldMoney + amount
            char:setData("money", newMoney)
            player:notifyMoney("Balance updated: $" .. oldMoney .. " → $" .. newMoney)
        end
        ```
]]
function playerMeta:notifyMoney(message)
    if SERVER then
        lia.notices.notify(self, message, "money")
    else
        lia.notices.notify(nil, message, "money")
    end
end

--[[
    Purpose: Sends an admin notification message to the player
    When Called: When displaying administrative messages, system alerts, or admin-specific information to the player
    Parameters:
        message (string) - The admin message to display
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send admin notification
        player:notifyAdmin("Admin command executed!")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send admin notification with context
        player:notifyAdmin("Player " .. target:Name() .. " has been banned")
        ```

        High Complexity:
        ```lua
        -- High: Complex admin system with logging
        local adminName = player:Name()
        local targetName = target:Name()
        local reason = "Cheating"
        player:notifyAdmin("Banned " .. targetName .. " for: " .. reason)
        lia.log.add("Admin " .. adminName .. " banned " .. targetName .. " for: " .. reason)
        ```
]]
function playerMeta:notifyAdmin(message)
    if SERVER then
        lia.notices.notify(self, message, "admin")
    else
        lia.notices.notify(nil, message, "admin")
    end
end

--[[
    Purpose: Sends a localized error notification message to the player with string formatting
    When Called: When displaying translated error messages, failures, or critical alerts to the player
    Parameters:
        key (string) - The localization key for the error message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized error notification
        player:notifyErrorLocalized("error_generic")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized error with formatting
        player:notifyErrorLocalized("error_permission_denied")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized error system with context
        local char = player:getChar()
        if not char then
            player:notifyErrorLocalized("error_no_character")
        else
            local money = char:getData("money", 0)
            local required = 1000
            if money < required then
                player:notifyErrorLocalized("error_insufficient_funds")
            end
        end
        ```
]]
function playerMeta:notifyErrorLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "error", ...)
    else
        lia.notices.notifyLocalized(nil, key, "error", ...)
    end
end

--[[
    Purpose: Sends a localized warning notification message to the player with string formatting
    When Called: When displaying translated warning messages, cautions, or important alerts to the player
    Parameters:
        key (string) - The localization key for the warning message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized warning notification
        player:notifyWarningLocalized("warning_generic")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized warning with formatting
        player:notifyWarningLocalized("warning_health_low")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized warning system with conditions
        local char = player:getChar()
        if char then
            local health = player:Health()
            local armor = player:Armor()
            if health < 25 then
                player:notifyWarningLocalized("warning_critical_health")
            elseif health < 50 and armor < 25 then
                player:notifyWarningLocalized("warning_vulnerable")
            end
        end
        ```
]]
function playerMeta:notifyWarningLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "warning", ...)
    else
        lia.notices.notifyLocalized(nil, key, "warning", ...)
    end
end

--[[
    Purpose: Sends a localized informational notification message to the player with string formatting
    When Called: When displaying translated informational messages, tips, or general updates to the player
    Parameters:
        key (string) - The localization key for the informational message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized info notification
        player:notifyInfoLocalized("info_welcome")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized info with formatting
        player:notifyInfoLocalized("info_ammo_count")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized info system with character data
        local char = player:getChar()
        if char then
            local money = char:getData("money", 0)
            local level = char:getData("level", 1)
            player:notifyInfoLocalized("info_character_stats")
        end
        ```
]]
function playerMeta:notifyInfoLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "info", ...)
    else
        lia.notices.notifyLocalized(nil, key, "info", ...)
    end
end

--[[
    Purpose: Sends a localized success notification message to the player with string formatting
    When Called: When displaying translated success messages, achievements, or positive feedback to the player
    Parameters:
        key (string) - The localization key for the success message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized success notification
        player:notifySuccessLocalized("success_task_completed")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized success with formatting
        player:notifySuccessLocalized("success_money_earned")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized success system with rewards
        local char = player:getChar()
        if char then
            local exp = char:getData("experience", 0)
            local newExp = exp + 100
            char:setData("experience", newExp)
            player:notifySuccessLocalized("success_experience_gained")
        end
        ```
]]
function playerMeta:notifySuccessLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "success", ...)
    else
        lia.notices.notifyLocalized(nil, key, "success", ...)
    end
end

--[[
    Purpose: Sends a localized money-related notification message to the player with string formatting
    When Called: When displaying translated financial transactions, currency changes, or economic updates to the player
    Parameters:
        key (string) - The localization key for the money-related message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized money notification
        player:notifyMoneyLocalized("money_received")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized money notification with formatting
        player:notifyMoneyLocalized("money_payment_received")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized money system with character data
        local char = player:getChar()
        if char then
            local oldMoney = char:getData("money", 0)
            local newMoney = oldMoney + amount
            char:setData("money", newMoney)
            player:notifyMoneyLocalized("money_balance_updated")
        end
        ```
]]
function playerMeta:notifyMoneyLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "money", ...)
    else
        lia.notices.notifyLocalized(nil, key, "money", ...)
    end
end

--[[
    Purpose: Sends a localized admin notification message to the player with string formatting
    When Called: When displaying translated administrative messages, system alerts, or admin-specific information to the player
    Parameters:
        key (string) - The localization key for the admin message
        ... (vararg) - Arguments to format into the localized string
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Send localized admin notification
        player:notifyAdminLocalized("admin_command_executed")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Send localized admin notification with formatting
        player:notifyAdminLocalized("admin_player_banned")
        ```

        High Complexity:
        ```lua
        -- High: Complex localized admin system with logging
        local adminName = player:Name()
        local targetName = target:Name()
        local reason = "Cheating"
        player:notifyAdminLocalized("admin_ban_executed")
        lia.log.add("Admin " .. adminName .. " banned " .. targetName .. " for: " .. reason)
        ```
]]
function playerMeta:notifyAdminLocalized(key, ...)
    if SERVER then
        lia.notices.notifyLocalized(self, key, "admin", ...)
    else
        lia.notices.notifyLocalized(nil, key, "admin", ...)
    end
end

--[[
    Purpose: Checks if the player can edit a specific vendor entity
    When Called: When validating vendor editing permissions, implementing vendor management systems, or access control
    Parameters:
        vendor (Entity) - The vendor entity to check edit permissions for
    Returns: boolean - True if player can edit the vendor, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player can edit vendor
        if player:canEditVendor(vendor) then
            print("Player can edit this vendor")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Conditional vendor editing with feedback
        if player:canEditVendor(vendor) then
            player:notify("You can edit this vendor")
        else
            player:notifyError("You don't have permission to edit this vendor")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex vendor system with logging and validation
        if player:canEditVendor(vendor) then
            local vendorData = vendor:getData("vendorData", {})
            if vendorData.owner == player:SteamID() or player:hasPrivilege("admin") then
                -- Allow editing
                player:notifySuccess("Vendor edit access granted")
            else
                player:notifyError("You don't own this vendor")
            end
        end
        ```
]]
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

--[[
    Purpose: Checks if the player is a staff member based on their user group
    When Called: When validating staff permissions, implementing staff-only features, or access control systems
    Parameters: None
    Returns: boolean - True if player is staff, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player is staff
        if player:isStaff() then
            print("Player is staff")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Staff-only feature access
        if player:isStaff() then
            player:notify("Welcome, staff member!")
        else
            player:notifyError("This feature is for staff only")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex staff system with different levels
        if player:isStaff() then
            local userGroup = player:GetUserGroup()
            if userGroup == "superadmin" then
                player:notify("Full admin access granted")
            elseif userGroup == "admin" then
                player:notify("Admin access granted")
            else
                player:notify("Staff access granted")
            end
        end
        ```
]]
function playerMeta:isStaff()
    return groupHasType(self:GetUserGroup(), "Staff")
end

--[[
    Purpose: Checks if the player is a VIP member based on their user group
    When Called: When validating VIP permissions, implementing VIP-only features, or access control systems
    Parameters: None
    Returns: boolean - True if player is VIP, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player is VIP
        if player:isVIP() then
            print("Player is VIP")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: VIP-only feature access
        if player:isVIP() then
            player:notify("Welcome, VIP member!")
        else
            player:notifyError("This feature is for VIP members only")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex VIP system with benefits
        if player:isVIP() then
            local char = player:getChar()
            if char then
                local money = char:getData("money", 0)
                local vipBonus = money * 0.1
                char:setData("money", money + vipBonus)
                player:notifySuccess("VIP bonus: +$" .. vipBonus)
            end
        end
        ```
]]
function playerMeta:isVIP()
    return groupHasType(self:GetUserGroup(), "VIP")
end

--[[
    Purpose: Checks if the player is currently on duty as staff (in staff faction)
    When Called: When validating active staff status, implementing duty-based features, or staff management systems
    Parameters: None
    Returns: boolean - True if player is on duty as staff, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player is on duty
        if player:isStaffOnDuty() then
            print("Player is on duty as staff")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Duty-based feature access
        if player:isStaffOnDuty() then
            player:notify("Staff tools available")
        else
            player:notifyError("You must be on duty to use this")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex duty system with logging and management
        if player:isStaffOnDuty() then
            local dutyTime = player:getData("dutyStartTime", 0)
            local currentTime = os.time()
            local dutyDuration = currentTime - dutyTime
            player:notifyInfo("On duty for " .. math.floor(dutyDuration / 60) .. " minutes")
        else
            player:notify("You are not currently on duty")
        end
        ```
]]
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

--[[
    Purpose: Checks if the player has whitelist access to a specific faction
    When Called: When validating faction access, implementing whitelist systems, or character creation restrictions
    Parameters:
        faction (string) - The faction unique ID to check whitelist for
    Returns: boolean - True if player has whitelist access, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player has whitelist
        if player:hasWhitelist("police") then
            print("Player can join police faction")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Faction selection with whitelist check
        if player:hasWhitelist("police") then
            player:notify("You can join the police faction")
        else
            player:notifyError("You don't have whitelist for police faction")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex whitelist system with multiple checks
        local faction = "police"
        if player:hasWhitelist(faction) then
            local factionData = lia.faction.indices[faction]
            if factionData and not factionData.isDefault then
                player:notifySuccess("Whitelist access granted for " .. factionData.name)
            end
        else
            player:notifyError("Whitelist required for " .. faction)
        end
        ```
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
    Purpose: Gets the class data for the player's current character class
    When Called: When accessing character class information, implementing class-based features, or character management
    Parameters: None
    Returns: table|nil - The class data table if character has a class, nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player's class data
        local classData = player:getClassData()
        if classData then
            print("Player class:", classData.name)
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use class data for features
        local classData = player:getClassData()
        if classData then
            player:notify("Class: " .. classData.name .. " - " .. classData.description)
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex class system with abilities and restrictions
        local classData = player:getClassData()
        if classData then
            local abilities = classData.abilities or {}
            local restrictions = classData.restrictions or {}
            player:notifyInfo("Class: " .. classData.name)
            if #abilities > 0 then
                player:notifyInfo("Abilities: " .. table.concat(abilities, ", "))
            end
        end
        ```
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
    Purpose: Gets DarkRP-compatible variable values for the player (currently only supports money)
    When Called: When implementing DarkRP compatibility, accessing player money, or legacy system integration
    Parameters:
        var (string) - The variable name to get (currently only "money" is supported)
    Returns: number|nil - The money amount if var is "money", nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player money via DarkRP compatibility
        local money = player:getDarkRPVar("money")
        if money then
            print("Player has $" .. money)
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Use DarkRP var for compatibility
        local money = player:getDarkRPVar("money")
        if money and money > 1000 then
            player:notify("You have enough money for this purchase")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex DarkRP compatibility system
        local var = "money"
        local value = player:getDarkRPVar(var)
        if value then
            local char = player:getChar()
            if char then
                local actualMoney = char:getMoney()
                if value == actualMoney then
                    player:notifyInfo("DarkRP compatibility: $" .. value)
                end
            end
        end
        ```
]]
function playerMeta:getDarkRPVar(var)
    if var ~= "money" then return end
    local char = self:getChar()
    return char:getMoney()
end

--[[
    Purpose: Gets the player's current money amount from their character
    When Called: When accessing player money, implementing economic systems, or financial transactions
    Parameters: None
    Returns: number - The player's money amount (0 if no character)
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player money
        local money = player:getMoney()
        print("Player has $" .. money)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check if player can afford something
        local cost = 1000
        local money = player:getMoney()
        if money >= cost then
            player:notify("You can afford this purchase!")
        else
            player:notifyError("You need $" .. (cost - money) .. " more")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex economic system with multiple currencies
        local money = player:getMoney()
        local char = player:getChar()
        if char then
            local bankMoney = char:getData("bankMoney", 0)
            local totalWealth = money + bankMoney
            player:notifyInfo("Cash: $" .. money .. " | Bank: $" .. bankMoney .. " | Total: $" .. totalWealth)
        end
        ```
]]
function playerMeta:getMoney()
    local character = self:getChar()
    return character and character:getMoney() or 0
end

--[[
    Purpose: Checks if the player can afford a specific amount of money
    When Called: When validating purchases, implementing economic systems, or checking financial capacity
    Parameters:
        amount (number) - The amount of money to check if player can afford
    Returns: boolean - True if player can afford the amount, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player can afford something
        if player:canAfford(1000) then
            print("Player can afford $1000")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Purchase validation with feedback
        local cost = 500
        if player:canAfford(cost) then
            player:notify("You can afford this purchase!")
        else
            player:notifyError("You need $" .. (cost - player:getMoney()) .. " more")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex economic system with multiple checks
        local cost = 1000
        if player:canAfford(cost) then
            local char = player:getChar()
            if char then
                local currentMoney = char:getMoney()
                local remaining = currentMoney - cost
                player:notifySuccess("Purchase successful! Remaining: $" .. remaining)
            end
        else
            player:notifyError("Insufficient funds for this purchase")
        end
        ```
]]
function playerMeta:canAfford(amount)
    local character = self:getChar()
    return character and character:hasMoney(amount)
end

--[[
    Purpose: Checks if the player has a specific skill level or higher
    When Called: When validating skill requirements, implementing skill-based features, or character progression systems
    Parameters:
        skill (string) - The skill name to check
        level (number) - The minimum skill level required
    Returns: boolean - True if player has the required skill level, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player has skill level
        if player:hasSkillLevel("strength", 5) then
            print("Player has strength level 5 or higher")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Skill-based feature access
        if player:hasSkillLevel("engineering", 10) then
            player:notify("You can use advanced engineering tools")
        else
            player:notifyError("You need engineering level 10 for this")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex skill system with multiple requirements
        local requiredSkills = {
            {skill = "strength", level = 5},
            {skill = "intelligence", level = 8}
        }
        local canUse = true
        for _, req in ipairs(requiredSkills) do
            if not player:hasSkillLevel(req.skill, req.level) then
                canUse = false
                player:notifyError("Need " .. req.skill .. " level " .. req.level)
            end
        end
        if canUse then
            player:notifySuccess("All skill requirements met!")
        end
        ```
]]
function playerMeta:hasSkillLevel(skill, level)
    local currentLevel = self:getChar():getAttrib(skill, 0)
    return currentLevel >= level
end

--[[
    Purpose: Checks if the player meets all required skill levels for a task or feature
    When Called: When validating complex skill requirements, implementing multi-skill features, or character progression systems
    Parameters:
        requiredSkillLevels (table) - Table of skill names and required levels {skill = level, ...}
    Returns: boolean - True if player meets all requirements, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check multiple skill requirements
        local requirements = {strength = 5, intelligence = 3}
        if player:meetsRequiredSkills(requirements) then
            print("Player meets all skill requirements")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Complex feature with multiple skill checks
        local requirements = {engineering = 10, strength = 8, intelligence = 6}
        if player:meetsRequiredSkills(requirements) then
            player:notify("You can use the advanced workshop!")
        else
            player:notifyError("You don't meet the skill requirements")
        end
        ```

        High Complexity:
        ```lua
        -- High: Dynamic skill system with detailed feedback
        local requirements = {engineering = 10, strength = 8, intelligence = 6}
        if player:meetsRequiredSkills(requirements) then
            player:notifySuccess("All skill requirements met!")
        else
            local missing = {}
            for skill, level in pairs(requirements) do
                if not player:hasSkillLevel(skill, level) then
                    table.insert(missing, skill .. "(" .. level .. ")")
                end
            end
            player:notifyError("Missing skills: " .. table.concat(missing, ", "))
        end
        ```
]]
function playerMeta:meetsRequiredSkills(requiredSkillLevels)
    if not requiredSkillLevels then return true end
    for skill, level in pairs(requiredSkillLevels) do
        if not self:hasSkillLevel(skill, level) then return false end
    end
    return true
end

--[[
    Purpose: Forces the player to play a specific animation sequence with optional callback
    When Called: When implementing cutscenes, animations, or scripted sequences for the player
    Parameters:
        sequenceName (string) - The name of the animation sequence to play
        callback (function, optional) - Function to call when sequence completes
        time (number, optional) - Duration of the sequence (default: sequence duration)
        noFreeze (boolean, optional) - Whether to freeze the player during sequence
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Play animation sequence
        player:forceSequence("sit")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Play sequence with callback
        player:forceSequence("wave", function()
            player:notify("Animation completed!")
        end)
        ```

        High Complexity:
        ```lua
        -- High: Complex sequence system with timing and effects
        local sequenceName = "salute"
        local duration = 3.0
        local callback = function()
            player:notifySuccess("Salute completed!")
            player:setData("lastSalute", os.time())
        end
        player:forceSequence(sequenceName, callback, duration, false)
        ```
]]
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

--[[
    Purpose: Makes the player leave their current animation sequence and restore normal movement
    When Called: When ending cutscenes, animations, or scripted sequences for the player
    Parameters: None
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: End animation sequence
        player:leaveSequence()
        ```

        Medium Complexity:
        ```lua
        -- Medium: End sequence with notification
        player:leaveSequence()
        player:notify("Animation sequence ended")
        ```

        High Complexity:
        ```lua
        -- High: Complex sequence management with cleanup
        player:leaveSequence()
        player:notifySuccess("Sequence completed!")
        player:setData("lastSequence", os.time())
        -- Clean up any sequence-related data
        player:setData("sequenceActive", false)
        ```
]]
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

--[[
    Purpose: Gets the player's character flags string
    When Called: When accessing character flags, implementing flag-based features, or character management
    Parameters: None
    Returns: string - The character flags string (empty if no character)
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player flags
        local flags = player:getFlags()
        print("Player flags:", flags)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check for specific flags
        local flags = player:getFlags()
        if string.find(flags, "a") then
            player:notify("You have admin flags")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex flag system with multiple checks
        local flags = player:getFlags()
        local flagList = {}
        for i = 1, #flags do
            local flag = string.sub(flags, i, i)
            table.insert(flagList, flag)
        end
        player:notifyInfo("Your flags: " .. table.concat(flagList, ", "))
        ```
]]
function playerMeta:getFlags()
    local char = self:getChar()
    return char and char:getFlags() or ""
end

--[[
    Purpose: Gives flags to the player's character
    When Called: When granting character flags, implementing flag-based permissions, or character management
    Parameters:
        flags (string) - The flags to give to the character
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Give flags to player
        player:giveFlags("a")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Give flags with validation
        if player:hasPrivilege("admin") then
            player:giveFlags("a")
            player:notify("Admin flags granted!")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex flag system with logging
        local flags = "a"
        local char = player:getChar()
        if char then
            local oldFlags = char:getFlags()
            char:giveFlags(flags)
            local newFlags = char:getFlags()
            player:notifySuccess("Flags updated: " .. oldFlags .. " → " .. newFlags)
            lia.log.add("Player " .. player:Name() .. " received flags: " .. flags)
        end
        ```
]]
function playerMeta:giveFlags(flags)
    local char = self:getChar()
    if char then char:giveFlags(flags) end
end

--[[
    Purpose: Takes flags from the player's character
    When Called: When removing character flags, implementing flag-based permissions, or character management
    Parameters:
        flags (string) - The flags to take from the character
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Take flags from player
        player:takeFlags("a")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Take flags with validation
        if player:hasPrivilege("admin") then
            player:takeFlags("a")
            player:notify("Admin flags removed!")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex flag system with logging
        local flags = "a"
        local char = player:getChar()
        if char then
            local oldFlags = char:getFlags()
            char:takeFlags(flags)
            local newFlags = char:getFlags()
            player:notifyWarning("Flags updated: " .. oldFlags .. " → " .. newFlags)
            lia.log.add("Player " .. player:Name() .. " lost flags: " .. flags)
        end
        ```
]]
function playerMeta:takeFlags(flags)
    local char = self:getChar()
    if char then char:takeFlags(flags) end
end

--[[
    Purpose: Networks bone animation data to all clients for the player
    When Called: When implementing custom animations, bone manipulation, or visual effects for the player
    Parameters:
        active (boolean) - Whether the animation is active
        boneData (table) - Table of bone names and angles {boneName = angle, ...}
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Network basic animation
        local boneData = {ValveBiped.Bip01_Head1 = Angle(0, 0, 0)}
        player:networkAnimation(true, boneData)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Network animation with multiple bones
        local boneData = {
            ValveBiped.Bip01_Head1 = Angle(0, 0, 0),
            ValveBiped.Bip01_Spine2 = Angle(0, 0, 0)
        }
        player:networkAnimation(true, boneData)
        ```

        High Complexity:
        ```lua
        -- High: Complex animation system with timing
        local boneData = {
            ValveBiped.Bip01_Head1 = Angle(0, 0, 0),
            ValveBiped.Bip01_Spine2 = Angle(0, 0, 0),
            ValveBiped.Bip01_L_Hand = Angle(0, 0, 0)
        }
        player:networkAnimation(true, boneData)
        timer.Simple(5, function()
            if IsValid(player) then
                player:networkAnimation(false, boneData)
            end
        end)
        ```
]]
function playerMeta:networkAnimation(active, boneData)
    if SERVER then
        net.Start("liaAnimationStatus")
        net.WriteEntity(self)
        net.WriteBool(active)
        net.WriteTable(boneData)
        net.Broadcast()
    else
        for name, ang in pairs(boneData) do
            local i = self:LookupBone(name)
            if i then self:ManipulateBoneAngles(i, active and ang or angle_zero) end
        end
    end
end

--[[
    Purpose: Gets all Lilia data for the player (server-side) or local data (client-side)
    When Called: When accessing player data storage, implementing data management, or debugging systems
    Parameters: None
    Returns: table - The player's Lilia data table
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get all player data
        local data = player:getAllLiliaData()
        print("Player data keys:", table.GetKeys(data))
        ```

        Medium Complexity:
        ```lua
        -- Medium: Access specific data with validation
        local data = player:getAllLiliaData()
        if data.settings then
            player:notify("Settings loaded: " .. tostring(data.settings))
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex data management with logging
        local data = player:getAllLiliaData()
        local dataSize = 0
        for k, v in pairs(data) do
            dataSize = dataSize + 1
        end
        player:notifyInfo("Data entries: " .. dataSize)
        lia.log.add("Player " .. player:Name() .. " data accessed")
        ```
]]
function playerMeta:getAllLiliaData()
    if SERVER then
        self.liaData = self.liaData or {}
        return self.liaData
    else
        lia.localData = lia.localData or {}
        return lia.localData
    end
end

--[[
    Purpose: Sets a waypoint for the player to navigate to
    When Called: When implementing navigation systems, quest objectives, or location guidance for the player
    Parameters:
        name (string) - The name of the waypoint
        vector (Vector) - The position of the waypoint
        logo (string, optional) - The material path for the waypoint icon
        onReach (function, optional) - Function to call when waypoint is reached
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Set basic waypoint
        player:setWaypoint("Objective", Vector(100, 200, 50))
        ```

        Medium Complexity:
        ```lua
        -- Medium: Set waypoint with icon
        player:setWaypoint("Treasure", Vector(500, 300, 100), "icon16/star.png")
        ```

        High Complexity:
        ```lua
        -- High: Complex waypoint system with callback
        local waypointName = "Mission Objective"
        local waypointPos = Vector(1000, 2000, 100)
        local waypointIcon = "icon16/flag.png"
        local onReach = function()
            player:notifySuccess("Objective reached!")
            player:setData("missionComplete", true)
        end
        player:setWaypoint(waypointName, waypointPos, waypointIcon, onReach)
        ```
]]
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

                surface.SetFont("liaSmallFont")
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
                draw.SimpleText(nameText, "liaSmallFont", math.Round(spos.x), math.Round(spos.y - 1), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
                draw.SimpleText(metersText, "liaSmallFont", math.Round(spos.x), math.Round(spos.y - 1 + nameTh + 3), textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
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

--[[
    Purpose: Gets a specific Lilia data value for the player with optional default
    When Called: When accessing player data storage, implementing data management, or retrieving stored values
    Parameters:
        key (string) - The data key to retrieve
        default (any, optional) - The default value to return if key doesn't exist
    Returns: any - The data value or default if not found
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Get player data with default
        local settings = player:getLiliaData("settings", {})
        print("Player settings:", settings)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Get data with validation
        local level = player:getLiliaData("level", 1)
        if level > 10 then
            player:notify("You are level " .. level)
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex data management with fallbacks
        local config = player:getLiliaData("config", {})
        local defaultConfig = {theme = "dark", language = "en", notifications = true}
        for k, v in pairs(defaultConfig) do
            if config[k] == nil then
                config[k] = v
            end
        end
        player:notifyInfo("Config loaded with " .. table.Count(config) .. " settings")
        ```
]]
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

--[[
    Purpose: Checks if the player has any of the specified flags
    When Called: When validating flag-based permissions, implementing access control, or character management
    Parameters:
        flags (string) - The flags to check for (any one flag will return true)
    Returns: boolean - True if player has any of the specified flags, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player has flags
        if player:hasFlags("a") then
            print("Player has admin flags")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Check multiple flags
        if player:hasFlags("abc") then
            player:notify("You have admin, builder, or custom flags")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex flag system with detailed feedback
        local requiredFlags = "abc"
        if player:hasFlags(requiredFlags) then
            local playerFlags = player:getFlags()
            local hasFlags = {}
            for i = 1, #requiredFlags do
                local flag = requiredFlags:sub(i, i)
                if playerFlags:find(flag, 1, true) then
                    table.insert(hasFlags, flag)
                end
            end
            player:notifySuccess("You have flags: " .. table.concat(hasFlags, ", "))
        end
        ```
]]
function playerMeta:hasFlags(flags)
    for i = 1, #flags do
        local flag = flags:sub(i, i)
        if self:getFlags():find(flag, 1, true) then return true end
    end
    return hook.Run("CharHasFlags", self, flags) or false
end

--[[
    Purpose: Checks if the player's play time is greater than a specified amount
    When Called: When implementing time-based features, veteran rewards, or play time validation
    Parameters:
        time (number) - The minimum play time required in seconds
    Returns: boolean - True if player's play time is greater than the specified time, false otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Check if player has enough play time
        if player:playTimeGreaterThan(3600) then
            print("Player has played for more than 1 hour")
        end
        ```

        Medium Complexity:
        ```lua
        -- Medium: Time-based feature access
        if player:playTimeGreaterThan(7200) then
            player:notify("You can access veteran features!")
        else
            player:notifyError("You need 2 hours of play time for this feature")
        end
        ```

        High Complexity:
        ```lua
        -- High: Complex time-based system with rewards
        local requiredTime = 86400 -- 24 hours
        if player:playTimeGreaterThan(requiredTime) then
            local playTime = player:getPlayTime()
            local hours = math.floor(playTime / 3600)
            player:notifySuccess("Veteran status achieved! Play time: " .. hours .. " hours")
            player:giveFlags("v")
        end
        ```
]]
function playerMeta:playTimeGreaterThan(time)
    local playTime = self:getPlayTime()
    if not playTime or not time then return false end
    return playTime > time
end

--[[
    Purpose: Requests the player to select from a list of options via a UI dialog
    When Called: When implementing interactive menus, choice systems, or user input dialogs for the player
    Parameters:
        title (string) - The title of the options dialog
        subTitle (string) - The subtitle or description of the options
        options (table) - Array of option strings to choose from
        limit (number, optional) - Maximum number of options that can be selected (default: 1)
        callback (function, optional) - Function to call when player makes a selection
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Request single option
        player:requestOptions("Choose Action", "What do you want to do?", {"Option 1", "Option 2"})
        ```

        Medium Complexity:
        ```lua
        -- Medium: Request with callback
        local options = {"Yes", "No", "Maybe"}
        local callback = function(selected)
            player:notify("You selected: " .. table.concat(selected, ", "))
        end
        player:requestOptions("Confirmation", "Do you want to continue?", options, 1, callback)
        ```

        High Complexity:
        ```lua
        -- High: Complex options system with validation
        local title = "Character Creation"
        local subTitle = "Choose your character's background"
        local options = {"Warrior", "Mage", "Rogue", "Healer"}
        local limit = 1
        local callback = function(selected)
            if #selected > 0 then
                local char = player:getChar()
                if char then
                    char:setData("class", selected[1])
                    player:notifySuccess("Character class set to: " .. selected[1])
                end
            end
        end
        player:requestOptions(title, subTitle, options, limit, callback)
        ```
]]
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

--[[
    Purpose: Requests the player to input a string via a UI dialog
    When Called: When implementing text input systems, name entry, or string-based user input for the player
    Parameters:
        title (string) - The title of the string input dialog
        subTitle (string) - The subtitle or description of the input
        callback (function) - Function to call when player submits the string
        default (string, optional) - Default value to pre-fill in the input field
    Returns: deferred|nil - A deferred object if no callback provided, nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Request string input
        player:requestString("Enter Name", "What is your name?", function(name)
            print("Player entered:", name)
        end)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Request with default value
        player:requestString("Enter Message", "Type your message:", function(message)
            player:notify("You said: " .. message)
        end, "Hello World")
        ```

        High Complexity:
        ```lua
        -- High: Complex string input with validation
        local title = "Character Name"
        local subTitle = "Enter your character's name (3-20 characters)"
        local callback = function(name)
            if name and #name >= 3 and #name <= 20 then
                local char = player:getChar()
                if char then
                    char:setData("name", name)
                    player:notifySuccess("Character name set to: " .. name)
                end
            else
                player:notifyError("Name must be 3-20 characters long")
            end
        end
        player:requestString(title, subTitle, callback, "New Character")
        ```
]]
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

--[[
    Purpose: Requests the player to input multiple arguments via a UI dialog
    When Called: When implementing complex input systems, command interfaces, or multi-parameter user input for the player
    Parameters:
        title (string) - The title of the arguments input dialog
        argTypes (table) - Array of argument type specifications
        callback (function) - Function to call when player submits the arguments
    Returns: deferred|nil - A deferred object if no callback provided, nil otherwise
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Request basic arguments
        local argTypes = {{type = "string", name = "Name"}, {type = "number", name = "Age"}}
        player:requestArguments("Enter Info", argTypes, function(args)
            print("Name:", args[1], "Age:", args[2])
        end)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Request with validation
        local argTypes = {
            {type = "string", name = "Item Name", required = true},
            {type = "number", name = "Quantity", min = 1, max = 100}
        }
        player:requestArguments("Create Item", argTypes, function(args)
            player:notify("Created " .. args[2] .. "x " .. args[1])
        end)
        ```

        High Complexity:
        ```lua
        -- High: Complex argument system with multiple types
        local argTypes = {
            {type = "string", name = "Character Name", required = true},
            {type = "number", name = "Level", min = 1, max = 100},
            {type = "boolean", name = "Is VIP", default = false},
            {type = "string", name = "Faction", options = {"police", "citizen", "criminal"}}
        }
        local callback = function(args)
            local char = player:getChar()
            if char then
                char:setData("name", args[1])
                char:setData("level", args[2])
                char:setData("isVIP", args[3])
                char:setData("faction", args[4])
                player:notifySuccess("Character updated!")
            end
        end
        player:requestArguments("Character Setup", argTypes, callback)
        ```
]]
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

--[[
    Purpose: Presents a binary question to the player with two options
    When Called: When implementing yes/no dialogs, confirmation prompts, or binary choice systems for the player
    Parameters:
        question (string) - The question to ask the player
        option1 (string) - The first option (usually "Yes" or "Accept")
        option2 (string) - The second option (usually "No" or "Cancel")
        manualDismiss (boolean, optional) - Whether the player can manually dismiss the dialog
        callback (function, optional) - Function to call when player makes a choice
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Ask yes/no question
        player:binaryQuestion("Do you want to continue?", "Yes", "No")
        ```

        Medium Complexity:
        ```lua
        -- Medium: Ask with callback
        player:binaryQuestion("Delete this item?", "Delete", "Cancel", true, function(choice)
            if choice == 1 then
                player:notify("Item deleted!")
            else
                player:notify("Deletion cancelled")
            end
        end)
        ```

        High Complexity:
        ```lua
        -- High: Complex confirmation system with validation
        local question = "Are you sure you want to reset your character? This cannot be undone!"
        local option1 = "Yes, Reset"
        local option2 = "No, Keep Character"
        local callback = function(choice)
            if choice == 1 then
                local char = player:getChar()
                if char then
                    char:delete()
                    player:notifySuccess("Character reset successfully!")
                end
            else
                player:notifyInfo("Character reset cancelled")
            end
        end
        player:binaryQuestion(question, option1, option2, true, callback)
        ```
]]
function playerMeta:binaryQuestion(question, option1, option2, manualDismiss, callback)
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
        lia.derma.binaryQuestion(question, option1, option2, manualDismiss, callback)
    end
end

--[[
    Purpose: Presents a custom button dialog to the player with multiple action buttons
    When Called: When implementing custom action menus, button interfaces, or interactive dialogs for the player
    Parameters:
        title (string) - The title of the button dialog
        buttons (table) - Array of button data {text = "Button Text", callback = function() end} or {text, callback}
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Request basic buttons
        local buttons = {
            {text = "Option 1", callback = function() print("Option 1 selected") end},
            {text = "Option 2", callback = function() print("Option 2 selected") end}
        }
        player:requestButtons("Choose Action", buttons)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Request with different actions
        local buttons = {
            {text = "Heal", callback = function() player:SetHealth(100) end},
            {text = "Give Money", callback = function() player:notify("Money given!") end},
            {text = "Cancel", callback = function() player:notify("Cancelled") end}
        }
        player:requestButtons("Player Actions", buttons)
        ```

        High Complexity:
        ```lua
        -- High: Complex button system with validation
        local title = "Character Management"
        local buttons = {
            {text = "Reset Character", callback = function()
                player:binaryQuestion("Reset character?", "Yes", "No", true, function(choice)
                    if choice == 1 then
                        local char = player:getChar()
                        if char then char:delete() end
                    end
                end)
            end},
            {text = "Change Name", callback = function()
                player:requestString("New Name", "Enter new character name:", function(name)
                    local char = player:getChar()
                    if char then char:setData("name", name) end
                end)
            end},
            {text = "Cancel", callback = function() player:notify("Cancelled") end}
        }
        player:requestButtons(title, buttons)
        ```
]]
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

--[[
    Purpose: Presents a dropdown selection dialog to the player
    When Called: When implementing selection menus, choice systems, or dropdown interfaces for the player
    Parameters:
        title (string) - The title of the dropdown dialog
        subTitle (string) - The subtitle or description of the selection
        options (table) - Array of option strings to choose from
        callback (function, optional) - Function to call when player makes a selection
    Returns: None
    Realm: Shared
    Example Usage:
        Low Complexity:
        ```lua
        -- Simple: Request dropdown selection
        local options = {"Option 1", "Option 2", "Option 3"}
        player:requestDropdown("Choose Option", "Select an option:", options)
        ```

        Medium Complexity:
        ```lua
        -- Medium: Request with callback
        local options = {"Red", "Green", "Blue", "Yellow"}
        local callback = function(selected)
            player:notify("You selected: " .. selected)
        end
        player:requestDropdown("Choose Color", "Select your favorite color:", options, callback)
        ```

        High Complexity:
        ```lua
        -- High: Complex dropdown system with validation
        local title = "Character Class"
        local subTitle = "Choose your character's class"
        local options = {"Warrior", "Mage", "Rogue", "Healer", "Paladin"}
        local callback = function(selected)
            local char = player:getChar()
            if char then
                char:setData("class", selected)
                player:notifySuccess("Character class set to: " .. selected)
                -- Apply class-specific bonuses
                if selected == "Warrior" then
                    char:setData("strength", 15)
                elseif selected == "Mage" then
                    char:setData("intelligence", 15)
                end
            end
        end
        player:requestDropdown(title, subTitle, options, callback)
        ```
]]
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
    Purpose: Sets a network variable for the player that synchronizes to all clients
    When Called: When updating player state, implementing networked properties, or when other players need to see the change (like handcuff status)
    Parameters:
        key (string) - The network variable key
        value (any) - The value to set
    Returns: None
    Realm: Server (only called on server side)
    Notes: Broadcasts to all clients so other players can see the player's state changes
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
