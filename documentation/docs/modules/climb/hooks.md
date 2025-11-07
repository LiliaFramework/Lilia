# Hooks

Hooks provided by the Climb module for player climbing mechanics.

---

Overview

The Climbing module enables players to scale ledges and obstacles using standard movement keys with custom climbing animations. It provides realistic climbing mechanics with configurable reach distances, smooth animation transitions, and comprehensive hook integration for customizing climb behavior, validation, and success/failure conditions.

---

### PlayerBeginClimb

#### 📋 Purpose
Called when a player successfully begins climbing an obstacle.

#### ⏰ When Called
After the climb attempt is validated and before the velocity is applied.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who is climbing |
| `distance` | **number** | The vertical distance to climb in units |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PlayerClimbAttempt

#### 📋 Purpose
Called when a player attempts to climb by pressing the jump key while looking at a climbable surface.

#### ⏰ When Called
When the jump key is pressed and the module checks for climbable surfaces.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player attempting to climb |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PlayerClimbed

#### 📋 Purpose
Called when a player successfully completes a climb.

#### ⏰ When Called
After the climb velocity has been applied.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player who climbed |
| `distance` | **number** | The vertical distance climbed in units |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### PlayerFailedClimb

#### 📋 Purpose
Called when a player's climb attempt fails.

#### ⏰ When Called
When the climb validation fails (no valid surface or already on a surface).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player whose climb attempt failed |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

