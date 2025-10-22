# Hooks

This document describes the hooks available in the NPC Spawner module for managing automatic NPC spawning functionality.

---

## CanNPCSpawn

**Purpose**

Called to determine if an NPC can spawn in a zone.

**Parameters**

* `zone` (*table*): The spawn zone data.
* `npcType` (*string*): The NPC type to spawn.
* `group` (*string*): The spawn group.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC is about to spawn
- Before `PreNPCSpawn` hook
- When the spawn validation begins

**Example Usage**

```lua
-- Control NPC spawning
hook.Add("CanNPCSpawn", "ControlNPCSpawning", function(zone, npcType, group)
    -- Check if NPC spawning is disabled
    if lia.data.get("npc_spawning_disabled", false) then
        return false
    end
    
    -- Check if zone is restricted
    if zone.restricted then
        return false
    end
    
    -- Check if NPC type is allowed
    local allowedTypes = lia.data.get("allowed_npc_types", {})
    if not table.HasValue(allowedTypes, npcType) then
        return false
    end
    
    return true
end)

-- Track NPC spawn checks
hook.Add("CanNPCSpawn", "TrackNPCSpawnChecks", function(zone, npcType, group)
    -- Track check
    local checks = lia.data.get("npc_spawn_checks", 0)
    lia.data.set("npc_spawn_checks", checks + 1)
    
    lia.log.add(nil, "npcSpawnCheck", zone, npcType, group)
end)

-- Apply NPC spawn check effects
hook.Add("CanNPCSpawn", "NPCSpawnCheckEffects", function(zone, npcType, group)
    -- Create check effect
    local effect = EffectData()
    effect:SetOrigin(zone.pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)
```

---

## OnNPCForceSpawn

**Purpose**

Called when an NPC is force spawned by an admin.

**Parameters**

* `client` (*Player*): The admin who force spawned the NPC.
* `selectedSpawner` (*string*): The selected spawner.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An admin force spawns an NPC
- During admin command execution
- When the force spawn is initiated

**Example Usage**

```lua
-- Track NPC force spawns
hook.Add("OnNPCForceSpawn", "TrackNPCForceSpawns", function(client, selectedSpawner)
    local char = client:getChar()
    if char then
        local forceSpawns = char:getData("npc_force_spawns", 0)
        char:setData("npc_force_spawns", forceSpawns + 1)
    end
    
    lia.log.add(client, "npcForceSpawned", selectedSpawner)
end)

-- Apply NPC force spawn effects
hook.Add("OnNPCForceSpawn", "NPCForceSpawnEffects", function(client, selectedSpawner)
    -- Play force spawn sound
    client:EmitSound("ui/buttonclick.wav", 75, 100)
    
    -- Apply screen effect
    client:ScreenFade(SCREENFADE.IN, Color(0, 255, 0, 15), 0.5, 0)
    
    -- Notify player
    client:notify("NPC force spawned: " .. selectedSpawner .. "!")
    
    -- Create particle effect
    local effect = EffectData()
    effect:SetOrigin(client:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
end)

-- Track NPC force spawn statistics
hook.Add("OnNPCForceSpawn", "TrackNPCForceSpawnStats", function(client, selectedSpawner)
    local char = client:getChar()
    if char then
        -- Track force spawn frequency
        local forceSpawnFrequency = char:getData("npc_force_spawn_frequency", 0)
        char:setData("npc_force_spawn_frequency", forceSpawnFrequency + 1)
        
        -- Track force spawn patterns
        local forceSpawnPatterns = char:getData("npc_force_spawn_patterns", {})
        table.insert(forceSpawnPatterns, {
            spawner = selectedSpawner,
            time = os.time()
        })
        char:setData("npc_force_spawn_patterns", forceSpawnPatterns)
    end
end)
```

---

## OnNPCGroupSpawned

**Purpose**

Called when a group of NPCs is spawned.

**Parameters**

* `zone` (*table*): The spawn zone data.
* `group` (*string*): The spawn group.
* `spawned` (*number*): The number of NPCs spawned.

**Realm**

Server.

**When Called**

This hook is triggered when:
- A group of NPCs is spawned
- After `PostProcessNPCZone` hook
- When the group spawn is complete

**Example Usage**

```lua
-- Track NPC group spawns
hook.Add("OnNPCGroupSpawned", "TrackNPCGroupSpawns", function(zone, group, spawned)
    -- Track group spawn
    local groupSpawns = lia.data.get("npc_group_spawns", 0)
    lia.data.set("npc_group_spawns", groupSpawns + 1)
    
    lia.log.add(nil, "npcGroupSpawned", zone, group, spawned)
end)

-- Apply NPC group spawn effects
hook.Add("OnNPCGroupSpawned", "NPCGroupSpawnEffects", function(zone, group, spawned)
    -- Create group spawn effect
    local effect = EffectData()
    effect:SetOrigin(zone.pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("NPC group spawned: " .. group .. " (" .. spawned .. " NPCs)!")
    end
end)

-- Track NPC group spawn statistics
hook.Add("OnNPCGroupSpawned", "TrackNPCGroupSpawnStats", function(zone, group, spawned)
    -- Track group spawn frequency
    local groupSpawnFrequency = lia.data.get("npc_group_spawn_frequency", 0)
    lia.data.set("npc_group_spawn_frequency", groupSpawnFrequency + 1)
    
    -- Track group spawn patterns
    local groupSpawnPatterns = lia.data.get("npc_group_spawn_patterns", {})
    table.insert(groupSpawnPatterns, {
        group = group,
        spawned = spawned,
        time = os.time()
    })
    lia.data.set("npc_group_spawn_patterns", groupSpawnPatterns)
end)
```

---

## OnNPCSpawned

**Purpose**

Called when an NPC is spawned.

**Parameters**

* `npc` (*Entity*): The spawned NPC entity.
* `zone` (*table*): The spawn zone data.
* `group` (*string*): The spawn group.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC is successfully spawned
- After `PreNPCSpawn` hook
- Before `PostNPCSpawn` hook

**Example Usage**

```lua
-- Track NPC spawns
hook.Add("OnNPCSpawned", "TrackNPCSpawns", function(npc, zone, group)
    -- Track spawn
    local spawns = lia.data.get("npc_spawns", 0)
    lia.data.set("npc_spawns", spawns + 1)
    
    lia.log.add(nil, "npcSpawned", npc, zone, group)
end)

-- Apply NPC spawn effects
hook.Add("OnNPCSpawned", "NPCSpawnEffects", function(npc, zone, group)
    -- Create spawn effect
    local effect = EffectData()
    effect:SetOrigin(npc:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play spawn sound
    npc:EmitSound("ui/buttonclick.wav", 75, 100)
end)

-- Track NPC spawn statistics
hook.Add("OnNPCSpawned", "TrackNPCSpawnStats", function(npc, zone, group)
    -- Track spawn frequency
    local spawnFrequency = lia.data.get("npc_spawn_frequency", 0)
    lia.data.set("npc_spawn_frequency", spawnFrequency + 1)
    
    -- Track spawn patterns
    local spawnPatterns = lia.data.get("npc_spawn_patterns", {})
    table.insert(spawnPatterns, {
        class = npc:GetClass(),
        group = group,
        time = os.time()
    })
    lia.data.set("npc_spawn_patterns", spawnPatterns)
end)
```

---

## PostNPCSpawn

**Purpose**

Called after an NPC is spawned.

**Parameters**

* `npc` (*Entity*): The spawned NPC entity.
* `zone` (*table*): The spawn zone data.
* `group` (*string*): The spawn group.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC spawn is complete
- After `OnNPCSpawned` hook
- When the spawn process is finished

**Example Usage**

```lua
-- Track NPC spawn completion
hook.Add("PostNPCSpawn", "TrackNPCSpawnCompletion", function(npc, zone, group)
    -- Track completion
    local completions = lia.data.get("npc_spawn_completions", 0)
    lia.data.set("npc_spawn_completions", completions + 1)
    
    lia.log.add(nil, "npcSpawnCompleted", npc, zone, group)
end)

-- Apply post NPC spawn effects
hook.Add("PostNPCSpawn", "PostNPCSpawnEffects", function(npc, zone, group)
    -- Create completion effect
    local effect = EffectData()
    effect:SetOrigin(npc:GetPos())
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Play completion sound
    npc:EmitSound("buttons/button14.wav", 75, 100)
end)

-- Track post NPC spawn statistics
hook.Add("PostNPCSpawn", "TrackPostNPCSpawnStats", function(npc, zone, group)
    -- Track completion frequency
    local completionFrequency = lia.data.get("npc_spawn_completion_frequency", 0)
    lia.data.set("npc_spawn_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("npc_spawn_completion_patterns", {})
    table.insert(completionPatterns, {
        class = npc:GetClass(),
        group = group,
        time = os.time()
    })
    lia.data.set("npc_spawn_completion_patterns", completionPatterns)
end)
```

---

## PostNPCSpawnCycle

**Purpose**

Called after an NPC spawn cycle is complete.

**Parameters**

* `zones` (*table*): The zones that were processed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC spawn cycle is complete
- After all zones have been processed
- When the cycle ends

**Example Usage**

```lua
-- Track NPC spawn cycle completion
hook.Add("PostNPCSpawnCycle", "TrackNPCSpawnCycleCompletion", function(zones)
    -- Track completion
    local completions = lia.data.get("npc_spawn_cycle_completions", 0)
    lia.data.set("npc_spawn_cycle_completions", completions + 1)
    
    lia.log.add(nil, "npcSpawnCycleCompleted", zones)
end)

-- Apply post NPC spawn cycle effects
hook.Add("PostNPCSpawnCycle", "PostNPCSpawnCycleEffects", function(zones)
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("NPC spawn cycle completed!")
    end
end)

-- Track post NPC spawn cycle statistics
hook.Add("PostNPCSpawnCycle", "TrackPostNPCSpawnCycleStats", function(zones)
    -- Track completion frequency
    local completionFrequency = lia.data.get("npc_spawn_cycle_completion_frequency", 0)
    lia.data.set("npc_spawn_cycle_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("npc_spawn_cycle_completion_patterns", {})
    table.insert(completionPatterns, {
        zones = zones,
        time = os.time()
    })
    lia.data.set("npc_spawn_cycle_completion_patterns", completionPatterns)
end)
```

---

## PostProcessNPCZone

**Purpose**

Called after an NPC zone is processed.

**Parameters**

* `zone` (*table*): The spawn zone data.
* `group` (*string*): The spawn group.
* `spawned` (*number*): The number of NPCs spawned.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC zone is processed
- After `PreProcessNPCZone` hook
- When the zone processing is complete

**Example Usage**

```lua
-- Track NPC zone processing completion
hook.Add("PostProcessNPCZone", "TrackNPCZoneProcessingCompletion", function(zone, group, spawned)
    -- Track completion
    local completions = lia.data.get("npc_zone_processing_completions", 0)
    lia.data.set("npc_zone_processing_completions", completions + 1)
    
    lia.log.add(nil, "npcZoneProcessingCompleted", zone, group, spawned)
end)

-- Apply post process NPC zone effects
hook.Add("PostProcessNPCZone", "PostProcessNPCZoneEffects", function(zone, group, spawned)
    -- Create completion effect
    local effect = EffectData()
    effect:SetOrigin(zone.pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("NPC zone processed: " .. group .. " (" .. spawned .. " NPCs)!")
    end
end)

-- Track post process NPC zone statistics
hook.Add("PostProcessNPCZone", "TrackPostProcessNPCZoneStats", function(zone, group, spawned)
    -- Track completion frequency
    local completionFrequency = lia.data.get("npc_zone_processing_completion_frequency", 0)
    lia.data.set("npc_zone_processing_completion_frequency", completionFrequency + 1)
    
    -- Track completion patterns
    local completionPatterns = lia.data.get("npc_zone_processing_completion_patterns", {})
    table.insert(completionPatterns, {
        group = group,
        spawned = spawned,
        time = os.time()
    })
    lia.data.set("npc_zone_processing_completion_patterns", completionPatterns)
end)
```

---

## PreNPCSpawn

**Purpose**

Called before an NPC is spawned.

**Parameters**

* `zone` (*table*): The spawn zone data.
* `npcType` (*string*): The NPC type to spawn.
* `group` (*string*): The spawn group.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC is about to spawn
- After `CanNPCSpawn` hook
- Before `OnNPCSpawned` hook

**Example Usage**

```lua
-- Track NPC spawn preparation
hook.Add("PreNPCSpawn", "TrackNPCSpawnPreparation", function(zone, npcType, group)
    -- Track preparation
    local preparations = lia.data.get("npc_spawn_preparations", 0)
    lia.data.set("npc_spawn_preparations", preparations + 1)
    
    lia.log.add(nil, "npcSpawnPrepared", zone, npcType, group)
end)

-- Apply pre NPC spawn effects
hook.Add("PreNPCSpawn", "PreNPCSpawnEffects", function(zone, npcType, group)
    -- Create preparation effect
    local effect = EffectData()
    effect:SetOrigin(zone.pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing NPC spawn: " .. npcType .. "!")
    end
end)

-- Track pre NPC spawn statistics
hook.Add("PreNPCSpawn", "TrackPreNPCSpawnStats", function(zone, npcType, group)
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("npc_spawn_preparation_frequency", 0)
    lia.data.set("npc_spawn_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("npc_spawn_preparation_patterns", {})
    table.insert(preparationPatterns, {
        npcType = npcType,
        group = group,
        time = os.time()
    })
    lia.data.set("npc_spawn_preparation_patterns", preparationPatterns)
end)
```

---

## PreNPCSpawnCycle

**Purpose**

Called before an NPC spawn cycle begins.

**Parameters**

* `zones` (*table*): The zones that will be processed.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC spawn cycle is about to begin
- Before any zones are processed
- When the cycle starts

**Example Usage**

```lua
-- Track NPC spawn cycle preparation
hook.Add("PreNPCSpawnCycle", "TrackNPCSpawnCyclePreparation", function(zones)
    -- Track preparation
    local preparations = lia.data.get("npc_spawn_cycle_preparations", 0)
    lia.data.set("npc_spawn_cycle_preparations", preparations + 1)
    
    lia.log.add(nil, "npcSpawnCyclePrepared", zones)
end)

-- Apply pre NPC spawn cycle effects
hook.Add("PreNPCSpawnCycle", "PreNPCSpawnCycleEffects", function(zones)
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing NPC spawn cycle...")
    end
end)

-- Track pre NPC spawn cycle statistics
hook.Add("PreNPCSpawnCycle", "TrackPreNPCSpawnCycleStats", function(zones)
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("npc_spawn_cycle_preparation_frequency", 0)
    lia.data.set("npc_spawn_cycle_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("npc_spawn_cycle_preparation_patterns", {})
    table.insert(preparationPatterns, {
        zones = zones,
        time = os.time()
    })
    lia.data.set("npc_spawn_cycle_preparation_patterns", preparationPatterns)
end)
```

---

## PreProcessNPCZone

**Purpose**

Called before an NPC zone is processed.

**Parameters**

* `zone` (*table*): The spawn zone data.
* `group` (*string*): The spawn group.

**Realm**

Server.

**When Called**

This hook is triggered when:
- An NPC zone is about to be processed
- Before any NPCs are spawned
- When the zone processing begins

**Example Usage**

```lua
-- Track NPC zone processing preparation
hook.Add("PreProcessNPCZone", "TrackNPCZoneProcessingPreparation", function(zone, group)
    -- Track preparation
    local preparations = lia.data.get("npc_zone_processing_preparations", 0)
    lia.data.set("npc_zone_processing_preparations", preparations + 1)
    
    lia.log.add(nil, "npcZoneProcessingPrepared", zone, group)
end)

-- Apply pre process NPC zone effects
hook.Add("PreProcessNPCZone", "PreProcessNPCZoneEffects", function(zone, group)
    -- Create preparation effect
    local effect = EffectData()
    effect:SetOrigin(zone.pos)
    effect:SetMagnitude(1)
    effect:SetScale(1)
    util.Effect("Explosion", effect)
    
    -- Notify all players
    for _, client in player.Iterator() do
        client:notify("Preparing NPC zone processing: " .. group .. "!")
    end
end)

-- Track pre process NPC zone statistics
hook.Add("PreProcessNPCZone", "TrackPreProcessNPCZoneStats", function(zone, group)
    -- Track preparation frequency
    local preparationFrequency = lia.data.get("npc_zone_processing_preparation_frequency", 0)
    lia.data.set("npc_zone_processing_preparation_frequency", preparationFrequency + 1)
    
    -- Track preparation patterns
    local preparationPatterns = lia.data.get("npc_zone_processing_preparation_patterns", {})
    table.insert(preparationPatterns, {
        group = group,
        time = os.time()
    })
    lia.data.set("npc_zone_processing_preparation_patterns", preparationPatterns)
end)
```
