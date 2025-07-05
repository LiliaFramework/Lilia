# Notice Library

This page describes how popup notices are displayed.

---

## Overview

The notice library displays temporary popup notifications at the top of the

player's screen. Server functions send network messages to connected clients,

which create `liaNotice` panels on the client. These panels are stored in the

`lia.notices` table and automatically expire after roughly 7.5 seconds.

---

### lia.notices.notify

**Description:**

Queues a text notice to display to a specific player or everyone. The

message is sent over the `liaNotify` network string.

**Parameters:**

* `message` (`string`) – Message text to send. Converted to a string internally.


* `recipient` (`Player|nil`) – Optional target player. Leave nil to broadcast.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Broadcast a restart warning to everyone
lia.notices.notify("Server restarting in 10 seconds.")

-- Notify just one player about an error
lia.notices.notify("Your quest failed.", player)
```

---

### lia.notices.notifyLocalized

**Description:**

Sends a localized notice to a player or everyone. When the second argument

isn't a player, it becomes the first formatting parameter and the notice is

broadcast. Messages use the `liaNotifyL` network string.

**Parameters:**

* `key` (`string`) – Localization key.


* `recipient` (`Player|nil`) – Optional target player. Leave nil or pass a

  non-player as the second argument to broadcast.


* ... (any) – Formatting arguments for the localization string.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Send a localized greeting to one player
lia.notices.notifyLocalized("welcome", player)

-- Broadcast a formatted message when no recipient is provided
lia.notices.notifyLocalized("questFoundItem", nil, "golden_key")
```

---

### lia.notices.notify

**Description:**

Creates a `liaNotice` panel on the local client and stores it in

`lia.notices`. Notices fade out after about 7.5 seconds.

**Parameters:**

* `message` (`string`) – Message text to display.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Display a pickup notice on the local client
lia.notices.notify("Item picked up")

-- Print an informational message locally
lia.notices.notify("Welcome back!")
```

---

### lia.notices.notifyLocalized

**Description:**

Translates the key using `L` and displays the result on the local client.

**Parameters:**

* `key` (`string`) – Localization key.


* ... (any) – Formatting arguments for the localization string.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
-- Show a localized pickup message
lia.notices.notifyLocalized("item_picked_up")

-- Include formatting parameters
lia.notices.notifyLocalized("foundCoins", 10)
```

