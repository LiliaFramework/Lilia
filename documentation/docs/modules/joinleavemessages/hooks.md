# Hooks

Hooks provided by the Join Leave Messages module for managing player join/leave notifications.

---

Overview

The Join Leave Messages module adds announcements when players join, notifications on disconnect, improved community awareness, relay of messages to discord, and per-player toggle to hide messages.. It provides comprehensive hook integration for customizing managing player join/leave notifications and extending functionality.

---

### JoinLeaveMessageSent

#### 📋 Purpose
Called when a join or leave message is sent to players.

#### ⏰ When Called
After the message is displayed to all players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who joined or left |
| `isLeaving` | **boolean** | True if leaving, false if joining |
| `message` | **string** | The message that was sent |

#### ↩️ Returns
nil

#### 🌐 Realm
Server

---

Overview

The Join Leave Messages module adds announcements when players join, notifications on disconnect, improved community awareness, relay of messages to discord, and per-player toggle to hide messages.. It provides comprehensive hook integration for customizing managing player join/leave notifications and extending functionality.

---

### PreJoinLeaveMessageSent

#### 📋 Purpose
Called before a join or leave message is sent.

#### ⏰ When Called
Before the message is displayed to players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who joined or left |
| `isLeaving` | **boolean** | True if leaving, false if joining |
| `message` | **string** | The message that will be sent |

#### ↩️ Returns
nil

#### 🌐 Realm
Server


