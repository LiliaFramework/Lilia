# Hooks

Hooks provided by the Broadcasts module for managing class and faction broadcast messages.

---

Overview

The Broadcasts module allows staff to broadcast messages to chosen factions or classes. Every broadcast is logged and controlled through CAMI privileges. It provides comprehensive hook integration for customizing broadcast behavior, logging, and extending faction/class communication systems.

---

### ClassBroadcastLogged

#### 📋 Purpose
Called after a class broadcast has been logged.

#### ⏰ When Called
After the broadcast is sent and logged in the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the broadcast |
| `message` | **string** | The broadcast message |
| `classes` | **table** | Array of class names that received the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### ClassBroadcastMenuClosed

#### 📋 Purpose
Called when the class selection menu for broadcasts is closed.

#### ⏰ When Called
After the player selects classes and the menu closes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who closed the menu |
| `selectedOptions` | **table** | Array of selected class options |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### ClassBroadcastMenuOpened

#### 📋 Purpose
Called when the class selection menu for broadcasts is opened.

#### ⏰ When Called
When the class broadcast command is executed and the selection menu is shown.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who opened the menu |
| `options` | **table** | Array of available class options |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### ClassBroadcastSent

#### 📋 Purpose
Called when a class broadcast has been sent to all eligible players.

#### ⏰ When Called
After the broadcast messages are sent to players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the broadcast |
| `message` | **string** | The broadcast message |
| `classes` | **table** | Array of class names that received the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### FactionBroadcastLogged

#### 📋 Purpose
Called after a faction broadcast has been logged.

#### ⏰ When Called
After the broadcast is sent and logged in the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the broadcast |
| `message` | **string** | The broadcast message |
| `factions` | **table** | Array of faction names that received the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### FactionBroadcastMenuClosed

#### 📋 Purpose
Called when the faction selection menu for broadcasts is closed.

#### ⏰ When Called
After the player selects factions and the menu closes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who closed the menu |
| `selectedOptions` | **table** | Array of selected faction options |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### FactionBroadcastMenuOpened

#### 📋 Purpose
Called when the faction selection menu for broadcasts is opened.

#### ⏰ When Called
When the faction broadcast command is executed and the selection menu is shown.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who opened the menu |
| `options` | **table** | Array of available faction options |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### FactionBroadcastSent

#### 📋 Purpose
Called when a faction broadcast has been sent to all eligible players.

#### ⏰ When Called
After the broadcast messages are sent to players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who sent the broadcast |
| `message` | **string** | The broadcast message |
| `factions` | **table** | Array of faction names that received the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreClassBroadcastSend

#### 📋 Purpose
Called before a class broadcast is sent to players.

#### ⏰ When Called
After class selection but before messages are sent.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player sending the broadcast |
| `message` | **string** | The broadcast message |
| `classes` | **table** | Array of class names that will receive the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

### PreFactionBroadcastSend

#### 📋 Purpose
Called before a faction broadcast is sent to players.

#### ⏰ When Called
After faction selection but before messages are sent.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player sending the broadcast |
| `message` | **string** | The broadcast message |
| `factions` | **table** | Array of faction names that will receive the broadcast |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

