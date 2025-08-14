# Meta

Utility methods for managing the raised state of a player's weapon.

---

### Player:isWepRaised

**Purpose**

Checks the `ShouldWeaponBeRaised` hook and weapon flags before returning the
player's `raised` networked state.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Player:setWepRaised

**Purpose**

Sets whether the player's weapon is raised, fires `PlayerWeaponRaisedChanged`,
and temporarily blocks firing for one second.

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

After a one second delay, toggles the weapon's raised state and runs any weapon
callbacks.

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

