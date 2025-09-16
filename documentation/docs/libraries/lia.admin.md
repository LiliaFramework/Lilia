# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library (`lia.administrator`) provides a comprehensive, hierarchical permission and user group management system for the Lilia framework, serving as the core authorization and access control infrastructure that governs all administrative operations and player privileges throughout the server. This library handles sophisticated permission management with support for multi-level privilege hierarchies, dynamic permission assignment, and granular access control that enables fine-tuned administrative capabilities from basic tool usage to complex server management operations. The system features advanced user group management with support for hierarchical group structures, inheritance-based permission systems, and dynamic group assignment that allows for flexible and scalable administrative organization. It includes comprehensive privilege registration with support for custom permission definitions, permission validation, and automatic privilege checking that ensures secure and consistent access control across all framework components. The library provides robust administrative command execution with support for server-side command processing, privilege verification, and secure command delegation that maintains system integrity while enabling powerful administrative capabilities. Additional features include integration with the framework's logging system for administrative action tracking, real-time permission synchronization across clients, and comprehensive administrative interfaces that provide intuitive management tools for server administrators, making it essential for maintaining secure and organized server operations while providing the flexibility needed for complex roleplay scenarios and administrative workflows.

---

### hasAccess

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

### registerPrivilege

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

### lia.administrator.applyPunishment

Applies punishment to a player by kicking and/or banning them with customizable messages.

```lua
lia.administrator.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)
```

**Parameters:**
- `client` (Player): The player to apply punishment to
- `infraction` (string): The reason for the punishment (will be inserted into the message)
- `kick` (boolean): Whether to kick the player
- `ban` (boolean): Whether to ban the player
- `time` (number, optional): Ban duration in minutes (0 = permanent ban). Defaults to 0
- `kickKey` (string, optional): Language key for kick message. Defaults to "kickedForInfraction"
- `banKey` (string, optional): Language key for ban message. Defaults to "bannedForInfraction"

**Returns:**
- None

**Description:**
This function provides a unified way to apply punishments to players. It can kick, ban, or both, with customizable messages. The function uses the Lilia localization system to format the punishment messages.

**Usage Examples:**

```lua
-- Kick a player for cheating
lia.administrator.applyPunishment(client, "usingThirdPartyCheats", true, false)

-- Ban a player permanently for hacking
lia.administrator.applyPunishment(client, "hackingInfraction", false, true, 0)

-- Kick and ban a player with custom message keys
lia.administrator.applyPunishment(client, "severeInfraction", true, true, 60, "kickedForInfractionPeriod", "bannedForInfractionPeriod")

-- Temporary ban for 24 hours
lia.administrator.applyPunishment(client, "ruleViolation", false, true, 1440)
```

**Message Formatting:**
The function uses language keys to format messages. The infraction reason is inserted into the message using string formatting:

- Default kick message: "Kicked for [infraction]"
- Default ban message: "Banned for [infraction]"
- Period messages: "[Action] for [infraction]." (with period)

**Common Language Keys:**
- `kickedForInfraction`: "Kicked for"
- `bannedForInfraction`: "Banned for"
- `kickedForInfractionPeriod`: "Kicked for %s."
- `bannedForInfractionPeriod`: "Banned for %s."

**Implementation Details:**
- Uses `lia.administrator.execCommand()` internally to execute kick/ban commands
- Automatically logs the punishment through the admin logging system
- Supports both permanent (0) and temporary bans
- Integrates with Lilia's localization system for multi-language support

**Related Functions:**
- `lia.administrator.execCommand()`: Executes administrative commands
- `lia.administrator.hasAccess()`: Checks if a player has administrative privileges


---

### unregisterPrivilege

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

### createGroup

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

### removeGroup

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

### renameGroup

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

### applyInheritance

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

### load

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

### save

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

### addPermission

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

### removePermission

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

### sync

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

### setPlayerUsergroup

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

### setSteamIDUsergroup

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

### serverExecCommand

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

### notifyAdmin

**Purpose**

Sends an admin notification to all players who have the privilege to see admin notifications.

**Parameters**

* `notification` (*string*): The notification message to send to admin players.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Send a general admin notification
lia.administrator.notifyAdmin("Server maintenance in 5 minutes")

-- Send a security alert
lia.administrator.notifyAdmin("Suspicious activity detected on the server")

-- Send a player action notification
lia.administrator.notifyAdmin("Player " .. target:Name() .. " has been banned for cheating")

-- Send a system status notification
lia.administrator.notifyAdmin("Database backup completed successfully")

-- Send a warning notification
lia.administrator.notifyAdmin("High player count detected - consider increasing server slots")
```

**Implementation Details**

- Only sends notifications to players who have the "canSeeAltingNotifications" privilege
- Uses the player's `notifyAdminLocalized` method to display the notification
- Automatically iterates through all connected players
- Integrates with the Lilia notification system for consistent UI display

**Related Functions**

- `player:notifyAdminLocalized()`: Player method for displaying localized admin notifications
- `lia.administrator.hasAccess()`: Checks if a player has the required privilege

---

### execCommand

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
