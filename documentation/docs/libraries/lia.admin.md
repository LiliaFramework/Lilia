# Admin Library

This page explains the built-in administration system.

---

## Overview

The admin library manages user groups, privileges, and bans. It automatically disables itself when the SAM or ServerGuard admin mods are detected.

The base user groups `user`, `admin`, and `superadmin` are created automatically and cannot be removed.

---

### lia.admin.isDisabled

**Purpose**

Checks for third-party admin mods and returns `true` when the built-in system should be ignored.

**Parameters**

*None*

**Realm**

`Shared`

**Returns**

* `boolean`: Whether an external admin mod is loaded.

---

### lia.admin.load

**Purpose**

Loads stored admin groups and privileges from disk.

**Parameters**

*None*

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.createGroup

**Purpose**

Creates a new user group with an optional table of permissions.

**Parameters**

* `groupName` (*string*): Name of the group.
* `info` (*table*): Table of permissions. Optional.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.registerPrivilege

**Purpose**

Registers a CAMI privilege for use with permission checks.

**Parameters**

* `privilege` (*table*): Table containing the privilege definition.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.removeGroup

**Purpose**

Deletes a previously created user group. The built-in groups `user`, `admin`, and `superadmin` are protected and cannot be removed.

**Parameters**

* `groupName` (*string*): Name of the group to remove.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.addPermission

**Purpose**

Grants a permission flag to a specific group.

**Parameters**

* `groupName` (*string*): Target group.
* `permission` (*string*): Permission identifier.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.removePermission

**Purpose**

Revokes a permission flag from a group.

**Parameters**

* `groupName` (*string*): Target group.
* `permission` (*string*): Permission identifier to remove.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.save

**Purpose**

Writes the current group table to disk and optionally networks it to clients.

**Parameters**

* `network` (*boolean*): When `true`, broadcasts the updated groups to clients.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.setPlayerGroup

**Purpose**

Changes the user group of a player and records it in the database.

**Parameters**

* `ply` (*Player*): Player to modify.
* `usergroup` (*string*): Group identifier.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.addBan

**Purpose**

Creates a ban entry for a SteamID.

**Parameters**

* `steamid` (*string*): SteamID64 of the player.
* `reason` (*string*): Ban reason. Optional.
* `duration` (*number*): Ban length in minutes. Optional.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.removeBan

**Purpose**

Removes an existing ban.

**Parameters**

* `steamid` (*string*): SteamID64 of the ban to lift.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

---

### lia.admin.isBanned

**Purpose**

Retrieves the ban entry for a SteamID if present.

**Parameters**

* `steamid` (*string*): SteamID64 to check.

**Realm**

`Shared`

**Returns**

* `table | false`: Ban data or `false` when not banned.

---

### lia.admin.hasBanExpired

**Purpose**

Determines whether a given ban has expired.

**Parameters**

* `steamid` (*string*): SteamID64 to check.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the ban is no longer active.

---
