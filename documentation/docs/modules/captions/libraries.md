# lia.caption Library

---

## Overview

Helpers to show and hide Closed Captions for players or locally on the client.

---

### start

**Purpose**

Begin displaying a caption for a duration.

**When Called**

This function is used when:
- Temporarily showing on-screen captions/subtitles

**Parameters**

Server variant:
* `client` (Player): Recipient.
* `text` (string): Caption text.
* `duration` (number): Seconds to show.

Client variant:
* `text` (string): Caption text.
* `duration` (number): Seconds to show.

**Returns**

None.

**Realm**

Server and Client variants exist.

**Example Usage**

```lua
-- Server
lia.caption.start(ply, "Sector sweep in progress", 5)

-- Client
lia.caption.start("Welcome", 3)
```

---

### finish

**Purpose**

Stop an active caption.

**Parameters**

Server variant:
* `client` (Player): Recipient.

Client variant:
None.

**Returns**

None.

**Realm**

Server and Client variants exist.

**Example Usage**

```lua
-- Server
lia.caption.finish(ply)

-- Client
lia.caption.finish()
```


