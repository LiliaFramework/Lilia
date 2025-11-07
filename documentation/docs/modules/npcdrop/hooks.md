# Hooks

Hooks provided by the NPC Drop module for managing item drops from NPCs.

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDropCheck

#### 📋 Purpose
Called when an NPC is killed and drop checking begins.

#### ⏰ When Called
When an NPC dies, before checking for drop tables.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity that was killed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDropFailed

#### 📋 Purpose
Called when an NPC drop attempt fails.

#### ⏰ When Called
When the drop roll completes but no item is selected.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity that was killed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDropNoItems

#### 📋 Purpose
Called when an NPC has a drop table but no valid items.

#### ⏰ When Called
When the drop table exists but total weight is 0 or less.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity that was killed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDropNoTable

#### 📋 Purpose
Called when an NPC has no drop table configured.

#### ⏰ When Called
When the NPC's class is not found in the drop table.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity that was killed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDroppedItem

#### 📋 Purpose
Called when an item is successfully dropped from an NPC.

#### ⏰ When Called
After an item is spawned from the NPC.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity that dropped the item |
| `itemName` | **string** | The unique ID of the item that was dropped |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The NPC Drop module adds npcs that drop items on death, droptable to define probabilities, encouragement for looting, editable drop tables per npc type, and weighted chances for rare items.. It provides comprehensive hook integration for customizing managing item drops from npcs and extending functionality.

---

### NPCDropRoll

#### 📋 Purpose
Called when the drop roll is performed.

#### ⏰ When Called
After the random roll is generated but before item selection.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **NPC** | The NPC entity |
| `choice` | **number** | The random roll value |
| `totalWeight` | **number** | The total weight of all items |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


