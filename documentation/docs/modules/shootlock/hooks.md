# Hooks

This document describes the hooks available in the Shoot Lock module for managing door lock shooting functionality.

---

## CanPlayerBustLock

**Purpose**

Called to determine if a player can bust a lock by shooting it.

**Parameters**

* `client` (*Player*): The player attempting to bust the lock.
* `entity` (*Entity*): The door entity being shot.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to bust a lock by shooting it
- Before `LockShotBreach` hook
- Before any lock busting validation

**Example Usage**

```lua
-- Control lock busting
hook.Add("CanPlayerBustLock", "ControlLockBusting", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check if lock busting is disabled
        if char:getData("lock_busting_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if player is in a vehicle
        if client:InVehicle() then
            return false
        end
        
        -- Check if player is in water
        if client:WaterLevel() >= 2 then
            return false
        end
        
        -- Check if player is handcuffed
        if client:IsHandcuffed() then
            return false
        end
        
        -- Check cooldown
        local lastLockBust = char:getData("last_lock_bust_time", 0)
        if os.time() - lastLockBust < 3 then -- 3 second cooldown
            return false
        end
        
        -- Update last lock bust time
        char:setData("last_lock_bust_time", os.time())
    end
    
    return true
end)

-- Track lock busting attempts
hook.Add("CanPlayerBustLock", "TrackLockBustingAttempts", function(client, entity)
    local char = client:getChar()
    if char then
        local bustingAttempts = char:getData("lock_busting_attempts", 0)
        char:setData("lock_busting_attempts", bustingAttempts + 1)
    end
end)

-- Apply lock busting check effects
hook.Add("CanPlayerBustLock", "LockBustingCheckEffects", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check if lock busting is disabled
        if char:getData("lock_busting_disabled", false) then
            client:notify("Lock busting is disabled!")
        end
    end
end)
```

---

## LockShotAttempt

**Purpose**

Called when a lock shot attempt is made.

**Parameters**

* `client` (*Player*): The player attempting to shoot the lock.
* `entity` (*Entity*): The door entity being shot.
* `dmgInfo` (*CTakeDamageInfo*): The damage information.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to shoot a door lock
- Before `CanPlayerBustLock` hook
- When the shot is detected

**Example Usage**

```lua
-- Track lock shot attempts
hook.Add("LockShotAttempt", "TrackLockShotAttempts", function(client, entity, dmgInfo)
    local char = client:getChar()
    if char then
        local shotAttempts = char:getData("lock_shot_attempts", 0)
        char:setData("lock_shot_attempts", shotAttempts + 1)
    end
    
    lia.log.add(client, "lockShotAttempt", entity)
end)

-- Apply lock shot attempt effects
hook.Add("LockShotAttempt", "LockShotAttemptEffects", function(client, entity, dmgInfo)
    -- Play attempt sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Lock shot attempt made!")
end)

-- Track lock shot attempt statistics
hook.Add("LockShotAttempt", "TrackLockShotAttemptStats", function(client, entity, dmgInfo)
    local char = client:getChar()
    if char then
        -- Track attempt frequency
        local attemptFrequency = char:getData("lock_shot_attempt_frequency", 0)
        char:setData("lock_shot_attempt_frequency", attemptFrequency + 1)
        
        -- Track attempt patterns
        local attemptPatterns = char:getData("lock_shot_attempt_patterns", {})
        table.insert(attemptPatterns, {
            entity = entity:GetClass(),
            time = os.time()
        })
        char:setData("lock_shot_attempt_patterns", attemptPatterns)
    end
end)
```

---

## LockShotBreach

**Purpose**

Called when a lock is successfully breached by shooting.

**Parameters**

* `client` (*Player*): The player who breached the lock.
* `entity` (*Entity*): The door entity that was breached.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A lock is successfully breached by shooting
- After `CanPlayerBustLock` hook
- When the door is unlocked

**Example Usage**

```lua
-- Track lock shot breaches
hook.Add("LockShotBreach", "TrackLockShotBreaches", function(client, entity)
    local char = client:getChar()
    if char then
        local shotBreaches = char:getData("lock_shot_breaches", 0)
        char:setData("lock_shot_breaches", shotBreaches + 1)
    end
    
    lia.log.add(client, "lockShotBreach", entity)
end)

-- Apply lock shot breach effects
hook.Add("LockShotBreach", "LockShotBreachEffects", function(client, entity)
    -- Play breach sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Lock breached successfully!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lock shot breach statistics
hook.Add("LockShotBreach", "TrackLockShotBreachStats", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track breach frequency
        local breachFrequency = char:getData("lock_shot_breach_frequency", 0)
        char:setData("lock_shot_breach_frequency", breachFrequency + 1)
        
        -- Track breach patterns
        local breachPatterns = char:getData("lock_shot_breach_patterns", {})
        table.insert(breachPatterns, {
            entity = entity:GetClass(),
            time = os.time()
        })
        char:setData("lock_shot_breach_patterns", breachPatterns)
    end
end)
```

---

## LockShotFailed

**Purpose**

Called when a lock shot attempt fails.

**Parameters**

* `client` (*Player*): The player whose lock shot failed.
* `entity` (*Entity*): The door entity that was shot.
* `dmgInfo` (*CTakeDamageInfo*): The damage information.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A lock shot attempt fails
- When the shot doesn't hit the lock properly
- After `LockShotAttempt` hook

**Example Usage**

```lua
-- Track lock shot failures
hook.Add("LockShotFailed", "TrackLockShotFailures", function(client, entity, dmgInfo)
    local char = client:getChar()
    if char then
        local shotFailures = char:getData("lock_shot_failures", 0)
        char:setData("lock_shot_failures", shotFailures + 1)
    end
    
    lia.log.add(client, "lockShotFailed", entity)
end)

-- Apply lock shot failure effects
hook.Add("LockShotFailed", "LockShotFailureEffects", function(client, entity, dmgInfo)
    -- Play failure sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Lock shot failed!")
end)

-- Track lock shot failure statistics
hook.Add("LockShotFailed", "TrackLockShotFailureStats", function(client, entity, dmgInfo)
    local char = client:getChar()
    if char then
        -- Track failure frequency
        local failureFrequency = char:getData("lock_shot_failure_frequency", 0)
        char:setData("lock_shot_failure_frequency", failureFrequency + 1)
        
        -- Track failure patterns
        local failurePatterns = char:getData("lock_shot_failure_patterns", {})
        table.insert(failurePatterns, {
            entity = entity:GetClass(),
            time = os.time()
        })
        char:setData("lock_shot_failure_patterns", failurePatterns)
    end
end)
```

---

## LockShotSuccess

**Purpose**

Called when a lock shot is successful.

**Parameters**

* `client` (*Player*): The player who successfully shot the lock.
* `entity` (*Entity*): The door entity that was successfully shot.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A lock shot is successful
- After `LockShotBreach` hook
- When the door is unlocked

**Example Usage**

```lua
-- Track lock shot successes
hook.Add("LockShotSuccess", "TrackLockShotSuccesses", function(client, entity)
    local char = client:getChar()
    if char then
        local shotSuccesses = char:getData("lock_shot_successes", 0)
        char:setData("lock_shot_successes", shotSuccesses + 1)
    end
    
    lia.log.add(client, "lockShotSuccess", entity)
end)

-- Apply lock shot success effects
hook.Add("LockShotSuccess", "LockShotSuccessEffects", function(client, entity)
    -- Play success sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Lock shot successful!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track lock shot success statistics
hook.Add("LockShotSuccess", "TrackLockShotSuccessStats", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track success frequency
        local successFrequency = char:getData("lock_shot_success_frequency", 0)
        char:setData("lock_shot_success_frequency", successFrequency + 1)
        
        -- Track success patterns
        local successPatterns = char:getData("lock_shot_success_patterns", {})
        table.insert(successPatterns, {
            entity = entity:GetClass(),
            time = os.time()
        })
        char:setData("lock_shot_success_patterns", successPatterns)
    end
end)
```
