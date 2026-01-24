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

<details class="realm-shared">
<summary><a id=lia.admin.applyPunishment></a>lia.admin.applyPunishment(client, infraction, kick, ban, time, kickKey, banKey)</summary>
<a id="liaadminapplypunishment"></a>
<p>Applies kick or ban punishments to a player based on the provided parameters.</p>
<p>Called when an automated system or admin action needs to punish a player with a kick or ban.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">client</span> The player to punish.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">infraction</span> Description of the infraction that caused the punishment.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">kick</span> Whether to kick the player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">ban</span> Whether to ban the player.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">time</span> Ban duration in minutes (only used if ban is true).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">kickKey</span> Localization key for kick message (defaults to "kickedForInfraction").</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">banKey</span> Localization key for ban message (defaults to "bannedForInfraction").</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Kick a player for spamming
    lia.admin.applyPunishment(player, "Spamming in chat", true, false, nil, nil, nil)
    -- Ban a player for griefing for 24 hours
    lia.admin.applyPunishment(player, "Griefing", false, true, 1440, nil, nil)
    -- Both kick and ban with custom messages
    lia.admin.applyPunishment(player, "Hacking", true, true, 10080, "kickedForHacking", "bannedForHacking")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.hasAccess></a>lia.admin.hasAccess(ply, privilege)</summary>
<a id="liaadminhasaccess"></a>
<p>Checks if a player has access to a specific privilege based on their usergroup and privilege requirements.</p>
<p>Called when verifying if a player can perform an action that requires specific permissions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|string</a></span> <span class="parameter">ply</span> The player to check access for, or a usergroup string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">privilege</span> The privilege ID to check access for (e.g., "command_kick", "property_door", "tool_remover").</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the player has access to the privilege, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Check if player can use kick command
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
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.save></a>lia.admin.save(noNetwork)</summary>
<a id="liaadminsave"></a>
<p>Saves administrator group configurations and privileges to the database.</p>
<p>Called when administrator settings are modified and need to be persisted, or when syncing with clients.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">noNetwork</span> If true, skips network synchronization with clients after saving.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Save admin groups without network sync
    lia.admin.save(true)
    -- Save and sync with all clients
    lia.admin.save(false)
    -- or simply:
    lia.admin.save()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.registerPrivilege></a>lia.admin.registerPrivilege(priv, ID, Name, MinAccess, Category)</summary>
<a id="liaadminregisterprivilege"></a>
<p>Registers a new privilege in the administrator system with specified access levels and categories.</p>
<p>Called when defining new administrative permissions that can be granted to user groups.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">priv</span> Privilege configuration table with the following fields:</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">ID</span> Unique identifier for the privilege (required)</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">Name</span> Display name for the privilege (optional, defaults to ID)</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">MinAccess</span> Minimum usergroup required ("user", "admin", "superadmin")</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">Category</span> Category for organizing privileges in menus</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Register a custom admin command privilege
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
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.unregisterPrivilege></a>lia.admin.unregisterPrivilege(id)</summary>
<a id="liaadminunregisterprivilege"></a>
<p>Removes a privilege from the administrator system and cleans up all associated data.</p>
<p>Called when a privilege is no longer needed or when cleaning up removed permissions.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">id</span> The privilege ID to unregister.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Unregister a custom privilege
    lia.admin.unregisterPrivilege("command_customban")
    -- Clean up a tool privilege
    lia.admin.unregisterPrivilege("tool_remover")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.applyInheritance></a>lia.admin.applyInheritance(groupName)</summary>
<a id="liaadminapplyinheritance"></a>
<p>Applies privilege inheritance to a usergroup, copying permissions from parent groups and ensuring appropriate access levels.</p>
<p>Called when setting up or updating usergroup permissions to ensure inheritance rules are properly applied.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> The name of the usergroup to apply inheritance to.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Apply inheritance to a moderator group
    lia.admin.applyInheritance("moderator")
    -- Apply inheritance after creating a new usergroup
    lia.admin.applyInheritance("customadmin")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.load></a>lia.admin.load()</summary>
<a id="liaadminload"></a>
<p>Loads administrator group configurations from the database and initializes the admin system.</p>
<p>Called during server startup to restore saved administrator settings and permissions.</p>
<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Load admin system (called automatically during server initialization)
    lia.admin.load()
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.createGroup></a>lia.admin.createGroup(groupName, info)</summary>
<a id="liaadmincreategroup"></a>
<p>Creates a new administrator usergroup with specified configuration and inheritance.</p>
<p>Called when setting up new administrator roles or permission levels in the system.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> The name of the usergroup to create.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.5">table</a></span> <span class="parameter">info</span> Optional configuration table for the group (privileges, inheritance, etc.).</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Create a moderator group
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
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.removeGroup></a>lia.admin.removeGroup(groupName)</summary>
<a id="liaadminremovegroup"></a>
<p>Removes an administrator usergroup from the system.</p>
<p>Called when cleaning up or removing unused administrator roles.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> The name of the usergroup to remove.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Remove a custom moderator group
    lia.admin.removeGroup("moderator")
    -- Remove a custom admin group
    lia.admin.removeGroup("customadmin")
</code></pre>
</details>

---

<details class="realm-shared">
<summary><a id=lia.admin.renameGroup></a>lia.admin.renameGroup(oldName, newName)</summary>
<a id="liaadminrenamegroup"></a>
<p>Renames an existing administrator usergroup to a new name.</p>
<p>Called when reorganizing or rebranding administrator roles.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">oldName</span> The current name of the usergroup to rename.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">newName</span> The new name for the usergroup.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Rename moderator group to staff
    lia.admin.renameGroup("moderator", "staff")
    -- Rename admin group to administrator
    lia.admin.renameGroup("admin", "administrator")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.notifyAdmin></a>lia.admin.notifyAdmin(notification)</summary>
<a id="liaadminnotifyadmin"></a>
<p>Sends a notification to all administrators who have permission to see admin notifications.</p>
<p>Called when important administrative events need to be communicated to staff.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">notification</span> The notification message key to send.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Notify admins of a potential exploit
    lia.admin.notifyAdmin("exploitDetected")
    -- Notify admins of a player report
    lia.admin.notifyAdmin("playerReportReceived")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.addPermission></a>lia.admin.addPermission(groupName, permission, silent)</summary>
<a id="liaadminaddpermission"></a>
<p>Grants a specific permission to an administrator usergroup.</p>
<p>Called when configuring permissions for administrator roles.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> The name of the usergroup to grant the permission to.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">permission</span> The permission ID to grant.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">silent</span> If true, skips network synchronization.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Grant kick permission to moderators
    lia.admin.addPermission("moderator", "command_kick", false)
    -- Grant ban permission to admins silently
    lia.admin.addPermission("admin", "command_ban", true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.removePermission></a>lia.admin.removePermission(groupName, permission, silent)</summary>
<a id="liaadminremovepermission"></a>
<p>Removes a specific permission from an administrator usergroup.</p>
<p>Called when revoking permissions from administrator roles.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">groupName</span> The name of the usergroup to remove the permission from.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">permission</span> The permission ID to remove.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> <span class="parameter">silent</span> If true, skips network synchronization.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Remove kick permission from moderators
    lia.admin.removePermission("moderator", "command_kick", false)
    -- Remove ban permission from admins silently
    lia.admin.removePermission("admin", "command_ban", true)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.sync></a>lia.admin.sync(c)</summary>
<a id="liaadminsync"></a>
<p>Synchronizes administrator privileges and usergroups with clients.</p>
<p>Called when administrator data changes and needs to be updated on clients, or when a player joins.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">c</span> Optional specific client to sync with. If not provided, syncs with all clients in batches.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Sync admin data with all clients
    lia.admin.sync()
    -- Sync admin data with a specific player
    lia.admin.sync(specificPlayer)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.hasChanges></a>lia.admin.hasChanges()</summary>
<a id="liaadminhaschanges"></a>
<p>Checks if administrator privileges or groups have changed since the last sync.</p>
<p>Called to determine if a sync operation is needed.</p>
<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if there are unsynced changes, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Check if admin data needs syncing
    if lia.admin.hasChanges() then
        lia.admin.sync()
    end
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.setPlayerUsergroup></a>lia.admin.setPlayerUsergroup(ply, newGroup, source)</summary>
<a id="liaadminsetplayerusergroup"></a>
<p>Sets the usergroup of a player entity.</p>
<p>Called when promoting, demoting, or changing a player's administrative role.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">ply</span> The player to change the usergroup for.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">newGroup</span> The new usergroup name to assign.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">source</span> Optional source identifier for logging.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Promote player to admin
    lia.admin.setPlayerUsergroup(player, "admin", "promotion")
    -- Demote player to user
    lia.admin.setPlayerUsergroup(player, "user", "demotion")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.setSteamIDUsergroup></a>lia.admin.setSteamIDUsergroup(steamId, newGroup, source)</summary>
<a id="liaadminsetsteamidusergroup"></a>
<p>Sets the usergroup of a player by their SteamID.</p>
<p>Called when changing a player's usergroup using their SteamID, useful for offline players.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">steamId</span> The SteamID of the player to change the usergroup for.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">newGroup</span> The new usergroup name to assign.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">source</span> Optional source identifier for logging.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Set offline player's usergroup to admin
    lia.admin.setSteamIDUsergroup("STEAM_0:1:12345678", "admin", "promotion")
    -- Demote player by SteamID
    lia.admin.setSteamIDUsergroup("STEAM_0:1:12345678", "user", "demotion")
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.serverExecCommand></a>lia.admin.serverExecCommand(cmd, victim, dur, reason, admin)</summary>
<a id="liaadminserverexeccommand"></a>
<p>Executes administrative commands on players with proper permission checking and logging.</p>
<p>Called when an administrator uses commands like kick, ban, mute, gag, freeze, slay, bring, goto, etc.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">cmd</span> The command to execute (e.g., "kick", "ban", "mute", "gag", "freeze", "slay", "bring", "goto", "return", "jail", "cloak", "god", "ignite", "strip", "respawn", "blind").</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|string</a></span> <span class="parameter">victim</span> The target player entity or SteamID string.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number|string</a></span> <span class="parameter">dur</span> Duration for commands that support time limits (ban, freeze, blind, ignite).</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">reason</span> Reason for the action (used in kick, ban, etc.).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player</a></span> <span class="parameter">admin</span> The administrator executing the command.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the command was executed successfully, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Kick a player for spamming
    lia.admin.serverExecCommand("kick", targetPlayer, nil, "Spamming in chat", adminPlayer)
    -- Ban a player for 24 hours
    lia.admin.serverExecCommand("ban", targetPlayer, 1440, "Griefing", adminPlayer)
    -- Mute a player
    lia.admin.serverExecCommand("mute", targetPlayer, nil, nil, adminPlayer)
    -- Bring a player to admin's position
    lia.admin.serverExecCommand("bring", targetPlayer, nil, nil, adminPlayer)
</code></pre>
</details>

---

<details class="realm-server">
<summary><a id=lia.admin.execCommand></a>lia.admin.execCommand(cmd, victim, dur, reason)</summary>
<a id="liaadminexeccommand"></a>
<p>Executes an administrative command using the client-side command system.</p>
<p>Called when running admin commands through console commands or automated systems.</p>
<p><h3>Parameters:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">cmd</span> The command to execute (e.g., "kick", "ban", "mute", "freeze", etc.).</p>
<p><span class="types"><a class="type" href="https://wiki.facepunch.com/gmod/Player">Player|string</a></span> <span class="parameter">victim</span> The target player or identifier.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.3">number</a></span> <span class="parameter">dur</span> Duration for time-based commands.</p>
<p><span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.4">string</a></span> <span class="parameter">reason</span> Reason for the administrative action.</p>

<p><h3>Returns:</h3>
<span class="types"><a class="type" href="https://www.lua.org/manual/5.1/manual.html#5.2">boolean</a></span> true if the command was executed successfully, false otherwise.</p>

<h3>Example Usage:</h3>
<pre><code class="language-lua">    -- Kick a player via console command
    lia.admin.execCommand("kick", targetPlayer, nil, "Rule violation")
    -- Ban a player for 24 hours
    lia.admin.execCommand("ban", targetPlayer, 1440, "Griefing")
</code></pre>
</details>

---

