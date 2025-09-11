# Player Meta

This page documents methods available on the `Player` meta table, representing connected human players in the Lilia framework.

---

## Overview

The `Player` meta table extends Garry's Mod's base player functionality with Lilia-specific features including character management, privilege checking, vehicle handling, movement detection, money management, flag systems, data persistence, and various utility functions. These methods provide comprehensive player management capabilities for roleplay servers and other gameplay systems within the Lilia framework.

---

### playerMeta:getChar

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

### playerMeta:Name

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

### playerMeta:hasPrivilegeVector

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

### playerMeta:getCurrentVehicle

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

### playerMeta:hasValidVehicle

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

### playerMeta:isNoClipping

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

### playerMeta:removeRagdoll

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

### playerMeta:getRagdoll

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

### playerMeta:isStuck

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

### playerMeta:isNearPlayer

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

### playerMeta:entitiesNearPlayer

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

### playerMeta:getItemWeapon

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

### playerMeta:isRunning

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

### playerMeta:IsFamilySharedAccount

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

### playerMeta:getItemDropPos

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

### playerMeta:getItems

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

### playerMeta:getTracedEntity

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

### playerMeta:getTrace

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

### playerMeta:getEyeEnt

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

### playerMeta:notify

**Purpose**

Sends a notification to the player.

**Parameters**

* `message` (*string*): The notification message.
* `...` (*any*): Additional arguments for the notification.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function sendPlayerNotification(player, message)
    player:notify(message)
end

concommand.Add("notify", function(ply, cmd, args)
    local message = table.concat(args, " ")
    if message ~= "" then
        sendPlayerNotification(ply, message)
    end
end)
```

---

### playerMeta:notifyLocalized

**Purpose**

Sends a localized notification to the player.

**Parameters**

* `message` (*string*): The localized message key.
* `...` (*any*): Additional arguments for the notification.

**Returns**

*None.*

**Realm**

Shared.

**Example Usage**

```lua
local function sendLocalizedNotification(player, messageKey, ...)
    player:notifyLocalized(messageKey, ...)
end

concommand.Add("notify_localized", function(ply, cmd, args)
    local messageKey = args[1]
    if messageKey then
        local args = {}
        for i = 2, #args do
            table.insert(args, args[i])
        end
        sendLocalizedNotification(ply, messageKey, unpack(args))
    end
end)
```

---

### playerMeta:CanEditVendor

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

### playerMeta:isStaff

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

### playerMeta:isVIP

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

### playerMeta:isStaffOnDuty

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

### playerMeta:isFaction

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

### playerMeta:isClass

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

### playerMeta:hasWhitelist

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

### playerMeta:getClass

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

### playerMeta:hasClassWhitelist

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

### playerMeta:getClassData

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

### playerMeta:getDarkRPVar

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

### playerMeta:getMoney

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

### playerMeta:canAfford

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

### playerMeta:hasSkillLevel

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

### playerMeta:meetsRequiredSkills

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

### playerMeta:restoreStamina

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

### playerMeta:consumeStamina

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

### playerMeta:addMoney

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

### playerMeta:takeMoney

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

### playerMeta:setLiliaData

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

### playerMeta:getLiliaData

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

### playerMeta:getFlags

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

### playerMeta:setFlags

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

### playerMeta:hasFlags

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

### playerMeta:getPlayTime

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
