# Meta

Functions managing a player's extra character slots for donors.

---

### Player:GetAdditionalCharSlots

**Purpose**

Returns the number of additional character slots assigned to the player.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*number*

---

### Player:SetAdditionalCharSlots

**Purpose**

Sets the player's additional character slot count.

**Parameters**

| Name | Type   | Description                 |
| ---- | ------ | --------------------------- |
| `val` | number | New additional slot amount. |

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:SetAdditionalCharSlots(3)
```

---

### Player:GiveAdditionalCharSlots

**Purpose**

Adds to the player's additional character slot count.

**Parameters**

| Name      | Type   | Description                            |
| --------- | ------ | -------------------------------------- |
| `AddValue` | number | Amount of slots to grant (default 1). |

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:GiveAdditionalCharSlots(2)
```

---
