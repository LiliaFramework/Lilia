# Hooks

Hooks provided by the First Person Effects module for managing camera view effects.

---

Overview

The First Person Effects module adds head bob and view sway, camera motion synced to actions, a realistic first-person feel, and adjustable intensity via config.. It provides comprehensive hook integration for customizing managing camera view effects and extending functionality.

---

### FirstPersonEffectsUpdated

#### 📋 Purpose
Called when first person effects are updated during view calculation.

#### ⏰ When Called
Every frame during CalcView when effects are active.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The local player |
| `position` | **Vector** | The current calculated position offset |
| `angles` | **Angle** | The current calculated angle offset |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The First Person Effects module adds head bob and view sway, camera motion synced to actions, a realistic first-person feel, and adjustable intensity via config.. It provides comprehensive hook integration for customizing managing camera view effects and extending functionality.

---

### PostFirstPersonEffects

#### 📋 Purpose
Called after first person effects have been calculated.

#### ⏰ When Called
After position and angle calculations are complete, before returning the view.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The local player |
| `position` | **Vector** | The calculated position offset |
| `angles` | **Angle** | The calculated angle offset |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The First Person Effects module adds head bob and view sway, camera motion synced to actions, a realistic first-person feel, and adjustable intensity via config.. It provides comprehensive hook integration for customizing managing camera view effects and extending functionality.

---

### PreFirstPersonEffects

#### 📋 Purpose
Called before first person effects are calculated.

#### ⏰ When Called
At the start of CalcView when effects are enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The local player |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The First Person Effects module adds head bob and view sway, camera motion synced to actions, a realistic first-person feel, and adjustable intensity via config.. It provides comprehensive hook integration for customizing managing camera view effects and extending functionality.

---

### ShouldUseFirstPersonEffects

#### 📋 Purpose
Called to determine if first person effects should be used.

#### ⏰ When Called
During CalcView before effects are processed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The local player |

#### ↩️ Returns
*boolean* - Return false to disable effects

#### 🌐 Realm
Client


