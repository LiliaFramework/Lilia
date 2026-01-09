# Administrator Library

Comprehensive user group and privilege management system for the Lilia framework.

---

Overview

The administrator library provides comprehensive functionality for managing user groups, privileges, and administrative permissions in the Lilia framework. It handles the creation, modification, and deletion of user groups with inheritance-based privilege systems. The library operates on both server and client sides, with the server managing privilege storage and validation while the client provides user interface elements for administrative management. It includes integration with CAMI (Comprehensive Administration Management Interface) for compatibility with other administrative systems. The library ensures proper privilege inheritance, automatic privilege registration for tools and properties, and comprehensive logging of administrative actions. It supports both console-based and GUI-based administrative command execution with proper permission checking and validation.

Setting Superadmin:
To set yourself as superadmin in the console, use: plysetgroup "STEAMID" superadmin
The system has three default user groups with inheritance levels: user (level 1), admin (level 2), and superadmin (level 3).
Superadmin automatically has all privileges and cannot be restricted by any permission checks.

---

### lia.admin.applyPunishment

#### 📋 Purpose
Applies kick or ban punishments to a player based on the provided parameters.

#### ⏰ When Called
Called when an automated system or admin action needs to punish a player with a kick or ban.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to punish. |
| `infraction` | **string** | Description of the infraction that caused the punishment. |
| `kick` | **boolean** | Whether to kick the player. |
| `ban` | **boolean** | Whether to ban the player. |
| `time` | **number** | Ban duration in minutes (only used if ban is true). |
| `kickKey` | **string** | Localization key for kick message (defaults to "kickedForInfraction"). |
| `banKey` | **string** | Localization key for ban message (defaults to "bannedForInfraction"). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Kick a player for spamming
    lia.admin.applyPunishment(player, "Spamming in chat", true, false, nil, nil, nil)
    -- Ban a player for griefing for 24 hours
    lia.admin.applyPunishment(player, "Griefing", false, true, 1440, nil, nil)
    -- Both kick and ban with custom messages
    lia.admin.applyPunishment(player, "Hacking", true, true, 10080, "kickedForHacking", "bannedForHacking")

```

---

### lia.admin.hasAccess

#### 📋 Purpose
Checks if a player has access to a specific privilege based on their usergroup and privilege requirements.

#### ⏰ When Called
Called when verifying if a player can perform an action that requires specific permissions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player|string** | The player to check access for, or a usergroup string. |
| `privilege` | **string** | The privilege ID to check access for (e.g., "command_kick", "property_door", "tool_remover"). |

#### ↩️ Returns
* boolean
true if the player has access to the privilege, false otherwise.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Check if player can use kick command
    if lia.admin.hasAccess(player, "command_kick") then
        -- Allow kicking
    end
    -- Check if player has access to a tool
    if lia.admin.hasAccess(player, "tool_remover") then
        -- Give tool access
    end
    -- Check usergroup access directly
    if lia.admin.hasAccess("admin", "command_ban") then
        -- Admin group has ban access
    end

```

---

### lia.admin.save

#### 📋 Purpose
Saves administrator group configurations and privileges to the database.

#### ⏰ When Called
Called when administrator settings are modified and need to be persisted, or when syncing with clients.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `noNetwork` | **boolean** | If true, skips network synchronization with clients after saving. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Save admin groups without network sync
    lia.admin.save(true)
    -- Save and sync with all clients
    lia.admin.save(false)
    -- or simply:
    lia.admin.save()

```

---

### lia.admin.registerPrivilege

#### 📋 Purpose
Registers a new privilege in the administrator system with specified access levels and categories.

#### ⏰ When Called
Called when defining new administrative permissions that can be granted to user groups.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `priv` | **table** | Privilege configuration table with the following fields: |
| `ID` | **string** | Unique identifier for the privilege (required) |
| `Name` | **string** | Display name for the privilege (optional, defaults to ID) |
| `MinAccess` | **string** | Minimum usergroup required ("user", "admin", "superadmin") |
| `Category` | **string** | Category for organizing privileges in menus |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Register a custom admin command privilege
    lia.admin.registerPrivilege({
        ID = "command_customban",
        Name = "Custom Ban Command",
        MinAccess = "admin",
        Category = "staffCommands"
    })
    -- Register a property privilege
    lia.admin.registerPrivilege({
        ID = "property_teleport",
        Name = "Teleport Property",
        MinAccess = "admin",
        Category = "staffPermissions"
    })

```

---

### lia.admin.unregisterPrivilege

#### 📋 Purpose
Removes a privilege from the administrator system and cleans up all associated data.

#### ⏰ When Called
Called when a privilege is no longer needed or when cleaning up removed permissions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | The privilege ID to unregister. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Unregister a custom privilege
    lia.admin.unregisterPrivilege("command_customban")
    -- Clean up a tool privilege
    lia.admin.unregisterPrivilege("tool_remover")

```

---

### lia.admin.applyInheritance

#### 📋 Purpose
Applies privilege inheritance to a usergroup, copying permissions from parent groups and ensuring appropriate access levels.

#### ⏰ When Called
Called when setting up or updating usergroup permissions to ensure inheritance rules are properly applied.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | The name of the usergroup to apply inheritance to. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Apply inheritance to a moderator group
    lia.admin.applyInheritance("moderator")
    -- Apply inheritance after creating a new usergroup
    lia.admin.applyInheritance("customadmin")

```

---

### lia.admin.load

#### 📋 Purpose
Loads administrator group configurations from the database and initializes the admin system.

#### ⏰ When Called
Called during server startup to restore saved administrator settings and permissions.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load admin system (called automatically during server initialization)
    lia.admin.load()

```

---

### lia.admin.createGroup

#### 📋 Purpose
Creates a new administrator usergroup with specified configuration and inheritance.

#### ⏰ When Called
Called when setting up new administrator roles or permission levels in the system.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | The name of the usergroup to create. |
| `info` | **table** | Optional configuration table for the group (privileges, inheritance, etc.). |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Create a moderator group
    lia.admin.createGroup("moderator", {
        _info = {
            inheritance = "user",
            types = {}
        },
        command_kick = true,
        command_mute = true
    })
    -- Create a custom admin group
    lia.admin.createGroup("customadmin")

```

---

### lia.admin.removeGroup

#### 📋 Purpose
Removes an administrator usergroup from the system.

#### ⏰ When Called
Called when cleaning up or removing unused administrator roles.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | The name of the usergroup to remove. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Remove a custom moderator group
    lia.admin.removeGroup("moderator")
    -- Remove a custom admin group
    lia.admin.removeGroup("customadmin")

```

---

### lia.admin.renameGroup

#### 📋 Purpose
Renames an existing administrator usergroup to a new name.

#### ⏰ When Called
Called when reorganizing or rebranding administrator roles.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `oldName` | **string** | The current name of the usergroup to rename. |
| `newName` | **string** | The new name for the usergroup. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Rename moderator group to staff
    lia.admin.renameGroup("moderator", "staff")
    -- Rename admin group to administrator
    lia.admin.renameGroup("admin", "administrator")

```

---

### lia.admin.notifyAdmin

#### 📋 Purpose
Sends a notification to all administrators who have permission to see admin notifications.

#### ⏰ When Called
Called when important administrative events need to be communicated to staff.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `notification` | **string** | The notification message key to send. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Notify admins of a potential exploit
    lia.admin.notifyAdmin("exploitDetected")
    -- Notify admins of a player report
    lia.admin.notifyAdmin("playerReportReceived")

```

---

### lia.admin.addPermission

#### 📋 Purpose
Grants a specific permission to an administrator usergroup.

#### ⏰ When Called
Called when configuring permissions for administrator roles.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | The name of the usergroup to grant the permission to. |
| `permission` | **string** | The permission ID to grant. |
| `silent` | **boolean** | If true, skips network synchronization. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Grant kick permission to moderators
    lia.admin.addPermission("moderator", "command_kick", false)
    -- Grant ban permission to admins silently
    lia.admin.addPermission("admin", "command_ban", true)

```

---

### lia.admin.removePermission

#### 📋 Purpose
Removes a specific permission from an administrator usergroup.

#### ⏰ When Called
Called when revoking permissions from administrator roles.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | The name of the usergroup to remove the permission from. |
| `permission` | **string** | The permission ID to remove. |
| `silent` | **boolean** | If true, skips network synchronization. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Remove kick permission from moderators
    lia.admin.removePermission("moderator", "command_kick", false)
    -- Remove ban permission from admins silently
    lia.admin.removePermission("admin", "command_ban", true)

```

---

### lia.admin.sync

#### 📋 Purpose
Synchronizes administrator privileges and usergroups with clients.

#### ⏰ When Called
Called when administrator data changes and needs to be updated on clients, or when a player joins.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c` | **Player** | Optional specific client to sync with. If not provided, syncs with all clients in batches. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Sync admin data with all clients
    lia.admin.sync()
    -- Sync admin data with a specific player
    lia.admin.sync(specificPlayer)

```

---

### lia.admin.hasChanges

#### 📋 Purpose
Checks if administrator privileges or groups have changed since the last sync.

#### ⏰ When Called
Called to determine if a sync operation is needed.

#### ↩️ Returns
* boolean
true if there are unsynced changes, false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Check if admin data needs syncing
    if lia.admin.hasChanges() then
        lia.admin.sync()
    end

```

---

### lia.admin.setPlayerUsergroup

#### 📋 Purpose
Sets the usergroup of a player entity.

#### ⏰ When Called
Called when promoting, demoting, or changing a player's administrative role.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | The player to change the usergroup for. |
| `newGroup` | **string** | The new usergroup name to assign. |
| `source` | **string** | Optional source identifier for logging. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Promote player to admin
    lia.admin.setPlayerUsergroup(player, "admin", "promotion")
    -- Demote player to user
    lia.admin.setPlayerUsergroup(player, "user", "demotion")

```

---

### lia.admin.setSteamIDUsergroup

#### 📋 Purpose
Sets the usergroup of a player by their SteamID.

#### ⏰ When Called
Called when changing a player's usergroup using their SteamID, useful for offline players.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamId` | **string** | The SteamID of the player to change the usergroup for. |
| `newGroup` | **string** | The new usergroup name to assign. |
| `source` | **string** | Optional source identifier for logging. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Set offline player's usergroup to admin
    lia.admin.setSteamIDUsergroup("STEAM_0:1:12345678", "admin", "promotion")
    -- Demote player by SteamID
    lia.admin.setSteamIDUsergroup("STEAM_0:1:12345678", "user", "demotion")

```

---

### lia.admin.serverExecCommand

#### 📋 Purpose
Executes administrative commands on players with proper permission checking and logging.

#### ⏰ When Called
Called when an administrator uses commands like kick, ban, mute, gag, freeze, slay, bring, goto, etc.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmd` | **string** | The command to execute (e.g., "kick", "ban", "mute", "gag", "freeze", "slay", "bring", "goto", "return", "jail", "cloak", "god", "ignite", "strip", "respawn", "blind"). |
| `victim` | **Player|string** | The target player entity or SteamID string. |
| `dur` | **number|string** | Duration for commands that support time limits (ban, freeze, blind, ignite). |
| `reason` | **string** | Reason for the action (used in kick, ban, etc.). |
| `admin` | **Player** | The administrator executing the command. |

#### ↩️ Returns
* boolean
true if the command was executed successfully, false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Kick a player for spamming
    lia.admin.serverExecCommand("kick", targetPlayer, nil, "Spamming in chat", adminPlayer)
    -- Ban a player for 24 hours
    lia.admin.serverExecCommand("ban", targetPlayer, 1440, "Griefing", adminPlayer)
    -- Mute a player
    lia.admin.serverExecCommand("mute", targetPlayer, nil, nil, adminPlayer)
    -- Bring a player to admin's position
    lia.admin.serverExecCommand("bring", targetPlayer, nil, nil, adminPlayer)

```

---

### lia.admin.execCommand

#### 📋 Purpose
Executes an administrative command using the client-side command system.

#### ⏰ When Called
Called when running admin commands through console commands or automated systems.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmd` | **string** | The command to execute (e.g., "kick", "ban", "mute", "freeze", etc.). |
| `victim` | **Player|string** | The target player or identifier. |
| `dur` | **number** | Duration for time-based commands. |
| `reason` | **string** | Reason for the administrative action. |

#### ↩️ Returns
* boolean
true if the command was executed successfully, false otherwise.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Kick a player via console command
    lia.admin.execCommand("kick", targetPlayer, nil, "Rule violation")
    -- Ban a player for 24 hours
    lia.admin.execCommand("ban", targetPlayer, 1440, "Griefing")

```

---

