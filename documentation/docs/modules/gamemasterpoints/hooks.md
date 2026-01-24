# Hooks

Hooks provided by the Gamemaster Points module for managing teleport points.

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterAddPoint

#### 📋 Purpose
Called when a gamemaster point is successfully added.

#### ⏰ When Called
After a point is added to the system and saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who added the point |
| `name` | **string** | The name of the point |
| `pos` | **Vector** | The position of the point |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterMoveToPoint

#### 📋 Purpose
Called when a player teleports to a gamemaster point.

#### ⏰ When Called
After the player is teleported to the point location.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who teleported |
| `name` | **string** | The name of the point |
| `pos` | **Vector** | The position the player teleported to |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreAddPoint

#### 📋 Purpose
Called before a gamemaster point is added.

#### ⏰ When Called
Before validation and adding the point to the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin attempting to add the point |
| `name` | **string** | The name of the point to be added |
| `pos` | **Vector** | The position of the point to be added |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreMoveToPoint

#### 📋 Purpose
Called before a player teleports to a gamemaster point.

#### ⏰ When Called
Before the teleport is executed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to teleport |
| `name` | **string** | The name of the point to teleport to |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreRemovePoint

#### 📋 Purpose
Called before a gamemaster point is removed.

#### ⏰ When Called
Before the point is removed from the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin attempting to remove the point |
| `name` | **string** | The name of the point to be removed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreRenamePoint

#### 📋 Purpose
Called before a gamemaster point is renamed.

#### ⏰ When Called
Before the point name is changed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin attempting to rename the point |
| `name` | **string** | The current name of the point |
| `newName` | **string** | The new name for the point |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreUpdateEffect

#### 📋 Purpose
Called before a gamemaster point's effect is updated.

#### ⏰ When Called
Before the effect is saved to the point.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin updating the effect |
| `name` | **string** | The name of the point |
| `newEffect` | **string** | The new effect path |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterPreUpdateSound

#### 📋 Purpose
Called before a gamemaster point's sound is updated.

#### ⏰ When Called
Before the sound is saved to the point.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin updating the sound |
| `name` | **string** | The name of the point |
| `newSound` | **string** | The new sound path |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterRemovePoint

#### 📋 Purpose
Called when a gamemaster point is successfully removed.

#### ⏰ When Called
After the point is removed from the system and saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who removed the point |
| `name` | **string** | The name of the point that was removed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterRenamePoint

#### 📋 Purpose
Called when a gamemaster point is successfully renamed.

#### ⏰ When Called
After the point name is changed and saved.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who renamed the point |
| `oldName` | **string** | The previous name of the point |
| `newName` | **string** | The new name of the point |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterUpdateEffect

#### 📋 Purpose
Called when a gamemaster point's effect is successfully updated.

#### ⏰ When Called
After the effect is saved to the point.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who updated the effect |
| `name` | **string** | The name of the point |
| `newEffect` | **string** | The effect path that was set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Gamemaster Points module adds teleport points for game masters, quick navigation across large maps, saving of locations for reuse, a command to list saved points, and sharing of points with other staff.. It provides comprehensive hook integration for customizing managing teleport points and extending functionality.

---

### GamemasterUpdateSound

#### 📋 Purpose
Called when a gamemaster point's sound is successfully updated.

#### ⏰ When Called
After the sound is saved to the point.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who updated the sound |
| `name` | **string** | The name of the point |
| `newSound` | **string** | The sound path that was set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


