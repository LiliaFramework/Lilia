# Hooks

Hooks provided by the Freelook module for managing free camera movement.

---

Overview

The Freelook module adds the ability to look around without turning the body, a toggle key similar to eft, movement direction preservation, and adjustable sensitivity while freelooking.. It provides comprehensive hook integration for customizing managing free camera movement and extending functionality.

---

### FreelookToggled

#### 📋 Purpose
Called when freelook is toggled on or off.

#### ⏰ When Called
After the freelook state changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | **boolean** | Whether freelook is now enabled (true) or disabled (false) |

#### ↩️ Returns
nil

#### 🌐 Realm
Client

---

Overview

The Freelook module adds the ability to look around without turning the body, a toggle key similar to eft, movement direction preservation, and adjustable sensitivity while freelooking.. It provides comprehensive hook integration for customizing managing free camera movement and extending functionality.

---

### PreFreelookToggle

#### 📋 Purpose
Called before freelook is toggled.

#### ⏰ When Called
When the freelook command is triggered, before the state changes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `enabled` | **boolean** | Whether freelook will be enabled (true) or disabled (false) |

#### ↩️ Returns
*boolean* - Return false to prevent toggle

#### 🌐 Realm
Client

---

Overview

The Freelook module adds the ability to look around without turning the body, a toggle key similar to eft, movement direction preservation, and adjustable sensitivity while freelooking.. It provides comprehensive hook integration for customizing managing free camera movement and extending functionality.

---

### ShouldUseFreelook

#### 📋 Purpose
Called to determine if freelook should be active.

#### ⏰ When Called
During Think when checking if freelook should be enabled.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `player` | **Player** | The local player |

#### ↩️ Returns
*boolean* - Return false to disable freelook

#### 🌐 Realm
Client


