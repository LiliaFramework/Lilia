# Hooks

This document describes the hooks available in the Simple Lockpicking module for managing lockpicking functionality.

---

## CanPlayerLockpick

**Purpose**

Called to determine if a player can lockpick an entity.

**Parameters**

* `player` (*Player*): The player attempting to lockpick.
* `target` (*Entity*): The entity being lockpicked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to lockpick an entity
- Before `LockpickStart` hook
- Before any lockpicking validation

**Example Usage**

```lua
-- Control lockpicking
hook.Add("CanPlayerLockpick", "ControlLockpicking", function(player, target)
    local char = player:getChar()
    if char then
        -- Check if lockpicking is disabled
        if char:getData("lockpicking_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if player:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if player:WaterLevel() >= 2 then
            return false
        end
        
        -- Check if player is handcuffed
        if player:IsHandcuffed() then
            return false
        end
        
        -- Check cooldown
        local lastLockpick = char:getData("last_lockpick_time", 0)
        if os.time() - lastLockpick < 5 then -- 5 second cooldown
            return false
        end
        
        -- Update last lockpick time
        char:setData("last_lockpick_time", os.time())
    end
    
    return true
end)

-- Track lockpicking attempts
hook.Add("CanPlayerLockpick", "TrackLockpickingAttempts", function(player, target)
    local char = player:getChar()
    if char then
        local lockpickingAttempts = char:getData("lockpicking_attempts", 0)
        char:setData("lockpicking_attempts", lockpickingAttempts + 1)
    end
end)

-- Apply lockpicking check effects
hook.Add("CanPlayerLockpick", "LockpickingCheckEffects", function(player, target)
    local char = player:getChar()
    if char then
        -- Check if lockpicking is disabled
        if char:getData("lockpicking_disabled", false) then
            player:notify("Lockpicking is disabled!")
        end
    end
end)
```

---

## LockpickFinished

**Purpose**

Called when lockpicking is finished (successful or interrupted).

**Parameters**

* `player` (*Player*): The player who was lockpicking.
* `target` (*Entity*): The entity that was being lockpicked.
* `success` (*boolean*): Whether the lockpicking was successful.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Lockpicking is finished (successful or interrupted)
- After `LockpickSuccess` or `LockpickInterrupted` hook
- When the lockpicking process ends

**Example Usage**

```lua
-- Track lockpicking completion
hook.Add("LockpickFinished", "TrackLockpickingCompletion", function(player, target, success)
    local char = player:getChar()
    if char then
        local lockpickingCompletions = char:getData("lockpicking_completions", 0)
        char:setData("lockpicking_completions", lockpickingCompletions + 1)
        
        -- Track success/failure patterns
        local successPatterns = char:getData("lockpicking_success_patterns", {})
        successPatterns[success] = (successPatterns[success] or 0) + 1
        char:setData("lockpicking_success_patterns", successPatterns)
    end
    
    lia.log.add(player, "lockpickFinished", target, success)
end)

-- Apply lockpicking completion effects
hook.Add("LockpickFinished", "LockpickingCompletionEffects", function(player, target, success)
    -- Play completion sound
    player:EmitSound(success and "buttons/button14.wav" or "buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, success and Color(0, 255, 0, 15) or Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    local status = success and "successful" or "interrupted"
    player:notify("Lockpicking " .. status .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lockpicking completion statistics
hook.Add("LockpickFinished", "TrackLockpickingCompletionStats", function(player, target, success)
    local char = player:getChar()
    if char then
        -- Track completion frequency
        local completionFrequency = char:getData("lockpicking_completion_frequency", 0)
        char:setData("lockpicking_completion_frequency", completionFrequency + 1)
        
        -- Track completion patterns
        local completionPatterns = char:getData("lockpicking_completion_patterns", {})
        table.insert(completionPatterns, {
            target = target:GetClass(),
            success = success,
            time = os.time()
        })
        char:setData("lockpicking_completion_patterns", completionPatterns)
    end
end)
```

---

## LockpickInterrupted

**Purpose**

Called when lockpicking is interrupted.

**Parameters**

* `player` (*Player*): The player whose lockpicking was interrupted.
* `target` (*Entity*): The entity that was being lockpicked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Lockpicking is interrupted
- Before `LockpickFinished` hook
- When the lockpicking process is stopped

**Example Usage**

```lua
-- Track lockpicking interruptions
hook.Add("LockpickInterrupted", "TrackLockpickingInterruptions", function(player, target)
    local char = player:getChar()
    if char then
        local lockpickingInterruptions = char:getData("lockpicking_interruptions", 0)
        char:setData("lockpicking_interruptions", lockpickingInterruptions + 1)
    end
    
    lia.log.add(player, "lockpickInterrupted", target)
end)

-- Apply lockpicking interruption effects
hook.Add("LockpickInterrupted", "LockpickingInterruptionEffects", function(player, target)
    -- Play interruption sound
    player:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Lockpicking interrupted!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lockpicking interruption statistics
hook.Add("LockpickInterrupted", "TrackLockpickingInterruptionStats", function(player, target)
    local char = player:getChar()
    if char then
        -- Track interruption frequency
        local interruptionFrequency = char:getData("lockpicking_interruption_frequency", 0)
        char:setData("lockpicking_interruption_frequency", interruptionFrequency + 1)
        
        -- Track interruption patterns
        local interruptionPatterns = char:getData("lockpicking_interruption_patterns", {})
        table.insert(interruptionPatterns, {
            target = target:GetClass(),
            time = os.time()
        })
        char:setData("lockpicking_interruption_patterns", interruptionPatterns)
    end
end)
```

---

## LockpickStart

**Purpose**

Called when lockpicking starts.

**Parameters**

* `player` (*Player*): The player starting to lockpick.
* `target` (*Entity*): The entity being lockpicked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Lockpicking starts
- After `CanPlayerLockpick` hook
- When the lockpicking process begins

**Example Usage**

```lua
-- Track lockpicking starts
hook.Add("LockpickStart", "TrackLockpickingStarts", function(player, target)
    local char = player:getChar()
    if char then
        local lockpickingStarts = char:getData("lockpicking_starts", 0)
        char:setData("lockpicking_starts", lockpickingStarts + 1)
    end
    
    lia.log.add(player, "lockpickStart", target)
end)

-- Apply lockpicking start effects
hook.Add("LockpickStart", "LockpickingStartEffects", function(player, target)
    -- Play start sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    player:notify("Starting to lockpick...")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lockpicking start statistics
hook.Add("LockpickStart", "TrackLockpickingStartStats", function(player, target)
    local char = player:getChar()
    if char then
        -- Track start frequency
        local startFrequency = char:getData("lockpicking_start_frequency", 0)
        char:setData("lockpicking_start_frequency", startFrequency + 1)
        
        -- Track start patterns
        local startPatterns = char:getData("lockpicking_start_patterns", {})
        table.insert(startPatterns, {
            target = target:GetClass(),
            time = os.time()
        })
        char:setData("lockpicking_start_patterns", startPatterns)
    end
end)
```

---

## LockpickSuccess

**Purpose**

Called when lockpicking is successful.

**Parameters**

* `player` (*Player*): The player who successfully lockpicked.
* `target` (*Entity*): The entity that was successfully lockpicked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Lockpicking is successful
- Before `LockpickFinished` hook
- When the entity is unlocked

**Example Usage**

```lua
-- Track lockpicking successes
hook.Add("LockpickSuccess", "TrackLockpickingSuccesses", function(player, target)
    local char = player:getChar()
    if char then
        local lockpickingSuccesses = char:getData("lockpicking_successes", 0)
        char:setData("lockpicking_successes", lockpickingSuccesses + 1)
    end
    
    lia.log.add(player, "lockpickSuccess", target)
end)

-- Apply lockpicking success effects
hook.Add("LockpickSuccess", "LockpickingSuccessEffects", function(player, target)
    -- Play success sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Lockpicking successful!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lockpicking success statistics
hook.Add("LockpickSuccess", "TrackLockpickingSuccessStats", function(player, target)
    local char = player:getChar()
    if char then
        -- Track success frequency
        local successFrequency = char:getData("lockpicking_success_frequency", 0)
        char:setData("lockpicking_success_frequency", successFrequency + 1)
        
        -- Track success patterns
        local successPatterns = char:getData("lockpicking_success_patterns", {})
        table.insert(successPatterns, {
            target = target:GetClass(),
            time = os.time()
        })
        char:setData("lockpicking_success_patterns", successPatterns)
    end
end)
```
