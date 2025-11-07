# Hooks

Hooks provided by the Simple Lockpicking module for managing lockpicking mechanics.

---

Overview

The Simple Lockpicking module adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.. It provides comprehensive hook integration for customizing managing lockpicking mechanics and extending functionality.

---

### CanPlayerLockpick

#### 📋 Purpose
Called to determine if a player can lockpick a target.

#### ⏰ When Called
When a player attempts to use a lockpick item.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player attempting to lockpick |
| `target` | **Entity** | The door or vehicle being lockpicked |

#### ↩️ Returns
*boolean* - Return false to prevent lockpicking

#### 🌐 Realm
Server

---

Overview

The Simple Lockpicking module adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.. It provides comprehensive hook integration for customizing managing lockpicking mechanics and extending functionality.

---

### LockpickFinished

#### 📋 Purpose
Called when a lockpicking attempt finishes (success or failure).

#### ⏰ When Called
After the lockpicking action completes or is interrupted.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who was lockpicking |
| `target` | **Entity** | The target entity |
| `success` | **boolean** | Whether the lockpick succeeded |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Simple Lockpicking module adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.. It provides comprehensive hook integration for customizing managing lockpicking mechanics and extending functionality.

---

### LockpickInterrupted

#### 📋 Purpose
Called when a lockpicking attempt is interrupted.

#### ⏰ When Called
When the lockpicking action is cancelled or interrupted.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose lockpick was interrupted |
| `target` | **Entity** | The target entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Simple Lockpicking module adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.. It provides comprehensive hook integration for customizing managing lockpicking mechanics and extending functionality.

---

### LockpickStart

#### 📋 Purpose
Called when a lockpicking attempt starts.

#### ⏰ When Called
When the lockpicking action begins.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player starting to lockpick |
| `target` | **Entity** | The target entity being lockpicked |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Simple Lockpicking module adds a simple lockpick tool for doors, logging of successful picks, brute-force style gameplay, configurable pick time, and chance for tools to break.. It provides comprehensive hook integration for customizing managing lockpicking mechanics and extending functionality.

---

### LockpickSuccess

#### 📋 Purpose
Called when a lockpicking attempt succeeds.

#### ⏰ When Called
After the lock is successfully picked and the door/vehicle is unlocked.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who succeeded |
| `target` | **Entity** | The target entity that was unlocked |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


