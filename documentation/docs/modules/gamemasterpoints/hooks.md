# Hooks

This document describes the hooks available in the Gamemaster Points module for managing teleport points functionality.

---

## GamemasterAddPoint

**Purpose**

Called when a gamemaster point is added.

**Parameters**

* `client` (*Player*): The player who added the point.
* `name` (*string*): The name of the point.
* `pos` (*Vector*): The position of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is successfully added
- After `GamemasterPreAddPoint` hook
- After the point is saved to data

**Example Usage**

```lua
-- Track gamemaster point additions
hook.Add("GamemasterAddPoint", "TrackGamemasterPointAdditions", function(client, name, pos)
    local char = client:getChar()
    if char then
        local pointAdditions = char:getData("gamemaster_point_additions", 0)
        char:setData("gamemaster_point_additions", pointAdditions + 1)
        
        -- Track point names
        local pointNames = char:getData("gamemaster_point_names", {})
        pointNames[name] = (pointNames[name] or 0) + 1
        char:setData("gamemaster_point_names", pointNames)
    end
    
    lia.log.add(client, "gamemasterPointAdded", name, pos)
end)

-- Apply gamemaster point addition effects
hook.Add("GamemasterAddPoint", "GamemasterPointAdditionEffects", function(client, name, pos)
    -- Play addition sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Gamemaster point added: " .. name .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point addition statistics
hook.Add("GamemasterAddPoint", "TrackGamemasterPointAdditionStats", function(client, name, pos)
    local char = client:getChar()
    if char then
        -- Track addition frequency
        local additionFrequency = char:getData("gamemaster_point_addition_frequency", 0)
        char:setData("gamemaster_point_addition_frequency", additionFrequency + 1)
        
        -- Track addition patterns
        local additionPatterns = char:getData("gamemaster_point_addition_patterns", {})
        table.insert(additionPatterns, {
            name = name,
            pos = pos,
            time = os.time()
        })
        char:setData("gamemaster_point_addition_patterns", additionPatterns)
    end
end)
```

---

## GamemasterMoveToPoint

**Purpose**

Called when a player moves to a gamemaster point.

**Parameters**

* `client` (*Player*): The player who moved to the point.
* `properName` (*string*): The proper name of the point.
* `pos` (*Vector*): The position of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player successfully moves to a gamemaster point
- After `GamemasterPreMoveToPoint` hook
- After the player is teleported

**Example Usage**

```lua
-- Track gamemaster point movements
hook.Add("GamemasterMoveToPoint", "TrackGamemasterPointMovements", function(client, properName, pos)
    local char = client:getChar()
    if char then
        local pointMovements = char:getData("gamemaster_point_movements", 0)
        char:setData("gamemaster_point_movements", pointMovements + 1)
        
        -- Track movement destinations
        local movementDestinations = char:getData("gamemaster_movement_destinations", {})
        movementDestinations[properName] = (movementDestinations[properName] or 0) + 1
        char:setData("gamemaster_movement_destinations", movementDestinations)
    end
    
    lia.log.add(client, "gamemasterMovedToPoint", properName, pos)
end)

-- Apply gamemaster point movement effects
hook.Add("GamemasterMoveToPoint", "GamemasterPointMovementEffects", function(client, properName, pos)
    -- Play movement sound
    client:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Moved to gamemaster point: " .. properName .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point movement statistics
hook.Add("GamemasterMoveToPoint", "TrackGamemasterPointMovementStats", function(client, properName, pos)
    local char = client:getChar()
    if char then
        -- Track movement frequency
        local movementFrequency = char:getData("gamemaster_point_movement_frequency", 0)
        char:setData("gamemaster_point_movement_frequency", movementFrequency + 1)
        
        -- Track movement patterns
        local movementPatterns = char:getData("gamemaster_point_movement_patterns", {})
        table.insert(movementPatterns, {
            name = properName,
            pos = pos,
            time = os.time()
        })
        char:setData("gamemaster_point_movement_patterns", movementPatterns)
    end
end)
```

---

## GamemasterPreAddPoint

**Purpose**

Called before a gamemaster point is added.

**Parameters**

* `client` (*Player*): The player attempting to add the point.
* `name` (*string*): The name of the point.
* `pos` (*Vector*): The position of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is about to be added
- Before `GamemasterAddPoint` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point addition
hook.Add("GamemasterPreAddPoint", "ValidateGamemasterPointAddition", function(client, name, pos)
    local char = client:getChar()
    if char then
        -- Check if point addition is disabled
        if char:getData("gamemaster_point_addition_disabled", false) then
            client:notify("Gamemaster point addition is disabled!")
            return false
        end
        
        -- Check if point name already exists
        local existingPoints = lia.data.get("TPPoints", {})
        for _, point in pairs(existingPoints) do
            if point.name == name then
                client:notify("A point with this name already exists!")
                return false
            end
        end
        
        -- Check cooldown
        local lastAddition = char:getData("last_gamemaster_point_addition_time", 0)
        if os.time() - lastAddition < 5 then -- 5 second cooldown
            client:notify("Please wait before adding another point!")
            return false
        end
        
        -- Update last addition time
        char:setData("last_gamemaster_point_addition_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point addition attempts
hook.Add("GamemasterPreAddPoint", "TrackGamemasterPointAdditionAttempts", function(client, name, pos)
    local char = client:getChar()
    if char then
        local additionAttempts = char:getData("gamemaster_point_addition_attempts", 0)
        char:setData("gamemaster_point_addition_attempts", additionAttempts + 1)
    end
end)

-- Apply pre-addition effects
hook.Add("GamemasterPreAddPoint", "PreGamemasterPointAdditionEffects", function(client, name, pos)
    -- Play pre-addition sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Adding gamemaster point: " .. name .. "...")
end)
```

---

## GamemasterPreMoveToPoint

**Purpose**

Called before a player moves to a gamemaster point.

**Parameters**

* `client` (*Player*): The player attempting to move to the point.
* `name` (*string*): The name of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is about to move to a gamemaster point
- Before `GamemasterMoveToPoint` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point movement
hook.Add("GamemasterPreMoveToPoint", "ValidateGamemasterPointMovement", function(client, name)
    local char = client:getChar()
    if char then
        -- Check if point movement is disabled
        if char:getData("gamemaster_point_movement_disabled", false) then
            client:notify("Gamemaster point movement is disabled!")
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            client:notify("Cannot use gamemaster points in this area!")
            return false
        end
        
        -- Check cooldown
        local lastMovement = char:getData("last_gamemaster_point_movement_time", 0)
        if os.time() - lastMovement < 3 then -- 3 second cooldown
            client:notify("Please wait before moving to another point!")
            return false
        end
        
        -- Update last movement time
        char:setData("last_gamemaster_point_movement_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point movement attempts
hook.Add("GamemasterPreMoveToPoint", "TrackGamemasterPointMovementAttempts", function(client, name)
    local char = client:getChar()
    if char then
        local movementAttempts = char:getData("gamemaster_point_movement_attempts", 0)
        char:setData("gamemaster_point_movement_attempts", movementAttempts + 1)
    end
end)

-- Apply pre-movement effects
hook.Add("GamemasterPreMoveToPoint", "PreGamemasterPointMovementEffects", function(client, name)
    -- Play pre-movement sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Moving to gamemaster point: " .. name .. "...")
end)
```

---

## GamemasterPreRemovePoint

**Purpose**

Called before a gamemaster point is removed.

**Parameters**

* `client` (*Player*): The player attempting to remove the point.
* `name` (*string*): The name of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is about to be removed
- Before `GamemasterRemovePoint` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point removal
hook.Add("GamemasterPreRemovePoint", "ValidateGamemasterPointRemoval", function(client, name)
    local char = client:getChar()
    if char then
        -- Check if point removal is disabled
        if char:getData("gamemaster_point_removal_disabled", false) then
            client:notify("Gamemaster point removal is disabled!")
            return false
        end
        
        -- Check cooldown
        local lastRemoval = char:getData("last_gamemaster_point_removal_time", 0)
        if os.time() - lastRemoval < 2 then -- 2 second cooldown
            client:notify("Please wait before removing another point!")
            return false
        end
        
        -- Update last removal time
        char:setData("last_gamemaster_point_removal_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point removal attempts
hook.Add("GamemasterPreRemovePoint", "TrackGamemasterPointRemovalAttempts", function(client, name)
    local char = client:getChar()
    if char then
        local removalAttempts = char:getData("gamemaster_point_removal_attempts", 0)
        char:setData("gamemaster_point_removal_attempts", removalAttempts + 1)
    end
end)

-- Apply pre-removal effects
hook.Add("GamemasterPreRemovePoint", "PreGamemasterPointRemovalEffects", function(client, name)
    -- Play pre-removal sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Removing gamemaster point: " .. name .. "...")
end)
```

---

## GamemasterPreRenamePoint

**Purpose**

Called before a gamemaster point is renamed.

**Parameters**

* `client` (*Player*): The player attempting to rename the point.
* `name` (*string*): The current name of the point.
* `newName` (*string*): The new name for the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is about to be renamed
- Before `GamemasterRenamePoint` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point renaming
hook.Add("GamemasterPreRenamePoint", "ValidateGamemasterPointRenaming", function(client, name, newName)
    local char = client:getChar()
    if char then
        -- Check if point renaming is disabled
        if char:getData("gamemaster_point_renaming_disabled", false) then
            client:notify("Gamemaster point renaming is disabled!")
            return false
        end
        
        -- Check if new name already exists
        local existingPoints = lia.data.get("TPPoints", {})
        for _, point in pairs(existingPoints) do
            if point.name == newName then
                client:notify("A point with this name already exists!")
                return false
            end
        end
        
        -- Check cooldown
        local lastRename = char:getData("last_gamemaster_point_rename_time", 0)
        if os.time() - lastRename < 2 then -- 2 second cooldown
            client:notify("Please wait before renaming another point!")
            return false
        end
        
        -- Update last rename time
        char:setData("last_gamemaster_point_rename_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point renaming attempts
hook.Add("GamemasterPreRenamePoint", "TrackGamemasterPointRenamingAttempts", function(client, name, newName)
    local char = client:getChar()
    if char then
        local renamingAttempts = char:getData("gamemaster_point_renaming_attempts", 0)
        char:setData("gamemaster_point_renaming_attempts", renamingAttempts + 1)
    end
end)

-- Apply pre-renaming effects
hook.Add("GamemasterPreRenamePoint", "PreGamemasterPointRenamingEffects", function(client, name, newName)
    -- Play pre-renaming sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Renaming gamemaster point: " .. name .. " to " .. newName .. "...")
end)
```

---

## GamemasterPreUpdateEffect

**Purpose**

Called before a gamemaster point's effect is updated.

**Parameters**

* `client` (*Player*): The player attempting to update the effect.
* `name` (*string*): The name of the point.
* `newEffect` (*string*): The new effect for the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point's effect is about to be updated
- Before `GamemasterUpdateEffect` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point effect update
hook.Add("GamemasterPreUpdateEffect", "ValidateGamemasterPointEffectUpdate", function(client, name, newEffect)
    local char = client:getChar()
    if char then
        -- Check if effect updates are disabled
        if char:getData("gamemaster_point_effect_updates_disabled", false) then
            client:notify("Gamemaster point effect updates are disabled!")
            return false
        end
        
        -- Check cooldown
        local lastEffectUpdate = char:getData("last_gamemaster_point_effect_update_time", 0)
        if os.time() - lastEffectUpdate < 1 then -- 1 second cooldown
            client:notify("Please wait before updating another effect!")
            return false
        end
        
        -- Update last effect update time
        char:setData("last_gamemaster_point_effect_update_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point effect update attempts
hook.Add("GamemasterPreUpdateEffect", "TrackGamemasterPointEffectUpdateAttempts", function(client, name, newEffect)
    local char = client:getChar()
    if char then
        local effectUpdateAttempts = char:getData("gamemaster_point_effect_update_attempts", 0)
        char:setData("gamemaster_point_effect_update_attempts", effectUpdateAttempts + 1)
    end
end)

-- Apply pre-effect update effects
hook.Add("GamemasterPreUpdateEffect", "PreGamemasterPointEffectUpdateEffects", function(client, name, newEffect)
    -- Play pre-effect update sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Updating gamemaster point effect: " .. name .. "...")
end)
```

---

## GamemasterPreUpdateSound

**Purpose**

Called before a gamemaster point's sound is updated.

**Parameters**

* `client` (*Player*): The player attempting to update the sound.
* `name` (*string*): The name of the point.
* `newSound` (*string*): The new sound for the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point's sound is about to be updated
- Before `GamemasterUpdateSound` hook
- Before any validation

**Example Usage**

```lua
-- Validate gamemaster point sound update
hook.Add("GamemasterPreUpdateSound", "ValidateGamemasterPointSoundUpdate", function(client, name, newSound)
    local char = client:getChar()
    if char then
        -- Check if sound updates are disabled
        if char:getData("gamemaster_point_sound_updates_disabled", false) then
            client:notify("Gamemaster point sound updates are disabled!")
            return false
        end
        
        -- Check cooldown
        local lastSoundUpdate = char:getData("last_gamemaster_point_sound_update_time", 0)
        if os.time() - lastSoundUpdate < 1 then -- 1 second cooldown
            client:notify("Please wait before updating another sound!")
            return false
        end
        
        -- Update last sound update time
        char:setData("last_gamemaster_point_sound_update_time", os.time())
    end
    
    return true
end)

-- Track gamemaster point sound update attempts
hook.Add("GamemasterPreUpdateSound", "TrackGamemasterPointSoundUpdateAttempts", function(client, name, newSound)
    local char = client:getChar()
    if char then
        local soundUpdateAttempts = char:getData("gamemaster_point_sound_update_attempts", 0)
        char:setData("gamemaster_point_sound_update_attempts", soundUpdateAttempts + 1)
    end
end)

-- Apply pre-sound update effects
hook.Add("GamemasterPreUpdateSound", "PreGamemasterPointSoundUpdateEffects", function(client, name, newSound)
    -- Play pre-sound update sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 5), 0.2, 0)
    
    -- Notify player
    client:notify("Updating gamemaster point sound: " .. name .. "...")
end)
```

---

## GamemasterRemovePoint

**Purpose**

Called when a gamemaster point is removed.

**Parameters**

* `client` (*Player*): The player who removed the point.
* `properName` (*string*): The proper name of the point that was removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is successfully removed
- After `GamemasterPreRemovePoint` hook
- After the point is removed from data

**Example Usage**

```lua
-- Track gamemaster point removals
hook.Add("GamemasterRemovePoint", "TrackGamemasterPointRemovals", function(client, properName)
    local char = client:getChar()
    if char then
        local pointRemovals = char:getData("gamemaster_point_removals", 0)
        char:setData("gamemaster_point_removals", pointRemovals + 1)
    end
    
    lia.log.add(client, "gamemasterPointRemoved", properName)
end)

-- Apply gamemaster point removal effects
hook.Add("GamemasterRemovePoint", "GamemasterPointRemovalEffects", function(client, properName)
    -- Play removal sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Gamemaster point removed: " .. properName .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point removal statistics
hook.Add("GamemasterRemovePoint", "TrackGamemasterPointRemovalStats", function(client, properName)
    local char = client:getChar()
    if char then
        -- Track removal frequency
        local removalFrequency = char:getData("gamemaster_point_removal_frequency", 0)
        char:setData("gamemaster_point_removal_frequency", removalFrequency + 1)
        
        -- Track removal patterns
        local removalPatterns = char:getData("gamemaster_point_removal_patterns", {})
        table.insert(removalPatterns, {
            name = properName,
            time = os.time()
        })
        char:setData("gamemaster_point_removal_patterns", removalPatterns)
    end
end)
```

---

## GamemasterRenamePoint

**Purpose**

Called when a gamemaster point is renamed.

**Parameters**

* `client` (*Player*): The player who renamed the point.
* `oldName` (*string*): The old name of the point.
* `newName` (*string*): The new name of the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point is successfully renamed
- After `GamemasterPreRenamePoint` hook
- After the point name is updated in data

**Example Usage**

```lua
-- Track gamemaster point renames
hook.Add("GamemasterRenamePoint", "TrackGamemasterPointRenames", function(client, oldName, newName)
    local char = client:getChar()
    if char then
        local pointRenames = char:getData("gamemaster_point_renames", 0)
        char:setData("gamemaster_point_renames", pointRenames + 1)
    end
    
    lia.log.add(client, "gamemasterPointRenamed", oldName, newName)
end)

-- Apply gamemaster point rename effects
hook.Add("GamemasterRenamePoint", "GamemasterPointRenameEffects", function(client, oldName, newName)
    -- Play rename sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Gamemaster point renamed: " .. oldName .. " to " .. newName .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point rename statistics
hook.Add("GamemasterRenamePoint", "TrackGamemasterPointRenameStats", function(client, oldName, newName)
    local char = client:getChar()
    if char then
        -- Track rename frequency
        local renameFrequency = char:getData("gamemaster_point_rename_frequency", 0)
        char:setData("gamemaster_point_rename_frequency", renameFrequency + 1)
        
        -- Track rename patterns
        local renamePatterns = char:getData("gamemaster_point_rename_patterns", {})
        table.insert(renamePatterns, {
            oldName = oldName,
            newName = newName,
            time = os.time()
        })
        char:setData("gamemaster_point_rename_patterns", renamePatterns)
    end
end)
```

---

## GamemasterUpdateEffect

**Purpose**

Called when a gamemaster point's effect is updated.

**Parameters**

* `client` (*Player*): The player who updated the effect.
* `name` (*string*): The name of the point.
* `newEffect` (*string*): The new effect for the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point's effect is successfully updated
- After `GamemasterPreUpdateEffect` hook
- After the effect is saved to data

**Example Usage**

```lua
-- Track gamemaster point effect updates
hook.Add("GamemasterUpdateEffect", "TrackGamemasterPointEffectUpdates", function(client, name, newEffect)
    local char = client:getChar()
    if char then
        local effectUpdates = char:getData("gamemaster_point_effect_updates", 0)
        char:setData("gamemaster_point_effect_updates", effectUpdates + 1)
    end
    
    lia.log.add(client, "gamemasterPointEffectUpdated", name, newEffect)
end)

-- Apply gamemaster point effect update effects
hook.Add("GamemasterUpdateEffect", "GamemasterPointEffectUpdateEffects", function(client, name, newEffect)
    -- Play effect update sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Gamemaster point effect updated: " .. name .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point effect update statistics
hook.Add("GamemasterUpdateEffect", "TrackGamemasterPointEffectUpdateStats", function(client, name, newEffect)
    local char = client:getChar()
    if char then
        -- Track effect update frequency
        local effectUpdateFrequency = char:getData("gamemaster_point_effect_update_frequency", 0)
        char:setData("gamemaster_point_effect_update_frequency", effectUpdateFrequency + 1)
        
        -- Track effect update patterns
        local effectUpdatePatterns = char:getData("gamemaster_point_effect_update_patterns", {})
        table.insert(effectUpdatePatterns, {
            name = name,
            effect = newEffect,
            time = os.time()
        })
        char:setData("gamemaster_point_effect_update_patterns", effectUpdatePatterns)
    end
end)
```

---

## GamemasterUpdateSound

**Purpose**

Called when a gamemaster point's sound is updated.

**Parameters**

* `client` (*Player*): The player who updated the sound.
* `name` (*string*): The name of the point.
* `newSound` (*string*): The new sound for the point.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A gamemaster point's sound is successfully updated
- After `GamemasterPreUpdateSound` hook
- After the sound is saved to data

**Example Usage**

```lua
-- Track gamemaster point sound updates
hook.Add("GamemasterUpdateSound", "TrackGamemasterPointSoundUpdates", function(client, name, newSound)
    local char = client:getChar()
    if char then
        local soundUpdates = char:getData("gamemaster_point_sound_updates", 0)
        char:setData("gamemaster_point_sound_updates", soundUpdates + 1)
    end
    
    lia.log.add(client, "gamemasterPointSoundUpdated", name, newSound)
end)

-- Apply gamemaster point sound update effects
hook.Add("GamemasterUpdateSound", "GamemasterPointSoundUpdateEffects", function(client, name, newSound)
    -- Play sound update sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Gamemaster point sound updated: " .. name .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track gamemaster point sound update statistics
hook.Add("GamemasterUpdateSound", "TrackGamemasterPointSoundUpdateStats", function(client, name, newSound)
    local char = client:getChar()
    if char then
        -- Track sound update frequency
        local soundUpdateFrequency = char:getData("gamemaster_point_sound_update_frequency", 0)
        char:setData("gamemaster_point_sound_update_frequency", soundUpdateFrequency + 1)
        
        -- Track sound update patterns
        local soundUpdatePatterns = char:getData("gamemaster_point_sound_update_patterns", {})
        table.insert(soundUpdatePatterns, {
            name = name,
            sound = newSound,
            time = os.time()
        })
        char:setData("gamemaster_point_sound_update_patterns", soundUpdatePatterns)
    end
end)
```
