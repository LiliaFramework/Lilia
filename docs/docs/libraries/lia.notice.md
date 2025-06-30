# Notice Library

This page describes how popup notices are displayed.

---

## Overview

The notice library displays temporary popup notifications at the top of the player's screen. Notices can be queued or targeted to specific players.

---

### lia.notices.notify(message, recipient)

**Description:**

Sends a notification message to a specific player or all players.

**Parameters:**

* message (string) – Message text to send.


* recipient (Player|nil) – Target player, or nil to broadcast.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.notices.notify
    lia.notices.notify("Server restarting", nil)
```

---

### lia.notices.notifyLocalized(key, recipient, ...)

**Description:**

Sends a localized notification to a player or all players.

**Parameters:**

* key (string) – Localization key.


* recipient (Player|nil) – Target player or nil to broadcast.


* ... (any) – Formatting arguments for the localization string.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
    -- This snippet demonstrates a common usage of lia.notices.notifyLocalized
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
    -- This snippet demonstrates a common usage of lia.notices.notify
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
    -- This snippet demonstrates a common usage of lia.notices.notifyLocalized
    lia.notices.notifyLocalized("item_picked_up")
```
