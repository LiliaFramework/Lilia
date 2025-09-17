# Hooks

This document describes the hooks available in the Door Kick module for managing door kicking functionality.

---

## DoorKickedOpen

**Purpose**

Called when a door has been successfully kicked open.

**Parameters**

* `client` (*Player*): The player who kicked the door.
* `door` (*Entity*): The door entity that was kicked open.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A door has been successfully kicked open
- The kick animation and unlock sequence completes
- After `DoorKickStarted` hook

**Example Usage**

```lua
-- Track door kick success
hook.Add("DoorKickedOpen", "TrackDoorKickSuccess", function(client, door)
    local char = client:getChar()
    if char then
        local doorKicks = char:getData("door_kicks", 0)
        char:setData("door_kicks", doorKicks + 1)
        
        -- Track door types
        local doorTypes = char:getData("door_kick_types", {})
        local doorClass = door:GetClass()
        doorTypes[doorClass] = (doorTypes[doorClass] or 0) + 1
        char:setData("door_kick_types", doorTypes)
    end
    
    lia.log.add(client, "doorKickedOpen", door)
end)

-- Apply door kick success effects
hook.Add("DoorKickedOpen", "DoorKickSuccessEffects", function(client, door)
    -- Play success sound
    client:EmitSound("doors/door_metal_thin_open1.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Door kicked open successfully!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(door:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track door kick success statistics
hook.Add("DoorKickedOpen", "TrackDoorKickSuccessStats", function(client, door)
    local char = client:getChar()
    if char then
        -- Track success frequency
        local successFrequency = char:getData("door_kick_success_frequency", 0)
        char:setData("door_kick_success_frequency", successFrequency + 1)
        
        -- Track success patterns
        local successPatterns = char:getData("door_kick_success_patterns", {})
        table.insert(successPatterns, {
            door = door:GetClass(),
            time = os.time()
        })
        char:setData("door_kick_success_patterns", successPatterns)
    end
end)
```

---

## DoorKickFailed

**Purpose**

Called when a door kick attempt fails.

**Parameters**

* `client` (*Player*): The player who attempted to kick the door.
* `door` (*Entity*): The door entity that was attempted to be kicked.
* `reason` (*string*): The reason for the failure ("disabled", "weak", "cannotKick", "tooClose", "tooFar", "invalid").

**Realm**

Server.

**When Called**

This hook is triggered when:
- A door kick attempt fails
- The player doesn't meet the requirements
- Before `DoorKickStarted` hook

**Example Usage**

```lua
-- Track door kick failures
hook.Add("DoorKickFailed", "TrackDoorKickFailures", function(client, door, reason)
    local char = client:getChar()
    if char then
        local doorKickFailures = char:getData("door_kick_failures", 0)
        char:setData("door_kick_failures", doorKickFailures + 1)
        
        -- Track failure reasons
        local failureReasons = char:getData("door_kick_failure_reasons", {})
        failureReasons[reason] = (failureReasons[reason] or 0) + 1
        char:setData("door_kick_failure_reasons", failureReasons)
    end
    
    lia.log.add(client, "doorKickFailed", door, reason)
end)

-- Apply door kick failure effects
hook.Add("DoorKickFailed", "DoorKickFailureEffects", function(client, door, reason)
    -- Play failure sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player based on reason
    local messages = {
        disabled = "Door kicking is disabled!",
        weak = "You are too weak to kick this door!",
        cannotKick = "You cannot kick this door!",
        tooClose = "You are too close to kick the door!",
        tooFar = "You are too far from the door!",
        invalid = "Invalid door target!"
    }
    
    client:notify(messages[reason] or "Door kick failed!")
end)

-- Track door kick failure statistics
hook.Add("DoorKickFailed", "TrackDoorKickFailureStats", function(client, door, reason)
    local char = client:getChar()
    if char then
        -- Track failure frequency
        local failureFrequency = char:getData("door_kick_failure_frequency", 0)
        char:setData("door_kick_failure_frequency", failureFrequency + 1)
        
        -- Track failure patterns
        local failurePatterns = char:getData("door_kick_failure_patterns", {})
        table.insert(failurePatterns, {
            door = door:GetClass(),
            reason = reason,
            time = os.time()
        })
        char:setData("door_kick_failure_patterns", failurePatterns)
    end
end)
```

---

## DoorKickStarted

**Purpose**

Called when a door kick attempt is started.

**Parameters**

* `client` (*Player*): The player who is starting to kick the door.
* `door` (*Entity*): The door entity being kicked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A door kick attempt is started
- The player meets the requirements
- Before the kick animation begins

**Example Usage**

```lua
-- Track door kick attempts
hook.Add("DoorKickStarted", "TrackDoorKickAttempts", function(client, door)
    local char = client:getChar()
    if char then
        local doorKickAttempts = char:getData("door_kick_attempts", 0)
        char:setData("door_kick_attempts", doorKickAttempts + 1)
    end
    
    lia.log.add(client, "doorKickStarted", door)
end)

-- Apply door kick start effects
hook.Add("DoorKickStarted", "DoorKickStartEffects", function(client, door)
    -- Play start sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Starting to kick the door...")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(door:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track door kick start statistics
hook.Add("DoorKickStarted", "TrackDoorKickStartStats", function(client, door)
    local char = client:getChar()
    if char then
        -- Track start frequency
        local startFrequency = char:getData("door_kick_start_frequency", 0)
        char:setData("door_kick_start_frequency", startFrequency + 1)
        
        -- Track start patterns
        local startPatterns = char:getData("door_kick_start_patterns", {})
        table.insert(startPatterns, {
            door = door:GetClass(),
            time = os.time()
        })
        char:setData("door_kick_start_patterns", startPatterns)
    end
end)
```
