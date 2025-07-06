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

**Purpose**

Sends a text notice to one player or everyone using the `liaNotify` network string.

**Parameters**

* `message` (*string*): Message text.
* `recipient` (*Player|nil*): Optional target player, or nil to broadcast.

**Realm**

`Server`

**Returns**

* `nil`

**Example**

```lua
-- Broadcast a restart warning to everyone
lia.notices.notify("Server restarting in 10 seconds.")

-- Notify just one player about an error
lia.notices.notify("Your quest failed.", player)
```

---

### lia.notices.notifyLocalized

**Purpose**

Sends a localized notice. When the second argument isn't a player it becomes the first formatting parameter and the notice is broadcast.

**Parameters**

* `key` (*string*): Localization key.
* `recipient` (*Player|nil*): Optional target player or formatting argument.
* ... (*any*): Additional formatting values.

**Realm**

`Server`

**Returns**

* `nil`

**Example**

```lua
-- Send a localized greeting to one player
lia.notices.notifyLocalized("welcome", player)

-- Broadcast a formatted message when no recipient is provided
lia.notices.notifyLocalized("questFoundItem", nil, "golden_key")

```
---

### lia.notices.notify

**Purpose**

Creates a `liaNotice` panel on the local client. Notices fade out after about 7.5 seconds.

**Parameters**

* `message` (*string*): Message text to display.

**Realm**

`Client`

**Returns**

* `nil`

**Example**

```lua
-- Display a pickup notice on the local client
lia.notices.notify("Item picked up")

-- Print an informational message locally
lia.notices.notify("Welcome back!")
```

---

### lia.notices.notifyLocalized

**Purpose**

Translates the key using `L` and displays the result on the local client.

**Parameters**

* `key` (*string*): Localization key.
* ... (*any*): Formatting arguments for the localization string.

**Realm**

`Client`

**Returns**

* `nil`

**Example**

```lua
-- Show a localized pickup message
lia.notices.notifyLocalized("item_picked_up")

-- Include formatting parameters
lia.notices.notifyLocalized("foundCoins", 10)

```

---

#### Library Conventions

1. **Namespace**
   When formatting libraries, make sure to only document lia.* functions of that type. For example if you are documenting workshop.lua, you'd document lia.workshop functions .

2. **Shared Definitions**
   Omit any parameters or fields already documented in `docs/definitions.lua`.

3. **Internal-Only Functions**
   If this function is not meant to be used outside the internal scope of the gamemode, such as lia.module.load, add the “Internal function” note (see above).
