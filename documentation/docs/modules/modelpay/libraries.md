# Libraries

Functions exposed by the Model Pay module.

---

### MODULE:GetSalaryAmount

**Purpose**

Calculates the wage assigned to a player based on their model.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `client` | Player | Player whose salary is being determined. |

**Realm**

`Server`

**Returns**

`number` — `The pay amount for the player's model.`

**Example**

```lua
local pay = MODULE:GetSalaryAmount(client)
```

---

### MODULE:PlayerModelChanged

**Purpose**

Handles player model changes and triggers eligibility hooks.

**Parameters**

| Name | Type | Description |
| --- | --- | --- |
| `client` | Player | Player who changed model. |
| `newModel` | string | Path of the new model. |

**Realm**

`Server`

**Returns**

`nil` — `This function does not return anything.`

**Example**

```lua
-- Called automatically when a player's model updates
MODULE:PlayerModelChanged(client, "models/player/barney.mdl")
```

---

