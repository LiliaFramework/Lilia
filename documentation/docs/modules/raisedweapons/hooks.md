# Hooks

This document describes the hooks available in the Raised Weapons module for managing weapon raising and lowering functionality.

---

## OnWeaponLowered

**Purpose**

Called when a weapon is lowered.

**Parameters**

* `player` (*Player*): The player whose weapon was lowered.
* `weapon` (*Weapon*): The weapon that was lowered.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon is lowered
- After `PlayerWeaponRaisedChanged` hook
- When the weapon state changes to lowered

**Example Usage**

```lua
-- Track weapon lowered
hook.Add("OnWeaponLowered", "TrackWeaponLowered", function(player, weapon)
    local char = player:getChar()
    if char then
        local weaponLowered = char:getData("weapon_lowered", 0)
        char:setData("weapon_lowered", weaponLowered + 1)
    end
    
    lia.log.add(player, "weaponLowered", weapon)
end)

-- Apply weapon lowered effects
hook.Add("OnWeaponLowered", "WeaponLoweredEffects", function(player, weapon)
    -- Play lowered sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Weapon lowered!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track weapon lowered statistics
hook.Add("OnWeaponLowered", "TrackWeaponLoweredStats", function(player, weapon)
    local char = player:getChar()
    if char then
        -- Track lowered frequency
        local loweredFrequency = char:getData("weapon_lowered_frequency", 0)
        char:setData("weapon_lowered_frequency", loweredFrequency + 1)
        
        -- Track lowered patterns
        local loweredPatterns = char:getData("weapon_lowered_patterns", {})
        table.insert(loweredPatterns, {
            weapon = weapon:GetClass(),
            time = os.time()
        })
        char:setData("weapon_lowered_patterns", loweredPatterns)
    end
end)
```

---

## OnWeaponRaised

**Purpose**

Called when a weapon is raised.

**Parameters**

* `player` (*Player*): The player whose weapon was raised.
* `weapon` (*Weapon*): The weapon that was raised.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon is raised
- After `PlayerWeaponRaisedChanged` hook
- When the weapon state changes to raised

**Example Usage**

```lua
-- Track weapon raised
hook.Add("OnWeaponRaised", "TrackWeaponRaised", function(player, weapon)
    local char = player:getChar()
    if char then
        local weaponRaised = char:getData("weapon_raised", 0)
        char:setData("weapon_raised", weaponRaised + 1)
    end
    
    lia.log.add(player, "weaponRaised", weapon)
end)

-- Apply weapon raised effects
hook.Add("OnWeaponRaised", "WeaponRaisedEffects", function(player, weapon)
    -- Play raised sound
    player:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    player:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    player:notify("Weapon raised!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(player:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track weapon raised statistics
hook.Add("OnWeaponRaised", "TrackWeaponRaisedStats", function(player, weapon)
    local char = player:getChar()
    if char then
        -- Track raised frequency
        local raisedFrequency = char:getData("weapon_raised_frequency", 0)
        char:setData("weapon_raised_frequency", raisedFrequency + 1)
        
        -- Track raised patterns
        local raisedPatterns = char:getData("weapon_raised_patterns", {})
        table.insert(raisedPatterns, {
            weapon = weapon:GetClass(),
            time = os.time()
        })
        char:setData("weapon_raised_patterns", raisedPatterns)
    end
end)
```

---

## OverrideWeaponRaiseSpeed

**Purpose**

Called to override the weapon raise speed.

**Parameters**

* `client` (*Player*): The player whose weapon raise speed is being set.
* `raiseSpeed` (*number*): The current raise speed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon raise speed is being set
- During weapon raising/lowering
- When the speed calculation begins

**Example Usage**

```lua
-- Override weapon raise speed
hook.Add("OverrideWeaponRaiseSpeed", "OverrideWeaponRaiseSpeed", function(client, raiseSpeed)
    local char = client:getChar()
    if char then
        -- Check if player has speed modifier
        local speedModifier = char:getData("weapon_raise_speed_modifier", 1)
        if speedModifier ~= 1 then
            return raiseSpeed * speedModifier
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return raiseSpeed * 0.5 -- Slower in restricted areas
        end
        
        -- Check if player is in water
        if client:WaterLevel() >= 2 then
            return raiseSpeed * 0.75 -- Slower in water
        end
        
        -- Check if player is handcuffed
        if client:IsHandcuffed() then
            return raiseSpeed * 0.25 -- Much slower when handcuffed
        end
    end
    
    return raiseSpeed
end)

-- Track weapon raise speed overrides
hook.Add("OverrideWeaponRaiseSpeed", "TrackWeaponRaiseSpeedOverrides", function(client, raiseSpeed)
    local char = client:getChar()
    if char then
        local speedOverrides = char:getData("weapon_raise_speed_overrides", 0)
        char:setData("weapon_raise_speed_overrides", speedOverrides + 1)
    end
    
    lia.log.add(client, "weaponRaiseSpeedOverridden", raiseSpeed)
end)

-- Apply weapon raise speed override effects
hook.Add("OverrideWeaponRaiseSpeed", "WeaponRaiseSpeedOverrideEffects", function(client, raiseSpeed)
    -- Play speed override sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
    
    -- Notify player
    client:notify("Weapon raise speed overridden!")
end)
```

---

## PlayerWeaponRaisedChanged

**Purpose**

Called when a player's weapon raised state changes.

**Parameters**

* `player` (*Player*): The player whose weapon state changed.
* `state` (*boolean*): The new raised state.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's weapon raised state changes
- After `setWepRaised` is called
- When the state is updated

**Example Usage**

```lua
-- Track weapon raised state changes
hook.Add("PlayerWeaponRaisedChanged", "TrackWeaponRaisedStateChanges", function(player, state)
    local char = player:getChar()
    if char then
        local stateChanges = char:getData("weapon_raised_state_changes", 0)
        char:setData("weapon_raised_state_changes", stateChanges + 1)
    end
    
    lia.log.add(player, "weaponRaisedStateChanged", state)
end)

-- Apply weapon raised state change effects
hook.Add("PlayerWeaponRaisedChanged", "WeaponRaisedStateChangeEffects", function(player, state)
    -- Play state change sound
    player:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    local color = state and Color(0, 255, 0, 10) or Color(255, 0, 0, 10)
    player:ScreenFade(SCREENFADE.IN, color, 0.3, 0)
    
    -- Notify player
    local status = state and "raised" or "lowered"
    player:notify("Weapon " .. status .. "!")
end)

-- Track weapon raised state change statistics
hook.Add("PlayerWeaponRaisedChanged", "TrackWeaponRaisedStateChangeStats", function(player, state)
    local char = player:getChar()
    if char then
        -- Track state change frequency
        local stateChangeFrequency = char:getData("weapon_raised_state_change_frequency", 0)
        char:setData("weapon_raised_state_change_frequency", stateChangeFrequency + 1)
        
        -- Track state change patterns
        local stateChangePatterns = char:getData("weapon_raised_state_change_patterns", {})
        table.insert(stateChangePatterns, {
            state = state,
            time = os.time()
        })
        char:setData("weapon_raised_state_change_patterns", stateChangePatterns)
    end
end)
```

---

## ShouldWeaponBeRaised

**Purpose**

Called to determine if a weapon should be raised.

**Parameters**

* `player` (*Player*): The player whose weapon is being checked.
* `weapon` (*Weapon*): The weapon being checked.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon raise state is being checked
- During `isWepRaised` calls
- When the state validation begins

**Example Usage**

```lua
-- Control weapon raising
hook.Add("ShouldWeaponBeRaised", "ControlWeaponRaising", function(player, weapon)
    local char = player:getChar()
    if char then
        -- Check if weapon raising is disabled
        if char:getData("weapon_raising_disabled", false) then
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
        
        -- Check if weapon is restricted
        if weapon:getData("restricted", false) then
            return false
        end
    end
    
    return nil -- Let default logic handle it
end)

-- Track weapon raising checks
hook.Add("ShouldWeaponBeRaised", "TrackWeaponRaisingChecks", function(player, weapon)
    local char = player:getChar()
    if char then
        local raisingChecks = char:getData("weapon_raising_checks", 0)
        char:setData("weapon_raising_checks", raisingChecks + 1)
    end
    
    lia.log.add(player, "weaponRaisingChecked", weapon)
end)

-- Apply weapon raising check effects
hook.Add("ShouldWeaponBeRaised", "WeaponRaisingCheckEffects", function(player, weapon)
    local char = player:getChar()
    if char then
        -- Check if weapon raising is disabled
        if char:getData("weapon_raising_disabled", false) then
            player:notify("Weapon raising is disabled!")
        end
    end
end)
```

---

## WeaponHolsterCancelled

**Purpose**

Called when a weapon holster is cancelled.

**Parameters**

* `client` (*Player*): The player whose weapon holster was cancelled.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon holster is cancelled
- During weapon holster processing
- When the holster is interrupted

**Example Usage**

```lua
-- Track weapon holster cancellations
hook.Add("WeaponHolsterCancelled", "TrackWeaponHolsterCancellations", function(client)
    local char = client:getChar()
    if char then
        local holsterCancellations = char:getData("weapon_holster_cancellations", 0)
        char:setData("weapon_holster_cancellations", holsterCancellations + 1)
    end
    
    lia.log.add(client, "weaponHolsterCancelled")
end)

-- Apply weapon holster cancellation effects
hook.Add("WeaponHolsterCancelled", "WeaponHolsterCancellationEffects", function(client)
    -- Play cancellation sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Weapon holster cancelled!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track weapon holster cancellation statistics
hook.Add("WeaponHolsterCancelled", "TrackWeaponHolsterCancellationStats", function(client)
    local char = client:getChar()
    if char then
        -- Track cancellation frequency
        local cancellationFrequency = char:getData("weapon_holster_cancellation_frequency", 0)
        char:setData("weapon_holster_cancellation_frequency", cancellationFrequency + 1)
        
        -- Track cancellation patterns
        local cancellationPatterns = char:getData("weapon_holster_cancellation_patterns", {})
        table.insert(cancellationPatterns, {
            time = os.time()
        })
        char:setData("weapon_holster_cancellation_patterns", cancellationPatterns)
    end
end)
```

---

## WeaponHolsterScheduled

**Purpose**

Called when a weapon holster is scheduled.

**Parameters**

* `client` (*Player*): The player whose weapon holster is scheduled.
* `raiseSpeed` (*number*): The raise speed for the holster.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon holster is scheduled
- During weapon holster processing
- When the holster is planned

**Example Usage**

```lua
-- Track weapon holster scheduling
hook.Add("WeaponHolsterScheduled", "TrackWeaponHolsterScheduling", function(client, raiseSpeed)
    local char = client:getChar()
    if char then
        local holsterScheduling = char:getData("weapon_holster_scheduling", 0)
        char:setData("weapon_holster_scheduling", holsterScheduling + 1)
    end
    
    lia.log.add(client, "weaponHolsterScheduled", raiseSpeed)
end)

-- Apply weapon holster scheduling effects
hook.Add("WeaponHolsterScheduled", "WeaponHolsterSchedulingEffects", function(client, raiseSpeed)
    -- Play scheduling sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Weapon holster scheduled!")
end)

-- Track weapon holster scheduling statistics
hook.Add("WeaponHolsterScheduled", "TrackWeaponHolsterSchedulingStats", function(client, raiseSpeed)
    local char = client:getChar()
    if char then
        -- Track scheduling frequency
        local schedulingFrequency = char:getData("weapon_holster_scheduling_frequency", 0)
        char:setData("weapon_holster_scheduling_frequency", schedulingFrequency + 1)
        
        -- Track scheduling patterns
        local schedulingPatterns = char:getData("weapon_holster_scheduling_patterns", {})
        table.insert(schedulingPatterns, {
            raiseSpeed = raiseSpeed,
            time = os.time()
        })
        char:setData("weapon_holster_scheduling_patterns", schedulingPatterns)
    end
end)
```

---

## WeaponRaiseScheduled

**Purpose**

Called when a weapon raise is scheduled.

**Parameters**

* `client` (*Player*): The player whose weapon raise is scheduled.
* `newWeapon` (*Weapon*): The new weapon being raised.
* `raiseSpeed` (*number*): The raise speed for the weapon.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A weapon raise is scheduled
- During weapon raising processing
- When the raise is planned

**Example Usage**

```lua
-- Track weapon raise scheduling
hook.Add("WeaponRaiseScheduled", "TrackWeaponRaiseScheduling", function(client, newWeapon, raiseSpeed)
    local char = client:getChar()
    if char then
        local raiseScheduling = char:getData("weapon_raise_scheduling", 0)
        char:setData("weapon_raise_scheduling", raiseScheduling + 1)
    end
    
    lia.log.add(client, "weaponRaiseScheduled", newWeapon, raiseSpeed)
end)

-- Apply weapon raise scheduling effects
hook.Add("WeaponRaiseScheduled", "WeaponRaiseSchedulingEffects", function(client, newWeapon, raiseSpeed)
    -- Play scheduling sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Weapon raise scheduled!")
end)

-- Track weapon raise scheduling statistics
hook.Add("WeaponRaiseScheduled", "TrackWeaponRaiseSchedulingStats", function(client, newWeapon, raiseSpeed)
    local char = client:getChar()
    if char then
        -- Track scheduling frequency
        local schedulingFrequency = char:getData("weapon_raise_scheduling_frequency", 0)
        char:setData("weapon_raise_scheduling_frequency", schedulingFrequency + 1)
        
        -- Track scheduling patterns
        local schedulingPatterns = char:getData("weapon_raise_scheduling_patterns", {})
        table.insert(schedulingPatterns, {
            weapon = newWeapon:GetClass(),
            raiseSpeed = raiseSpeed,
            time = os.time()
        })
        char:setData("weapon_raise_scheduling_patterns", schedulingPatterns)
    end
end)
```
