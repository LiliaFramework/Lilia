# Tool Meta

The ToolGun interacts with the world through specialized meta functions.

---

### Create

**Purpose**

Creates a new tool object with default properties and metatable.

**Parameters**

* None

**Returns**

* table - The new tool object.

**Realm**

`Shared`

**Example Usage**

```lua
local tool = toolGunMeta:Create()
```

---

### CreateConVars

**Purpose**

Creates client and server console variables for the tool mode.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:CreateConVars()
```

---

### UpdateData

**Purpose**

Updates tool data. Intended to be overridden by specific tool implementations.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:UpdateData()
```

---

### FreezeMovement

**Purpose**

Freezes movement for the tool. Intended to be overridden by specific tool implementations.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:FreezeMovement()
```

---

### DrawHUD

**Purpose**

Draws the tool's HUD. Intended to be overridden by specific tool implementations.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Client`

**Example Usage**

```lua
tool:DrawHUD()
```

---

### GetServerInfo

**Purpose**

Retrieves the server convar for the given property and current tool mode.

**Parameters**

* property (string) - The property name.

**Returns**

* ConVar - The server convar object.

**Realm**

`Shared`

**Example Usage**

```lua
local cvar = tool:GetServerInfo("allow")
```

---

### BuildConVarList

**Purpose**

Builds a table of client convars for the current tool mode.

**Parameters**

* None

**Returns**

* table - Table of convar names and their default values.

**Realm**

`Shared`

**Example Usage**

```lua
local convars = tool:BuildConVarList()
```

---

### GetClientInfo

**Purpose**

Gets the value of a client convar for the tool's owner.

**Parameters**

* property (string) - The property name.

**Returns**

* string - The value of the client convar.

**Realm**

`Shared`

**Example Usage**

```lua
local value = tool:GetClientInfo("someproperty")
```

---

### GetClientNumber

**Purpose**

Gets the numeric value of a client convar for the tool's owner.

**Parameters**

* property (string) - The property name.
* default (number) - The default value if the convar is not set.

**Returns**

* number - The numeric value of the client convar.

**Realm**

`Shared`

**Example Usage**

```lua
local num = tool:GetClientNumber("someproperty", 1)
```

---

### Allowed

**Purpose**

Checks if the tool mode is allowed on the server.

**Parameters**

* None

**Returns**

* boolean - True if allowed, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if tool:Allowed() then ... end
```

---

### Init

**Purpose**

Initializes the tool. Intended to be overridden by specific tool implementations.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:Init()
```

---

### GetMode

**Purpose**

Returns the current tool mode.

**Parameters**

* None

**Returns**

* string - The tool mode.

**Realm**

`Shared`

**Example Usage**

```lua
local mode = tool:GetMode()
```

---

### GetSWEP

**Purpose**

Returns the SWEP (Scripted Weapon) associated with the tool.

**Parameters**

* None

**Returns**

* SWEP - The SWEP object.

**Realm**

`Shared`

**Example Usage**

```lua
local swep = tool:GetSWEP()
```

---

### GetOwner

**Purpose**

Returns the owner of the tool.

**Parameters**

* None

**Returns**

* Player - The owner of the tool.

**Realm**

`Shared`

**Example Usage**

```lua
local owner = tool:GetOwner()
```

---

### GetWeapon

**Purpose**

Returns the weapon associated with the tool.

**Parameters**

* None

**Returns**

* Weapon - The weapon object.

**Realm**

`Shared`

**Example Usage**

```lua
local weapon = tool:GetWeapon()
```

---

### LeftClick

**Purpose**

Handles the left click action for the tool. Intended to be overridden.

**Parameters**

* None

**Returns**

* boolean - Whether the action was successful.

**Realm**

`Shared`

**Example Usage**

```lua
tool:LeftClick()
```

---

### RightClick

**Purpose**

Handles the right click action for the tool. Intended to be overridden.

**Parameters**

* None

**Returns**

* boolean - Whether the action was successful.

**Realm**

`Shared`

**Example Usage**

```lua
tool:RightClick()
```

---

### Reload

**Purpose**

Handles the reload action for the tool, clearing all objects.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:Reload()
```

---

### Deploy

**Purpose**

Handles the deploy action for the tool, releasing the ghost entity.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:Deploy()
```

---

### Holster

**Purpose**

Handles the holster action for the tool, releasing the ghost entity.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:Holster()
```

---

### Think

**Purpose**

Called every frame, releases the ghost entity.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:Think()
```

---

### CheckObjects

**Purpose**

Checks the validity of objects in the tool's object list and clears them if invalid.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:CheckObjects()
```

---

### ClearObjects

**Purpose**

Clears the tool's object list.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:ClearObjects()
```

---

### ReleaseGhostEntity

**Purpose**

Removes the ghost entity if it exists.

**Parameters**

* None

**Returns**

* `None`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
tool:ReleaseGhostEntity()
```

