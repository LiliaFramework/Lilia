# Hooks

This document describes the hooks available in the Perma Remove module for managing permanent entity removal functionality.

---

## CanPermaRemoveEntity

**Purpose**

Called to determine if an entity can be permanently removed.

**Parameters**

* `client` (*Player*): The player attempting to remove the entity.
* `entity` (*Entity*): The entity being removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A player attempts to permanently remove an entity
- Before `OnPermaRemoveEntity` hook
- When the removal validation begins

**Example Usage**

```lua
-- Control perma remove entity
hook.Add("CanPermaRemoveEntity", "ControlPermaRemoveEntity", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check if perma remove is disabled
        if char:getData("perma_remove_disabled", false) then
            return false
        end
        
        -- Check if player is in a restricted area
        if char:getData("in_restricted_area", false) then
            return false
        end
        
        -- Check if entity is protected
        if entity:getData("protected", false) then
            return false
        end
        
        -- Check if entity is important
        if entity:getData("important", false) then
            return false
        end
        
        -- Check cooldown
        local lastPermaRemove = char:getData("last_perma_remove_time", 0)
        if os.time() - lastPermaRemove < 5 then -- 5 second cooldown
            return false
        end
        
        -- Update last perma remove time
        char:setData("last_perma_remove_time", os.time())
    end
    
    return true
end)

-- Track perma remove entity attempts
hook.Add("CanPermaRemoveEntity", "TrackPermaRemoveEntityAttempts", function(client, entity)
    local char = client:getChar()
    if char then
        local removeAttempts = char:getData("perma_remove_attempts", 0)
        char:setData("perma_remove_attempts", removeAttempts + 1)
    end
    
    lia.log.add(client, "permaRemoveEntityAttempted", entity)
end)

-- Apply perma remove entity check effects
hook.Add("CanPermaRemoveEntity", "PermaRemoveEntityCheckEffects", function(client, entity)
    local char = client:getChar()
    if char then
        -- Check if perma remove is disabled
        if char:getData("perma_remove_disabled", false) then
            client:notify("Perma remove is disabled!")
        end
    end
end)
```

---

## OnPermaRemoveEntity

**Purpose**

Called when an entity is permanently removed.

**Parameters**

* `client` (*Player*): The player who removed the entity.
* `entity` (*Entity*): The entity that was removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An entity is permanently removed
- After `CanPermaRemoveEntity` hook
- When the removal is complete

**Example Usage**

```lua
-- Track perma remove entity
hook.Add("OnPermaRemoveEntity", "TrackPermaRemoveEntity", function(client, entity)
    local char = client:getChar()
    if char then
        local removeCount = char:getData("perma_remove_count", 0)
        char:setData("perma_remove_count", removeCount + 1)
    end
    
    lia.log.add(client, "permaRemoveEntity", entity)
end)

-- Apply perma remove entity effects
hook.Add("OnPermaRemoveEntity", "PermaRemoveEntityEffects", function(client, entity)
    -- Play removal sound
    client:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("Entity permanently removed!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track perma remove entity statistics
hook.Add("OnPermaRemoveEntity", "TrackPermaRemoveEntityStats", function(client, entity)
    local char = client:getChar()
    if char then
        -- Track removal frequency
        local removalFrequency = char:getData("perma_remove_frequency", 0)
        char:setData("perma_remove_frequency", removalFrequency + 1)
        
        -- Track removal patterns
        local removalPatterns = char:getData("perma_remove_patterns", {})
        table.insert(removalPatterns, {
            class = entity:GetClass(),
            time = os.time()
        })
        char:setData("perma_remove_patterns", removalPatterns)
    end
end)
```

---

## OnPermaRemoveLoaded

**Purpose**

Called when a perma remove entity is loaded from data.

**Parameters**

* `entity` (*Entity*): The entity that was loaded for removal.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A perma remove entity is loaded from data
- During data loading process
- When the entity is restored for removal

**Example Usage**

```lua
-- Track perma remove loaded
hook.Add("OnPermaRemoveLoaded", "TrackPermaRemoveLoaded", function(entity)
    -- Track loaded
    local loaded = lia.data.get("perma_remove_loaded", 0)
    lia.data.set("perma_remove_loaded", loaded + 1)
    
    lia.log.add(nil, "permaRemoveLoaded", entity)
end)

-- Apply perma remove loaded effects
hook.Add("OnPermaRemoveLoaded", "PermaRemoveLoadedEffects", function(entity)
    -- Create loaded effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play loaded sound
    entity:EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track perma remove loaded statistics
hook.Add("OnPermaRemoveLoaded", "TrackPermaRemoveLoadedStats", function(entity)
    -- Track loaded frequency
    local loadedFrequency = lia.data.get("perma_remove_loaded_frequency", 0)
    lia.data.set("perma_remove_loaded_frequency", loadedFrequency + 1)
    
    -- Track loaded patterns
    local loadedPatterns = lia.data.get("perma_remove_loaded_patterns", {})
    table.insert(loadedPatterns, {
        class = entity:GetClass(),
        time = os.time()
    })
    lia.data.set("perma_remove_loaded_patterns", loadedPatterns)
end)
```
