# Hooks

This document describes the hooks available in the Free Look module for managing freelook functionality.

---

## FreelookToggled

**Purpose**

Called when freelook is toggled on or off.

**Parameters**

* `enabled` (*boolean*): Whether freelook is being enabled or disabled.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Freelook is toggled on or off
- After `PreFreelookToggle` hook
- When the freelook state changes

**Example Usage**

```lua
-- Track freelook toggles
hook.Add("FreelookToggled", "TrackFreelookToggles", function(enabled)
    local char = LocalPlayer():getChar()
    if char then
        local freelookToggles = char:getData("freelook_toggles", 0)
        char:setData("freelook_toggles", freelookToggles + 1)
        
        -- Track toggle patterns
        local togglePatterns = char:getData("freelook_toggle_patterns", {})
        table.insert(togglePatterns, {
            enabled = enabled,
            time = os.time()
        })
        char:setData("freelook_toggle_patterns", togglePatterns)
    end
end)

-- Apply freelook toggle effects
hook.Add("FreelookToggled", "FreelookToggleEffects", function(enabled)
    -- Play toggle sound
    LocalPlayer():EmitSound(enabled and "buttons/button24.wav" or "buttons/button10.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    local status = enabled and "on" or "off"
    LocalPlayer():notify("Freelook turned " .. status .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(LocalPlayer():GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track freelook toggle statistics
hook.Add("FreelookToggled", "TrackFreelookToggleStats", function(enabled)
    local char = LocalPlayer():getChar()
    if char then
        -- Track toggle frequency
        local toggleFrequency = char:getData("freelook_toggle_frequency", 0)
        char:setData("freelook_toggle_frequency", toggleFrequency + 1)
        
        -- Track toggle patterns
        local togglePatterns = char:getData("freelook_toggle_patterns", {})
        table.insert(togglePatterns, {
            enabled = enabled,
            time = os.time()
        })
        char:setData("freelook_toggle_patterns", togglePatterns)
    end
end)
```

---

## PreFreelookToggle

**Purpose**

Called before freelook is toggled on or off.

**Parameters**

* `enabled` (*boolean*): Whether freelook is being enabled or disabled.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Freelook is about to be toggled
- Before the freelook state changes
- Before `FreelookToggled` hook

**Example Usage**

```lua
-- Control freelook toggling
hook.Add("PreFreelookToggle", "ControlFreelookToggling", function(enabled)
    local char = LocalPlayer():getChar()
    if char then
        -- Check if freelook is disabled
        if char:getData("freelook_disabled", false) then
            LocalPlayer():notify("Freelook is disabled!")
            return false
        end
        
        -- Check if player is in a vehicle
        if LocalPlayer():InVehicle() then
            LocalPlayer():notify("Cannot use freelook in a vehicle!")
            return false
        end
        
        -- Check if player is in water
        if LocalPlayer():WaterLevel() >= 2 then
            LocalPlayer():notify("Cannot use freelook underwater!")
            return false
        end
        
        -- Check cooldown
        local lastToggle = char:getData("last_freelook_toggle_time", 0)
        if os.time() - lastToggle < 1 then -- 1 second cooldown
            LocalPlayer():notify("Please wait before toggling freelook again!")
            return false
        end
        
        -- Update last toggle time
        char:setData("last_freelook_toggle_time", os.time())
    end
    
    return true
end)

-- Track freelook toggle attempts
hook.Add("PreFreelookToggle", "TrackFreelookToggleAttempts", function(enabled)
    local char = LocalPlayer():getChar()
    if char then
        local toggleAttempts = char:getData("freelook_toggle_attempts", 0)
        char:setData("freelook_toggle_attempts", toggleAttempts + 1)
    end
end)

-- Apply pre-toggle effects
hook.Add("PreFreelookToggle", "PreFreelookToggleEffects", function(enabled)
    -- Play pre-toggle sound
    LocalPlayer():EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    local status = enabled and "on" or "off"
    LocalPlayer():notify("Attempting to turn freelook " .. status .. "...")
end)
```

---

## ShouldUseFreelook

**Purpose**

Called to determine if freelook should be used for a player.

**Parameters**

* `player` (*Player*): The player to check.

**Realm**

Client.

**When Called**

This hook is triggered when:
- Freelook input is being processed
- Before any freelook calculations
- Before `PreFreelookToggle` hook

**Example Usage**

```lua
-- Control freelook usage
hook.Add("ShouldUseFreelook", "ControlFreelookUsage", function(player)
    local char = player:getChar()
    if char then
        -- Check if freelook is disabled
        if char:getData("freelook_disabled", false) then
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
        
        -- Check if player is crouching
        if player:KeyDown(IN_DUCK) then
            return false
        end
        
        -- Check if player is sprinting
        if player:KeyDown(IN_SPEED) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
    end
    
    return true
end)

-- Track freelook usage checks
hook.Add("ShouldUseFreelook", "TrackFreelookUsageChecks", function(player)
    local char = player:getChar()
    if char then
        local usageChecks = char:getData("freelook_usage_checks", 0)
        char:setData("freelook_usage_checks", usageChecks + 1)
    end
end)

-- Apply freelook usage check effects
hook.Add("ShouldUseFreelook", "FreelookUsageCheckEffects", function(player)
    local char = player:getChar()
    if char then
        -- Check if freelook is disabled
        if char:getData("freelook_disabled", false) then
            player:notify("Freelook is disabled!")
        end
    end
end)
```
