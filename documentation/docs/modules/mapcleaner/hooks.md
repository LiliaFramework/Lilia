# Hooks

This document describes the hooks available in the Map Cleaner module for managing periodic map cleanup functionality.

---

## ItemCleanupEntityRemoved

**Purpose**

Called when an item entity is removed during cleanup.

**Parameters**

* `item` (*Entity*): The item entity that was removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An item entity is removed during cleanup
- During `PreItemCleanup` hook execution
- When the item is being deleted

**Example Usage**

```lua
-- Track item cleanup entity removals
hook.Add("ItemCleanupEntityRemoved", "TrackItemCleanupEntityRemovals", function(item)
    -- Track removal
    local removals = lia.data.get("item_cleanup_entity_removals", 0)
    lia.data.set("item_cleanup_entity_removals", removals + 1)
    
    lia.log.add(nil, "itemCleanupEntityRemoved", item)
end)

-- Apply item cleanup entity removal effects
hook.Add("ItemCleanupEntityRemoved", "ItemCleanupEntityRemovalEffects", function(item)
    -- Create removal effect
    local effect = EffectData()
    effect:SetOrigin(item:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play removal sound
    item:EmitSound("buttons/button16.wav", 75, 100)
end)

-- Track item cleanup entity removal statistics
hook.Add("ItemCleanupEntityRemoved", "TrackItemCleanupEntityRemovalStats", function(item)
    -- Track removal frequency
    local removalFrequency = lia.data.get("item_cleanup_entity_removal_frequency", 0)
    lia.data.set("item_cleanup_entity_removal_frequency", removalFrequency + 1)
    
    -- Track removal patterns
    local removalPatterns = lia.data.get("item_cleanup_entity_removal_patterns", {})
    table.insert(removalPatterns, {
        class = item:GetClass(),
        time = os.time()
    })
    lia.data.set("item_cleanup_entity_removal_patterns", removalPatterns)
end)
```

---

## MapCleanupEntityRemoved

**Purpose**

Called when a map entity is removed during cleanup.

**Parameters**

* `entity` (*Entity*): The map entity that was removed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A map entity is removed during cleanup
- During `PreMapCleanup` hook execution
- When the entity is being deleted

**Example Usage**

```lua
-- Track map cleanup entity removals
hook.Add("MapCleanupEntityRemoved", "TrackMapCleanupEntityRemovals", function(entity)
    -- Track removal
    local removals = lia.data.get("map_cleanup_entity_removals", 0)
    lia.data.set("map_cleanup_entity_removals", removals + 1)
    
    lia.log.add(nil, "mapCleanupEntityRemoved", entity)
end)

-- Apply map cleanup entity removal effects
hook.Add("MapCleanupEntityRemoved", "MapCleanupEntityRemovalEffects", function(entity)
    -- Create removal effect
    local effect = EffectData()
    effect:SetOrigin(entity:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play removal sound
    entity:EmitSound("buttons/button16.wav", 75, 100)
end)

-- Track map cleanup entity removal statistics
hook.Add("MapCleanupEntityRemoved", "TrackMapCleanupEntityRemovalStats", function(entity)
    -- Track removal frequency
    local removalFrequency = lia.data.get("map_cleanup_entity_removal_frequency", 0)
    lia.data.set("map_cleanup_entity_removal_frequency", removalFrequency + 1)
    
    -- Track removal patterns
    local removalPatterns = lia.data.get("map_cleanup_entity_removal_patterns", {})
    table.insert(removalPatterns, {
        class = entity:GetClass(),
        time = os.time()
    })
    lia.data.set("map_cleanup_entity_removal_patterns", removalPatterns)
end)
```

---

## PostItemCleanup

**Purpose**

Called after item cleanup is complete.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Item cleanup is complete
- After all items have been removed
- When the cleanup cycle ends

**Example Usage**

```lua
-- Track item cleanup completion
hook.Add("PostItemCleanup", "TrackItemCleanupCompletion", function()
    -- Track completion
    local completions = lia.data.get("item_cleanup_completions", 0)
    lia.data.set("item_cleanup_completions", completions + 1)
    
    lia.log.add(nil, "itemCleanupCompleted")
end)

-- Apply post item cleanup effects
hook.Add("PostItemCleanup", "PostItemCleanupEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Item cleanup completed!")
    end
end)

-- Track post item cleanup statistics
hook.Add("PostItemCleanup", "TrackPostItemCleanupStats", function()
    -- Track completion frequency
    local completionFrequency = lia.data.get("item_cleanup_completion_frequency", 0)
    lia.data.set("item_cleanup_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("item_cleanup_completion_patterns", {})
    table.insert(completionPatterns, {
        time = os.time()
    })
    lia.data.set("item_cleanup_completion_patterns", completionPatterns)
end)
```

---

## PostItemCleanupWarning

**Purpose**

Called after item cleanup warning is sent.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Item cleanup warning is sent to all players
- After `PreItemCleanupWarning` hook
- When the warning cycle ends

**Example Usage**

```lua
-- Track item cleanup warning completion
hook.Add("PostItemCleanupWarning", "TrackItemCleanupWarningCompletion", function()
    -- Track completion
    local completions = lia.data.get("item_cleanup_warning_completions", 0)
    lia.data.set("item_cleanup_warning_completions", completions + 1)
    
    lia.log.add(nil, "itemCleanupWarningCompleted")
end)

-- Apply post item cleanup warning effects
hook.Add("PostItemCleanupWarning", "PostItemCleanupWarningEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Item cleanup warning sent!")
    end
end)

-- Track post item cleanup warning statistics
hook.Add("PostItemCleanupWarning", "TrackPostItemCleanupWarningStats", function()
    -- Track completion frequency
    local completionFrequency = lia.data.get("item_cleanup_warning_completion_frequency", 0)
    lia.data.set("item_cleanup_warning_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("item_cleanup_warning_completion_patterns", {})
    table.insert(completionPatterns, {
        time = os.time()
    })
    lia.data.set("item_cleanup_warning_completion_patterns", completionPatterns)
end)
```

---

## PostMapCleanup

**Purpose**

Called after map cleanup is complete.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Map cleanup is complete
- After all map entities have been removed
- When the cleanup cycle ends

**Example Usage**

```lua
-- Track map cleanup completion
hook.Add("PostMapCleanup", "TrackMapCleanupCompletion", function()
    -- Track completion
    local completions = lia.data.get("map_cleanup_completions", 0)
    lia.data.set("map_cleanup_completions", completions + 1)
    
    lia.log.add(nil, "mapCleanupCompleted")
end)

-- Apply post map cleanup effects
hook.Add("PostMapCleanup", "PostMapCleanupEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Map cleanup completed!")
    end
end)

-- Track post map cleanup statistics
hook.Add("PostMapCleanup", "TrackPostMapCleanupStats", function()
    -- Track completion frequency
    local completionFrequency = lia.data.get("map_cleanup_completion_frequency", 0)
    lia.data.set("map_cleanup_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("map_cleanup_completion_patterns", {})
    table.insert(completionPatterns, {
        time = os.time()
    })
    lia.data.set("map_cleanup_completion_patterns", completionPatterns)
end)
```

---

## PostMapCleanupWarning

**Purpose**

Called after map cleanup warning is sent.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Map cleanup warning is sent to all players
- After `PreMapCleanupWarning` hook
- When the warning cycle ends

**Example Usage**

```lua
-- Track map cleanup warning completion
hook.Add("PostMapCleanupWarning", "TrackMapCleanupWarningCompletion", function()
    -- Track completion
    local completions = lia.data.get("map_cleanup_warning_completions", 0)
    lia.data.set("map_cleanup_warning_completions", completions + 1)
    
    lia.log.add(nil, "mapCleanupWarningCompleted")
end)

-- Apply post map cleanup warning effects
hook.Add("PostMapCleanupWarning", "PostMapCleanupWarningEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Map cleanup warning sent!")
    end
end)

-- Track post map cleanup warning statistics
hook.Add("PostMapCleanupWarning", "TrackPostMapCleanupWarningStats", function()
    -- Track completion frequency
    local completionFrequency = lia.data.get("map_cleanup_warning_completion_frequency", 0)
    lia.data.set("map_cleanup_warning_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("map_cleanup_warning_completion_patterns", {})
    table.insert(completionPatterns, {
        time = os.time()
    })
    lia.data.set("map_cleanup_warning_completion_patterns", completionPatterns)
end)
```

---

## PreItemCleanup

**Purpose**

Called before item cleanup begins.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Item cleanup is about to begin
- Before items are removed
- When the cleanup cycle starts

**Example Usage**

```lua
-- Track item cleanup preparation
hook.Add("PreItemCleanup", "TrackItemCleanupPreparation", function()
    -- Track preparation
    local preparations = lia.data.get("item_cleanup_preparations", 0)
    lia.data.set("item_cleanup_preparations", preparations + 1)
    
    lia.log.add(nil, "itemCleanupPrepared")
end)

-- Apply pre item cleanup effects
hook.Add("PreItemCleanup", "PreItemCleanupEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing item cleanup...")
    end
end)

-- Track pre item cleanup statistics
hook.Add("PreItemCleanup", "TrackPreItemCleanupStats", function()
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("item_cleanup_preparation_frequency", 0)
    lia.data.set("item_cleanup_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("item_cleanup_preparation_patterns", {})
    table.insert(preparationPatterns, {
        time = os.time()
    })
    lia.data.set("item_cleanup_preparation_patterns", preparationPatterns)
end)
```

---

## PreItemCleanupWarning

**Purpose**

Called before item cleanup warning is sent.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Item cleanup warning is about to be sent
- Before players are notified
- When the warning cycle starts

**Example Usage**

```lua
-- Track item cleanup warning preparation
hook.Add("PreItemCleanupWarning", "TrackItemCleanupWarningPreparation", function()
    -- Track preparation
    local preparations = lia.data.get("item_cleanup_warning_preparations", 0)
    lia.data.set("item_cleanup_warning_preparations", preparations + 1)
    
    lia.log.add(nil, "itemCleanupWarningPrepared")
end)

-- Apply pre item cleanup warning effects
hook.Add("PreItemCleanupWarning", "PreItemCleanupWarningEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing item cleanup warning...")
    end
end)

-- Track pre item cleanup warning statistics
hook.Add("PreItemCleanupWarning", "TrackPreItemCleanupWarningStats", function()
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("item_cleanup_warning_preparation_frequency", 0)
    lia.data.set("item_cleanup_warning_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("item_cleanup_warning_preparation_patterns", {})
    table.insert(preparationPatterns, {
        time = os.time()
    })
    lia.data.set("item_cleanup_warning_preparation_patterns", preparationPatterns)
end)
```

---

## PreMapCleanup

**Purpose**

Called before map cleanup begins.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Map cleanup is about to begin
- Before map entities are removed
- When the cleanup cycle starts

**Example Usage**

```lua
-- Track map cleanup preparation
hook.Add("PreMapCleanup", "TrackMapCleanupPreparation", function()
    -- Track preparation
    local preparations = lia.data.get("map_cleanup_preparations", 0)
    lia.data.set("map_cleanup_preparations", preparations + 1)
    
    lia.log.add(nil, "mapCleanupPrepared")
end)

-- Apply pre map cleanup effects
hook.Add("PreMapCleanup", "PreMapCleanupEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing map cleanup...")
    end
end)

-- Track pre map cleanup statistics
hook.Add("PreMapCleanup", "TrackPreMapCleanupStats", function()
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("map_cleanup_preparation_frequency", 0)
    lia.data.set("map_cleanup_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("map_cleanup_preparation_patterns", {})
    table.insert(preparationPatterns, {
        time = os.time()
    })
    lia.data.set("map_cleanup_preparation_patterns", preparationPatterns)
end)
```

---

## PreMapCleanupWarning

**Purpose**

Called before map cleanup warning is sent.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- Map cleanup warning is about to be sent
- Before players are notified
- When the warning cycle starts

**Example Usage**

```lua
-- Track map cleanup warning preparation
hook.Add("PreMapCleanupWarning", "TrackMapCleanupWarningPreparation", function()
    -- Track preparation
    local preparations = lia.data.get("map_cleanup_warning_preparations", 0)
    lia.data.set("map_cleanup_warning_preparations", preparations + 1)
    
    lia.log.add(nil, "mapCleanupWarningPrepared")
end)

-- Apply pre map cleanup warning effects
hook.Add("PreMapCleanupWarning", "PreMapCleanupWarningEffects", function()
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing map cleanup warning...")
    end
end)

-- Track pre map cleanup warning statistics
hook.Add("PreMapCleanupWarning", "TrackPreMapCleanupWarningStats", function()
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("map_cleanup_warning_preparation_frequency", 0)
    lia.data.set("map_cleanup_warning_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("map_cleanup_warning_preparation_patterns", {})
    table.insert(preparationPatterns, {
        time = os.time()
    })
    lia.data.set("map_cleanup_warning_preparation_patterns", preparationPatterns)
end)
```
