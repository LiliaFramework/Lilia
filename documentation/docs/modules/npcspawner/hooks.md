# Hooks

Hooks provided by the NPC Spawner module for managing NPC spawning and zones.

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### CanNPCSpawn

#### 📋 Purpose
Called to determine if an NPC can spawn.

#### ⏰ When Called
Before spawning an NPC in a zone.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zone` | **table** | The spawn zone data |
| `npcType` | **string** | The NPC class to spawn |
| `group` | **string** | The spawn group identifier |

#### ↩️ Returns
*boolean* - Return false to prevent spawn

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### OnNPCForceSpawn

#### 📋 Purpose
Called when an admin forces an NPC to spawn.

#### ⏰ When Called
When the force spawn command is executed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who forced the spawn |
| `selectedSpawner` | **string** | The spawner/group identifier |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### OnNPCGroupSpawned

#### 📋 Purpose
Called when a group of NPCs has been spawned in a zone.

#### ⏰ When Called
After all NPCs for a group have been spawned.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zone` | **table** | The spawn zone data |
| `group` | **string** | The spawn group identifier |
| `spawned` | **number** | The number of NPCs spawned |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### OnNPCSpawned

#### 📋 Purpose
Called when a single NPC has been spawned.

#### ⏰ When Called
After an NPC is created and spawned.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **NPC** | The NPC entity that was spawned |
| `zone` | **table** | The spawn zone data |
| `group` | **string** | The spawn group identifier |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PostNPCSpawn

#### 📋 Purpose
Called after an NPC spawn is complete.

#### ⏰ When Called
After the NPC is spawned and added to the zone.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **NPC** | The NPC entity that was spawned |
| `zone` | **table** | The spawn zone data |
| `group` | **string** | The spawn group identifier |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PostNPCSpawnCycle

#### 📋 Purpose
Called after a complete NPC spawn cycle has finished.

#### ⏰ When Called
After all zones have been processed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zones` | **table** | All spawn zones for the current map |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PostProcessNPCZone

#### 📋 Purpose
Called after a zone has been processed for spawning.

#### ⏰ When Called
After all NPCs for a zone have been spawned (or skipped).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zone` | **table** | The spawn zone data |
| `group` | **string** | The spawn group identifier |
| `spawned` | **number** | The number of NPCs spawned in this zone |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PreNPCSpawn

#### 📋 Purpose
Called before an NPC is spawned.

#### ⏰ When Called
Before creating and spawning the NPC entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zone` | **table** | The spawn zone data |
| `npcType` | **string** | The NPC class to spawn |
| `group` | **string** | The spawn group identifier |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PreNPCSpawnCycle

#### 📋 Purpose
Called before a complete NPC spawn cycle begins.

#### ⏰ When Called
At the start of the spawn timer cycle.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zones` | **table** | All spawn zones for the current map |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Spawner module adds automatic npc spawns at points, the ability for admins to force spawns, logging of spawn actions, and configuration for spawn intervals.. It provides comprehensive hook integration for customizing managing npc spawning and zones and extending functionality.

---

### PreProcessNPCZone

#### 📋 Purpose
Called before a zone is processed for spawning.

#### ⏰ When Called
Before checking and spawning NPCs in a zone.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `zone` | **table** | The spawn zone data |
| `group` | **string** | The spawn group identifier |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


