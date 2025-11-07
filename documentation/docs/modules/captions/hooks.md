# Hooks

Hooks provided by the Captions module for managing on-screen caption displays.

---

Overview

The Captions module provides a comprehensive API for displaying timed on-screen text overlays suitable for tutorials, story events, and narrative sequences. It supports both server and client-triggered captions with customizable duration, positioning, and styling. The module includes built-in commands for caption management and extensive hook integration for synchronizing caption events across players and customizing caption behavior.

---

### BroadcastCaptionCommand

#### 📋 Purpose
Called when an admin uses the broadcast caption command to send a caption to all players.

#### ⏰ When Called
After the command is validated but before captions are sent to players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who executed the command |
| `text` | **string** | The caption text to broadcast |
| `duration` | **number** | The duration in seconds for the caption display |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

---

### CaptionFinished

#### 📋 Purpose
Called when a caption display has finished on the client.

#### ⏰ When Called
After the caption has been removed from the screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | The player whose caption finished (server-side only) |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client (no parameters) or Server (with client parameter)

---

### CaptionStarted

#### 📋 Purpose
Called when a caption display has started on the client.

#### ⏰ When Called
After the caption has been displayed on screen.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | The player whose caption started (server-side only) |
| `text` | **string** | The caption text being displayed |
| `duration` | **number** | The duration in seconds for the caption display |

#### ↩️ Returns
nil 

#### 🌐 Realm
Client (text, duration) or Server (client, text, duration)

---

### SendCaptionCommand

#### 📋 Purpose
Called when an admin uses the send caption command to send a caption to a specific player.

#### ⏰ When Called
After the command is validated but before the caption is sent to the target player.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The admin who executed the command |
| `target` | **Player** | The target player who will receive the caption |
| `text` | **string** | The caption text to send |
| `duration` | **number** | The duration in seconds for the caption display |

#### ↩️ Returns
nil 

#### 🌐 Realm
Server

