# Hooks

This document describes the hooks available in the Instakill module for managing instant kill functionality.

---

## PlayerInstantKilled

**Purpose**

Called when a player is instant killed.

**Parameters**

* `client` (*Player*): The player who was instant killed.
* `dmgInfo` (*CTakeDamageInfo*): The damage information that caused the instant kill.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is instant killed by a headshot
- After `PlayerPreInstantKill` hook
- After the damage is applied

**Example Usage**

```lua
-- Track instant kills
hook.Add("PlayerInstantKilled", "TrackInstantKills", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        local instantKills = char:getData("instant_kills", 0)
        char:setData("instant_kills", instantKills + 1)
        
        -- Track instant kill patterns
        local instantKillPatterns = char:getData("instant_kill_patterns", {})
        table.insert(instantKillPatterns, {
            attacker = dmgInfo:GetAttacker(),
            weapon = dmgInfo:GetInflictor(),
            time = os.time()
        })
        char:setData("instant_kill_patterns", instantKillPatterns)
    end
    
    lia.log.add(client, "instantKilled", dmgInfo:GetAttacker())
end)

-- Apply instant kill effects
hook.Add("PlayerInstantKilled", "InstantKillEffects", function(client, dmgInfo)
    -- Play instant kill sound
    client:EmitSound("vo/npc/male01/pain08.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 25), 1, 0)
    
    -- Notify player
    client:notify("You were instant killed!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track instant kill statistics
hook.Add("PlayerInstantKilled", "TrackInstantKillStats", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        -- Track instant kill frequency
        local instantKillFrequency = char:getData("instant_kill_frequency", 0)
        char:setData("instant_kill_frequency", instantKillFrequency + 1)
        
        -- Track instant kill patterns
        local instantKillPatterns = char:getData("instant_kill_patterns", {})
        table.insert(instantKillPatterns, {
            attacker = dmgInfo:GetAttacker(),
            weapon = dmgInfo:GetInflictor(),
            time = os.time()
        })
        char:setData("instant_kill_patterns", instantKillPatterns)
    end
end)
```

---

## PlayerPreInstantKill

**Purpose**

Called before a player is instant killed.

**Parameters**

* `client` (*Player*): The player who is about to be instant killed.
* `dmgInfo` (*CTakeDamageInfo*): The damage information that will cause the instant kill.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is about to be instant killed by a headshot
- Before `PlayerInstantKilled` hook
- Before the damage is applied

**Example Usage**

```lua
-- Track instant kill attempts
hook.Add("PlayerPreInstantKill", "TrackInstantKillAttempts", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        local instantKillAttempts = char:getData("instant_kill_attempts", 0)
        char:setData("instant_kill_attempts", instantKillAttempts + 1)
    end
end)

-- Apply pre-instant kill effects
hook.Add("PlayerPreInstantKill", "PreInstantKillEffects", function(client, dmgInfo)
    -- Play pre-instant kill sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("You are about to be instant killed!")
end)

-- Track pre-instant kill statistics
hook.Add("PlayerPreInstantKill", "TrackPreInstantKillStats", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        -- Track pre-instant kill frequency
        local preInstantKillFrequency = char:getData("pre_instant_kill_frequency", 0)
        char:setData("pre_instant_kill_frequency", preInstantKillFrequency + 1)
        
        -- Track pre-instant kill patterns
        local preInstantKillPatterns = char:getData("pre_instant_kill_patterns", {})
        table.insert(preInstantKillPatterns, {
            attacker = dmgInfo:GetAttacker(),
            weapon = dmgInfo:GetInflictor(),
            time = os.time()
        })
        char:setData("pre_instant_kill_patterns", preInstantKillPatterns)
    end
end)
```

---

## ShouldInstantKill

**Purpose**

Called to determine if a player should be instant killed.

**Parameters**

* `client` (*Player*): The player who might be instant killed.
* `dmgInfo` (*CTakeDamageInfo*): The damage information that might cause the instant kill.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player takes headshot damage
- Before `PlayerPreInstantKill` hook
- Before any instant kill validation

**Example Usage**

```lua
-- Control instant kill usage
hook.Add("ShouldInstantKill", "ControlInstantKillUsage", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        -- Check if instant kill is disabled
        if char:getData("instant_kill_disabled", false) then
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
        local lastInstantKill = char:getData("last_instant_kill_time", 0)
        if os.time() - lastInstantKill < 5 then -- 5 second cooldown
            return false
        end
        
        -- Update last instant kill time
        char:setData("last_instant_kill_time", os.time())
    end
    
    return true
end)

-- Track instant kill usage checks
hook.Add("ShouldInstantKill", "TrackInstantKillUsageChecks", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        local usageChecks = char:getData("instant_kill_usage_checks", 0)
        char:setData("instant_kill_usage_checks", usageChecks + 1)
    end
end)

-- Apply instant kill usage check effects
hook.Add("ShouldInstantKill", "InstantKillUsageCheckEffects", function(client, dmgInfo)
    local char = client:getChar()
    if char then
        -- Check if instant kill is disabled
        if char:getData("instant_kill_disabled", false) then
            client:notify("Instant kill is disabled!")
        end
    end
end)
```
