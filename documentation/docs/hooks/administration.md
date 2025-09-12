## Administration

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

Client.

**Example Usage**

```lua
hook.Add("AddToAdminStickHUD", "ShowTargetModel", function(client, target, information)
    if IsValid(target) and target.GetModel then
        information[#information + 1] = L("model") .. ": " .. tostring(target:GetModel())
    end
end)

hook.Add("AddToAdminStickHUD", "ShowTargetHealth", function(client, target, information)
    if IsValid(target) and target.Health then
        information[#information + 1] = L("health") .. ": " .. tostring(target:Health())
    end
end)

hook.Add("AddToAdminStickHUD", "ShowTargetClass", function(client, target, information)
    if IsValid(target) and target.GetClass then
        information[#information + 1] = L("class") .. ": " .. tostring(target:GetClass())
    end
end)

hook.Add("AddToAdminStickHUD", "ShowTargetPosition", function(client, target, information)
    if IsValid(target) and target.GetPos then
        local pos = target:GetPos()
        information[#information + 1] = L("position") .. ": " .. string.format("%.1f, %.1f, %.1f", pos.x, pos.y, pos.z)
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
hook.Add("CharListColumns", "AddHoursPlayedColumn", function(columns)
    table.insert(columns, {
        name = "hoursPlayed",
        field = "PlayTime",
        format = function(seconds)
            return string.format("%0.1f h", (tonumber(seconds) or 0) / 3600)
        end
    })
end)

hook.Add("CharListColumns", "AddKarmaColumn", function(columns)
    table.insert(columns, {
        name = "karma",
        field = "Karma",
        format = function(value)
            return tostring(value or 0)
        end
    })
end)

hook.Add("CharListColumns", "AddLastSeenColumn", function(columns)
    table.insert(columns, {
        name = "lastSeen",
        field = "LastSeen",
        format = function(timestamp)
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
hook.Add("CharListEntry", "AttachKarmaField", function(entry, row)
    entry.Karma = tonumber(row.karma or 0)
end)

hook.Add("CharListEntry", "AddPlayTime", function(entry, row)
    entry.PlayTime = tonumber(row.playtime or 0)
end)

hook.Add("CharListEntry", "AddLastSeen", function(entry, row)
    entry.LastSeen = tonumber(row.lastseen or 0)
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
hook.Add("OnAdminSystemLoaded", "AuditPrivileges", function(groups, privileges)
    PrintTable(privileges)
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
hook.Add("OnPrivilegeRegistered", "AnnouncePrivilege", function(info)
    print("Registered privilege:", info.ID, "(min:", info.MinAccess .. ")")
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
hook.Add("OnPrivilegeUnregistered", "LogPrivRemoval", function(info)
    print("Removed privilege:", info.ID)
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
hook.Add("OnUsergroupCreated", "LogNewGroup", function(groupName, groupData)
    print("New usergroup created:", groupName)
    PrintTable(groupData)
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
hook.Add("OnUsergroupRemoved", "LogGroupRemoval", function(groupName)
    print("Usergroup removed:", groupName)
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
hook.Add("OnUsergroupRenamed", "LogGroupRename", function(oldName, newName)
    print("Usergroup renamed from", oldName, "to", newName)
end)
```

---

### PopulateAdminTabs

**Purpose**

Populate the Admin tab in the F1 menu. Mutate the provided `pages` array and insert page descriptors.

**Parameters**

* `pages` (*table*): Insert items like `{ name = string, icon = string, drawFunc = function(panel) end }`.

**Returns**

Client

**Realm**

*** `nil` (*nil*): This function does not return a value.

**Example Usage**

```lua
hook.Add("PopulateAdminTabs", "AddOnlineList", function(pages)
    pages[#pages + 1] = {
        name = "onlinePlayers",
        icon = "icon16/user.png",
        drawFunc = function(panel)
            -- build UI here
        end
    }
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

- boolean: False to hide the category

**Realm**

**Server**

**Example Usage**

```lua
hook.Add("CanPlayerSeeLogCategory", "HideChatLogs", function(ply, category)
    if category == "chatOOC" and not ply:IsAdmin() then
        return false
    end
end)
```

---

### RunAdminSystemCommand

**Purpose**

Allows external admin mods to intercept and handle admin actions. Returning

`true` prevents the default command behaviour.

**Parameters**

* `cmd` (*string*): Action identifier such as `kick` or `ban`.
* `executor` (*Player* | *nil*): Player running the command, if any.
* `target` (*Player* | *string*): Target player or SteamID.
* `duration` (*number* | *nil*): Optional duration for timed actions.
* `reason` (*string* | *nil*): Optional reason text.

**Returns**

Shared

**Realm**

*** `boolean?`: Return `true` if the command was handled.**

**Example Usage**

```lua
hook.Add("RunAdminSystemCommand", "liaSam", function(cmd, exec, victim, dur, reason)
    if SAM and SAM.Commands[cmd] then
        SAM.Commands[cmd](exec, victim, dur, reason)
        return true
    end
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

**Realm**

**Server**

**Returns**

* `allow` (*boolean*): True to allow giving the SWEP, false or nil to deny.

**Example Usage**

```lua
hook.Add("PlayerGiveSWEP", "RestrictNPCWeapons", function(ply, class, swep)
    return ply:hasPrivilege("canSpawnSWEPs")
end)
```


