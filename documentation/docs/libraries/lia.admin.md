# Administrator Library

Comprehensive user group and privilege management system for the Lilia framework.

---

Overview

The administrator library provides comprehensive functionality for managing user groups, privileges, and administrative permissions in the Lilia framework. It handles the creation, modification, and deletion of user groups with inheritance-based privilege systems. The library operates on both server and client sides, with the server managing privilege storage and validation while the client provides user interface elements for administrative management. It includes integration with CAMI (Comprehensive Administration Management Interface) for compatibility with other administrative systems. The library ensures proper privilege inheritance, automatic privilege registration for tools and properties, and comprehensive logging of administrative actions. It supports both console-based and GUI-based administrative command execution with proper permission checking and validation.

Setting Superadmin:
To set yourself as superadmin in the console, use: plysetgroup [NAME] superadmin
The system has three default user groups with inheritance levels: user (level 1), admin (level 2), and superadmin (level 3).
Superadmin automatically has all privileges and cannot be restricted by any permission checks.

---

### lia.administrator.applyPunishment

#### 📋 Purpose
Kicks and/or bans a player for an infraction using admin commands

#### ⏰ When Called
When staff tools need a quick punishment action (simple for non-developers)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Target player to punish |
| `infraction` | **string** | Description of the infraction |
| `kick` | **boolean** | Whether to kick the player |
| `ban` | **boolean** | Whether to ban the player |
| `time` | **number** | Ban duration in minutes (0 or nil = permanent; optional) |
| `kickKey` | **string** | Language key for the kick message (optional) |
| `banKey` | **string** | Language key for the ban message (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Kick for simple spam
    lia.administrator.applyPunishment(target, "Spam", true, false)

```

#### 📊 Medium Complexity
```lua
    -- Ban for 60 minutes with custom language keys
    lia.administrator.applyPunishment(target, "RDM", false, true, 60, "kickedForRDM", "bannedForRDM")

```

#### ⚙️ High Complexity
```lua
    -- Choose punishment severity dynamically
    local rules = {
        minor = {kick = true, ban = false, time = 0},
        major = {kick = true, ban = true, time = 120},
        severe = {kick = true, ban = true, time = 0}
    }
    local action = rules[reportLevel] or rules.minor
    lia.administrator.applyPunishment(target, reportLevel, action.kick, action.ban, action.time)

```

---

### lia.administrator.hasAccess

#### 📋 Purpose
Checks if a player or group may use a specific privilege

#### ⏰ When Called
Before running any protected action (clear for non-developers)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player|string** | Player to check, or a usergroup name |
| `privilege` | **string** | Privilege identifier to test |

#### ↩️ Returns
* boolean

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    if lia.administrator.hasAccess(client, "command_kick") then
        print("Client can kick players")
    end

```

#### 📊 Medium Complexity
```lua
    -- Protect a network handler with a simple check
    if not lia.administrator.hasAccess(netCaller, "manageUsergroups") then
        netCaller:notifyErrorLocalized("noPerm")
        return
    end
    performAdminAction()

```

#### ⚙️ High Complexity
```lua
    -- Check permissions for players and raw group names
    local identifiers = {client, "admin", "superadmin"}
    for _, id in ipairs(identifiers) do
        local has = lia.administrator.hasAccess(id, "command_ban")
        print(tostring(id) .. " -> " .. tostring(has))
    end

```

---

### lia.administrator.save

#### 📋 Purpose
Saves admin groups and privileges to the database and syncs them when needed

#### ⏰ When Called
After changing groups or permissions so data stays stored and shared

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `noNetwork` | **boolean** | Skip client synchronization if true (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Save changes after adding a permission
    lia.administrator.save()

```

#### 📊 Medium Complexity
```lua
    -- Save during bulk import without sending to players
    lia.administrator.save(true)

```

#### ⚙️ High Complexity
```lua
    -- Change a group, save, and only sync if ready
    lia.administrator.groups["vip"] = lia.administrator.groups["vip"] or {_info = {inheritance = "user", types = {}}}
    lia.administrator.groups["vip"]["canSpawnProps"] = true
    local shouldSync = not lia.administrator._loading
    lia.administrator.save(not shouldSync)
    if shouldSync then
        lia.administrator.sync()
    end

```

---

### lia.administrator.registerPrivilege

#### 📋 Purpose
Adds a new privilege with its minimum access, name, and category, then updates groups

#### ⏰ When Called
When creating new admin actions so they are gated behind simple permissions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `priv` | **table** | Privilege definition containing: |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.registerPrivilege({ID = "canOpenSupportUI", MinAccess = "admin"})

```

#### 📊 Medium Complexity
```lua
    -- Add a ticket command that only admins can use
    lia.administrator.registerPrivilege({
        ID = "command_ticket",
        Name = "commandTicket",
        MinAccess = "admin",
        Category = "support"
    })

```

#### ⚙️ High Complexity
```lua
    -- Add a set of appeal-related permissions
    local actions = {
        {id = "manageAppeals", access = "superadmin"},
        {id = "viewAppeals", access = "admin"},
        {id = "commentAppeals", access = "admin"}
    }
    for _, action in ipairs(actions) do
        lia.administrator.registerPrivilege({
            ID = action.id,
            Name = action.id,
            MinAccess = action.access,
            Category = "appeals"
        })
    end

```

---

### lia.administrator.unregisterPrivilege

#### 📋 Purpose
Deletes a privilege and clears it from all groups and CAMI

#### ⏰ When Called
When a command or ability is no longer needed

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **string** | Privilege identifier to remove |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.unregisterPrivilege("command_unused")

```

#### 📊 Medium Complexity
```lua
    -- Remove an old menu privilege after adding a replacement
    lia.administrator.unregisterPrivilege("legacyAdminMenu")
    lia.administrator.registerPrivilege({ID = "newAdminMenu", MinAccess = "admin"})

```

#### ⚙️ High Complexity
```lua
    -- Remove several deprecated privileges in one go
    local deprecated = {"command_oldkick", "command_oldban", "command_oldmute"}
    for _, id in ipairs(deprecated) do
        lia.administrator.unregisterPrivilege(id)
    end

```

---

### lia.administrator.applyInheritance

#### 📋 Purpose
Copies permissions from a parent group and grants required minimum privileges

#### ⏰ When Called
After setting or changing a group's parent so permissions stay in sync

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the usergroup to process |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Refresh inheritance after setting up a group
    lia.administrator.applyInheritance("moderator")

```

#### 📊 Medium Complexity
```lua
    -- Reapply inheritance for all groups after bulk edits
    for name in pairs(lia.administrator.groups or {}) do
        lia.administrator.applyInheritance(name)
    end

```

#### ⚙️ High Complexity
```lua
    -- Make sure a custom group inherits from admin if missing
    local target = "eventStaff"
    lia.administrator.groups[target] = lia.administrator.groups[target] or {_info = {inheritance = "admin", types = {}}}
    lia.administrator.applyInheritance(target)

```

---

### lia.administrator.load

#### 📋 Purpose
Loads admin groups and privileges from the database, reapplies inheritance, and syncs CAMI

#### ⏰ When Called
During server start or when refreshing the admin system

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Load admin data during initialization
    lia.administrator.load()

```

#### 📊 Medium Complexity
```lua
    -- Reload admin data after an external update
    hook.Run("ReloadAdministrationData")
    lia.administrator.load()

```

#### ⚙️ High Complexity
```lua
    -- Log reload progress and summarize results
    print("[Admin] Reloading admin tables...")
    lia.administrator.load()
    hook.Add("OnAdminSystemLoaded", "postReloadNotice", function(groups, privileges)
        print("[Admin] Loaded " .. table.Count(groups) .. " groups and " .. table.Count(privileges) .. " privileges")
    end)

```

---

### lia.administrator.createGroup

#### 📋 Purpose
Creates a new usergroup, sets its parent, and registers it with CAMI

#### ⏰ When Called
When staff add a custom role with its own permissions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the new usergroup |
| `info` | **table** | Group data including `_info.inheritance` and `types` (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.createGroup("vip", {_info = {inheritance = "user", types = {"VIP"}}})

```

#### 📊 Medium Complexity
```lua
    -- Make a helper role that inherits from admin
    lia.administrator.createGroup("helper", {
        _info = {inheritance = "admin", types = {"Staff"}}
    })
    lia.administrator.addPermission("helper", "canAccessPlayerList")

```

#### ⚙️ High Complexity
```lua
    -- Create several event roles that share admin as parent
    local roles = {"eventHelper", "eventManager"}
    for _, role in ipairs(roles) do
        lia.administrator.createGroup(role, {_info = {inheritance = "admin", types = {"Staff"}}})
        lia.administrator.addPermission(role, "command_bring")
    end

```

---

### lia.administrator.removeGroup

#### 📋 Purpose
Deletes a usergroup (not the base ones) and unregisters it from CAMI

#### ⏰ When Called
When removing unused or outdated groups

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the usergroup to remove |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.removeGroup("oldStaff")

```

#### 📊 Medium Complexity
```lua
    -- Remove a group and log the action
    lia.administrator.removeGroup("trialmod")
    lia.log.add(nil, "usergroupRemoved", "trialmod")

```

#### ⚙️ High Complexity
```lua
    -- Remove several non-default groups safely
    local targets = {"vip_old", "eventStaff"}
    for _, g in ipairs(targets) do
        if not lia.administrator.DefaultGroups[g] then
            lia.administrator.removeGroup(g)
        end
    end

```

---

### lia.administrator.renameGroup

#### 📋 Purpose
Changes the name of an existing usergroup (not a base group) and updates CAMI

#### ⏰ When Called
When a group needs a clearer or merged name

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `oldName` | **string** | Current usergroup name |
| `newName` | **string** | Desired new usergroup name |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.renameGroup("helper", "moderator")

```

#### 📊 Medium Complexity
```lua
    -- Rename and immediately reapply inheritance
    lia.administrator.renameGroup("juniorStaff", "staff")
    lia.administrator.applyInheritance("staff")

```

#### ⚙️ High Complexity
```lua
    -- Rename multiple legacy groups to new scheme
    local renames = {["trialmod"] = "moderator", ["srmod"] = "seniorModerator"}
    for old, new in pairs(renames) do
        lia.administrator.renameGroup(old, new)
    end

```

---

### lia.administrator.notifyAdmin

#### 📋 Purpose
Sends an admin notification to staff with the proper privilege

#### ⏰ When Called
When the server needs to broadcast an admin-only message (simple for non-developers)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `notification` | **string** | Text to send to qualified staff |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.notifyAdmin("Server restart in 5 minutes")

```

#### 📊 Medium Complexity
```lua
    -- Notify only when a rule is broken
    if violationDetected then
        lia.administrator.notifyAdmin("Player flagged for suspected cheating")
    end

```

#### ⚙️ High Complexity
```lua
    -- Notify on repeated offenses with a counter
    local count = offenseCounts[steamID] or 0
    count = count + 1
    offenseCounts[steamID] = count
    lia.administrator.notifyAdmin(string.format("Player %s has %d infractions", steamID, count))

```

---

### lia.administrator.addPermission

#### 📋 Purpose
Grants a permission to a usergroup and saves the change

#### ⏰ When Called
When staff give a group a new ability (clear for non-developers)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the target usergroup |
| `permission` | **string** | Permission to add |
| `silent` | **boolean** | If true, skip broadcasting sync immediately (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.addPermission("helper", "command_kick")

```

#### 📊 Medium Complexity
```lua
    -- Add a permission quietly during setup
    lia.administrator.addPermission("vip", "canSpawnProps", true)

```

#### ⚙️ High Complexity
```lua
    -- Grant several permissions to a new role
    local perms = {"command_kick", "command_goto", "command_bring"}
    for _, perm in ipairs(perms) do
        lia.administrator.addPermission("juniorStaff", perm)
    end

```

---

### lia.administrator.removePermission

#### 📋 Purpose
Removes a permission from a usergroup and saves the change

#### ⏰ When Called
When staff revoke an ability from a group (simple for non-developers)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `groupName` | **string** | Name of the target usergroup |
| `permission` | **string** | Permission to remove |
| `silent` | **boolean** | If true, skip broadcasting sync immediately (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.removePermission("helper", "command_kick")

```

#### 📊 Medium Complexity
```lua
    -- Quietly remove a testing permission
    lia.administrator.removePermission("vip", "canSpawnProps", true)

```

#### ⚙️ High Complexity
```lua
    -- Strip several powers during a cleanup
    for _, perm in ipairs({"command_goto", "command_bring"}) do
        lia.administrator.removePermission("juniorStaff", perm)
    end

```

---

### lia.administrator.sync

#### 📋 Purpose
Sends current privileges and groups to players who are ready to receive them

#### ⏰ When Called
After changes or on demand to keep clients up to date

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `c` | **Player** | Specific player to sync; if nil, syncs all ready players (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Sync all ready players after edits
    lia.administrator.sync()

```

#### 📊 Medium Complexity
```lua
    -- Sync a single player who just connected
    lia.administrator.sync(newPlayer)

```

#### ⚙️ High Complexity
```lua
    -- Resync only if something changed
    if lia.administrator.hasChanges() then
        lia.administrator.sync()
    end

```

---

### lia.administrator.hasChanges

#### 📋 Purpose
Checks if admin groups or privileges differ from the last sync

#### ⏰ When Called
Before deciding to push updates to players

#### ↩️ Returns
* boolean

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    if lia.administrator.hasChanges() then
        print("Admin data changed")
    end

```

#### 📊 Medium Complexity
```lua
    -- Sync only when there is a difference
    if lia.administrator.hasChanges() then
        lia.administrator.sync()
    end

```

#### ⚙️ High Complexity
```lua
    -- Avoid redundant work in a timer
    timer.Create("CheckAdminChanges", 10, 0, function()
        if lia.administrator.hasChanges() then
            lia.administrator.sync()
        end
    end)

```

---

### lia.administrator.setPlayerUsergroup

#### 📋 Purpose
Sets a player's usergroup and notifies CAMI about the change

#### ⏰ When Called
When staff move a live player to a new group

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ply` | **Player** | Player to update |
| `newGroup` | **string** | Desired usergroup |
| `source` | **string** | Tag describing who/what made the change (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.setPlayerUsergroup(player, "helper")

```

#### 📊 Medium Complexity
```lua
    -- Track the source of the change
    lia.administrator.setPlayerUsergroup(player, "moderator", "PromotionMenu")

```

#### ⚙️ High Complexity
```lua
    -- Promote several players at once
    for _, ply in ipairs(staffList) do
        lia.administrator.setPlayerUsergroup(ply, "admin", "BulkPromotion")
    end

```

---

### lia.administrator.setSteamIDUsergroup

#### 📋 Purpose
Sets a usergroup for a SteamID and informs CAMI (works even if the player is offline)

#### ⏰ When Called
When updating ranks by SteamID directly

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamId` | **string** | Target SteamID |
| `newGroup` | **string** | Desired usergroup |
| `source` | **string** | Tag describing who/what made the change (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    lia.administrator.setSteamIDUsergroup("STEAM_0:1:12345", "helper")

```

#### 📊 Medium Complexity
```lua
    -- Record source for auditing
    lia.administrator.setSteamIDUsergroup("STEAM_0:1:54321", "moderator", "TicketSystem")

```

#### ⚙️ High Complexity
```lua
    -- Promote a list of SteamIDs
    for _, sid in ipairs(promotionList) do
        lia.administrator.setSteamIDUsergroup(sid, "admin", "BulkSteamPromotion")
    end

```

---

### lia.administrator.serverExecCommand

#### 📋 Purpose
Executes a server-side admin command (kick/ban/etc.) after checking privilege

#### ⏰ When Called
When an admin triggers a protected command against a target

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmd` | **string** | Command name (e.g., "kick", "ban") |
| `victim` | **Player|string** | Target player or identifier |
| `dur` | **number** | Duration for time-based commands (optional) |
| `reason` | **string** | Reason text (optional) |
| `admin` | **Player** | The admin issuing the command |

#### ↩️ Returns
* boolean

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Kick with a reason
    lia.administrator.serverExecCommand("kick", targetPlayer, nil, "Breaking rules", adminPlayer)

```

#### 📊 Medium Complexity
```lua
    -- Ban for 60 minutes
    lia.administrator.serverExecCommand("ban", targetPlayer, 60, "RDM", adminPlayer)

```

#### ⚙️ High Complexity
```lua
    -- Execute a list of actions on a target
    local actions = {
        {cmd = "mute", dur = 0, reason = "Spam"},
        {cmd = "gag", dur = 0, reason = "Voice spam"}
    }
    for _, action in ipairs(actions) do
        lia.administrator.serverExecCommand(action.cmd, targetPlayer, action.dur, action.reason, adminPlayer)
    end

```

---

### lia.administrator.execCommand

#### 📋 Purpose
Executes a server-side admin command (kick/ban/etc.) after checking privilege

#### ⏰ When Called
When an admin triggers a protected command against a target

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `cmd` | **string** | Command name (e.g., "kick", "ban") |
| `victim` | **Player|string** | Target player or identifier |
| `dur` | **number** | Duration for time-based commands (optional) |
| `reason` | **string** | Reason text (optional) |
| `admin` | **Player** | The admin issuing the command |

#### ↩️ Returns
* boolean

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Kick with a reason
    lia.administrator.serverExecCommand("kick", targetPlayer, nil, "Breaking rules", adminPlayer)

```

#### 📊 Medium Complexity
```lua
    -- Ban for 60 minutes
    lia.administrator.serverExecCommand("ban", targetPlayer, 60, "RDM", adminPlayer)

```

#### ⚙️ High Complexity
```lua
    -- Execute a list of actions on a target
    local actions = {
        {cmd = "mute", dur = 0, reason = "Spam"},
        {cmd = "gag", dur = 0, reason = "Voice spam"}
    }
    for _, action in ipairs(actions) do
        lia.administrator.serverExecCommand(action.cmd, targetPlayer, action.dur, action.reason, adminPlayer)
    end

```

---

