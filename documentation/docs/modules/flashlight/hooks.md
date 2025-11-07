# Hooks

Hooks provided by the Flashlight module for managing flashlight functionality.

---

Overview

The Flashlight module adds a serious flashlight with dynamic light, darkening of surroundings when turned off, adjustable brightness, and keybind toggle support.. It provides comprehensive hook integration for customizing managing flashlight functionality and extending functionality.

---

### CanPlayerToggleFlashlight

#### 📋 Purpose
Called to determine if a player can toggle their flashlight.

#### ⏰ When Called
Before the flashlight toggle is processed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to toggle |
| `isEnabled` | **boolean** | Whether the flashlight is being turned on (true) or off (false) |

#### ↩️ Returns
*boolean* - Return false to prevent toggle

#### 🌐 Realm
Server

---

Overview

The Flashlight module adds a serious flashlight with dynamic light, darkening of surroundings when turned off, adjustable brightness, and keybind toggle support.. It provides comprehensive hook integration for customizing managing flashlight functionality and extending functionality.

---

### PlayerToggleFlashlight

#### 📋 Purpose
Called when a player successfully toggles their flashlight.

#### ⏰ When Called
After the flashlight state is changed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who toggled the flashlight |
| `isEnabled` | **boolean** | Whether the flashlight is now on (true) or off (false) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Flashlight module adds a serious flashlight with dynamic light, darkening of surroundings when turned off, adjustable brightness, and keybind toggle support.. It provides comprehensive hook integration for customizing managing flashlight functionality and extending functionality.

---

### PrePlayerToggleFlashlight

#### 📋 Purpose
Called before a player's flashlight toggle is processed.

#### ⏰ When Called
Before any validation or checks are performed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to toggle |
| `isEnabled` | **boolean** | Whether the flashlight is being turned on (true) or off (false) |

#### ↩️ Returns
*boolean* - Return false to prevent toggle

#### 🌐 Realm
Server


