# Notices Library

This page documents the functions for working with in-game notifications and notices.

---

## Overview

The notices library (`lia.notices`) provides a comprehensive system for managing in-game notifications, notices, and message display in the Lilia framework. It includes notice creation, display, and management functionality.

---

### lia.notices.notify

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
-- Show notification
local function notify(client, message, type)
    lia.notices.notify(client, message, type)
end

-- Use in a function
local function notifyPlayer(client, message)
    lia.notices.notify(client, message, "info")
    print("Notification sent to " .. client:Name())
end

-- Use in a function
local function notifyError(client, message)
    lia.notices.notify(client, message, "error")
    print("Error notification sent to " .. client:Name())
end

-- Use in a function
local function notifySuccess(client, message)
    lia.notices.notify(client, message, "success")
    print("Success notification sent to " .. client:Name())
end
```

---

### lia.notices.notifyLocalized

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
-- Show localized notification
local function notifyLocalized(client, key, ...)
    lia.notices.notifyLocalized(client, key, ...)
end

-- Use in a function
local function notifyWelcome(client)
    lia.notices.notifyLocalized(client, "welcome")
    print("Welcome notification sent to " .. client:Name())
end

-- Use in a function
local function notifyPlayerCount(client, count)
    lia.notices.notifyLocalized(client, "player_count", count)
    print("Player count notification sent to " .. client:Name())
end
```
