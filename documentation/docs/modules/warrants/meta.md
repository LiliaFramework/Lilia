# Meta

### Character:ToggleWanted (Server)

**Purpose**

Toggles the character's wanted status and notifies relevant players.

| Name        | Type   | Description                     |
| ----------- | ------ | ------------------------------- |
| `warranter` | Player | Player initiating the toggle. |

**Realm**

Server

**Returns**

`nil`

---

### Character:CanWarrantPlayers (Server)

**Purpose**

Checks whether the character has permission to issue warrants.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*

---

### Character:CanSeeWarrantsIssued (Server)

**Purpose**

Returns true if the character can see warrant notifications.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*

---

### Character:IsWanted (Shared)

**Purpose**

Returns whether the character currently has a warrant.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Character:CanSeeWarrants (Server)

**Purpose**

Determines whether the character can view the list of active warrants.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*
