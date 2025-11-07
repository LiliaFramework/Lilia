# Hooks

Hooks provided by the Enhanced Death module for managing hospital respawns and death penalties.

---

Overview

The Enhanced Death module adds respawning of players at hospitals, a medical recovery system, support for multiple hospital spawns, configurable respawn delays, and integration with death logs.. It provides comprehensive hook integration for customizing managing hospital respawns and death penalties and extending functionality.

---

### HospitalDeathFlagged

#### 📋 Purpose
Called when a player's death is flagged for hospital respawn.

#### ⏰ When Called
When a player dies and hospitals are enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who died |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Enhanced Death module adds respawning of players at hospitals, a medical recovery system, support for multiple hospital spawns, configurable respawn delays, and integration with death logs.. It provides comprehensive hook integration for customizing managing hospital respawns and death penalties and extending functionality.

---

### HospitalMoneyLost

#### 📋 Purpose
Called when a player loses money upon hospital respawn.

#### ⏰ When Called
After money is deducted from the character during respawn.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who lost money |
| `moneyLoss` | **number** | The amount of money lost |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Enhanced Death module adds respawning of players at hospitals, a medical recovery system, support for multiple hospital spawns, configurable respawn delays, and integration with death logs.. It provides comprehensive hook integration for customizing managing hospital respawns and death penalties and extending functionality.

---

### HospitalRespawned

#### 📋 Purpose
Called when a player respawns at a hospital location.

#### ⏰ When Called
After the player is teleported to the hospital respawn location.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who respawned |
| `respawnLocation` | **Vector** | The hospital location where the player respawned |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


