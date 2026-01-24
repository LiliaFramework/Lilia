# Hooks

Hooks provided by the Perma Remove module for managing permanent entity removal.

---

Overview

The Perma Remove module adds ability to permanently delete map entities, logging for each removed entity, an admin-only command, confirmation prompts before removal, and restore list to undo mistakes.. It provides comprehensive hook integration for customizing managing permanent entity removal and extending functionality.

---

### CanPermaRemoveEntity

#### 📋 Purpose
Called to determine if an entity can be permanently removed.

#### ⏰ When Called
When the permaremove command is executed, before removal.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin attempting to remove the entity |
| `entity` | **Entity** | The entity to be removed |

#### ↩️ Returns
*boolean* - Return false to prevent removal

#### 🌐 Realm
Server

---

Overview

The Perma Remove module adds ability to permanently delete map entities, logging for each removed entity, an admin-only command, confirmation prompts before removal, and restore list to undo mistakes.. It provides comprehensive hook integration for customizing managing permanent entity removal and extending functionality.

---

### OnPermaRemoveEntity

#### 📋 Purpose
Called when an entity is permanently removed.

#### ⏰ When Called
After the entity is removed and saved to the removal list.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who removed the entity |
| `entity` | **Entity** | The entity that was removed (may be invalid) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Perma Remove module adds ability to permanently delete map entities, logging for each removed entity, an admin-only command, confirmation prompts before removal, and restore list to undo mistakes.. It provides comprehensive hook integration for customizing managing permanent entity removal and extending functionality.

---

### OnPermaRemoveLoaded

#### 📋 Purpose
Called when a permanently removed entity is loaded and removed on map start.

#### ⏰ When Called
When the module loads and finds entities that should be removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The entity being removed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


