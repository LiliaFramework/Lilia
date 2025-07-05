# Player Meta

Lilia extends Garry's Mod players with characters, inventories, and permission checks. This reference details the meta functions enabling that integration.

---

## Overview

Player meta functions provide quick access to the active character, networking helpers for messaging or data transfer, and utility checks such as admin status. Players are entity objects that hold at most one Character instance, so these helpers unify player-related logic across the framework.

---

### getChar

**Description:**

Returns the currently loaded character object for this player.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* Character|None – The player's active character.


**Example Usage:**

```lua
-- Retrieve the character to modify inventory
local char = player:getChar()
```

---

### Name

**Description:**

Returns either the character's roleplay name or the player's Steam name.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* string – Display name.


**Example Usage:**

```lua
-- Print the roleplay name in chat
chat.AddText(player:Name())
```

---

### hasPrivilege

**Description:**

Wrapper for CAMI privilege checks.

**Parameters:**

* `privilegeName` (`string`) – Privilege identifier.


**Realm:**

* Shared


**Returns:**

* boolean – Result from CAMI.PlayerHasAccess.


**Example Usage:**

```lua
-- Deny access if the player lacks a privilege
if not player:hasPrivilege("Manage") then
    return false
end
```

---

### getCurrentVehicle

**Description:**

Safely returns the vehicle the player is currently using.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* Entity|None – Vehicle entity or None.


**Example Usage:**

```lua
-- Attach a camera to the vehicle the player is in
local veh = player:getCurrentVehicle()
if IsValid(veh) then
    AttachCamera(veh)
end
```

---

### hasValidVehicle

**Description:**

Determines if the player is currently inside a valid vehicle.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* boolean – True if a vehicle entity is valid.


**Example Usage:**

```lua
-- Allow honking only when in a valid vehicle
if player:hasValidVehicle() then
    player:GetVehicle():EmitSound("Horn")
end
```

---

### isNoClipping

**Description:**

Returns true if the player is in noclip mode and not inside a vehicle.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* boolean – Whether the player is noclipping.


**Example Usage:**

```lua
-- Disable certain actions while noclipping
if player:isNoClipping() then return end
```

---

### hasRagdoll

**Description:**

Checks if the player currently has an active ragdoll entity.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* boolean – True when a ragdoll entity exists.


**Example Usage:**

```lua
if player:hasRagdoll() then
    print("Player is ragdolled")
end
```

---

### CanOverrideView

**Description:**

Checks if the player is allowed to override the camera view. A valid character

must be loaded and the player cannot be in a vehicle or ragdoll. The option

`thirdPersonEnabled` must be enabled both client and server side and the

`ShouldDisableThirdperson` hook must not return `true`.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True when a third person view may be used.

**Example Usage:**

```lua
if player:CanOverrideView() then
    -- Place the camera behind the player
end
```

---

### IsInThirdPerson

**Description:**

Returns whether third person view is enabled for this player according to the

`thirdPersonEnabled` option and configuration.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True if third person mode is enabled.

**Example Usage:**

```lua
if player:IsInThirdPerson() then
    print("Third person active")
end
```

---

### removeRagdoll

**Description:**

Safely removes the player's ragdoll entity if present.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Clean up any ragdoll left behind
player:removeRagdoll()
```

---

### getRagdoll

**Description:**

Retrieves the ragdoll entity associated with the player.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* Entity|None – The ragdoll entity or None.


**Example Usage:**

```lua
local ragdoll = player:getRagdoll()
```

---

### isStuck

**Description:**

Determines whether the player's position is stuck in the world.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* boolean – True if the trace detects a stuck state.


**Example Usage:**

if player:isStuck() then

    player:SetPos(player:GetPos() + Vector(0, 0, 16))

end

```
---

### isNearPlayer

**Description:**

Checks if an entity is within the given radius of the player.

**Parameters:**

* `radius` (`number`) – Distance in units.

* `entity` (`Entity`) – Entity to compare.

**Realm:**

* Shared

**Returns:**

* boolean – True if the entity is close enough.

**Example Usage:**

if player:isNearPlayer(128, target) then
    print("Target is nearby")
end
```

---

### entitiesNearPlayer

**Description:**

Returns a table of entities within radius of the player.

**Parameters:**

* `radius` (`number`) – Search distance in units.


* `playerOnly` (`boolean|None`) – Only include players when true.


**Realm:**

* Shared


**Returns:**

* table – List of nearby entities.


**Example Usage:**

```lua
for _, ent in ipairs(player:entitiesNearPlayer(256)) do
    if ent:IsPlayer() then
        ent:ChatPrint(L("nearPlayer"))
    else
        DebugDrawBox(ent:GetPos(), ent:OBBMins(), ent:OBBMaxs(), 0, 255, 0, 0, 5)
    end
end
```

---

### getItemWeapon

**Description:**

Returns the active weapon entity and associated item if equipped.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* Entity|None – Weapon entity when matched.

* Item|None – Inventory item associated with the weapon.


**Example Usage:**

```lua
local weapon, item = player:getItemWeapon()
```

---

### isRunning

**Description:**

Checks whether the player is moving faster than walking speed.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* boolean – True if the player is running.


**Example Usage:**

if player:isRunning() then

    -- player is sprinting

end

```
---

### isFemale

**Description:**

Returns true if the player's model is considered female.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Whether a female model is detected.

**Example Usage:**

```lua

if player:isFemale() then

    print("Female model detected")

end

```
---

### getItemDropPos

**Description:**

Finds a safe position in front of the player to drop items.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Vector – World position for dropping items.

**Example Usage:**

```lua

local pos = player:getItemDropPos()

```
---

### getItems

**Description:**

Returns the player's inventory item list if a character is loaded.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table|None – Table of items or None if absent.

**Example Usage:**

```lua

-- Iterate player's items to calculate total weight

for _, it in pairs(player:getItems() or {}) do

    total = total + it.weight

end

```
---

### getTracedEntity

**Description:**

Performs a simple trace from the player's shoot position.

**Parameters:**

* `distance` (`number`) – Trace length in units.

**Realm:**

* Shared

**Returns:**

* Entity|None – The entity hit or None.

**Example Usage:**

```lua

-- Grab the entity the player is pointing at

local entity = player:getTracedEntity(96)

```
---

### getTrace

**Description:**

Returns a hull trace in front of the player.

**Parameters:**

* `distance` (`number`) – Hull length in units.

**Realm:**

* Shared

**Returns:**

* table – Trace result.

**Example Usage:**

```lua

-- Use a hull trace for melee attacks

local tr = player:getTrace(48)

```
---

### getEyeEnt

**Description:**

Returns the entity the player is looking at within a distance.

**Parameters:**

* `distance` (`number`) – Maximum distance.

**Realm:**

* Shared

**Returns:**

* Entity|None – The entity or None if too far.

**Example Usage:**

```lua

-- Show the name of the object being looked at

local target = player:getEyeEnt(128)

if IsValid(target) then

    player:ChatPrint(string.format(L("targetClass"), target:GetClass()))

end

```
---

### notify

**Description:**

Sends a plain notification message to the player.

**Parameters:**

* `message` (`string`) – Text to display.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Send a welcome notification and log the join event

player:notify("Welcome to the server!")

file.Append("welcome.txt", player:SteamID() .. " joined\n")

```
---

### notifyLocalized

**Description:**

Sends a localized notification to the player.

**Parameters:**

* `message` (`string`) – Translation key.

* ... – Additional parameters for localization.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Send a localized message including the player's name and score

local score = player:GetFrags()

player:notifyLocalized("greeting_key", player:Name(), score)

```
---

### CanEditVendor

**Description:**

Determines whether the player can edit the given vendor.

**Parameters:**

* `vendor` (`Entity`) – Vendor entity to check.

**Realm:**

* Server

**Returns:**

* boolean – True if allowed to edit.

**Example Usage:**

```lua

if player:CanEditVendor(vendor) then

    vendor:OpenEditor(player)

end

```
---

### isUser

**Description:**

Convenience wrapper to check if the player is in the "user" group.

**Parameters:**

* None

**Realm:**

* Shared


**Returns:**

* boolean – Whether usergroup is "user".

**Example Usage:**

```lua

-- Check if the player belongs to the default user group

local result = player:isUser()

```
---

### isStaff

**Description:**

Returns true if the player belongs to a staff group.

**Parameters:**

* None

**Realm:**

* Shared


**Returns:**

* boolean – Result from the privilege check.

**Example Usage:**

```lua

-- Verify staff permissions for administrative actions

local result = player:isStaff()

```
---

### isVIP

**Description:**

Checks whether the player is in the VIP group.

**Parameters:**

* None

**Realm:**

* Shared


**Returns:**

* boolean – Result from privilege check.

**Example Usage:**

```lua

-- Test if the player has VIP status

local result = player:isVIP()

```
---

### isStaffOnDuty

**Description:**

Determines if the player is currently in the staff faction.

**Parameters:**

* None

**Realm:**

* Shared
**Returns:**

* boolean – True if staff faction is active.

**Example Usage:**

```lua

-- Confirm the player is currently in a staff role

local result = player:isStaffOnDuty()

```
---

### isFaction

**Description:**

Checks if the player's character belongs to the given faction.

**Parameters:**

* `faction` (`number`) – Faction index to compare.

**Realm:**

* Shared

**Returns:**

* boolean – True if the factions match.

**Example Usage:**

```lua

-- Compare the player's faction to a requirement

local result = player:isFaction(faction)

```
---

### isClass

**Description:**

Returns true if the player's character is of the given class.

**Parameters:**

* `class` (`number`) – Class index to compare.

**Realm:**

* Shared

**Returns:**

* boolean – Whether the character matches the class.

**Example Usage:**

```lua

-- Determine if the player's class matches

local result = player:isClass(class)

```
---

### hasWhitelist

**Description:**

Determines if the player has whitelist access for a faction.

**Parameters:**

* `faction` (`number`) – Faction index.

**Realm:**

* Shared

**Returns:**

* boolean – True if whitelisted.

**Example Usage:**

```lua

-- Check for whitelist permission on a faction

local result = player:hasWhitelist(faction)

```
---

### getClass

**Description:**

Retrieves the class index of the player's character.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number|None – Class index or None.

**Example Usage:**

```lua

-- Retrieve the current class index

local result = player:getClass()

```
---

### hasClassWhitelist

**Description:**

Checks if the player's character is whitelisted for a class.

**Parameters:**

* `class` (`number`) – Class index.

**Realm:**

**Returns:**

* boolean – True if class whitelist exists.

**Example Usage:**

```lua

-- Verify the player is approved for a specific class

local result = player:hasClassWhitelist(class)

```
---

### getClassData

**Description:**

Returns the class table of the player's current class.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table|None – Class definition table.

**Example Usage:**

```lua

-- Access data table for the player's class

local result = player:getClassData()

```
---

### getDarkRPVar

**Description:**

Compatibility helper for retrieving money with DarkRP-style calls.

**Parameters:**

* `var` (`string`) – Currently only supports "money".

**Realm:**

* Shared

**Returns:**

* number|None – Money amount or None.

**Example Usage:**

```lua

-- Read money amount in a DarkRP-compatible way

local result = player:getDarkRPVar(var)

```
---

### getMoney

**Description:**

Convenience function to get the character's money amount.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Current funds or 0.

**Example Usage:**

```lua

-- Fetch the character's stored funds

local result = player:getMoney()

```
---

### canAfford

**Description:**

Checks if the player has enough money for a purchase.

**Parameters:**

* `amount` (`number`) – Cost to test.

**Realm:**

* Shared

**Returns:**

* boolean – True if funds are sufficient.

**Example Usage:**

```lua

-- Check if the player has enough money to buy something

local result = player:canAfford(amount)

```
---

### hasSkillLevel

**Description:**

Verifies the player's character meets an attribute level.

**Parameters:**

* `skill` (`string`) – Attribute ID.

* `level` (`number`) – Required level.

**Realm:**

* Shared

**Returns:**

* boolean – Whether the character satisfies the requirement.

**Example Usage:**

```lua

-- Ensure the player meets a single skill requirement

local result = player:hasSkillLevel(skill, level)

```
---

### meetsRequiredSkills

**Description:**

Checks a table of skill requirements against the player.

**Parameters:**

* `requiredSkillLevels` (`table`) – Mapping of attribute IDs to levels.

**Realm:**

* Shared

**Returns:**

* boolean – True if all requirements are met.

**Example Usage:**

```lua

-- Validate multiple skill requirements at once

local result = player:meetsRequiredSkills(requiredSkillLevels)

```
---

### forceSequence

**Description:**

Plays an animation sequence and optionally freezes the player.

**Parameters:**

* `sequenceName` (`string`) – Sequence to play.

* `callback` (`function|None`) – Called when finished.

* `time` (`number|None`) – Duration override.

* `noFreeze` (`boolean`) – Don't freeze movement when true.

**Realm:**

* Shared

**Returns:**

* number|boolean – Duration or false on failure.

**Example Usage:**

```lua

-- Play an animation while freezing the player

local result = player:forceSequence(sequenceName, callback, time, noFreeze)

```
---

### leaveSequence

**Description:**

Stops any forced sequence and restores player movement.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Stop the player's forced animation sequence

local result = player:leaveSequence()

```
---

### restoreStamina

**Description:**

Increases the player's stamina value.

**Parameters:**

* `amount` (`number`) – Amount to restore.

**Realm:**

* Server

* Returns:

* None – This function does not return a value.

**Example Usage:**

```lua

-- Give the player extra stamina points

local result = player:restoreStamina(amount)

```
---

### consumeStamina

**Description:**

Reduces the player's stamina value.

**Parameters:**

* `amount` (`number`) – Amount to subtract.

**Realm:**

* Server

* Returns:

* None – This function does not return a value.

**Example Usage:**

```lua

-- Spend stamina as the player performs an action

local result = player:consumeStamina(amount)

```
---

### addMoney

**Description:**

Adds funds to the player's character, clamping to limits.

**Parameters:**

* `amount` (`number`) – Money to add.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Reward the player and announce the payout

player:addMoney(100)

player:notifyLocalized("questReward", lia.currency.get(100))

```
---

### takeMoney

**Description:**

Removes money from the player's character.

**Parameters:**

* `amount` (`number`) – Amount to subtract.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Remove money from the player's character

local result = player:takeMoney(amount)

```
---

### WhitelistAllClasses

**Description:**

Grants whitelist access to every registered class.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Unlock every class for the player

player:WhitelistAllClasses()

```
---

### WhitelistAllFactions

**Description:**

Whitelists the player for all factions.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:WhitelistAllFactions()

```
---

### WhitelistEverything

**Description:**

Convenience method to whitelist all factions and classes.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

-- Give the player access to all content

player:WhitelistEverything()

```
---

### classWhitelist

**Description:**

Adds a single class to the character's whitelist table.

**Parameters:**

* `class` (`number`) – Class index to whitelist.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:classWhitelist(CLASS_MEDIC)

```
---

### classUnWhitelist

**Description:**

Removes a class from the character's whitelist table.

**Parameters:**

* `class` (`number`) – Class index to remove.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:classUnWhitelist(CLASS_MEDIC)

```
---

### setWhitelisted

**Description:**

Sets or clears whitelist permission for a faction.

**Parameters:**

* `faction` (`number`) – Faction index.

* `whitelisted` (`boolean|None`) – Enable when true, disable when false/nil.

**Realm:**

* Server

**Returns:**

* boolean – True if the faction exists.

**Example Usage:**

```lua

player:setWhitelisted(FACTION_POLICE, true)

```
---

### loadLiliaData

**Description:**

Loads persistent Lilia data for the player from the database.

**Parameters:**

* `callback` (`function|None`) – Invoked with the loaded table.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:loadLiliaData(function(data) print(data) end)

```
---

### saveLiliaData

**Description:**

Saves the player's Lilia data back to the database.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:saveLiliaData()

```
---

### setLiliaData

**Description:**

Stores a value in the player's persistent data table.

**Parameters:**

* `key` (`string`) – Data key.

* `value` (`any`) – Value to store.

* `noNetworking` (`boolean|None`) – Skip network update when true.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setLiliaData("settings", {foo = true})

```
---

### setWaypoint

**Description:**

Sends a waypoint to the client at the specified position.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – World position.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setWaypoint("Objective", Vector(0, 0, 0))

```
---

### setWeighPoint

**Description:**

Alias of `setWaypoint()` for backwards compatibility.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – World position.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setWeighPoint("Target", Vector(100, 100, 0))

```
---

### setWaypointWithLogo

**Description:**

Creates a waypoint using a custom logo material.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – World position.

* `logo` (`string`) – Material path for the icon.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setWaypointWithLogo("Objective", Vector(0,0,0), "path/to/icon.png")

```
---

### getLiliaData

**Description:**

Retrieves a stored value from the player's data table.

**Parameters:**

* `key` (`string`) – Data key.

* `default` (`any`) – Returned if the key is nil.

**Realm:**

* Server

**Returns:**

* any – Stored value or default.

**Example Usage:**

```lua

local settings = player:getLiliaData("settings", {})

```
---

### getAllLiliaData

**Description:**

Returns the entire table of persistent data for the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* table – Player data table.

**Example Usage:**

```lua

local data = player:getAllLiliaData()

```
---

### setRagdoll

**Description:**

Associates a ragdoll entity with the player for later retrieval.

**Parameters:**

* `entity` (`Entity`) – The ragdoll entity.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setRagdoll(ragdollEnt)

```
---

### NetworkAnimation

**Description:**

Broadcasts animation bone data to all clients.

**Parameters:**

* `active` (`boolean`) – Enable or disable manipulation.

* `boneData` (`table`) – Map of bone names to angles.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:NetworkAnimation(true, {

    ["ValveBiped.Bip01_Head"] = Angle(0, 90, 0)

})

```
---

### setAction

**Description:**

Displays an action bar for a set duration and optionally runs a callback.

**Parameters:**

* `text` (`string|None`) – Text to display, or nil to clear.

* `time` (`number|None`) – How long to show it for.

* `callback` (`function|None`) – Executed when time elapses.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setAction("Lockpicking", 5)

```
---

### doStaredAction

**Description:**

Runs an action only while the player stares at the entity.

**Parameters:**

* `entity` (`Entity`) – Target entity.

* `callback` (`function`) – Called when the timer finishes.

* `time` (`number`) – Duration in seconds.

* `onCancel` (`function|None`) – Called if gaze breaks.

* `distance` (`number|None`) – Max distance to maintain.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:doStaredAction(door, function() door:Open() end, 3)

```
---

### stopAction

**Description:**

Cancels any running action bar on the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:stopAction()

```
---

### requestDropdown

**Description:**

Prompts the client with a dropdown selection dialog.

**Parameters:**

* `title` (`string`) – Window title.

* `subTitle` (`string`) – Description text.

* `options` (`table`) – Table of options.

* `callback` (`function`) – Receives the chosen value.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:requestDropdown("Choose", "Pick one", {"A", "B"}, print)

```
---

### requestOptions

**Description:**

Asks the client to select one or more options from a list.

**Parameters:**

* `title` (`string`) – Window title.

* `subTitle` (`string`) – Description text.

* `options` (`table`) – Available options.

* `limit` (`number`) – Maximum selections allowed.

* `callback` (`function`) – Receives the chosen values.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:requestOptions("Permissions", "Select", {"A", "B"}, 2, print)

```
---

### requestString

**Description:**

Requests a string from the client.

**Parameters:**

* `title` (`string`) – Prompt title.

* `subTitle` (`string`) – Prompt description.

* `callback` (`function|None`) – Called with the string.

* `default` (`string|None`) – Default value.

**Realm:**

* Server

**Returns:**

* deferred|None – Deferred object when no callback supplied.

**Example Usage:**

```lua

player:requestString("Name", "Enter text", print)

```
---

### binaryQuestion

**Description:**

Displays a yes/no style question to the player.

**Parameters:**

* `question` (`string`) – Main text.

* `option1` (`string`) – Text for the first option.

* `option2` (`string`) – Text for the second option.

* `manualDismiss` (`boolean`) – Require manual closing.

* `callback` (`function`) – Called with chosen value.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:binaryQuestion("Proceed?", "Yes", "No", false, print)

```
---

### getPlayTime

**Description:**

Calculates how long the player has been on the server.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* number – Total seconds of playtime.

**Example Usage:**

```lua

print(player:getPlayTime())

```
---

### createRagdoll

**Description:**

Spawns a ragdoll copy of the player and optionally freezes it.

**Parameters:**

* `freeze` (`boolean|None`) – Disable physics when true.

* `isDead` (`boolean|None`) – Mark as a death ragdoll.

**Realm:**

* Server

**Returns:**

* Entity – The created ragdoll.

**Example Usage:**

```lua

local rag = player:createRagdoll(true)

```
---

### setRagdolled

**Description:**

Toggles the player's ragdoll state for a duration.

**Parameters:**

* `state` (`boolean`) – Enable or disable ragdoll.

* `time` (`number|None`) – Duration before standing up.

* `getUpGrace` (`number|None`) – Extra time to prevent early stand.

* `getUpMessage` (`string|None`) – Message while downed.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setRagdolled(true, 5)

```
---

### syncVars

**Description:**

Sends all networked variables to the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:syncVars()

```
---

### setLocalVar

**Description:**

Sets a networked local variable on the player.

Triggers the **LocalVarChanged** hook on both server and client.

**Parameters:**

* `key` (`string`) – Variable name.

* `value` (`any`) – Value to set.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:setLocalVar("health", 75)

```
---

### getPlayTime

**Description:**

Returns playtime calculated client side when called on a client.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* number – Seconds of playtime.

**Example Usage:**

```lua

print(LocalPlayer():getPlayTime())

```
---

### setWaypoint

**Description:**

Displays a waypoint on the HUD until the player reaches it.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – World position.

* `onReach` (`function|None`) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

LocalPlayer():setWaypoint("Home", Vector(0,0,0))

```
---

### setWeighPoint

**Description:**

Alias of the client version of `setWaypoint`.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – World position.

* `onReach` (`function|None`) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

LocalPlayer():setWeighPoint("Spot", Vector(10,10,0))

```
---

### setWaypointWithLogo

**Description:**

Places a waypoint using a logo material on the client HUD.

**Parameters:**

* `name` (`string`) – Display label.

* `vector` (`Vector`) – Position to navigate to.

* `logo` (`string`) – Material path for the icon.

* `onReach` (`function|None`) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

LocalPlayer():setWaypointWithLogo("Loot", Vector(1,1,1), "icon.png")

```
---

### getLiliaData

**Description:**

Client side accessor for stored player data.

**Parameters:**

* `key` (`string`) – Data key.

* `default` (`any`) – Fallback value.

**Realm:**

* Client

**Returns:**

* any – Stored value or default.

**Example Usage:**

```lua

local data = LocalPlayer():getLiliaData("settings")

```
---

### getAllLiliaData

**Description:**

Returns the entire local data table for the player.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* table – Local data table.

**Example Usage:**

```lua

local data = LocalPlayer():getAllLiliaData()

```
---

### NetworkAnimation

**Description:**

Applies or clears clientside bone angles based on animation data.

**Parameters:**

* `active` (`boolean`) – Enable or disable animation.

* `boneData` (`table`) – Bones and angles to apply.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

LocalPlayer():NetworkAnimation(true, {

    ["ValveBiped.Bip01_Head"] = Angle(0, 90, 0)

})

```
---
### getParts

**Description:**

Returns the table of PAC3 part IDs currently attached to the player.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table – Mapping of active part IDs.

**Example Usage:**

```lua

for id in pairs(player:getParts()) do

    print("equipped part", id)

end

```
---

### syncParts

**Description:**

Sends the player's PAC3 part data to their client.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:syncParts()

```
---

### addPart

**Description:**

Adds the given PAC3 part to the player and broadcasts it.

**Parameters:**

* `partID` (`string`) – Identifier of the part to attach.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:addPart("hat_01")

```
---

### removePart

**Description:**

Removes a previously added PAC3 part from the player.

**Parameters:**

* `partID` (`string`) – Identifier of the part to remove.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:removePart("hat_01")

```
---

### resetParts

**Description:**

Clears all PAC3 parts that are currently attached to the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:resetParts()

```
---

### LagCompensation

**Description:**

Wrapper that tracks when lag compensation is enabled on the player.

**Parameters:**

* `state` (`boolean`) – Whether to enable lag compensation.

**Realm:**

* Shared

**Returns:**

* None – This function does not return a value.

**Example Usage:**

```lua

player:LagCompensation(true)

-- perform trace logic here

player:LagCompensation(false)

```
---
