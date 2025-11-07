# Hooks

Hooks provided by the Realistic View module for managing realistic first-person view.

---

Overview

The Realistic View module adds a first-person view that shows the full body, immersive camera transitions, compatibility with animations, smooth leaning animations, and optional third-person override.. It provides comprehensive hook integration for customizing managing realistic first-person view and extending functionality.

---

### RealisticViewCalcView

#### 📋 Purpose
Called during realistic view calculation, allowing modification of the view.

#### ⏰ When Called
After view calculations are complete, before returning the view.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `view` | **table** | The view table with origin, angles, fov, drawviewer |

#### ↩️ Returns
*table* or nil - Return modified view table or nil to use default

#### 🌐 Realm
Client

---

Overview

The Realistic View module adds a first-person view that shows the full body, immersive camera transitions, compatibility with animations, smooth leaning animations, and optional third-person override.. It provides comprehensive hook integration for customizing managing realistic first-person view and extending functionality.

---

### RealisticViewUpdated

#### 📋 Purpose
Called when realistic view is updated.

#### ⏰ When Called
After view calculations are complete but before CalcView hook.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `view` | **table** | The calculated view table |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Realistic View module adds a first-person view that shows the full body, immersive camera transitions, compatibility with animations, smooth leaning animations, and optional third-person override.. It provides comprehensive hook integration for customizing managing realistic first-person view and extending functionality.

---

### ShouldUseRealisticView

#### 📋 Purpose
Called to determine if realistic view should be used.

#### ⏰ When Called
During CalcView when realistic view is enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |

#### ↩️ Returns
*boolean* - Return false to disable realistic view

#### 🌐 Realm
Client


