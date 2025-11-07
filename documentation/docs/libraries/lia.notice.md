# Notice Library

Player notification and messaging system for the Lilia framework.

---

Overview

The notice library provides comprehensive functionality for displaying notifications and messages to players in the Lilia framework. It handles both server-side and client-side notification systems, supporting both direct text messages and localized messages with parameter substitution. The library operates across server and client realms, with the server sending notification data to clients via network messages, while the client handles the visual display of notifications using VGUI panels. It includes automatic organization of multiple notifications, sound effects, and console output for debugging purposes. The library also provides compatibility with Garry's Mod's legacy notification system.

---

### lia.notices.notify

#### 📋 Purpose
Sends a notification message to a specific client or all clients

#### ⏰ When Called
When server needs to display a notification to player(s)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Target player to send notification to, or nil for all players |
| `message` | **string** | The notification message text to display |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send basic notification to all players
    lia.notices.notify(nil, "Server restarting in 5 minutes!")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send error notification to specific player
    local player = Player(1)
    if IsValid(player) then
        lia.notices.notify(player, "You don't have permission to do that!", "error")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Send notifications to multiple players with different types
    local players = player.GetAll()
    for _, ply in ipairs(players) do
        if ply:IsAdmin() then
            lia.notices.notify(ply, "Admin panel updated", "info")
        else
            lia.notices.notify(ply, "Welcome to the server!", "success")
        end
    end

```

---

### lia.notices.notifyLocalized

#### 📋 Purpose
Sends a localized notification message to a specific client or all clients

#### ⏰ When Called
When server needs to display a localized notification with parameter substitution

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Target player to send notification to, or nil for all players |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Send localized notification to all players
    lia.notices.notifyInfoLocalized(nil, "server.restart")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Send localized notification with one parameter
    local player = Player(1)
    lia.notices.notifySuccessLocalized(player, "player.welcome", player:Name())

```

#### ⚙️ High Complexity
```lua
    -- High: Send localized notifications with multiple parameters
    local players = player.GetAll()
    for _, ply in ipairs(players) do
        local timeLeft = math.max(0, 300 - CurTime())
        lia.notices.notifyWarningLocalized(ply, "server.restart.time",
        ply:Name(), math.floor(timeLeft / 60), timeLeft % 60)
    end

```

---

### lia.notices.receiveNotify

#### 📋 Purpose
Receives and displays notification messages from the server

#### ⏰ When Called
Automatically called when server sends notification data via network

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `None` | **reads from network stream** |  |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Function is called automatically when server sends notification
    -- No direct usage needed - handled by network receiver

```

#### 📊 Medium Complexity
```lua
    -- Medium: Custom network receiver with additional processing
    net.Receive("liaNotificationData", function()
    lia.notices.receiveNotify()
    -- Additional custom processing here
    print("Notification received from server")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Override default behavior with custom notification handling
    local originalReceiveNotify = lia.notices.receiveNotify
    lia.notices.receiveNotify = function()
    local msg = net.ReadString() or ""
    local ntype = net.ReadString() or "default"
    -- Custom processing before creating notice
    if ntype == "error" then
        -- Log errors to file
        file.Append("notifications.log", os.date() .. ": " .. msg .. "\n")
    end
    -- Call original function
    originalReceiveNotify()
    end

```

---

### lia.notices.receiveNotifyL

#### 📋 Purpose
Receives and displays localized notification messages from the server

#### ⏰ When Called
Automatically called when server sends localized notification data via network

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `None` | **reads from network stream** |  |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Function is called automatically when server sends localized notification
    -- No direct usage needed - handled by network receiver

```

#### 📊 Medium Complexity
```lua
    -- Medium: Custom network receiver with additional processing
    net.Receive("liaNotifyLocal", function()
    lia.notices.receiveNotifyL()
    -- Additional custom processing here
    print("Localized notification received from server")
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Override default behavior with custom localized notification handling
    local originalReceiveNotifyL = lia.notices.receiveNotifyL
    lia.notices.receiveNotifyL = function()
    local key = net.ReadString() or ""
    local argc = net.ReadUInt(8) or 0
    local args = {}
    for i = 1, argc do
        args[i] = net.ReadString()
    end
    -- Custom processing before creating notice
    local msg = L(key, unpack(args))
    if string.find(msg, "error") then
        -- Log errors to file
        file.Append("notifications.log", os.date() .. ": " .. msg .. "\n")
    end
    -- Call original function
    originalReceiveNotifyL()
    end

```

---

### lia.notices.notify

#### 📋 Purpose
Creates and displays a notification message directly on the client

#### ⏰ When Called
When client needs to display a notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `_` | **any** | Ignored parameter (for compatibility with server version) |
| `message` | **string** | The notification message text to display |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display basic notification
    lia.notices.notify(nil, "Settings saved!", "success")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display notification with dynamic content
    local playerName = LocalPlayer():Name()
    lia.notices.notify(nil, "Welcome back, " .. playerName .. "!", "info")

```

#### ⚙️ High Complexity
```lua
    -- High: Display notifications based on conditions
    local player = LocalPlayer()
    if player:GetNWInt("health") < 25 then
        lia.notices.notify(nil, "Health critical! Find medical attention!", "error")
        elseif player:GetNWInt("health") < 50 then
            lia.notices.notify(nil, "Health low - be careful!", "warning")
            else
                lia.notices.notify(nil, "Health status: Good", "success")
            end

```

---

### lia.notices.notifyLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifyInfoLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifyWarningLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifyErrorLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifySuccessLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifyMoneyLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

### lia.notices.notifyAdminLocalized

#### 📋 Purpose
Creates and displays a localized notification message directly on the client

#### ⏰ When Called
When client needs to display a localized notification without server communication

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **any** | Ignored parameter (for compatibility with server version) |
| `key` | **string** | Localization key for the message |
| `notifType` | **string|nil** | Type of notification ("default", "error", "success", "info", etc.) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Display localized notification
    lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Display localized notification with one parameter
    local playerName = LocalPlayer():Name()
    lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

#### ⚙️ High Complexity
```lua
    -- High: Display localized notifications with multiple parameters
    local player = LocalPlayer()
    local health = player:GetNWInt("health")
    local maxHealth = player:GetMaxHealth()
    local healthPercent = math.floor((health / maxHealth) * 100)
    if health < 25 then
        lia.notices.notifyErrorLocalized(nil, "ui.health.critical",
        health, maxHealth, healthPercent)
        elseif health < 50 then
            lia.notices.notifyWarningLocalized(nil, "ui.health.low",
            health, maxHealth, healthPercent)
            else
                lia.notices.notifySuccessLocalized(nil, "ui.health.good",
                health, maxHealth, healthPercent)
            end

```

---

