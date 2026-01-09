# Notice Library

Player notification and messaging system for the Lilia framework.

---

Overview

The notice library provides comprehensive functionality for displaying notifications and messages to players in the Lilia framework. It handles both server-side and client-side notification systems, supporting both direct text messages and localized messages with parameter substitution. The library operates across server and client realms, with the server sending notification data to clients via network messages, while the client handles the visual display of notifications using VGUI panels. It includes automatic organization of multiple notifications, sound effects, and console output for debugging purposes. The library also provides compatibility with Garry's Mod's legacy notification system.

---

### lia.notices.receiveNotify

#### 📋 Purpose
Receives notification data from the server via network message and displays it to the client.

#### ⏰ When Called
Automatically called when the client receives a "liaNotificationData" network message from the server.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- This function is called automatically when receiving server notifications
    -- No manual calling needed

```

---

### lia.notices.receiveNotifyL

#### 📋 Purpose
Receives localized notification data from the server and displays the localized message to the client.

#### ⏰ When Called
Automatically called when the client receives a "liaNotifyLocal" network message from the server containing localized notification data.

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- This function is called automatically when receiving localized server notifications
    -- No manual calling needed

```

---

### lia.notices.notifyInfoLocalized

#### 📋 Purpose
Sends an informational notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send an info-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized info notification to a specific player
    lia.notices.notifyInfoLocalized(player, "item.purchased", itemName, price)
    -- Send to all players
    lia.notices.notifyInfoLocalized(nil, "server.restart", "5")

```

---

### lia.notices.notifyWarningLocalized

#### 📋 Purpose
Sends a warning notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send a warning-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized warning notification to a specific player
    lia.notices.notifyWarningLocalized(player, "inventory.full")
    -- Send to all players
    lia.notices.notifyWarningLocalized(nil, "server.maintenance", "30")

```

---

### lia.notices.notifyErrorLocalized

#### 📋 Purpose
Sends an error notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send an error-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized error notification to a specific player
    lia.notices.notifyErrorLocalized(player, "command.noPermission")
    -- Send to all players
    lia.notices.notifyErrorLocalized(nil, "server.error", errorCode)

```

---

### lia.notices.notifySuccessLocalized

#### 📋 Purpose
Sends a success notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send a success-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized success notification to a specific player
    lia.notices.notifySuccessLocalized(player, "quest.completed", questName)
    -- Send to all players
    lia.notices.notifySuccessLocalized(nil, "server.update.complete")

```

---

### lia.notices.notifyMoneyLocalized

#### 📋 Purpose
Sends a money-related notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send a money-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized money notification to a specific player
    lia.notices.notifyMoneyLocalized(player, "money.earned", amount, reason)
    -- Send to all players
    lia.notices.notifyMoneyLocalized(nil, "lottery.winner", winnerName, prize)

```

---

### lia.notices.notifyAdminLocalized

#### 📋 Purpose
Sends an admin-related notification to a client using a localized message key with optional parameters.

#### ⏰ When Called
Called when you want to send an admin-type notification with localized text to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    -- Send localized admin notification to a specific player
    lia.notices.notifyAdminLocalized(player, "admin.kicked", reason)
    -- Send to all players
    lia.notices.notifyAdminLocalized(nil, "admin.announcement", message)

```

---

### lia.notices.notifyLocalized

#### 📋 Purpose
Sends a localized notification to a client or all clients, handling both server-side networking and client-side display.

#### ⏰ When Called
Called when you want to send a notification using a localization key with variable arguments to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|string|nil** | The player to send the notification to, or the first argument if not a player. If nil, sends to all players. |
| `key` | **string** | The localization key for the message. |
| `notifType` | **string** | The type of notification (e.g., "info", "warning", "error", "success"). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Server-side: Send to specific player
    lia.notices.notifyLocalized(player, "item.purchased", "success", itemName, price)
    -- Server-side: Send to all players
    lia.notices.notifyLocalized(nil, "server.restart", "warning", "5")
    -- Client-side: Display localized notification
    lia.notices.notifyLocalized(nil, "ui.button.clicked", "info")

```

---

### lia.notices.notify

#### 📋 Purpose
Sends a text notification to a client or all clients, handling both server-side networking and client-side display with sound and visual effects.

#### ⏰ When Called
Called when you want to send a notification with plain text (not localized) to a specific client or all clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | The player to send the notification to. If nil, sends to all players. |
| `message` | **string** | The notification message text to display. |
| `notifType` | **string** | The type of notification (e.g., "default", "info", "warning", "error", "success", "money", "admin"). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Server-side: Send to specific player
    lia.notices.notify(player, "You have received 100 credits!", "money")
    -- Server-side: Send to all players
    lia.notices.notify(nil, "Server restarting in 5 minutes", "warning")
    -- Client-side: Display notification
    lia.notices.notify(nil, "Welcome to the server!", "info")

```

---

