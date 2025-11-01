# Notice Library

Player notification and messaging system for the Lilia framework.

---

Overview

The notice library provides comprehensive functionality for displaying notifications and messages to players in the Lilia framework. It handles both server-side and client-side notification systems, supporting both direct text messages and localized messages with parameter substitution. The library operates across server and client realms, with the server sending notification data to clients via network messages, while the client handles the visual display of notifications using VGUI panels. It includes automatic organization of multiple notifications, sound effects, and console output for debugging purposes. The library also provides compatibility with Garry's Mod's legacy notification system.

---

### notify

**Purpose**

Sends a notification message to a specific client or all clients

**When Called**

When server needs to display a notification to player(s)

**Parameters**

* `client` (*Player|nil*): Target player to send notification to, or nil for all players
* `message` (*string*): The notification message text to display
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send basic notification to all players
lia.notices.notify(nil, "Server restarting in 5 minutes!")

```

**Medium Complexity:**
```lua
-- Medium: Send error notification to specific player
local player = Player(1)
if IsValid(player) then
    lia.notices.notify(player, "You don't have permission to do that!", "error")
end

```

**High Complexity:**
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

### notifyLocalized

**Purpose**

Sends a localized notification message to a specific client or all clients

**When Called**

When server needs to display a localized notification with parameter substitution

**Parameters**

* `client` (*Player|nil*): Target player to send notification to, or nil for all players
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Send localized notification to all players
lia.notices.notifyInfoLocalized(nil, "server.restart")

```

**Medium Complexity:**
```lua
-- Medium: Send localized notification with one parameter
local player = Player(1)
lia.notices.notifySuccessLocalized(player, "player.welcome", player:Name())

```

**High Complexity:**
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

### lia.originalReceiveNotify

**Purpose**

Receives and displays notification messages from the server

**When Called**

Automatically called when server sends notification data via network

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Function is called automatically when server sends notification
-- No direct usage needed - handled by network receiver

```

**Medium Complexity:**
```lua
-- Medium: Custom network receiver with additional processing
net.Receive("liaNotificationData", function()
lia.notices.receiveNotify()
-- Additional custom processing here
print("Notification received from server")
end)

```

**High Complexity:**
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

### receiveNotify

**Purpose**

Receives and displays notification messages from the server

**When Called**

Automatically called when server sends notification data via network

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Function is called automatically when server sends notification
-- No direct usage needed - handled by network receiver

```

**Medium Complexity:**
```lua
-- Medium: Custom network receiver with additional processing
net.Receive("liaNotificationData", function()
lia.notices.receiveNotify()
-- Additional custom processing here
print("Notification received from server")
end)

```

**High Complexity:**
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

### lia.originalReceiveNotifyL

**Purpose**

Receives and displays localized notification messages from the server

**When Called**

Automatically called when server sends localized notification data via network

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Function is called automatically when server sends localized notification
-- No direct usage needed - handled by network receiver

```

**Medium Complexity:**
```lua
-- Medium: Custom network receiver with additional processing
net.Receive("liaNotifyLocal", function()
lia.notices.receiveNotifyL()
-- Additional custom processing here
print("Localized notification received from server")
end)

```

**High Complexity:**
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

### receiveNotifyL

**Purpose**

Receives and displays localized notification messages from the server

**When Called**

Automatically called when server sends localized notification data via network

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Function is called automatically when server sends localized notification
-- No direct usage needed - handled by network receiver

```

**Medium Complexity:**
```lua
-- Medium: Custom network receiver with additional processing
net.Receive("liaNotifyLocal", function()
lia.notices.receiveNotifyL()
-- Additional custom processing here
print("Localized notification received from server")
end)

```

**High Complexity:**
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

### notify

**Purpose**

Creates and displays a notification message directly on the client

**When Called**

When client needs to display a notification without server communication

**Parameters**

* `_` (*any*): Ignored parameter (for compatibility with server version)
* `message` (*string*): The notification message text to display
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display basic notification
lia.notices.notify(nil, "Settings saved!", "success")

```

**Medium Complexity:**
```lua
-- Medium: Display notification with dynamic content
local playerName = LocalPlayer():Name()
lia.notices.notify(nil, "Welcome back, " .. playerName .. "!", "info")

```

**High Complexity:**
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

### notifyLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifyInfoLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifyWarningLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifyErrorLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifySuccessLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifyMoneyLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### notifyAdminLocalized

**Purpose**

Creates and displays a localized notification message directly on the client

**When Called**

When client needs to display a localized notification without server communication

**Parameters**

* `client` (*any*): Ignored parameter (for compatibility with server version)
* `key` (*string*): Localization key for the message
* `notifType` (*string|nil*): Type of notification ("default", "error", "success", "info", etc.)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Display localized notification
lia.notices.notifySuccessLocalized(nil, "ui.settings.saved")

```

**Medium Complexity:**
```lua
-- Medium: Display localized notification with one parameter
local playerName = LocalPlayer():Name()
lia.notices.notifyInfoLocalized(nil, "ui.welcome.back", playerName)

```

**High Complexity:**
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

### lia.originalAddLegacy

**Purpose**

Provides compatibility with Garry's Mod's legacy notification system

**When Called**

When legacy notification functions are used (e.g., notification.AddLegacy)

**Parameters**

* `text` (*string*): The notification message text to display
* `typeId` (*number*): Legacy notification type ID (0=info, 1=error, 2=success)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Use legacy notification system
notification.AddLegacy("Server restarting!", 0)

```

**Medium Complexity:**
```lua
-- Medium: Convert legacy notifications to new system
local legacyTypes = {[0] = "info", [1] = "error", [2] = "success"}
local message = "Player disconnected"
local typeId = 1
notification.AddLegacy(message, typeId)

```

**High Complexity:**
```lua
-- High: Override legacy notification with custom handling
local originalAddLegacy = notification.AddLegacy
notification.AddLegacy = function(text, typeId)
local map = {[0] = "info", [1] = "error", [2] = "success"}
local notifType = map[tonumber(typeId) or -1] or "default"
-- Custom processing
if notifType == "error" then
    -- Log errors to file
    file.Append("legacy_notifications.log", os.date() .. ": " .. text .. "\n")
end
-- Call original function
originalAddLegacy(text, typeId)
end

```

---

### lia.notification.AddLegacy

**Purpose**

Provides compatibility with Garry's Mod's legacy notification system

**When Called**

When legacy notification functions are used (e.g., notification.AddLegacy)

**Parameters**

* `text` (*string*): The notification message text to display
* `typeId` (*number*): Legacy notification type ID (0=info, 1=error, 2=success)

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Use legacy notification system
notification.AddLegacy("Server restarting!", 0)

```

**Medium Complexity:**
```lua
-- Medium: Convert legacy notifications to new system
local legacyTypes = {[0] = "info", [1] = "error", [2] = "success"}
local message = "Player disconnected"
local typeId = 1
notification.AddLegacy(message, typeId)

```

**High Complexity:**
```lua
-- High: Override legacy notification with custom handling
local originalAddLegacy = notification.AddLegacy
notification.AddLegacy = function(text, typeId)
local map = {[0] = "info", [1] = "error", [2] = "success"}
local notifType = map[tonumber(typeId) or -1] or "default"
-- Custom processing
if notifType == "error" then
    -- Log errors to file
    file.Append("legacy_notifications.log", os.date() .. ": " .. text .. "\n")
end
-- Call original function
originalAddLegacy(text, typeId)
end

```

---

### lia.OrganizeNotices

**Purpose**

Organizes and positions notification panels on the screen

**When Called**

Automatically called when new notifications are created

**Returns**

* None

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Function is called automatically when notifications are created
-- No direct usage needed - handled internally

```

**Medium Complexity:**
```lua
-- Medium: Manually organize notices after bulk creation
for i = 1, 5 do
    lia.notices.notify(nil, "Notification " .. i, "info")
end
OrganizeNotices() -- Ensure proper positioning

```

**High Complexity:**
```lua
-- High: Custom notice organization with different positioning
local originalOrganizeNotices = OrganizeNotices
OrganizeNotices = function()
local scale = ScrH() / 1080
local baseY = ScrH() - 300 * scale -- Different base position
local spacing = 8 * scale -- Different spacing
local y = baseY
for _, v in ipairs(lia.notices) do
    if IsValid(v) then
        v.targetY = y
        -- Add custom animation
        v:MoveTo(v:GetX(), y, 0.3, 0, 0.5)
        y = y - (v:GetTall() + spacing)
    end
end
end

```

---

