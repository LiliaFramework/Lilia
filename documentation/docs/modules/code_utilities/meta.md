# Meta

A collection of player and entity utility helpers.

---

### Player:squaredDistanceFromEnt

**Purpose**

Returns the squared distance between the player and an entity.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*number* — Squared distance in Hammer units.

**Example**

```lua
local dSqr = client:squaredDistanceFromEnt(ent)
```

---

### Player:distanceFromEnt

**Purpose**

Returns the distance between the player and an entity.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*number* — Distance in Hammer units.

**Example**

```lua
local dist = client:distanceFromEnt(ent)
```

---

### Player:isMoving

**Purpose**

Determines whether the player is currently walking or running.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean* — True if the player is moving on the ground.

**Example**

```lua
if client:isMoving() then print("Player is moving") end
```

---

### Player:isOutside

**Purpose**

Checks whether the player has a clear line to the sky.

**Parameters**

*None*

**Realm**

Shared

**Returns**

*boolean* — True if the player is outside.

**Example**

```lua
if client:isOutside() then print("It's open air above") end
```

---

### Player:openPage

**Purpose**

Sends the player a request to open a webpage in the Steam overlay.

| Name | Type   | Description |

| ---- | ------ | ----------- |

| `url` | string | HTTP or HTTPS address. |

**Realm**

Server

**Returns**

`nil`

**Example**

```lua
client:openPage("https://example.com")
```

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

**Example**

```lua
client:openUI("SomePanel")
```

---

### Entity:getViewAngle

**Purpose**

Calculates the angle difference between the entity's view and a position.

| Name | Type   | Description |

| ---- | ------ | ----------- |

| `pos` | Vector | World position to test. |

**Realm**

Shared

**Returns**

*number* — Absolute angle difference in degrees.

**Example**

```lua
local angDiff = ent:getViewAngle(Vector(0,0,0))
```

---

### Entity:inFov

**Purpose**

Determines whether another entity is within this entity's field of view.

| Name    | Type   | Description                         |

| ------- | ------ | ----------------------------------- |

| `entity` | Entity | Target to check.                    |

| `fov`    | number | Field of view in degrees (default 88). |

**Realm**

Shared

**Returns**

*boolean* — True if the target is within the FOV.

**Example**

```lua
if ent:inFov(target, 60) then ... end
```

---

### Entity:isInRoom

**Purpose**

Checks if there is a direct line between this entity and the target.

| Name   | Type   | Description |

| ------ | ------ | ----------- |

| `target` | Entity | Target entity. |

**Realm**

Shared

**Returns**

*boolean* — True if no world geometry blocks the trace.

**Example**

```lua
if ent:isInRoom(other) then ... end
```

---

### Entity:isScreenVisible

**Purpose**

Checks if an entity is visible on screen within distance and FOV limits.

| Name    | Type   | Description                                   |

| ------- | ------ | --------------------------------------------- |

| `entity` | Entity | Target entity.                                |

| `maxDist` | number | Maximum squared distance (default 512^2).     |

| `fov`    | number | Field of view in degrees.                     |

**Realm**

Shared

**Returns**

*boolean* — True if visible.

**Example**

```lua
if ent:isScreenVisible(target, 1024^2, 70) then ... end
```

---

### Entity:canSeeEntity

**Purpose**

Determines if this entity can see another using line-of-sight and FOV.

| Name    | Type   | Description |

| ------- | ------ | ----------- |

| `entity` | Entity | Target entity. |

| `fov`    | number | Field of view in degrees. |

**Realm**

Shared

**Returns**

*boolean* — True if the target is visible.

**Example**

```lua
if ent:canSeeEntity(target) then ... end
```

---

