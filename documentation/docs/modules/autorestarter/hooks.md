# Hooks

Hooks provided by the Auto Restarter module for managing automatic server restarts.

---

Overview

The Auto Restarter module provides automated server restart functionality with scheduled maintenance cycles and player notification systems. It displays countdown timers to give players advance warning of impending restarts, allowing them to save progress and prepare for the map change. The module includes configurable restart intervals, emergency restart capabilities, and comprehensive hook support for integrating with other systems that need to respond to server restart events.

---

### AutoRestart

#### 📋 Purpose
Called when the server is about to restart automatically.

#### ⏰ When Called
Immediately before the server executes the restart command.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `timestamp` | **number** | The current Unix timestamp when restart is triggered |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### AutoRestartCountdown

#### 📋 Purpose
Called during the countdown period before an automatic restart (within 25% of the restart interval).

#### ⏰ When Called
Every second when the remaining time is within 25% of the restart interval.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `remaining` | **number** | The remaining seconds until restart |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### AutoRestartScheduled

#### 📋 Purpose
Called when a new automatic restart is scheduled.

#### ⏰ When Called
When the restart timer is initialized or when a new restart time is calculated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `nextRestart` | **number** | Unix timestamp of the next scheduled restart |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### AutoRestartStarted

#### 📋 Purpose
Called when the automatic restart process has begun.

#### ⏰ When Called
After AutoRestart is called, just before the map change command is executed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mapName` | **string** | The name of the map that will be loaded |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

