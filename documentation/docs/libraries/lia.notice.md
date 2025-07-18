# Notice Library

This page describes how popup notices are displayed.

---

## Overview

The notice library displays temporary popup notifications at the top of the player’s screen. Server functions send network messages to clients, which create `liaNotice` panels client-side. These panels are stored in `lia.notices` and automatically expire about 7.5 seconds after creation.

---

### lia.notices.notify

**Purpose**

Sends a text notice to a specific player or to everyone using the `liaNotify` net message.

**Parameters**

* `message` (*string*): Notice text.

* `recipient` (*Player | nil*): Target player; `nil` broadcasts to all.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Broadcast a restart warning
lia.notices.notify("Server restarting in 10 seconds.")

-- Notify a single player about an error
lia.notices.notify("Your quest failed.", player)
```

---

### lia.notices.notifyLocalized

**Purpose**

Sends a localised notice. If `recipient` is not a `Player`, it is treated as the first formatting argument and the notice is broadcast.

**Parameters**

* `key` (*string*): Localisation key.

* `recipient` (*Player | nil*): Target player, or first format argument if not a `Player`.

* … (*any*): Additional `string.format` values.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Send a localised greeting to one player
lia.notices.notifyLocalized("welcome", player)

-- Broadcast a formatted message
lia.notices.notifyLocalized("questFoundItem", nil, "golden_key")
```

---

### lia.notices.notify

**Purpose**

Creates a `liaNotice` panel on the local client. The notice fades after \~7.5 seconds.

**Parameters**

* `message` (*string*): Text to display.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Display a pickup notice locally
lia.notices.notify("Item picked up")

-- Simple informational message
lia.notices.notify("Welcome back!")
```

---

### lia.notices.notifyLocalized

**Purpose**

Translates a localisation key with `L` and shows the result on the local client.

**Parameters**

* `key` (*string*): Localisation key.

* … (*any*): Formatting values.

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- Show a localised pickup message
lia.notices.notifyLocalized("item_picked_up")

-- Include formatting parameters
lia.notices.notifyLocalized("foundCoins", 10)
```

---
