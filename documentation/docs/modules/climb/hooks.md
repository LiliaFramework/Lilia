# Hooks

This document describes the hooks available in the Climb module for managing player climbing mechanics and ledge climbing.

---

## PlayerBeginClimb

**Purpose**

Called when a player begins climbing a ledge.

**Parameters**

* `player` (*Player*): The player who is beginning to climb.
* `distance` (*number*): The distance to the ledge being climbed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player successfully attempts to climb a ledge
- The climb trace detects a valid climbable surface
- Before the player's velocity is modified

**Example Usage**

```lua
-- Track climbing statistics
hook.Add("PlayerBeginClimb", "TrackClimbingStats", function(player, distance)
    local char = player:getChar()
    if char then
        local climbs = char:getData("climbs_attempted", 0)
        char:setData("climbs_attempted", climbs + 1)
        
        -- Track distance climbed
        local totalDistance = char:getData("total_climb_distance", 0)
        char:setData("total_climb_distance", totalDistance + distance)
        
        -- Track highest climb
        local highestClimb = char:getData("highest_climb", 0)
        if distance > highestClimb then
            char:setData("highest_climb", distance)
        end
    end
end)

-- Apply climbing effects
hook.Add("PlayerBeginClimb", "ApplyClimbingEffects", function(player, distance)
    -- Play climbing sound
    player:EmitSound("player/pl_jumpland1.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 10), 0.5, 0)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Log climbing attempts
hook.Add("PlayerBeginClimb", "LogClimbingAttempts", function(player, distance)
    lia.log.add(player, "climbBegin", distance)
    
    -- Notify nearby players
    for _, ply in player.Iterator() do
        if ply ~= player and ply:GetPos():Distance(player:GetPos()) < 200 then
            ply:notify(player:Name() .. " is climbing a ledge!")
        end
    end
end)

-- Apply climbing restrictions
hook.Add("PlayerBeginClimb", "ApplyClimbingRestrictions", function(player, distance)
    local char = player:getChar()
    if char then
        -- Check if player is carrying too much weight
        local weight = char:getData("carried_weight", 0)
        if weight > 50 then
            player:notify("You're carrying too much to climb!")
            return false
        end
        
        -- Check if player is injured
        if char:getData("injured", false) then
            player:notify("You're too injured to climb!")
            return false
        end
    end
end)
```

---

## PlayerClimbAttempt

**Purpose**

Called when a player attempts to climb (presses jump while looking at a ledge).

**Parameters**

* `player` (*Player*): The player attempting to climb.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player presses the jump key
- Before any climb detection logic runs
- Before `PlayerBeginClimb` or `PlayerFailedClimb` hooks

**Example Usage**

```lua
-- Track climb attempts
hook.Add("PlayerClimbAttempt", "TrackClimbAttempts", function(player)
    local char = player:getChar()
    if char then
        local attempts = char:getData("climb_attempts", 0)
        char:setData("climb_attempts", attempts + 1)
        
        -- Track attempt frequency
        local lastAttempt = char:getData("last_climb_attempt", 0)
        char:setData("last_climb_attempt", os.time())
        
        if os.time() - lastAttempt < 1 then
            char:setData("rapid_climb_attempts", char:getData("rapid_climb_attempts", 0) + 1)
        end
    end
end)

-- Apply attempt restrictions
hook.Add("PlayerClimbAttempt", "ApplyAttemptRestrictions", function(player)
    local char = player:getChar()
    if char then
        -- Check cooldown
        local lastClimb = char:getData("last_climb", 0)
        if os.time() - lastClimb < 2 then -- 2 second cooldown
            player:notify("Please wait before attempting to climb again!")
            return false
        end
        
        -- Check stamina
        local stamina = char:getData("stamina", 100)
        if stamina < 20 then
            player:notify("You're too tired to climb!")
            return false
        end
        
        -- Reduce stamina
        char:setData("stamina", stamina - 10)
    end
end)

-- Log climb attempts
hook.Add("PlayerClimbAttempt", "LogClimbAttempts", function(player)
    lia.log.add(player, "climbAttempt")
end)

-- Apply attempt effects
hook.Add("PlayerClimbAttempt", "ApplyAttemptEffects", function(player)
    -- Play attempt sound
    player:EmitSound("player/pl_jump1.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 5), 0.3, 0)
end)
```

---

## PlayerClimbed

**Purpose**

Called when a player successfully completes a climb.

**Parameters**

* `player` (*Player*): The player who successfully climbed.
* `distance` (*number*): The distance that was climbed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player successfully climbs a ledge
- After the player's velocity has been modified
- After `PlayerBeginClimb` hook

**Example Usage**

```lua
-- Track successful climbs
hook.Add("PlayerClimbed", "TrackSuccessfulClimbs", function(player, distance)
    local char = player:getChar()
    if char then
        local successfulClimbs = char:getData("successful_climbs", 0)
        char:setData("successful_climbs", successfulClimbs + 1)
        
        -- Track total distance climbed
        local totalDistance = char:getData("total_climb_distance", 0)
        char:setData("total_climb_distance", totalDistance + distance)
        
        -- Track climb success rate
        local attempts = char:getData("climb_attempts", 0)
        local successRate = (successfulClimbs / attempts) * 100
        char:setData("climb_success_rate", successRate)
    end
end)

-- Apply success effects
hook.Add("PlayerClimbed", "ApplySuccessEffects", function(player, distance)
    -- Play success sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 1, 0)
    
    -- Create success particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos() + Vector(0, 0, 50))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify player
    player:notify("Successfully climbed " .. math.Round(distance) .. " units!")
end)

-- Award climbing achievements
hook.Add("PlayerClimbed", "ClimbingAchievements", function(player, distance)
    local char = player:getChar()
    if char then
        local successfulClimbs = char:getData("successful_climbs", 0)
        
        if successfulClimbs == 1 then
            player:notify("Achievement: First Climb!")
        elseif successfulClimbs == 10 then
            player:notify("Achievement: Climbing Enthusiast!")
        elseif successfulClimbs == 50 then
            player:notify("Achievement: Master Climber!")
        elseif successfulClimbs == 100 then
            player:notify("Achievement: Climbing Legend!")
        end
        
        -- Check for distance achievements
        if distance > 100 then
            player:notify("Achievement: High Climber! (" .. math.Round(distance) .. " units)")
        end
    end
end)

-- Log successful climbs
hook.Add("PlayerClimbed", "LogSuccessfulClimbs", function(player, distance)
    lia.log.add(player, "climbSuccess", distance)
    
    -- Notify nearby players
    for _, ply in player.Iterator() do
        if ply ~= player and ply:GetPos():Distance(player:GetPos()) < 300 then
            ply:notify(player:Name() .. " successfully climbed a ledge!")
        end
    end
end)

-- Apply post-climb effects
hook.Add("PlayerClimbed", "PostClimbEffects", function(player, distance)
    local char = player:getChar()
    if char then
        -- Reduce stamina based on distance
        local stamina = char:getData("stamina", 100)
        local staminaCost = math.min(distance * 0.1, 20)
        char:setData("stamina", math.max(0, stamina - staminaCost))
        
        -- Set last climb time
        char:setData("last_climb", os.time())
        
        -- Apply temporary speed boost
        player:SetWalkSpeed(player:GetWalkSpeed() * 1.1)
        player:SetRunSpeed(player:GetRunSpeed() * 1.1)
        
        -- Remove speed boost after 5 seconds
        timer.Simple(5, function()
            if IsValid(player) then
                player:SetWalkSpeed(200)
                player:SetRunSpeed(400)
            end
        end)
    end
end)
```

---

## PlayerFailedClimb

**Purpose**

Called when a player fails to climb (no valid climbable surface detected).

**Parameters**

* `player` (*Player*): The player who failed to climb.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to climb but no valid surface is found
- The climb trace doesn't detect a climbable ledge
- After `PlayerClimbAttempt` hook

**Example Usage**

```lua
-- Track failed climb attempts
hook.Add("PlayerFailedClimb", "TrackFailedClimbs", function(player)
    local char = player:getChar()
    if char then
        local failedClimbs = char:getData("failed_climbs", 0)
        char:setData("failed_climbs", failedClimbs + 1)
        
        -- Track failure rate
        local attempts = char:getData("climb_attempts", 0)
        local failureRate = (failedClimbs / attempts) * 100
        char:setData("climb_failure_rate", failureRate)
    end
end)

-- Apply failure effects
hook.Add("PlayerFailedClimb", "ApplyFailureEffects", function(player)
    -- Play failure sound
    player:EmitSound("player/pl_jump2.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 5), 0.5, 0)
    
    -- Notify player
    player:notify("No climbable surface found!")
end)

-- Provide climbing hints
hook.Add("PlayerFailedClimb", "ProvideClimbingHints", function(player)
    local char = player:getChar()
    if char then
        local failedClimbs = char:getData("failed_climbs", 0)
        
        -- Provide hints based on failure count
        if failedClimbs == 5 then
            player:notify("Tip: Look for ledges that are about 30 units away!")
        elseif failedClimbs == 10 then
            player:notify("Tip: Make sure you're looking directly at the ledge!")
        elseif failedClimbs == 20 then
            player:notify("Tip: Try jumping while looking at the ledge!")
        end
    end
end)

-- Log failed climbs
hook.Add("PlayerFailedClimb", "LogFailedClimbs", function(player)
    lia.log.add(player, "climbFailed")
end)

-- Apply failure penalties
hook.Add("PlayerFailedClimb", "ApplyFailurePenalties", function(player)
    local char = player:getChar()
    if char then
        -- Reduce stamina for failed attempts
        local stamina = char:getData("stamina", 100)
        char:setData("stamina", math.max(0, stamina - 5))
        
        -- Apply temporary movement penalty
        player:SetWalkSpeed(player:GetWalkSpeed() * 0.9)
        player:SetRunSpeed(player:GetRunSpeed() * 0.9)
        
        -- Remove penalty after 3 seconds
        timer.Simple(3, function()
            if IsValid(player) then
                player:SetWalkSpeed(200)
                player:SetRunSpeed(400)
            end
        end)
    end
end)

-- Track consecutive failures
hook.Add("PlayerFailedClimb", "TrackConsecutiveFailures", function(player)
    local char = player:getChar()
    if char then
        local consecutiveFailures = char:getData("consecutive_climb_failures", 0)
        char:setData("consecutive_climb_failures", consecutiveFailures + 1)
        
        -- Apply cooldown for too many consecutive failures
        if consecutiveFailures >= 5 then
            char:setData("climb_cooldown", os.time() + 10) -- 10 second cooldown
            player:notify("Too many failed climb attempts! Please wait 10 seconds.")
        end
    end
end)
```
