# Hooks

Hooks provided by the War Table module for managing strategic war table functionality.

---

Overview

The War Table module provides an interactive 3D strategic planning system that allows players to visualize and coordinate operations on detailed maps. It includes marker placement for tactical positioning, support for multiple map layouts, and comprehensive hook integration for customizing gameplay mechanics. The module enables real-time strategic coordination with visual markers, map management, and event-driven interactions that can be extended through custom hooks for specialized gameplay modes, team coordination, and dynamic mission planning.

---

### PostWarTableClear

#### 📋 Purpose
Called after a war table is cleared.

#### ⏰ When Called
After all markers are removed from the table.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who cleared the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PostWarTableMapChange

#### 📋 Purpose
Called after a war table map image is changed.

#### ⏰ When Called
After the map image is updated and broadcast.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who changed the map |
| `tableEnt` | **Entity** | The war table entity |
| `text` | **string** | The new map image URL |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PostWarTableMarkerPlace

#### 📋 Purpose
Called after a marker is placed on a war table.

#### ⏰ When Called
After the marker entity is created and parented.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who placed the marker |
| `marker` | **Entity** | The marker entity that was created |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PostWarTableMarkerRemove

#### 📋 Purpose
Called after a marker is removed from a war table.

#### ⏰ When Called
After the marker entity is removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who removed the marker |
| `ent` | **Entity** | The marker entity that was removed |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PostWarTableUsed

#### 📋 Purpose
Called after a war table is used.

#### ⏰ When Called
After a war table interaction completes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who used the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreWarTableClear

#### 📋 Purpose
Called before a war table is cleared.

#### ⏰ When Called
Before markers are removed from the table.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player clearing the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreWarTableMapChange

#### 📋 Purpose
Called before a war table map image is changed.

#### ⏰ When Called
Before the map image is updated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player changing the map |
| `tableEnt` | **Entity** | The war table entity |
| `text` | **string** | The new map image URL to be set |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreWarTableMarkerPlace

#### 📋 Purpose
Called before a marker is placed on a war table.

#### ⏰ When Called
Before the marker entity is created.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player placing the marker |
| `pos` | **Vector** | The position where the marker will be placed |
| `bodygroups` | **table** | The bodygroup table for the marker |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreWarTableMarkerRemove

#### 📋 Purpose
Called before a marker is removed from a war table.

#### ⏰ When Called
Before the marker entity is removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player removing the marker |
| `ent` | **Entity** | The marker entity to be removed |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreWarTableUsed

#### 📋 Purpose
Called before a war table is used.

#### ⏰ When Called
When a war table interaction begins.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player using the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### WarTableCleared

#### 📋 Purpose
Called when a war table is cleared.

#### ⏰ When Called
After the clear operation completes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who cleared the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### WarTableMapChanged

#### 📋 Purpose
Called when a war table map image is changed.

#### ⏰ When Called
After the map change is processed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who changed the map |
| `tableEnt` | **Entity** | The war table entity |
| `text` | **string** | The new map image URL |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### WarTableMarkerPlaced

#### 📋 Purpose
Called when a marker is placed on a war table.

#### ⏰ When Called
After the marker is created and positioned.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who placed the marker |
| `marker` | **Entity** | The marker entity that was created |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### WarTableMarkerRemoved

#### 📋 Purpose
Called when a marker is removed from a war table.

#### ⏰ When Called
After the marker is removed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who removed the marker |
| `ent` | **Entity** | The marker entity that was removed |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### WarTableUsed

#### 📋 Purpose
Called when a war table is used.

#### ⏰ When Called
When a war table interaction occurs.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player using the table |
| `tableEnt` | **Entity** | The war table entity |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

