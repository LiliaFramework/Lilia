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

Determines whether the player's position is stuck in the world.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the trace detects a stuck state.

**Example Usage**

```lua
if player:isStuck() then
    player:SetPos(player:GetPos() + Vector(0, 0, 16))
end
```

---

### isNearPlayer

**Purpose**

Checks if an entity is within the given radius of the player.

**Parameters**

* `radius` (`number`): Distance in units.

* `entity` (`Entity`): Entity to compare.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the entity is close enough.

**Example Usage**

```lua
if player:isNearPlayer(128, target) then
    print("Target is nearby")
end
```

---

### entitiesNearPlayer

**Purpose**

Returns a table of entities within radius of the player.

**Parameters**

* `radius` (`number`): Search distance in units.

* `playerOnly` (`boolean|nil`): Only include players when `true`.

**Realm**

`Shared`

**Returns**

* `table`: List of nearby entities.

**Example Usage**

```lua
for _, ent in ipairs(player:entitiesNearPlayer(256)) do
    if ent:IsPlayer() then
        ent:ChatPrint("Someone is close to you!")
    else
        DebugDrawBox(ent:GetPos(), ent:OBBMins(), ent:OBBMaxs(), 0, 255, 0, 0, 5)
    end
end
```

---

### getItemWeapon

**Purpose**

Returns the active weapon entity and associated item if equipped.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `Entity|nil`: Weapon entity when matched.

* `Item|nil`: Inventory item associated with the weapon.

**Example Usage**

```lua
local weapon, item = player:getItemWeapon()
```

---

### isRunning

**Purpose**

Checks whether the player is moving faster than walking speed.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the player is running.

**Example Usage**

```lua
if player:isRunning() then
    -- player is sprinting
end
```

---

### isFemale

**Purpose**

Returns `true` if the player's model is considered female.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: Whether a female model is detected.

**Example Usage**

```lua
if player:isFemale() then
    print("Female model detected")
end
```

---

### IsFamilySharedAccount

**Purpose**

Checks if the player is using a Steam Family Share account.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: `true` when the account is shared.

**Example Usage**

```lua
if player:IsFamilySharedAccount() then
    print("Using a shared account")
end
```

---

### getItemDropPos

**Purpose**

Finds a safe position in front of the player to drop items.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `Vector`: World position for dropping items.

**Example Usage**

```lua
local pos = player:getItemDropPos()
```

---

### getItems

**Purpose**

Returns the player's inventory item list if a character is loaded.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table|nil`: Table of items or `nil` if absent.

**Example Usage**

```lua
-- Iterate player's items to calculate total weight
local total = 0

for _, it in pairs(player:getItems() or {}) do
    total = total + it.weight
end
```

---

### getTracedEntity

**Purpose**

Performs a simple trace from the player's shoot position.

**Parameters**

* `distance` (`number|nil`): Trace length in units. Default is `96`.

**Realm**

`Shared`

**Returns**

* `Entity|nil`: The entity hit or `nil`.

**Example Usage**

```lua
-- Grab the entity the player is pointing at
local entity = player:getTracedEntity(96)
```

---

### getTrace

**Purpose**

Returns a hull trace in front of the player.

**Parameters**

* `distance` (`number|nil`): Hull length in units. Default is `200`.

**Realm**

`Shared`

**Returns**

* `table`: Trace result.

**Example Usage**

```lua
-- Use a hull trace for melee attacks
local tr = player:getTrace(48)
```

---

### getEyeEnt

**Purpose**

Returns the entity the player is looking at within a distance.

**Parameters**

* `distance` (`number|nil`): Maximum distance. Default is `150`.

**Realm**

`Shared`

**Returns**

* `Entity|nil`: The entity or `nil` if too far.

**Example Usage**

```lua
-- Show the name of the object being looked at
local target = player:getEyeEnt(128)

if IsValid(target) then
    player:ChatPrint(string.format("Class: %s", target:GetClass()))
end
```

---

### notify

**Purpose**

Sends a plain notification message to the player.

**Parameters**

* `message` (`string`): Text to display.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Send a welcome notification and log the join event
player:notify("Welcome to the server!")
file.Append("welcome.txt", player:SteamID() .. " joined\n")
```

---

### notifyLocalized

**Purpose**

Sends a localized notification to the player.

**Parameters**

* `message` (`string`): Translation key.

* `...`: Additional parameters for localization.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Send a localized message including the player's name and score
local score = player:GetFrags()
player:notifyLocalized("greeting_key", player:Name(), score)
```

---

### CanEditVendor

**Purpose**

Determines whether the player can edit the given vendor.

**Parameters**

* `vendor` (`Entity`): Vendor entity to check.

**Realm**

`Server`

**Returns**

* `boolean`: `true` if allowed to edit.

**Example Usage**

```lua
if player:CanEditVendor(vendor) then
    vendor:OpenEditor(player)
end
```

---
### isStaff

**Purpose**

Returns `true` if the player belongs to a staff group.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: Result from the privilege check.

**Example Usage**

```lua
-- Verify staff permissions for administrative actions
local result = player:isStaff()
```

---

### isVIP

**Purpose**

Checks whether the player is in the VIP group.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: Result from privilege check.

**Example Usage**

```lua
-- Test if the player has VIP status
local result = player:isVIP()
```

---

### isStaffOnDuty

**Purpose**

Determines if the player is currently in the staff faction.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if staff faction is active.

**Example Usage**

```lua
-- Confirm the player is currently in a staff role
local result = player:isStaffOnDuty()
```

---

### isFaction

**Purpose**

Checks if the player's character belongs to the given faction.

**Parameters**

* `faction` (`number`): Faction index to compare.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the factions match.

**Example Usage**

```lua
-- Compare the player's faction to a requirement
local result = player:isFaction(faction)
```

---

### isClass

**Purpose**

Returns `true` if the player's character is of the given class.

**Parameters**

* `class` (`number`): Class index to compare.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether the character matches the class.

**Example Usage**

```lua
-- Determine if the player's class matches
local result = player:isClass(class)
```

---

### hasWhitelist

**Purpose**

Determines if the player has whitelist access for a faction.

**Parameters**

* `faction` (`number`): Faction index.

**Realm**

`Shared`

**Returns**

* `boolean`: True if whitelisted.

**Example Usage**

```lua
-- Check for whitelist permission on a faction
local result = player:hasWhitelist(faction)
```

---

### getClass

**Purpose**

Retrieves the class index of the player's character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number|nil`: Class index or nil.

**Example Usage**

```lua
-- Retrieve the current class index
local result = player:getClass()
```

---

### hasClassWhitelist

**Purpose**

Checks if the player's character is whitelisted for a class.

**Parameters**

* `class` (`number`): Class index.

**Realm**

`Shared`

**Returns**

* `boolean`: True if class whitelist exists.

**Example Usage**

```lua
-- Verify the player is approved for a specific class
local result = player:hasClassWhitelist(class)
```

---

### getClassData

**Purpose**

Returns the class table of the player's current class.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table|nil`: Class definition table.

**Example Usage**

```lua
-- Access data table for the player's class
local result = player:getClassData()
```

---

### getDarkRPVar

**Purpose**

Compatibility helper for retrieving money with DarkRP-style calls.

**Parameters**

* `var` (`string`): Currently only supports `"money"`.

**Realm**

`Shared`

**Returns**

* `number|nil`: Money amount or nil.

**Example Usage**

```lua
-- Read money amount in a DarkRP-compatible way
local result = player:getDarkRPVar(var)
```

---

### getMoney

**Purpose**

Convenience function to get the character's money amount.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Current funds or `0`.

**Example Usage**

```lua
-- Fetch the character's stored funds
local result = player:getMoney()
```

---

### canAfford

**Purpose**

Checks if the player has enough money for a purchase.

**Parameters**

* `amount` (`number`): Cost to test.

**Realm**

`Shared`

**Returns**

* `boolean`: True if funds are sufficient.

**Example Usage**

```lua
-- Check if the player has enough money to buy something
local result = player:canAfford(amount)
```

---

### hasSkillLevel

**Purpose**

Verifies the player's character meets an attribute level.

**Parameters**

* `skill` (`string`): Attribute ID.

* `level` (`number`): Required level.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether the character satisfies the requirement.

**Example Usage**

```lua
-- Ensure the player meets a single skill requirement
local result = player:hasSkillLevel(skill, level)
```

---

### meetsRequiredSkills

**Purpose**

Checks a table of skill requirements against the player.

**Parameters**

* `requiredSkillLevels` (`table`): Mapping of attribute IDs to levels.

**Realm**

`Shared`

**Returns**

* `boolean`: True if all requirements are met.

**Example Usage**

```lua
-- Validate multiple skill requirements at once
local result = player:meetsRequiredSkills(requiredSkillLevels)
```

---

### forceSequence

**Purpose**

Plays an animation sequence and optionally freezes the player.

**Parameters**

* `sequenceName` (`string`): Sequence to play.

* `callback` (`function|nil`): Called when finished.

* `time` (`number|nil`): Duration override.

* `noFreeze` (`boolean`): Don't freeze movement when true.

**Realm**

`Shared`

**Returns**

* `number|boolean`: Duration or `false` on failure.

**Example Usage**

```lua
-- Play an animation while freezing the player
local result = player:forceSequence(sequenceName, callback, time, noFreeze)
```

---

### leaveSequence

**Purpose**

Stops any forced sequence and restores player movement.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Stop the player's forced animation sequence
player:leaveSequence()
```

---

### restoreStamina

**Purpose**

Increases the player's stamina value.

**Parameters**

* `amount` (`number`): Amount to restore.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Give the player extra stamina points
player:restoreStamina(amount)
```

---

### consumeStamina

**Purpose**

Reduces the player's stamina value.

**Parameters**

* `amount` (`number`): Amount to subtract.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Spend stamina as the player performs an action
player:consumeStamina(amount)
```

---

### addMoney

**Purpose**

Adds funds to the player's character, clamping to limits.

**Parameters**

* `amount` (`number`): Money to add.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Reward the player and announce the payout
player:addMoney(100)
player:notifyLocalized("questReward", lia.currency.get(100))
```

---

### takeMoney

**Purpose**

Removes money from the player's character.

**Parameters**

* `amount` (`number`): Amount to subtract.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Remove money from the player's character
player:takeMoney(amount)
```

---

### WhitelistAllClasses

**Purpose**

Grants whitelist access to every registered class.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Unlock every class for the player
player:WhitelistAllClasses()
```

---

### WhitelistAllFactions

**Purpose**

Whitelists the player for all factions.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:WhitelistAllFactions()
```

---

### WhitelistEverything

**Purpose**

Convenience method to whitelist all factions and classes.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Give the player access to all content
player:WhitelistEverything()
```

---

### classWhitelist

**Purpose**

Adds a single class to the character's whitelist table.

**Parameters**

* `class` (`number`): Class index to whitelist.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:classWhitelist(CLASS_MEDIC)
```

---

### classUnWhitelist

**Purpose**

Removes a class from the character's whitelist table.

**Parameters**

* `class` (`number`): Class index to remove.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:classUnWhitelist(CLASS_MEDIC)
```

---

### setWhitelisted

**Purpose**

Sets or clears whitelist permission for a faction.

**Parameters**

* `faction` (`number`): Faction index.

* `whitelisted` (`boolean|nil`): Enable when true, disable when false/nil.

**Realm**

`Server`

**Returns**

* `boolean`: True if the faction exists.

**Example Usage**

```lua
player:setWhitelisted(FACTION_POLICE, true)
```

---

### loadLiliaData

**Purpose**

Loads persistent Lilia data for the player from the database.

**Parameters**

* `callback` (`function|nil`): Invoked with the loaded table.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:loadLiliaData(function(data) print(data) end)
```

---

### saveLiliaData

**Purpose**

Saves the player's Lilia data back to the database.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:saveLiliaData()
```

---

### setLiliaData

**Purpose**

Stores a value in the player's persistent data table.

**Parameters**

* `key` (`string`): Data key.

* `value` (`any`): Value to store.

* `noNetworking` (`boolean|nil`): Skip network update when true.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setLiliaData("settings", {foo = true})
```

---

### setWaypoint

**Purpose**

Sends a waypoint to the client at the specified position.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): World position.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setWaypoint("Objective", vector_origin)
```

---

### setWeighPoint

**Purpose**

Alias of `setWaypoint()` for backwards compatibility.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): World position.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setWeighPoint("Target", Vector(100, 100, 0))
```

---

### setWaypointWithLogo

**Purpose**

Creates a waypoint using a custom logo material.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): World position.

* `logo` (`string`): Material path for the icon.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setWaypointWithLogo("Objective", vector_origin, "path/to/icon.png")
```

---

### getLiliaData

**Purpose**

Retrieves a stored value from the player's data table.

**Parameters**

* `key` (`string`): Data key.

* `default` (`any`): Returned if the key is nil.

**Realm**

`Server`

**Returns**

* `any`: Stored value or default.

**Example Usage**

```lua
local settings = player:getLiliaData("settings", {})
```

---

### getData

**Purpose**

Alias of `getLiliaData`.

**Parameters**

* `key` (`string`): Data key.

* `default` (`any`): Returned if the key is nil.

**Realm**

`Server`

**Returns**

* `any`: Stored value or default.

**Example Usage**

```lua
local settings = player:getData("settings", {})
```

---

### getAllLiliaData

**Purpose**

Returns the entire table of persistent data for the player.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `table`: Player data table.

**Example Usage**

```lua
local data = player:getAllLiliaData()
```

---

### getFlags

**Purpose**

Returns the flags associated with the player's character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Character flags or empty string.

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

Replaces the character's flag string.

**Parameters**

* `flags` (`string`): Flags to assign.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setFlags("ab")
```

---

### giveFlags

**Purpose**

Adds flags to the character.

**Parameters**

* `flags` (`string`): Flags to add.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:giveFlags("a")
```

---

### takeFlags

**Purpose**

Removes flags from the character.

**Parameters**

* `flags` (`string`): Flags to remove.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:takeFlags("a")
```

---

### getPlayerFlags

**Purpose**

Gets the player's personal flag string.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Player-specific flags.

**Example Usage**

```lua
local pf = player:getPlayerFlags()
```

---

### setPlayerFlags

**Purpose**

Sets the player's personal flags.

**Parameters**

* `flags` (`string`): Flags to assign.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setPlayerFlags("v")
```

---

### hasPlayerFlags

**Purpose**

Checks for any of the specified personal flags.

**Parameters**

* `flags` (`string`): Flags to check.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether any flag is present.

**Example Usage**

```lua
if player:hasPlayerFlags("v") then
    print("Player is VIP")
end
```

---

### givePlayerFlags

**Purpose**

Adds personal flags to the player.

**Parameters**

* `flags` (`string`): Flags to add.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:givePlayerFlags("v")
```

---

### takePlayerFlags

**Purpose**

Removes personal flags from the player.

**Parameters**

* `flags` (`string`): Flags to remove.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:takePlayerFlags("v")
```

---

### hasFlags

**Purpose**

Checks both character and personal flags for any of the supplied flags.

**Parameters**

* `flags` (`string`): Flags to check.

**Realm**

`Shared`

**Returns**

* `boolean`: True if any flag is present.

**Example Usage**

```lua
if player:hasFlags("a") then
    print("Has admin access")
end
```

---

### setRagdoll

**Purpose**

Associates a ragdoll entity with the player for later retrieval.

**Parameters**

* `entity` (`Entity`): The ragdoll entity.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setRagdoll(ragdollEnt)
```

---

### NetworkAnimation

**Purpose**

Broadcasts animation bone data to all clients.

**Parameters**

* `active` (`boolean`): Enable or disable manipulation.

* `boneData` (`table`): Map of bone names to angles.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:NetworkAnimation(true, {
    ["ValveBiped.Bip01_Head"] = Angle(0, 90, 0)
})
```

---

### banPlayer

**Purpose**

Bans the player for a given reason and duration then kicks them.

**Parameters**

* `reason` (`string|nil`): Message shown to the player.

* `duration` (`number|nil`): Length in minutes, or `nil` for permanent.

* `banner` (`Player|nil`): Player issuing the ban.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:banPlayer("Breaking rules", 60, admin)
```

---

### setAction

**Purpose**

Displays an action bar for a set duration and optionally runs a callback.

**Parameters**

* `text` (`string|nil`): Text to display, or nil to clear.

* `time` (`number|nil`): How long to show it for in seconds. Defaults to 5. If `time` ≤ 0, the callback runs immediately with no bar.

* `callback` (`function|nil`): Executed when time elapses.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setAction("Lockpicking", 5)
```

---

### doStaredAction

**Purpose**

Runs an action only while the player stares at the entity.

**Parameters**

* `entity` (`Entity`): Target entity.

* `callback` (`function`): Called when the timer finishes.

* `time` (`number`): Duration in seconds.

* `onCancel` (`function|nil`): Called if gaze breaks.

* `distance` (`number|nil`): Max distance to maintain, defaults to 96.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:doStaredAction(door, function() door:Open() end, 3)
```

---

### stopAction

**Purpose**

Cancels any running action bar on the player.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:stopAction()
```

---

### requestDropdown

**Purpose**

Prompts the client with a dropdown selection dialog.

**Parameters**

* `title` (`string`): Window title.

* `subTitle` (`string`): Description text.

* `options` (`table`): Table of options.

* `callback` (`function|nil`): Receives the chosen value.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:requestDropdown("Choose", "Pick one", {"A", "B"}, print)
```

---

### requestOptions

**Purpose**

Asks the client to select one or more options from a list.

**Parameters**

* `title` (`string`): Window title.

* `subTitle` (`string`): Description text.

* `options` (`table`): Available options.

* `limit` (`number`): Maximum selections allowed.

* `callback` (`function|nil`): Receives the chosen values.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:requestOptions("Permissions", "Select", {"A", "B"}, 2, print)
```

---

### requestString

**Purpose**

Requests a string from the client.

**Parameters**

* `title` (`string`): Prompt title.

* `subTitle` (`string`): Prompt description.

* `callback` (`function|nil`): Called with the string.

* `default` (`string|nil`): Default value.

**Realm**

`Server`

**Returns**

* `Deferred|nil`: Deferred object when no callback supplied.

**Example Usage**

```lua
player:requestString("Name", "Enter text", print)
```

---

### requestArguments

**Purpose**

Prompts the client for multiple typed values.

**Parameters**

* `title` (`string`): Window title.

* `argTypes` (`table`): Field definitions.

* `callback` (`function|nil`): Called with a table of values.

**Realm**

`Server`

**Returns**

* `Deferred|nil`: Deferred object when no callback supplied.

**Example Usage**

```lua
player:requestArguments("Info", {Name = "string", Age = "int"}, print)
```

---

### binaryQuestion

**Purpose**

Displays a yes/no style question to the player.

**Parameters**

* `question` (`string`): Main text.

* `option1` (`string`): Text for the first option.

* `option2` (`string`): Text for the second option.

* `manualDismiss` (`boolean`): Require manual closing.

* `callback` (`function`): Called with chosen value.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:binaryQuestion("Proceed?", "Yes", "No", false, print)
```

---

### requestButtons

**Purpose**

Prompts the player with multiple buttons that each trigger a server callback.

**Parameters**

* `title` (`string`): Window title.

* `buttons` (`table`): Array where each element contains button text and a callback.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:requestButtons("Select one", {
    {"A", function(client) print("Chose A") end},
    {"B", function(client) print("Chose B") end}
})
```

---

### getPlayTime

**Purpose**

Calculates how long the player has been on the server.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `number`: Total seconds of play-time.

**Example Usage**

```lua
print(player:getPlayTime())
```

---

### getSessionTime

**Purpose**

Returns how long the player has been connected in the current session.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `number`: Seconds since the player joined this session.

**Example Usage**

```lua
print(player:getSessionTime())
```

---

### getTotalOnlineTime

**Purpose**

Returns the player's total online time across all sessions.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `number`: Seconds spent online in total.

**Example Usage**

```lua
print(player:getTotalOnlineTime())
```

---

### getLastOnline

**Purpose**

Returns how long ago the player was last seen online.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `string`: Human readable time description.

**Example Usage**

```lua
print("Last online:", player:getLastOnline())
```

---

### getLastOnlineTime

**Purpose**

Provides the timestamp of the player's last connection.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `number`: Unix time of the last session end.

**Example Usage**

```lua
local ts = player:getLastOnlineTime()
```

---

### createRagdoll

**Purpose**

Spawns a ragdoll copy of the player and optionally freezes it.

**Parameters**

* `freeze` (`boolean|nil`): Disable physics when `true`.

* `isDead` (`boolean|nil`): Mark as a death ragdoll.

**Realm**

`Server`

**Returns**

* `Entity`: The created ragdoll.

**Example Usage**

```lua
local rag = player:createRagdoll(true)
```

---

### setRagdolled

**Purpose**

Toggles the player's ragdoll state for a duration.

**Parameters**

* `state` (`boolean`): Enable or disable ragdoll.

* `time` (`number|nil`): Duration before standing up.

* `getUpGrace` (`number|nil`): Extra time to prevent early stand.

* `getUpMessage` (`string|nil`): Message while downed.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setRagdolled(true, 5)
```

---

### syncVars

**Purpose**

Sends all networked variables to the player.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:syncVars()
```

---

### setLocalVar

**Purpose**

Sets a networked local variable on the player and triggers the **LocalVarChanged** hook.

**Parameters**

* `key` (`string`): Variable name.

* `value` (`any`): Value to set.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
player:setLocalVar("health", 75)
```

---

### getPlayTime

**Purpose**

Returns play-time calculated client-side when called on a client.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `number`: Seconds of play-time.

**Example Usage**

```lua
print(LocalPlayer():getPlayTime())
```

---

### getTotalOnlineTime

**Purpose**

Returns the player's total online time on the client side.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `number`: Accumulated seconds of play-time.

**Example Usage**

```lua
print(LocalPlayer():getTotalOnlineTime())
```

---

### getLastOnline

**Purpose**

Reports how long it has been since the player was last online.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `string`: Friendly time string.

**Example Usage**

```lua
chat.AddText(LocalPlayer():getLastOnline())
```

---

### getLastOnlineTime

**Purpose**

Gives the Unix timestamp of the player's last session end.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `number`: Time value in seconds.

**Example Usage**

```lua
local last = LocalPlayer():getLastOnlineTime()
```

---

### setWaypoint

**Purpose**

Displays a waypoint on the HUD until the player reaches it.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): World position.

* `onReach` (`function|nil`): Called when reached.

**Realm**

`Client`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
LocalPlayer():setWaypoint("Home", vector_origin)
```

---

### setWeighPoint

**Purpose**

Alias of the client version of `setWaypoint`.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): World position.

* `onReach` (`function|nil`): Called when reached.

**Realm**

`Client`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
LocalPlayer():setWeighPoint("Spot", Vector(10, 10, 0))
```

---

### setWaypointWithLogo

**Purpose**

Places a waypoint using a logo material on the client HUD.

**Parameters**

* `name` (`string`): Display label.

* `vector` (`Vector`): Position to navigate to.

* `logo` (`string`): Material path for the icon.

* `onReach` (`function|nil`): Called when reached.

**Realm**

`Client`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
LocalPlayer():setWaypointWithLogo("Loot", Vector(1, 1, 1), "icon.png")
```

---

### getLiliaData

**Purpose**

Client-side accessor for stored player data.

**Parameters**

* `key` (`string`): Data key.

* `default` (`any`): Fallback value.

**Realm**

`Client`

**Returns**

* `any`: Stored value or default.

**Example Usage**

```lua
local data = LocalPlayer():getLiliaData("settings")
```

---

### getData

**Purpose**

Alias of `getLiliaData`.

**Parameters**

* `key` (`string`): Data key.

* `default` (`any`): Fallback value.

**Realm**

`Client`

**Returns**

* `any`: Stored value or default.

**Example Usage**

```lua
local data = LocalPlayer():getData("settings")
```

---

### getAllLiliaData

**Purpose**

Returns the entire local data table for the player.

**Parameters**

* None

**Realm**

`Client`

**Returns**

* `table`: Local data table.

**Example Usage**

```lua
local data = LocalPlayer():getAllLiliaData()
```

---

### NetworkAnimation

**Purpose**

Applies or clears client-side bone angles based on animation data.

**Parameters**

* `active` (`boolean`): Enable or disable animation.

* `boneData` (`table`): Bones and angles to apply.

**Realm**

`Client`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
LocalPlayer():NetworkAnimation(true, {
    ["ValveBiped.Bip01_Head"] = Angle(0, 90, 0)
})
```

---

### playTimeGreaterThan

**Purpose**

Checks if the player's total play time exceeds a threshold.

**Parameters**

* `time` (`number`): Time in seconds to compare against.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether the player has played longer than `time`.

**Example Usage**

```lua
if player:playTimeGreaterThan(3600) then
    print("Played for over an hour")
end
```
