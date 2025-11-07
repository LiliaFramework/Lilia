# Hooks

Hooks provided by the Raised Weapons module for managing weapon raising and lowering mechanics.

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### OnWeaponLowered

#### 📋 Purpose
Called when a player's weapon is lowered.

#### ⏰ When Called
After the weapon raised state changes to false.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player whose weapon was lowered |
| `weapon` | **Weapon** | The weapon that was lowered |

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### OnWeaponRaised

#### 📋 Purpose
Called when a player's weapon is raised.

#### ⏰ When Called
After the weapon raised state changes to true.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player whose weapon was raised |
| `weapon` | **Weapon** | The weapon that was raised |

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### OverrideWeaponRaiseSpeed

#### 📋 Purpose
Called to override the weapon raise speed.

#### ⏰ When Called
When calculating weapon raise speed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player raising the weapon |
| `raiseSpeed` | **number** | The default raise speed |

#### ↩️ Returns
*number* - Return a number to override the speed, nil for default

#### 🌐 Realm
Server

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### PlayerWeaponRaisedChanged

#### 📋 Purpose
Called when a player's weapon raised state changes.

#### ⏰ When Called
When the raised state transitions between true and false.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player whose state changed |
| `state` | **boolean** | The new raised state |

#### ↩️ Returns
nil

#### 🌐 Realm
Shared

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### ShouldWeaponBeRaised

#### 📋 Purpose
Called to determine if a weapon should be raised.

#### ⏰ When Called
During weapon raise state checking.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The player holding the weapon |
| `weapon` | **Weapon** | The weapon being checked |

#### ↩️ Returns
*boolean* - Return true to force raise, false to prevent, nil for default

#### 🌐 Realm
Shared

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### WeaponHolsterCancelled

#### 📋 Purpose
Called when a weapon holster is cancelled.

#### ⏰ When Called
When a holster is interrupted or cancelled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose holster was cancelled |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### WeaponHolsterScheduled

#### 📋 Purpose
Called when a weapon holster is scheduled.

#### ⏰ When Called
When a holster action is initiated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player holstering the weapon |
| `raiseSpeed` | **number** | The speed of the holster action |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Raised Weapons module adds auto-lowering of weapons when running, a raise delay set by weaponraisespeed, prevention of accidental fire, a toggle to keep weapons lowered, and compatibility with melee weapons.. It provides comprehensive hook integration for customizing managing weapon raising and lowering mechanics and extending functionality.

---

### WeaponRaiseScheduled

#### 📋 Purpose
Called when a weapon raise is scheduled.

#### ⏰ When Called
When a raise action is initiated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player raising the weapon |
| `newWeapon` | **Weapon** | The weapon being raised |
| `raiseSpeed` | **number** | The speed of the raise action |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


