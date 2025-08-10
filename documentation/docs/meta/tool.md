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

The returned table includes:

* `Mode`: `nil`
* `SWEP`: `nil`
* `Owner`: `nil`
* `ClientConVar`: `{}`
* `ServerConVar`: `{}`
* `Objects`: `{}`
* `Stage`: `0`
* `Message`: `L("start")`
* `LastMessage`: `0`
* `AllowedCVar`: `0`

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

Client-side, every entry in `ClientConVar` becomes a persistent
convar named `<mode>_<cvar>` with its default value.

Server-side, a convar named `toolmode_allow_<mode>` is created with a
default value of `1` and stored in `self.AllowedCVar`.

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

### UpdateData

**Purpose**

Placeholder for updating tool data. Override in specific tools.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:UpdateData()
    self.Stage = 1
end
```

---

### FreezeMovement

**Purpose**

Placeholder to freeze player movement while using the tool.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:FreezeMovement()
    return true -- stop movement
end
```

---

### DrawHUD

**Purpose**

Draws custom HUD information for the tool.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `None`: This function does not return a value.

**Example Usage**

```lua
function TOOL:DrawHUD()
    draw.SimpleText("Using tool", "DermaDefault", 8, 8, color_white)
end
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

* `default` (*number*): Value returned if the ConVar doesn't exist. Converted to a number and falling back to `0` if not provided or non-numeric.

**Realm**

`Shared`

**Returns**

* number: The numeric value of the ConVar or the provided default.

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

* boolean: `true` on the client. On the server, the value of `self.AllowedCVar`.

**Example Usage**

```lua
-- Gate tool usage behind an admin check
function TOOL:Allowed()
    if CLIENT then return true end
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

Internally it retrieves `self:GetSWEP().Owner` and falls back to
`self:GetOwner()` if that is unavailable.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* Player: Owner of the tool or `nil` if unavailable.

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
tool:CheckObjects()
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
tool:ClearObjects()
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
tool:ReleaseGhostEntity()
```

---
