# Administrator Library

Comprehensive user group and privilege management system for the Lilia framework.

---

## Overview

The administrator library provides comprehensive functionality for managing user groups, privileges, and administrative permissions in the Lilia framework. It handles the creation, modification, and deletion of user groups with inheritance-based privilege systems. The library operates on both server and client sides, with the server managing privilege storage and validation while the client provides user interface elements for administrative management. It includes integration with CAMI (Comprehensive Administration Management Interface) for compatibility with other administrative systems. The library ensures proper privilege inheritance, automatic privilege registration for tools and properties, and comprehensive logging of administrative actions. It supports both console-based and GUI-based administrative command execution with proper permission checking and validation.

---

### lia.administrator.applyPunishment

**Purpose**

Applies punishment actions (kick/ban) to a player based on infraction details

**When Called**

When an administrative action needs to be taken against a player for rule violations

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player for cheating
lia.administrator.applyPunishment(player, "Cheating detected", true, false)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban a player for 60 minutes with custom message
lia.administrator.applyPunishment(player, "RDM", false, true, 60, "kickedForRDM", "bannedForRDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Apply punishment based on infraction severity
local punishments = {
["RDM"] = {kick = true, ban = false, time = 0},
["Cheating"] = {kick = true, ban = true, time = 0},
["Spam"] = {kick = true, ban = false, time = 30}
}
local punishment = punishments[infractionType]
if punishment then
lia.administrator.applyPunishment(player, infractionType, punishment.kick, punishment.ban, punishment.time)
end
```
```

---

### lia.checkMultiplePrivileges

**Purpose**

Checks if a player or user group has access to a specific privilege

**When Called**

When permission validation is needed before allowing access to features or commands

**Returns**

* boolean - true if access is granted, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if player can use admin tools
if lia.administrator.hasAccess(player, "tool_adminstick") then
-- Grant access to admin stick
end
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Check access for different user groups
local groups = {"admin", "moderator", "user"}
for _, group in ipairs(groups) do
if lia.administrator.hasAccess(group, "manageUsergroups") then
print(group .. " can manage user groups")
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Complex permission checking with fallback
local function checkMultiplePrivileges(player, privileges)
for _, privilege in ipairs(privileges) do
if lia.administrator.hasAccess(player, privilege) then
return true, privilege
end
end
return false, nil
end
local hasAccess, grantedPrivilege = checkMultiplePrivileges(player, {"admin", "moderator", "helper"})
```
```

---

### lia.administrator.hasAccess

**Purpose**

Checks if a player or user group has access to a specific privilege

**When Called**

When permission validation is needed before allowing access to features or commands

**Returns**

* boolean - true if access is granted, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Check if player can use admin tools
if lia.administrator.hasAccess(player, "tool_adminstick") then
-- Grant access to admin stick
end
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Check access for different user groups
local groups = {"admin", "moderator", "user"}
for _, group in ipairs(groups) do
if lia.administrator.hasAccess(group, "manageUsergroups") then
print(group .. " can manage user groups")
end
end
```
```

**High Complexity:**
```lua
```lua
-- High: Complex permission checking with fallback
local function checkMultiplePrivileges(player, privileges)
for _, privilege in ipairs(privileges) do
if lia.administrator.hasAccess(player, privilege) then
return true, privilege
end
end
return false, nil
end
local hasAccess, grantedPrivilege = checkMultiplePrivileges(player, {"admin", "moderator", "helper"})
```
```

---

### lia.safeSave

**Purpose**

Saves all administrator groups and privileges to the database and synchronizes with clients

**When Called**

When administrator data needs to be persisted to the database after changes

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Save administrator data
lia.administrator.save()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Save without network sync during bulk operations
for i = 1, 10 do
lia.administrator.createGroup("group" .. i, {})
end
lia.administrator.save(true) -- Save without network sync
lia.administrator.save() -- Final save with sync
```
```

**High Complexity:**
```lua
```lua
-- High: Batch save with error handling
local function safeSave(noNetwork)
local success, err = pcall(function()
lia.administrator.save(noNetwork)
end)
if not success then
lia.log.add(nil, "adminSaveError", err)
return false
end
return true
end
if safeSave(true) then
print("Administrator data saved successfully")
end
```
```

---

### lia.administrator.save

**Purpose**

Saves all administrator groups and privileges to the database and synchronizes with clients

**When Called**

When administrator data needs to be persisted to the database after changes

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Save administrator data
lia.administrator.save()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Save without network sync during bulk operations
for i = 1, 10 do
lia.administrator.createGroup("group" .. i, {})
end
lia.administrator.save(true) -- Save without network sync
lia.administrator.save() -- Final save with sync
```
```

**High Complexity:**
```lua
```lua
-- High: Batch save with error handling
local function safeSave(noNetwork)
local success, err = pcall(function()
lia.administrator.save(noNetwork)
end)
if not success then
lia.log.add(nil, "adminSaveError", err)
return false
end
return true
end
if safeSave(true) then
print("Administrator data saved successfully")
end
```
```

---

### lia.administrator.registerPrivilege

**Purpose**

Registers a new privilege in the administrator system with specified access requirements

**When Called**

When a new privilege needs to be added to the system for permission checking

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Register a basic privilege
lia.administrator.registerPrivilege({
ID = "accessAdminPanel",
Name = "Access Admin Panel",
MinAccess = "admin"
})
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Register privilege with category
lia.administrator.registerPrivilege({
ID = "managePlayers",
Name = "Manage Players",
MinAccess = "moderator",
Category = "Player Management"
})
```
```

**High Complexity:**
```lua
```lua
-- High: Register multiple privileges from module
local modulePrivileges = {
{ID = "module_feature1", Name = "Feature 1", MinAccess = "user", Category = "Module"},
{ID = "module_feature2", Name = "Feature 2", MinAccess = "admin", Category = "Module"},
{ID = "module_feature3", Name = "Feature 3", MinAccess = "superadmin", Category = "Module"}
}
for _, privilege in ipairs(modulePrivileges) do
lia.administrator.registerPrivilege(privilege)
end
```
```

---

### lia.administrator.unregisterPrivilege

**Purpose**

Removes a privilege from the administrator system and all user groups

**When Called**

When a privilege is no longer needed and should be completely removed

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Remove a privilege
lia.administrator.unregisterPrivilege("oldPrivilege")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Remove privilege with validation
local privilegeToRemove = "deprecatedFeature"
if lia.administrator.privileges[privilegeToRemove] then
lia.administrator.unregisterPrivilege(privilegeToRemove)
print("Privilege removed: " .. privilegeToRemove)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Remove multiple privileges with cleanup
local privilegesToRemove = {"old_feature1", "old_feature2", "deprecated_tool"}
for _, privilege in ipairs(privilegesToRemove) do
if lia.administrator.privileges[privilege] then
lia.administrator.unregisterPrivilege(privilege)
lia.log.add(nil, "privilegeRemoved", privilege)
end
end
```
```

---

### lia.administrator.applyInheritance

**Purpose**

Applies privilege inheritance from parent groups to a specific user group

**When Called**

When a user group's inheritance needs to be recalculated after changes

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Apply inheritance to a group
lia.administrator.applyInheritance("moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Apply inheritance after group modification
lia.administrator.groups["moderator"]._info.inheritance = "admin"
lia.administrator.applyInheritance("moderator")
```
```

**High Complexity:**
```lua
```lua
-- High: Apply inheritance to multiple groups with validation
local groupsToUpdate = {"moderator", "helper", "vip"}
for _, groupName in ipairs(groupsToUpdate) do
if lia.administrator.groups[groupName] then
lia.administrator.applyInheritance(groupName)
print("Applied inheritance to: " .. groupName)
end
end
```
```

---

### lia.copyFrom

**Purpose**

Applies privilege inheritance from parent groups to a specific user group

**When Called**

When a user group's inheritance needs to be recalculated after changes

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Apply inheritance to a group
lia.administrator.applyInheritance("moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Apply inheritance after group modification
lia.administrator.groups["moderator"]._info.inheritance = "admin"
lia.administrator.applyInheritance("moderator")
```
```

**High Complexity:**
```lua
```lua
-- High: Apply inheritance to multiple groups with validation
local groupsToUpdate = {"moderator", "helper", "vip"}
for _, groupName in ipairs(groupsToUpdate) do
if lia.administrator.groups[groupName] then
lia.administrator.applyInheritance(groupName)
print("Applied inheritance to: " .. groupName)
end
end
```
```

---

### lia.safeLoad

**Purpose**

Loads administrator groups and privileges from the database and initializes the system

**When Called**

During server startup or when administrator data needs to be reloaded

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load administrator data
lia.administrator.load()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load with callback handling
lia.administrator.load()
hook.Add("OnAdminSystemLoaded", "MyModule", function(groups, privileges)
print("Admin system loaded with " .. table.Count(groups) .. " groups")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Load with error handling and validation
local function safeLoad()
local success, err = pcall(function()
lia.administrator.load()
end)
if not success then
lia.log.add(nil, "adminLoadError", err)
-- Fallback to default groups
lia.administrator.groups = {
user = {_info = {inheritance = "user", types = {}}},
admin = {_info = {inheritance = "admin", types = {"Staff"}}},
superadmin = {_info = {inheritance = "superadmin", types = {"Staff"}}}
}
return false
end
return true
end
if safeLoad() then
print("Administrator system loaded successfully")
else
print("Failed to load administrator system, using defaults")
end
```
```

---

### lia.administrator.load

**Purpose**

Loads administrator groups and privileges from the database and initializes the system

**When Called**

During server startup or when administrator data needs to be reloaded

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load administrator data
lia.administrator.load()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load with callback handling
lia.administrator.load()
hook.Add("OnAdminSystemLoaded", "MyModule", function(groups, privileges)
print("Admin system loaded with " .. table.Count(groups) .. " groups")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Load with error handling and validation
local function safeLoad()
local success, err = pcall(function()
lia.administrator.load()
end)
if not success then
lia.log.add(nil, "adminLoadError", err)
-- Fallback to default groups
lia.administrator.groups = {
user = {_info = {inheritance = "user", types = {}}},
admin = {_info = {inheritance = "admin", types = {"Staff"}}},
superadmin = {_info = {inheritance = "superadmin", types = {"Staff"}}}
}
return false
end
return true
end
if safeLoad() then
print("Administrator system loaded successfully")
else
print("Failed to load administrator system, using defaults")
end
```
```

---

### lia.continueLoad

**Purpose**

Loads administrator groups and privileges from the database and initializes the system

**When Called**

During server startup or when administrator data needs to be reloaded

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Load administrator data
lia.administrator.load()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Load with callback handling
lia.administrator.load()
hook.Add("OnAdminSystemLoaded", "MyModule", function(groups, privileges)
print("Admin system loaded with " .. table.Count(groups) .. " groups")
end)
```
```

**High Complexity:**
```lua
```lua
-- High: Load with error handling and validation
local function safeLoad()
local success, err = pcall(function()
lia.administrator.load()
end)
if not success then
lia.log.add(nil, "adminLoadError", err)
-- Fallback to default groups
lia.administrator.groups = {
user = {_info = {inheritance = "user", types = {}}},
admin = {_info = {inheritance = "admin", types = {"Staff"}}},
superadmin = {_info = {inheritance = "superadmin", types = {"Staff"}}}
}
return false
end
return true
end
if safeLoad() then
print("Administrator system loaded successfully")
else
print("Failed to load administrator system, using defaults")
end
```
```

---

### lia.administrator.createGroup

**Purpose**

Creates a new user group with specified inheritance and type information

**When Called**

When a new user group needs to be added to the administrator system

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Create a basic group
lia.administrator.createGroup("moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Create group with inheritance
lia.administrator.createGroup("helper", {
_info = {
inheritance = "user",
types = {"Staff"}
}
})
```
```

**High Complexity:**
```lua
```lua
-- High: Create multiple groups with different configurations
local groupConfigs = {
{name = "moderator", inherit = "admin", types = {"Staff"}},
{name = "helper", inherit = "user", types = {"Staff"}},
{name = "vip", inherit = "user", types = {"VIP"}}
}
for _, config in ipairs(groupConfigs) do
lia.administrator.createGroup(config.name, {
_info = {
inheritance = config.inherit,
types = config.types
}
})
end
```
```

---

### lia.administrator.removeGroup

**Purpose**

Removes a user group from the administrator system (cannot remove base groups)

**When Called**

When a user group is no longer needed and should be deleted

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Remove a group
lia.administrator.removeGroup("oldGroup")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Remove group with validation
local groupToRemove = "deprecatedGroup"
if lia.administrator.groups[groupToRemove] and not lia.administrator.DefaultGroups[groupToRemove] then
lia.administrator.removeGroup(groupToRemove)
print("Group removed: " .. groupToRemove)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Remove multiple groups with safety checks
local groupsToRemove = {"tempGroup1", "tempGroup2", "oldModerator"}
for _, groupName in ipairs(groupsToRemove) do
if lia.administrator.groups[groupName] and not lia.administrator.DefaultGroups[groupName] then
lia.administrator.removeGroup(groupName)
lia.log.add(nil, "groupRemoved", groupName)
else
print("Cannot remove group: " .. groupName)
end
end
```
```

---

### lia.administrator.renameGroup

**Purpose**

Renames an existing user group to a new name (cannot rename base groups)

**When Called**

When a user group needs to be renamed for organizational purposes

**Returns**

* None

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Rename a group
lia.administrator.renameGroup("oldModerator", "moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Rename with validation
local oldGroupName = "tempGroup"
local newGroupName = "permanentGroup"
if lia.administrator.groups[oldGroupName] and not lia.administrator.groups[newGroupName] then
lia.administrator.renameGroup(oldGroupName, newGroupName)
end
```
```

**High Complexity:**
```lua
```lua
-- High: Batch rename with error handling
local renameOperations = {
{old = "oldHelper", new = "helper"},
{old = "oldVIP", new = "vip"},
{old = "tempMod", new = "moderator"}
}
for _, operation in ipairs(renameOperations) do
if lia.administrator.groups[operation.old] and not lia.administrator.groups[operation.new] then
lia.administrator.renameGroup(operation.old, operation.new)
lia.log.add(nil, "groupRenamed", operation.old, operation.new)
else
print("Cannot rename " .. operation.old .. " to " .. operation.new)
end
end
```
```

---

### lia.administrator.notifyAdmin

**Purpose**

Sends administrative notifications to all players with the appropriate privilege

**When Called**

When administrative notifications need to be broadcast to qualified players

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Notify admins about an event
lia.administrator.notifyAdmin({
text = "Player kicked for cheating",
type = "warning"
})
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Notify with specific privilege requirement
lia.administrator.notifyAdmin({
text = "Suspicious activity detected",
type = "alert",
privilege = "canSeeAltingNotifications"
})
```
```

**High Complexity:**
```lua
```lua
-- High: Batch notifications with different privilege levels
local notifications = {
{text = "Server restart in 5 minutes", privilege = "admin"},
{text = "New player joined", privilege = "moderator"},
{text = "VIP player online", privilege = "vip"}
}
for _, notification in ipairs(notifications) do
lia.administrator.notifyAdmin(notification)
end
```
```

---

### lia.administrator.addPermission

**Purpose**

Adds a permission to a specific user group

**When Called**

When a user group needs to be granted a new permission

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Add permission to group
lia.administrator.addPermission("moderator", "kickPlayers")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Add permission silently during bulk operations
lia.administrator.addPermission("helper", "mutePlayers", true)
```
```

**High Complexity:**
```lua
```lua
-- High: Add multiple permissions with validation
local permissions = {"kickPlayers", "mutePlayers", "banPlayers"}
for _, permission in ipairs(permissions) do
if not lia.administrator.groups["moderator"][permission] then
lia.administrator.addPermission("moderator", permission)
end
end
```
```

---

### lia.administrator.removePermission

**Purpose**

Removes a permission from a specific user group

**When Called**

When a user group should no longer have a specific permission

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Remove permission from group
lia.administrator.removePermission("moderator", "banPlayers")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Remove permission silently during bulk operations
lia.administrator.removePermission("helper", "kickPlayers", true)
```
```

**High Complexity:**
```lua
```lua
-- High: Remove multiple permissions with validation
local permissionsToRemove = {"banPlayers", "kickPlayers", "mutePlayers"}
for _, permission in ipairs(permissionsToRemove) do
if lia.administrator.groups["moderator"][permission] then
lia.administrator.removePermission("moderator", permission)
end
end
```
```

---

### lia.safeSync

**Purpose**

Synchronizes administrator data with connected clients

**When Called**

When administrator data needs to be sent to clients after changes

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Sync with all clients
lia.administrator.sync()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Sync with specific client
lia.administrator.sync(player)
```
```

**High Complexity:**
```lua
```lua
-- High: Sync with validation and error handling
local function safeSync(client)
if client and not IsValid(client) then
lia.log.add(nil, "syncError", "Invalid client")
return false
end
local success, err = pcall(function()
lia.administrator.sync(client)
end)
if not success then
lia.log.add(nil, "syncError", err)
return false
end
return true
end
if safeSync(player) then
print("Administrator data synced successfully")
end
```
```

---

### lia.administrator.sync

**Purpose**

Synchronizes administrator data with connected clients

**When Called**

When administrator data needs to be sent to clients after changes

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Sync with all clients
lia.administrator.sync()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Sync with specific client
lia.administrator.sync(player)
```
```

**High Complexity:**
```lua
```lua
-- High: Sync with validation and error handling
local function safeSync(client)
if client and not IsValid(client) then
lia.log.add(nil, "syncError", "Invalid client")
return false
end
local success, err = pcall(function()
lia.administrator.sync(client)
end)
if not success then
lia.log.add(nil, "syncError", err)
return false
end
return true
end
if safeSync(player) then
print("Administrator data synced successfully")
end
```
```

---

### lia.push

**Purpose**

Synchronizes administrator data with connected clients

**When Called**

When administrator data needs to be sent to clients after changes

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Sync with all clients
lia.administrator.sync()
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Sync with specific client
lia.administrator.sync(player)
```
```

**High Complexity:**
```lua
```lua
-- High: Sync with validation and error handling
local function safeSync(client)
if client and not IsValid(client) then
lia.log.add(nil, "syncError", "Invalid client")
return false
end
local success, err = pcall(function()
lia.administrator.sync(client)
end)
if not success then
lia.log.add(nil, "syncError", err)
return false
end
return true
end
if safeSync(player) then
print("Administrator data synced successfully")
end
```
```

---

### lia.administrator.setPlayerUsergroup

**Purpose**

Changes a player's user group and triggers CAMI events

**When Called**

When a player's user group needs to be changed

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Change player's group
lia.administrator.setPlayerUsergroup(player, "moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Change group with source tracking
lia.administrator.setPlayerUsergroup(player, "admin", "MyModule")
```
```

**High Complexity:**
```lua
```lua
-- High: Batch group changes with validation
local groupChanges = {
{player = player1, group = "moderator", source = "promotion"},
{player = player2, group = "helper", source = "demotion"},
{player = player3, group = "vip", source = "donation"}
}
for _, change in ipairs(groupChanges) do
if IsValid(change.player) then
lia.administrator.setPlayerUsergroup(change.player, change.group, change.source)
lia.log.add(nil, "groupChanged", change.player:Name(), change.group)
end
end
```
```

---

### lia.administrator.setSteamIDUsergroup

**Purpose**

Changes a Steam ID's user group and triggers CAMI events

**When Called**

When a Steam ID's user group needs to be changed (for offline players)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Change Steam ID's group
lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456789", "moderator")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Change group with source tracking
lia.administrator.setSteamIDUsergroup("STEAM_0:1:123456789", "admin", "WebPanel")
```
```

**High Complexity:**
```lua
```lua
-- High: Batch Steam ID group changes with validation
local steamGroupChanges = {
{steamid = "STEAM_0:1:123456789", group = "moderator", source = "promotion"},
{steamid = "STEAM_0:1:987654321", group = "helper", source = "demotion"},
{steamid = "STEAM_0:1:555555555", group = "vip", source = "donation"}
}
for _, change in ipairs(steamGroupChanges) do
if change.steamid and change.steamid ~= "" then
lia.administrator.setSteamIDUsergroup(change.steamid, change.group, change.source)
lia.log.add(nil, "steamGroupChanged", change.steamid, change.group)
end
end
```
```

---

### lia.administrator.serverExecCommand

**Purpose**

Executes administrative commands on the server with permission checking

**When Called**

When administrative commands need to be executed with proper validation

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.serverExecCommand("kick", player, nil, "Cheating", admin)
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.serverExecCommand("ban", player, 60, "RDM", admin)
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.serverExecCommand(
command.cmd,
command.target,
command.duration,
command.reason,
admin
)
if success then
print("Command executed: " .. command.cmd)
end
end
```
```

---

### lia.administrator.execCommand

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.ensureStructures

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.broadcastGroups

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.computeCategoryMap

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.promptCreateGroup

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.buildPrivilegeList

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.addRow

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.renderGroupInfo

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.buildGroupsUI

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.SetupUserGroupInterface

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

### lia.updateGroupDetails

**Purpose**

Executes administrative commands on the client by sending console commands to server

**When Called**

When administrative commands need to be executed from the client side

**Returns**

* boolean - true if command was executed successfully, false otherwise

**Realm**

Client

**Example Usage**

**Low Complexity:**
```lua
```lua
-- Simple: Kick a player
lia.administrator.execCommand("kick", player, nil, "Cheating")
```
```

**Medium Complexity:**
```lua
```lua
-- Medium: Ban player with duration
lia.administrator.execCommand("ban", player, 60, "RDM")
```
```

**High Complexity:**
```lua
```lua
-- High: Execute multiple commands with validation
local commands = {
{cmd = "kick", target = player1, reason = "Cheating"},
{cmd = "ban", target = player2, duration = 30, reason = "RDM"},
{cmd = "mute", target = player3, duration = 10, reason = "Spam"}
}
for _, command in ipairs(commands) do
local success = lia.administrator.execCommand(
command.cmd,
command.target,
command.duration,
command.reason
)
if success then
print("Command sent: " .. command.cmd)
end
end
```
```

---

