# Notice Library

This page describes how popup notices are displayed.

---

## Overview

The notice library displays temporary popup notifications at the top of the
player's screen. Notices can be queued or targeted to specific players. On the
client, active notice panels are stored in the `lia.notices` table.

---

### lia.notices.notify(message, recipient)

**Description:**

Queues a text notice to display to a specific player or everyone.

**Parameters:**

* message (string) – Message text to send.


* recipient (Player|nil) – Optional target player. Leave nil to broadcast.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Broadcast a restart warning to all players
    lia.notices.notify("Server restarting in 10 seconds.")
```

---

### lia.notices.notifyLocalized(key, recipient, ...)

**Description:**

Sends a localized notice to a player or everyone. When the second
argument isn't a player, it becomes the first formatting parameter and
the notice is broadcast.

**Parameters:**

* key (string) – Localization key.


* recipient (Player|nil) – Optional target player. Leave nil or pass a
  non-player as the second argument to broadcast.


* ... (any) – Formatting arguments for the localization string.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- Send a localized greeting to a specific client
    lia.notices.notifyLocalized("welcome", client)
```

---

### lia.notices.notify(message)

**Description:**

Creates a visual notification panel on the client's screen.

**Parameters:**

* message (string) – Message text to display.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- Display a pickup notice on the local client
    lia.notices.notify("Item picked up")
```

---

### lia.notices.notifyLocalized(key, ...)

**Description:**

Displays a localized notification on the client's screen.

**Parameters:**

* key (string) – Localization key.


* ... (any) – Formatting arguments for the localization string.


**Realm:**

* Client


**Returns:**

* None


**Example Usage:**

```lua
    -- Translate and display a pickup message
    lia.notices.notifyLocalized("item_picked_up")
```

---

### notification.AddLegacy(text)

**Description:**

Client-side alias that calls `lia.notices.notify`. Any addon using the
default Garry's Mod function will display the notice using Lilia's UI.

**Parameters:**

* text (string) – Text to display.

**Realm:**

* Client

**Returns:**

* None

**Example Usage:**

```lua
    notification.AddLegacy("You have leveled up!")
```
