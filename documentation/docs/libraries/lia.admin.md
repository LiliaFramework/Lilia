# Administrator Library

Comprehensive user group and privilege management system for the Lilia framework.

---

## Overview

The administrator library provides comprehensive functionality for managing user groups, privileges,

and administrative permissions in the Lilia framework. It handles the creation, modification,

and deletion of user groups with inheritance-based privilege systems. The library operates on

both server and client sides, with the server managing privilege storage and validation while

the client provides user interface elements for administrative management. It includes integration

with CAMI (Comprehensive Administration Management Interface) for compatibility with other

administrative systems. The library ensures proper privilege inheritance, automatic privilege

registration for tools and properties, and comprehensive logging of administrative actions.

It supports both console-based and GUI-based administrative command execution with proper

permission checking and validation.

---

### applyPunishment

**Purpose**

Applies punishment actions (kick/ban) to a player based on infraction details

**When Called**

When an administrative action needs to be taken against a player for rule violations

**Parameters**

* `client` (*Player*): The player to punish
* `infraction` (*string*): Description of the infraction committed
* `kick` (*boolean*): Whether to kick the player
* `ban` (*boolean*): Whether to ban the player
* `time` (*number*): Ban duration in minutes (0 = permanent)
* `kickKey` (*string*): Language key for kick message (optional)
* `banKey` (*string*): Language key for ban message (optional)

---

### hasAccess

**Purpose**

Checks if a player or user group has access to a specific privilege

**When Called**

When permission validation is needed before allowing access to features or commands

**Parameters**

* `ply` (*Player|string*): Player entity or user group name to check
* `privilege` (*string*): The privilege identifier to check access for

---

### save

**Purpose**

Saves all administrator groups and privileges to the database and synchronizes with clients

**When Called**

When administrator data needs to be persisted to the database after changes

**Parameters**

* `noNetwork` (*boolean*): If true, skips network synchronization (optional)
* `lia.administrator.save(true)` (*unknown*): - Save without network sync
* `lia.administrator.save()` (*unknown*): - Final save with sync

---

### registerPrivilege

**Purpose**

Registers a new privilege in the administrator system with specified access requirements

**When Called**

When a new privilege needs to be added to the system for permission checking

**Parameters**

* `priv` (*table*): Privilege definition table containing:
* `ID` (*string*): Unique identifier for the privilege
* `Name` (*string*): Display name for the privilege (optional)
* `MinAccess` (*string*): Minimum access level required (default: "user")
* `Category` (*string*): Category for organizing privileges (optional)

---

### unregisterPrivilege

**Purpose**

Removes a privilege from the administrator system and all user groups

**When Called**

When a privilege is no longer needed and should be completely removed

**Parameters**

* `id` (*string*): The privilege identifier to remove

---

### applyInheritance

**Purpose**

Applies privilege inheritance from parent groups to a specific user group

**When Called**

When a user group's inheritance needs to be recalculated after changes

**Parameters**

* `groupName` (*string*): The name of the user group to apply inheritance to

---

### load

**Purpose**

Loads administrator groups and privileges from the database and initializes the system

**When Called**

During server startup or when administrator data needs to be reloaded

---

### createGroup

**Purpose**

Creates a new user group with specified inheritance and type information

**When Called**

When a new user group needs to be added to the administrator system

**Parameters**

* `groupName` (*string*): The name of the new user group
* `info` (*table*): Group configuration table containing:
* `_info` (*table*): Group metadata with inheritance and types (optional)

---

### removeGroup

**Purpose**

Removes a user group from the administrator system (cannot remove base groups)

**When Called**

When a user group is no longer needed and should be deleted

**Parameters**

* `groupName` (*string*): The name of the user group to remove

---

### renameGroup

**Purpose**

Renames an existing user group to a new name (cannot rename base groups)

**When Called**

When a user group needs to be renamed for organizational purposes

**Parameters**

* `oldName` (*string*): The current name of the user group
* `newName` (*string*): The new name for the user group

---

### notifyAdmin

**Purpose**

Sends administrative notifications to all players with the appropriate privilege

**When Called**

When administrative notifications need to be broadcast to qualified players

**Parameters**

* `notification` (*table*): Notification data to send to players

---

### addPermission

**Purpose**

Adds a permission to a specific user group

**When Called**

When a user group needs to be granted a new permission

**Parameters**

* `groupName` (*string*): The name of the user group
* `permission` (*string*): The permission identifier to add
* `silent` (*boolean*): If true, skips network synchronization (optional)

---

### removePermission

**Purpose**

Removes a permission from a specific user group

**When Called**

When a user group should no longer have a specific permission

**Parameters**

* `groupName` (*string*): The name of the user group
* `permission` (*string*): The permission identifier to remove
* `silent` (*boolean*): If true, skips network synchronization (optional)

---

### sync

**Purpose**

Synchronizes administrator data with connected clients

**When Called**

When administrator data needs to be sent to clients after changes

**Parameters**

* `c` (*Player*): Specific client to sync with (optional, syncs all if nil)

---

### setPlayerUsergroup

**Purpose**

Changes a player's user group and triggers CAMI events

**When Called**

When a player's user group needs to be changed

**Parameters**

* `ply` (*Player*): The player whose group should be changed
* `newGroup` (*string*): The new user group name
* `source` (*string*): Source identifier for CAMI events (optional)

---

### setSteamIDUsergroup

**Purpose**

Changes a Steam ID's user group and triggers CAMI events

**When Called**

When a Steam ID's user group needs to be changed (for offline players)

**Parameters**

* `steamId` (*string*): The Steam ID whose group should be changed
* `newGroup` (*string*): The new user group name
* `source` (*string*): Source identifier for CAMI events (optional)

---

### serverExecCommand

**Purpose**

Executes administrative commands on the server with permission checking

**When Called**

When administrative commands need to be executed with proper validation

**Parameters**

* `cmd` (*string*): The command to execute
* `victim` (*Player|string*): Target player or Steam ID
* `dur` (*number*): Duration parameter for timed commands (optional)
* `reason` (*string*): Reason for the command (optional)
* `admin` (*Player*): The admin executing the command

---

### execCommand

**Purpose**

Executes administrative commands on the client with hook system integration and callback support

**When Called**

When administrative commands need to be executed from the client side

**Parameters**

* `cmd` (*string*): The command to execute
* `victim` (*Player|string*): Target player or Steam ID
* `dur` (*number*): Duration parameter for timed commands (optional)
* `reason` (*string*): Reason for the command (optional)

---

