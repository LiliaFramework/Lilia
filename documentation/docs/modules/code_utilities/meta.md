# Meta

A collection of player and entity utility helpers.

---

### Player:squaredDistanceFromEnt

**Purpose**

Returns the squared distance from the player to the given entity.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*number*

**Example**

```lua
local dist = client:squaredDistanceFromEnt(ent)
```

---

### Player:distanceFromEnt

**Purpose**

Returns the distance from the player to the given entity.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*number*

---

### Player:isMoving

**Purpose**

Checks whether the player is currently walking or running.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Player:isOutside

**Purpose**

Determines whether the player has an unobstructed line to the sky.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean*

---

### Player:openPage

**Purpose**

Opens the given URL in the player's Steam overlay.

| Name | Type   | Description |

| ---- | ------ | ----------- |

| `url` | string | HTTP or HTTPS address. |

**Realm**

Server

**Returns**

`nil`

---

### Player:openUI

**Purpose**

Opens a named VGUI panel on the client.

| Name   | Type   | Description                  |

| ------ | ------ | ---------------------------- |

| `panel` | string | Panel identifier registered client-side. |

**Realm**

Server

**Returns**

`nil`

---

### Entity:getViewAngle

**Purpose**

Returns the absolute angle difference between the entity's view and a world position.

| Name | Type   | Description |

| ---- | ------ | ----------- |

| `pos` | Vector | World position to test. |

**Realm**

Shared

**Returns**

*number*

---

### Entity:inFov

**Purpose**

Checks if another entity is within this entity's field of view.

| Name    | Type   | Description                         |

| ------- | ------ | ----------------------------------- |

| `entity` | Entity | Target to check.                    |

| `fov`    | number | Field of view in degrees (default 88). |

**Realm**

Shared

**Returns**

*boolean*

---

### Entity:isInRoom

**Purpose**

Returns true if there is a direct line between this entity and the target.

| Name   | Type   | Description |

| ------ | ------ | ----------- |

| `target` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*boolean*

---

### Entity:isScreenVisible

**Purpose**

Checks whether an entity is visible on screen within optional distance and FOV limits.

| Name    | Type   | Description                                   |

| ------- | ------ | --------------------------------------------- |

| `entity` | Entity | Target entity.                                |

| `maxDist` | number | Maximum squared distance (default 512^2).     |

| `fov`    | number | Field of view in degrees.                     |

**Realm**

Shared

**Returns**

*boolean*

---

### Entity:canSeeEntity

**Purpose**

Combines line-of-sight and FOV checks to determine if a target is visible.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

| `fov`    | number | Field of view in degrees. |

**Realm**

Shared

**Returns**

*boolean*

---

