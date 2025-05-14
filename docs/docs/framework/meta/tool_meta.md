---

A custom tool class based on the Base GMOD Toolgun, designed for integration with Lilia's framework.

The `ToolGunMeta` class extends the functionality of the base GMOD Toolgun, enabling seamless integration with Lilia's files and configuration. This custom tool class provides a flexible framework for creating and managing interactive tools within Garry's Mod, specifically tailored to work with Lilia's environment and system.

The `ToolGunMeta` class is designed to work in conjunction with Lilia's file system and configuration setup. It allows for the implementation of toolguns that can be dynamically loaded and configured based on Lilia's files, offering a robust solution for extending tool functionalities in a modular way.

The `ToolGunMeta` class provides a foundation for creating custom tools that integrate smoothly with Lilia's system. Developers can extend and modify the class to fit specific needs, leveraging Lilia's configuration files to dictate tool behavior and appearance. This approach ensures that tools can be easily adapted and updated in line with Lilia's framework, providing a consistent and maintainable tool environment.

By integrating with Lilia's files, the `ToolGunMeta` class enables developers to build sophisticated tools that are fully compatible with Lilia's system, enhancing the overall gameplay experience and tool management within Garry's Mod.

---

## **toolMeta:Create**

**Description**

Creates a new tool object with default properties. Initializes the metatable and sets up various default values such as `Mode`, `SWEP`, `Owner`, `ClientConVar`, `ServerConVar`, `Objects`, `Stage`, `Message`, `LastMessage`, and `AllowedCVar`.

**Realm**

`Shared`

**Returns**

- **Table**: A new tool object with default properties.

**Example**

```lua
local tool = ToolGunMeta:Create()
tool.Mode = "builder"
```

---

## **toolMeta:CreateConVars**

**Description**

Creates client and server console variables (ConVars) for the tool based on its mode. Client ConVars are created on the client-side, while server ConVars are created on the server-side.

**Realm**

`Shared`

**Example**

```lua
tool:CreateConVars()
```

---

## **toolMeta:GetServerInfo**

**Description**

Retrieves server-side information for a given property by accessing the server ConVar associated with the tool's mode.

**Realm**

`Shared`

**Parameters**

- **property** (`String`): The name of the property to retrieve.

**Returns**

- **ConVar**: The server ConVar object.

**Example**

```lua
local allowUse = tool:GetServerInfo("allow_use"):GetBool()
```

---

## **toolMeta:BuildConVarList**

**Description**

Builds a list of client-side ConVars by appending the tool's mode prefix to each ConVar name.

**Realm**

`Shared`

**Returns**

- **Table**: A table containing the mode-prefixed ConVars.

**Example**

```lua
local convars = tool:BuildConVarList()
for k, v in pairs(convars) do
    print(k, v)
end
```

---

## **toolMeta:GetClientInfo**

**Description**

Retrieves client-side information for a given property by accessing the client ConVar associated with the tool's mode.

**Realm**

`Shared`

**Parameters**

- **property** (`String`): The name of the property to retrieve.

**Returns**

- **String**: The value of the client ConVar.

**Example**

```lua
local toolSetting = tool:GetClientInfo("setting")
print("Tool Setting:", toolSetting)
```

---

## **toolMeta:GetClientNumber**

**Description**

Retrieves a numerical value from client-side ConVars. Returns the value as a number or a default value if the ConVar does not exist.

**Realm**

`Shared`

**Parameters**

- **property** (`String`): The name of the property to retrieve.
- **default** (`float`): The default value to return if the ConVar does not exist.

**Returns**

- **Float**: The numerical value of the client ConVar.

**Example**

```lua
local toolPower = tool:GetClientNumber("power", 10)
print("Tool Power:", toolPower)
```

---

## **toolMeta:Allowed**

**Description**

Checks if the tool is allowed on the server based on the server ConVar `AllowedCVar`. Always returns `true` on the client-side.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the tool is allowed, `false` otherwise.

**Example**

```lua
if tool:Allowed() then
    print("Tool is allowed.")
else
    print("Tool is not allowed.")
end
```

---

## **toolMeta:Init**

**Description**

Placeholder for initializing the tool. Intended to be overridden if initialization logic is needed when the tool is created.

**Realm**

`Shared`

**Example**

```lua
function ToolGunMeta:Init()
    -- Custom initialization logic here
end
```

---

## **toolMeta:GetMode**

**Description**

Retrieves the current mode of the tool, which is a string representing the specific operation the tool is set to perform.

**Realm**

`Shared`

**Returns**

- **String**: The current mode of the tool.

**Example**

```lua
local mode = tool:GetMode()
print("Tool Mode:", mode)
```

---

## **toolMeta:GetSWEP**

**Description**

Retrieves the SWEP (Scripted Weapon) associated with the tool.

**Realm**

`Shared`

**Returns**

- **SWEP**: The SWEP object associated with the tool.

**Example**

```lua
local swep = tool:GetSWEP()
print("Tool SWEP:", swep:GetClass())
```

---

## **toolMeta:GetOwner**

**Description**

Retrieves the owner of the tool by accessing the SWEP's `Owner` property.

**Realm**

`Shared`

**Returns**

- **Player**: The player who owns the tool.

**Example**

```lua
local owner = tool:GetOwner()
print("Tool Owner:", owner:Nick())
```

---

## **toolMeta:GetWeapon**

**Description**

Retrieves the weapon associated with the tool by accessing the SWEP's `Weapon` property or the tool's own `Weapon` property.

**Realm**

`Shared`

**Returns**

- **Weapon**: The weapon object associated with the tool.

**Example**

```lua
local weapon = tool:GetWeapon()
print("Associated Weapon:", weapon:GetClass())
```

---

## **toolMeta:LeftClick**

**Description**

Handles the left-click action with the tool. Intended to be overridden to define custom behavior when the player left-clicks with the tool. By default, it does nothing and returns `false`.

**Realm**

`Shared`

**Returns**

- **Boolean**: `false` by default, indicating no action was taken.

**Example**

```lua
function ToolGunMeta:LeftClick(trace)
    -- Custom left-click logic here
    return true
end
```

---

## **toolMeta:RightClick**

**Description**

Handles the right-click action with the tool. Intended to be overridden to define custom behavior when the player right-clicks with the tool. By default, it does nothing and returns `false`.

**Realm**

`Shared`

**Returns**

- **Boolean**: `false` by default, indicating no action was taken.

**Example**

```lua
function ToolGunMeta:RightClick(trace)
    -- Custom right-click logic here
    return true
end
```

---

## **toolMeta:Reload**

**Description**

Handles the reload action with the tool. Clears the objects that the tool is currently manipulating when the player reloads with the tool.

**Realm**

`Shared`

**Example**

```lua
function ToolGunMeta:Reload()
    self:ClearObjects()
end
```

---

## **toolMeta:Deploy**

**Description**

Deploys the tool when the player equips it. Releases any ghost entities associated with the tool.

**Realm**

`Shared`

**Example**

```lua
function ToolGunMeta:Deploy()
    self:ReleaseGhostEntity()
    return
end
```

---

## **toolMeta:Holster**

**Description**

Holsters the tool when the player unequips it. Releases any ghost entities associated with the tool.

**Realm**

`Shared`

**Example**

```lua
function ToolGunMeta:Holster()
    self:ReleaseGhostEntity()
    return
end
```

---

## **toolMeta:Think**

**Description**

Handles the tool's "think" logic. Called periodically to perform updates. By default, it releases any ghost entities associated with the tool.

**Realm**

`Shared`

**Example**

```lua
function ToolGunMeta:Think()
    self:ReleaseGhostEntity()
end
```

---

## **toolMeta:CheckObjects**

**Description**

Checks the validity of objects the tool is manipulating. Iterates over the tool's objects and clears them if they are no longer valid, such as if the entity is no longer part of the world or is invalid.

**Realm**

`Shared`

**Example**

```lua
tool:CheckObjects()
```

---

## **toolMeta:ClearObjects**

**Description**

Clears all objects the tool is manipulating. Removes all objects from the tool's `Objects` table, effectively resetting the tool's state.

**Realm**

`Shared`

**Example**

```lua
tool:ClearObjects()
```

---

## **toolMeta:ReleaseGhostEntity**

**Description**

Releases any ghost entities associated with the tool. Removes any ghost entities the tool may be holding, ensuring that no visual artifacts remain when the tool is not actively manipulating objects.

**Realm**

`Shared`

**Example**

```lua
tool:ReleaseGhostEntity()
```

---