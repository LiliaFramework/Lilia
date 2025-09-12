# Administration Hooks

This page documents the hooks related to administration functionality in the Lilia framework.

---

## Overview

The administration hooks form the backbone of Lilia's administrative system, providing comprehensive control over user management, privilege handling, administrative interfaces, and system monitoring. These hooks serve as the primary integration points for customizing administrative functionality, extending core admin features, and implementing custom permission systems.

The administration system in Lilia is built around a hierarchical privilege-based architecture that allows for granular control over administrative actions. The hooks cover several key areas:

**User Group Management**: Hooks like `OnUsergroupCreated`, `OnUsergroupRemoved`, and `OnUsergroupRenamed` provide complete lifecycle management for user groups, allowing developers to implement custom group behaviors, logging, and data synchronization.

**Privilege System**: The privilege system is managed through `OnPrivilegeRegistered` and `OnPrivilegeUnregistered` hooks, enabling dynamic privilege registration and cleanup. The `OnAdminSystemLoaded` hook ensures proper initialization and synchronization of the entire admin system.

**Character Management**: Administrative character management is handled through `CharListColumns` and `CharListEntry` hooks, allowing for custom column definitions and data manipulation in character lists displayed to administrators.

**Interface Customization**: The `PopulateAdminTabs` hook enables complete customization of the F1 admin menu, while `AddToAdminStickHUD` allows for extending the admin stick's information display with custom data.

**Security and Access Control**: Hooks like `CanPlayerSeeLogCategory` and `PlayerGiveSWEP` provide fine-grained access control, allowing developers to implement custom security measures and permission checks.

**Command Interception**: The `RunAdminSystemCommand` hook enables external admin systems to integrate seamlessly with Lilia's command system, providing a unified interface for administrative actions.

These hooks work together to create a flexible, extensible administrative framework that can be adapted to various server configurations and administrative needs. They provide both high-level system integration points and low-level customization options, making them suitable for everything from simple permission tweaks to complete administrative system overhauls.

---

### AddToAdminStickHUD

**Purpose**

Extend the Admin Stick HUD with extra information by mutating the provided information table.

**Parameters**

* `client` (*Player*): Local player using the admin stick.
* `target` (*Entity*): Entity under the crosshair or selected by the admin stick.
* `information` (*table*): Array of strings to append additional lines to.

**Returns**

* `nil` (*nil*): This hook does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to extend the Admin Stick HUD with additional entity information.
-- The Admin Stick is a tool that allows administrators to inspect entities by pointing at them.
-- Each hook.Add call registers a different piece of information to display when an entity is targeted.

-- Display the model of the entity under the crosshair
hook.Add("AddToAdminStickHUD", "ShowTargetModel", function(client, target, information)
    -- Check if the target is valid and has a GetModel method
    if IsValid(target) and target.GetModel then
        -- Add the model information to the HUD display
        information[#information + 1] = L("model") .. ": " .. tostring(target:GetModel())
    end
end)

-- Display the health of the target entity
hook.Add("AddToAdminStickHUD", "ShowTargetHealth", function(client, target, information)
    -- Check if the target is valid and has a Health property
    if IsValid(target) and target.Health then
        -- Add the health information to the HUD display
        information[#information + 1] = L("health") .. ": " .. tostring(target:Health())
    end
end)

-- Display the class name of the target entity
hook.Add("AddToAdminStickHUD", "ShowTargetClass", function(client, target, information)
    -- Check if the target is valid and has a GetClass method
    if IsValid(target) and target.GetClass then
        -- Add the class information to the HUD display
        information[#information + 1] = L("class") .. ": " .. tostring(target:GetClass())
    end
end)

-- Display the position coordinates of the target entity
hook.Add("AddToAdminStickHUD", "ShowTargetPosition", function(client, target, information)
    -- Check if the target is valid and has a GetPos method
    if IsValid(target) and target.GetPos then
        -- Get the entity's position
        local pos = target:GetPos()
        -- Format and add the position information to the HUD display
        information[#information + 1] = L("position") .. ": " .. string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z)
    end
end)
```

---

### CanPlayerSeeLogCategory

**Purpose**

Determines if a player can view a specific log category in the admin console.

**Parameters**

* `client` (*Player*): Player requesting logs.
* `category` (*string*): Category name.

**Returns**

* `boolean` (*boolean*): False to hide the category, true or nil to show it.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to control which log categories players can view in the admin console.
-- The hook allows you to implement custom permission systems for log access based on player privileges.
-- Each hook.Add call shows different permission scenarios for log category visibility.

-- Hide OOC chat logs from non-admin players
hook.Add("CanPlayerSeeLogCategory", "HideChatLogs", function(ply, category)
    -- Check if the category is OOC chat and player is not admin
    if category == "chatOOC" and not ply:IsAdmin() then
        -- Hide the category from non-admin players
        return false
    end
end)

-- Restrict admin logs to super admins only
hook.Add("CanPlayerSeeLogCategory", "RestrictAdminLogs", function(ply, category)
    -- Check if the category is admin logs and player is not super admin
    if category == "admin" and not ply:IsSuperAdmin() then
        -- Hide admin logs from non-super admin players
        return false
    end
end)
```

---

### CharListColumns

**Purpose**

Customize columns shown in the Admin Character List. Mutate the `columns` array to add or adjust column definitions.

**Parameters**

* `columns` (*table*): Array of column descriptors. Each entry supports:
  * `name` (*string*): Column header text.
  * `field` (*string*): Key in the row to display.
  * `format` (*function* | optional): `(value, row) -> any` to transform display.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to customize the Admin Character List by adding custom columns.
-- The character list displays player characters in a table format for administrators to view and manage.
-- Each hook.Add call adds a different type of column with custom formatting for display.

-- Add a column to display hours played in a readable format
hook.Add("CharListColumns", "AddHoursPlayedColumn", function(columns)
    -- Insert a new column definition into the columns array
    table.insert(columns, {
        name = "hoursPlayed", -- Column header text
        field = "PlayTime", -- Field name from the data row
        format = function(seconds)
            -- Convert seconds to hours with one decimal place
            return string.format("%0.1f h", (tonumber(seconds) or 0) / 3600)
        end
    })
end)

-- Add a karma column to the character list
hook.Add("CharListColumns", "AddKarmaColumn", function(columns)
    -- Insert a karma column definition
    table.insert(columns, {
        name = "karma", -- Column header
        field = "Karma", -- Field name from the data
        format = function(value)
            -- Convert value to string, defaulting to 0 if nil
            return tostring(value or 0)
        end
    })
end)

-- Add a last seen column with formatted date
hook.Add("CharListColumns", "AddLastSeenColumn", function(columns)
    -- Insert a last seen column definition
    table.insert(columns, {
        name = "lastSeen", -- Column header
        field = "LastSeen", -- Field name from the data
        format = function(timestamp)
            -- Format timestamp as readable date and time
            return os.date("%Y-%m-%d %H:%M", tonumber(timestamp) or 0)
        end
    })
end)
```

---

### CharListEntry

**Purpose**

Adjust each character list entry as it is built server-side before sending to clients.

**Parameters**

* `entry` (*table*): Mutable payload row (keys like `ID`, `Name`, `SteamID`, etc.).
* `row` (*table*): Original database row for reference.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to modify character list entries before they are sent to clients.
-- The character list is built server-side and then sent to administrators for display.
-- Each hook.Add call adds different custom data fields to the character entries.

-- Add karma field to character list entries
hook.Add("CharListEntry", "AttachKarmaField", function(entry, row)
    -- Convert karma from database row to number and add to entry
    entry.Karma = tonumber(row.karma or 0)
end)

-- Add play time field to character list entries
hook.Add("CharListEntry", "AddPlayTime", function(entry, row)
    -- Convert playtime from database row to number and add to entry
    entry.PlayTime = tonumber(row.playtime or 0)
end)

-- Add last seen timestamp to character list entries
hook.Add("CharListEntry", "AddLastSeen", function(entry, row)
    -- Convert lastseen from database row to number and add to entry
    entry.LastSeen = tonumber(row.lastseen or 0)
end)

-- Add custom data field to character list entries
hook.Add("CharListEntry", "AddCustomData", function(entry, row)
    -- Add custom data field with fallback to "N/A" if not available
    entry.CustomField = row.custom_data or "N/A"
end)
```

---

### OnAdminSystemLoaded

**Purpose**

Called after admin usergroups and privileges are loaded and synchronized.

**Parameters**

* `groups` (*table*): Map of usergroup -> permissions table.
* `privileges` (*table*): Map of privilege ID -> minimum access group.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when the admin system has finished loading.
-- The admin system includes usergroups and privileges that are loaded from the database.
-- This hook is useful for initializing custom admin functionality or logging system status.

-- Debug hook to print all loaded privileges
hook.Add("OnAdminSystemLoaded", "AuditPrivileges", function(groups, privileges)
    -- Print all privileges to console for debugging
    PrintTable(privileges)
end)

-- Initialize custom groups and log their information
hook.Add("OnAdminSystemLoaded", "InitializeCustomGroups", function(groups, privileges)
    -- Iterate through all loaded groups
    for groupName, permissions in pairs(groups) do
        -- Print group information including permission count
        print("Loaded group:", groupName, "with", table.Count(permissions), "permissions")
    end
end)
```

---

### OnPrivilegeRegistered

**Purpose**

Triggered when a new admin privilege is registered.

**Parameters**

* `info` (*table*): Contains `Name`, `ID`, `MinAccess`, `Category`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when a new admin privilege is registered.
-- Privileges define what actions administrators can perform and their required access level.
-- This hook is useful for logging privilege registration or initializing privilege-specific functionality.

-- Announce when a new privilege is registered
hook.Add("OnPrivilegeRegistered", "AnnouncePrivilege", function(info)
    -- Print privilege information including ID and minimum access level
    print("Registered privilege:", info.ID, "(min:", info.MinAccess .. ")")
end)

-- Log privilege registration to server log
hook.Add("OnPrivilegeRegistered", "LogPrivilegeRegistration", function(info)
    -- Write privilege registration to server log file
    ServerLog("Privilege registered: " .. info.Name .. " (" .. info.ID .. ")\n")
end)
```

---

### OnPrivilegeUnregistered

**Purpose**

Triggered when a privilege is unregistered.

**Parameters**

* `info` (*table*): Contains `Name`, `ID`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to respond when an admin privilege is unregistered.
-- This hook is useful for cleanup operations when privileges are removed from the system.
-- It can be used for logging, data cleanup, or notifying administrators of privilege changes.

-- Log when a privilege is removed
hook.Add("OnPrivilegeUnregistered", "LogPrivRemoval", function(info)
    -- Print the removed privilege ID to console
    print("Removed privilege:", info.ID)
end)

-- Clean up privilege data and log to server
hook.Add("OnPrivilegeUnregistered", "CleanupPrivilegeData", function(info)
    -- Write privilege unregistration to server log file
    ServerLog("Privilege unregistered: " .. info.Name .. " (" .. info.ID .. ")\n")
end)
```

---

### OnUsergroupCreated

**Purpose**

Fires after a new usergroup is created.

**Parameters**

* `groupName` (*string*): Name of the new group.
* `groupData` (*table*): Permissions and metadata for the group.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when a new usergroup is created.
-- Usergroups define permission levels and access rights for players.
-- This hook is useful for initializing group-specific data or logging group creation.

-- Log when a new usergroup is created
hook.Add("OnUsergroupCreated", "LogNewGroup", function(groupName, groupData)
    -- Print the new group name to console
    print("New usergroup created:", groupName)
    -- Print the group data table for debugging
    PrintTable(groupData)
end)

-- Initialize default values for new groups
hook.Add("OnUsergroupCreated", "InitializeGroupDefaults", function(groupName, groupData)
    -- Set default color if none is specified
    if not groupData.color then
        groupData.color = Color(255, 255, 255) -- White color as default
    end
end)
```

---

### OnUsergroupPermissionsChanged

**Purpose**

Fires when a usergroup's permissions are modified.

**Parameters**

* `groupName` (*string*): Name of the usergroup whose permissions changed.
* `groupData` (*table*): Updated permissions/metadata.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when a usergroup's permissions are modified.
-- This hook is useful for logging permission changes and notifying administrators.
-- It can be used to maintain audit trails and keep admins informed of permission updates.

-- Log when usergroup permissions are changed
hook.Add("OnUsergroupPermissionsChanged", "LogPermissionChanges", function(groupName, groupData)
    -- Print which group's permissions changed
    print("Permissions changed for group:", groupName)
    -- Print the updated group data for debugging
    PrintTable(groupData)
end)

-- Notify all admins when permissions change
hook.Add("OnUsergroupPermissionsChanged", "NotifyAdmins", function(groupName, groupData)
    -- Iterate through all players
    for _, ply in pairs(player.GetAll()) do
        -- Check if player is an admin
        if ply:IsAdmin() then
            -- Send notification about permission changes
            ply:ChatPrint("Group '" .. groupName .. "' permissions have been updated.")
        end
    end
end)
```

---

### OnUsergroupRemoved

**Purpose**

Fires after a usergroup is removed.

**Parameters**

* `groupName` (*string*): Name of the removed usergroup.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when a usergroup is removed from the system.
-- This hook is useful for cleanup operations and logging when groups are deleted.
-- It can be used to maintain audit trails and clean up group-specific data.

-- Log when a usergroup is removed
hook.Add("OnUsergroupRemoved", "LogGroupRemoval", function(groupName)
    -- Print the removed group name to console
    print("Usergroup removed:", groupName)
end)

-- Clean up group data and log to server
hook.Add("OnUsergroupRemoved", "CleanupGroupData", function(groupName)
    -- Write group removal to server log file
    ServerLog("Usergroup '" .. groupName .. "' has been removed.\n")
end)
```

---

### OnUsergroupRenamed

**Purpose**

Fires after a usergroup is renamed.

**Parameters**

* `oldName` (*string*): Previous name of the usergroup.
* `newName` (*string*): New name of the usergroup.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to respond when a usergroup is renamed.
-- This hook is useful for updating references and logging group name changes.
-- It can be used to maintain data consistency when group names are modified.

-- Log when a usergroup is renamed
hook.Add("OnUsergroupRenamed", "LogGroupRename", function(oldName, newName)
    -- Print the rename information to console
    print("Usergroup renamed from", oldName, "to", newName)
end)

-- Update references and log to server
hook.Add("OnUsergroupRenamed", "UpdateReferences", function(oldName, newName)
    -- Write group rename to server log file
    ServerLog("Usergroup renamed from '" .. oldName .. "' to '" .. newName .. "'\n")
end)
```

---

### PlayerGiveSWEP

**Purpose**

Gate giving a SWEP to an entity (e.g., via context menu tools). Return `true` to allow; any falsy value denies.

**Parameters**

* `ply` (*Player*): Initiator.
* `class` (*string*): Weapon class name.
* `swep` (*table*): SWEP data table (from `list.Get("Weapon")`).

**Returns**

* `allow` (*boolean*): True to allow giving the SWEP, false or nil to deny.

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to control weapon giving through the context menu or admin tools.
-- SWEPs (Scripted Weapons) can be given to entities using various admin tools.
-- This hook allows you to implement custom permission checks and logging for weapon distribution.

-- Restrict SWEP giving based on privilege
hook.Add("PlayerGiveSWEP", "RestrictNPCWeapons", function(ply, class, swep)
    -- Check if player has the required privilege
    return ply:hasPrivilege("canSpawnSWEPs")
end)

-- Log when weapons are given to entities
hook.Add("PlayerGiveSWEP", "LogWeaponGiving", function(ply, class, swep)
    -- Write weapon giving action to server log
    ServerLog(ply:Nick() .. " gave SWEP: " .. class .. "\n")
end)

-- Restrict admin-only weapons to super admins
hook.Add("PlayerGiveSWEP", "RestrictAdminWeapons", function(ply, class, swep)
    -- Check if weapon class contains "admin" and player is not super admin
    if string.find(class, "admin") and not ply:IsSuperAdmin() then
        -- Deny giving admin weapons to non-super admins
        return false
    end
end)
```

---

### PopulateAdminTabs

**Purpose**

Populate the Admin tab in the F1 menu. Mutate the provided `pages` array and insert page descriptors.

**Parameters**

* `pages` (*table*): Insert items like `{ name = string, icon = string, drawFunc = function(panel) end }`.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

**Client**

**Example Usage**

```lua
-- This example demonstrates how to add custom tabs to the F1 admin menu.
-- The admin menu provides a centralized interface for administrative functions.
-- Each hook.Add call adds a different tab with custom content and functionality.

-- Add an online players list tab to the admin menu
hook.Add("PopulateAdminTabs", "AddOnlineList", function(pages)
    -- Insert a new page descriptor into the pages array
    pages[#pages + 1] = {
        name = "onlinePlayers", -- Tab name
        icon = "icon16/user.png", -- Tab icon
        drawFunc = function(panel)
            -- Create a list view for displaying players
            local list = vgui.Create("DListView")
            -- Set size to fill most of the panel with margins
            list:SetSize(panel:GetWide() - 20, panel:GetTall() - 20)
            -- Position with margin from top-left
            list:SetPos(10, 10)
            -- Add columns for player information
            list:AddColumn("Name")
            list:AddColumn("SteamID")
            list:AddColumn("Ping")
            -- Add the list to the panel
            panel:Add(list)
        end
    }
end)

-- Add a server information tab to the admin menu
hook.Add("PopulateAdminTabs", "AddServerInfo", function(pages)
    -- Insert a new page descriptor for server info
    pages[#pages + 1] = {
        name = "serverInfo", -- Tab name
        icon = "icon16/information.png", -- Tab icon
        drawFunc = function(panel)
            -- Create a label to display server information
            local info = vgui.Create("DLabel")
            -- Set text to show server hostname
            info:SetText("Server: " .. GetHostName())
            -- Position the label
            info:SetPos(10, 10)
            -- Add the label to the panel
            panel:Add(info)
        end
    }
end)
```

---

### RunAdminSystemCommand

**Purpose**

Allows external admin mods to intercept and handle admin actions. Returning `true` prevents the default command behaviour.

**Parameters**

* `cmd` (*string*): Action identifier such as `kick` or `ban`.
* `executor` (*Player* | *nil*): Player running the command, if any.
* `target` (*Player* | *string*): Target player or SteamID.
* `duration` (*number* | *nil*): Optional duration for timed actions.
* `reason` (*string* | *nil*): Optional reason text.

**Returns**

* `boolean` (*boolean*): Return `true` if the command was handled.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to intercept and handle admin commands from external systems.
-- This hook allows integration with other admin mods or custom command handling.
-- Each hook.Add call shows different approaches to command interception and processing.

-- Integrate with SAM (Simple Admin Mod)
hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, exec, victim, dur, reason)
    -- Check if SAM is available and has the command
    if SAM and SAM.Commands[cmd] then
        -- Execute the SAM command with the provided parameters
        SAM.Commands[cmd](exec, victim, dur, reason)
        -- Return true to prevent default behavior
        return true
    end
end)

-- Custom kick command handler
hook.Add("RunAdminSystemCommand", "CustomKickHandler", function(cmd, executor, target, duration, reason)
    -- Check if this is a kick command and executor is valid
    if cmd == "kick" and IsValid(executor) then
        -- Check if executor has admin privileges
        if not executor:IsAdmin() then
            -- Send error message to executor
            executor:ChatPrint("You don't have permission to kick players!")
            -- Return true to prevent default behavior
            return true
        end
        
        -- Check if target is valid
        if IsValid(target) then
            -- Kick the target player with reason or default message
            target:Kick(reason or "Kicked by admin")
            -- Log the kick action to server log
            ServerLog(executor:Nick() .. " kicked " .. target:Nick() .. " (" .. (reason or "No reason") .. ")\n")
        end
        -- Return true to indicate command was handled
        return true
    end
end)
```

---

### OverrideFactionName

**Purpose**

Override a faction's display name during registration/loading.

**Parameters**

* `uniqueID` (*string*): Faction unique ID.
* `currentName` (*string*): Current localized name.

**Returns**

* `newName` (*string* | *nil*): New name to use, or nil to keep existing.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to override faction display names during registration.
-- Factions are groups that players can join, each with their own name and properties.
-- This hook allows you to customize how faction names appear throughout the game.

-- Override faction display names
hook.Add("OverrideFactionName", "CustomFactionNames", function(uniqueID, currentName)
    -- Customize specific faction names
    if uniqueID == "police" then
        return "Metro Police Department"
    elseif uniqueID == "fire" then
        return "Fire & Rescue Service"
    end
    -- Return nil to keep original name
end)
```

---

### OverrideFactionDesc

**Purpose**

Override a faction's description during registration/loading.

**Parameters**

* `uniqueID` (*string*): Faction unique ID.
* `currentDesc` (*string*): Current localized description.

**Returns**

* `newDesc` (*string* | *nil*): New description to use, or nil to keep existing.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to override faction descriptions during registration.
-- Faction descriptions provide information about what each faction does and represents.
-- This hook allows you to customize how faction descriptions appear in the UI.

-- Override faction descriptions
hook.Add("OverrideFactionDesc", "CustomFactionDescs", function(uniqueID, currentDesc)
    -- Customize specific faction descriptions
    if uniqueID == "police" then
        return "Metro's finest law enforcement officers dedicated to protecting and serving the community."
    elseif uniqueID == "fire" then
        return "Emergency response team specializing in fire suppression and rescue operations."
    end
    -- Return nil to keep original description
end)
```

---

### OverrideFactionModels

**Purpose**

Override a faction's models table during registration/loading.

**Parameters**

* `uniqueID` (*string*): Faction unique ID.
* `currentModels` (*table*): Models table.

**Returns**

* `models` (*table* | *nil*): Replacement models table, or nil to keep existing.

**Realm**

**Shared**

**Example Usage**

```lua
-- This example demonstrates how to override faction models during registration.
-- Faction models define what player models are available for each faction.
-- This hook allows you to customize which models players can use when joining a faction.

-- Override faction models
hook.Add("OverrideFactionModels", "CustomFactionModels", function(uniqueID, currentModels)
    -- Customize specific faction models
    if uniqueID == "police" then
        return {
            "models/player/police.mdl",
            "models/player/police_female.mdl"
        }
    elseif uniqueID == "fire" then
        return {
            "models/player/firefighter.mdl"
        }
    end
    -- Return nil to keep original models
end)
```

---

### PlayerSay

**Purpose**

Invoked when a client sends chat text through the chatbox network path. Note: in this context the return value is ignored; use it for side effects.

**Parameters**

* `client` (*Player*): The player who sent the chat message.
* `text` (*string*): The chat message text.

**Returns**

* `nil` (*nil*): This function does not return a value. (ignored in this invocation path)

**Realm**

**Server**

**Example Usage**

```lua
-- This example demonstrates how to process and filter chat messages from players.
-- The PlayerSay hook is called when a player sends a message through the chat system.
-- This hook is useful for logging, moderation, and content filtering.

-- Log all chat messages for moderation
hook.Add("PlayerSay", "LogChatMessages", function(client, text)
    -- Log the chat message with player information
    ServerLog(client:Nick() .. " said: " .. text .. "\n")
end)

-- Filter inappropriate language
hook.Add("PlayerSay", "FilterLanguage", function(client, text)
    -- Check for inappropriate words and replace them
    local filteredText = string.gsub(text, "badword", "***")
    if filteredText ~= text then
        -- Notify the player about filtered content
        client:ChatPrint("Your message contained inappropriate language and was filtered.")
    end
end)
```