# Hooks

This document describes the hooks available in the Slow Weapons module for managing weapon movement speed penalties.

---

## ApplyWeaponSlowdown

**Purpose**

Called when a weapon slowdown is being applied to a player's movement.

**Parameters**

* `client` (*Player*): The player whose movement is being slowed down.
* `weapon` (*Weapon*): The weapon causing the slowdown.
* `moveData` (*CMoveData*): The movement data being modified.
* `speed` (*number*): The speed value being applied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is holding a weapon that has a speed penalty
- Before the movement speed is actually applied
- After `OverrideSlowWeaponSpeed` hook

**Example Usage**

```lua
-- Track weapon slowdown applications
hook.Add("ApplyWeaponSlowdown", "TrackWeaponSlowdown", function(client, weapon, moveData, speed)
    local char = client:getChar()
    if char then
        local slowdowns = char:getData("weapon_slowdowns", 0)
        char:setData("weapon_slowdowns", slowdowns + 1)
        
        -- Track weapon types
        local weaponType = weapon:GetClass()
        local weaponSlowdowns = char:getData("weapon_type_slowdowns", {})
        weaponSlowdowns[weaponType] = (weaponSlowdowns[weaponType] or 0) + 1
        char:setData("weapon_type_slowdowns", weaponSlowdowns)
    end
    
    lia.log.add(client, "weaponSlowdownApplied", weapon:GetClass(), speed)
end)

-- Apply slowdown effects
hook.Add("ApplyWeaponSlowdown", "SlowdownEffects", function(client, weapon, moveData, speed)
    -- Play slowdown sound
    client:EmitSound("player/pl_jump1.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.3, 0)
    
    -- Notify client
    client:notify("Weapon slowdown applied: " .. weapon:GetClass())
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track slowdown statistics
hook.Add("ApplyWeaponSlowdown", "TrackSlowdownStats", function(client, weapon, moveData, speed)
    local char = client:getChar()
    if char then
        -- Track slowdown frequency
        local slowdownFrequency = char:getData("weapon_slowdown_frequency", 0)
        char:setData("weapon_slowdown_frequency", slowdownFrequency + 1)
        
        -- Track slowdown patterns
        local slowdownPatterns = char:getData("weapon_slowdown_patterns", {})
        table.insert(slowdownPatterns, {
            weapon = weapon:GetClass(),
            speed = speed,
            time = os.time()
        })
        char:setData("weapon_slowdown_patterns", slowdownPatterns)
        
        -- Track speed reduction
        local baseSpeed = client:GetWalkSpeed()
        local speedReduction = baseSpeed - speed
        char:setData("total_speed_reduction", char:getData("total_speed_reduction", 0) + speedReduction)
    end
end)
```

---

## OverrideSlowWeaponSpeed

**Purpose**

Called to allow overriding the slow weapon speed value before it's applied.

**Parameters**

* `client` (*Player*): The player whose weapon speed is being calculated.
* `weapon` (*Weapon*): The weapon being held.
* `baseSpeed` (*number*): The base speed value for the weapon.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is holding a weapon that has a speed penalty
- Before the speed is calculated and applied
- Before `ApplyWeaponSlowdown` hook

**Example Usage**

```lua
-- Override weapon speed based on character attributes
hook.Add("OverrideSlowWeaponSpeed", "OverrideWeaponSpeed", function(client, weapon, baseSpeed)
    local char = client:getChar()
    if char then
        -- Apply character-specific modifications
        local strength = char:getData("strength", 50)
        local speedModifier = 1 + (strength - 50) / 100 -- 0.5x to 1.5x based on strength
        
        -- Apply weapon-specific modifications
        local weaponType = weapon:GetClass()
        if weaponType == "weapon_rifle" then
            speedModifier = speedModifier * 0.8 -- Rifles are heavier
        elseif weaponType == "weapon_pistol" then
            speedModifier = speedModifier * 1.2 -- Pistols are lighter
        end
        
        -- Apply character perks
        if char:getData("lightweight_perk", false) then
            speedModifier = speedModifier * 1.3
        end
        
        -- Apply temporary effects
        if char:getData("adrenaline_boost", false) then
            speedModifier = speedModifier * 1.5
        end
        
        return baseSpeed * speedModifier
    end
end)

-- Track weapon speed overrides
hook.Add("OverrideSlowWeaponSpeed", "TrackWeaponSpeedOverrides", function(client, weapon, baseSpeed)
    local char = client:getChar()
    if char then
        local overrides = char:getData("weapon_speed_overrides", 0)
        char:setData("weapon_speed_overrides", overrides + 1)
        
        -- Track weapon types
        local weaponType = weapon:GetClass()
        local weaponOverrides = char:getData("weapon_type_overrides", {})
        weaponOverrides[weaponType] = (weaponOverrides[weaponType] or 0) + 1
        char:setData("weapon_type_overrides", weaponOverrides)
    end
end)

-- Apply speed override effects
hook.Add("OverrideSlowWeaponSpeed", "SpeedOverrideEffects", function(client, weapon, baseSpeed)
    -- Play override sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 5), 0.2, 0)
    
    -- Notify client
    client:notify("Weapon speed override: " .. weapon:GetClass())
end)
```

---

## PostApplyWeaponSlowdown

**Purpose**

Called after a weapon slowdown has been applied to a player's movement.

**Parameters**

* `client` (*Player*): The player whose movement was slowed down.
* `weapon` (*Weapon*): The weapon that caused the slowdown.
* `moveData` (*CMoveData*): The movement data that was modified.
* `speed` (*number*): The speed value that was applied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon slowdown has been successfully applied
- After the movement speed has been set
- After `ApplyWeaponSlowdown` hook

**Example Usage**

```lua
-- Track weapon slowdown completion
hook.Add("PostApplyWeaponSlowdown", "TrackWeaponSlowdownCompletion", function(client, weapon, moveData, speed)
    local char = client:getChar()
    if char then
        local slowdownsCompleted = char:getData("weapon_slowdowns_completed", 0)
        char:setData("weapon_slowdowns_completed", slowdownsCompleted + 1)
        
        -- Track completion patterns
        local completionPatterns = char:getData("weapon_slowdown_completion_patterns", {})
        table.insert(completionPatterns, {
            weapon = weapon:GetClass(),
            speed = speed,
            time = os.time()
        })
        char:setData("weapon_slowdown_completion_patterns", completionPatterns)
    end
    
    lia.log.add(client, "weaponSlowdownCompleted", weapon:GetClass(), speed)
end)

-- Apply post-slowdown effects
hook.Add("PostApplyWeaponSlowdown", "PostSlowdownEffects", function(client, weapon, moveData, speed)
    -- Play completion sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify client
    client:notify("Weapon slowdown applied successfully!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track post-slowdown statistics
hook.Add("PostApplyWeaponSlowdown", "TrackPostSlowdownStats", function(client, weapon, moveData, speed)
    local char = client:getChar()
    if char then
        -- Track completion frequency
        local completionFrequency = char:getData("weapon_slowdown_completion_frequency", 0)
        char:setData("weapon_slowdown_completion_frequency", completionFrequency + 1)
        
        -- Track speed effectiveness
        local baseSpeed = client:GetWalkSpeed()
        local speedReduction = baseSpeed - speed
        local effectiveness = speedReduction / baseSpeed
        char:setData("weapon_slowdown_effectiveness", char:getData("weapon_slowdown_effectiveness", 0) + effectiveness)
    end
end)
```
