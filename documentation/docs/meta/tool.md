# Tool Meta

This page documents methods available on the `Tool` meta table, representing tool gun tools in the Lilia framework.

---

## Overview

The `Tool` meta table provides comprehensive tool gun functionality including creation, configuration, networking, interaction handling, and object management. These methods form the foundation for creating custom tools within the Lilia framework, supporting both server-side logic and client-side interface management for Garry's Mod's tool gun system.

---

### toolMeta:Create

**Purpose**

Creates a new tool instance with default properties.

**Parameters**

*None.*

**Returns**

* `tool` (*Tool*): The new tool instance.

**Realm**

Shared.

**Example Usage**

```lua
local function createCustomTool()
    local tool = lia.meta.tool:Create()
    tool.Mode = "custom_tool"
    tool.SWEP = "gmod_tool"
    tool.Owner = nil
    tool.ClientConVar = {
        size = "1",
        color = "255 255 255"
    }
    tool.ServerConVar = {}
    tool.Objects = {}
    tool.Stage = 0
    tool.Message = "Click to place object"
    tool.LastMessage = 0
    tool.AllowedCVar = 0
    return tool
end

concommand.Add("create_tool", function(ply)
    local tool = createCustomTool()
    print("Created tool: " .. tool.Mode)
end)
```

---

### toolMeta:CreateConVars

**Purpose**

Creates console variables for the tool on both client and server.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolConVars(tool)
    tool:CreateConVars()
    print("Created console variables for tool: " .. tool:GetMode())
end

concommand.Add("setup_tool_convars", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.ClientConVar = {
        size = "1",
        color = "255 255 255"
    }
    setupToolConVars(tool)
end)
```

---

### toolMeta:UpdateData

**Purpose**

Updates tool data (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolDataUpdate(tool)
    function tool:UpdateData()
        print("Updating data for tool: " .. self:GetMode())
        -- Custom data update logic here
    end
end

concommand.Add("setup_tool_data", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "data_tool"
    setupToolDataUpdate(tool)
end)
```

---

### toolMeta:FreezeMovement

**Purpose**

Freezes player movement (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolMovementFreeze(tool)
    function tool:FreezeMovement()
        if IsValid(self:GetOwner()) then
            self:GetOwner():SetMoveType(MOVETYPE_NONE)
            print("Froze movement for tool: " .. self:GetMode())
        end
    end
end

concommand.Add("setup_tool_freeze", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "freeze_tool"
    setupToolMovementFreeze(tool)
end)
```

---

### toolMeta:DrawHUD

**Purpose**

Draws HUD elements for the tool (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Client.

**Example Usage**

```lua
local function setupToolHUD(tool)
    function tool:DrawHUD()
        local owner = self:GetOwner()
        if IsValid(owner) and owner == LocalPlayer() then
            draw.SimpleText("Tool: " .. self:GetMode(), "DermaDefault", 10, 10, Color(255, 255, 255))
        end
    end
end

concommand.Add("setup_tool_hud", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "hud_tool"
    setupToolHUD(tool)
end)
```

---

### toolMeta:GetServerInfo

**Purpose**

Gets server-side console variable information.

**Parameters**

* `property` (*string*): The property name to get.

**Returns**

* `convar` (*ConVar*): The console variable.

**Realm**

Shared.

**Example Usage**

```lua
local function getToolServerInfo(tool, property)
    local convar = tool:GetServerInfo(property)
    if convar then
        print("Server info for " .. property .. ": " .. convar:GetString())
        return convar
    else
        print("No server info found for: " .. property)
        return nil
    end
end

concommand.Add("get_tool_server_info", function(ply, cmd, args)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool:CreateConVars()
    local property = args[1] or "size"
    getToolServerInfo(tool, property)
end)
```

---

### toolMeta:BuildConVarList

**Purpose**

Builds a list of console variables for the tool.

**Parameters**

*None.*

**Returns**

* `convars` (*table*): Table of console variables.

**Realm**

Shared.

**Example Usage**

```lua
local function displayToolConVars(tool)
    local convars = tool:BuildConVarList()
    print("Console variables for " .. tool:GetMode() .. ":")
    for name, default in pairs(convars) do
        print("  " .. name .. " = " .. default)
    end
    return convars
end

concommand.Add("list_tool_convars", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.ClientConVar = {
        size = "1",
        color = "255 255 255"
    }
    tool:CreateConVars()
    displayToolConVars(tool)
end)
```

---

### toolMeta:GetClientInfo

**Purpose**

Gets client-side console variable information.

**Parameters**

* `property` (*string*): The property name to get.

**Returns**

* `value` (*string*): The console variable value.

**Realm**

Shared.

**Example Usage**

```lua
local function getToolClientInfo(tool, property)
    local value = tool:GetClientInfo(property)
    print("Client info for " .. property .. ": " .. value)
    return value
end

concommand.Add("get_tool_client_info", function(ply, cmd, args)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.Owner = ply
    local property = args[1] or "size"
    getToolClientInfo(tool, property)
end)
```

---

### toolMeta:GetClientNumber

**Purpose**

Gets a numeric client-side console variable value.

**Parameters**

* `property` (*string*): The property name to get.
* `default` (*number|nil*): Default value if not found.

**Returns**

* `value` (*number*): The numeric console variable value.

**Realm**

Shared.

**Example Usage**

```lua
local function getToolClientNumber(tool, property, default)
    local value = tool:GetClientNumber(property, default)
    print("Client number for " .. property .. ": " .. value)
    return value
end

concommand.Add("get_tool_client_number", function(ply, cmd, args)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.Owner = ply
    local property = args[1] or "size"
    local default = tonumber(args[2]) or 1
    getToolClientNumber(tool, property, default)
end)
```

---

### toolMeta:Allowed

**Purpose**

Checks if the tool is allowed to be used.

**Parameters**

*None.*

**Returns**

* `allowed` (*boolean*): True if the tool is allowed.

**Realm**

Shared.

**Example Usage**

```lua
local function checkToolAllowed(tool)
    if tool:Allowed() then
        print("Tool " .. tool:GetMode() .. " is allowed!")
        return true
    else
        print("Tool " .. tool:GetMode() .. " is not allowed!")
        return false
    end
end

concommand.Add("check_tool_allowed", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool:CreateConVars()
    checkToolAllowed(tool)
end)
```

---

### toolMeta:Init

**Purpose**

Initializes the tool (placeholder for custom implementations).

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolInit(tool)
    function tool:Init()
        print("Initializing tool: " .. self:GetMode())
        -- Custom initialization logic here
    end
end

concommand.Add("setup_tool_init", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "init_tool"
    setupToolInit(tool)
end)
```

---

### toolMeta:GetMode

**Purpose**

Gets the tool's mode name.

**Parameters**

*None.*

**Returns**

* `mode` (*string*): The tool's mode name.

**Realm**

Shared.

**Example Usage**

```lua
local function displayToolMode(tool)
    local mode = tool:GetMode()
    print("Tool mode: " .. mode)
    return mode
end

concommand.Add("get_tool_mode", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    displayToolMode(tool)
end)
```

---

### toolMeta:GetSWEP

**Purpose**

Gets the tool's SWEP (weapon) entity.

**Parameters**

*None.*

**Returns**

* `swep` (*Entity*): The SWEP entity.

**Realm**

Shared.

**Example Usage**

```lua
local function displayToolSWEP(tool)
    local swep = tool:GetSWEP()
    if IsValid(swep) then
        print("Tool SWEP: " .. swep:GetClass())
        return swep
    else
        print("No SWEP found for tool")
        return nil
    end
end

concommand.Add("get_tool_swep", function(ply)
    local tool = lia.meta.tool:Create()
    tool.SWEP = ply:GetActiveWeapon()
    displayToolSWEP(tool)
end)
```

---

### toolMeta:GetOwner

**Purpose**

Gets the tool's owner (player).

**Parameters**

*None.*

**Returns**

* `owner` (*Player|nil*): The tool's owner, or nil if not found.

**Realm**

Shared.

**Notes**

This method first tries to get the owner from the tool's SWEP (self:GetSWEP().Owner), and falls back to the tool's internal Owner field if that fails.

**Example Usage**

```lua
local function displayToolOwner(tool)
    local owner = tool:GetOwner()
    if IsValid(owner) then
        print("Tool owner: " .. owner:Name())
        return owner
    else
        print("No owner found for tool")
        return nil
    end
end

concommand.Add("get_tool_owner", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Owner = ply
    displayToolOwner(tool)
end)
```

---

### toolMeta:GetWeapon

**Purpose**

Gets the tool's weapon entity.

**Parameters**

*None.*

**Returns**

* `weapon` (*Entity|nil*): The weapon entity, or nil if not found.

**Realm**

Shared.

**Notes**

This method first tries to get the weapon from the tool's SWEP (self:GetSWEP().Weapon), and falls back to the tool's internal Weapon field if that fails.

**Example Usage**

```lua
local function displayToolWeapon(tool)
    local weapon = tool:GetWeapon()
    if IsValid(weapon) then
        print("Tool weapon: " .. weapon:GetClass())
        return weapon
    else
        print("No weapon found for tool")
        return nil
    end
end

concommand.Add("get_tool_weapon", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Weapon = ply:GetActiveWeapon()
    displayToolWeapon(tool)
end)
```

---

### toolMeta:LeftClick

**Purpose**

Handles left click events for the tool.

**Parameters**

*None.*

**Returns**

* `handled` (*boolean*): True if the click was handled.

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolLeftClick(tool)
    function tool:LeftClick()
        print("Left click on tool: " .. self:GetMode())
        -- Custom left click logic here
        return true
    end
end

concommand.Add("setup_tool_left_click", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "left_click_tool"
    setupToolLeftClick(tool)
end)
```

---

### toolMeta:RightClick

**Purpose**

Handles right click events for the tool.

**Parameters**

*None.*

**Returns**

* `handled` (*boolean*): True if the click was handled.

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolRightClick(tool)
    function tool:RightClick()
        print("Right click on tool: " .. self:GetMode())
        -- Custom right click logic here
        return true
    end
end

concommand.Add("setup_tool_right_click", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "right_click_tool"
    setupToolRightClick(tool)
end)
```

---

### toolMeta:Reload

**Purpose**

Handles reload events for the tool, clearing objects by default.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolReload(tool)
    function tool:Reload()
        print("Reload on tool: " .. self:GetMode())
        self:ClearObjects()
        -- Custom reload logic here
    end
end

concommand.Add("setup_tool_reload", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "reload_tool"
    setupToolReload(tool)
end)
```

---

### toolMeta:Deploy

**Purpose**

Handles tool deployment, releasing ghost entities by default.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolDeploy(tool)
    function tool:Deploy()
        print("Deploy tool: " .. self:GetMode())
        self:ReleaseGhostEntity()
        -- Custom deploy logic here
    end
end

concommand.Add("setup_tool_deploy", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "deploy_tool"
    setupToolDeploy(tool)
end)
```

---

### toolMeta:Holster

**Purpose**

Handles tool holstering, releasing ghost entities by default.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolHolster(tool)
    function tool:Holster()
        print("Holster tool: " .. self:GetMode())
        self:ReleaseGhostEntity()
        -- Custom holster logic here
    end
end

concommand.Add("setup_tool_holster", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "holster_tool"
    setupToolHolster(tool)
end)
```

---

### toolMeta:Think

**Purpose**

Handles tool thinking, releasing ghost entities by default.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolThink(tool)
    function tool:Think()
        self:ReleaseGhostEntity()
        -- Custom think logic here
    end
end

concommand.Add("setup_tool_think", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "think_tool"
    setupToolThink(tool)
end)
```

---

### toolMeta:CheckObjects

**Purpose**

Checks if all tool objects are still valid.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function setupToolObjectCheck(tool)
    function tool:CheckObjects()
        print("Checking objects for tool: " .. self:GetMode())
        for id, obj in pairs(self.Objects) do
            if not IsValid(obj.Ent) then
                print("Object " .. id .. " is no longer valid")
            end
        end
    end
end

concommand.Add("setup_tool_object_check", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "object_check_tool"
    setupToolObjectCheck(tool)
end)
```

---

### toolMeta:ClearObjects

**Purpose**

Clears all tool objects.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function clearToolObjects(tool)
    tool:ClearObjects()
    print("Cleared objects for tool: " .. tool:GetMode())
end

concommand.Add("clear_tool_objects", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.Objects = {
        {Ent = ents.Create("prop_physics")},
        {Ent = ents.Create("prop_physics")}
    }
    clearToolObjects(tool)
end)
```

---

### toolMeta:ReleaseGhostEntity

**Purpose**

Releases the tool's ghost entity if it exists.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function releaseToolGhost(tool)
    tool:ReleaseGhostEntity()
    print("Released ghost entity for tool: " .. tool:GetMode())
end

concommand.Add("release_tool_ghost", function(ply)
    local tool = lia.meta.tool:Create()
    tool.Mode = "test_tool"
    tool.GhostEntity = ents.Create("prop_physics")
    releaseToolGhost(tool)
end)
```

---
