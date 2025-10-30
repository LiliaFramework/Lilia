--[[
    Entity Meta

    Entity management system for the Lilia framework.
]]
--[[
    Overview:
        The entity meta table provides comprehensive functionality for extending Garry's Mod entities with Lilia-specific features and operations. It handles entity identification, sound management, door access control, vehicle ownership, network variable synchronization, and entity-specific operations. The meta table operates on both server and client sides, with the server managing entity data and validation while the client provides entity interaction and display. It includes integration with the door system for access control, vehicle system for ownership management, network system for data synchronization, and sound system for audio playback. The meta table ensures proper entity identification, access control validation, network data synchronization, and comprehensive entity interaction management for doors, vehicles, and other game objects.
]]
local entityMeta = FindMetaTable("Entity")
local baseEmitSound = entityMeta.EmitSound
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

--[[
    Purpose:
        Emits a sound from the entity, with support for web sounds and URL-based audio
    When Called:
        When an entity needs to play a sound effect or audio
    Parameters:
        - soundName (string): The sound file path, URL, or websound identifier
        - soundLevel (number, optional): Sound level/distance (default: 100)
        - pitchPercent (number, optional): Pitch adjustment percentage
        - volume (number, optional): Volume level (default: 100)
        - channel (number, optional): Sound channel
        - flags (number, optional): Sound flags
        - dsp (number, optional): DSP effect
    Returns:
        boolean - True if sound was played successfully
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Play a basic sound
        entity:EmitSound("buttons/button15.wav")
        ```

        Medium Complexity:

        ```lua
        -- Medium: Play sound with custom volume and distance
        entity:EmitSound("ambient/atmosphere/city_hum_loop.wav", 200, 100, 0.5)
        ```

        High Complexity:

        ```lua
        -- High: Play web sound with full parameters
        entity:EmitSound("https://example.com/sound.mp3", 300, 100, 0.8, CHAN_AUTO, 0, 0)
        ```
]]
function entityMeta:EmitSound(soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
    if isstring(soundName) and (soundName:find("^https?://") or soundName:find("^lilia/websounds/") or soundName:find("^websounds/")) then
        if SERVER then
            net.Start("liaEmitUrlSound")
            net.WriteEntity(self)
            net.WriteString(soundName)
            net.WriteFloat(volume or 100)
            net.WriteFloat(soundLevel or 100)
            net.WriteBool(false)
            net.Broadcast()
            return true
        else
            local maxDistance = soundLevel and soundLevel * 13.33 or 1000
            self:playFollowingSound(soundName, volume or 100, true, maxDistance)
            return true
        end
    end

    if SERVER and isstring(soundName) then
        local name = soundName:gsub("\\", "/"):gsub("^%s+", ""):gsub("%s+$", "")
        if string.StartWith(name, "sound/") then name = name:sub(7) end
        if lia.websound and lia.websound.stored and lia.websound.stored[name] then
            net.Start("liaEmitUrlSound")
            net.WriteEntity(self)
            net.WriteString("lilia/websounds/" .. name)
            net.WriteFloat(volume or 100)
            net.WriteFloat(soundLevel or 100)
            net.WriteBool(false)
            net.Broadcast()
            return true
        end
    end

    if CLIENT and isstring(soundName) and lia.websound.get(soundName) then
        local maxDistance = soundLevel and soundLevel * 13.33 or 1000
        self:playFollowingSound(soundName, volume or 100, true, maxDistance)
        return true
    end
    return baseEmitSound(self, soundName, soundLevel, pitchPercent, volume, channel, flags, dsp)
end

--[[
    Purpose:
        Checks if the entity is a physics prop
    When Called:
        When you need to determine if an entity is a prop_physics object
    Parameters:
        None
    Returns:
        boolean - True if the entity is a prop_physics, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is a prop
        if entity:isProp() then
            print("This is a physics prop")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in conditional logic
        if entity:isProp() and entity:GetPhysicsObject():IsValid() then
            entity:GetPhysicsObject():Wake()
        end
        ```

        High Complexity:

        ```lua
        -- High: Combine with other checks for complex logic
        if entity:isProp() and entity:GetModel():find("wood") then
            -- Handle wooden prop specifically
            entity:SetMaterial("models/wood")
        end
        ```
]]
function entityMeta:isProp()
    if not IsValid(self) then return false end
    return self:GetClass() == "prop_physics"
end

--[[
    Purpose:
        Checks if the entity is a Lilia item entity
    When Called:
        When you need to determine if an entity is a lia_item object
    Parameters:
        None
    Returns:
        boolean - True if the entity is a lia_item, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is an item
        if entity:isItem() then
            print("This is a Lilia item")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in item handling logic
        if entity:isItem() and entity:GetItemData() then
            local itemData = entity:GetItemData()
            print("Item name:", itemData.name)
        end
        ```

        High Complexity:

        ```lua
        -- High: Combine with inventory system
        if entity:isItem() and IsValid(ply) then
            local itemData = entity:GetItemData()
            if itemData and ply:getChar():getInv():canFit(itemData) then
                ply:getChar():getInv():add(itemData)
                entity:Remove()
            end
        end
        ```
]]
function entityMeta:isItem()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_item"
end

--[[
    Purpose:
        Checks if the entity is a Lilia money entity
    When Called:
        When you need to determine if an entity is a lia_money object
    Parameters:
        None
    Returns:
        boolean - True if the entity is a lia_money, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is money
        if entity:isMoney() then
            print("This is money")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in money handling logic
        if entity:isMoney() and IsValid(ply) then
            local amount = entity:GetAmount() or 0
            ply:getChar():giveMoney(amount)
            entity:Remove()
        end
        ```

        High Complexity:

        ```lua
        -- High: Combine with economy system
        if entity:isMoney() and IsValid(ply) then
            local amount = entity:GetAmount() or 0
            local char = ply:getChar()
            if char:getMoney() + amount <= char:getMaxMoney() then
                char:giveMoney(amount)
                entity:Remove()
                ply:notify("You picked up $" .. amount)
            end
        end
        ```
]]
function entityMeta:isMoney()
    if not IsValid(self) then return false end
    return self:GetClass() == "lia_money"
end

--[[
    Purpose:
        Checks if the entity is a Simfphys vehicle or LVS vehicle
    When Called:
        When you need to determine if an entity is a vehicle from Simfphys or LVS
    Parameters:
        None
    Returns:
        boolean - True if the entity is a supported vehicle, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is a vehicle
        if entity:isSimfphysCar() then
            print("This is a vehicle")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in vehicle handling logic
        if entity:isSimfphysCar() and IsValid(ply) then
            if entity:GetDriver() == ply then
                ply:notify("You are driving this vehicle")
            end
        end
        ```

        High Complexity:

        ```lua
        -- High: Combine with vehicle systems
        if entity:isSimfphysCar() and IsValid(ply) then
            local char = ply:getChar()
            if char:hasFlags("v") then
                entity:SetDriver(ply)
                entity:SetNetVar("owner", char:getID())
            end
        end
        ```
]]
function entityMeta:isSimfphysCar()
    if not IsValid(self) then return false end
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

--[[
    Purpose:
        Checks if a client has access to a door with the specified access level
    When Called:
        When you need to verify if a player can access a door
    Parameters:
        - client (Player): The player to check access for
        - access (number, optional): The required access level (default: DOOR_GUEST)
    Returns:
        boolean - True if the client has access, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check basic door access
        if door:checkDoorAccess(ply) then
            door:Fire("Open")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Check specific access level
        if door:checkDoorAccess(ply, DOOR_OWNER) then
            ply:notify("You own this door")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in door interaction system
        if door:checkDoorAccess(ply, DOOR_GUEST) then
            if door:isDoorLocked() then
                ply:notify("The door is locked")
                else
                    door:Fire("Open")
                    ply:notify("Door opened")
                end
                else
                    ply:notify("You don't have access to this door")
                end
        ```
]]
function entityMeta:checkDoorAccess(client, access)
    if not IsValid(self) then return false end
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

--[[
    Purpose:
        Sets a client as the owner of a vehicle and updates ownership data
    When Called:
        When a player becomes the owner of a vehicle
    Parameters:
        - client (Player): The player to set as the owner
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Set vehicle owner
        vehicle:keysOwn(ply)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Set owner with validation
        if IsValid(ply) and ply:getChar() then
            vehicle:keysOwn(ply)
            ply:notify("You now own this vehicle")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in vehicle purchase system
        if ply:getChar():getMoney() >= vehiclePrice then
            ply:getChar():takeMoney(vehiclePrice)
            vehicle:keysOwn(ply)
            ply:notify("Vehicle purchased for $" .. vehiclePrice)
            else
                ply:notify("Insufficient funds")
            end
        ```
]]
function entityMeta:keysOwn(client)
    if not IsValid(self) then return end
    if self:IsVehicle() then
        self:CPPISetOwner(client)
        self:setNetVar("owner", client:getChar():getID())
        self.ownerID = client:getChar():getID()
        self:setNetVar("ownerName", client:getChar():getName())
    end
end

--[[
    Purpose:
        Locks a vehicle if it is a valid vehicle entity
    When Called:
        When a player wants to lock their vehicle
    Parameters:
        None
    Returns:
        None
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Lock vehicle
        vehicle:keysLock()
        ```

        Medium Complexity:

        ```lua
        -- Medium: Lock with validation
        if IsValid(vehicle) and vehicle:IsVehicle() then
            vehicle:keysLock()
            ply:notify("Vehicle locked")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in vehicle interaction system
        if vehicle:keysOwn(ply) and not vehicle:isLocked() then
            vehicle:keysLock()
            ply:notify("Vehicle locked")
            elseif not vehicle:keysOwn(ply) then
                ply:notify("You don't own this vehicle")
                else
                    ply:notify("Vehicle is already locked")
                end
        ```
]]
function entityMeta:keysLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("lock") end
end

--[[
    Purpose:
        Unlocks a vehicle if it is a valid vehicle entity
    When Called:
        When a player wants to unlock their vehicle
    Parameters:
        None
    Returns:
        None
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Unlock vehicle
        vehicle:keysUnLock()
        ```

        Medium Complexity:

        ```lua
        -- Medium: Unlock with validation
        if IsValid(vehicle) and vehicle:IsVehicle() then
            vehicle:keysUnLock()
            ply:notify("Vehicle unlocked")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in vehicle interaction system
        if vehicle:keysOwn(ply) and vehicle:isLocked() then
            vehicle:keysUnLock()
            ply:notify("Vehicle unlocked")
            elseif not vehicle:keysOwn(ply) then
                ply:notify("You don't own this vehicle")
                else
                    ply:notify("Vehicle is already unlocked")
                end
        ```
]]
function entityMeta:keysUnLock()
    if not IsValid(self) then return end
    if self:IsVehicle() then self:Fire("unlock") end
end

--[[
    Purpose:
        Gets the owner of a door entity
    When Called:
        When you need to retrieve the owner of a door
    Parameters:
        None
    Returns:
        Player or nil - The door owner if it's a vehicle with CPPI, nil otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Get door owner
        local owner = door:getDoorOwner()
        if IsValid(owner) then
            print("Door owner:", owner:Name())
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Check ownership for access control
        local owner = door:getDoorOwner()
        if IsValid(owner) and owner == ply then
            ply:notify("You own this door")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in door management system
        local owner = door:getDoorOwner()
        if IsValid(owner) then
            local char = owner:getChar()
            if char then
                door:setNetVar("ownerName", char:getName())
                door:setNetVar("ownerID", char:getID())
            end
        end
        ```
]]
function entityMeta:getDoorOwner()
    if not IsValid(self) then return nil end
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

--[[
    Purpose:
        Checks if the entity is locked using network variables
    When Called:
        When you need to check if an entity is in a locked state
    Parameters:
        None
    Returns:
        boolean - True if the entity is locked, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is locked
        if entity:isLocked() then
            print("Entity is locked")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in interaction logic
        if entity:isLocked() then
            ply:notify("This is locked")
            else
                entity:Use(ply)
            end
        ```

        High Complexity:

        ```lua
        -- High: Use in security system
        if entity:isLocked() and not ply:hasFlags("A") then
            ply:notify("Access denied - locked")
            elseif entity:isLocked() and ply:hasFlags("A") then
                entity:setLocked(false)
                ply:notify("Unlocked with admin access")
            end
        ```
]]
function entityMeta:isLocked()
    if not IsValid(self) then return false end
    return self:getNetVar("locked", false)
end

--[[
    Purpose:
        Checks if a door entity is locked using internal variables or custom properties
    When Called:
        When you need to check if a door is in a locked state
    Parameters:
        None
    Returns:
        boolean - True if the door is locked, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if door is locked
        if door:isDoorLocked() then
            print("Door is locked")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in door interaction
        if door:isDoorLocked() then
            ply:notify("The door is locked")
            else
                door:Fire("Open")
            end
        ```

        High Complexity:

        ```lua
        -- High: Use in door access system
        if door:isDoorLocked() and not door:checkDoorAccess(ply, DOOR_OWNER) then
            ply:notify("Door is locked and you don't have access")
            elseif door:isDoorLocked() and door:checkDoorAccess(ply, DOOR_OWNER) then
                door:setLocked(false)
                ply:notify("Door unlocked with your key")
            end
        ```
]]
function entityMeta:isDoorLocked()
    if not IsValid(self) then return false end
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

--[[
    Purpose:
        Calculates the position and angle for dropping items from an entity
    When Called:
        When an entity needs to drop an item at a specific location
    Parameters:
        - offset (number, optional): Distance to trace forward from entity (default: 64)
    Returns:
        Vector, Angle - The drop position and angle
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Get drop position
        local pos, ang = entity:getEntItemDropPos()
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use with custom offset
        local pos, ang = entity:getEntItemDropPos(100)
        local item = ents.Create("lia_item")
        item:SetPos(pos)
        item:SetAngles(ang)
        ```

        High Complexity:

        ```lua
        -- High: Use in item dropping system
        local pos, ang = entity:getEntItemDropPos(offset)
        local tr = util.TraceLine({
        start = pos,
        endpos = pos + Vector(0, 0, -50),
        mask = MASK_SOLID_BRUSHONLY
        })
        if tr.Hit then
            pos = tr.HitPos + tr.HitNormal * 5
        end
        local item = ents.Create("lia_item")
        item:SetPos(pos)
        item:SetAngles(ang)
        item:Spawn()
        ```
]]
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

--[[
    Purpose:
        Checks if the entity's model represents a female character
    When Called:
        When you need to determine the gender of a character entity
    Parameters:
        None
    Returns:
        boolean - True if the entity is female, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is female
        if entity:isFemale() then
            print("This is a female character")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in character customization
        if entity:isFemale() then
            entity:SetBodygroup(1, 1) -- Set female bodygroup
            else
                entity:SetBodygroup(1, 0) -- Set male bodygroup
            end
        ```

        High Complexity:

        ```lua
        -- High: Use in roleplay system
        if entity:isFemale() then
            local char = entity:getChar()
            if char then
                char:setData("gender", "female")
                char:setData("pronouns", {"she", "her", "hers"})
                end
            end
        ```
]]
function entityMeta:isFemale()
    if not IsValid(self) then return false end
    return hook.Run("GetModelGender", self:GetModel()) == "female"
end

--[[
    Purpose:
        Checks if the entity is near another entity within a specified radius
    When Called:
        When you need to check proximity between entities
    Parameters:
        - radius (number, optional): Search radius in units (default: 96)
        - otherEntity (Entity, optional): Specific entity to check for proximity
    Returns:
        boolean - True if near another entity, false otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is near any other entity
        if entity:isNearEntity() then
            print("Entity is near something")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Check proximity to specific entity
        if entity:isNearEntity(150, targetEntity) then
            print("Entity is near target")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in interaction system
        if entity:isNearEntity(100, ply) then
            if entity:isItem() then
                ply:notify("Press E to pick up " .. entity:GetItemData().name)
                elseif entity:isMoney() then
                    ply:notify("Press E to collect $" .. entity:GetAmount())
                end
            end
        ```
]]
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

--[[
    Purpose:
        Gets the partner door entity for double doors
    When Called:
        When you need to find the paired door in a double door setup
    Parameters:
        None
    Returns:
        Entity or nil - The partner door if found, nil otherwise
    Realm:
        Shared
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Get door partner
        local partner = door:getDoorPartner()
        if IsValid(partner) then
            print("Found door partner")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in door synchronization
        local partner = door:getDoorPartner()
        if IsValid(partner) then
            partner:Fire("Open")
            door:Fire("Open")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in door management system
        local partner = door:getDoorPartner()
        if IsValid(partner) then
            if door:isDoorLocked() then
                partner:setLocked(true)
                else
                    partner:setLocked(false)
                end
                door:setNetVar("partnerID", partner:EntIndex())
            end
        ```
]]
function entityMeta:getDoorPartner()
    if SERVER then
        return self.liaPartner
    else
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
end

if SERVER then
    --[[
    Purpose:
        Sends a network variable to clients via network message
    When Called:
        When you need to synchronize entity data with clients
    Parameters:
        - key (string): The network variable key to send
        - receiver (Player, optional): Specific player to send to, or nil for all players
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Send network variable to all clients
        entity:sendNetVar("health")
        ```

        Medium Complexity:

        ```lua
        -- Medium: Send to specific player
        entity:sendNetVar("owner", ply)
        ```

        High Complexity:

        ```lua
        -- High: Use in data synchronization system
        if entity:getNetVar("dirty") then
            entity:sendNetVar("data", nil)
            entity:setNetVar("dirty", false)
        end
        ```
]]
    function entityMeta:sendNetVar(key, receiver)
        if not IsValid(self) then return end
        net.Start("liaNetVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(lia.net[self] and lia.net[self][key])
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
    Purpose:
        Clears all network variables for the entity and notifies clients
    When Called:
        When you need to remove all network data from an entity
    Parameters:
        - receiver (Player, optional): Specific player to notify, or nil for all players
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Clear all network variables
        entity:clearNetVars()
        ```

        Medium Complexity:

        ```lua
        -- Medium: Clear for specific player
        entity:clearNetVars(ply)
        ```

        High Complexity:

        ```lua
        -- High: Use in entity cleanup system
        if entity:IsValid() then
            entity:clearNetVars()
            entity:Remove()
        end
        ```
]]
    function entityMeta:clearNetVars(receiver)
        if not IsValid(self) then return end
        lia.net[self] = nil
        if lia.shuttingDown then return end
        net.Start("liaNetDel")
        net.WriteUInt(self:EntIndex(), 16)
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
    Purpose:
        Removes all door access data and notifies clients to close door menus
    When Called:
        When you need to clear all door access permissions and close related UIs
    Parameters:
        None
    Returns:
        None
    Realm:
        Server (can only be called on server)
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Remove door access data
        door:removeDoorAccessData()
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in door cleanup
        if door:IsValid() then
            door:removeDoorAccessData()
            door:Remove()
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in door management system
        if ply:hasFlags("A") then
            door:removeDoorAccessData()
            ply:notify("Door access data cleared")
        end
        ```
]]
    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                net.Start("liaDoorMenu")
                net.Send(k)
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    --[[
    Purpose:
        Sets the locked state of an entity using network variables
    When Called:
        When you need to lock or unlock an entity
    Parameters:
        - state (boolean): True to lock, false to unlock
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Lock entity
        entity:setLocked(true)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Toggle lock state
        entity:setLocked(not entity:isLocked())
        ```

        High Complexity:

        ```lua
        -- High: Use in security system
        if ply:hasFlags("A") then
            entity:setLocked(not entity:isLocked())
            ply:notify("Entity " .. (entity:isLocked() and "locked" or "unlocked"))
        end
        ```
]]
    function entityMeta:setLocked(state)
        if not IsValid(self) then return end
        self:setNetVar("locked", state)
    end

    --[[
    Purpose:
        Sets whether a vehicle can be owned or sold
    When Called:
        When you need to make a vehicle non-ownable or ownable
    Parameters:
        - state (boolean): True to make non-ownable, false to make ownable
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Make vehicle non-ownable
        vehicle:setKeysNonOwnable(true)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Toggle ownable state
        vehicle:setKeysNonOwnable(not vehicle:getNetVar("noSell", false))
        ```

        High Complexity:

        ```lua
        -- High: Use in vehicle management system
        if ply:hasFlags("A") then
            vehicle:setKeysNonOwnable(true)
            ply:notify("Vehicle made non-ownable")
        end
        ```
]]
    function entityMeta:setKeysNonOwnable(state)
        if not IsValid(self) then return end
        self:setNetVar("noSell", state)
    end

    --[[
    Purpose:
        Checks if the entity is a door by examining its class name
    When Called:
        When you need to determine if an entity is a door
    Parameters:
        None
    Returns:
        boolean - True if the entity is a door, false otherwise
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is a door
        if entity:isDoor() then
            print("This is a door")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in door interaction
        if entity:isDoor() and entity:checkDoorAccess(ply) then
            entity:Fire("Open")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in door management system
        if entity:isDoor() then
            local partner = entity:getDoorPartner()
            if IsValid(partner) then
                partner:setLocked(entity:isDoorLocked())
            end
        end
        ```
]]
    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_"}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    --[[
    Purpose:
        Sets a network variable for the entity and synchronizes it with clients
    When Called:
        When you need to store and sync data on an entity
    Parameters:
        - key (string): The network variable key
        - value (any): The value to store
        - receiver (Player, optional): Specific player to send to, or nil for all players
    Returns:
        None
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Set a network variable
        entity:setNetVar("health", 100)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Set with specific receiver
        entity:setNetVar("owner", ply, ply)
        ```

        High Complexity:

        ```lua
        -- High: Use in data management system
        if entity:getNetVar("dirty") then
            entity:setNetVar("lastUpdate", CurTime())
            entity:setNetVar("dirty", false)
        end
        ```
]]
    function entityMeta:setNetVar(key, value, receiver)
        if not IsValid(self) then return end
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    --[[
    Purpose:
        Gets a network variable from the entity (server-side)
    When Called:
        When you need to retrieve synchronized data from an entity on the server
    Parameters:
        - key (string): The network variable key to retrieve
        - default (any, optional): Default value if the key doesn't exist
    Returns:
        any - The network variable value or default
    Realm:
        Server
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Get a network variable
        local health = entity:getNetVar("health", 100)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in server-side logic
        local owner = entity:getNetVar("owner")
        if owner and IsValid(owner) then
            print("Entity owner:", owner:Name())
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in server-side data management
        local data = entity:getNetVar("data", {})
        if data.lastUpdate and CurTime() - data.lastUpdate > 300 then
            entity:setNetVar("data", {lastUpdate = CurTime()})
            end
        ```
]]
    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end
else
    --[[
    Purpose:
        Checks if the entity is a door by examining its class name (client-side)
    When Called:
        When you need to determine if an entity is a door on the client
    Parameters:
        None
    Returns:
        boolean - True if the entity is a door, false otherwise
    Realm:
        Client (can only be called on client)
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Check if entity is a door
        if entity:isDoor() then
            print("This is a door")
        end
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in client-side door interaction
        if entity:isDoor() and entity:isNearEntity(100, LocalPlayer()) then
            draw.DrawText("Press E to open door", "DermaDefault", ScrW()/2, ScrH()/2)
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in client-side door management
        if entity:isDoor() then
            local locked = entity:getNetVar("locked", false)
            local color = locked and Color(255, 0, 0) or Color(0, 255, 0)
            draw.DrawText(locked and "Locked" or "Unlocked", "DermaDefault", ScrW()/2, ScrH()/2, color)
        end
        ```
]]
    function entityMeta:isDoor()
        if not IsValid(self) then return false end
        return self:GetClass():find("door")
    end

    --[[
    Purpose:
        Gets a network variable from the entity (client-side)
    When Called:
        When you need to retrieve synchronized data from an entity on the client
    Parameters:
        - key (string): The network variable key to retrieve
        - default (any, optional): Default value if the key doesn't exist
    Returns:
        any - The network variable value or default
    Realm:
        Client (can only be called on client)
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Get a network variable
        local health = entity:getNetVar("health", 100)
        ```

        Medium Complexity:

        ```lua
        -- Medium: Use in client-side logic
        local owner = entity:getNetVar("owner")
        if owner and owner == LocalPlayer() then
            print("You own this entity")
        end
        ```

        High Complexity:

        ```lua
        -- High: Use in client-side rendering
        local locked = entity:getNetVar("locked", false)
        local color = locked and Color(255, 0, 0) or Color(0, 255, 0)
        draw.DrawText(locked and "Locked" or "Unlocked", "DermaDefault", x, y, color)
        ```
]]
    function entityMeta:getNetVar(key, default)
        if not IsValid(self) then return default end
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    --[[
    Purpose:
        Plays a sound that follows the entity with 3D positioning and distance attenuation
    When Called:
        When you need to play a sound that moves with an entity
    Parameters:
        - soundPath (string): Path to the sound file or URL
        - volume (number, optional): Volume level (0-1, default: 1)
        - shouldFollow (boolean, optional): Whether sound should follow entity (default: true)
        - maxDistance (number, optional): Maximum audible distance (default: 1200)
        - startDelay (number, optional): Delay before playing (default: 0)
        - minDistance (number, optional): Minimum distance for full volume (default: 0)
        - pitch (number, optional): Pitch multiplier (default: 1)
        - _ (any, optional): Unused parameter
        - dsp (number, optional): DSP effect ID (default: 0)
    Returns:
        None
    Realm:
        Client (can only be called on client)
    Example Usage:
        Low Complexity:

        ```lua
        -- Simple: Play following sound
        entity:playFollowingSound("ambient/atmosphere/city_hum_loop.wav")
        ```

        Medium Complexity:

        ```lua
        -- Medium: Play with custom volume and distance
        entity:playFollowingSound("buttons/button15.wav", 0.5, true, 500)
        ```

        High Complexity:

        ```lua
        -- High: Play web sound with full parameters
        entity:playFollowingSound("https://example.com/sound.mp3", 0.8, true, 1000, 0.5, 100, 1.2, nil, 1)
        ```
]]
    function entityMeta:playFollowingSound(soundPath, volume, shouldFollow, maxDistance, startDelay, minDistance, pitch, _, dsp)
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

        if soundPath:find("^lilia/websounds/") or soundPath:find("^websounds/") or soundPath:find("^lilia/websounds/") or soundPath:find("^data/websounds/") then
            playLocalFile(soundPath)
            return
        end

        if lia.websound.get(soundPath) then
            playLocalFile(soundPath)
            return
        end
    end
end
