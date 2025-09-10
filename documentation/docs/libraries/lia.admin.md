# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library (`lia.administrator`) provides a comprehensive, hierarchical permission and user group management system for the Lilia framework. It serves as the core authorization system, handling everything from basic tool usage permissions to complex administrative operations.

---

### lia.administrator.hasAccess

**Purpose**

Checks if a player or usergroup has access to a specific privilege.

**Parameters**

* `ply` (*Player|string*): The player entity or usergroup name to check.
* `privilege` (*string*): The privilege to check access for.

**Returns**

* `hasAccess` (*boolean*): True if the player/usergroup has the privilege, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if a player has the "manageUsergroups" privilege
if lia.administrator.hasAccess(ply, "manageUsergroups") then
    print(ply:Nick() .. " can manage usergroups!")
end

-- Check if the "admin" group has the "ban" privilege
if lia.administrator.hasAccess("admin", "ban") then
    print("Admins can ban players.")
end

-- Check privilege access in a command function
hook.Add("PlayerSay", "CheckAdminCommand", function(ply, text)
    if string.sub(text, 1, 5) == "!kick" then
        if not lia.administrator.hasAccess(ply, "kick") then
            ply:ChatPrint("You don't have permission to kick players!")
            return false
        end
        -- Process kick command
    end
end)

-- Check tool usage permission
hook.Add("CanTool", "CheckToolPermissions", function(ply, trace, tool)
    local privilege = "tool_" .. tool
    if not lia.administrator.hasAccess(ply, privilege) then
        ply:ChatPrint("You don't have permission to use this tool!")
        return false
    end
end)

-- Conditional feature access
if lia.administrator.hasAccess(LocalPlayer(), "seeAdminChat") then
    drawAdminChat()
end
```

---

### lia.administrator.registerPrivilege

**Purpose**

Registers a new privilege with the administrator system.

**Parameters**

* `priv` (*table*): The privilege data table containing ID, Name, MinAccess, and Category.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Register a basic privilege
lia.administrator.registerPrivilege({
    Name = "Access to Admin Panel",
    ID = "adminPanel",
    MinAccess = "admin",
    Category = "Administration"
})

-- Register a tool privilege
lia.administrator.registerPrivilege({
    Name = "Use Advanced Duplicator",
    ID = "tool_adv_duplicator",
    MinAccess = "admin",
    Category = "Tools"
})

-- Register a command privilege
lia.administrator.registerPrivilege({
    Name = "Access to Kick Command",
    ID = "command_kick",
    MinAccess = "admin",
    Category = "Commands"
})

-- Register a custom module privilege
lia.administrator.registerPrivilege({
    Name = "Manage Custom Module",
    ID = "customModule_manage",
    MinAccess = "superadmin",
    Category = "Custom Module"
})
```

---

### lia.administrator.unregisterPrivilege

**Purpose**

Removes a privilege from the administrator system.

**Parameters**

* `id` (*string*): The ID of the privilege to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a privilege
lia.administrator.unregisterPrivilege("oldPrivilege")

-- Remove a tool privilege
lia.administrator.unregisterPrivilege("tool_old_tool")

-- Remove a command privilege
lia.administrator.unregisterPrivilege("command_oldCommand")
```

---

### lia.administrator.createGroup

**Purpose**

Creates a new usergroup with specified inheritance and permissions.

**Parameters**

* `groupName` (*string*): The name of the group to create.
* `info` (*table*): Optional table containing group information with _info field.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Create a basic usergroup
lia.administrator.createGroup("moderator", {
    _info = {
        inheritance = "user",
        types = {"Staff"}
    }
})

-- Create a custom usergroup with specific settings
lia.administrator.createGroup("vip", {
    _info = {
        inheritance = "user",
        types = {"VIP", "User"}
    }
})

-- Create a staff usergroup
lia.administrator.createGroup("staff", {
    _info = {
        inheritance = "admin",
        types = {"Staff"}
    }
})
```

---

### lia.administrator.removeGroup

**Purpose**

Removes a usergroup from the administrator system.

**Parameters**

* `groupName` (*string*): The name of the group to remove.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Remove a custom usergroup
lia.administrator.removeGroup("moderator")

-- Remove a VIP group
lia.administrator.removeGroup("vip")

-- Note: Cannot remove base groups (user, admin, superadmin)
lia.administrator.removeGroup("user") -- This will error
```

---

### lia.administrator.renameGroup

**Purpose**

Renames an existing usergroup.

**Parameters**

* `oldName` (*string*): The current name of the group.
* `newName` (*string*): The new name for the group.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Rename a usergroup
lia.administrator.renameGroup("moderator", "mod")

-- Rename a VIP group
lia.administrator.renameGroup("vip", "premium")

-- Note: Cannot rename base groups
lia.administrator.renameGroup("user", "player") -- This will error
```

---

### lia.administrator.applyInheritance

**Purpose**

Applies inheritance rules to a usergroup, copying permissions from parent groups.

**Parameters**

* `groupName` (*string*): The name of the group to apply inheritance to.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Apply inheritance to a group
lia.administrator.applyInheritance("moderator")

-- This will copy all permissions from the parent group
-- as defined in the group's _info.inheritance field
```

---

### lia.administrator.load

**Purpose**

Loads the administrator system from the database.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Load the administrator system
lia.administrator.load()

-- This is typically called during gamemode initialization
-- to restore saved usergroups and privileges from the database
```

---

### lia.administrator.save

**Purpose**

Saves the current administrator system state to the database.

**Parameters**

* `noNetwork` (*boolean*): Optional parameter to skip network synchronization.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Save administrator data
lia.administrator.save()

-- Save without network sync
lia.administrator.save(true)

-- This is called automatically when groups or privileges are modified
```

---

### lia.administrator.addPermission

**Purpose**

Adds a permission to a usergroup.

**Parameters**

* `groupName` (*string*): The name of the group to add permission to.
* `permission` (*string*): The permission to add.
* `silent` (*boolean*): Optional parameter to skip logging.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add a permission to a group
lia.administrator.addPermission("moderator", "kick")

-- Add a tool permission
lia.administrator.addPermission("moderator", "tool_remover")

-- Add silently (no logging)
lia.administrator.addPermission("moderator", "mute", true)
```

---

### lia.administrator.removePermission

**Purpose**

Removes a permission from a usergroup.

**Parameters**

* `groupName` (*string*): The name of the group to remove permission from.
* `permission` (*string*): The permission to remove.
* `silent` (*boolean*): Optional parameter to skip logging.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Remove a permission from a group
lia.administrator.removePermission("moderator", "kick")

-- Remove a tool permission
lia.administrator.removePermission("moderator", "tool_remover")

-- Remove silently (no logging)
lia.administrator.removePermission("moderator", "mute", true)
```

---

### lia.administrator.sync

**Purpose**

Synchronizes administrator data with connected clients.

**Parameters**

* `client` (*Player*): Optional specific client to sync with.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Sync with all clients
lia.administrator.sync()

-- Sync with specific client
lia.administrator.sync(ply)

-- This is called automatically when data changes
```

---

### lia.administrator.setPlayerUsergroup

**Purpose**

Sets a player's usergroup.

**Parameters**

* `ply` (*Player*): The player to set usergroup for.
* `newGroup` (*string*): The new usergroup name.
* `source` (*string*): Optional source identifier for logging.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set player usergroup
lia.administrator.setPlayerUsergroup(ply, "moderator")

-- Set with source tracking
lia.administrator.setPlayerUsergroup(ply, "admin", "console")

-- Set from command
lia.administrator.setPlayerUsergroup(target, "vip", "adminCommand")
```

---

### lia.administrator.setSteamIDUsergroup

**Purpose**

Sets a usergroup for a player by their SteamID.

**Parameters**

* `steamId` (*string*): The SteamID of the player.
* `newGroup` (*string*): The new usergroup name.
* `source` (*string*): Optional source identifier for logging.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set usergroup by SteamID
lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456", "moderator")

-- Set with source tracking
lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456", "admin", "console")

-- Set from database operation
lia.administrator.setSteamIDUsergroup(steamID, "vip", "database")
```

---

### lia.administrator.serverExecCommand

**Purpose**

Executes a server-side administrative command.

**Parameters**

* `cmd` (*string*): The command to execute.
* `victim` (*Player|string*): The target player or SteamID.
* `dur` (*number*): Optional duration for timed commands.
* `reason` (*string*): Optional reason for the command.
* `admin` (*Player*): The admin executing the command.

**Returns**

* `success` (*boolean*): True if command executed successfully, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
-- Execute kick command
lia.administrator.serverExecCommand("kick", target, nil, "Rule violation", admin)

-- Execute ban command with duration
lia.administrator.serverExecCommand("ban", target, 1440, "Cheating", admin)

-- Execute mute command
lia.administrator.serverExecCommand("mute", target, 60, "Spam", admin)

-- Execute freeze command
lia.administrator.serverExecCommand("freeze", target, 30, nil, admin)
```

---

### lia.administrator.execCommand

**Purpose**

Executes an administrative command from the client side.

**Parameters**

* `cmd` (*string*): The command to execute.
* `victim` (*Player|string*): The target player or SteamID.
* `dur` (*number*): Optional duration for timed commands.
* `reason` (*string*): Optional reason for the command.

**Returns**

* `success` (*boolean*): True if command executed successfully, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Execute kick command from client
lia.administrator.execCommand("kick", target, nil, "Rule violation")

-- Execute ban command with duration
lia.administrator.execCommand("ban", target, 1440, "Cheating")

-- Execute mute command
lia.administrator.execCommand("mute", target, 60, "Spam")

-- Execute freeze command
lia.administrator.execCommand("freeze", target, 30)
```
