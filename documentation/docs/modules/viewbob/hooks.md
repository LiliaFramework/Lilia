# Hooks

Hooks provided by the View Bob module for managing view bobbing effects.

---

Overview

The View Bob module adds camera bobbing while moving, adjustable intensity, hooks to modify view punch, and configuration for bobbing frequency.. It provides comprehensive hook integration for customizing managing view bobbing effects and extending functionality.

---

### PostViewPunch

#### 📋 Purpose
Called after a view punch is applied.

#### ⏰ When Called
After ViewPunch is called on the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `angleX` | **number** | The X angle punch |
| `angleY` | **number** | The Y angle punch |
| `angleZ` | **number** | The Z angle punch |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The View Bob module adds camera bobbing while moving, adjustable intensity, hooks to modify view punch, and configuration for bobbing frequency.. It provides comprehensive hook integration for customizing managing view bobbing effects and extending functionality.

---

### PreViewPunch

#### 📋 Purpose
Called before a view punch is applied.

#### ⏰ When Called
Before ViewPunch is called on the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `angleX` | **number** | The X angle punch to apply |
| `angleY` | **number** | The Y angle punch to apply |
| `angleZ` | **number** | The Z angle punch to apply |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The View Bob module adds camera bobbing while moving, adjustable intensity, hooks to modify view punch, and configuration for bobbing frequency.. It provides comprehensive hook integration for customizing managing view bobbing effects and extending functionality.

---

### ViewBobPunch

#### 📋 Purpose
Called when a view bob punch is triggered.

#### ⏰ When Called
During the punch application, before ViewPunch is called.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `angleX` | **number** | The X angle punch |
| `angleY` | **number** | The Y angle punch |
| `angleZ` | **number** | The Z angle punch |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The View Bob module adds camera bobbing while moving, adjustable intensity, hooks to modify view punch, and configuration for bobbing frequency.. It provides comprehensive hook integration for customizing managing view bobbing effects and extending functionality.

---

### ViewBobStep

#### 📋 Purpose
Called when a view bob step value is calculated.

#### ⏰ When Called
During footstep processing, when step value alternates.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The local player |
| `stepvalue` | **number** | The current step value (1 or -1) |

#### ↩️ Returns
*number* - Return a number to override the step value, nil for default

#### 🌐 Realm
Client


