# Hooks

Module-specific events raised by the NPC Spawner module.

---

### `CanNPCSpawn`

**Purpose**

`Allows modules to disallow an NPC from spawning.`

**Parameters**

* `zone` (`table`): `Spawn zone information.`

* `npcType` (`string`): `Class name of the NPC being spawned.`

* `group` (`string`): `Identifier for the spawn group.`

**Realm**

`Server`

**Returns**

`boolean` — `Return false to cancel the spawn.`

**Example**

```lua
hook.Add("CanNPCSpawn", "BlockZombies", function(zone, npcType)
    if npcType == "npc_zombie" then return false end
end)
```

---

### `PreNPCSpawn`

**Purpose**

`Called right before an NPC entity is created.`

**Parameters**

* `zone` (`table`): `Spawn zone information.`

* `npcType` (`string`): `Class name of the NPC.`

* `group` (`string`): `Identifier for the spawn group.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PreNPCSpawn", "AnnounceSpawn", function(zone, npcType, group)
    print("Spawning" , npcType , "from" , group)
end)
```

---

### `OnNPCSpawned`

**Purpose**

`Runs after an NPC has spawned and been added to the zone list.`

**Parameters**

* `npc` (`Entity`): `The spawned NPC entity.`

* `zone` (`table`): `Zone the NPC spawned in.`

* `group` (`string`): `Identifier for the spawn group.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnNPCSpawned", "TrackNPC", function(npc, zone, group)
    print("NPC spawned:", npc)
end)
```

---

### `PostNPCSpawn`

**Purpose**

`Fires after all spawn logic for an individual NPC is complete.`

**Parameters**

* `npc` (`Entity`): `The spawned NPC entity.`

* `zone` (`table`): `Zone the NPC spawned in.`

* `group` (`string`): `Identifier for the spawn group.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PostNPCSpawn", "SetupNPC", function(npc, zone, group)
    npc:SetHealth(200)
end)
```

---

### `PreProcessNPCZone`

**Purpose**

`Called before a spawn zone begins spawning NPCs.`

**Parameters**

* `zone` (`table`): `Zone data being processed.`

* `group` (`string`): `Identifier for the spawn group.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PreProcessNPCZone", "LogZoneStart", function(zone, group)
    print("Processing zone", group)
end)
```

---

### `OnNPCGroupSpawned`

**Purpose**

`Runs when one or more NPCs have been spawned for a zone.`

**Parameters**

* `zone` (`table`): `Zone that spawned NPCs.`

* `group` (`string`): `Identifier for the spawn group.`

* `count` (`number`): `Number of NPCs spawned this cycle.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnNPCGroupSpawned", "NotifyGroupSpawn", function(zone, group, count)
    print(count .. " NPCs spawned in " .. group)
end)
```

---

### `PostProcessNPCZone`

**Purpose**

`Called after a spawn zone has finished spawning NPCs.`

**Parameters**

* `zone` (`table`): `Zone that was processed.`

* `group` (`string`): `Identifier for the spawn group.`

* `count` (`number`): `Number of NPCs spawned during processing.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PostProcessNPCZone", "ZoneFinished", function(zone, group, count)
    print("Zone complete", count)
end)
```

---

### `PreNPCSpawnCycle`

**Purpose**

`Fires at the start of an automatic spawn cycle.`

**Parameters**

* `zones` (`table`): `Table of all zones for the current map.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PreNPCSpawnCycle", "CycleBegin", function(zones)
    print("Starting spawn cycle")
end)
```

---

### `PostNPCSpawnCycle`

**Purpose**

`Runs once all zones have been processed in the spawn cycle.`

**Parameters**

* `zones` (`table`): `Table of all zones for the current map.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("PostNPCSpawnCycle", "CycleEnd", function(zones)
    print("Spawn cycle finished")
end)
```

---

### `OnNPCForceSpawn`

**Purpose**

`Triggered when an administrator manually forces a spawn.`

**Parameters**

* `client` (`Player`): `Player that used the command.`

* `spawnerName` (`string`): `Name of the spawner that was triggered.`

**Realm**

`Server`

**Returns**

`nil` — `No return value.`

**Example**

```lua
hook.Add("OnNPCForceSpawn", "LogForce", function(client, spawnerName)
    print(client:Name(), "forced spawn", spawnerName)
end)
```

---

