# Notice Library

This page describes how popup notices are displayed.

---

## Overview

The notice library displays temporary popup notifications at the top‑right of the player’s screen. Server functions send network messages to clients, which create `liaNotice` panels client-side. These panels are stored in `lia.notices`, repositioned to stack, play `garrysmod/content_downloaded.wav` 0.15 seconds after appearing and automatically expire roughly 7.75 seconds after creation.

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

Sends a localised notice using the `liaNotifyL` net message. If `recipient` is not a `Player`, it is treated as the first formatting argument and the notice is broadcast.

**Parameters**

* `key` (*string*): Localisation key.

* `recipient` (*Player | nil*): Target player, or first format argument if not a `Player`.

* … (*any*): Additional `string.format` values, converted to strings for transmission. Up to 255 are supported.

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

Creates a `liaNotice` panel on the local client, prints the message to console, plays `garrysmod/content_downloaded.wav` 0.15 seconds later at volume 50 and pitch 250, stacks it with existing notices and removes it about 7.75 seconds after creation.

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

Translates `key` with `L(key, …)` and displays the result on the local client using `lia.notices.notify`.

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
