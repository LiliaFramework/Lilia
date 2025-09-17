# Hooks

This document describes the hooks available in the Flashlight module for managing flashlight functionality.

---

## CanPlayerToggleFlashlight

**Purpose**

Called to determine if a player can toggle their flashlight.

**Parameters**

* `client` (*Player*): The player attempting to toggle the flashlight.
* `isEnabled` (*boolean*): Whether the flashlight is being turned on or off.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to toggle their flashlight
- After `PrePlayerToggleFlashlight` hook
- Before the flashlight is actually toggled

**Example Usage**

```lua
-- Control flashlight usage
hook.Add("CanPlayerToggleFlashlight", "ControlFlashlightUsage", function(client, isEnabled)
    local char = client:getChar()
    if char then
        -- Check if flashlight is disabled
        if char:getData("flashlight_disabled", false) then
            client:notify("Flashlight is disabled!")
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            client:notify("Flashlight not allowed in this area!")
            return false
        end
        
        -- Check if player is handcuffed
        if client:IsHandcuffed() then
            client:notify("Cannot use flashlight while handcuffed!")
            return false
        end
        
        -- Check cooldown
        local lastToggle = char:getData("last_flashlight_toggle_time", 0)
        if os.time() - lastToggle < 2 then -- 2 second cooldown
            client:notify("Please wait before toggling flashlight again!")
            return false
        end
        
        -- Update last toggle time
        char:setData("last_flashlight_toggle_time", os.time())
    end
    
    return true
end)

-- Track flashlight usage attempts
hook.Add("CanPlayerToggleFlashlight", "TrackFlashlightUsageAttempts", function(client, isEnabled)
    local char = client:getChar()
    if char then
        local usageAttempts = char:getData("flashlight_usage_attempts", 0)
        char:setData("flashlight_usage_attempts", usageAttempts + 1)
    end
end)

-- Apply flashlight usage check effects
hook.Add("CanPlayerToggleFlashlight", "FlashlightUsageCheckEffects", function(client, isEnabled)
    local char = client:getChar()
    if char then
        -- Check if flashlight is disabled
        if char:getData("flashlight_disabled", false) then
            client:notify("Flashlight is disabled!")
        end
    end
end)
```

---

## PlayerToggleFlashlight

**Purpose**

Called when a player's flashlight is toggled.

**Parameters**

* `client` (*Player*): The player whose flashlight was toggled.
* `isEnabled` (*boolean*): Whether the flashlight was turned on or off.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's flashlight is successfully toggled
- After `CanPlayerToggleFlashlight` hook
- After the flashlight state is changed

**Example Usage**

```lua
-- Track flashlight toggles
hook.Add("PlayerToggleFlashlight", "TrackFlashlightToggles", function(client, isEnabled)
    local char = client:getChar()
    if char then
        local flashlightToggles = char:getData("flashlight_toggles", 0)
        char:setData("flashlight_toggles", flashlightToggles + 1)
        
        -- Track toggle patterns
        local togglePatterns = char:getData("flashlight_toggle_patterns", {})
        table.insert(togglePatterns, {
            enabled = isEnabled,
            time = os.time()
        })
        char:setData("flashlight_toggle_patterns", togglePatterns)
    end
    
    lia.log.add(client, "flashlightToggled", isEnabled)
end)

-- Apply flashlight toggle effects
hook.Add("PlayerToggleFlashlight", "FlashlightToggleEffects", function(client, isEnabled)
    -- Play toggle sound
    client:EmitSound(isEnabled and "buttons/button24.wav" or "buttons/button10.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    local status = isEnabled and "on" or "off"
    client:notify("Flashlight turned " .. status .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track flashlight toggle statistics
hook.Add("PlayerToggleFlashlight", "TrackFlashlightToggleStats", function(client, isEnabled)
    local char = client:getChar()
    if char then
        -- Track toggle frequency
        local toggleFrequency = char:getData("flashlight_toggle_frequency", 0)
        char:setData("flashlight_toggle_frequency", toggleFrequency + 1)
        
        -- Track toggle patterns
        local togglePatterns = char:getData("flashlight_toggle_patterns", {})
        table.insert(togglePatterns, {
            enabled = isEnabled,
            time = os.time()
        })
        char:setData("flashlight_toggle_patterns", togglePatterns)
    end
end)
```

---

## PrePlayerToggleFlashlight

**Purpose**

Called before a player's flashlight is toggled.

**Parameters**

* `client` (*Player*): The player attempting to toggle the flashlight.
* `isEnabled` (*boolean*): Whether the flashlight is being turned on or off.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to toggle their flashlight
- Before `CanPlayerToggleFlashlight` hook
- Before any flashlight validation

**Example Usage**

```lua
-- Track flashlight toggle attempts
hook.Add("PrePlayerToggleFlashlight", "TrackFlashlightToggleAttempts", function(client, isEnabled)
    local char = client:getChar()
    if char then
        local toggleAttempts = char:getData("flashlight_toggle_attempts", 0)
        char:setData("flashlight_toggle_attempts", toggleAttempts + 1)
    end
end)

-- Apply pre-toggle effects
hook.Add("PrePlayerToggleFlashlight", "PreFlashlightToggleEffects", function(client, isEnabled)
    -- Play pre-toggle sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    local status = isEnabled and "on" or "off"
    client:notify("Attempting to turn flashlight " .. status .. "...")
end)

-- Track pre-toggle statistics
hook.Add("PrePlayerToggleFlashlight", "TrackPreFlashlightToggleStats", function(client, isEnabled)
    local char = client:getChar()
    if char then
        -- Track pre-toggle frequency
        local preToggleFrequency = char:getData("flashlight_pre_toggle_frequency", 0)
        char:setData("flashlight_pre_toggle_frequency", preToggleFrequency + 1)
        
        -- Track pre-toggle patterns
        local preTogglePatterns = char:getData("flashlight_pre_toggle_patterns", {})
        table.insert(preTogglePatterns, {
            enabled = isEnabled,
            time = os.time()
        })
        char:setData("flashlight_pre_toggle_patterns", preTogglePatterns)
    end
end)
```
