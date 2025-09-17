# Hooks

This document describes the hooks available in the First Person Effects module for managing head bob and view sway functionality.

---

## FirstPersonEffectsUpdated

**Purpose**

Called when first person effects are updated with new position and angle values.

**Parameters**

* `player` (*Player*): The player whose effects are being updated.
* `currentPos` (*Vector*): The current position offset.
* `currentAng` (*Angle*): The current angle offset.

**Realm**

Client.

**When Called**

This hook is triggered when:
- First person effects are updated
- After `PostFirstPersonEffects` hook
- When the effects calculation is complete

**Example Usage**

```lua
-- Track first person effects updates
hook.Add("FirstPersonEffectsUpdated", "TrackFirstPersonEffectsUpdates", function(player, currentPos, currentAng)
    local char = player:getChar()
    if char then
        local effectsUpdates = char:getData("first_person_effects_updates", 0)
        char:setData("first_person_effects_updates", effectsUpdates + 1)
    end
end)

-- Apply first person effects update effects
hook.Add("FirstPersonEffectsUpdated", "FirstPersonEffectsUpdateEffects", function(player, currentPos, currentAng)
    -- Play update sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    player:notify("First person effects updated!")
end)

-- Track first person effects update statistics
hook.Add("FirstPersonEffectsUpdated", "TrackFirstPersonEffectsUpdateStats", function(player, currentPos, currentAng)
    local char = player:getChar()
    if char then
        -- Track update frequency
        local updateFrequency = char:getData("first_person_effects_update_frequency", 0)
        char:setData("first_person_effects_update_frequency", updateFrequency + 1)
        
        -- Track update patterns
        local updatePatterns = char:getData("first_person_effects_update_patterns", {})
        table.insert(updatePatterns, {
            pos = currentPos,
            ang = currentAng,
            time = os.time()
        })
        char:setData("first_person_effects_update_patterns", updatePatterns)
    end
end)
```

---

## PostFirstPersonEffects

**Purpose**

Called after first person effects have been calculated.

**Parameters**

* `player` (*Player*): The player whose effects are being calculated.
* `currentPos` (*Vector*): The current position offset.
* `currentAng` (*Angle*): The current angle offset.

**Realm**

Client.

**When Called**

This hook is triggered when:
- First person effects have been calculated
- After `PreFirstPersonEffects` hook
- Before `FirstPersonEffectsUpdated` hook

**Example Usage**

```lua
-- Track first person effects completion
hook.Add("PostFirstPersonEffects", "TrackFirstPersonEffectsCompletion", function(player, currentPos, currentAng)
    local char = player:getChar()
    if char then
        local effectsCompletions = char:getData("first_person_effects_completions", 0)
        char:setData("first_person_effects_completions", effectsCompletions + 1)
    end
end)

-- Apply first person effects completion effects
hook.Add("PostFirstPersonEffects", "FirstPersonEffectsCompletionEffects", function(player, currentPos, currentAng)
    -- Play completion sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    player:notify("First person effects calculated!")
end)

-- Track first person effects completion statistics
hook.Add("PostFirstPersonEffects", "TrackFirstPersonEffectsCompletionStats", function(player, currentPos, currentAng)
    local char = player:getChar()
    if char then
        -- Track completion frequency
        local completionFrequency = char:getData("first_person_effects_completion_frequency", 0)
        char:setData("first_person_effects_completion_frequency", completionFrequency + 1)
        
        -- Track completion patterns
        local completionPatterns = char:getData("first_person_effects_completion_patterns", {})
        table.insert(completionPatterns, {
            pos = currentPos,
            ang = currentAng,
            time = os.time()
        })
        char:setData("first_person_effects_completion_patterns", completionPatterns)
    end
end)
```

---

## PreFirstPersonEffects

**Purpose**

Called before first person effects are calculated.

**Parameters**

* `player` (*Player*): The player whose effects are about to be calculated.

**Realm**

Client.

**When Called**

This hook is triggered when:
- First person effects are about to be calculated
- Before any effect calculations begin
- Before `PostFirstPersonEffects` hook

**Example Usage**

```lua
-- Track first person effects preparation
hook.Add("PreFirstPersonEffects", "TrackFirstPersonEffectsPreparation", function(player)
    local char = player:getChar()
    if char then
        local effectsPreparations = char:getData("first_person_effects_preparations", 0)
        char:setData("first_person_effects_preparations", effectsPreparations + 1)
    end
end)

-- Apply first person effects preparation effects
hook.Add("PreFirstPersonEffects", "FirstPersonEffectsPreparationEffects", function(player)
    -- Play preparation sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    player:notify("Calculating first person effects...")
end)

-- Track first person effects preparation statistics
hook.Add("PreFirstPersonEffects", "TrackFirstPersonEffectsPreparationStats", function(player)
    local char = player:getChar()
    if char then
        -- Track preparation frequency
        local preparationFrequency = char:getData("first_person_effects_preparation_frequency", 0)
        char:setData("first_person_effects_preparation_frequency", preparationFrequency + 1)
        
        -- Track preparation patterns
        local preparationPatterns = char:getData("first_person_effects_preparation_patterns", {})
        table.insert(preparationPatterns, {
            time = os.time()
        })
        char:setData("first_person_effects_preparation_patterns", preparationPatterns)
    end
end)
```

---

## ShouldUseFirstPersonEffects

**Purpose**

Called to determine if first person effects should be used for a player.

**Parameters**

* `player` (*Player*): The player to check.

**Realm**

Client.

**When Called**

This hook is triggered when:
- First person effects are about to be calculated
- Before any effect calculations begin
- Before `PreFirstPersonEffects` hook

**Example Usage**

```lua
-- Control first person effects usage
hook.Add("ShouldUseFirstPersonEffects", "ControlFirstPersonEffectsUsage", function(player)
    local char = player:getChar()
    if char then
        -- Check if effects are disabled
        if char:getData("first_person_effects_disabled", false) then
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
    end
    
    return true
end)

-- Track first person effects usage checks
hook.Add("ShouldUseFirstPersonEffects", "TrackFirstPersonEffectsUsageChecks", function(player)
    local char = player:getChar()
    if char then
        local usageChecks = char:getData("first_person_effects_usage_checks", 0)
        char:setData("first_person_effects_usage_checks", usageChecks + 1)
    end
end)

-- Apply first person effects usage check effects
hook.Add("ShouldUseFirstPersonEffects", "FirstPersonEffectsUsageCheckEffects", function(player)
    local char = player:getChar()
    if char then
        -- Check if effects are disabled
        if char:getData("first_person_effects_disabled", false) then
            player:notify("First person effects are disabled!")
        end
    end
end)
```
