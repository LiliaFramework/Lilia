# Tool Meta

The ToolGun interacts with the world through specialized meta functions. This guide lists utilities for object manipulation and ghost entity management.

---

## Overview

Tool meta functions track hovered entities, create ghost previews, and wrap common building operations. They ensure consistent behavior across custom tools in Lilia.

---

### `Create()`

**Description:**
Creates a new tool object with default values.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* table – The newly created tool object.

**Example Usage:**
```lua
-- Create a table for a custom door tool mode
local tool = ToolGunMeta:Create()
tool.Mode = "lia_dooredit"
```

### `CreateConVars()`

**Description:**
Creates client and server ConVars for this tool.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Ensure console variables exist for configuration
tool:CreateConVars()
```

### `GetServerInfo(property)`

**Description:**
Returns the server ConVar for the given property.

**Parameters:**
* property (string) – Property name.

**Realm:**
* Shared

**Returns:**
* ConVar – The server ConVar object.

**Example Usage:**
```lua
-- Check if the server allows using this tool
local allow = tool:GetServerInfo("allow_use"):GetBool()
```

### `BuildConVarList()`

**Description:**
Returns a table of client ConVars prefixed by the tool mode.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* table – Table of convars.

**Example Usage:**
```lua
-- Get a table of client ConVars for networking
local cvars = tool:BuildConVarList()
```

### `GetClientInfo(property)`

**Description:**
Retrieves a client ConVar value as a string.

**Parameters:**
* property (string) – ConVar name without mode prefix.

**Realm:**
* Shared

**Returns:**
* string – The value stored in the ConVar.

**Example Usage:**
```lua
-- Get the client's chosen material from a ConVar
local mat = tool:GetClientInfo("material")
```

### `GetClientNumber(property, default)`

**Description:**
Retrieves a numeric client ConVar value.

**Parameters:**
* property (string) – ConVar name without mode prefix.
* default (number) – Value returned if the ConVar doesn't exist.

**Realm:**
* Shared

**Returns:**
* number – The numeric value of the ConVar.

**Example Usage:**
```lua
-- Read the numeric power setting with a fallback
local power = tool:GetClientNumber("power", 10)
```

### `Allowed()`

**Description:**
Determines whether this tool is allowed to be used.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* boolean – True if the tool is allowed.

**Example Usage:**
```lua
-- Check if the player can use the current tool
if tool:Allowed() then
    tool:GetOwner():ChatPrint("Tool is permitted!")
    hook.Run("PlayerToolPermitted", tool:GetOwner(), tool:GetMode())
else
    tool:GetOwner():ChatPrint("Tool usage blocked.")
end
```

### `Init()`

**Description:**
Placeholder for tool initialization.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Prepare the tool for use
local result = tool:Init()
```

### `GetMode()`

**Description:**
Gets the current tool mode string.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* string – Tool mode name.

**Example Usage:**
```lua
-- Retrieve the tool's active mode string
local result = tool:GetMode()
```

### `GetSWEP()`

**Description:**
Returns the SWEP associated with this tool.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* SWEP – The tool's weapon entity.

**Example Usage:**
```lua
-- Obtain the weapon entity representing this tool
local result = tool:GetSWEP()
```

### `GetOwner()`

**Description:**
Retrieves the tool owner's player object.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* Player – Owner of the tool.

**Example Usage:**
```lua
-- Reference the player who deployed the tool
local result = tool:GetOwner()
```

### `GetWeapon()`

**Description:**
Retrieves the weapon entity this tool is attached to.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* Weapon – The weapon object.

**Example Usage:**
```lua
-- Access the underlying weapon object
local result = tool:GetWeapon()
```

### `LeftClick()`

**Description:**
Handles the left-click action. Override for custom behavior.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* boolean – False by default.

**Example Usage:**
```lua
-- Attempt the primary tool action
local result = tool:LeftClick()
```

### `RightClick()`

**Description:**
Handles the right-click action. Override for custom behavior.

**Parameters:**
* None

**Realm:**
* Shared

**Returns:**
* boolean – False by default.

**Example Usage:**
```lua
-- Attempt the secondary tool action
local result = tool:RightClick()
```

### `Reload()`

**Description:**
Clears stored objects when the tool reloads.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Clear saved objects when reloading the tool
local result = tool:Reload()
```

### `Deploy()`

**Description:**
Called when the tool is equipped. Releases ghost entity.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Equip the tool and spawn its ghost entity
local result = tool:Deploy()
```

### `Holster()`

**Description:**
Called when the tool is holstered. Releases ghost entity.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Unequip the tool and remove its ghost entity
local result = tool:Holster()
```

### `Think()`

**Description:**
Called every tick; releases ghost entities by default.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Run per-tick logic for the active tool
local result = tool:Think()
```

### `CheckObjects()`

**Description:**
Validates stored objects and clears them if invalid.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Validate all stored objects each tick
local result = tool:CheckObjects()
```

### `ClearObjects()`

**Description:**
Removes all stored objects from the tool.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Remove any objects the tool is storing
local result = tool:ClearObjects()
```

### `ReleaseGhostEntity()`

**Description:**
Removes the ghost entity used for previewing placements.

**Parameters:**
* None

**Realm:**
* Shared
**Returns:**
* None – This function does not return a value.

**Example Usage:**
```lua
-- Remove the placement preview entity
local result = tool:ReleaseGhostEntity()
```

