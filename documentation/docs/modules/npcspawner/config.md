# Configuration

Configuration options for the NPC Spawner module.

---

Overview

The NPC Spawner module provides configurable spawn positions and settings for NPCs across different maps, including spawn locations, radii, maximum NPC counts, and spawn cooldowns.

---

### SpawnPositions

#### 📋 Description
Defines spawn positions for NPCs organized by map name and location name. Each location specifies position, radius, maximum NPCs, and limits per NPC type.

#### ⚙️ Type
Table

#### 💾 Default Value
A table containing example spawn positions for maps like "rp_nycity_day" with locations such as "City Center" and "Burgers".

#### 📊 Structure
A nested table structure:
- Map name (key) → Location table
  - Location name (key) → Location config:
    - `pos` (Vector) - Spawn position
    - `radius` (number) - Spawn radius
    - `maxNPCs` (number) - Maximum total NPCs at this location
    - `maxPerType` (table) - Maximum NPCs per NPC class name

#### 🌐 Realm
Server

---

### SpawnCooldown

#### 📋 Description
Sets the cooldown time in seconds between NPC spawn cycles.

#### ⚙️ Type
Int

#### 💾 Default Value
240

#### 📊 Range
Minimum: 1
Maximum: 3600

#### 🌐 Realm
Server

