# Notices Library

This page documents the functions for working with in-game notifications and notices.

---

## Overview

The notices library (`lia.notices`) provides a comprehensive system for managing in-game notifications, notices, and message display in the Lilia framework, enabling effective communication between the server and players through various notification channels. This library handles sophisticated notification management with support for multiple notice types, priority systems, and intelligent display queuing to ensure important messages are never missed while avoiding notification spam. The system features advanced notice creation with support for rich text formatting, custom styling, interactive elements, and contextual information that adapts to different game situations and player states. It includes comprehensive display functionality with support for various UI positions, animation effects, and accessibility options to accommodate different player preferences and visual needs. The library provides robust notice management with automatic expiration, user dismissal capabilities, and history tracking for administrative review and player reference. Additional features include localization support for multilingual notifications, integration with the framework's permission system for targeted messaging, and performance optimization for high-volume notification scenarios, making it essential for maintaining clear communication channels and keeping players informed about important events, updates, and administrative actions.

**Note**: For most use cases, it's recommended to use the player object methods `client:notify(message, type)` and `client:notifyLocalized(key, ...)` instead of calling the library functions directly. These methods provide a cleaner API and automatically handle the client parameter.

---

### notify

**Purpose**

Shows a notification to a client.

**Parameters**

* `client` (*Player*): The client to show the notification to.
* `message` (*string*): The notification message.
* `type` (*string*): The notification type.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Show notification using the player object method (recommended)
local function notifyPlayer(client, message)
    client:notify(message, "info")
    print("Notification sent to " .. client:Name())
end

-- Use in a function
local function notifyError(client, message)
    client:notify(message, "error")
    print("Error notification sent to " .. client:Name())
end

-- Use in a function
local function notifySuccess(client, message)
    client:notify(message, "success")
    print("Success notification sent to " .. client:Name())
end

-- Alternative: Direct library usage (for advanced cases)
local function notifyDirect(client, message, type)
    client:notify(message, type)
end
```

---

### notifyLocalized

**Purpose**

Shows a localized notification to a client.

**Parameters**

* `client` (*Player*): The client to show the notification to.
* `key` (*string*): The localization key.
* `...` (*any*): Optional parameters for formatting.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Show localized notification using the player object method (recommended)
local function notifyWelcome(client)
    client:notifyLocalized("welcome")
    print("Welcome notification sent to " .. client:Name())
end

-- Use in a function
local function notifyPlayerCount(client, count)
    client:notifyLocalized("player_count", count)
    print("Player count notification sent to " .. client:Name())
end

-- Alternative: Direct library usage (for advanced cases)
local function notifyLocalizedDirect(client, key, ...)
    client:notifyLocalized(key, ...)
end
```