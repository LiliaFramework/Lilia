# Hooks

This document describes the hooks available in the Realistic View module for managing first-person view functionality.

---

## RealisticViewUpdated

**Purpose**

Called when realistic view is updated with new values.

**Parameters**

* `client` (*Player*): The player whose view is being updated.
* `view` (*table*): The view table containing origin, angles, fov, and drawviewer.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Realistic view is updated with new values
- Before view calculations
- When the view data is ready

**Example Usage**

```lua
-- Track realistic view updates
hook.Add("RealisticViewUpdated", "TrackRealisticViewUpdates", function(client, view)
    local char = client:getChar()
    if char then
        local viewUpdates = char:getData("realistic_view_updates", 0)
        char:setData("realistic_view_updates", viewUpdates + 1)
    end
end)

-- Apply realistic view update effects
hook.Add("RealisticViewUpdated", "RealisticViewUpdateEffects", function(client, view)
    -- Play update sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Realistic view updated!")
end)

-- Track realistic view update statistics
hook.Add("RealisticViewUpdated", "TrackRealisticViewUpdateStats", function(client, view)
    local char = client:getChar()
    if char then
        -- Track update frequency
        local updateFrequency = char:getData("realistic_view_update_frequency", 0)
        char:setData("realistic_view_update_frequency", updateFrequency + 1)
        
        -- Track update patterns
        local updatePatterns = char:getData("realistic_view_update_patterns", {})
        table.insert(updatePatterns, {
            origin = view.origin,
            angles = view.angles,
            fov = view.fov,
            time = os.time()
        })
        char:setData("realistic_view_update_patterns", updatePatterns)
    end
end)
```

---

## ShouldUseRealisticView

**Purpose**

Called to determine if realistic view should be used for a player.

**Parameters**

* `client` (*Player*): The player to check.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Realistic view is being checked
- Before any view calculations
- Before `RealisticViewUpdated` hook

**Example Usage**

```lua
-- Control realistic view usage
hook.Add("ShouldUseRealisticView", "ControlRealisticViewUsage", function(client)
    local char = client:getChar()
    if char then
        -- Check if realistic view is disabled
        if char:getData("realistic_view_disabled", false) then
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
        
        -- Check if player is crouching
        if client:KeyDown(IN_DUCK) then
            return false
        end
        
        -- Check if player is sprinting
        if client:KeyDown(IN_SPEED) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
    end
    
    return true
end)

-- Track realistic view usage checks
hook.Add("ShouldUseRealisticView", "TrackRealisticViewUsageChecks", function(client)
    local char = client:getChar()
    if char then
        local usageChecks = char:getData("realistic_view_usage_checks", 0)
        char:setData("realistic_view_usage_checks", usageChecks + 1)
    end
end)

-- Apply realistic view usage check effects
hook.Add("ShouldUseRealisticView", "RealisticViewUsageCheckEffects", function(client)
    local char = client:getChar()
    if char then
        -- Check if realistic view is disabled
        if char:getData("realistic_view_disabled", false) then
            client:notify("Realistic view is disabled!")
        end
    end
end)
```

---

## RealisticViewCalcView

**Purpose**

Called when realistic view calculations are complete and the final view data is ready.

**Parameters**

* `client` (*Player*): The player whose view is being calculated.
* `view` (*table*): The final view table containing origin, angles, fov, and drawviewer.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Realistic view calculations are complete
- After `RealisticViewUpdated` hook
- Before the view is returned to the game engine
- When all view modifications are finished

**Example Usage**

```lua
-- Apply final view modifications
hook.Add("RealisticViewCalcView", "FinalViewModifications", function(client, view)
    local char = client:getChar()
    if char then
        -- Apply character-specific view modifications
        local viewModifier = char:getData("view_modifier", 1)
        view.fov = view.fov * viewModifier
        
        -- Apply head movement restrictions
        local headMovement = char:getData("head_movement_restricted", false)
        if headMovement then
            view.angles.p = math.Clamp(view.angles.p, -30, 30)
            view.angles.y = math.Clamp(view.angles.y, -45, 45)
        end
    end
end)

-- Track realistic view calculations
hook.Add("RealisticViewCalcView", "TrackRealisticViewCalculations", function(client, view)
    local char = client:getChar()
    if char then
        local calculations = char:getData("realistic_view_calculations", 0)
        char:setData("realistic_view_calculations", calculations + 1)
        
        -- Log view data for debugging
        print("Realistic view calculated for", client:Name(), "at", view.origin)
    end
end)

-- Apply realistic view effects
hook.Add("RealisticViewCalcView", "RealisticViewEffects", function(client, view)
    -- Apply screen shake based on movement
    local velocity = client:GetVelocity()
    local shake = math.min(velocity:Length() / 100, 5)
    if shake > 0.1 then
        view.angles.p = view.angles.p + math.sin(RealTime() * 10) * shake
        view.angles.y = view.angles.y + math.cos(RealTime() * 8) * shake
    end
    
    -- Apply breathing effect
    local breathing = math.sin(RealTime() * 2) * 0.5
    view.origin = view.origin + Vector(0, 0, breathing)
end)
```
