# Libraries

This page documents the functions for working with on-screen captions.

---

## Overview

The caption library provides helpers to display short messages (“captions”) on players’ screens.

On the **server**, captions are sent to a single player via the `StartCaption` / `EndCaption` network messages, allowing optional custom durations.

On the **client**, captions are shown locally with the Source engine’s built-in `gui.AddCaption`.

Two utility methods are exposed on the global `lia.caption` table:

* `lia.caption.start` – show a caption

* `lia.caption.finish` – clear the current caption

The net strings `StartCaption` and `EndCaption` are registered automatically when the file is executed on the server.

---

### lia.caption.start (Server)

**Purpose**

Sends a caption to the specified player for a given duration.

**Parameters**

| Name       | Type   | Description                                        |

| ---------- | ------ | -------------------------------------------------- |

| `client`   | Player | The target player who should see the caption.      |

| `text`     | string | The caption text.                                  |

| `duration` | number | How long (in seconds) the caption stays on screen. |

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Grant a player access and show a five-second caption
lia.caption.start(ply, "Access Granted", 5)
```

---

### lia.caption.finish (Server)

**Purpose**

Clears any caption currently displayed to the player.

**Parameters**

| Name     | Type   | Description        |

| -------- | ------ | ------------------ |

| `client` | Player | The target player. |

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Immediately remove the caption from a player’s screen
lia.caption.finish(ply)
```

---

### lia.caption.start (Client)

**Purpose**

Displays a caption on the local player’s screen.

**Parameters**

| Name       | Type   | Description                                                                    |

| ---------- | ------ | ------------------------------------------------------------------------------ |

| `text`     | string | The caption text.                                                              |

| `duration` | number | *(Optional)* Duration in seconds. If omitted, defaults to `#characters × 0.1`. |

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Show a local caption for three seconds
lia.caption.start("Mission Complete", 3)
```

---

### lia.caption.finish (Client)

**Purpose**

Removes the caption shown on the local player’s screen.

**Parameters**

*(None)*

**Realm**

`Client`

**Returns**

* *nil*: This function does not return a value.

**Example**

```lua
-- Clear the current caption
lia.caption.finish()
```

---

