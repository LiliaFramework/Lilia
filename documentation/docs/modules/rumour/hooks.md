# Hooks

Hooks provided by the Rumour module for managing rumour spreading mechanics.

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### CanSendRumour

#### 📋 Purpose
Called to determine if a player can send a rumour.

#### ⏰ When Called
After validation but before the rumour is sent.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to send the rumour |
| `rumourMessage` | **string** | The rumour message |

#### ↩️ Returns
*boolean* - Return false to prevent sending

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### PreRumourCommand

#### 📋 Purpose
Called before the rumour command is processed.

#### ⏰ When Called
When the rumour command is executed, before any validation.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player using the command |
| `arguments` | **table** | The command arguments |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourAttempt

#### 📋 Purpose
Called when a player attempts to send a rumour.

#### ⏰ When Called
After validation passes, before cooldown check.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting to send |
| `rumourMessage` | **string** | The rumour message |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourFactionDisallowed

#### 📋 Purpose
Called when a player's faction is not allowed to send rumours.

#### ⏰ When Called
When the player's faction is not criminal.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose faction is disallowed |
| `faction` | **table** | The player's faction data (may be nil) |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourNoMessage

#### 📋 Purpose
Called when a rumour command is used without a message.

#### ⏰ When Called
When the message argument is empty.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent empty message |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourRevealed

#### 📋 Purpose
Called when a rumour is revealed to police.

#### ⏰ When Called
When the reveal roll succeeds.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the rumour |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourRevealRoll

#### 📋 Purpose
Called when the reveal roll is performed.

#### ⏰ When Called
After the random reveal chance is calculated.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the rumour |
| `revealChance` | **number** | The reveal chance percentage |
| `revealMath` | **boolean** | Whether the reveal succeeded |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourSent

#### 📋 Purpose
Called when a rumour has been sent to players.

#### ⏰ When Called
After the rumour messages are sent to eligible players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the rumour |
| `rumourMessage` | **string** | The rumour message |
| `revealMath` | **boolean** | Whether the rumour was revealed to police |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Rumour module adds an anonymous rumour chat command, hiding of the sender's identity, encouragement for roleplay intrigue, a cooldown to prevent spam, and admin logging of rumour messages.. It provides comprehensive hook integration for customizing managing rumour spreading mechanics and extending functionality.

---

### RumourValidationFailed

#### 📋 Purpose
Called when rumour validation fails.

#### ⏰ When Called
When CanSendRumour returns false.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose validation failed |
| `rumourMessage` | **string** | The rumour message that failed |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


