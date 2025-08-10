# Administrator Library

This page documents the functions for working with administrator privileges and user groups.

---

## Overview

The administrator library provides a comprehensive system for managing user permissions, privileges, and access control within the Lilia framework. It handles user group management, privilege registration, access checking, and integration with external permission systems like CAMI. The library supports hierarchical permission structures and provides tools for administrative operations.

The library features include:
- **Hierarchical Permission System**: Supports user, admin, and superadmin levels with inheritance
- **CAMI Integration**: Seamless integration with the CAMI permission system for external addon compatibility
- **Dynamic Privilege Management**: Register and manage privileges with automatic access level assignment
- **Group Management**: Create custom user groups with specific permission sets
- **Access Control**: Comprehensive checking system for command and feature access
- **Privilege Validation**: Built-in validation for privilege requirements and user capabilities
- **Cross-Realm Support**: Works on both client and server sides with proper networking
- **Hook Integration**: Extensive hook system for custom permission logic and validation
- **Database Persistence**: Automatic saving and loading of permission configurations
- **Fallback Systems**: Graceful handling of missing permissions and default access levels

The library serves as the foundation for all administrative functionality within Lilia, providing a robust and extensible permission system that can be easily integrated with external administrative tools and addons.

---

### getPrivilegeCategory

**Purpose**

Computes the category for a privilege on-demand by checking various sources instead of storing it persistently.

**Parameters**

* `privilegeName` (*string*): The name/ID of the privilege.

**Returns**

* `string`: The category name for the privilege.

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
```

---

### lia.administrator.save

**Purpose**

Saves all usergroups and privileges to the database and optionally synchronizes with clients.

**Parameters**

* `noNetwork` (*boolean*, optional): If true, does not sync to clients after saving.

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

* `priv` (*table*): A table describing the privilege. Should contain:
  * `ID` (*string*): Unique identifier used when checking permissions.
  * `Name` (*string*): (Optional) Localized name shown in privilege lists. If not provided, ID will be used.
  * `MinAccess` (*string*): (Optional) The minimum usergroup required to have this privilege (default: `"user"`).
  * `Category` (*string*): (Optional) The category for the privilege.

**Returns**

* `nil`

**Realm**

Shared.

**Example Usage**

```lua
-- Register a new privilege "canFly" for admins and above
lia.administrator.registerPrivilege({
    ID = "canFly",
    MinAccess = "admin",
    Category = "Fun"
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

* `groupName` (*string*): The name of the new usergroup.
* `info` (*table*): (Optional) Table containing group info, such as inheritance and types.

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

