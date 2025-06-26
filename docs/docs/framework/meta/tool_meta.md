## Create

**Description:**
    Creates a new tool object with default values.

---

### Parameters

---

### Returns

    * table – The newly created tool object.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local tool = ToolGunMeta:Create()
    ```

## CreateConVars

**Description:**
    Creates client and server ConVars for this tool.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

### Example

    ```lua
    tool:CreateConVars()
    ```

## GetServerInfo

**Description:**
    Returns the server ConVar for the given property.

---

### Parameters

    * property (string) – Property name.

---

### Returns

    * ConVar – The server ConVar object.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local allow = tool:GetServerInfo("allow_use"):GetBool()
    ```

## BuildConVarList

**Description:**
    Returns a table of client ConVars prefixed by the tool mode.

---

### Parameters

---

### Returns

    * table – Table of convars.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local cvars = tool:BuildConVarList()
    ```

## GetClientInfo

**Description:**
    Retrieves a client ConVar value as a string.

---

### Parameters

    * property (string) – ConVar name without mode prefix.

---

### Returns

    * string – The value stored in the ConVar.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local val = tool:GetClientInfo("setting")
    ```

## GetClientNumber

**Description:**
    Retrieves a numeric client ConVar value.

---

### Parameters

    * property (string) – ConVar name without mode prefix.
    * default (number) – Value returned if the ConVar doesn't exist.

---

### Returns

    * number – The numeric value of the ConVar.

---

**Realm:**
    Shared

---

### Example

    ```lua
    local power = tool:GetClientNumber("power", 10)
    ```

## Allowed

**Description:**
    Determines whether this tool is allowed to be used.

---

### Parameters

---

### Returns

    * boolean – True if the tool is allowed.

---

**Realm:**
    Shared

---

### Example

    ```lua
    if tool:Allowed() then print("ok") end
    ```

## Init

**Description:**
    Placeholder for tool initialization.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## GetMode

**Description:**
    Gets the current tool mode string.

---

### Parameters

---

### Returns

    * string – Tool mode name.

---

**Realm:**
    Shared

---

## GetSWEP

**Description:**
    Returns the SWEP associated with this tool.

---

### Parameters

---

### Returns

    * SWEP – The tool's weapon entity.

---

**Realm:**
    Shared

---

## GetOwner

**Description:**
    Retrieves the tool owner's player object.

---

### Parameters

---

### Returns

    * Player – Owner of the tool.

---

**Realm:**
    Shared

---

## GetWeapon

**Description:**
    Retrieves the weapon entity this tool is attached to.

---

### Parameters

---

### Returns

    * Weapon – The weapon object.

---

**Realm:**
    Shared

---

## LeftClick

**Description:**
    Handles the left-click action. Override for custom behavior.

---

### Parameters

---

### Returns

    * boolean – False by default.

---

**Realm:**
    Shared

---

## RightClick

**Description:**
    Handles the right-click action. Override for custom behavior.

---

### Parameters

---

### Returns

    * boolean – False by default.

---

**Realm:**
    Shared

---

## Reload

**Description:**
    Clears stored objects when the tool reloads.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## Deploy

**Description:**
    Called when the tool is equipped. Releases ghost entity.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## Holster

**Description:**
    Called when the tool is holstered. Releases ghost entity.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## Think

**Description:**
    Called every tick; releases ghost entities by default.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## CheckObjects

**Description:**
    Validates stored objects and clears them if invalid.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## ClearObjects

**Description:**
    Removes all stored objects from the tool.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## ReleaseGhostEntity

**Description:**
    Removes the ghost entity used for previewing placements.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

