# Hooks

Hooks provided by the Shoot Lock module for managing lock breaking via shooting.

---

Overview

The Shoot Lock module adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.. It provides comprehensive hook integration for customizing managing lock breaking via shooting and extending functionality.

---

### CanPlayerBustLock

#### 📋 Purpose
Called to determine if a player can bust a lock by shooting.

#### ⏰ When Called
When a door is shot and before lock breaking is attempted.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to bust the lock |
| `entity` | **Entity** | The door entity |

#### ↩️ Returns
*boolean* - Return false to prevent lock busting

#### 🌐 Realm
Server

---

Overview

The Shoot Lock module adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.. It provides comprehensive hook integration for customizing managing lock breaking via shooting and extending functionality.

---

### LockShotAttempt

#### 📋 Purpose
Called when a player attempts to shoot a lock.

#### ⏰ When Called
When a door is shot with a bullet, before validation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to shoot the lock |
| `entity` | **Entity** | The door entity being shot |
| `dmgInfo` | **CTakeDamageInfo** | The damage information |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Shoot Lock module adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.. It provides comprehensive hook integration for customizing managing lock breaking via shooting and extending functionality.

---

### LockShotBreach

#### 📋 Purpose
Called when a lock is successfully breached.

#### ⏰ When Called
After the door is unlocked and opened.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who breached the lock |
| `entity` | **Entity** | The door entity that was breached |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Shoot Lock module adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.. It provides comprehensive hook integration for customizing managing lock breaking via shooting and extending functionality.

---

### LockShotFailed

#### 📋 Purpose
Called when a lock shot attempt fails.

#### ⏰ When Called
When the shot doesn't hit the lock handle or other validation fails.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose attempt failed |
| `entity` | **Entity** | The door entity |
| `dmgInfo` | **CTakeDamageInfo** | The damage information |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Shoot Lock module adds the ability to shoot door locks to open them, a quick breach alternative, a loud action that may alert others, and chance-based lock destruction.. It provides comprehensive hook integration for customizing managing lock breaking via shooting and extending functionality.

---

### LockShotSuccess

#### 📋 Purpose
Called when a lock is successfully shot open.

#### ⏰ When Called
After the door is unlocked and opened.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who succeeded |
| `entity` | **Entity** | The door entity that was opened |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


