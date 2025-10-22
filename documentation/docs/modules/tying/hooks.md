# Hooks

This document describes the hooks available in the Tying module for managing player handcuffing and restraint functionality.

---

## PlayerFinishUnTying

**Purpose**

Called when a player has finished untying another player.

**Parameters**

* `client` (*Player*): The player who performed the untying.
* `entity` (*Player*): The player who was untied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player successfully completes the untying action
- The handcuff removal process is finished
- After `PlayerStartUnTying` hook

**Example Usage**

```lua
-- Track untying completion
hook.Add("PlayerFinishUnTying", "TrackUnTyingCompletion", function(client, entity)
    local char = client:getChar()
    if char then
        local untyingsCompleted = char:getData("untyings_completed", 0)
        char:setData("untyings_completed", untyingsCompleted + 1)
        
        -- Track untying targets
        local untyingTargets = char:getData("untying_targets", {})
        untyingTargets[entity:SteamID()] = (untyingTargets[entity:SteamID()] or 0) + 1
        char:setData("untying_targets", untyingTargets)
    end
    
    lia.log.add(client, "untyingCompleted", entity:Name())
end)

-- Apply untying completion effects
hook.Add("PlayerFinishUnTying", "UnTyingCompletionEffects", function(client, entity)
    -- Play completion sound
    client:EmitSound("npc/roller/blade_in.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 10), 0.5, 0)
    
    -- Notify players
    client:notify("Successfully untied " .. entity:Name() .. "!")
    entity:notify("You have been untied by " .. client:Name() .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track untying statistics
hook.Add("PlayerFinishUnTying", "TrackUnTyingStats", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track untying frequency
        local untyingFrequency = char:getData("untying_frequency", 0)
        char:setData("untying_frequency", untyingFrequency + 1)
        
        -- Track untying patterns
        local untyingPatterns = char:getData("untying_patterns", {})
        table.insert(untyingPatterns, {
            target = entity:Name(),
            time = os.time()
        })
        char:setData("untying_patterns", untyingPatterns)
    end
end)
```

---

## PlayerHandcuffed

**Purpose**

Called when a player has been handcuffed.

**Parameters**

* `target` (*Player*): The player who was handcuffed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is successfully handcuffed
- The handcuff process is completed
- After `PlayerStartHandcuff` hook

**Example Usage**

```lua
-- Track handcuffing
hook.Add("PlayerHandcuffed", "TrackHandcuffing", function(target)
    local char = target:getChar()
    if char then
        local handcuffs = char:getData("handcuffs", 0)
        char:setData("handcuffs", handcuffs + 1)
        
        -- Set handcuff data
        char:setData("handcuffed", true)
        char:setData("handcuff_time", os.time())
    end
    
    lia.log.add(target, "handcuffed")
end)

-- Apply handcuff effects
hook.Add("PlayerHandcuffed", "HandcuffEffects", function(target)
    -- Play handcuff sound
    target:EmitSound("npc/roller/blade_out.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 15), 0.5, 0)
    
    -- Notify target
    target:notify("You have been handcuffed!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track handcuff statistics
hook.Add("PlayerHandcuffed", "TrackHandcuffStats", function(target)
    local char = target:getChar()
    if char then
        -- Track handcuff frequency
        local handcuffFrequency = char:getData("handcuff_frequency", 0)
        char:setData("handcuff_frequency", handcuffFrequency + 1)
        
        -- Track handcuff patterns
        local handcuffPatterns = char:getData("handcuff_patterns", {})
        table.insert(handcuffPatterns, {
            time = os.time()
        })
        char:setData("handcuff_patterns", handcuffPatterns)
    end
end)
```

---

## PlayerStartHandcuff

**Purpose**

Called when a player is about to be handcuffed.

**Parameters**

* `target` (*Player*): The player who is about to be handcuffed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is about to be handcuffed
- Before the handcuff process begins
- Before `PlayerHandcuffed` hook

**Example Usage**

```lua
-- Track handcuff attempts
hook.Add("PlayerStartHandcuff", "TrackHandcuffAttempts", function(target)
    local char = target:getChar()
    if char then
        local handcuffAttempts = char:getData("handcuff_attempts", 0)
        char:setData("handcuff_attempts", handcuffAttempts + 1)
    end
    
    lia.log.add(target, "handcuffAttempt")
end)

-- Apply handcuff start effects
hook.Add("PlayerStartHandcuff", "HandcuffStartEffects", function(target)
    -- Play start sound
    target:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(255, 255, 0, 10), 0.3, 0)
    
    -- Notify target
    target:notify("You are about to be handcuffed!")
end)

-- Validate handcuff start
hook.Add("PlayerStartHandcuff", "ValidateHandcuffStart", function(target)
    local char = target:getChar()
    if char then
        -- Check if already handcuffed
        if char:getData("handcuffed", false) then
            target:notify("You are already handcuffed!")
            return false
        end
        
        -- Check handcuff cooldown
        local lastHandcuff = char:getData("last_handcuff_time", 0)
        if os.time() - lastHandcuff < 5 then -- 5 second cooldown
            target:notify("Please wait before being handcuffed again!")
            return false
        end
        
        -- Update last handcuff time
        char:setData("last_handcuff_time", os.time())
    end
end)
```

---

## PlayerStartUnTying

**Purpose**

Called when a player starts untying another player.

**Parameters**

* `client` (*Player*): The player who is starting to untie.
* `entity` (*Player*): The player who is being untied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player starts the untying action
- Before the untying process begins
- Before `PlayerFinishUnTying` hook

**Example Usage**

```lua
-- Track untying attempts
hook.Add("PlayerStartUnTying", "TrackUnTyingAttempts", function(client, entity)
    local char = client:getChar()
    if char then
        local untyingAttempts = char:getData("untying_attempts", 0)
        char:setData("untying_attempts", untyingAttempts + 1)
    end
    
    lia.log.add(client, "untyingAttempt", entity:Name())
end)

-- Apply untying start effects
hook.Add("PlayerStartUnTying", "UnTyingStartEffects", function(client, entity)
    -- Play start sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 255, 10), 0.3, 0)
    
    -- Notify players
    client:notify("Starting to untie " .. entity:Name() .. "...")
    entity:notify("You are being untied by " .. client:Name() .. "...")
end)

-- Validate untying start
hook.Add("PlayerStartUnTying", "ValidateUnTyingStart", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check if target is handcuffed
        if not entity:IsHandcuffed() then
            client:notify("This player is not handcuffed!")
            return false
        end
        
        -- Check untying cooldown
        local lastUntying = char:getData("last_untying_time", 0)
        if os.time() - lastUntying < 3 then -- 3 second cooldown
            client:notify("Please wait before untying again!")
            return false
        end
        
        -- Update last untying time
        char:setData("last_untying_time", os.time())
    end
end)
```

---

## PlayerUnhandcuffed

**Purpose**

Called when a player has been unhandcuffed.

**Parameters**

* `target` (*Player*): The player who was unhandcuffed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is successfully unhandcuffed
- The handcuff removal process is completed
- After `ResetSubModuleCuffData` hook

**Example Usage**

```lua
-- Track unhandcuffing
hook.Add("PlayerUnhandcuffed", "TrackUnhandcuffing", function(target)
    local char = target:getChar()
    if char then
        local unhandcuffs = char:getData("unhandcuffs", 0)
        char:setData("unhandcuffs", unhandcuffs + 1)
        
        -- Clear handcuff data
        char:setData("handcuffed", false)
        char:setData("handcuff_time", nil)
    end
    
    lia.log.add(target, "unhandcuffed")
end)

-- Apply unhandcuff effects
hook.Add("PlayerUnhandcuffed", "UnhandcuffEffects", function(target)
    -- Play unhandcuff sound
    target:EmitSound("npc/roller/blade_in.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify target
    target:notify("You have been unhandcuffed!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(target:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track unhandcuff statistics
hook.Add("PlayerUnhandcuffed", "TrackUnhandcuffStats", function(target)
    local char = target:getChar()
    if char then
        -- Track unhandcuff frequency
        local unhandcuffFrequency = char:getData("unhandcuff_frequency", 0)
        char:setData("unhandcuff_frequency", unhandcuffFrequency + 1)
        
        -- Track unhandcuff patterns
        local unhandcuffPatterns = char:getData("unhandcuff_patterns", {})
        table.insert(unhandcuffPatterns, {
            time = os.time()
        })
        char:setData("unhandcuff_patterns", unhandcuffPatterns)
    end
end)
```

---

## PlayerUnTieAborted

**Purpose**

Called when a player's untying action is aborted.

**Parameters**

* `client` (*Player*): The player who was untying.
* `entity` (*Player*): The player who was being untied.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player's untying action is interrupted
- The untying process is cancelled
- After `PlayerStartUnTying` hook

**Example Usage**

```lua
-- Track untying aborts
hook.Add("PlayerUnTieAborted", "TrackUnTyingAborts", function(client, entity)
    local char = client:getChar()
    if char then
        local untyingAborts = char:getData("untying_aborts", 0)
        char:setData("untying_aborts", untyingAborts + 1)
    end
    
    lia.log.add(client, "untyingAborted", entity:Name())
end)

-- Apply untying abort effects
hook.Add("PlayerUnTieAborted", "UnTyingAbortEffects", function(client, entity)
    -- Play abort sound
    client:EmitSound("buttons/button16.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(255, 0, 0, 10), 0.3, 0)
    
    -- Notify players
    client:notify("Untying aborted!")
    entity:notify("Untying was aborted!")
end)

-- Track untying abort patterns
hook.Add("PlayerUnTieAborted", "TrackUnTyingAbortPatterns", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track abort frequency
        local abortFrequency = char:getData("untying_abort_frequency", 0)
        char:setData("untying_abort_frequency", abortFrequency + 1)
        
        -- Track abort patterns
        local abortPatterns = char:getData("untying_abort_patterns", {})
        table.insert(abortPatterns, {
            target = entity:Name(),
            time = os.time()
        })
        char:setData("untying_abort_patterns", abortPatterns)
    end
end)
```

---

## ResetSubModuleCuffData

**Purpose**

Called when handcuff data needs to be reset for submodules.

**Parameters**

* `target` (*Player*): The player whose handcuff data is being reset.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player is unhandcuffed
- Handcuff data needs to be cleared
- Before `PlayerUnhandcuffed` hook

**Example Usage**

```lua
-- Reset handcuff data for submodules
hook.Add("ResetSubModuleCuffData", "ResetHandcuffData", function(target)
    local char = target:getChar()
    if char then
        -- Clear all handcuff related data
        char:setData("handcuffed", false)
        char:setData("handcuff_time", nil)
        char:setData("handcuff_attacker", nil)
        char:setData("handcuff_reason", nil)
        
        -- Clear submodule specific data
        char:setData("search_data", nil)
        char:setData("confiscated_items", nil)
        char:setData("handcuff_restrictions", nil)
    end
    
    lia.log.add(target, "handcuffDataReset")
end)

-- Apply data reset effects
hook.Add("ResetSubModuleCuffData", "DataResetEffects", function(target)
    -- Play reset sound
    target:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    target:ScreenFade(SCREENFADE.IN, Color(0, 255, 255, 5), 0.2, 0)
    
    -- Notify target
    target:notify("Handcuff data reset!")
end)

-- Track data reset statistics
hook.Add("ResetSubModuleCuffData", "TrackDataResetStats", function(target)
    local char = target:getChar()
    if char then
        -- Track reset frequency
        local dataResets = char:getData("handcuff_data_resets", 0)
        char:setData("handcuff_data_resets", dataResets + 1)
        
        -- Track reset patterns
        local resetPatterns = char:getData("handcuff_reset_patterns", {})
        table.insert(resetPatterns, {
            time = os.time()
        })
        char:setData("handcuff_reset_patterns", resetPatterns)
    end
end)
```
