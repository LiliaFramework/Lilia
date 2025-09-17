# Hooks

This document describes the hooks available in the Damage Numbers module for managing floating damage text display.

---

## DamageNumberAdded

**Purpose**

Called when a damage number is added to the display queue.

**Parameters**

* `entity` (*Entity*): The entity that received damage.
* `damage` (*number*): The amount of damage dealt.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A damage number is received from the server
- The damage number is added to the display queue
- Before the damage number starts displaying

**Example Usage**

```lua
-- Track damage number display
hook.Add("DamageNumberAdded", "TrackDamageNumbers", function(entity, damage)
    local char = LocalPlayer():getChar()
    if char then
        local damageNumbers = char:getData("damage_numbers_seen", 0)
        char:setData("damage_numbers_seen", damageNumbers + 1)
        
        -- Track damage amounts
        local totalDamage = char:getData("total_damage_seen", 0)
        char:setData("total_damage_seen", totalDamage + damage)
        
        -- Track entity types
        if IsValid(entity) then
            local entityType = entity:GetClass()
            local entityDamage = char:getData("entity_damage_seen", {})
            entityDamage[entityType] = (entityDamage[entityType] or 0) + damage
            char:setData("entity_damage_seen", entityDamage)
        end
    end
end)

-- Apply damage number effects
hook.Add("DamageNumberAdded", "DamageNumberEffects", function(entity, damage)
    -- Play damage sound
    LocalPlayer():EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 5), 0.3, 0)
    
    -- Create particle effect
    if IsValid(entity) then
        local effect = EffectData()
        effect:SetOrigin(entity:GetPos())
        effect:SetMagnitude(1)
        effect:SetScale(1)
        util.Effect("Explosion", effect)
    end
end)

-- Customize damage number display
hook.Add("DamageNumberAdded", "CustomizeDamageDisplay", function(entity, damage)
    -- Modify damage number based on amount
    if damage > 100 then
        -- Large damage - make it more prominent
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.5, 0)
    elseif damage > 50 then
        -- Medium damage - normal effect
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 5), 0.3, 0)
    else
        -- Small damage - subtle effect
        LocalPlayer():ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 3), 0.2, 0)
    end
end)

-- Track damage statistics
hook.Add("DamageNumberAdded", "TrackDamageStats", function(entity, damage)
    local char = LocalPlayer():getChar()
    if char then
        -- Track damage frequency
        local damageFrequency = char:getData("damage_frequency", 0)
        char:setData("damage_frequency", damageFrequency + 1)
        
        -- Track damage patterns
        local damagePatterns = char:getData("damage_patterns", {})
        table.insert(damagePatterns, {
            damage = damage,
            time = os.time(),
            entity = IsValid(entity) and entity:GetClass() or "unknown"
        })
        char:setData("damage_patterns", damagePatterns)
        
        -- Track damage ranges
        if damage > 100 then
            char:setData("high_damage_count", char:getData("high_damage_count", 0) + 1)
        elseif damage > 50 then
            char:setData("medium_damage_count", char:getData("medium_damage_count", 0) + 1)
        else
            char:setData("low_damage_count", char:getData("low_damage_count", 0) + 1)
        end
    end
end)
```

---

## DamageNumberExpired

**Purpose**

Called when a damage number expires and is removed from the display.

**Parameters**

* `entity` (*Entity*): The entity that the damage number was associated with.
* `damage` (*number*): The amount of damage that was displayed.

**Realm**

Client.

**When Called**

This hook is triggered when:
- A damage number's display time expires
- The damage number is removed from the display queue
- After the damage number has been shown

**Example Usage**

```lua
-- Track damage number expiration
hook.Add("DamageNumberExpired", "TrackDamageExpiration", function(entity, damage)
    local char = LocalPlayer():getChar()
    if char then
        local damageExpired = char:getData("damage_numbers_expired", 0)
        char:setData("damage_numbers_expired", damageExpired + 1)
        
        -- Track damage display duration
        local totalDisplayTime = char:getData("total_damage_display_time", 0)
        char:setData("total_damage_display_time", totalDisplayTime + 2) -- Default 2 second display
    end
end)

-- Apply damage expiration effects
hook.Add("DamageNumberExpired", "DamageExpirationEffects", function(entity, damage)
    -- Play expiration sound
    LocalPlayer():EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    LocalPlayer():ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 0), 0.5, 0)
    
    -- Create particle effect
    if IsValid(entity) then
        local effect = EffectData()
        effect:SetOrigin(entity:GetPos())
        effect:SetMagnitude(1)
        effect:SetScale(1)
        util.Effect("Explosion", effect)
    end
end)

-- Track damage display statistics
hook.Add("DamageNumberExpired", "TrackDamageDisplayStats", function(entity, damage)
    local char = LocalPlayer():getChar()
    if char then
        -- Track damage display patterns
        local damageDisplayPatterns = char:getData("damage_display_patterns", {})
        table.insert(damageDisplayPatterns, {
            damage = damage,
            entity = IsValid(entity) and entity:GetClass() or "unknown",
            time = os.time()
        })
        char:setData("damage_display_patterns", damageDisplayPatterns)
        
        -- Track damage display frequency
        local damageDisplayFrequency = char:getData("damage_display_frequency", 0)
        char:setData("damage_display_frequency", damageDisplayFrequency + 1)
    end
end)

-- Clean up damage data
hook.Add("DamageNumberExpired", "CleanupDamageData", function(entity, damage)
    local char = LocalPlayer():getChar()
    if char then
        -- Remove expired damage from tracking
        local activeDamage = char:getData("active_damage_numbers", {})
        for i = #activeDamage, 1, -1 do
            if activeDamage[i].damage == damage and activeDamage[i].entity == entity then
                table.remove(activeDamage, i)
            end
        end
        char:setData("active_damage_numbers", activeDamage)
    end
end)
```

---

## DamageNumbersSent

**Purpose**

Called when damage numbers are sent from the server to clients.

**Parameters**

* `attacker` (*Player*): The player who dealt the damage.
* `target` (*Player*): The player who received the damage.
* `damage` (*number*): The amount of damage dealt.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player takes damage from another player
- The damage numbers are sent to both players
- After the damage calculation is complete

**Example Usage**

```lua
-- Track damage number sending
hook.Add("DamageNumbersSent", "TrackDamageSending", function(attacker, target, damage)
    local char = attacker:getChar()
    if char then
        local damageDealt = char:getData("damage_dealt", 0)
        char:setData("damage_dealt", damageDealt + damage)
        
        -- Track damage targets
        local damageTargets = char:getData("damage_targets", {})
        damageTargets[target:SteamID()] = (damageTargets[target:SteamID()] or 0) + damage
        char:setData("damage_targets", damageTargets)
    end
    
    lia.log.add(attacker, "damageNumbersSent", target:Name(), damage)
end)

-- Apply damage sending effects
hook.Add("DamageNumbersSent", "DamageSendingEffects", function(attacker, target, damage)
    -- Play damage sound for attacker
    attacker:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect for attacker
    attacker:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Apply screen effect for target
    target:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.5, 0)
    
    -- Notify players
    attacker:notify("Dealt " .. damage .. " damage to " .. target:Name() .. "!")
    target:notify("Received " .. damage .. " damage from " .. attacker:Name() .. "!")
end)

-- Track damage statistics
hook.Add("DamageNumbersSent", "TrackDamageStats", function(attacker, target, damage)
    local char = attacker:getChar()
    if char then
        -- Track damage frequency
        local damageFrequency = char:getData("damage_frequency", 0)
        char:setData("damage_frequency", damageFrequency + 1)
        
        -- Track damage amounts
        local damageAmounts = char:getData("damage_amounts", {})
        table.insert(damageAmounts, {
            damage = damage,
            target = target:Name(),
            time = os.time()
        })
        char:setData("damage_amounts", damageAmounts)
        
        -- Track damage ranges
        if damage > 100 then
            char:setData("high_damage_dealt", char:getData("high_damage_dealt", 0) + 1)
        elseif damage > 50 then
            char:setData("medium_damage_dealt", char:getData("medium_damage_dealt", 0) + 1)
        else
            char:setData("low_damage_dealt", char:getData("low_damage_dealt", 0) + 1)
        end
    end
end)

-- Apply damage restrictions
hook.Add("DamageNumbersSent", "ApplyDamageRestrictions", function(attacker, target, damage)
    local char = attacker:getChar()
    if char then
        -- Check damage cooldown
        local lastDamage = char:getData("last_damage_time", 0)
        if os.time() - lastDamage < 1 then -- 1 second cooldown
            attacker:notify("Please wait before dealing damage again!")
            return false
        end
        
        -- Check damage limits
        local damageToday = char:getData("damage_today", 0)
        if damageToday >= 1000 then
            attacker:notify("Daily damage limit reached!")
            return false
        end
        
        -- Update counters
        char:setData("last_damage_time", os.time())
        char:setData("damage_today", damageToday + damage)
    end
end)

-- Award damage achievements
hook.Add("DamageNumbersSent", "DamageAchievements", function(attacker, target, damage)
    local char = attacker:getChar()
    if char then
        local totalDamage = char:getData("damage_dealt", 0)
        
        if totalDamage >= 1000 then
            attacker:notify("Achievement: Damage Dealer!")
        elseif totalDamage >= 5000 then
            attacker:notify("Achievement: Heavy Hitter!")
        elseif totalDamage >= 10000 then
            attacker:notify("Achievement: Damage Master!")
        end
        
        -- Check for specific damage achievements
        if damage >= 100 then
            attacker:notify("Achievement: High Damage Hit!")
        elseif damage >= 50 then
            attacker:notify("Achievement: Medium Damage Hit!")
        end
    end
end)
```
