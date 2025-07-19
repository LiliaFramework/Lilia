# Meta

Utility methods for managing the raised state of a player's weapon.

---

### Player:isWepRaised

**Purpose**

Returns `true` if the player's active weapon is considered raised.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Player:setWepRaised

**Purpose**

Sets whether the player's weapon is raised and fires `PlayerWeaponRaisedChanged`.

| Name   | Type    | Description          |

| ------ | ------- | -------------------- |

| `state` | boolean | Desired raised state |

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:setWepRaised(true)
```

---

### Player:toggleWepRaised

**Purpose**

Toggles the weapon's raised state and runs any weapon callbacks.

**Parameters**

*None*

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:toggleWepRaised()
```

---

