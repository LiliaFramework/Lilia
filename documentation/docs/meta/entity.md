# Entity Meta

This page documents methods available on the `Entity` meta table, representing game entities in the Lilia framework.

---

## Overview

The `Entity` meta table extends Garry's Mod's base entity functionality with Lilia-specific features including web sound support, entity type checking, door access control, vehicle ownership, networking, and various utility functions. These methods provide enhanced entity management capabilities for props, doors, vehicles, and other game objects within the Lilia framework.

---

### entityMeta:EmitSound

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio.

**Parameters**

* `soundName` (*string*): The sound name or URL to play.
* `soundLevel` (*number|nil*): Sound level for distance calculation.
* `pitchPercent` (*number|nil*): Pitch percentage for the sound.
* `volume` (*number|nil*): Volume level for the sound.
* `channel` (*number|nil*): Sound channel to use.
* `flags` (*number|nil*): Sound flags.
* `dsp` (*number|nil*): DSP effect to apply.

**Returns**

* `success` (*boolean*): True if the sound was emitted successfully.

**Realm**

Shared.

**Example Usage**

```lua
local function playWebSound(entity, soundURL)
    entity:EmitSound(soundURL, 100, 100, 1.0)
end

local function playLocalSound(entity, soundName)
    entity:EmitSound(soundName, 75, 100, 0.8)
end

hook.Add("OnEntityCreated", "PlayWelcomeSound", function(ent)
    if ent:GetClass() == "prop_physics" then
        playLocalSound(ent, "buttons/button15.wav")
    end
end)
```

---

### entityMeta:isProp

**Purpose**

Checks if the entity is a physics prop.

**Parameters**

*None.*

**Returns**

* `isProp` (*boolean*): True if the entity is a prop_physics.

**Realm**

Shared.

**Example Usage**

```lua
local function handlePropInteraction(entity, player)
    if entity:isProp() then
        player:ChatPrint("You interacted with a prop!")
        entity:EmitSound("buttons/button15.wav")
    end
end

hook.Add("OnPlayerUse", "HandlePropInteraction", function(ply, ent)
    if IsValid(ent) then
        handlePropInteraction(ent, ply)
    end
end)
```

---

### entityMeta:isItem

**Purpose**

Checks if the entity is a Lilia item entity.

**Parameters**

*None.*

**Returns**

* `isItem` (*boolean*): True if the entity is a lia_item.

**Realm**

Shared.

**Example Usage**

```lua
local function handleItemPickup(entity, player)
    if entity:isItem() then
        player:ChatPrint("You found an item!")
        local item = entity:getItem()
        if item then
            player:ChatPrint("Item: " .. item:getName())
        end
    end
end

hook.Add("OnPlayerUse", "HandleItemPickup", function(ply, ent)
    if IsValid(ent) then
        handleItemPickup(ent, ply)
    end
end)
```

---

### entityMeta:isMoney

**Purpose**

Checks if the entity is a Lilia money entity.

**Parameters**

*None.*

**Returns**

* `isMoney` (*boolean*): True if the entity is a lia_money.

**Realm**

Shared.

**Example Usage**

```lua
local function handleMoneyPickup(entity, player)
    if entity:isMoney() then
        player:ChatPrint("You found money!")
        local amount = entity:getAmount()
        if amount then
            player:ChatPrint("Amount: " .. amount)
        end
    end
end

hook.Add("OnPlayerUse", "HandleMoneyPickup", function(ply, ent)
    if IsValid(ent) then
        handleMoneyPickup(ent, ply)
    end
end)
```

---

### entityMeta:isSimfphysCar

**Purpose**

Checks if the entity is a Simfphys vehicle.

**Parameters**

*None.*

**Returns**

* `isSimfphysCar` (*boolean*): True if the entity is a Simfphys vehicle.

**Realm**

Shared.

**Example Usage**

```lua
local function handleVehicleInteraction(entity, player)
    if entity:isSimfphysCar() then
        player:ChatPrint("You interacted with a Simfphys vehicle!")
        if entity:GetDriver() then
            player:ChatPrint("The vehicle has a driver.")
        else
            player:ChatPrint("The vehicle is empty.")
        end
    end
end

hook.Add("OnPlayerUse", "HandleVehicleInteraction", function(ply, ent)
    if IsValid(ent) then
        handleVehicleInteraction(ent, ply)
    end
end)
```

---

### entityMeta:isLiliaPersistent

**Purpose**

Checks if the entity is marked as persistent in Lilia.

**Parameters**

*None.*

**Returns**

* `isPersistent` (*boolean*): True if the entity is persistent.

**Realm**

Shared.

**Example Usage**

```lua
local function checkEntityPersistence(entity)
    if entity:isLiliaPersistent() then
        print("Entity " .. entity:EntIndex() .. " is persistent and will be saved.")
    else
        print("Entity " .. entity:EntIndex() .. " is not persistent.")
    end
end

hook.Add("EntityCreated", "CheckPersistence", function(ent)
    if IsValid(ent) then
        checkEntityPersistence(ent)
    end
end)
```

---

### entityMeta:checkDoorAccess

**Purpose**

Checks if a client has access to a door with the specified access level.

**Parameters**

* `client` (*Player*): The client to check access for.
* `access` (*number|nil*): The access level to check (default: DOOR_GUEST).

**Returns**

* `hasAccess` (*boolean*): True if the client has access to the door.

**Realm**

Shared.

**Example Usage**

```lua
local function checkDoorPermission(door, player, accessLevel)
    if door:checkDoorAccess(player, accessLevel) then
        player:ChatPrint("You have access to this door!")
        return true
    else
        player:ChatPrint("You don't have access to this door.")
        return false
    end
end

hook.Add("OnPlayerUse", "CheckDoorAccess", function(ply, ent)
    if IsValid(ent) and ent:isDoor() then
        checkDoorPermission(ent, ply, DOOR_GUEST)
    end
end)
```

---

### entityMeta:keysOwn

**Purpose**

Sets the owner of a vehicle entity.

**Parameters**

* `client` (*Player*): The client to set as owner.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function giveVehicleOwnership(vehicle, player)
    if IsValid(vehicle) and vehicle:IsVehicle() then
        vehicle:keysOwn(player)
        player:ChatPrint("You now own this vehicle!")
    end
end

concommand.Add("own_vehicle", function(ply)
    local vehicle = ply:getTracedEntity()
    if IsValid(vehicle) and vehicle:IsVehicle() then
        giveVehicleOwnership(vehicle, ply)
    end
end)
```

---

### entityMeta:keysLock

**Purpose**

Locks a vehicle entity.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function lockVehicle(vehicle)
    if IsValid(vehicle) and vehicle:IsVehicle() then
        vehicle:keysLock()
        print("Vehicle locked.")
    end
end

concommand.Add("lock_vehicle", function(ply)
    local vehicle = ply:getTracedEntity()
    if IsValid(vehicle) and vehicle:IsVehicle() then
        lockVehicle(vehicle)
    end
end)
```

---

### entityMeta:keysUnLock

**Purpose**

Unlocks a vehicle entity.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function unlockVehicle(vehicle)
    if IsValid(vehicle) and vehicle:IsVehicle() then
        vehicle:keysUnLock()
        print("Vehicle unlocked.")
    end
end

concommand.Add("unlock_vehicle", function(ply)
    local vehicle = ply:getTracedEntity()
    if IsValid(vehicle) and vehicle:IsVehicle() then
        unlockVehicle(vehicle)
    end
end)
```

---

### entityMeta:getDoorOwner

**Purpose**

Gets the owner of a door entity.

**Parameters**

*None.*

**Returns**

* `owner` (*Player|nil*): The door owner if it's a vehicle, otherwise nil.

**Realm**

Shared.

**Example Usage**

```lua
local function checkDoorOwnership(door, player)
    local owner = door:getDoorOwner()
    if IsValid(owner) then
        player:ChatPrint("Door owner: " .. owner:Name())
    else
        player:ChatPrint("This door has no owner.")
    end
end

hook.Add("OnPlayerUse", "CheckDoorOwnership", function(ply, ent)
    if IsValid(ent) and ent:isDoor() then
        checkDoorOwnership(ent, ply)
    end
end)
```

---

### entityMeta:isLocked

**Purpose**

Checks if the entity is locked via networked variables.

**Parameters**

*None.*

**Returns**

* `isLocked` (*boolean*): True if the entity is locked.

**Realm**

Shared.

**Example Usage**

```lua
local function checkEntityLock(entity, player)
    if entity:isLocked() then
        player:ChatPrint("This entity is locked!")
    else
        player:ChatPrint("This entity is unlocked.")
    end
end

hook.Add("OnPlayerUse", "CheckEntityLock", function(ply, ent)
    if IsValid(ent) then
        checkEntityLock(ent, ply)
    end
end)
```

---

### entityMeta:isDoorLocked

**Purpose**

Checks if a door entity is locked via internal variables.

**Parameters**

*None.*

**Returns**

* `isLocked` (*boolean*): True if the door is locked.

**Realm**

Shared.

**Example Usage**

```lua
local function checkDoorLock(door, player)
    if door:isDoorLocked() then
        player:ChatPrint("This door is locked!")
    else
        player:ChatPrint("This door is unlocked.")
    end
end

hook.Add("OnPlayerUse", "CheckDoorLock", function(ply, ent)
    if IsValid(ent) and ent:isDoor() then
        checkDoorLock(ent, ply)
    end
end)
```

---

### entityMeta:getEntItemDropPos

**Purpose**

Gets the position and angle where items should be dropped from this entity.

**Parameters**

* `offset` (*number|nil*): Distance offset for the drop position (default: 64).

**Returns**

* `position` (*Vector*): The drop position.
* `angle` (*Angle*): The drop angle.

**Realm**

Shared.

**Example Usage**

```lua
local function dropItemFromEntity(entity, item)
    local pos, ang = entity:getEntItemDropPos(100)
    if item then
        item:spawn(pos, ang)
        print("Item dropped at position: " .. tostring(pos))
    end
end

concommand.Add("drop_item", function(ply, cmd, args)
    local ent = ply:getTracedEntity()
    local itemID = tonumber(args[1])
    if IsValid(ent) and itemID then
        local item = lia.item.instances[itemID]
        if item then
            dropItemFromEntity(ent, item)
        end
    end
end)
```

---

### entityMeta:isFemale

**Purpose**

Checks if the entity's model represents a female character.

**Parameters**

*None.*

**Returns**

* `isFemale` (*boolean*): True if the entity is female.

**Realm**

Shared.

**Example Usage**

```lua
local function checkEntityGender(entity, player)
    if entity:isFemale() then
        player:ChatPrint("This is a female character.")
    else
        player:ChatPrint("This is a male character.")
    end
end

hook.Add("OnPlayerUse", "CheckGender", function(ply, ent)
    if IsValid(ent) and ent:IsPlayer() then
        checkEntityGender(ent, ply)
    end
end)
```

---

### entityMeta:isNearEntity

**Purpose**

Checks if the entity is near another entity within a specified radius.

**Parameters**

* `radius` (*number|nil*): Search radius (default: 96).
* `otherEntity` (*Entity*): The entity to check proximity to.

**Returns**

* `isNear` (*boolean*): True if the entity is near the other entity.

**Realm**

Shared.

**Example Usage**

```lua
local function checkEntityProximity(entity, targetEntity, radius)
    if entity:isNearEntity(radius, targetEntity) then
        print("Entity " .. entity:EntIndex() .. " is near entity " .. targetEntity:EntIndex())
        return true
    else
        print("Entity " .. entity:EntIndex() .. " is not near entity " .. targetEntity:EntIndex())
        return false
    end
end

hook.Add("Think", "CheckProximity", function()
    for _, ent1 in pairs(ents.FindByClass("prop_physics")) do
        for _, ent2 in pairs(ents.FindByClass("lia_item")) do
            checkEntityProximity(ent1, ent2, 50)
        end
    end
end)
```

---

### entityMeta:GetCreator

**Purpose**

Gets the creator of the entity via networked variables.

**Parameters**

*None.*

**Returns**

* `creator` (*Player|nil*): The entity creator if set.

**Realm**

Shared.

**Example Usage**

```lua
local function checkEntityCreator(entity, player)
    local creator = entity:GetCreator()
    if IsValid(creator) then
        player:ChatPrint("This entity was created by: " .. creator:Name())
    else
        player:ChatPrint("This entity has no known creator.")
    end
end

hook.Add("OnPlayerUse", "CheckCreator", function(ply, ent)
    if IsValid(ent) then
        checkEntityCreator(ent, ply)
    end
end)
```

---

### entityMeta:SetCreator

**Purpose**

Sets the creator of the entity via networked variables.

**Parameters**

* `client` (*Player*): The client to set as creator.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setEntityCreator(entity, player)
    if IsValid(entity) then
        entity:SetCreator(player)
        player:ChatPrint("You are now the creator of this entity.")
    end
end

concommand.Add("set_creator", function(ply)
    local ent = ply:getTracedEntity()
    if IsValid(ent) then
        setEntityCreator(ent, ply)
    end
end)
```

---

### entityMeta:sendNetVar

**Purpose**

Sends a networked variable to a specific client or all clients.

**Parameters**

* `key` (*string*): The networked variable key to send.
* `receiver` (*Player|nil*): Specific client to send to, or nil for all clients.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function updateEntityData(entity, key, value, targetPlayer)
    entity:setNetVar(key, value)
    entity:sendNetVar(key, targetPlayer)
    if IsValid(targetPlayer) then
        targetPlayer:ChatPrint("Entity data updated and sent to you.")
    else
        print("Entity data updated and broadcasted.")
    end
end

concommand.Add("update_entity_data", function(ply, cmd, args)
    local ent = ply:getTracedEntity()
    local key = args[1]
    local value = args[2]
    if IsValid(ent) and key and value then
        updateEntityData(ent, key, value, ply)
    end
end)
```

---

### entityMeta:clearNetVars

**Purpose**

Clears all networked variables for the entity and notifies clients.

**Parameters**

* `receiver` (*Player|nil*): Specific client to notify, or nil for all clients.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function clearEntityData(entity, targetPlayer)
    entity:clearNetVars(targetPlayer)
    if IsValid(targetPlayer) then
        targetPlayer:ChatPrint("Entity data cleared for you.")
    else
        print("Entity data cleared for all clients.")
    end
end

concommand.Add("clear_entity_data", function(ply)
    local ent = ply:getTracedEntity()
    if IsValid(ent) then
        clearEntityData(ent, ply)
    end
end)
```

---

### entityMeta:removeDoorAccessData

**Purpose**

Removes all door access data and notifies affected clients.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function resetDoorAccess(door)
    if IsValid(door) and door:isDoor() then
        door:removeDoorAccessData()
        print("Door access data cleared.")
    end
end

concommand.Add("reset_door_access", function(ply)
    local door = ply:getTracedEntity()
    if IsValid(door) and door:isDoor() then
        resetDoorAccess(door)
    end
end)
```

---

### entityMeta:setLocked

**Purpose**

Sets the locked state of the entity via networked variables.

**Parameters**

* `state` (*boolean*): Whether the entity should be locked.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function toggleEntityLock(entity, player)
    local currentState = entity:isLocked()
    entity:setLocked(not currentState)
    player:ChatPrint("Entity " .. (not currentState and "locked" or "unlocked") .. "!")
end

concommand.Add("toggle_lock", function(ply)
    local ent = ply:getTracedEntity()
    if IsValid(ent) then
        toggleEntityLock(ent, ply)
    end
end)
```

---

### entityMeta:setKeysNonOwnable

**Purpose**

Sets whether the entity can be owned via networked variables.

**Parameters**

* `state` (*boolean*): Whether the entity should be non-ownable.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setEntityOwnable(entity, ownable, player)
    entity:setKeysNonOwnable(not ownable)
    player:ChatPrint("Entity is now " .. (ownable and "ownable" or "non-ownable") .. "!")
end

concommand.Add("set_ownable", function(ply, cmd, args)
    local ent = ply:getTracedEntity()
    local ownable = tobool(args[1])
    if IsValid(ent) then
        setEntityOwnable(ent, ownable, ply)
    end
end)
```

---

### entityMeta:isDoor

**Purpose**

Checks if the entity is a door based on its class name.

**Parameters**

*None.*

**Returns**

* `isDoor` (*boolean*): True if the entity is a door.

**Realm**

Shared.

**Example Usage**

```lua
local function handleDoorInteraction(entity, player)
    if entity:isDoor() then
        player:ChatPrint("You interacted with a door!")
        if entity:isDoorLocked() then
            player:ChatPrint("The door is locked.")
        else
            player:ChatPrint("The door is unlocked.")
        end
    end
end

hook.Add("OnPlayerUse", "HandleDoorInteraction", function(ply, ent)
    if IsValid(ent) then
        handleDoorInteraction(ent, ply)
    end
end)
```

---

### entityMeta:getDoorPartner

**Purpose**

Gets the partner door entity if this is a double door.

**Parameters**

*None.*

**Returns**

* `partner` (*Entity|nil*): The partner door entity if it exists.

**Realm**

Shared.

**Example Usage**

```lua
local function checkDoorPartnership(door, player)
    local partner = door:getDoorPartner()
    if IsValid(partner) then
        player:ChatPrint("This door has a partner door.")
    else
        player:ChatPrint("This door is standalone.")
    end
end

hook.Add("OnPlayerUse", "CheckDoorPartnership", function(ply, ent)
    if IsValid(ent) and ent:isDoor() then
        checkDoorPartnership(ent, ply)
    end
end)
```

---

### entityMeta:setNetVar

**Purpose**

Sets a networked variable on the entity and replicates it to clients.

**Parameters**

* `key` (*string*): The networked variable key.
* `value` (*any*): The value to set.
* `receiver` (*Player|nil*): Specific client to send to, or nil for all clients.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setEntityCustomData(entity, key, value, targetPlayer)
    entity:setNetVar(key, value, targetPlayer)
    if IsValid(targetPlayer) then
        targetPlayer:ChatPrint("Set " .. key .. " to " .. tostring(value))
    end
end

concommand.Add("set_entity_var", function(ply, cmd, args)
    local ent = ply:getTracedEntity()
    local key = args[1]
    local value = args[2]
    if IsValid(ent) and key and value then
        setEntityCustomData(ent, key, value, ply)
    end
end)
```

---

### entityMeta:getNetVar

**Purpose**

Gets a networked variable value from the entity.

**Parameters**

* `key` (*string*): The networked variable key.
* `default` (*any*): Default value if the key doesn't exist.

**Returns**

* `value` (*any*): The networked variable value or default.

**Realm**

Shared.

**Example Usage**

```lua
local function getEntityCustomData(entity, key, player)
    local value = entity:getNetVar(key, "not set")
    if IsValid(player) then
        player:ChatPrint(key .. ": " .. tostring(value))
    end
end

concommand.Add("get_entity_var", function(ply, cmd, args)
    local ent = ply:getTracedEntity()
    local key = args[1]
    if IsValid(ent) and key then
        getEntityCustomData(ent, key, ply)
    end
end)
```

---

### entityMeta:PlayFollowingSound

**Purpose**

Plays a sound that follows the entity with 3D positioning and distance attenuation.

**Parameters**

* `soundPath` (*string*): Path to the sound file or URL.
* `volume` (*number|nil*): Volume level (0-1).
* `shouldFollow` (*boolean|nil*): Whether the sound should follow the entity.
* `maxDistance` (*number|nil*): Maximum distance for sound attenuation.
* `startDelay` (*number|nil*): Delay before starting the sound.
* `minDistance` (*number|nil*): Minimum distance for sound attenuation.
* `pitch` (*number|nil*): Pitch multiplier for the sound.
* `dsp` (*number|nil*): DSP effect to apply.

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function playAmbientSound(entity, soundPath)
    entity:PlayFollowingSound(soundPath, 0.8, true, 500, 0, 0, 1.0)
end

local function playWebSound(entity, soundURL)
    entity:PlayFollowingSound(soundURL, 1.0, true, 1000)
end

hook.Add("EntityCreated", "PlayAmbientSound", function(ent)
    if ent:GetClass() == "prop_physics" then
        playAmbientSound(ent, "ambient/atmosphere/city_rumble_loop1.wav")
    end
end)
```

---
