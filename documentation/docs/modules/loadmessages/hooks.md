# Hooks

Hooks provided by the Load Messages module for managing character load messages.

---

Overview

The Load Messages module adds faction-based load messages, execution when players first load a character, customizable message text, color-coded formatting options, and per-faction enable toggles.. It provides comprehensive hook integration for customizing managing character load messages and extending functionality.

---

### LoadMessageMissing

#### 📋 Purpose
Called when a load message configuration is missing.

#### ⏰ When Called
When a player loads but no message data is found for their class.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who loaded without a message |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Load Messages module adds faction-based load messages, execution when players first load a character, customizable message text, color-coded formatting options, and per-faction enable toggles.. It provides comprehensive hook integration for customizing managing character load messages and extending functionality.

---

### LoadMessageSent

#### 📋 Purpose
Called when a load message is sent to a player.

#### ⏰ When Called
After the message is displayed to the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player receiving the message |
| `data` | **table** | The load message data that was sent |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Load Messages module adds faction-based load messages, execution when players first load a character, customizable message text, color-coded formatting options, and per-faction enable toggles.. It provides comprehensive hook integration for customizing managing character load messages and extending functionality.

---

### PostLoadMessage

#### 📋 Purpose
Called after a load message has been processed.

#### ⏰ When Called
After the message is sent and displayed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who received the message |
| `data` | **table** | The load message data |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Load Messages module adds faction-based load messages, execution when players first load a character, customizable message text, color-coded formatting options, and per-faction enable toggles.. It provides comprehensive hook integration for customizing managing character load messages and extending functionality.

---

### PreLoadMessage

#### 📋 Purpose
Called before a load message is sent.

#### ⏰ When Called
Before the message is displayed to the player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who will receive the message |
| `data` | **table** | The load message data that will be sent |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


