# Hooks

Hooks provided by the Door Kick module for managing door kicking mechanics.

---

Overview

The Door Kick module adds the ability to kick doors open with an animation, logging of door kick events, and a fun breach mechanic with physics force to fling doors open.. It provides comprehensive hook integration for customizing managing door kicking mechanics and extending functionality.

---

### DoorKickedOpen

#### 📋 Purpose
Called when a player successfully kicks open a door.

#### ⏰ When Called
After the door is unlocked and opened following a successful kick.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who kicked the door |
| `ent` | **Entity** | The door entity that was kicked open |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Door Kick module adds the ability to kick doors open with an animation, logging of door kick events, and a fun breach mechanic with physics force to fling doors open.. It provides comprehensive hook integration for customizing managing door kicking mechanics and extending functionality.

---

### DoorKickFailed

#### 📋 Purpose
Called when a door kick attempt fails.

#### ⏰ When Called
When a door kick fails for various reasons (disabled, too close, too far, invalid, etc.).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose kick attempt failed |
| `ent` | **Entity** | The door entity (may be invalid) |
| `reason` | **string** | The reason for failure: "disabled", "weak", "cannotKick", "tooClose", "tooFar", or "invalid" |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Door Kick module adds the ability to kick doors open with an animation, logging of door kick events, and a fun breach mechanic with physics force to fling doors open.. It provides comprehensive hook integration for customizing managing door kicking mechanics and extending functionality.

---

### DoorKickStarted

#### 📋 Purpose
Called when a player begins the door kick animation.

#### ⏰ When Called
When the kick sequence starts and the player is frozen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player starting the kick |
| `ent` | **Entity** | The door entity being kicked |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


