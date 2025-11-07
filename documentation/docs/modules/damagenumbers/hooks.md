# Hooks

Hooks provided by the Damage Numbers module for managing floating damage number displays.

---

Overview

The Damage Numbers module displays floating combat text that shows damage dealt and received during combat encounters. It features color-coded damage types, scaling text based on damage amounts, and client-side toggle options. The module provides real-time visual feedback for combat actions with comprehensive hook integration for customizing damage display behavior and extending combat feedback systems.

---

### DamageNumberAdded

#### 📋 Purpose
Called when a new damage number is added to the display queue.

#### ⏰ When Called
After a damage number is received and added to the damage numbers table.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | The entity that took damage |
| `dmg` | **number** | The amount of damage dealt |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### DamageNumberExpired

#### 📋 Purpose
Called when a damage number has expired and is being removed from display.

#### ⏰ When Called
When a damage number's display duration has elapsed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ent` | **Entity** | The entity that took the damage |
| `dmg` | **number** | The amount of damage that was displayed |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

### DamageNumbersSent

#### 📋 Purpose
Called when damage numbers are sent to clients after an entity takes damage.

#### ⏰ When Called
After the network message is sent to the attacker and victim.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `attacker` | **Player** | The player who dealt the damage |
| `victim` | **Player** | The player who took the damage |
| `dmg` | **number** | The amount of damage dealt |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

