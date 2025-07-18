# Player Meta

Helper functions for tracking a player's blood alcohol content.

---
### Player:ResetBAC (Server)

**Purpose**

Resets the player's blood alcohol level to zero and triggers the BAC hooks.

**Parameters**

*None*

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:ResetBAC()
```

---

### Player:AddBAC (Server)

**Purpose**

Raises the player's BAC by the specified amount.

| Name    | Type   | Description        |
| ------- | ------ | ------------------ |
| `amount` | number | BAC points to add. |

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:AddBAC(15)
```

---

### Player:IsDrunk (Shared)

**Purpose**

Checks whether the player's BAC is above the configured threshold.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean* – `true` if the player is drunk.

---

### Player:GetBAC (Shared)

**Purpose**

Retrieves the player's current BAC value.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*number*

**Example**

```lua
local level = client:GetBAC()
```

---
