# Hooks

This document describes the hooks available in the Utilities module for managing utility functions and entity spawning.

---

## CodeUtilsLoaded

**Purpose**

Called when the utilities module has finished loading.

**Parameters**

None.

**Realm**

Server.

**When Called**

This hook is triggered when:
- The utilities module has finished initializing
- All utility functions are available
- The module is ready for use

**Example Usage**

```lua
-- Track utilities loading
hook.Add("CodeUtilsLoaded", "TrackUtilsLoading", function()
    lia.log.add(nil, "utilitiesLoaded")
    
    -- Notify all players
    for _, ply in player.Iterator() do
        ply:notify("Utilities module loaded!")
    end
end)

-- Apply loading effects
hook.Add("CodeUtilsLoaded", "UtilsLoadingEffects", function()
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(Vector(0, 0, 0))
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Print loading message
    print("Utilities module loaded successfully!")
end)

-- Initialize utilities data
hook.Add("CodeUtilsLoaded", "InitializeUtilsData", function()
    -- Set up utilities data
    lia.data.set("utilities_loaded", true)
    lia.data.set("utilities_load_time", os.time())
    
    -- Initialize utility counters
    lia.data.set("utility_props_spawned", 0)
    lia.data.set("utility_entities_spawned", 0)
end)
```

---

## UtilityEntitySpawned

**Purpose**

Called when a utility entity has been spawned.

**Parameters**

* `entity` (*Entity*): The entity that was spawned.
* `class` (*string*): The class name of the entity.
* `position` (*Vector*): The position where the entity was spawned.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A utility entity is spawned using `lia.utilities.spawnEntities`
- The entity is successfully created and positioned
- After the entity is spawned

**Example Usage**

```lua
-- Track utility entity spawning
hook.Add("UtilityEntitySpawned", "TrackUtilityEntitySpawning", function(entity, class, position)
    local entitySpawns = lia.data.get("utility_entities_spawned", 0)
    lia.data.set("utility_entities_spawned", entitySpawns + 1)
    
    -- Track entity types
    local entityTypes = lia.data.get("utility_entity_types", {})
    entityTypes[class] = (entityTypes[class] or 0) + 1
    lia.data.set("utility_entity_types", entityTypes)
    
    lia.log.add(nil, "utilityEntitySpawned", class, position)
end)

-- Apply entity spawn effects
hook.Add("UtilityEntitySpawned", "UtilityEntitySpawnEffects", function(entity, class, position)
    -- Play spawn sound
    entity:EmitSound("buttons/button14.wav", 75, 100)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(position)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify nearby players
    for _, ply in player.Iterator() do
        if ply:GetPos():Distance(position) < 500 then
            ply:notify("Utility entity spawned: " .. class)
        end
    end
end)

-- Track entity spawn statistics
hook.Add("UtilityEntitySpawned", "TrackEntitySpawnStats", function(entity, class, position)
    -- Track spawn frequency
    local spawnFrequency = lia.data.get("utility_entity_spawn_frequency", 0)
    lia.data.set("utility_entity_spawn_frequency", spawnFrequency + 1)
    
    -- Track spawn patterns
    local spawnPatterns = lia.data.get("utility_entity_spawn_patterns", {})
    table.insert(spawnPatterns, {
        class = class,
        position = position,
        time = os.time()
    })
    lia.data.set("utility_entity_spawn_patterns", spawnPatterns)
end)
```

---

## UtilityPropSpawned

**Purpose**

Called when a utility prop has been spawned.

**Parameters**

* `entity` (*Entity*): The prop entity that was spawned.
* `model` (*string*): The model path of the prop.
* `position` (*Vector*): The position where the prop was spawned.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A utility prop is spawned using `lia.utilities.spawnProp`
- The prop is successfully created and positioned
- After the prop is spawned

**Example Usage**

```lua
-- Track utility prop spawning
hook.Add("UtilityPropSpawned", "TrackUtilityPropSpawning", function(entity, model, position)
    local propSpawns = lia.data.get("utility_props_spawned", 0)
    lia.data.set("utility_props_spawned", propSpawns + 1)
    
    -- Track prop models
    local propModels = lia.data.get("utility_prop_models", {})
    propModels[model] = (propModels[model] or 0) + 1
    lia.data.set("utility_prop_models", propModels)
    
    lia.log.add(nil, "utilityPropSpawned", model, position)
end)

-- Apply prop spawn effects
hook.Add("UtilityPropSpawned", "UtilityPropSpawnEffects", function(entity, model, position)
    -- Play spawn sound
    entity:EmitSound("buttons/button15.wav", 75, 100)
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(position)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify nearby players
    for _, ply in player.Iterator() do
        if ply:GetPos():Distance(position) < 500 then
            ply:notify("Utility prop spawned: " .. model)
        end
    end
end)

-- Track prop spawn statistics
hook.Add("UtilityPropSpawned", "TrackPropSpawnStats", function(entity, model, position)
    -- Track spawn frequency
    local spawnFrequency = lia.data.get("utility_prop_spawn_frequency", 0)
    lia.data.set("utility_prop_spawn_frequency", spawnFrequency + 1)
    
    -- Track spawn patterns
    local spawnPatterns = lia.data.get("utility_prop_spawn_patterns", {})
    table.insert(spawnPatterns, {
        model = model,
        position = position,
        time = os.time()
    })
    lia.data.set("utility_prop_spawn_patterns", spawnPatterns)
end)
```
