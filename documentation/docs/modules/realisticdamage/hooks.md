# Hooks

This document describes the hooks available in the Realistic Damage module for managing damage scaling and sound effects.

---

## GetDamageScale

**Purpose**

Called to get the damage scale for a specific hitgroup and damage info.

**Parameters**

* `hitgroup` (*number*): The hitgroup that was hit.
* `dmgInfo` (*CTakeDamageInfo*): The damage information.
* `damageScale` (*number*): The current damage scale value.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Player damage is being scaled
- After `PreScaleDamage` hook
- Before `PostScaleDamage` hook

**Example Usage**

```lua
-- Modify damage scale based on hitgroup
hook.Add("GetDamageScale", "ModifyDamageScale", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    -- Increase headshot damage for certain weapons
    if hitgroup == HITGROUP_HEAD then
        local weapon = attacker:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "weapon_sniper" then
            return damageScale * 1.5
        end
    end
    
    -- Reduce limb damage for certain weapons
    if hitgroup == HITGROUP_LEFTARM or hitgroup == HITGROUP_RIGHTARM then
        local weapon = attacker:GetActiveWeapon()
        if IsValid(weapon) and weapon:GetClass() == "weapon_pistol" then
            return damageScale * 0.8
        end
    end
    
    return damageScale
end)

-- Track damage scale modifications
hook.Add("GetDamageScale", "TrackDamageScaleModifications", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local char = attacker:getChar()
        if char then
            local scaleModifications = char:getData("damage_scale_modifications", 0)
            char:setData("damage_scale_modifications", scaleModifications + 1)
        end
    end
end)

-- Apply damage scale modification effects
hook.Add("GetDamageScale", "DamageScaleModificationEffects", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Play modification sound
        attacker:EmitSound("ui/buttonclick.wav", 75, 100)
        
        -- Apply screen effect
        attacker:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
        
        -- Notify player
        attacker:notify("Damage scale modified!")
    end
end)
```

---

## GetPlayerDeathSound

**Purpose**

Called to get the death sound for a player.

**Parameters**

* `client` (*Player*): The player who died.
* `isFemale` (*boolean*): Whether the player is female.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player dies
- Before `ShouldPlayDeathSound` hook
- Before the death sound is played

**Example Usage**

```lua
-- Customize death sounds
hook.Add("GetPlayerDeathSound", "CustomizeDeathSounds", function(client, isFemale)
    local char = client:getChar()
    if char then
        -- Check if player has custom death sound
        local customDeathSound = char:getData("custom_death_sound", "")
        if customDeathSound ~= "" then
            return customDeathSound
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return isFemale and "vo/npc/female01/pain08.wav" or "vo/npc/male01/pain08.wav"
        end
        
        -- Check if player is drunk
        if char:getData("drunk", false) then
            return isFemale and "vo/npc/female01/pain09.wav" or "vo/npc/male01/pain09.wav"
        end
    end
    
    -- Return default death sound
    return isFemale and "vo/npc/female01/pain08.wav" or "vo/npc/male01/pain08.wav"
end)

-- Track death sound requests
hook.Add("GetPlayerDeathSound", "TrackDeathSoundRequests", function(client, isFemale)
    local char = client:getChar()
    if char then
        local deathSoundRequests = char:getData("death_sound_requests", 0)
        char:setData("death_sound_requests", deathSoundRequests + 1)
    end
end)

-- Apply death sound request effects
hook.Add("GetPlayerDeathSound", "DeathSoundRequestEffects", function(client, isFemale)
    local char = client:getChar()
    if char then
        -- Check if player has custom death sound
        local customDeathSound = char:getData("custom_death_sound", "")
        if customDeathSound ~= "" then
            client:notify("Using custom death sound!")
        end
    end
end)
```

---

## OnDeathSoundPlayed

**Purpose**

Called when a death sound is played.

**Parameters**

* `client` (*Player*): The player whose death sound was played.
* `deathSound` (*string*): The death sound that was played.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A death sound is played
- After `ShouldPlayDeathSound` hook
- After the sound is emitted

**Example Usage**

```lua
-- Track death sound plays
hook.Add("OnDeathSoundPlayed", "TrackDeathSoundPlays", function(client, deathSound)
    local char = client:getChar()
    if char then
        local deathSoundPlays = char:getData("death_sound_plays", 0)
        char:setData("death_sound_plays", deathSoundPlays + 1)
        
        -- Track specific death sounds
        local specificDeathSounds = char:getData("specific_death_sounds", {})
        specificDeathSounds[deathSound] = (specificDeathSounds[deathSound] or 0) + 1
        char:setData("specific_death_sounds", specificDeathSounds)
    end
    
    lia.log.add(client, "deathSoundPlayed", deathSound)
end)

-- Apply death sound play effects
hook.Add("OnDeathSoundPlayed", "DeathSoundPlayEffects", function(client, deathSound)
    -- Play additional sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Death sound played!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track death sound play statistics
hook.Add("OnDeathSoundPlayed", "TrackDeathSoundPlayStats", function(client, deathSound)
    local char = client:getChar()
    if char then
        -- Track play frequency
        local playFrequency = char:getData("death_sound_play_frequency", 0)
        char:setData("death_sound_play_frequency", playFrequency + 1)
        
        -- Track play patterns
        local playPatterns = char:getData("death_sound_play_patterns", {})
        table.insert(playPatterns, {
            sound = deathSound,
            time = os.time()
        })
        char:setData("death_sound_play_patterns", playPatterns)
    end
end)
```

---

## OnPainSoundPlayed

**Purpose**

Called when a pain sound is played.

**Parameters**

* `client` (*Player*): The player whose pain sound was played.
* `painSound` (*string*): The pain sound that was played.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A pain sound is played
- After `ShouldPlayPainSound` hook
- After the sound is emitted

**Example Usage**

```lua
-- Track pain sound plays
hook.Add("OnPainSoundPlayed", "TrackPainSoundPlays", function(client, painSound)
    local char = client:getChar()
    if char then
        local painSoundPlays = char:getData("pain_sound_plays", 0)
        char:setData("pain_sound_plays", painSoundPlays + 1)
        
        -- Track specific pain sounds
        local specificPainSounds = char:getData("specific_pain_sounds", {})
        specificPainSounds[painSound] = (specificPainSounds[painSound] or 0) + 1
        char:setData("specific_pain_sounds", specificPainSounds)
    end
    
    lia.log.add(client, "painSoundPlayed", painSound)
end)

-- Apply pain sound play effects
hook.Add("OnPainSoundPlayed", "PainSoundPlayEffects", function(client, painSound)
    -- Play additional sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify player
    client:notify("Pain sound played!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track pain sound play statistics
hook.Add("OnPainSoundPlayed", "TrackPainSoundPlayStats", function(client, painSound)
    local char = client:getChar()
    if char then
        -- Track play frequency
        local playFrequency = char:getData("pain_sound_play_frequency", 0)
        char:setData("pain_sound_play_frequency", playFrequency + 1)
        
        -- Track play patterns
        local playPatterns = char:getData("pain_sound_play_patterns", {})
        table.insert(playPatterns, {
            sound = painSound,
            time = os.time()
        })
        char:setData("pain_sound_play_patterns", playPatterns)
    end
end)
```

---

## PostScaleDamage

**Purpose**

Called after damage is scaled.

**Parameters**

* `hitgroup` (*number*): The hitgroup that was hit.
* `dmgInfo` (*CTakeDamageInfo*): The damage information.
* `damageScale` (*number*): The final damage scale value.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Damage scaling is complete
- After `GetDamageScale` hook
- After the damage is scaled

**Example Usage**

```lua
-- Track damage scaling completion
hook.Add("PostScaleDamage", "TrackDamageScalingCompletion", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local char = attacker:getChar()
        if char then
            local scalingCompletions = char:getData("damage_scaling_completions", 0)
            char:setData("damage_scaling_completions", scalingCompletions + 1)
        end
    end
end)

-- Apply post-scaling effects
hook.Add("PostScaleDamage", "PostScalingEffects", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Play completion sound
        attacker:EmitSound("buttons/button14.wav", 75, 100)
        
        -- Apply screen effect
        attacker:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.3, 0)
        
        -- Notify player
        attacker:notify("Damage scaling complete!")
    end
end)

-- Track post-scaling statistics
hook.Add("PostScaleDamage", "TrackPostScalingStats", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local char = attacker:getChar()
        if char then
            -- Track scaling frequency
            local scalingFrequency = char:getData("damage_scaling_frequency", 0)
            char:setData("damage_scaling_frequency", scalingFrequency + 1)
            
            -- Track scaling patterns
            local scalingPatterns = char:getData("damage_scaling_patterns", {})
            table.insert(scalingPatterns, {
                hitgroup = hitgroup,
                scale = damageScale,
                time = os.time()
            })
            char:setData("damage_scaling_patterns", scalingPatterns)
        end
    end
end)
```

---

## PreScaleDamage

**Purpose**

Called before damage is scaled.

**Parameters**

* `hitgroup` (*number*): The hitgroup that was hit.
* `dmgInfo` (*CTakeDamageInfo*): The damage information.
* `damageScale` (*number*): The initial damage scale value.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Damage scaling is about to begin
- Before `GetDamageScale` hook
- Before any damage calculations

**Example Usage**

```lua
-- Track damage scaling preparation
hook.Add("PreScaleDamage", "TrackDamageScalingPreparation", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local char = attacker:getChar()
        if char then
            local scalingPreparations = char:getData("damage_scaling_preparations", 0)
            char:setData("damage_scaling_preparations", scalingPreparations + 1)
        end
    end
end)

-- Apply pre-scaling effects
hook.Add("PreScaleDamage", "PreScalingEffects", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        -- Play preparation sound
        attacker:EmitSound("ui/buttonclick.wav", 75, 100)
        
        -- Apply screen effect
        attacker:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.1, 0)
        
        -- Notify player
        attacker:notify("Preparing damage scaling...")
    end
end)

-- Track pre-scaling statistics
hook.Add("PreScaleDamage", "TrackPreScalingStats", function(hitgroup, dmgInfo, damageScale)
    local attacker = dmgInfo:GetAttacker()
    local victim = dmgInfo:GetInflictor()
    
    if IsValid(attacker) and attacker:IsPlayer() then
        local char = attacker:getChar()
        if char then
            -- Track preparation frequency
            local preparationFrequency = char:getData("damage_scaling_preparation_frequency", 0)
            char:setData("damage_scaling_preparation_frequency", preparationFrequency + 1)
            
            -- Track preparation patterns
            local preparationPatterns = char:getData("damage_scaling_preparation_patterns", {})
            table.insert(preparationPatterns, {
                hitgroup = hitgroup,
                scale = damageScale,
                time = os.time()
            })
            char:setData("damage_scaling_preparation_patterns", preparationPatterns)
        end
    end
end)
```

---

## ShouldPlayDeathSound

**Purpose**

Called to determine if a death sound should be played.

**Parameters**

* `client` (*Player*): The player who died.
* `deathSound` (*string*): The death sound that would be played.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A death sound is about to be played
- After `GetPlayerDeathSound` hook
- Before `OnDeathSoundPlayed` hook

**Example Usage**

```lua
-- Control death sound playback
hook.Add("ShouldPlayDeathSound", "ControlDeathSoundPlayback", function(client, deathSound)
    local char = client:getChar()
    if char then
        -- Check if death sounds are disabled
        if char:getData("death_sounds_disabled", false) then
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
        
        -- Check cooldown
        local lastDeathSound = char:getData("last_death_sound_time", 0)
        if os.time() - lastDeathSound < 1 then -- 1 second cooldown
            return false
        end
        
        -- Update last death sound time
        char:setData("last_death_sound_time", os.time())
    end
    
    return true
end)

-- Track death sound playback checks
hook.Add("ShouldPlayDeathSound", "TrackDeathSoundPlaybackChecks", function(client, deathSound)
    local char = client:getChar()
    if char then
        local playbackChecks = char:getData("death_sound_playback_checks", 0)
        char:setData("death_sound_playback_checks", playbackChecks + 1)
    end
end)

-- Apply death sound playback check effects
hook.Add("ShouldPlayDeathSound", "DeathSoundPlaybackCheckEffects", function(client, deathSound)
    local char = client:getChar()
    if char then
        -- Check if death sounds are disabled
        if char:getData("death_sounds_disabled", false) then
            client:notify("Death sounds are disabled!")
        end
    end
end)
```

---

## ShouldPlayPainSound

**Purpose**

Called to determine if a pain sound should be played.

**Parameters**

* `client` (*Player*): The player who took damage.
* `painSound` (*string*): The pain sound that would be played.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A pain sound is about to be played
- Before `OnPainSoundPlayed` hook
- During damage processing

**Example Usage**

```lua
-- Control pain sound playback
hook.Add("ShouldPlayPainSound", "ControlPainSoundPlayback", function(client, painSound)
    local char = client:getChar()
    if char then
        -- Check if pain sounds are disabled
        if char:getData("pain_sounds_disabled", false) then
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
        
        -- Check cooldown
        local lastPainSound = char:getData("last_pain_sound_time", 0)
        if os.time() - lastPainSound < 0.5 then -- 0.5 second cooldown
            return false
        end
        
        -- Update last pain sound time
        char:setData("last_pain_sound_time", os.time())
    end
    
    return true
end)

-- Track pain sound playback checks
hook.Add("ShouldPlayPainSound", "TrackPainSoundPlaybackChecks", function(client, painSound)
    local char = client:getChar()
    if char then
        local playbackChecks = char:getData("pain_sound_playback_checks", 0)
        char:setData("pain_sound_playback_checks", playbackChecks + 1)
    end
end)

-- Apply pain sound playback check effects
hook.Add("ShouldPlayPainSound", "PainSoundPlaybackCheckEffects", function(client, painSound)
    local char = client:getChar()
    if char then
        -- Check if pain sounds are disabled
        if char:getData("pain_sounds_disabled", false) then
            client:notify("Pain sounds are disabled!")
        end
    end
end)
```
