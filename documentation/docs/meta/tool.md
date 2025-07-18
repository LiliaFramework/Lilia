# Tool Meta

The ToolGun interacts with the world through specialized meta functions.

This guide lists utilities for object manipulation and ghost entity management.

---

## Overview

Tool meta functions track hovered entities, create ghost previews, and wrap common building operations.

They ensure consistent behavior across custom tools in Lilia.

---

### Create

**Purpose**

Creates a new tool object with default values.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* table: The newly created tool object.

**Example Usage**

```lua
-- Create a new tool instance and configure it
local tool = ToolGunMeta:Create()
tool.Mode = "lia_dooredit"
tool.SWEP = weapon -- weapon variable from your SWEP
tool.Owner = client -- client that spawned the tool
```

---

### CreateConVars

**Purpose**

Creates client and server ConVars for this tool.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
-- Ensure console variables exist for configuration
tool:CreateConVars()
```

---

### GetServerInfo

**Purpose**

Returns the server ConVar for the given property.

**Parameters**

* `property` (*string*): Property name.

**Realm**

`Shared`

**Returns**

* ConVar: The server ConVar object.

**Example Usage**

```lua
-- Check if the server allows using this tool
local allow = tool:GetServerInfo("allow_use"):GetBool()
```

---

### BuildConVarList

**Purpose**

Returns a table of client ConVars prefixed by the tool mode.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* table: Table of convars.

**Example Usage**

```lua
-- Get a table of client ConVars for networking
local cvars = tool:BuildConVarList()
```

---

### GetClientInfo

**Purpose**

Retrieves a client ConVar value as a string.

**Parameters**

* `property` (*string*): ConVar name without mode prefix.

**Realm**

`Shared`

**Returns**

* string: The value stored in the ConVar.

**Example Usage**

```lua
-- Get the client's chosen material from a ConVar
local mat = tool:GetClientInfo("material")
```

---

### GetClientNumber

**Purpose**

Retrieves a numeric client ConVar value.

**Parameters**

* `property` (*string*): ConVar name without mode prefix.

* `default` (*number*): Value returned if the ConVar doesn't exist.

**Realm**

`Shared`

**Returns**

* number: The numeric value of the ConVar.

**Example Usage**

```lua
-- Read the numeric power setting with a fallback
local power = tool:GetClientNumber("power", 10)
```

---

### Allowed

**Purpose**

Determines whether this tool is allowed to be used.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* boolean: True if the tool is allowed.

**Example Usage**

```lua
-- Gate tool usage behind an admin check
function TOOL:Allowed()
    return self.AllowedCVar:GetBool() and self:GetOwner():IsAdmin()
end
```

---

### Init

**Purpose**

Placeholder for tool initialization.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:Init()
    self.Stage = 1
    self:CreateConVars()
end
```

---

### GetMode

**Purpose**

Gets the current tool mode string.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* string: Tool mode name.

**Example Usage**

```lua
-- Retrieve the tool's active mode string
local result = tool:GetMode()
```

---

### GetSWEP

**Purpose**

Returns the SWEP associated with this tool.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* SWEP: The tool's weapon entity.

**Example Usage**

```lua
-- Obtain the weapon entity representing this tool
local result = tool:GetSWEP()
```

---

### GetOwner

**Purpose**

Returns the player who owns the associated weapon.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* Player: Owner of the tool.

**Example Usage**

```lua
-- Reference the player who deployed the tool
local owner = tool:GetOwner()
print(owner:Name())
```

---

### GetWeapon

**Purpose**

Retrieves the weapon entity this tool is attached to.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* Weapon: The weapon object.

**Example Usage**

```lua
-- Access the underlying weapon object
local result = tool:GetWeapon()
```

---

### LeftClick

**Purpose**

Handles the left-click action. Override for custom behavior.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* boolean: False by default.

**Example Usage**

```lua
-- Example override performing a build action
function TOOL:LeftClick(trace)
    self:AddPoint(trace.HitPos)
    return true
end
```

---

### RightClick

**Purpose**

Handles the right-click action. Override for custom behavior.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* boolean: False by default.

**Example Usage**

```lua
-- Example override for an alternate action
function TOOL:RightClick(trace)
    openContextMenu(trace.Entity)
    return true
end
```

---

### Reload

**Purpose**

Clears stored objects when the tool reloads.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:Reload()
    self:ClearObjects()
    self:ReleaseGhostEntity()
end
```

---

### Deploy

**Purpose**

Called when the tool is equipped. Releases ghost entity.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:Deploy()
    self:ReleaseGhostEntity()
    self:CreateConVars()
end
```

---

### Holster

**Purpose**

Called when the tool is holstered. Releases ghost entity.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:Holster()
    self:ReleaseGhostEntity()
    self:ClearObjects()
end
```

---

### Think

**Purpose**

Called every tick; releases ghost entities by default.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:Think()
    self:CheckObjects()
    updateGhost(self:GetOwner(), self.GhostEntity)
end
```

---

### CheckObjects

**Purpose**

Validates stored objects and clears them if invalid.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
-- Validate all stored objects each tick
local result = tool:CheckObjects()
```

---

### ClearObjects

**Purpose**

Removes all stored objects from the tool.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
-- Remove any objects the tool is storing
local result = tool:ClearObjects()
```

---

### ReleaseGhostEntity

**Purpose**

Removes the ghost entity used for previewing placements.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
-- Remove the placement preview entity
local result = tool:ReleaseGhostEntity()
```

---
