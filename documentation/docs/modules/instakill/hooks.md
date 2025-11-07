# Hooks

Hooks provided by the Instakill module for managing instant kill mechanics on headshots.

---

Overview

The Instakill module adds instant kill on headshots, lethality configurable per weapon, extra tension to combat, and integration with damage numbers.. It provides comprehensive hook integration for customizing managing instant kill mechanics on headshots and extending functionality.

---

### PlayerInstantKilled

#### 📋 Purpose
Called when a player is instant killed by a headshot.

#### ⏰ When Called
After the damage is set to instant kill level.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who was instant killed |
| `dmgInfo` | **CTakeDamageInfo** | The damage information |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Instakill module adds instant kill on headshots, lethality configurable per weapon, extra tension to combat, and integration with damage numbers.. It provides comprehensive hook integration for customizing managing instant kill mechanics on headshots and extending functionality.

---

### PlayerPreInstantKill

#### 📋 Purpose
Called before a player is instant killed by a headshot.

#### ⏰ When Called
After ShouldInstantKill check passes, before damage is modified.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player about to be instant killed |
| `dmgInfo` | **CTakeDamageInfo** | The damage information |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Instakill module adds instant kill on headshots, lethality configurable per weapon, extra tension to combat, and integration with damage numbers.. It provides comprehensive hook integration for customizing managing instant kill mechanics on headshots and extending functionality.

---

### ShouldInstantKill

#### 📋 Purpose
Called to determine if a headshot should instant kill.

#### ⏰ When Called
When a headshot is detected and instakilling is enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player being hit |
| `dmgInfo` | **CTakeDamageInfo** | The damage information |

#### ↩️ Returns
*boolean* - Return false to prevent instant kill

#### 🌐 Realm
Server


