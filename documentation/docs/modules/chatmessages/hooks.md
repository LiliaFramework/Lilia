# Hooks

Hooks provided by the Chat Messages module for automated chat message display.

---

Overview

The Chat Messages module provides an automated messaging system that periodically displays rotating informational messages in the chat. It keeps players informed with tips, announcements, and server information even when staff are offline. The system includes configurable message rotation timers and comprehensive hook integration for customizing message content, timing, and delivery mechanisms.

---

### ChatMessageSent

#### 📋 Purpose
Called when an automated chat message is sent to players.

#### ⏰ When Called
After a chat message is displayed in the chat.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `messageIndex` | **number** | The index of the message that was sent |
| `text` | **string** | The message text that was displayed |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

---

### ChatMessagesTimerStarted

#### 📋 Purpose
Called when the chat messages timer is initialized.

#### ⏰ When Called
When the module initializes and sets up the repeating timer for chat messages.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `interval` | **number** | The interval in seconds between messages |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client

