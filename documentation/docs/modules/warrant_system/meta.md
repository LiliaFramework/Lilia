# Meta

Extensions for managing a character's warrant status.

---

### Character:ToggleWanted

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

### Character:CanWarrantPlayers

**Purpose**

Checks whether the character has permission to issue warrants.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*

---

### Character:CanSeeWarrantsIssued

**Purpose**

Returns true if the character can see warrant notifications.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*

---

### Character:IsWanted

**Purpose**

Returns whether the character currently has a warrant.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Character:CanSeeWarrants

**Purpose**

Determines whether the character can view the list of active warrants.

**Parameters**

*None*

**Realm**

Server

**Returns**

*boolean*

---

