# Hooks

This document describes the hooks available in the Alcoholism module for managing Blood Alcohol Content (BAC) and alcohol-related effects.

---

## AlcoholConsumed

**Purpose**

Called when a player consumes an alcoholic item.

**Parameters**

* `client` (*Player*): The player who consumed the alcohol.
* `item` (*Item*): The alcohol item that was consumed.

**Realm**

Server.

**When Called**

This hook is triggered after:
- The player uses an alcohol item
- The BAC has been increased via `AddBAC()`
- The item has been consumed

**Example Usage**

```lua
-- Track alcohol consumption statistics
hook.Add("AlcoholConsumed", "TrackAlcoholStats", function(client, item)
    local char = client:getChar()
    if char then
        local drinksConsumed = char:getData("drinks_consumed", 0)
        char:setData("drinks_consumed", drinksConsumed + 1)
        
        -- Track specific alcohol types
        local alcoholType = char:getData("alcohol_" .. item.uniqueID, 0)
        char:setData("alcohol_" .. item.uniqueID, alcoholType + 1)
    end
end)

-- Award achievement for first drink
hook.Add("AlcoholConsumed", "FirstDrinkAchievement", function(client, item)
    local char = client:getChar()
    if char and not char:getData("first_drink", false) then
        char:setData("first_drink", true)
        client:notify("Achievement Unlocked: First Sip!")
    end
end)

-- Log alcohol consumption for moderation
hook.Add("AlcoholConsumed", "LogAlcoholConsumption", function(client, item)
    lia.log.add(client, "alcoholConsumed", item.name, item.abv)
    
    -- Notify moderators if high ABV alcohol is consumed
    if item.abv > 50 then
        for _, admin in player.Iterator() do
            if admin:IsAdmin() then
                admin:notify(client:Name() .. " consumed " .. item.name .. " (" .. item.abv .. "% ABV)")
            end
        end
    end
end)
```

---

## BACChanged

**Purpose**

Called whenever a player's Blood Alcohol Content (BAC) changes, either through increase or decrease.

**Parameters**

* `client` (*Player*): The player whose BAC changed.
* `newBac` (*number*): The new BAC value (0-100).

**Realm**

Server.

**When Called**

This hook is triggered:
- When BAC is increased via `AddBAC()`
- When BAC is decreased through natural degradation
- When BAC is reset via `ResetBAC()`

**Example Usage**

```lua
-- Update client-side effects based on BAC
hook.Add("BACChanged", "UpdateAlcoholEffects", function(client, newBac)
    -- Send BAC update to client
    net.Start("UpdateBAC")
    net.WriteFloat(newBac)
    net.Send(client)
    
    -- Update player's drunk status
    if newBac > 50 then
        client:setNetVar("isDrunk", true)
    else
        client:setNetVar("isDrunk", false)
    end
end)

-- Track BAC changes for analytics
hook.Add("BACChanged", "TrackBACChanges", function(client, newBac)
    local char = client:getChar()
    if char then
        char:setData("last_bac_change", os.time())
        char:setData("peak_bac", math.max(char:getData("peak_bac", 0), newBac))
    end
end)
```

---

## BACIncreased

**Purpose**

Called when a player's BAC is increased through alcohol consumption.

**Parameters**

* `client` (*Player*): The player whose BAC increased.
* `amount` (*number*): The amount of BAC that was added.
* `newBac` (*number*): The new BAC value after the increase.

**Realm**

Server.

**When Called**

This hook is triggered after:
- `PreBACIncrease` hook
- BAC has been increased via `AddBAC()`
- `BACChanged` hook

**Example Usage**

```lua
-- Apply immediate effects for BAC increase
hook.Add("BACIncreased", "ApplyBACEffects", function(client, amount, newBac)
    -- Apply screen effects based on BAC level
    if newBac > 30 then
        client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 1, 0)
    end
    
    -- Apply movement effects
    if newBac > 50 then
        client:SetWalkSpeed(client:GetWalkSpeed() * 0.8)
        client:SetRunSpeed(client:GetRunSpeed() * 0.8)
    end
end)

-- Track BAC increase patterns
hook.Add("BACIncreased", "TrackBACPatterns", function(client, amount, newBac)
    local char = client:getChar()
    if char then
        local increases = char:getData("bac_increases", 0)
        char:setData("bac_increases", increases + 1)
        
        -- Track rapid drinking
        local lastIncrease = char:getData("last_bac_increase", 0)
        if os.time() - lastIncrease < 60 then
            char:setData("rapid_drinking", true)
        end
        char:setData("last_bac_increase", os.time())
    end
end)
```

---

## BACReset

**Purpose**

Called when a player's BAC is reset to 0.

**Parameters**

* `client` (*Player*): The player whose BAC was reset.

**Realm**

Server.

**When Called**

This hook is triggered after:
- `PreBACReset` hook
- BAC has been set to 0
- `BACChanged` hook

**Example Usage**

```lua
-- Restore player abilities when BAC is reset
hook.Add("BACReset", "RestorePlayerAbilities", function(client)
    -- Restore normal movement speeds
    client:SetWalkSpeed(200)
    client:SetRunSpeed(400)
    
    -- Clear drunk status
    client:setNetVar("isDrunk", false)
    
    -- Remove screen effects
    client:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 0.5, 0)
end)

-- Track sobriety achievements
hook.Add("BACReset", "SobrietyAchievement", function(client)
    local char = client:getChar()
    if char then
        local soberResets = char:getData("sober_resets", 0)
        char:setData("sober_resets", soberResets + 1)
        
        if soberResets >= 10 then
            client:notify("Achievement: Sober as a Judge!")
        end
    end
end)
```

---

## BACThresholdReached

**Purpose**

Called when a player's BAC reaches or exceeds the drunk notification threshold.

**Parameters**

* `client` (*Player*): The player who reached the threshold.
* `newBac` (*number*): The BAC value that triggered the threshold.

**Realm**

Server.

**When Called**

This hook is triggered when:
- BAC increases from below the threshold to at or above it
- The threshold is defined by `DrunkNotifyThreshold` config (default: 50)

**Example Usage**

```lua
-- Notify player they are now drunk
hook.Add("BACThresholdReached", "NotifyDrunkStatus", function(client, newBac)
    client:notify("You are now feeling the effects of alcohol!")
    client:ChatPrint("Your BAC is " .. newBac .. "% - you are legally drunk!")
end)

-- Apply drunk status effects
hook.Add("BACThresholdReached", "ApplyDrunkEffects", function(client, newBac)
    -- Apply drunk HUD overlay
    client:setNetVar("showDrunkHUD", true)
    
    -- Start drunk camera effects
    net.Start("StartDrunkEffects")
    net.WriteFloat(newBac)
    net.Send(client)
end)

-- Track drunk incidents
hook.Add("BACThresholdReached", "TrackDrunkIncidents", function(client, newBac)
    lia.log.add(client, "drunkThreshold", newBac)
    
    -- Notify staff
    for _, admin in player.Iterator() do
        if admin:IsAdmin() then
            admin:notify(client:Name() .. " has reached drunk threshold (BAC: " .. newBac .. "%)")
        end
    end
end)
```

---

## PostBACDecrease

**Purpose**

Called after a player's BAC has been decreased through natural degradation.

**Parameters**

* `client` (*Player*): The player whose BAC decreased.
* `newBac` (*number*): The new BAC value after the decrease.

**Realm**

Server.

**When Called**

This hook is triggered after:
- `PreBACDecrease` hook
- BAC has been decreased through the Think loop
- `BACChanged` hook

**Example Usage**

```lua
-- Update effects based on decreased BAC
hook.Add("PostBACDecrease", "UpdateDecreasedBAC", function(client, newBac)
    -- Reduce screen effects as BAC decreases
    if newBac < 30 then
        client:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 2, 0)
    end
    
    -- Gradually restore movement speed
    local baseWalkSpeed = 200
    local baseRunSpeed = 400
    local speedMultiplier = math.max(0.8, 1 - (newBac / 100))
    
    client:SetWalkSpeed(baseWalkSpeed * speedMultiplier)
    client:SetRunSpeed(baseRunSpeed * speedMultiplier)
end)

-- Track recovery time
hook.Add("PostBACDecrease", "TrackRecovery", function(client, newBac)
    local char = client:getChar()
    if char and newBac == 0 then
        local recoveryTime = os.time() - char:getData("last_drunk_time", 0)
        char:setData("last_recovery_time", recoveryTime)
        client:notify("You have fully recovered from alcohol effects!")
    end
end)
```

---

## PostBACReset

**Purpose**

Called after a player's BAC has been completely reset to 0.

**Parameters**

* `client` (*Player*): The player whose BAC was reset.

**Realm**

Server.

**When Called**

This hook is triggered after:
- `PreBACReset` hook
- BAC has been set to 0
- `BACChanged` hook
- `BACReset` hook

**Example Usage**

```lua
-- Clean up all alcohol-related effects
hook.Add("PostBACReset", "CleanupAlcoholEffects", function(client)
    -- Remove all drunk-related netvars
    client:setNetVar("isDrunk", false)
    client:setNetVar("showDrunkHUD", false)
    
    -- Stop all drunk effects on client
    net.Start("StopAllDrunkEffects")
    net.Send(client)
    
    -- Restore normal player state
    client:SetWalkSpeed(200)
    client:SetRunSpeed(400)
end)

-- Award sobriety bonus
hook.Add("PostBACReset", "SobrietyBonus", function(client)
    local char = client:getChar()
    if char then
        -- Give small money bonus for staying sober
        char:giveMoney(10)
        client:notify("You received 10 credits for maintaining sobriety!")
    end
end)
```

---

## PreBACDecrease

**Purpose**

Called before a player's BAC is decreased through natural degradation.

**Parameters**

* `client` (*Player*): The player whose BAC will decrease.
* `currentBac` (*number*): The current BAC value before the decrease.

**Realm**

Server.

**When Called**

This hook is triggered before:
- BAC is decreased through the Think loop
- `BACChanged` hook
- `PostBACDecrease` hook

**Example Usage**

```lua
-- Track when BAC starts decreasing
hook.Add("PreBACDecrease", "TrackBACDecrease", function(client, currentBac)
    local char = client:getChar()
    if char then
        char:setData("last_bac_decrease", os.time())
        
        -- Track how long player was drunk
        if currentBac >= 50 then
            local drunkStartTime = char:getData("drunk_start_time", 0)
            if drunkStartTime > 0 then
                local drunkDuration = os.time() - drunkStartTime
                char:setData("total_drunk_time", char:getData("total_drunk_time", 0) + drunkDuration)
            end
        end
    end
end)

-- Prevent BAC decrease under certain conditions
hook.Add("PreBACDecrease", "PreventBACDecrease", function(client, currentBac)
    local char = client:getChar()
    if char and char:getData("alcohol_immunity", false) then
        -- Player has alcohol immunity, prevent decrease
        return false
    end
end)
```

---

## PreBACIncrease

**Purpose**

Called before a player's BAC is increased through alcohol consumption.

**Parameters**

* `client` (*Player*): The player whose BAC will increase.
* `amount` (*number*): The amount of BAC that will be added.

**Realm**

Server.

**When Called**

This hook is triggered before:
- BAC is increased via `AddBAC()`
- `BACChanged` hook
- `BACIncreased` hook

**Example Usage**

```lua
-- Modify BAC increase amount based on player traits
hook.Add("PreBACIncrease", "ModifyBACIncrease", function(client, amount)
    local char = client:getChar()
    if char then
        -- Check for alcohol tolerance trait
        local tolerance = char:getData("alcohol_tolerance", 1)
        if tolerance > 1 then
            -- Reduce BAC increase for tolerant players
            amount = amount * (1 / tolerance)
        end
        
        -- Check for alcohol resistance
        local resistance = char:getData("alcohol_resistance", 0)
        if resistance > 0 then
            amount = math.max(0, amount - resistance)
        end
    end
    
    return amount
end)

-- Track BAC increase attempts
hook.Add("PreBACIncrease", "TrackBACAttempts", function(client, amount)
    local char = client:getChar()
    if char then
        local attempts = char:getData("bac_increase_attempts", 0)
        char:setData("bac_increase_attempts", attempts + 1)
        
        -- Log large BAC increases
        if amount > 20 then
            lia.log.add(client, "largeBACIncrease", amount)
        end
    end
end)
```

---

## PreBACReset

**Purpose**

Called before a player's BAC is reset to 0.

**Parameters**

* `client` (*Player*): The player whose BAC will be reset.

**Realm**

Server.

**When Called**

This hook is triggered before:
- BAC is set to 0
- `BACChanged` hook
- `BACReset` hook
- `PostBACReset` hook

**Example Usage**

```lua
-- Track BAC reset events
hook.Add("PreBACReset", "TrackBACReset", function(client)
    local char = client:getChar()
    if char then
        local currentBac = client:GetBAC()
        char:setData("last_reset_bac", currentBac)
        char:setData("total_resets", char:getData("total_resets", 0) + 1)
        
        -- Log BAC reset
        lia.log.add(client, "bacReset", currentBac)
    end
end)

-- Prevent BAC reset under certain conditions
hook.Add("PreBACReset", "PreventBACReset", function(client)
    local char = client:getChar()
    if char and char:getData("forced_drunk", false) then
        -- Player is forced to be drunk, prevent reset
        client:notify("You cannot sober up right now!")
        return false
    end
end)

-- Apply reset penalties
hook.Add("PreBACReset", "ApplyResetPenalties", function(client)
    local char = client:getChar()
    if char then
        local currentBac = client:GetBAC()
        if currentBac > 80 then
            -- Heavy penalty for resetting while very drunk
            char:takeMoney(50)
            client:notify("You lost 50 credits for resetting while heavily intoxicated!")
        end
    end
end)
```
