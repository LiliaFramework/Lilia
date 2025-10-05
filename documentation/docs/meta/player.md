# Player Meta

This page documents methods available on the `Player` meta table, representing connected human players in the Lilia framework.

---

## Overview

The `Player` meta table extends Garry's Mod's base player functionality with Lilia-specific features including character management, privilege checking, vehicle handling, movement detection, money management, flag systems, data persistence, and various utility functions. These methods provide comprehensive player management capabilities for roleplay servers and other gameplay systems within the Lilia framework.

---

### tostring

**Purpose**

Returns a string representation of the player.

**Parameters**

*None.*

**Returns**

* `string` (*string*): String representation of the player.

**Realm**

Shared.

**Example Usage**

```lua
local function logPlayer(player)
    print("Player info: " .. tostring(player))
end
```

---

### getChar

**Purpose**

Gets the player's current character.

**Parameters**

*None.*

**Returns**

* `character` (*Character|nil*): The player's current character if loaded.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerCharacter(player)
    local char = player:getChar()
    if char then
        player:ChatPrint("You have a character loaded: " .. char:getName())
        return char
    else
        player:ChatPrint("You don't have a character loaded.")
        return nil
    end
end

concommand.Add("check_char", function(ply)
    checkPlayerCharacter(ply)
end)
```

---

### Name

**Purpose**

Gets the player's display name, preferring character name over Steam name.

**Parameters**

*None.*

**Returns**

* `name` (*string*): The player's display name.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayerName(player)
    local name = player:Name()
    print("Player name: " .. name)
end

hook.Add("PlayerSay", "DisplayName", function(ply, text)
    if text == "!myname" then
        displayPlayerName(ply)
    end
end)
```

---

### hasPrivilege

**Purpose**

Checks if the player has a specific privilege.

**Parameters**

* `privilegeName` (*string*): The privilege name to check.

**Returns**

* `hasPrivilege` (*boolean*): True if the player has the privilege.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerPrivilege(player, privilege)
    if player:hasPrivilege(privilege) then
        player:ChatPrint("You have the " .. privilege .. " privilege!")
        return true
    else
        player:ChatPrint("You don't have the " .. privilege .. " privilege.")
        return false
    end
end

concommand.Add("check_privilege", function(ply, cmd, args)
    local privilege = args[1]
    if privilege then
        checkPlayerPrivilege(ply, privilege)
    end
end)
```

---

### getCurrentVehicle

**Purpose**

Gets the vehicle the player is currently in.

**Parameters**

*None.*

**Returns**

* `vehicle` (*Entity|nil*): The vehicle if the player is in one.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerVehicle(player)
    local vehicle = player:getCurrentVehicle()
    if IsValid(vehicle) then
        player:ChatPrint("You are in a " .. vehicle:GetClass())
        return vehicle
    else
        player:ChatPrint("You are not in a vehicle.")
        return nil
    end
end

concommand.Add("check_vehicle", function(ply)
    checkPlayerVehicle(ply)
end)
```

---

### hasValidVehicle

**Purpose**

Checks if the player is in a valid vehicle.

**Parameters**

*None.*

**Returns**

* `hasVehicle` (*boolean*): True if the player is in a valid vehicle.

**Realm**

Shared.

**Example Usage**

```lua
local function handleVehicleAction(player)
    if player:hasValidVehicle() then
        player:ChatPrint("You can perform vehicle actions!")
        return true
    else
        player:ChatPrint("You need to be in a vehicle to do that.")
        return false
    end
end

concommand.Add("vehicle_action", function(ply)
    handleVehicleAction(ply)
end)
```

---

### isNoClipping

**Purpose**

Checks if the player is no-clipping and not in a vehicle.

**Parameters**

*None.*

**Returns**

* `isNoClipping` (*boolean*): True if the player is no-clipping.

**Realm**

Shared.

**Example Usage**

```lua
local function checkNoClipStatus(player)
    if player:isNoClipping() then
        player:ChatPrint("You are no-clipping!")
        return true
    else
        player:ChatPrint("You are not no-clipping.")
        return false
    end
end

concommand.Add("check_noclip", function(ply)
    checkNoClipStatus(ply)
end)
```

---

### removeRagdoll

**Purpose**

Removes the player's ragdoll if it exists.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function cleanupPlayerRagdoll(player)
    player:removeRagdoll()
    player:ChatPrint("Ragdoll removed!")
end

concommand.Add("remove_ragdoll", function(ply)
    cleanupPlayerRagdoll(ply)
end)
```

---

### getRagdoll

**Purpose**

Gets the player's current ragdoll entity.

**Parameters**

*None.*

**Returns**

* `ragdoll` (*Entity|nil*): The ragdoll entity if it exists.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerRagdoll(player)
    local ragdoll = player:getRagdoll()
    if IsValid(ragdoll) then
        player:ChatPrint("You have a ragdoll at position: " .. tostring(ragdoll:GetPos()))
        return ragdoll
    else
        player:ChatPrint("You don't have a ragdoll.")
        return nil
    end
end

concommand.Add("check_ragdoll", function(ply)
    checkPlayerRagdoll(ply)
end)
```

---

### isStuck

**Purpose**

Checks if the player is stuck in a wall or object.

**Parameters**

*None.*

**Returns**

* `isStuck` (*boolean*): True if the player is stuck.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerStuck(player)
    if player:isStuck() then
        player:ChatPrint("You are stuck! Teleporting to spawn...")
        player:Spawn()
        return true
    else
        player:ChatPrint("You are not stuck.")
        return false
    end
end

concommand.Add("check_stuck", function(ply)
    checkPlayerStuck(ply)
end)
```

---

### isNearPlayer

**Purpose**

Checks if the player is near another entity within a specified radius.

**Parameters**

* `radius` (*number*): The radius to check within.
* `entity` (*Entity*): The entity to check proximity to.

**Returns**

* `isNear` (*boolean*): True if the player is within the radius.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerProximity(player, target, radius)
    if player:isNearPlayer(radius, target) then
        player:ChatPrint("You are near " .. target:GetClass())
        return true
    else
        player:ChatPrint("You are not near " .. target:GetClass())
        return false
    end
end

concommand.Add("check_proximity", function(ply, cmd, args)
    local radius = tonumber(args[1]) or 100
    local target = ply:getTracedEntity()
    if IsValid(target) then
        checkPlayerProximity(ply, target, radius)
    end
end)
```

---

### entitiesNearPlayer

**Purpose**

Gets all entities near the player within a specified radius.

**Parameters**

* `radius` (*number*): The radius to search within.
* `playerOnly` (*boolean|nil*): Whether to only return player entities.

**Returns**

* `entities` (*table*): Array of nearby entities.

**Realm**

Shared.

**Example Usage**

```lua
local function listNearbyEntities(player, radius, playerOnly)
    local entities = player:entitiesNearPlayer(radius, playerOnly)
    player:ChatPrint("Found " .. #entities .. " nearby entities:")
    for i, ent in ipairs(entities) do
        player:ChatPrint("  " .. i .. ". " .. ent:GetClass())
    end
end

concommand.Add("list_nearby", function(ply, cmd, args)
    local radius = tonumber(args[1]) or 100
    local playerOnly = tobool(args[2])
    listNearbyEntities(ply, radius, playerOnly)
end)
```

---

### getItemWeapon

**Purpose**

Gets the weapon and item associated with the player's active weapon.

**Parameters**

*None.*

**Returns**

* `weapon` (*Weapon|nil*): The weapon entity if it's an item weapon.
* `item` (*Item|nil*): The associated item if found.

**Realm**

Shared.

**Example Usage**

```lua
local function checkItemWeapon(player)
    local weapon, item = player:getItemWeapon()
    if IsValid(weapon) and item then
        player:ChatPrint("You have an item weapon: " .. item:getName())
        return weapon, item
    else
        player:ChatPrint("You don't have an item weapon equipped.")
        return nil, nil
    end
end

concommand.Add("check_item_weapon", function(ply)
    checkItemWeapon(ply)
end)
```

---

### isRunning

**Purpose**

Checks if the player is currently running.

**Parameters**

*None.*

**Returns**

* `isRunning` (*boolean*): True if the player is running.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerRunning(player)
    if player:isRunning() then
        player:ChatPrint("You are running!")
        return true
    else
        player:ChatPrint("You are not running.")
        return false
    end
end

concommand.Add("check_running", function(ply)
    checkPlayerRunning(ply)
end)
```

---

### IsFamilySharedAccount

**Purpose**

Checks if the player is using a family shared Steam account.

**Parameters**

*None.*

**Returns**

* `isFamilyShared` (*boolean*): True if the account is family shared.

**Realm**

Shared.

**Example Usage**

```lua
local function checkFamilyShared(player)
    if player:IsFamilySharedAccount() then
        player:ChatPrint("You are using a family shared account.")
        return true
    else
        player:ChatPrint("You are using your own account.")
        return false
    end
end

concommand.Add("check_family_shared", function(ply)
    checkFamilyShared(ply)
end)
```

---

### getItemDropPos

**Purpose**

Gets the position where items should be dropped from the player.

**Parameters**

*None.*

**Returns**

* `position` (*Vector*): The drop position.

**Realm**

Shared.

**Example Usage**

```lua
local function getDropPosition(player)
    local pos = player:getItemDropPos()
    player:ChatPrint("Drop position: " .. tostring(pos))
    return pos
end

concommand.Add("get_drop_pos", function(ply)
    getDropPosition(ply)
end)
```

---

### getItems

**Purpose**

Gets all items in the player's character's inventory.

**Parameters**

*None.*

**Returns**

* `items` (*table|nil*): Table of items if the player has a character.

**Realm**

Shared.

**Example Usage**

```lua
local function listPlayerItems(player)
    local items = player:getItems()
    if items then
        player:ChatPrint("You have " .. table.Count(items) .. " items:")
        for itemID, item in pairs(items) do
            player:ChatPrint("  " .. item:getName() .. " (ID: " .. itemID .. ")")
        end
    else
        player:ChatPrint("You don't have any items.")
    end
end

concommand.Add("list_items", function(ply)
    listPlayerItems(ply)
end)
```

---

### getTracedEntity

**Purpose**

Gets the entity the player is looking at within a specified distance.

**Parameters**

* `distance` (*number|nil*): Maximum distance to trace (default: 96).

**Returns**

* `entity` (*Entity|nil*): The traced entity if found.

**Realm**

Shared.

**Example Usage**

```lua
local function getLookedAtEntity(player, distance)
    local entity = player:getTracedEntity(distance)
    if IsValid(entity) then
        player:ChatPrint("You are looking at: " .. entity:GetClass())
        return entity
    else
        player:ChatPrint("You are not looking at anything.")
        return nil
    end
end

concommand.Add("look_at", function(ply, cmd, args)
    local distance = tonumber(args[1]) or 96
    getLookedAtEntity(ply, distance)
end)
```

---

### getTrace

**Purpose**

Gets a trace result from the player's view with hull collision.

**Parameters**

* `distance` (*number|nil*): Maximum distance to trace (default: 200).

**Returns**

* `trace` (*table*): The trace result table.

**Realm**

Shared.

**Example Usage**

```lua
local function getPlayerTrace(player, distance)
    local trace = player:getTrace(distance)
    if trace.Hit then
        player:ChatPrint("Trace hit: " .. trace.Entity:GetClass() .. " at " .. tostring(trace.HitPos))
        return trace
    else
        player:ChatPrint("Trace didn't hit anything.")
        return trace
    end
end

concommand.Add("trace", function(ply, cmd, args)
    local distance = tonumber(args[1]) or 200
    getPlayerTrace(ply, distance)
end)
```

---

### getEyeEnt

**Purpose**

Gets the entity the player is looking at within a specified distance.

**Parameters**

* `distance` (*number|nil*): Maximum distance to check (default: 150).

**Returns**

* `entity` (*Entity|nil*): The entity if within distance.

**Realm**

Shared.

**Example Usage**

```lua
local function getEyeEntity(player, distance)
    local entity = player:getEyeEnt(distance)
    if IsValid(entity) then
        player:ChatPrint("You see: " .. entity:GetClass())
        return entity
    else
        player:ChatPrint("You don't see anything.")
        return nil
    end
end

concommand.Add("eye_entity", function(ply, cmd, args)
    local distance = tonumber(args[1]) or 150
    getEyeEntity(ply, distance)
end)
```

---

### notify

**Purpose**

Sends a notification to the player.

**Parameters**

* `message` (*string*): The notification message.
* `notifType` (*string*): The type of notification (e.g., "default", "error", "success", "info").
* `...` (*any*): Additional arguments for the notification.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function sendPlayerNotification(player, message, notifType)
    player:notify(message, notifType or "default")
end

concommand.Add("notify", function(ply, cmd, args)
    local message = table.concat(args, " ")
    local notifType = args[#args] -- Last argument as notification type
    if message ~= "" then
        sendPlayerNotification(ply, message, notifType)
    end
end)
```

---

### notifyLocalized

**Purpose**

Sends a localized notification to the player.

**Parameters**

* `message` (*string*): The localized message key.
* `notifType` (*string*): The type of notification (e.g., "default", "error", "success", "info").
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function sendLocalizedNotification(player, messageKey, notifType, ...)
    player:notifyLocalized(messageKey, notifType or "default", ...)
end

concommand.Add("notify_localized", function(ply, cmd, args)
    local messageKey = args[1]
    local notifType = args[2] -- Second argument as notification type
    if messageKey then
        local localizationArgs = {}
        for i = 3, #args do
            table.insert(localizationArgs, args[i])
        end
        sendLocalizedNotification(ply, messageKey, notifType, unpack(localizationArgs))
    end
end)
```

---

### notifyError

**Purpose**

Sends an error notification to the player with red styling and exclamation icon.

**Parameters**

* `message` (*string*): The error message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function handleDatabaseError(player, errorMsg)
    player:notifyError("Database error: " .. errorMsg)
end

concommand.Add("test_error", function(ply)
    ply:notifyError("This is an error notification!")
end)
```

---

### notifyWarning

**Purpose**

Sends a warning notification to the player with yellow/orange styling and error icon.

**Parameters**

* `message` (*string*): The warning message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function warnPlayer(player, action)
    player:notifyWarning("Warning: " .. action .. " may have consequences!")
end

concommand.Add("test_warning", function(ply)
    ply:notifyWarning("This is a warning notification!")
end)
```

---

### notifyInfo

**Purpose**

Sends an informational notification to the player with blue styling and information icon.

**Parameters**

* `message` (*string*): The informational message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function informPlayer(player, info)
    player:notifyInfo("Information: " .. info)
end

concommand.Add("test_info", function(ply)
    ply:notifyInfo("This is an info notification!")
end)
```

---

### notifySuccess

**Purpose**

Sends a success notification to the player with green styling and accept icon.

**Parameters**

* `message` (*string*): The success message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function confirmSuccess(player, action)
    player:notifySuccess("Successfully completed: " .. action)
end

concommand.Add("test_success", function(ply)
    ply:notifySuccess("This is a success notification!")
end)
```

---

### notifyMoney

**Purpose**

Sends a money-related notification to the player with green styling and money icon.

**Parameters**

* `message` (*string*): The money message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function notifyMoneyChange(player, amount, reason)
    player:notifyMoney("Money " .. reason .. ": $" .. amount)
end

concommand.Add("test_money", function(ply)
    ply:notifyMoney("You received $100!")
end)
```

---

### notifyAdmin

**Purpose**

Sends an admin notification to the player with purple styling and shield icon.

**Parameters**

* `message` (*string*): The admin message to display.
* `...` (*any*): Additional arguments (unused, for consistency with other methods).

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function adminAction(player, action)
    player:notifyAdmin("Admin action: " .. action)
end

concommand.Add("test_admin", function(ply)
    ply:notifyAdmin("This is an admin notification!")
end)
```

---

### notifyErrorLocalized

**Purpose**

Sends a localized error notification to the player with red styling and exclamation icon.

**Parameters**

* `key` (*string*): The localization key for the error message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function handleLocalizedError(player, errorKey, ...)
    player:notifyErrorLocalized(errorKey, ...)
end

concommand.Add("test_error_localized", function(ply)
    ply:notifyErrorLocalized("errorDatabaseConnection", "localhost")
end)
```

---

### notifyWarningLocalized

**Purpose**

Sends a localized warning notification to the player with yellow/orange styling and error icon.

**Parameters**

* `key` (*string*): The localization key for the warning message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function warnPlayerLocalized(player, warningKey, ...)
    player:notifyWarningLocalized(warningKey, ...)
end

concommand.Add("test_warning_localized", function(ply)
    ply:notifyWarningLocalized("warningActionConsequences", "deleting character")
end)
```

---

### notifyInfoLocalized

**Purpose**

Sends a localized informational notification to the player with blue styling and information icon.

**Parameters**

* `key` (*string*): The localization key for the informational message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function informPlayerLocalized(player, infoKey, ...)
    player:notifyInfoLocalized(infoKey, ...)
end

concommand.Add("test_info_localized", function(ply)
    ply:notifyInfoLocalized("infoServerRestart", "5 minutes")
end)
```

---

### notifySuccessLocalized

**Purpose**

Sends a localized success notification to the player with green styling and accept icon.

**Parameters**

* `key` (*string*): The localization key for the success message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function confirmSuccessLocalized(player, successKey, ...)
    player:notifySuccessLocalized(successKey, ...)
end

concommand.Add("test_success_localized", function(ply)
    ply:notifySuccessLocalized("successCharacterCreated", "John Doe")
end)
```

---

### notifyMoneyLocalized

**Purpose**

Sends a localized money-related notification to the player with green styling and money icon.

**Parameters**

* `key` (*string*): The localization key for the money message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function notifyMoneyChangeLocalized(player, moneyKey, ...)
    player:notifyMoneyLocalized(moneyKey, ...)
end

concommand.Add("test_money_localized", function(ply)
    ply:notifyMoneyLocalized("moneyReceived", 100, "quest completion")
end)
```

---

### notifyAdminLocalized

**Purpose**

Sends a localized admin notification to the player with purple styling and shield icon.

**Parameters**

* `key` (*string*): The localization key for the admin message.
* `...` (*any*): Additional arguments for localization.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function adminActionLocalized(player, adminKey, ...)
    player:notifyAdminLocalized(adminKey, ...)
end

concommand.Add("test_admin_localized", function(ply)
    ply:notifyAdminLocalized("adminActionPerformed", "kick player")
end)
```

---

### CanEditVendor

**Purpose**

Checks if the player can edit vendors.

**Parameters**

* `vendor` (*Entity*): The vendor entity to check.

**Returns**

* `canEdit` (*boolean*): True if the player can edit the vendor.

**Realm**

Shared.

**Example Usage**

```lua
local function checkVendorEditPermission(player, vendor)
    if player:CanEditVendor(vendor) then
        player:ChatPrint("You can edit this vendor!")
        return true
    else
        player:ChatPrint("You cannot edit this vendor.")
        return false
    end
end

concommand.Add("check_vendor_edit", function(ply)
    local vendor = ply:getTracedEntity()
    if IsValid(vendor) and vendor:GetClass() == "lia_vendor" then
        checkVendorEditPermission(ply, vendor)
    end
end)
```

---

### isStaff

**Purpose**

Checks if the player is a staff member.

**Parameters**

*None.*

**Returns**

* `isStaff` (*boolean*): True if the player is staff.

**Realm**

Shared.

**Example Usage**

```lua
local function checkStaffStatus(player)
    if player:isStaff() then
        player:ChatPrint("You are a staff member!")
        return true
    else
        player:ChatPrint("You are not a staff member.")
        return false
    end
end

concommand.Add("check_staff", function(ply)
    checkStaffStatus(ply)
end)
```

---

### isVIP

**Purpose**

Checks if the player is a VIP member.

**Parameters**

*None.*

**Returns**

* `isVIP` (*boolean*): True if the player is VIP.

**Realm**

Shared.

**Example Usage**

```lua
local function checkVIPStatus(player)
    if player:isVIP() then
        player:ChatPrint("You are a VIP member!")
        return true
    else
        player:ChatPrint("You are not a VIP member.")
        return false
    end
end

concommand.Add("check_vip", function(ply)
    checkVIPStatus(ply)
end)
```

---

### isStaffOnDuty

**Purpose**

Checks if the player is staff and on duty.

**Parameters**

*None.*

**Returns**

* `isOnDuty` (*boolean*): True if the player is staff on duty.

**Realm**

Shared.

**Example Usage**

```lua
local function checkStaffDuty(player)
    if player:isStaffOnDuty() then
        player:ChatPrint("You are staff and on duty!")
        return true
    else
        player:ChatPrint("You are not staff on duty.")
        return false
    end
end

concommand.Add("check_staff_duty", function(ply)
    checkStaffDuty(ply)
end)
```

---

### isFaction

**Purpose**

Checks if the player's character belongs to a specific faction.

**Parameters**

* `faction` (*string*): The faction name to check.

**Returns**

* `isFaction` (*boolean*): True if the character belongs to the faction.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerFaction(player, faction)
    if player:isFaction(faction) then
        player:ChatPrint("You belong to the " .. faction .. " faction!")
        return true
    else
        player:ChatPrint("You don't belong to the " .. faction .. " faction.")
        return false
    end
end

concommand.Add("check_faction", function(ply, cmd, args)
    local faction = args[1]
    if faction then
        checkPlayerFaction(ply, faction)
    end
end)
```

---

### isClass

**Purpose**

Checks if the player's character belongs to a specific class.

**Parameters**

* `class` (*string*): The class name to check.

**Returns**

* `isClass` (*boolean*): True if the character belongs to the class.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerClass(player, className)
    if player:isClass(className) then
        player:ChatPrint("You are a " .. className .. "!")
        return true
    else
        player:ChatPrint("You are not a " .. className .. ".")
        return false
    end
end

concommand.Add("check_class", function(ply, cmd, args)
    local className = args[1]
    if className then
        checkPlayerClass(ply, className)
    end
end)
```

---

### hasWhitelist

**Purpose**

Checks if the player has whitelist access to a specific faction.

**Parameters**

* `faction` (*string*): The faction name to check.

**Returns**

* `hasWhitelist` (*boolean*): True if the player has whitelist access.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerWhitelist(player, faction)
    if player:hasWhitelist(faction) then
        player:ChatPrint("You have whitelist access to " .. faction .. "!")
        return true
    else
        player:ChatPrint("You don't have whitelist access to " .. faction .. ".")
        return false
    end
end

concommand.Add("check_whitelist", function(ply, cmd, args)
    local faction = args[1]
    if faction then
        checkPlayerWhitelist(ply, faction)
    end
end)
```

---

### getClass

**Purpose**

Gets the player's character's class.

**Parameters**

*None.*

**Returns**

* `class` (*string|nil*): The character's class if loaded.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayerClass(player)
    local class = player:getClass()
    if class then
        player:ChatPrint("Your class: " .. class)
        return class
    else
        player:ChatPrint("You don't have a class loaded.")
        return nil
    end
end

concommand.Add("my_class", function(ply)
    displayPlayerClass(ply)
end)
```

---

### hasClassWhitelist

**Purpose**

Checks if the player's character has whitelist access to a specific class.

**Parameters**

* `class` (*string*): The class name to check.

**Returns**

* `hasWhitelist` (*boolean*): True if the character has class whitelist access.

**Realm**

Shared.

**Example Usage**

```lua
local function checkClassWhitelist(player, className)
    if player:hasClassWhitelist(className) then
        player:ChatPrint("You have whitelist access to " .. className .. " class!")
        return true
    else
        player:ChatPrint("You don't have whitelist access to " .. className .. " class.")
        return false
    end
end

concommand.Add("check_class_whitelist", function(ply, cmd, args)
    local className = args[1]
    if className then
        checkClassWhitelist(ply, className)
    end
end)
```

---

### getClassData

**Purpose**

Gets the data for the player's character's class.

**Parameters**

*None.*

**Returns**

* `classData` (*table|nil*): The class data if the character has a class.

**Realm**

Shared.

**Example Usage**

```lua
local function displayClassData(player)
    local classData = player:getClassData()
    if classData then
        player:ChatPrint("Class data:")
        for key, value in pairs(classData) do
            player:ChatPrint("  " .. key .. ": " .. tostring(value))
        end
        return classData
    else
        player:ChatPrint("You don't have class data.")
        return nil
    end
end

concommand.Add("class_data", function(ply)
    displayClassData(ply)
end)
```

---

### getDarkRPVar

**Purpose**

Gets a DarkRP variable value for compatibility.

**Parameters**

* `var` (*string*): The variable name to get.

**Returns**

* `value` (*any*): The variable value.

**Realm**

Shared.

**Example Usage**

```lua
local function getDarkRPMoney(player)
    local money = player:getDarkRPVar("money")
    if money then
        player:ChatPrint("DarkRP Money: " .. money)
        return money
    end
end

concommand.Add("darkrp_money", function(ply)
    getDarkRPMoney(ply)
end)
```

---

### getMoney

**Purpose**

Gets the player's character's money.

**Parameters**

*None.*

**Returns**

* `money` (*number*): The character's money amount.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayerMoney(player)
    local money = player:getMoney()
    player:ChatPrint("You have " .. money .. " money.")
    return money
end

concommand.Add("my_money", function(ply)
    displayPlayerMoney(ply)
end)
```

---

### canAfford

**Purpose**

Checks if the player's character can afford a specific amount.

**Parameters**

* `amount` (*number*): The amount to check.

**Returns**

* `canAfford` (*boolean*): True if the character can afford the amount.

**Realm**

Shared.

**Example Usage**

```lua
local function checkAffordability(player, amount)
    if player:canAfford(amount) then
        player:ChatPrint("You can afford " .. amount .. " money!")
        return true
    else
        player:ChatPrint("You cannot afford " .. amount .. " money.")
        return false
    end
end

concommand.Add("check_afford", function(ply, cmd, args)
    local amount = tonumber(args[1])
    if amount then
        checkAffordability(ply, amount)
    end
end)
```

---

### hasSkillLevel

**Purpose**

Checks if the player's character has a specific skill level.

**Parameters**

* `skill` (*string*): The skill name to check.
* `level` (*number*): The required level.

**Returns**

* `hasLevel` (*boolean*): True if the character has the required level.

**Realm**

Shared.

**Example Usage**

```lua
local function checkSkillLevel(player, skill, level)
    if player:hasSkillLevel(skill, level) then
        player:ChatPrint("You have " .. skill .. " level " .. level .. " or higher!")
        return true
    else
        player:ChatPrint("You don't have " .. skill .. " level " .. level .. ".")
        return false
    end
end

concommand.Add("check_skill", function(ply, cmd, args)
    local skill = args[1]
    local level = tonumber(args[2])
    if skill and level then
        checkSkillLevel(ply, skill, level)
    end
end)
```

---

### meetsRequiredSkills

**Purpose**

Checks if the player meets all required skill levels.

**Parameters**

* `requiredSkillLevels` (*table|nil*): Table of skill names and required levels.

**Returns**

* `meetsRequirements` (*boolean*): True if all requirements are met.

**Realm**

Shared.

**Example Usage**

```lua
local function checkRequiredSkills(player, requirements)
    if player:meetsRequiredSkills(requirements) then
        player:ChatPrint("You meet all skill requirements!")
        return true
    else
        player:ChatPrint("You don't meet all skill requirements.")
        return false
    end
end

concommand.Add("check_skills", function(ply)
    local requirements = {
        strength = 5,
        intelligence = 3
    }
    checkRequiredSkills(ply, requirements)
end)
```

---

### restoreStamina

**Purpose**

Restores the player's stamina by a specified amount.

**Parameters**

* `amount` (*number*): The amount of stamina to restore.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function restorePlayerStamina(player, amount)
    player:restoreStamina(amount)
    player:ChatPrint("Restored " .. amount .. " stamina!")
end

concommand.Add("restore_stamina", function(ply, cmd, args)
    local amount = tonumber(args[1]) or 10
    restorePlayerStamina(ply, amount)
end)
```

---

### consumeStamina

**Purpose**

Consumes the player's stamina by a specified amount.

**Parameters**

* `amount` (*number*): The amount of stamina to consume.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function consumePlayerStamina(player, amount)
    player:consumeStamina(amount)
    player:ChatPrint("Consumed " .. amount .. " stamina!")
end

concommand.Add("consume_stamina", function(ply, cmd, args)
    local amount = tonumber(args[1]) or 10
    consumePlayerStamina(ply, amount)
end)
```

---

### addMoney

**Purpose**

Adds money to the player's character.

**Parameters**

* `amount` (*number*): The amount of money to add.

**Returns**

* `success` (*boolean*): True if the money was added successfully.

**Realm**

Server.

**Example Usage**

```lua
local function givePlayerMoney(player, amount)
    if player:addMoney(amount) then
        player:ChatPrint("You received " .. amount .. " money!")
        return true
    else
        player:ChatPrint("Failed to add money.")
        return false
    end
end

concommand.Add("give_money", function(ply, cmd, args)
    local amount = tonumber(args[1])
    if amount then
        givePlayerMoney(ply, amount)
    end
end)
```

---

### takeMoney

**Purpose**

Takes money from the player's character.

**Parameters**

* `amount` (*number*): The amount of money to take.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function takePlayerMoney(player, amount)
    player:takeMoney(amount)
    player:ChatPrint("You lost " .. amount .. " money!")
end

concommand.Add("take_money", function(ply, cmd, args)
    local amount = tonumber(args[1])
    if amount then
        takePlayerMoney(ply, amount)
    end
end)
```

---

### setLiliaData

**Purpose**

Sets persistent data for the player.

**Parameters**

* `key` (*string*): The data key to set.
* `value` (*any*): The value to set.
* `noNetworking` (*boolean|nil*): Whether to skip network replication.
* `noSave` (*boolean|nil*): Whether to skip database saving.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerData(player, key, value)
    player:setLiliaData(key, value)
    player:ChatPrint("Set " .. key .. " to " .. tostring(value))
end

concommand.Add("set_data", function(ply, cmd, args)
    local key = args[1]
    local value = args[2]
    if key and value then
        setPlayerData(ply, key, value)
    end
end)
```

---

### getLiliaData

**Purpose**

Gets persistent data for the player.

**Parameters**

* `key` (*string*): The data key to get.
* `default` (*any*): Default value if the key doesn't exist.

**Returns**

* `value` (*any*): The data value or default.

**Realm**

Shared.

**Example Usage**

```lua
local function getPlayerData(player, key)
    local value = player:getLiliaData(key, "not set")
    player:ChatPrint(key .. ": " .. tostring(value))
    return value
end

concommand.Add("get_data", function(ply, cmd, args)
    local key = args[1]
    if key then
        getPlayerData(ply, key)
    end
end)
```

---

### getFlags

**Purpose**

Gets the player's flags for a specific type.

**Parameters**

* `flagType` (*string|nil*): The flag type to get ("player" or nil for character flags).

**Returns**

* `flags` (*string*): The player's flags.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayerFlags(player, flagType)
    local flags = player:getFlags(flagType)
    local typeName = flagType or "character"
    player:ChatPrint(typeName .. " flags: " .. flags)
    return flags
end

concommand.Add("my_flags", function(ply, cmd, args)
    local flagType = args[1]
    displayPlayerFlags(ply, flagType)
end)
```

---

### setFlags

**Purpose**

Sets the player's flags for a specific type.

**Parameters**

* `flags` (*string*): The flags to set.
* `flagType` (*string|nil*): The flag type to set ("player" or nil for character flags).

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerFlags(player, flags, flagType)
    player:setFlags(flags, flagType)
    local typeName = flagType or "character"
    player:ChatPrint("Set " .. typeName .. " flags to: " .. flags)
end

concommand.Add("set_flags", function(ply, cmd, args)
    local flags = args[1]
    local flagType = args[2]
    if flags then
        setPlayerFlags(ply, flags, flagType)
    end
end)
```

---

### hasFlags

**Purpose**

Checks if the player has any of the specified flags.

**Parameters**

* `flags` (*string*): The flags to check for.

**Returns**

* `hasFlags` (*boolean*): True if the player has any of the flags.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayerFlags(player, flags)
    if player:hasFlags(flags) then
        player:ChatPrint("You have the required flags!")
        return true
    else
        player:ChatPrint("You don't have the required flags.")
        return false
    end
end

concommand.Add("check_flags", function(ply, cmd, args)
    local flags = args[1]
    if flags then
        checkPlayerFlags(ply, flags)
    end
end)
```

---

### doGesture

**Purpose**

Makes the player perform a gesture animation and synchronizes it across all clients.

**Parameters**

* `a` (*number*): The gesture slot (0-255).
* `b` (*number*): The gesture type (0-255).
* `c` (*boolean*): Whether the gesture should loop.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function makePlayerGesture(player, slot, gestureType, loop)
    player:doGesture(slot, gestureType, loop)
    player:ChatPrint("Playing gesture in slot " .. slot)
end

concommand.Add("do_gesture", function(ply, cmd, args)
    local slot = tonumber(args[1]) or 1
    local gestureType = tonumber(args[2]) or 1
    local loop = tobool(args[3])
    makePlayerGesture(ply, slot, gestureType, loop)
end)
```

---

### forceSequence

**Purpose**

Forces the player to play a specific animation sequence.

**Parameters**

* `sequenceName` (*string|nil*): The name of the sequence to play, or nil to stop current sequence.
* `callback` (*function|nil*): Function to call when the sequence completes.
* `time` (*number|nil*): Duration of the sequence (defaults to sequence duration).
* `noFreeze` (*boolean|nil*): Whether to prevent freezing the player during sequence.

**Returns**

* `duration` (*number|false*): The duration of the sequence, or false if invalid.

**Realm**

Shared.

**Example Usage**

```lua
local function playPlayerSequence(player, sequenceName, duration)
    local result = player:forceSequence(sequenceName, function()
        player:ChatPrint("Sequence completed!")
    end, duration)
    
    if result then
        player:ChatPrint("Playing sequence for " .. result .. " seconds")
    else
        player:ChatPrint("Invalid sequence name")
    end
end

concommand.Add("play_sequence", function(ply, cmd, args)
    local sequenceName = args[1]
    local duration = tonumber(args[2])
    if sequenceName then
        playPlayerSequence(ply, sequenceName, duration)
    end
end)
```

---

### leaveSequence

**Purpose**

Stops the current animation sequence and restores normal movement.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function stopPlayerSequence(player)
    player:leaveSequence()
    player:ChatPrint("Sequence stopped!")
end

concommand.Add("stop_sequence", function(ply)
    stopPlayerSequence(ply)
end)
```

---

### NetworkAnimation

**Purpose**

Synchronizes bone animations across the network for all players.

**Parameters**

* `active` (*boolean*): Whether the animation is active.
* `boneData` (*table*): Table of bone names and their angle data.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function animatePlayerBones(player, active, boneData)
    player:NetworkAnimation(active, boneData)
    player:ChatPrint("Bone animation " .. (active and "started" or "stopped"))
end

concommand.Add("animate_bones", function(ply, cmd, args)
    local active = tobool(args[1])
    local boneData = {
        ["ValveBiped.Bip01_Head1"] = Angle(0, 0, 0),
        ["ValveBiped.Bip01_Spine2"] = Angle(0, 0, 0)
    }
    animatePlayerBones(ply, active, boneData)
end)
```


---

### classWhitelist

**Purpose**

Gives the player's character whitelist access to a specific class.

**Parameters**

* `class` (*string*): The class name to whitelist.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function whitelistClass(player, className)
    player:classWhitelist(className)
    player:ChatPrint("You now have access to " .. className .. " class!")
end

concommand.Add("whitelist_class", function(ply, cmd, args)
    local className = args[1]
    if className then
        whitelistClass(ply, className)
    end
end)
```

---

### classUnWhitelist

**Purpose**

Removes the player's character whitelist access to a specific class.

**Parameters**

* `class` (*string*): The class name to remove whitelist access from.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function unwhitelistClass(player, className)
    player:classUnWhitelist(className)
    player:ChatPrint("You no longer have access to " .. className .. " class!")
end

concommand.Add("unwhitelist_class", function(ply, cmd, args)
    local className = args[1]
    if className then
        unwhitelistClass(ply, className)
    end
end)
```

---

### setWhitelisted

**Purpose**

Sets the player's whitelist status for a specific faction.

**Parameters**

* `faction` (*string*): The faction name to set whitelist for.
* `whitelisted` (*boolean|nil*): Whether to whitelist (true) or remove whitelist (nil/false).

**Returns**

* `success` (*boolean*): True if the whitelist was set successfully.

**Realm**

Server.

**Example Usage**

```lua
local function setFactionWhitelist(player, faction, whitelisted)
    if player:setWhitelisted(faction, whitelisted) then
        local status = whitelisted and "whitelisted" or "unwhitelisted"
        player:ChatPrint("You are now " .. status .. " for " .. faction .. " faction!")
    else
        player:ChatPrint("Failed to set whitelist for " .. faction .. " faction.")
    end
end

concommand.Add("set_faction_whitelist", function(ply, cmd, args)
    local faction = args[1]
    local whitelisted = tobool(args[2])
    if faction then
        setFactionWhitelist(ply, faction, whitelisted)
    end
end)
```

---

### loadLiliaData

**Purpose**

Loads persistent player data from the database.

**Parameters**

* `callback` (*function|nil*): Function to call when data is loaded.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function loadPlayerData(player)
    player:loadLiliaData(function(data)
        player:ChatPrint("Data loaded! Keys: " .. table.Count(data))
        -- Process loaded data
        for key, value in pairs(data) do
            print(key .. " = " .. tostring(value))
        end
    end)
end

concommand.Add("load_data", function(ply)
    loadPlayerData(ply)
end)
```

---

### saveLiliaData

**Purpose**

Saves the player's current data to the database.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function savePlayerData(player)
    player:saveLiliaData()
    player:ChatPrint("Data saved to database!")
end

concommand.Add("save_data", function(ply)
    savePlayerData(ply)
end)
```

---

### getAllLiliaData

**Purpose**

Gets all persistent data for the player.

**Parameters**

*None.*

**Returns**

* `data` (*table*): Table containing all player data.

**Realm**

Shared.

**Example Usage**

```lua
local function displayAllPlayerData(player)
    local data = player:getAllLiliaData()
    player:ChatPrint("All player data:")
    for key, value in pairs(data) do
        player:ChatPrint("  " .. key .. ": " .. tostring(value))
    end
    return data
end

concommand.Add("all_data", function(ply)
    displayAllPlayerData(ply)
end)
```

---

### giveFlags

**Purpose**

Adds flags to the player's character.

**Parameters**

* `flags` (*string*): The flags to add.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function givePlayerFlags(player, flags)
    player:giveFlags(flags)
    player:ChatPrint("Added flags: " .. flags)
end

concommand.Add("give_flags", function(ply, cmd, args)
    local flags = args[1]
    if flags then
        givePlayerFlags(ply, flags)
    end
end)
```

---

### takeFlags

**Purpose**

Removes flags from the player's character.

**Parameters**

* `flags` (*string*): The flags to remove.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function takePlayerFlags(player, flags)
    player:takeFlags(flags)
    player:ChatPrint("Removed flags: " .. flags)
end

concommand.Add("take_flags", function(ply, cmd, args)
    local flags = args[1]
    if flags then
        takePlayerFlags(ply, flags)
    end
end)
```

---

### setWaypoint

**Purpose**

Sets a waypoint for the player to follow.

**Parameters**

* `name` (*string*): The name of the waypoint.
* `vector` (*Vector*): The position of the waypoint.
* `onReach` (*function|nil*): Function to call when the waypoint is reached (client-side only).

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerWaypoint(player, name, pos)
    player:setWaypoint(name, pos)
    player:ChatPrint("Waypoint set: " .. name .. " at " .. tostring(pos))
end

concommand.Add("set_waypoint", function(ply, cmd, args)
    local name = args[1] or "Waypoint"
    local pos = ply:GetPos() + Vector(0, 0, 50)
    setPlayerWaypoint(ply, name, pos)
end)
```

---

### setWeighPoint

**Purpose**

Sets a waypoint for the player to follow (alias for setWaypoint).

**Parameters**

* `name` (*string*): The name of the waypoint.
* `vector` (*Vector*): The position of the waypoint.
* `onReach` (*function|nil*): Function to call when the waypoint is reached (client-side only).

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerWeighPoint(player, name, pos)
    player:setWeighPoint(name, pos)
    player:ChatPrint("Weigh point set: " .. name .. " at " .. tostring(pos))
end

concommand.Add("set_weighpoint", function(ply, cmd, args)
    local name = args[1] or "WeighPoint"
    local pos = ply:GetPos() + Vector(0, 0, 50)
    setPlayerWeighPoint(ply, name, pos)
end)
```

---

### setWaypointWithLogo

**Purpose**

Sets a waypoint with a custom logo for the player to follow.

**Parameters**

* `name` (*string*): The name of the waypoint.
* `vector` (*Vector*): The position of the waypoint.
* `logo` (*string*): The material path for the logo.
* `onReach` (*function|nil*): Function to call when the waypoint is reached (client-side only).

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerWaypointWithLogo(player, name, pos, logo)
    player:setWaypointWithLogo(name, pos, logo)
    player:ChatPrint("Waypoint with logo set: " .. name .. " at " .. tostring(pos))
end

concommand.Add("set_waypoint_logo", function(ply, cmd, args)
    local name = args[1] or "Waypoint"
    local logo = args[2] or "icon16/flag_blue.png"
    local pos = ply:GetPos() + Vector(0, 0, 50)
    setPlayerWaypointWithLogo(ply, name, pos, logo)
end)
```

---

### banPlayer

**Purpose**

Bans the player from the server.

**Parameters**

* `reason` (*string|nil*): The reason for the ban.
* `duration` (*number|nil*): The duration of the ban in seconds (0 for permanent).
* `banner` (*Player|nil*): The player who issued the ban.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function banPlayerFromServer(player, reason, duration, banner)
    player:banPlayer(reason, duration, banner)
    print("Player " .. player:Name() .. " has been banned")
end

concommand.Add("ban_player", function(ply, cmd, args)
    local target = ply:getTracedEntity()
    if IsValid(target) and target:IsPlayer() then
        local reason = args[1] or "No reason provided"
        local duration = tonumber(args[2]) or 0
        banPlayerFromServer(target, reason, duration, ply)
    end
end)
```

---

### setAction

**Purpose**

Sets an action bar for the player with optional callback.

**Parameters**

* `text` (*string|nil*): The action text to display, or nil to clear.
* `time` (*number|nil*): The duration of the action (default: 5).
* `callback` (*function|nil*): Function to call when the action completes.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerAction(player, text, time, callback)
    player:setAction(text, time, callback)
    player:ChatPrint("Action set: " .. (text or "cleared"))
end

concommand.Add("set_action", function(ply, cmd, args)
    local text = args[1] or "Default Action"
    local time = tonumber(args[2]) or 5
    setPlayerAction(ply, text, time, function()
        ply:ChatPrint("Action completed!")
    end)
end)
```

---

### doStaredAction

**Purpose**

Performs an action that requires the player to stare at an entity.

**Parameters**

* `entity` (*Entity*): The entity to stare at.
* `callback` (*function|nil*): Function to call when the action completes.
* `time` (*number|nil*): The duration of the action.
* `onCancel` (*function|nil*): Function to call if the action is cancelled.
* `distance` (*number|nil*): Maximum distance to maintain (default: 96).

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function doPlayerStaredAction(player, entity, time, callback)
    player:doStaredAction(entity, callback, time, function()
        player:ChatPrint("Action cancelled - look away!")
    end)
    player:ChatPrint("Stare at the entity for " .. time .. " seconds")
end

concommand.Add("stare_action", function(ply, cmd, args)
    local entity = ply:getTracedEntity()
    local time = tonumber(args[1]) or 3
    if IsValid(entity) then
        doPlayerStaredAction(ply, entity, time, function()
            ply:ChatPrint("Stared action completed!")
        end)
    end
end)
```

---

### stopAction

**Purpose**

Stops any current action or stared action.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function stopPlayerAction(player)
    player:stopAction()
    player:ChatPrint("Action stopped!")
end

concommand.Add("stop_action", function(ply)
    stopPlayerAction(ply)
end)
```

---

### requestDropdown

**Purpose**

Shows a dropdown menu to the player and handles the response.

**Parameters**

* `title` (*string*): The title of the dropdown.
* `subTitle` (*string*): The subtitle of the dropdown.
* `options` (*table*): Array of options to display.
* `callback` (*function*): Function to call with the selected option.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function showPlayerDropdown(player, title, options, callback)
    player:requestDropdown(title, "Choose an option:", options, callback)
end

concommand.Add("show_dropdown", function(ply)
    local options = {"Option 1", "Option 2", "Option 3"}
    showPlayerDropdown(ply, "Test Dropdown", options, function(selected)
        ply:ChatPrint("You selected: " .. selected)
    end)
end)
```

---

### requestOptions

**Purpose**

Shows a multi-select options menu to the player.

**Parameters**

* `title` (*string*): The title of the options menu.
* `subTitle` (*string*): The subtitle of the options menu.
* `options` (*table*): Array of options to display.
* `limit` (*number|nil*): Maximum number of selections allowed (default: 1).
* `callback` (*function*): Function to call with the selected options.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function showPlayerOptions(player, title, options, limit, callback)
    player:requestOptions(title, "Choose options:", options, limit, callback)
end

concommand.Add("show_options", function(ply, cmd, args)
    local options = {"Option A", "Option B", "Option C", "Option D"}
    local limit = tonumber(args[1]) or 2
    showPlayerOptions(ply, "Multi-Select", options, limit, function(selected)
        ply:ChatPrint("You selected: " .. table.concat(selected, ", "))
    end)
end)
```

---

### requestString

**Purpose**

Shows a string input dialog to the player.

**Parameters**

* `title` (*string*): The title of the input dialog.
* `subTitle` (*string*): The subtitle of the input dialog.
* `callback` (*function*): Function to call with the input string.
* `default` (*string|nil*): Default value for the input.

**Returns**

* `deferred` (*Deferred|nil*): Deferred object if callback is not provided.

**Realm**

Server.

**Example Usage**

```lua
local function requestPlayerString(player, title, callback, default)
    player:requestString(title, "Enter your input:", callback, default)
end

concommand.Add("request_string", function(ply)
    requestPlayerString(ply, "Test Input", function(input)
        ply:ChatPrint("You entered: " .. input)
    end, "Default text")
end)
```

---

### requestArguments

**Purpose**

Shows an arguments input dialog to the player.

**Parameters**

* `title` (*string*): The title of the arguments dialog.
* `argTypes` (*table*): Array of argument type specifications.
* `callback` (*function*): Function to call with the parsed arguments.

**Returns**

* `deferred` (*Deferred|nil*): Deferred object if callback is not provided.

**Realm**

Server.

**Example Usage**

```lua
local function requestPlayerArguments(player, title, argTypes, callback)
    player:requestArguments(title, argTypes, callback)
end

concommand.Add("request_args", function(ply)
    local argTypes = {
        {type = "string", name = "Name", desc = "Enter a name"},
        {type = "number", name = "Age", desc = "Enter your age"},
        {type = "boolean", name = "Active", desc = "Are you active?"}
    }
    requestPlayerArguments(ply, "Test Arguments", argTypes, function(args)
        ply:ChatPrint("Arguments: " .. util.TableToJSON(args))
    end)
end)
```

---

### binaryQuestion

**Purpose**

Shows a yes/no question dialog to the player.

**Parameters**

* `question` (*string*): The question to ask.
* `option1` (*string*): The first option (usually "Yes").
* `option2` (*string*): The second option (usually "No").
* `manualDismiss` (*boolean|nil*): Whether the dialog can be manually dismissed.
* `callback` (*function*): Function to call with the selected option.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function askPlayerQuestion(player, question, option1, option2, callback)
    player:binaryQuestion(question, option1, option2, false, callback)
end

concommand.Add("ask_question", function(ply)
    askPlayerQuestion(ply, "Do you want to continue?", "Yes", "No", function(choice)
        ply:ChatPrint("You chose: " .. choice)
    end)
end)
```

---

### requestButtons

**Purpose**

Shows a custom button menu to the player.

**Parameters**

* `title` (*string*): The title of the button menu.
* `buttons` (*table*): Array of button data tables with 'text' and 'callback' fields.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function showPlayerButtons(player, title, buttons)
    player:requestButtons(title, buttons)
end

concommand.Add("show_buttons", function(ply)
    local buttons = {
        {text = "Button 1", callback = function() ply:ChatPrint("Button 1 pressed!") end},
        {text = "Button 2", callback = function() ply:ChatPrint("Button 2 pressed!") end},
        {text = "Button 3", callback = function() ply:ChatPrint("Button 3 pressed!") end}
    }
    showPlayerButtons(ply, "Test Buttons", buttons)
end)
```

---

### getSessionTime

**Purpose**

Gets the player's current session time in seconds.

**Parameters**

*None.*

**Returns**

* `sessionTime` (*number*): The current session time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
local function displaySessionTime(player)
    local sessionTime = player:getSessionTime()
    local hours = math.floor(sessionTime / 3600)
    local minutes = math.floor((sessionTime % 3600) / 60)
    player:ChatPrint("Session time: " .. hours .. "h " .. minutes .. "m")
    return sessionTime
end

concommand.Add("session_time", function(ply)
    displaySessionTime(ply)
end)
```

---

### getTotalOnlineTime

**Purpose**

Gets the player's total online time including current session.

**Parameters**

*None.*

**Returns**

* `totalTime` (*number*): The total online time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
local function displayTotalTime(player)
    local totalTime = player:getTotalOnlineTime()
    local hours = math.floor(totalTime / 3600)
    local minutes = math.floor((totalTime % 3600) / 60)
    player:ChatPrint("Total online time: " .. hours .. "h " .. minutes .. "m")
    return totalTime
end

concommand.Add("total_time", function(ply)
    displayTotalTime(ply)
end)
```

---

### getLastOnline

**Purpose**

Gets the time since the player was last online.

**Parameters**

*None.*

**Returns**

* `timeSince` (*string*): Human-readable time since last online.

**Realm**

Shared.

**Example Usage**

```lua
local function displayLastOnline(player)
    local timeSince = player:getLastOnline()
    player:ChatPrint("Last online: " .. timeSince .. " ago")
    return timeSince
end

concommand.Add("last_online", function(ply)
    displayLastOnline(ply)
end)
```

---

### getLastOnlineTime

**Purpose**

Gets the timestamp of when the player was last online.

**Parameters**

*None.*

**Returns**

* `timestamp` (*number*): Unix timestamp of last online time.

**Realm**

Shared.

**Example Usage**

```lua
local function displayLastOnlineTime(player)
    local timestamp = player:getLastOnlineTime()
    local date = os.date("%Y-%m-%d %H:%M:%S", timestamp)
    player:ChatPrint("Last online timestamp: " .. date)
    return timestamp
end

concommand.Add("last_online_time", function(ply)
    displayLastOnlineTime(ply)
end)
```

---

### CanOverrideView

**Purpose**

Checks if the player can override their view (for third-person mode).

**Parameters**

*None.*

**Returns**

* `canOverride` (*boolean*): True if the player can override their view.

**Realm**

Client.

**Example Usage**

```lua
local function checkViewOverride(player)
    if player:CanOverrideView() then
        player:ChatPrint("You can override your view!")
        return true
    else
        player:ChatPrint("You cannot override your view.")
        return false
    end
end

concommand.Add("check_view_override", function(ply)
    checkViewOverride(ply)
end)
```

---

### IsInThirdPerson

**Purpose**

Checks if the player is currently in third-person mode.

**Parameters**

*None.*

**Returns**

* `isThirdPerson` (*boolean*): True if the player is in third-person mode.

**Realm**

Client.

**Example Usage**

```lua
local function checkThirdPerson(player)
    if player:IsInThirdPerson() then
        player:ChatPrint("You are in third-person mode!")
        return true
    else
        player:ChatPrint("You are in first-person mode.")
        return false
    end
end

concommand.Add("check_third_person", function(ply)
    checkThirdPerson(ply)
end)
```

---

### syncVars

**Purpose**

Synchronizes all network variables to the player.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncPlayerVars(player)
    player:syncVars()
    player:ChatPrint("Network variables synchronized!")
end

concommand.Add("sync_vars", function(ply)
    syncPlayerVars(ply)
end)
```

---

### setLocalVar

**Purpose**

Sets a local variable for the player (client-side only).

**Parameters**

* `key` (*string*): The variable key to set.
* `value` (*any*): The value to set.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerLocalVar(player, key, value)
    player:setLocalVar(key, value)
    player:ChatPrint("Set local variable " .. key .. " to " .. tostring(value))
end

concommand.Add("set_local_var", function(ply, cmd, args)
    local key = args[1]
    local value = args[2]
    if key and value then
        setPlayerLocalVar(ply, key, value)
    end
end)
```

---

### playTimeGreaterThan

**Purpose**

Checks if the player's play time is greater than a specified amount.

**Parameters**

* `time` (*number*): The time in seconds to compare against.

**Returns**

* `isGreater* (*boolean*): True if play time is greater than the specified time.

**Realm**

Shared.

**Example Usage**

```lua
local function checkPlayTimeRequirement(player, requiredTime)
    if player:playTimeGreaterThan(requiredTime) then
        player:ChatPrint("You meet the play time requirement!")
        return true
    else
        player:ChatPrint("You need more play time.")
        return false
    end
end

concommand.Add("check_playtime_req", function(ply, cmd, args)
    local requiredTime = tonumber(args[1]) or 3600 -- 1 hour default
    checkPlayTimeRequirement(ply, requiredTime)
end)
```

---

### createRagdoll

**Purpose**

Creates a ragdoll entity for the player.

**Parameters**

* `freeze` (*boolean|nil*): Whether to freeze the ragdoll physics.
* `isDead` (*boolean|nil*): Whether the player is dead (sets ragdoll as active).

**Returns**

* `ragdoll` (*Entity*): The created ragdoll entity.

**Realm**

Server.

**Example Usage**

```lua
local function createPlayerRagdoll(player, freeze, isDead)
    local ragdoll = player:createRagdoll(freeze, isDead)
    if IsValid(ragdoll) then
        player:ChatPrint("Ragdoll created!")
        return ragdoll
    else
        player:ChatPrint("Failed to create ragdoll.")
        return nil
    end
end

concommand.Add("create_ragdoll", function(ply, cmd, args)
    local freeze = tobool(args[1])
    local isDead = tobool(args[2])
    createPlayerRagdoll(ply, freeze, isDead)
end)
```

---

### setRagdolled

**Purpose**

Sets the player's ragdoll state.

**Parameters**

* `state` (*boolean*): Whether to ragdoll the player.
* `baseTime` (*number|nil*): Base time for the ragdoll duration.
* `getUpGrace` (*number|nil*): Grace period before allowing get up.
* `getUpMessage` (*string|nil*): Message to display during get up.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setPlayerRagdolled(player, state, time, grace, message)
    player:setRagdolled(state, time, grace, message)
    local status = state and "ragdolled" or "unragdolled"
    player:ChatPrint("Player " .. status .. "!")
end

concommand.Add("set_ragdolled", function(ply, cmd, args)
    local state = tobool(args[1])
    local time = tonumber(args[2]) or 10
    local grace = tonumber(args[3]) or 2
    local message = args[4] or "Getting up..."
    setPlayerRagdolled(ply, state, time, grace, message)
end)
```

---

### getPlayTime

**Purpose**

Gets the player's total play time.

**Parameters**

*None.*

**Returns**

* `playTime` (*number*): The player's play time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayTime(player)
    local playTime = player:getPlayTime()
    local hours = math.floor(playTime / 3600)
    local minutes = math.floor((playTime % 3600) / 60)
    player:ChatPrint("Play time: " .. hours .. "h " .. minutes .. "m")
    return playTime
end

concommand.Add("play_time", function(ply)
    displayPlayTime(ply)
end)
```

---

### getParts

**Purpose**

Gets the player's current PAC parts.

**Parameters**

*None.*

**Returns**

* `parts` (*table*): Table of currently active PAC parts.

**Realm**

Shared.

**Example Usage**

```lua
local function displayPlayerParts(player)
    local parts = player:getParts()
    player:ChatPrint("Current PAC parts: " .. table.Count(parts))
    for partID, _ in pairs(parts) do
        player:ChatPrint("  - " .. partID)
    end
    return parts
end

concommand.Add("my_parts", function(ply)
    displayPlayerParts(ply)
end)
```

---

### addPart

**Purpose**

Adds a PAC part to the player.

**Parameters**

* `partID` (*string*): The unique ID of the part to add.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function givePlayerPart(player, partID)
    player:addPart(partID)
    player:ChatPrint("Added PAC part: " .. partID)
end

concommand.Add("add_part", function(ply, cmd, args)
    local partID = args[1]
    if partID then
        givePlayerPart(ply, partID)
    end
end)
```

---

### removePart

**Purpose**

Removes a PAC part from the player.

**Parameters**

* `partID` (*string*): The unique ID of the part to remove.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function removePlayerPart(player, partID)
    player:removePart(partID)
    player:ChatPrint("Removed PAC part: " .. partID)
end

concommand.Add("remove_part", function(ply, cmd, args)
    local partID = args[1]
    if partID then
        removePlayerPart(ply, partID)
    end
end)
```

---

### resetParts

**Purpose**

Removes all PAC parts from the player.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function clearPlayerParts(player)
    player:resetParts()
    player:ChatPrint("All PAC parts removed!")
end

concommand.Add("reset_parts", function(ply)
    clearPlayerParts(ply)
end)
```

---

### syncParts

**Purpose**

Synchronizes the player's PAC parts with all clients.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncPlayerParts(player)
    player:syncParts()
    player:ChatPrint("PAC parts synchronized!")
end

concommand.Add("sync_parts", function(ply)
    syncPlayerParts(ply)
end)
```

---