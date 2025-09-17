# Hooks

This document describes the hooks available in the View Bob module for managing camera bobbing and view punch effects.

---

## PostViewPunch

**Purpose**

Called after a view punch has been applied to the player's camera.

**Parameters**

* `client` (*Player*): The player whose view was punched.
* `angleX` (*number*): The X-axis angle of the view punch.
* `angleY` (*number*): The Y-axis angle of the view punch.
* `angleZ` (*number*): The Z-axis angle of the view punch.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A view punch has been applied to the player's camera
- After `ViewBobPunch` hook
- After the `ViewPunch` function has been called

**Example Usage**

```lua
-- Track view punch effects
hook.Add("PostViewPunch", "TrackViewPunchEffects", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        local viewPunches = char:getData("view_punches", 0)
        char:setData("view_punches", viewPunches + 1)
        
        -- Track punch intensity
        local punchIntensity = math.sqrt(angleX^2 + angleY^2 + angleZ^2)
        char:setData("total_punch_intensity", char:getData("total_punch_intensity", 0) + punchIntensity)
    end
end)

-- Apply post-punch effects
hook.Add("PostViewPunch", "PostPunchEffects", function(client, angleX, angleY, angleZ)
    -- Play punch sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 255, 5), 0.3, 0)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track punch patterns
hook.Add("PostViewPunch", "TrackPunchPatterns", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Track punch directions
        local punchDirections = char:getData("punch_directions", {})
        if angleX > 0 then
            punchDirections.x_positive = (punchDirections.x_positive or 0) + 1
        elseif angleX < 0 then
            punchDirections.x_negative = (punchDirections.x_negative or 0) + 1
        end
        
        if angleY > 0 then
            punchDirections.y_positive = (punchDirections.y_positive or 0) + 1
        elseif angleY < 0 then
            punchDirections.y_negative = (punchDirections.y_negative or 0) + 1
        end
        
        if angleZ > 0 then
            punchDirections.z_positive = (punchDirections.z_positive or 0) + 1
        elseif angleZ < 0 then
            punchDirections.z_negative = (punchDirections.z_negative or 0) + 1
        end
        
        char:setData("punch_directions", punchDirections)
    end
end)

-- Apply punch restrictions
hook.Add("PostViewPunch", "ApplyPunchRestrictions", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Check punch cooldown
        local lastPunch = char:getData("last_punch_time", 0)
        if os.time() - lastPunch < 1 then -- 1 second cooldown
            char:setData("punch_cooldown_warning", true)
            client:notify("View punch cooldown active!")
        end
        
        -- Update last punch time
        char:setData("last_punch_time", os.time())
    end
end)
```

---

## PreViewPunch

**Purpose**

Called before a view punch is applied to the player's camera.

**Parameters**

* `client` (*Player*): The player whose view will be punched.
* `angleX` (*number*): The X-axis angle of the view punch.
* `angleY` (*number*): The Y-axis angle of the view punch.
* `angleZ` (*number*): The Z-axis angle of the view punch.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A view punch is about to be applied
- Before `ViewBobPunch` hook
- Before the `ViewPunch` function is called

**Example Usage**

```lua
-- Validate view punch
hook.Add("PreViewPunch", "ValidateViewPunch", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Check if view punch is disabled
        if char:getData("view_punch_disabled", false) then
            client:notify("View punch is disabled!")
            return false
        end
        
        -- Check punch limits
        local punchIntensity = math.sqrt(angleX^2 + angleY^2 + angleZ^2)
        if punchIntensity > 10 then
            client:notify("View punch intensity too high!")
            return false
        end
    end
end)

-- Modify view punch values
hook.Add("PreViewPunch", "ModifyViewPunch", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Apply punch multiplier
        local punchMultiplier = char:getData("punch_multiplier", 1)
        angleX = angleX * punchMultiplier
        angleY = angleY * punchMultiplier
        angleZ = angleZ * punchMultiplier
        
        -- Apply punch dampening
        local punchDampening = char:getData("punch_dampening", 1)
        angleX = angleX * punchDampening
        angleY = angleY * punchDampening
        angleZ = angleZ * punchDampening
    end
end)

-- Track view punch attempts
hook.Add("PreViewPunch", "TrackViewPunchAttempts", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        local punchAttempts = char:getData("punch_attempts", 0)
        char:setData("punch_attempts", punchAttempts + 1)
        
        -- Track punch frequency
        local lastPunch = char:getData("last_punch_time", 0)
        char:setData("last_punch_time", os.time())
        
        if os.time() - lastPunch < 1 then
            char:setData("rapid_punch_attempts", char:getData("rapid_punch_attempts", 0) + 1)
        end
    end
end)

-- Apply pre-punch effects
hook.Add("PreViewPunch", "PrePunchEffects", function(client, angleX, angleY, angleZ)
    -- Play pre-punch sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.2, 0)
end)
```

---

## ViewBobPunch

**Purpose**

Called when a view punch is being applied during view bobbing.

**Parameters**

* `client` (*Player*): The player whose view is being punched.
* `angleX` (*number*): The X-axis angle of the view punch.
* `angleY` (*number*): The Y-axis angle of the view punch.
* `angleZ` (*number*): The Z-axis angle of the view punch.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A view punch is being applied during movement
- After `PreViewPunch` hook
- Before the `ViewPunch` function is called

**Example Usage**

```lua
-- Track view bob punches
hook.Add("ViewBobPunch", "TrackViewBobPunches", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        local viewBobPunches = char:getData("view_bob_punches", 0)
        char:setData("view_bob_punches", viewBobPunches + 1)
        
        -- Track punch intensity
        local punchIntensity = math.sqrt(angleX^2 + angleY^2 + angleZ^2)
        char:setData("total_bob_intensity", char:getData("total_bob_intensity", 0) + punchIntensity)
    end
end)

-- Apply view bob effects
hook.Add("ViewBobPunch", "ViewBobEffects", function(client, angleX, angleY, angleZ)
    -- Play bob sound
    client:EmitSound("player/pl_jump1.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 3), 0.1, 0)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Customize view bob behavior
hook.Add("ViewBobPunch", "CustomizeViewBob", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Apply character-specific modifications
        local bobStyle = char:getData("bob_style", "normal")
        
        if bobStyle == "aggressive" then
            angleX = angleX * 1.5
            angleY = angleY * 1.5
            angleZ = angleZ * 1.5
        elseif bobStyle == "subtle" then
            angleX = angleX * 0.5
            angleY = angleY * 0.5
            angleZ = angleZ * 0.5
        end
        
        -- Apply movement-based modifications
        if client:KeyDown(IN_SPEED) then
            angleX = angleX * 1.2
            angleY = angleY * 1.2
            angleZ = angleZ * 1.2
        elseif client:KeyDown(IN_DUCK) then
            angleX = angleX * 0.8
            angleY = angleY * 0.8
            angleZ = angleZ * 0.8
        end
    end
end)

-- Track view bob patterns
hook.Add("ViewBobPunch", "TrackViewBobPatterns", function(client, angleX, angleY, angleZ)
    local char = client:getChar()
    if char then
        -- Track movement patterns
        local movementPatterns = char:getData("movement_patterns", {})
        local pattern = "unknown"
        
        if client:KeyDown(IN_FORWARD) then
            pattern = "forward"
        elseif client:KeyDown(IN_BACK) then
            pattern = "backward"
        elseif client:KeyDown(IN_MOVERIGHT) then
            pattern = "right"
        elseif client:KeyDown(IN_MOVELEFT) then
            pattern = "left"
        end
        
        movementPatterns[pattern] = (movementPatterns[pattern] or 0) + 1
        char:setData("movement_patterns", movementPatterns)
    end
end)
```

---

## ViewBobStep

**Purpose**

Called when determining the step value for view bobbing.

**Parameters**

* `client` (*Player*): The player whose step value is being determined.
* `stepValue` (*number*): The current step value (1 or -1).

**Realm**

Client.

**When Called**

This hook is triggered when:
- A player takes a step while moving
- The step value is being determined for view bobbing
- Before the view punch is applied

**Example Usage**

```lua
-- Customize step value
hook.Add("ViewBobStep", "CustomizeStepValue", function(client, stepValue)
    local char = client:getChar()
    if char then
        -- Apply character-specific step modifications
        local stepStyle = char:getData("step_style", "normal")
        
        if stepStyle == "irregular" then
            -- Make steps more irregular
            if math.random(1, 10) <= 3 then
                stepValue = stepValue * -1
            end
        elseif stepStyle == "rhythmic" then
            -- Make steps more rhythmic
            local stepCount = char:getData("step_count", 0)
            char:setData("step_count", stepCount + 1)
            
            if stepCount % 4 == 0 then
                stepValue = stepValue * 1.5
            end
        end
        
        -- Apply movement-based modifications
        if client:KeyDown(IN_SPEED) then
            stepValue = stepValue * 1.2
        elseif client:KeyDown(IN_DUCK) then
            stepValue = stepValue * 0.8
        end
    end
    
    return stepValue
end)

-- Track step patterns
hook.Add("ViewBobStep", "TrackStepPatterns", function(client, stepValue)
    local char = client:getChar()
    if char then
        local stepCount = char:getData("step_count", 0)
        char:setData("step_count", stepCount + 1)
        
        -- Track step frequency
        local lastStep = char:getData("last_step_time", 0)
        char:setData("last_step_time", os.time())
        
        if os.time() - lastStep < 1 then
            char:setData("rapid_steps", char:getData("rapid_steps", 0) + 1)
        end
        
        -- Track step directions
        local stepDirections = char:getData("step_directions", {})
        if stepValue > 0 then
            stepDirections.positive = (stepDirections.positive or 0) + 1
        else
            stepDirections.negative = (stepDirections.negative or 0) + 1
        end
        char:setData("step_directions", stepDirections)
    end
end)

-- Apply step effects
hook.Add("ViewBobStep", "StepEffects", function(client, stepValue)
    -- Play step sound
    client:EmitSound("player/pl_step1.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 0, 255, 2), 0.1, 0)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Apply step restrictions
hook.Add("ViewBobStep", "ApplyStepRestrictions", function(client, stepValue)
    local char = client:getChar()
    if char then
        -- Check if view bobbing is disabled
        if char:getData("view_bob_disabled", false) then
            return 0
        end
        
        -- Check step cooldown
        local lastStep = char:getData("last_step_time", 0)
        if os.time() - lastStep < 0.1 then -- 0.1 second cooldown
            return stepValue * 0.5
        end
        
        -- Update last step time
        char:setData("last_step_time", os.time())
    end
end)
```
