# Hooks

Hooks provided by the Slow Weapons module for managing weapon movement speed reduction.

---

Overview

The Slow Weapons module adds slower movement while holding heavy weapons, speed penalties defined per weapon, encouragement for strategic choices, customizable weapon speed table, and automatic speed restore when switching.. It provides comprehensive hook integration for customizing managing weapon movement speed reduction and extending functionality.

---

### ApplyWeaponSlowdown

#### 📋 Purpose
Called when weapon slowdown is applied to movement.

#### ⏰ When Called
After speed calculation but before setting the movement speed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player being slowed |
| `wep` | **Weapon** | The weapon causing slowdown |
| `moveData` | **CMoveData** | The movement data |
| `speed` | **number** | The calculated speed to apply |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Slow Weapons module adds slower movement while holding heavy weapons, speed penalties defined per weapon, encouragement for strategic choices, customizable weapon speed table, and automatic speed restore when switching.. It provides comprehensive hook integration for customizing managing weapon movement speed reduction and extending functionality.

---

### OverrideSlowWeaponSpeed

#### 📋 Purpose
Called to override the slow weapon speed calculation.

#### ⏰ When Called
During speed calculation, before applying slowdown.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player holding the weapon |
| `wep` | **Weapon** | The weapon being checked |
| `baseSpeed` | **number** | The base speed from config |

#### ↩️ Returns
*number* - Return a number to override, nil for default

#### 🌐 Realm
Server

---

Overview

The Slow Weapons module adds slower movement while holding heavy weapons, speed penalties defined per weapon, encouragement for strategic choices, customizable weapon speed table, and automatic speed restore when switching.. It provides comprehensive hook integration for customizing managing weapon movement speed reduction and extending functionality.

---

### PostApplyWeaponSlowdown

#### 📋 Purpose
Called after weapon slowdown has been applied.

#### ⏰ When Called
After movement speed has been set.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who was slowed |
| `wep` | **Weapon** | The weapon causing slowdown |
| `moveData` | **CMoveData** | The movement data |
| `speed` | **number** | The speed that was applied |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


