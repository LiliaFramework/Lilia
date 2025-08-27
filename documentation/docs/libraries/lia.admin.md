# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library (`lia.administrator`) provides a comprehensive, hierarchical permission and user group management system for the Lilia framework. It serves as the core authorization system, handling everything from basic tool usage permissions to complex administrative operations.

### Core Architecture

The system is built around three fundamental concepts:

1. **Usergroups**: Hierarchical groups that users belong to (`user`, `admin`, `superadmin`)
2. **Privileges**: Individual permissions that can be assigned to usergroups
3. **Inheritance**: Child groups inherit all privileges from their parent groups

### Key Features

#### Hierarchical Permission System
- **Three-tier Structure**: `user` (level 1) → `admin` (level 2) → `superadmin` (level 3)
- **Custom Groups**: Unlimited custom usergroups with flexible inheritance
- **Dynamic Inheritance**: Groups can inherit from any existing group, creating complex permission trees

#### CAMI Integration
- **Full Compatibility**: Implements the CAMI (Compatibility Admin Mod Interface) standard
- **External Addon Support**: Works seamlessly with ULX, SAM, ServerGuard, and other CAMI-compliant admin mods
- **Automatic Synchronization**: Usergroup and privilege changes are automatically synchronized with CAMI

#### Dynamic Privilege Management
- **Automatic Registration**: Tools, properties, and commands are automatically registered as privileges
- **Custom Privileges**: Create custom privileges with specific access levels and categories
- **Runtime Modification**: Add or remove privileges without server restart

#### Cross-Realm Functionality
- **Shared Functions**: Core permission checking works on both client and server
- **Network Synchronization**: Admin data is automatically synchronized between server and clients
- **Client-side Validation**: Permission checks can be performed client-side for UI purposes

#### Database Integration
- **Persistent Storage**: All usergroups and privileges are stored in the database
- **Automatic Migration**: Existing configurations are preserved across server restarts
- **Bulk Operations**: Efficient database operations for large permission updates

### Technical Implementation

#### Permission Checking Flow
1. **Input Validation**: Privilege name validation and type checking
2. **Usergroup Resolution**: Determine user's current usergroup
3. **Inheritance Chain**: Walk up the inheritance tree to collect all applicable privileges
4. **Privilege Lookup**: Check if the specific privilege is granted
5. **Fallback Logic**: Default to admin-level access for unknown privileges

#### Data Synchronization
- **BigTable Networking**: Uses efficient binary serialization for large admin data transfers
- **Incremental Updates**: Only changed data is sent to clients
- **Ready State Management**: Ensures clients receive data only when ready

#### Hook System Integration
- **Privilege Registration**: `OnPrivilegeRegistered` and `OnPrivilegeUnregistered` hooks
- **Group Management**: `OnUsergroupCreated`, `OnUsergroupRemoved`, `OnUsergroupRenamed` hooks
- **Permission Changes**: `OnUsergroupPermissionsChanged` hook

### Performance Considerations

- **Cached Lookups**: Privilege levels are cached for fast access checking
- **Lazy Loading**: Privilege categories are computed on-demand
- **Bulk Database Operations**: Multiple changes are batched for efficiency
- **Memory Optimization**: Uses weak references for network-ready state tracking

### Security Features

- **Server-side Validation**: All privilege checks are validated server-side
- **SQL Injection Protection**: All database queries use parameterized statements
- **Access Level Verification**: Minimum access levels prevent privilege escalation
- **Logging Integration**: All admin actions are logged for audit purposes

The administrator library is the backbone of Lilia's permission system, providing a robust, extensible foundation that can scale from simple role-based access control to complex administrative hierarchies.

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
    -- Show admin chat UI
    drawAdminChat()
end
```

---

### lia.administrator.save

**Purpose**

Saves all usergroups and privileges to the database and optionally synchronizes with clients.

**Parameters**

* `noNetwork` (*boolean*, optional): If true, skips synchronizing the updated admin data to all connected clients after saving. Defaults to false.

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Save admin data and sync to clients
lia.administrator.save()

-- Save admin data without syncing to clients
lia.administrator.save(true)
```

---

### lia.administrator.registerPrivilege

**Purpose**

Registers a new privilege in the admin system, assigning it to all usergroups that meet the minimum access level.

**Parameters**

* `priv` (*table*): A table describing the privilege with the following structure:
  * `ID` (*string*, required): Unique identifier used when checking permissions.
  * `Name` (*string*, optional): Localized name shown in privilege lists. If not provided, the ID will be used as the display name.
  * `MinAccess` (*string*, optional): The minimum usergroup required to have this privilege. Valid values are `"user"`, `"admin"`, or `"superadmin"`. Defaults to `"user"`.
  * `Category` (*string*, optional): The category this privilege belongs to for organizational purposes.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Register a new privilege "canFly" for admins and above
lia.administrator.registerPrivilege({
    ID = "canFly",
    Name = "Can Fly",
    MinAccess = "admin",
    Category = "Fun"
})

-- Register a superadmin-only privilege with custom category
lia.administrator.registerPrivilege({
    ID = "serverShutdown",
    Name = "Server Shutdown",
    MinAccess = "superadmin",
    Category = "Server Management"
})

-- Register a user-level privilege for basic tools
lia.administrator.registerPrivilege({
    ID = "useBasicTools",
    Name = "Basic Tool Usage",
    MinAccess = "user",
    Category = "Tools"
})

-- Register a privilege with localized name
lia.administrator.registerPrivilege({
    ID = "teleportPlayers",
    Name = L("teleportPrivilege"),
    MinAccess = "admin",
    Category = "Teleportation"
})
```

---

### lia.administrator.unregisterPrivilege

**Purpose**

Unregisters a privilege from the admin system, removing it from all usergroups.

**Parameters**

* `name` (*string*): The name of the privilege to unregister.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Remove the "canFly" privilege from all groups
lia.administrator.unregisterPrivilege("canFly")
```

---

### lia.administrator.applyInheritance

**Purpose**

Applies inheritance to a usergroup, copying privileges from its parent group and ensuring minimum privileges are granted.

**Parameters**

* `groupName` (*string*): The name of the usergroup to apply inheritance to.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Apply inheritance to the "moderator" group after changing its parent
lia.administrator.applyInheritance("moderator")
```

---

### lia.administrator.load

**Purpose**

Loads usergroups and privileges from the database, ensures default groups exist, applies inheritance, and synchronizes with CAMI if available.

**Parameters**

* `nil`

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Load all admin groups and privileges on server startup
lia.administrator.load()
```

---

### lia.administrator.createGroup

**Purpose**

Creates a new usergroup with the specified name and info, applies inheritance, and registers it with CAMI.

**Parameters**

* `groupName` (*string*): The name of the new usergroup. Must be unique and not one of the default groups (`user`, `admin`, `superadmin`).
* `info` (*table*, optional): Table containing group configuration with the following optional structure:
  * `_info` (*table*): Group metadata containing:
    * `inheritance` (*string*): The parent group this group inherits privileges from. Defaults to `"user"`.
    * `types` (*table*): Array of strings representing group types/categories (e.g., `{"Staff"}`, `{"VIP"}`).

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Create a new "moderator" group that inherits from "user"
lia.administrator.createGroup("moderator", {
    _info = {
        inheritance = "user",
        types = {"Staff"}
    }
})

-- Create a "vip" group that inherits from "user" with VIP type
lia.administrator.createGroup("vip", {
    _info = {
        inheritance = "user",
        types = {"VIP"}
    }
})

-- Create an "eventstaff" group with custom privileges
lia.administrator.createGroup("eventstaff", {
    _info = {
        inheritance = "user",
        types = {"Staff", "Event"}
    }
})
```

---

### lia.administrator.removeGroup

**Purpose**

Removes a usergroup from the admin system, unregisters it from CAMI, and saves the changes.

**Parameters**

* `groupName` (*string*): The name of the usergroup to remove.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Remove the "moderator" group
lia.administrator.removeGroup("moderator")
```

---

### lia.administrator.renameGroup

**Purpose**

Renames an existing usergroup, updates inheritance, and synchronizes with CAMI.

**Parameters**

* `oldName` (*string*): The current name of the usergroup.
* `newName` (*string*): The new name for the usergroup.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Rename the "moderator" group to "helper"
lia.administrator.renameGroup("moderator", "helper")
```

---

### lia.administrator.addPermission

**Purpose**

Adds a permission/privilege to a usergroup and saves the change.

**Parameters**

* `groupName` (*string*): The name of the usergroup.
* `permission` (*string*): The privilege to add.
* `silent` (*boolean*, optional): If true, suppresses network updates.

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Give the "moderator" group the "kick" privilege
lia.administrator.addPermission("moderator", "kick")
```

---

### lia.administrator.removePermission

**Purpose**

Removes a permission/privilege from a usergroup and saves the change.

**Parameters**

* `groupName` (*string*): The name of the usergroup.
* `permission` (*string*): The privilege to remove.
* `silent` (*boolean*, optional): If true, suppresses network updates.

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Remove the "ban" privilege from the "moderator" group
lia.administrator.removePermission("moderator", "ban")
```

---

### lia.administrator.sync

**Purpose**

Synchronizes admin privileges, privilege meta, and groups to a specific client or all clients.

**Parameters**

* `c` (*Player*, optional): The player to sync to. If nil, syncs to all players.

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Sync admin data to a specific player
lia.administrator.sync(somePlayer)

-- Sync admin data to all players
lia.administrator.sync()
```

---

### lia.administrator.setPlayerUsergroup

**Purpose**

Sets a player's usergroup and notifies CAMI of the change.

**Parameters**

* `ply` (*Player*): The player whose usergroup to set.
* `newGroup` (*string*): The new usergroup name.
* `source` (*string*, optional): The source of the change (for CAMI).

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Set a player to the "admin" group
lia.administrator.setPlayerUsergroup(targetPlayer, "admin", "Console")
```

---

### lia.administrator.setSteamIDUsergroup

**Purpose**

Sets the usergroup for a player by SteamID, updating both online and offline players, and notifies CAMI.

**Parameters**

* `steamId` (*string*): The SteamID of the player.
* `newGroup` (*string*): The new usergroup name.
* `source` (*string*, optional): The source of the change (for CAMI).

**Returns**

* `nil`

**Realm**

Server.

**Example Usage**

```lua
-- Set a SteamID to the "vip" group
lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456", "vip", "Admin Panel")
```

---

### lia.administrator.execCommand

**Purpose**

Executes an admin command as a chat command, such as kick, ban, mute, etc.

**Parameters**

* `cmd` (*string*): The command to execute (e.g., `"kick"`, `"ban"`, `"mute"`).
* `victim` (*Player|string*): The player entity or SteamID to target.
* `dur` (*number*, optional): Duration for timed commands (e.g., ban, mute).
* `reason` (*string*, optional): Reason for the command.

**Returns**

* `success` (*boolean*): True if the command was executed, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
-- Kick a player for "AFK"
lia.administrator.execCommand("kick", targetPlayer, nil, "AFK")

-- Ban a player for 60 minutes for "Cheating"
lia.administrator.execCommand("ban", "STEAM_0:1:123456", 60, "Cheating")
```

---

### lia.administrator.serverExecCommand

**Purpose**

Executes an admin command server-side on a target player, providing server-side execution with proper validation and logging.

**Parameters**

* `cmd` (*string*): The command to execute (e.g., `"kick"`, `"ban"`, `"mute"`, `"slay"`, `"bring"`, `"goto"`, `"jail"`, `"cloak"`, `"god"`, `"ignite"`, `"strip"`, `"respawn"`, `"blind"`).
* `victim` (*Player|string*): The player entity or SteamID to target.
* `dur` (*number*, optional): Duration for timed commands (e.g., ban, mute, jail, ignite).
* `reason` (*string*, optional): Reason for the command execution.
* `admin` (*Player*): The admin player executing the command (must have "basicAdminFunctions" privilege).

**Returns**

* `success` (*boolean*): True if the command was executed successfully, false otherwise.

**Realm**

Server.

**Supported Commands**

- **kick**: Kicks the player from the server
- **ban**: Bans the player (supports duration and reason)
- **unban**: Unbans a player by SteamID
- **mute**: Voice mutes the player
- **unmute**: Removes voice mute from the player
- **gag**: Prevents the player from using voice chat
- **ungag**: Allows the player to use voice chat again
- **freeze**: Freezes the player in place
- **unfreeze**: Unfreezes the player
- **slay**: Kills the player instantly
- **kill**: Kills the player and logs the action
- **bring**: Teleports the player to the admin's location
- **goto**: Teleports the admin to the player's location
- **return**: Returns players to their previous positions (after bring/goto)
- **jail**: Locks and freezes the player
- **unjail**: Releases the player from jail
- **cloak**: Makes the player invisible
- **uncloak**: Makes the player visible again
- **god**: Enables god mode for the player
- **ungod**: Disables god mode for the player
- **ignite**: Sets the player on fire
- **extinguish/unignite**: Extinguishes the player
- **strip**: Removes all weapons from the player
- **respawn**: Respawns the player
- **blind**: Blinds the player (black screen)
- **unblind**: Removes blindness from the player

**Example Usage**

```lua
-- Kick a player for spamming
lia.administrator.serverExecCommand("kick", targetPlayer, nil, "Spamming", LocalPlayer())

-- Ban a player for 60 minutes for cheating
lia.administrator.serverExecCommand("ban", targetPlayer, 60, "Cheating", LocalPlayer())

-- Kill a player
lia.administrator.serverExecCommand("slay", targetPlayer, nil, nil, LocalPlayer())

-- Freeze a player for 30 seconds
lia.administrator.serverExecCommand("freeze", targetPlayer, 30, "Investigation", LocalPlayer())
```

**Notes**

- Requires the admin to have the "basicAdminFunctions" privilege
- Automatically logs admin actions to the database
- Provides proper notifications to both admin and target
- Supports both Player entities and SteamID strings for targeting
- Includes comprehensive error handling and validation

---

### getPrivilegeCategory

**Purpose**

Computes the category for a privilege on-demand by checking various sources instead of storing it persistently.

**Parameters**

* `privilegeName` (*string*): The name/ID of the privilege.

**Returns**

* `string`: The category name for the privilege.

**Realm**

Shared.

**Category Logic**

The function determines privilege categories through the following hierarchy:
1. **Custom Categories**: Checks `lia.administrator.privilegeCategories[privilegeName]`
2. **Command Categories**: Checks if the privilege matches a command in `lia.command.list`
3. **Module Categories**: Checks module-defined privileges
4. **CAMI Categories**: Uses CAMI's category system if available
5. **Pattern-based Categories**:
   - Tool privileges (`tool_*`) → "categoryStaffTools"
   - Property privileges (`property_*`) → "categoryStaffManagement"
   - Specific patterns for ServerGuard, PAC3, SAM, simfphys, etc.

**Example Usage**

```lua
-- Get category for a tool privilege
local category = getPrivilegeCategory("tool_weld")
print(category) -- Output: "categoryStaffTools"

-- Get category for a custom privilege
local category = getPrivilegeCategory("customAdminPower")
print(category) -- Output: "unassigned" (if no category found)
```

---

## Internal Structures and Functions

The administrator library uses several internal data structures and helper functions that are essential for understanding how the permission system works.

### Data Structures

#### lia.administrator.groups
**Structure**: Table containing all usergroups indexed by group name.

**Example Structure**:
```lua
lia.administrator.groups = {
    ["user"] = {
        _info = {
            inheritance = "user",
            types = {}
        },
        -- privilege_name = true/false
        tool_remover = true,
    },
    ["admin"] = {
        _info = {
            inheritance = "user",
            types = {"Staff"}
        },
        manageUsergroups = true,
        ban = true,
        kick = true
        -- ... other privileges
    }
}
```

#### lia.administrator.privileges
**Structure**: Table mapping privilege IDs to their minimum required access level.

**Example Structure**:
```lua
lia.administrator.privileges = {
    ["kick"] = "admin",
    ["ban"] = "admin",
    ["manageUsergroups"] = "superadmin",
    ["tool_weld"] = "user",
    ["canFly"] = "admin"
}
```

#### lia.administrator.DefaultGroups
**Structure**: Table defining the default group hierarchy levels.

**Structure**:
```lua
lia.administrator.DefaultGroups = {
    user = 1,
    admin = 2,
    superadmin = 3
}
```

### Internal Helper Functions

#### getGroupLevel(group)
**Purpose**: Calculates the numeric level of a usergroup based on the inheritance chain.

**Parameters**:
* `group` (*string*): The name of the usergroup to check.

**Returns**:
* `number`: The numeric level of the group (1=user, 2=admin, 3=superadmin).

#### shouldGrant(group, minAccess)
**Purpose**: Determines if a usergroup should be granted a privilege based on the minimum access level.

**Parameters**:
* `group` (*string*): The name of the usergroup.
* `minAccess` (*string*): The minimum access level required.

**Returns**:
* `boolean`: True if the group meets or exceeds the minimum access level.

#### rebuildPrivileges()
**Purpose**: Rebuilds the privilege lookup table by scanning all groups and determining the minimum access level for each privilege.

**Parameters**: None

**Returns**: None

**Notes**: This function is called automatically when groups are modified and ensures that the privilege system remains consistent.

### Privilege Registration System

The administrator library automatically registers privileges for:

1. **Tools**: All Garry's Mod tools are automatically registered as `tool_<toolname>` privileges
2. **Properties**: All map properties are registered as `property_<propertyname>` privileges
3. **Commands**: Lilia commands are automatically registered based on their privilege requirements
4. **Custom Privileges**: Can be registered using `lia.administrator.registerPrivilege()`

### CAMI Integration

The administrator library includes full CAMI (Compatibility Admin Mod Interface) support:

- **Automatic Registration**: Usergroups and privileges are registered with CAMI when created
- **Inheritance Sync**: Group inheritance is synchronized with CAMI
- **SteamID Support**: Player usergroup changes are signaled to CAMI for external addon compatibility
- **Bootstrap**: Existing CAMI usergroups and privileges are imported on load

This ensures compatibility with external admin addons that use the CAMI standard.

