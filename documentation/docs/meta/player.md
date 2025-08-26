# Player Meta

Lilia extends Garry's Mod players with characters, inventories, and permission checks.

This reference details the meta functions enabling that integration.

---

## Overview

Player-meta functions provide quick access to the active character, networking helpers for messaging or data transfer, and utility checks such as admin status.

Players are entity objects that hold at most one `Character` instance, so these helpers unify player-related logic across the framework.

---

### getChar

**Purpose**

Returns the current character of the player.

**Parameters**

* None

**Returns**

* `Character|nil`: The player's current character, or `nil` if no character is loaded.

**Realm**

`Shared`

**Example Usage**

```lua
local char = player:getChar()
if char then
    print("Character name: " .. char:getName())
end
```

---

### Name

**Purpose**

Returns the display name of the player, either their character name or Steam name.

**Parameters**

* None

**Returns**

* `string`: The player's display name.

**Realm**

`Shared`

**Example Usage**

```lua
local name = player:Name()
print("Player name: " .. name)
```

---

### steamName

**Purpose**

Returns the player's Steam name without considering character data.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Steam community display name.

**Example Usage**

```lua
print(player:steamName())
```

---

### SteamName

**Purpose**

Alias of `steamName`.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Steam community display name.

**Example Usage**

```lua
print(player:SteamName())
```

---

### hasPrivilege

**Purpose**

Checks if the player has the specified privilege.

**Parameters**

* `privilegeName` (`string`): The name of the privilege to check.

**Returns**

* `boolean`: True if the player has the privilege, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:hasPrivilege("admin") then
    print("Player has admin privileges")
end
```

---

### getCurrentVehicle

**Purpose**

Returns the player's currently occupied vehicle entity.

**Parameters**

* None

**Returns**

* `Entity|nil`: The vehicle entity the player is in, or `nil` if not in a vehicle.

**Realm**

`Shared`

**Example Usage**

```lua
local vehicle = player:getCurrentVehicle()
if vehicle then
    print("Player is in vehicle: " .. vehicle:GetClass())
end
```

---

### hasValidVehicle

**Purpose**

Checks if the player has a valid vehicle.

**Parameters**

* None

**Returns**

* `boolean`: True if the player has a valid vehicle, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:hasValidVehicle() then
    print("Player is in a vehicle")
end
```

---

### isNoClipping

**Purpose**

Checks if the player is currently nocliping.

**Parameters**

* None

**Returns**

* `boolean`: True if the player is nocliping, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:isNoClipping() then
    print("Player is nocliping")
end
```

---

### hasRagdoll

**Purpose**

Checks if the player has a ragdoll.

**Parameters**

* None

**Returns**

* `boolean`: True if the player has a ragdoll, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:hasRagdoll() then
    print("Player has a ragdoll")
end
```

---

### CanOverrideView

**Purpose**

Checks if the player is allowed to override the camera view.

A valid character must be loaded and the player cannot be in a vehicle or ragdoll.

The `thirdPersonEnabled` option must be enabled both client and server side and the `ShouldDisableThirdperson` hook must not return `true`.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `boolean`: `true` when a third-person view may be used.

**Example Usage**

```lua
if player:CanOverrideView() then
    -- Place the camera behind the player
end
```

---

### IsInThirdPerson

**Purpose**

Returns whether third-person view is enabled for this player according to the `thirdPersonEnabled` option and configuration.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `boolean`: `true` if third-person mode is enabled.

**Example Usage**

```lua
if player:IsInThirdPerson() then
    print("Third person active")
end
```

---

### removeRagdoll

**Purpose**

Removes the player's ragdoll if one exists.

**Parameters**

* None

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
player:removeRagdoll()
```

---

### getRagdoll

**Purpose**

Returns the player's ragdoll entity if one exists.

**Parameters**

* None

**Returns**

* `Entity|nil`: The ragdoll entity, or `nil` if no ragdoll exists.

**Realm**

`Shared`

**Example Usage**

```lua
local ragdoll = player:getRagdoll()
if ragdoll then
    print("Player has a ragdoll")
end
```

---

### isStuck

**Purpose**

Checks if the player is stuck in geometry.

**Returns**

* `boolean`: True if the player is stuck, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:isStuck() then
    print("Player is stuck in geometry")
end
```

---

### isNearPlayer

**Purpose**

Checks if the player is near another entity within the specified radius.

**Parameters**

* `radius` (`number`): The radius to check within.
* `entity` (`Entity`): The entity to check distance to.

**Returns**

* `boolean`: True if the player is within the radius, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:isNearPlayer(100, otherPlayer) then
    print("Player is nearby")
end
```

---

### entitiesNearPlayer

**Purpose**

Returns all entities near the player within the specified radius.

**Parameters**

* `radius` (`number`): The radius to search within.
* `playerOnly` (`boolean`): If true, only return player entities.

**Returns**

* `table`: Array of nearby entities.

**Realm**

`Shared`

**Example Usage**

```lua
local nearby = player:entitiesNearPlayer(200, true)
print("Found " .. #nearby .. " players nearby")
```

---

### getItemWeapon

**Purpose**

Returns the player's currently equipped weapon and its corresponding inventory item.

**Returns**

* `Weapon|Item|nil`: The weapon and item, or `nil` if not found.

**Realm**

`Shared`

**Example Usage**

```lua
local weapon, item = player:getItemWeapon()
if weapon then
    print("Equipped weapon: " .. weapon:GetClass())
end
```

---

### isRunning

**Purpose**

Checks if the player is currently running.

**Returns**

* `boolean`: True if the player is running, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:isRunning() then
    print("Player is running")
end
```

---

### isFemale

**Purpose**

Checks if the player's model is female.

**Returns**

* `boolean`: True if the player's model is female, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:isFemale() then
    print("Player is female")
end
```

---

### IsFamilySharedAccount

**Purpose**

Checks if the player's Steam account is family shared.

**Returns**

* `boolean`: True if the account is family shared, false otherwise.

**Realm**

`Shared`

**Example Usage**

```lua
if player:IsFamilySharedAccount() then
    print("Player has family shared account")
end
```

---

### getItemDropPos

**Purpose**

Calculates the position where items should be dropped in front of the player.

**Returns**

* `Vector`: The calculated drop position.

**Realm**

`Shared`

**Example Usage**

```lua
local dropPos = player:getItemDropPos()
print("Item will be dropped at: " .. tostring(dropPos))
```

---

### getItems

**Purpose**

Returns all items in the player's inventory.

**Returns**

* `table|nil`: Array of inventory items, or `nil` if no character or inventory exists.

**Realm**

`Shared`

**Example Usage**

```lua
local items = player:getItems()
if items then
    print("Player has " .. #items .. " items")
end
```

---


### getTrace

**Purpose**

Performs a hull trace from the player's shoot position in the direction they are looking.

**Parameters**

* distance (number) - The maximum distance to trace. Defaults to 200.

**Returns**

table - The trace result table containing hit information.

**Realm**

Shared.

**Example Usage**

```lua
    local trace = player:getTrace(300)
    if trace.Hit then
        print("Hit something at: " .. tostring(trace.HitPos))
    end
```

---

### getEyeEnt

**Purpose**

Returns the entity the player is looking at within a specified distance using eye trace.

**Parameters**

* distance (number) - The maximum distance to check. Defaults to 150.

**Returns**

Entity or nil - The entity being looked at, or nil if out of range.

**Realm**

Shared.

**Example Usage**

```lua
    local entity = player:getEyeEnt(200)
    if entity then
        print("Looking at: " .. entity:GetClass())
    end
```

---

### notify

**Purpose**

Sends a notification message to the player. On the server, the notification is sent specifically to this player. On the client, it's sent to the local player.

**Parameters**

* `message` (`string`): The message to display to the player.
* `...` (`any`): Additional arguments to pass to the notification system.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
-- Server-side: Send notification to specific player
player:notify("Welcome to the server!")

-- Client-side: Send notification to local player
LocalPlayer():notify("Action completed!")
```

---

### notifyLocalized

**Purpose**

Sends a localized notification message to the player. On the server, the notification is sent specifically to this player. On the client, it's sent to the local player. The message is automatically translated using the player's language settings.

**Parameters**

* `message` (`string`): The localization key for the message.
* `...` (`any`): Additional arguments to format the localized message.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
-- Server-side: Send localized notification to specific player
player:notifyLocalized("welcome_message", player:Name())

-- Client-side: Send localized notification to local player
LocalPlayer():notifyLocalized("action_completed", "Item pickup")

-- With multiple format arguments
player:notifyLocalized("item_given", "Health Kit", 100)
```

---

### CanEditVendor

**Purpose**

Checks if the player can edit the specified vendor.

**Parameters**

* vendor (Entity) - The vendor entity to check permissions for.

**Returns**

boolean - True if the player can edit the vendor, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:CanEditVendor(vendorEntity) then
        print("Player can edit this vendor")
    end
```

---

### isStaff

**Purpose**

Checks if the player is a staff member based on their user group.

**Returns**

boolean - True if the player is staff, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:isStaff() then
        print("Player is a staff member")
    end
```

---

### isVIP

**Purpose**

Checks if the player is a VIP member based on their user group.

**Returns**

boolean - True if the player is VIP, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:isVIP() then
        print("Player is a VIP member")
    end
```

---

### isStaffOnDuty

**Purpose**

Checks if the player is currently on duty as staff.

**Returns**

boolean - True if the player is on duty as staff, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:isStaffOnDuty() then
        print("Player is on duty as staff")
    end
```

---

### isFaction

**Purpose**

Checks if the player belongs to the specified faction.

**Parameters**

* faction (string) - The faction name to check against.

**Returns**

boolean or nil - True if the player belongs to the faction, false or nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:isFaction("police") then
        print("Player is a police officer")
    end
```

---

### isClass

**Purpose**

Checks if the player belongs to the specified class.

**Parameters**

* class (string) - The class name to check against.

**Returns**

boolean or nil - True if the player belongs to the class, false or nil otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:isClass("medic") then
        print("Player is a medic")
    end
```

---

### hasWhitelist

**Purpose**

Checks if the player has a whitelist for the specified faction.

**Parameters**

* faction (string) - The faction name to check whitelist for.

**Returns**

boolean - True if the player has a whitelist for the faction, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasWhitelist("police") then
        print("Player has police whitelist")
    end
```

---

### getClass

**Purpose**

Returns the player's current class.

**Returns**

string or nil - The player's class name, or nil if no character exists.

**Realm**

Shared.

**Example Usage**

```lua
    local class = player:getClass()
    if class then
        print("Player's class: " .. class)
    end
```

---

### hasClassWhitelist

**Purpose**

Checks if the player has a whitelist for the specified class.

**Parameters**

* class (string) - The class name to check whitelist for.

**Returns**

boolean - True if the player has a whitelist for the class, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasClassWhitelist("medic") then
        print("Player has medic class whitelist")
    end
```

---

### getClassData

**Purpose**

Returns the data for the player's current class.

**Returns**

table or nil - The class data table, or nil if no character or class exists.

**Realm**

Shared.

**Example Usage**

```lua
    local classData = player:getClassData()
    if classData then
        print("Class description: " .. classData.description)
    end
```

---

### getDarkRPVar

**Purpose**

Returns DarkRP variable values for the player. Currently only supports "money" variable.

**Parameters**

* var (string) - The DarkRP variable name to retrieve. Only "money" is currently supported.

**Returns**

number or nil - The value of the requested variable, or nil if not supported.

**Realm**

Shared.

**Example Usage**

```lua
    local money = player:getDarkRPVar("money")
    if money then
        print("Player has " .. money .. " money")
    end
```

---

### getMoney

**Purpose**

Returns the player's current money amount from their character.

**Returns**

number - The player's current money amount, or 0 if no character exists.

**Realm**

Shared.

**Example Usage**

```lua
    local money = player:getMoney()
    print("Player has " .. money .. " money")
```

---

### canAfford

**Purpose**

Checks if the player can afford a specified amount of money.

**Parameters**

* amount (number) - The amount of money to check.

**Returns**

boolean - True if the player can afford the amount, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:canAfford(1000) then
        print("Player can afford 1000")
    end
```

---

### hasSkillLevel

**Purpose**

Checks if the player has a skill level at or above the specified level.

**Parameters**

* skill (string) - The skill name to check.
* level (number) - The minimum skill level required.

**Returns**

boolean - True if the player has the required skill level, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasSkillLevel("strength", 5) then
        print("Player has strength level 5 or higher")
    end
```

---

### meetsRequiredSkills

**Purpose**

Checks if the player meets all the required skill levels for a set of skills.

**Parameters**

* requiredSkillLevels (table) - Table of skill names mapped to required levels.

**Returns**

boolean - True if the player meets all required skill levels, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    local required = {strength = 5, agility = 3}
    if player:meetsRequiredSkills(required) then
        print("Player meets all skill requirements")
    end
```

---

### forceSequence

**Purpose**

Forces the player to play a specific animation sequence.

**Parameters**

* sequenceName (string) - The name of the sequence to play.
* callback (function) - Optional callback function to execute when sequence ends.
* time (number) - Optional duration for the sequence. Defaults to sequence duration.
* noFreeze (boolean) - If false, freezes player movement during sequence.

**Returns**

number or boolean - Duration of the sequence if successful, false if failed.

**Realm**

Shared.

**Example Usage**

```lua
    local duration = player:forceSequence("sit", function() print("Sit sequence finished") end)
```

---

### leaveSequence

**Purpose**

Stops the current forced sequence and restores normal player movement.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:leaveSequence()
```

---

### restoreStamina

**Purpose**

Restores the player's stamina by the specified amount.

**Parameters**

* amount (number) - The amount of stamina to restore.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:restoreStamina(50)
```

---

### consumeStamina

**Purpose**

Consumes the specified amount of stamina from the player.

**Parameters**

* amount (number) - The amount of stamina to consume.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:consumeStamina(25)
```

---

### addMoney

**Purpose**

Adds the specified amount of money to the player's character.

**Parameters**

* amount (number) - The amount of money to add.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:addMoney(1000)
```

---

### takeMoney

**Purpose**

Removes the specified amount of money from the player's character.

**Parameters**

* amount (number) - The amount of money to remove.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:takeMoney(500)
```

---

### WhitelistAllClasses

**Purpose**

Grants the player access to all available classes.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:WhitelistAllClasses()
```

---

### WhitelistAllFactions

**Purpose**

Grants the player access to all available factions.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:WhitelistAllFactions()
```

---

### WhitelistEverything

**Purpose**

Grants the player access to all available factions and classes.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:WhitelistEverything()
```

---

### classWhitelist

**Purpose**

Grants the player access to a specific class.

**Parameters**

* class (string) - The class name to whitelist.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:classWhitelist("medic")
```

---

### classUnWhitelist

**Purpose**

Removes the player's access to a specific class.

**Parameters**

* class (string) - The class name to remove whitelist for.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:classUnWhitelist("medic")
```

---

### setWhitelisted

**Purpose**

Sets the whitelist status for a specific faction for the player.

**Parameters**

* faction (string) - The faction name to set whitelist for.
* whitelisted (boolean) - Whether to whitelist or remove whitelist.

**Returns**

boolean - True if the operation was successful, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
    player:setWhitelisted("police", true)
```

---

### loadLiliaData

**Purpose**

Loads the player's Lilia data from the database.

**Parameters**

* callback (function) - Optional callback function to execute after loading.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:loadLiliaData(function(data) print("Data loaded") end)
```

---

### saveLiliaData

**Purpose**

Saves the player's Lilia data to the database, including online time tracking and other persistent data.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:saveLiliaData()
```

---

### setLiliaData

**Purpose**

Sets a key-value pair in the player's Lilia data and optionally syncs it to the client and saves to database.

**Parameters**

* key (string) - The data key to set.
* value (any) - The value to store.
* noNetworking (boolean) - If true, doesn't sync to client.
* noSave (boolean) - If true, doesn't save to database.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setLiliaData("customFlag", true)
```

---

### setWaypoint

**Purpose**

Sets a waypoint for the player at the specified location.

**Parameters**

* name (string) - The name of the waypoint.
* vector (Vector) - The position where the waypoint should be set.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setWaypoint("Home", Vector(100, 200, 300))
```

---

### setWeighPoint

**Purpose**

Sets a waypoint for the player (alias for setWaypoint).

**Parameters**

* name (string) - The name of the waypoint.
* vector (Vector) - The position where the waypoint should be set.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setWeighPoint("Home", Vector(100, 200, 300))
```

---

### setWaypointWithLogo

**Purpose**

Sets a waypoint for the player with a custom logo/icon.

**Parameters**

* name (string) - The name of the waypoint.
* vector (Vector) - The position where the waypoint should be set.
* logo (string) - The logo/icon identifier for the waypoint.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setWaypointWithLogo("Store", Vector(500, 600, 700), "store_icon")
```

---

### getLiliaData

**Purpose**

Retrieves a value from the player's Lilia data storage.

**Parameters**

* key (string) - The data key to retrieve.
* default (any) - The default value to return if the key doesn't exist.

**Returns**

any - The stored value or the default value if not found.

**Realm**

Shared.

**Example Usage**

```lua
    local customFlag = player:getLiliaData("customFlag", false)
```

---

### getAllLiliaData

**Purpose**

Returns all of the player's Lilia data as a table.

**Returns**

table - The complete Lilia data table for the player.

**Realm**

Shared.

**Example Usage**

```lua
    local allData = player:getAllLiliaData()
    for key, value in pairs(allData) do
        print(key .. ": " .. tostring(value))
    end
```

---

### getFlags

**Purpose**

Returns the flags associated with the player's character.

**Returns**

string - The character's flags, or empty string if no character exists.

**Realm**

Shared.

**Example Usage**

```lua
    local flags = player:getFlags()
    if flags:find("a") then
        print("Player has admin flag")
    end
```

---

### setFlags

**Purpose**

Sets the flags for the player's character.

**Parameters**

* flags (string) - The flags to set for the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:setFlags("a")
    print("Player now has admin flag")
```

---

### giveFlags

**Purpose**

Gives flags to the player's character.

**Parameters**

* flags (string) - The flags to give to the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:giveFlags("a")
    print("Player now has admin flag")
```

---

### takeFlags

**Purpose**

Removes flags from the player's character.

**Parameters**

* flags (string) - The flags to remove from the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:takeFlags("a")
    print("Player no longer has admin flag")
```

---

### getPlayerFlags

**Purpose**

Returns the player's personal flags.

**Returns**

string - The player's personal flags.

**Realm**

Shared.

**Example Usage**

```lua
    local flags = player:getPlayerFlags()
    print("Player flags: " .. flags)
```

---

### setPlayerFlags

**Purpose**

Sets the player's personal flags.

**Parameters**

* flags (string) - The flags to set.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:setPlayerFlags("v")
    print("Player now has VIP flag")
```

---

### hasPlayerFlags

**Purpose**

Checks if the player has specific personal flags.

**Parameters**

* flags (string) - the flags to check for.

**Returns**

boolean - True if the player has any of the specified flags.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasPlayerFlags("v") then
        print("Player has VIP flag")
    end
```

---

### givePlayerFlags

**Purpose**

Gives personal flags to the player.

**Parameters**

* flags (string) - The flags to give.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:givePlayerFlags("v")
    print("Player now has VIP flag")
```

---

### takePlayerFlags

**Purpose**

Removes personal flags from the player.

**Parameters**

* flags (string) - The flags to remove.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    player:takePlayerFlags("v")
    print("Player no longer has VIP flag")
```

---

### hasFlags

**Purpose**

Checks if the player has specific flags (character or personal).

**Parameters**

* flags (string) - The flags to check for.

**Returns**

boolean - True if the player has any of the specified flags.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasFlags("a") then
        print("Player has admin flag")
    end
```

---

### setRagdoll

**Purpose**

Sets the player's ragdoll entity.

**Parameters**

* entity (Entity) - The ragdoll entity to set.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setRagdoll(ragdollEntity)
```

---

### NetworkAnimation

**Purpose**

Networks animation status to all clients.

**Parameters**

* active (boolean) - Whether the animation is active.
* boneData (table) - The bone data for the animation.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:NetworkAnimation(true, boneData)
```

---

### banPlayer

**Purpose**

Bans the player from the server.

**Parameters**

* reason (string) - The reason for the ban.
* duration (number) - The duration of the ban in seconds.
* banner (Player) - The player who issued the ban.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:banPlayer("Breaking rules", 3600, adminPlayer)
```

---

### setAction

**Purpose**

Sets an action bar for the player with optional callback.

**Parameters**

* text (string) - The text to display in the action bar.
* time (number) - The duration of the action bar.
* callback (function) - Optional callback function when action completes.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setAction("Loading...", 5, function() print("Action complete") end)
```

---

### doStaredAction

**Purpose**

Performs an action that requires the player to stare at an entity.

**Parameters**

* entity (Entity) - The entity to stare at.
* callback (function) - Function to call when action completes.
* time (number) - Time required to complete the action.
* onCancel (function) - Function to call if action is cancelled.
* distance (number) - Maximum distance to perform action.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:doStaredAction(targetEntity, function() print("Action done") end, 3)
```

---

### stopAction

**Purpose**

Stops the current action bar.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:stopAction()
```

---

### requestDropdown

**Purpose**

Requests a dropdown selection from the player.

**Parameters**

* title (string) - The title of the dropdown.
* subTitle (string) - The subtitle of the dropdown.
* options (table) - The options to choose from.
* callback (function) - Function to call when selection is made.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:requestDropdown("Choose", "Select an option", {"Option 1", "Option 2"}, callback)
```

---

### requestOptions

**Purpose**

Requests multiple option selections from the player.

**Parameters**

* title (string) - The title of the request.
* subTitle (string) - The subtitle of the request.
* options (table) - The options to choose from.
* limit (number) - Maximum number of selections allowed.
* callback (function) - Function to call when selection is made.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:requestOptions("Choose", "Select options", {"A", "B", "C"}, 2, callback)
```

---

### requestString

**Purpose**

Requests a string input from the player.

**Parameters**

* title (string) - The title of the request.
* subTitle (string) - The subtitle of the request.
* callback (function) - Function to call when string is entered.
* default (string) - Default value for the input.

**Returns**

Deferred object or nil.

**Realm**

Server.

**Example Usage**

```lua
    local deferred = player:requestString("Name", "Enter your name", callback, "Default")
```

---

### requestArguments

**Purpose**

Requests multiple arguments from the player with support for various input types including strings, numbers, booleans, and dropdown selections.

**Parameters**

* title (string) - The title of the request dialog.
* argTypes (table) - A table describing the argument types and names. Each key represents the field name, and the value can be:
  - A string type: `"string"`, `"number"`, `"int"`, `"boolean"`
  - A table for dropdowns: `{"table", {"Option1", "Option2", "Option3"}}`
  - A table with default value: `{type, dataTable, defaultValue}`
* callback (function) - Optional function to call when arguments are submitted. If not provided, returns a deferred object.

**Returns**

Deferred object if no callback is provided, otherwise nil.

**Realm**

Server.

**Example Usage**

```lua
-- Simple string and number inputs
local deferred = player:requestArguments("Enter Info", {Name="string", Age="number"}, function(result)
    print("Name: " .. result.Name .. ", Age: " .. result.Age)
end)

-- With dropdown options
player:requestArguments("Character Creation", {
    Name = "string",
    Class = {"table", {"Warrior", "Mage", "Rogue"}},
    Level = {"number", nil, 1} -- number type with default value of 1
}, function(result)
    -- Handle result
end)

-- Using deferred pattern
local promise = player:requestArguments("Settings", {Volume="number", Music="boolean"})
promise:next(function(result)
    -- Handle result
end)
```

---

### binaryQuestion

**Purpose**

Asks the player a yes/no question.

**Parameters**

* question (string) - The question to ask.
* option1 (string) - The first option text.
* option2 (string) - The second option text.
* manualDismiss (boolean) - Whether the player can manually dismiss.
* callback (function) - Function to call when answer is given.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:binaryQuestion("Continue?", "Yes", "No", false, callback)
```

---

### requestButtons

**Purpose**

Requests button selection from the player.

**Parameters**

* title (string) - The title of the request.
* buttons (table) - Table of button data with text and callbacks.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:requestButtons("Choose", {{text = "Button 1", callback = func1}, {text = "Button 2", callback = func2}})
```

---

### getPlayTime

**Purpose**

Returns the player's total play time.

**Returns**

number - The player's total play time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
    local playTime = player:getPlayTime()
    print("Player has played for " .. playTime .. " seconds")
```

---

### getSessionTime

**Purpose**

Returns the player's current session time.

**Returns**

number - The current session time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
    local sessionTime = player:getSessionTime()
    print("Current session: " .. sessionTime .. " seconds")
```

---

### getTotalOnlineTime

**Purpose**

Returns the player's total online time including current session.

**Returns**

number - The total online time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
    local totalTime = player:getTotalOnlineTime()
    print("Total online time: " .. totalTime .. " seconds")
```

---

### getLastOnline

**Purpose**

Returns a human-readable string of when the player was last online.

**Returns**

string - Human-readable time since last online.

**Realm**

Shared.

**Example Usage**

```lua
    local lastOnline = player:getLastOnline()
    print("Last online: " .. lastOnline)
```

---

### getLastOnlineTime

**Purpose**

Returns the timestamp of when the player was last online.

**Returns**

number - Unix timestamp of last online time.

**Realm**

Shared.

**Example Usage**

```lua
    local lastTime = player:getLastOnlineTime()
    print("Last online timestamp: " .. lastTime)
```

---

### createRagdoll

**Purpose**

Creates a ragdoll entity for the player.

**Parameters**

* freeze (boolean) - Whether to freeze the ragdoll physics.
* isDead (boolean) - Whether this ragdoll represents a dead player.

**Returns**

Entity - The created ragdoll entity.

**Realm**

Server.

**Example Usage**

```lua
    local ragdoll = player:createRagdoll(false, true)
```

---

### setRagdolled

**Purpose**

Sets the player's ragdoll state.

**Parameters**

* state (boolean) - Whether to ragdoll the player.
* time (number) - Time before auto-recovery.
* getUpGrace (number) - Grace period for getting up.
* getUpMessage (string) - Message to show during recovery.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    player:setRagdolled(true, 5, 2, "Getting up...")
```

---

### syncVars

**Purpose**

Synchronizes all networked variables for this player with the client.
    Sends global variables and entity-specific variables through networking.

**Parameters**

* None.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    -- Sync all variables for a player
    player:syncVars()
```

---

### setLocalVar

**Purpose**

Sets a local variable for this player and synchronizes it to the client.
    The variable is stored locally and sent through networking.

**Parameters**

* key (string) - The key/name of the variable.
* value (any) - The value to store.

**Returns**

None.

**Realm**

Server.

**Example Usage**

```lua
    -- Set a local variable for a player
    player:setLocalVar("customFlag", true)
```

---

### CanOverrideView

**Purpose**

Determines if the player can override their view (third person).
    Checks various conditions like ragdoll state, vehicle status, and configuration.

**Parameters**

* None.

**Returns**

boolean - True if the player can override their view, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
    if player:CanOverrideView() then
        print("Player can use third person view")
    end
```

---

### IsInThirdPerson

**Purpose**

Checks if the player is currently in third person view mode.
    Considers both global configuration and player preferences.

**Parameters**

* None.

**Returns**

boolean - True if third person is enabled, false otherwise.

**Realm**

Client.

**Example Usage**

```lua
    if player:IsInThirdPerson() then
        print("Player is in third person view")
    end
```

---

### getPlayTime

**Purpose**

Gets the total play time for this player, including current session.
    Considers character login time and previous play time.

**Parameters**

* None.

**Returns**

number - Total play time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
    local playTime = player:getPlayTime()
    print("Total play time: " .. playTime .. " seconds")
```

---

### getTotalOnlineTime

**Purpose**

Gets the total time this player has been online across all sessions.
    Includes stored time and current session time.

**Parameters**

* None.

**Returns**

number - Total online time in seconds.

**Realm**

Shared.

**Example Usage**

```lua
    local totalTime = player:getTotalOnlineTime()
    print("Total online time: " .. totalTime .. " seconds")
```

---

### getLastOnline

**Purpose**

Gets a human-readable string representing when the player was last online.
    Returns relative time (e.g., "2 hours ago").

**Parameters**

* None.

**Returns**

string - Human-readable time since last online.

**Realm**

Shared.

**Example Usage**

```lua
    local lastOnline = player:getLastOnline()
    print("Last online: " .. lastOnline)
```

---

### getLastOnlineTime

**Purpose**

Gets the timestamp when the player was last online.
    Returns the raw timestamp value.

**Parameters**

* None.

**Returns**

number - Unix timestamp of last online time.

**Realm**

Shared.

**Example Usage**

```lua
    local lastTime = player:getLastOnlineTime()
    print("Last online timestamp: " .. lastTime)
```

---

### setWaypoint

**Purpose**

Sets a waypoint for the player at the specified location.
    Creates a HUD element that shows the waypoint and distance.

**Parameters**

* name (string) - The name of the waypoint.
* vector (Vector) - The position where the waypoint should be set.
* onReach (function, optional) - Callback function when waypoint is reached.

**Returns**

None.

**Realm**

Client.

**Example Usage**

```lua
    -- Set a waypoint with callback when reached
    player:setWaypoint("Home", Vector(100, 200, 300), function()
        print("Reached home!")
    end)
```

---

### setWeighPoint

**Purpose**

Sets a weight-based waypoint for the player.
    Similar to setWaypoint but with weight considerations.

**Parameters**

* name (string) - The name/description of the waypoint.
* vector (Vector) - The position of the waypoint.
* onReach (function, optional) - Callback function when waypoint is reached.

**Returns**

None.

**Realm**

Client.

**Example Usage**

```lua
    -- Set a weight-based waypoint
    player:setWeighPoint("Heavy Item", Vector(500, 600, 700))
```

---

### setWaypointWithLogo

**Purpose**

Sets a waypoint with a custom logo/icon for the player.
    The logo will be displayed alongside the waypoint.

**Parameters**

* name (string) - The name/description of the waypoint.
* vector (Vector) - The position of the waypoint.
* logo (string) - The logo/icon identifier.
* onReach (function, optional) - Callback function when waypoint is reached.

**Returns**

None.

**Realm**

Client.

**Example Usage**

```lua
    -- Set a waypoint with custom logo
    player:setWaypointWithLogo("Shop", Vector(1000, 2000, 3000), "shop_icon")
```

---

### getLiliaData

**Purpose**

Retrieves a value from the player's local Lilia data storage.
    This is the client-side version of getLiliaData.

**Parameters**

* key (string) - The data key to retrieve.
* default (any) - The default value to return if the key doesn't exist.

**Returns**

any - The stored value or the default value if not found.

**Realm**

Client.

**Example Usage**

```lua
    -- Get player's local settings
    local settings = player:getLiliaData("settings", {})
    if settings then
        print("Player has custom settings")
    end
```

---

### getAllLiliaData

**Purpose**

Retrieves all stored Lilia data for this player.
    Returns a table containing all key-value pairs.

**Parameters**

* None.

**Returns**

table - All stored Lilia data.

**Realm**

Shared.

**Example Usage**

```lua
    local allData = player:getAllLiliaData()
    for key, value in pairs(allData) do
        print(key .. ": " .. tostring(value))
    end
```

---

### getFlags

**Purpose**

Gets the flags associated with this player's character.
    Returns the character flags if available, otherwise returns an empty string.

**Parameters**

* None.

**Returns**

string - The character flags or empty string if no character.

**Realm**

Shared.

**Example Usage**

```lua
    local flags = player:getFlags()
    print("Player flags: " .. flags)
```

---

### setFlags

**Purpose**

Sets the flags for this player's character.
    Updates the character flags if a character exists.

**Parameters**

* flags (string) - The flags to set for the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Set player character flags
    player:setFlags("abc")
```

---

### giveFlags

**Purpose**

Adds flags to this player's character.
    Appends the new flags to existing character flags.

**Parameters**

* flags (string) - The flags to add to the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Give additional flags to player
    player:giveFlags("d")
```

---

### takeFlags

**Purpose**

Removes flags from this player's character.
    Removes the specified flags from existing character flags.

**Parameters**

* flags (string) - The flags to remove from the character.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Remove flags from player
    player:takeFlags("a")
```

---

### getPlayerFlags

**Purpose**

Gets the player-specific flags stored in Lilia data.
    Returns flags that are specific to the player, not the character.

**Parameters**

* None.

**Returns**

string - The player flags or empty string if none set.

**Realm**

Shared.

**Example Usage**

```lua
    local playerFlags = player:getPlayerFlags()
    print("Player flags: " .. playerFlags)
```

---

### setPlayerFlags

**Purpose**

Sets the player-specific flags in Lilia data.
    Stores flags that are specific to the player, not the character.

**Parameters**

* flags (string) - The player flags to set.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Set player-specific flags
    player:setPlayerFlags("xyz")
```

---

### hasPlayerFlags

**Purpose**

Checks if the player has any of the specified player flags.
    Checks player-specific flags stored in Lilia data.

**Parameters**

* flags (string) - A string of flag characters to check.

**Returns**

boolean - True if the player has at least one of the specified flags, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasPlayerFlags("x") then
        print("Player has flag 'x'")
    end
```

---

### givePlayerFlags

**Purpose**

Adds player-specific flags to this player.
    Adds new flags that the player doesn't already have and runs callbacks.

**Parameters**

* flags (string) - The player flags to add.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Give additional player flags
    player:givePlayerFlags("xyz")
```

---

### takePlayerFlags

**Purpose**

Removes player-specific flags from this player.
    Removes specified flags and runs callbacks for removed flags.

**Parameters**

* flags (string) - The player flags to remove.

**Returns**

None.

**Realm**

Shared.

**Example Usage**

```lua
    -- Remove player flags
    player:takePlayerFlags("x")
```

---

### hasFlags

**Purpose**

Checks if the player has any of the specified flags.
    Checks both character flags and player flags, and runs hook callbacks.

**Parameters**

* flags (string) - A string of flag characters to check.

**Returns**

boolean - True if the player has at least one of the specified flags, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    if player:hasFlags("a") then
        print("Player has flag 'a'")
    end
```

---

### NetworkAnimation

**Purpose**

Applies bone angle manipulations for animations on the client side.
    This is the client-side version of NetworkAnimation.

**Parameters**

* active (boolean) - Whether the animation is active.
* boneData (table) - The bone data containing bone names and angles.

**Returns**

None.

**Realm**

Client.

**Example Usage**

```lua
    -- Apply bone animation data
    player:NetworkAnimation(true, {
        ["ValveBiped.Bip01_Head1"] = Angle(0, 45, 0)
    })
```

---

### playTimeGreaterThan

**Purpose**

Checks if the player's total play time is greater than the specified time.
    Compares the player's accumulated play time against the given threshold.

**Parameters**

* time (number) - The time threshold to compare against in seconds.

**Returns**

boolean - True if the player's play time is greater than the specified time, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
    -- Check if player has played for more than 1 hour
    if player:playTimeGreaterThan(3600) then
        print("Player has been playing for more than 1 hour")
    end
```

