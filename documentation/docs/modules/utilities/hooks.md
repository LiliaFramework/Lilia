# Hooks

Hooks provided by the Utilities module for managing utility functions and entity spawning.

---

Overview

The Utilities module adds extra helper functions in lia.util, simplified utilities for common scripting tasks, a central library used by other modules, utilities for networking data, and shared constants for modules.. It provides comprehensive hook integration for customizing managing utility functions and entity spawning and extending functionality.

---

### CodeUtilsLoaded

#### 📋 Purpose
Called when utility code utilities are loaded.

#### ⏰ When Called
When the utilities module initializes.

#### ⚙️ Parameters
None

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Utilities module adds extra helper functions in lia.util, simplified utilities for common scripting tasks, a central library used by other modules, utilities for networking data, and shared constants for modules.. It provides comprehensive hook integration for customizing managing utility functions and entity spawning and extending functionality.

---

### UtilityEntitySpawned

#### 📋 Purpose
Called when a utility entity is spawned.

#### ⏰ When Called
After an entity is created and spawned via lia.utilities.spawnEntities.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The entity that was spawned |
| `class` | **string** | The entity class name |
| `pos` | **Vector** | The spawn position |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Utilities module adds extra helper functions in lia.util, simplified utilities for common scripting tasks, a central library used by other modules, utilities for networking data, and shared constants for modules.. It provides comprehensive hook integration for customizing managing utility functions and entity spawning and extending functionality.

---

### UtilityPropSpawned

#### 📋 Purpose
Called when a utility prop is spawned.

#### ⏰ When Called
After a prop is created and spawned via lia.utilities.spawnProp.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `entity` | **Entity** | The prop entity that was spawned |
| `model` | **string** | The model path |
| `pos` | **Vector** | The spawn position |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


