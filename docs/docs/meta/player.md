# Player Meta

Lilia extends Garry's Mod players with characters, inventories, and permission checks. This reference details the meta functions enabling that integration.

---

## Overview

Player meta functions provide quick access to the active character, networking helpers for messaging or data transfer, and utility checks such as admin status. Players are entity objects that hold at most one Character instance, so these helpers unify player-related logic across the framework.
---

### getChar()

**Description:**

Returns the currently loaded character object for this player.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Character|None – The player's active character.

**Example:**

```lua
-- Retrieve the character to modify inventory
local char = player:getChar()
```
---

### Name()

**Description:**

Returns either the character's roleplay name or the player's Steam name.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* string – Display name.

**Example:**

```lua
-- Print the roleplay name in chat
chat.AddText(player:Name())
```
---

### hasPrivilege(privilegeName)

**Description:**

Wrapper for CAMI privilege checks.

**Parameters:**

* privilegeName (string) – Privilege identifier.

**Realm:**

* Shared

**Returns:**

* boolean – Result from CAMI.PlayerHasAccess.

**Example:**

```lua
-- Deny access if the player lacks a privilege
if not player:hasPrivilege("Manage") then
    return false
end
```
---

### getCurrentVehicle()

**Description:**

Safely returns the vehicle the player is currently using.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Entity|None – Vehicle entity or None.

**Example:**

```lua
-- Attach a camera to the vehicle the player is in
local veh = player:getCurrentVehicle()
if IsValid(veh) then
    AttachCamera(veh)
end
```
---

### hasValidVehicle()

**Description:**

Determines if the player is currently inside a valid vehicle.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True if a vehicle entity is valid.

**Example:**

```lua
-- Allow honking only when in a valid vehicle
if player:hasValidVehicle() then
    player:GetVehicle():EmitSound("Horn")
end
```
---

### isNoClipping()

**Description:**

Returns true if the player is in noclip mode and not inside a vehicle.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Whether the player is noclipping.

**Example:**

```lua
-- Disable certain actions while noclipping
if player:isNoClipping() then return end
```
---

### hasRagdoll()

**Description:**

Checks if the player currently has an active ragdoll entity.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True when a ragdoll entity exists.

**Example:**

```lua
if player:hasRagdoll() then
    print("Player is ragdolled")
end
```
---

### removeRagdoll()

**Description:**

Safely removes the player's ragdoll entity if present.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Clean up any ragdoll left behind
player:removeRagdoll()
```
---

### getRagdoll()

**Description:**

Retrieves the ragdoll entity associated with the player.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Entity|None – The ragdoll entity or None.

**Example:**

```lua
local ragdoll = player:getRagdoll()
```
---

### isStuck()

**Description:**

Determines whether the player's position is stuck in the world.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True if the trace detects a stuck state.

**Example:**

```lua
if player:isStuck() then
    player:SetPos(player:GetPos() + Vector(0, 0, 16))
end
```
---

### isNearPlayer(radius, entity)

**Description:**

Checks if an entity is within the given radius of the player.

**Parameters:**

* radius (number) – Distance in units.
* entity (Entity) – Entity to compare.

**Realm:**

* Shared

**Returns:**

* boolean – True if the entity is close enough.

**Example:**

```lua
if player:isNearPlayer(128, target) then
    print("Target is nearby")
end
```
---

### entitiesNearPlayer(radius, playerOnly)

**Description:**

Returns a table of entities within radius of the player.

**Parameters:**

* radius (number) – Search distance in units.
* playerOnly (boolean|None) – Only include players when true.

**Realm:**

* Shared

**Returns:**

* table – List of nearby entities.

**Example:**

```lua
for _, ent in ipairs(player:entitiesNearPlayer(256)) do
    print(ent)
end
```
---

### getItemWeapon()

**Description:**

Returns the active weapon entity and associated item if equipped.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Entity|None – Weapon entity when matched.

**Example:**

```lua
local weapon, item = player:getItemWeapon()
```
---

### isRunning()

**Description:**

Checks whether the player is moving faster than walking speed.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True if the player is running.

**Example:**

```lua
if player:isRunning() then
    -- player is sprinting
end
```
---

### isFemale()

**Description:**

Returns true if the player's model is considered female.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Whether a female model is detected.

**Example:**

```lua
if player:isFemale() then
    print("Female model detected")
end
```
---

### getItemDropPos()

**Description:**

Finds a safe position in front of the player to drop items.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* Vector – World position for dropping items.

**Example:**

```lua
local pos = player:getItemDropPos()
```
---

### getItems()

**Description:**

Returns the player's inventory item list if a character is loaded.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table|None – Table of items or None if absent.

**Example:**

```lua
-- Iterate player's items to calculate total weight
for _, it in pairs(player:getItems() or {}) do
    total = total + it.weight
end
```
---

### getTracedEntity(distance)

**Description:**

Performs a simple trace from the player's shoot position.

**Parameters:**

* distance (number) – Trace length in units.

**Realm:**

* Shared

**Returns:**

* Entity|None – The entity hit or None.

**Example:**

```lua
-- Grab the entity the player is pointing at
local entity = player:getTracedEntity(96)
```
---

### getTrace(distance)

**Description:**

Returns a hull trace in front of the player.

**Parameters:**

* distance (number) – Hull length in units.

**Realm:**

* Shared

**Returns:**

* table – Trace result.

**Example:**

```lua
-- Use a hull trace for melee attacks
local tr = player:getTrace(48)
```
---

### getEyeEnt(distance)

**Description:**

Returns the entity the player is looking at within a distance.

**Parameters:**

* distance (number) – Maximum distance.

**Realm:**

* Shared

**Returns:**

* Entity|None – The entity or None if too far.

**Example:**

```lua
-- Show the name of the object being looked at
local target = player:getEyeEnt(128)
if IsValid(target) then
    player:ChatPrint(target:GetClass())
end
```
---

### notify(message)

**Description:**

Sends a plain notification message to the player.

**Parameters:**

* message (string) – Text to display.

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Send a welcome notification and log the join event
player:notify("Welcome to the server!")
file.Append("welcome.txt", player:SteamID() .. " joined\n")
```
---

### notifyLocalized(message, ...)

**Description:**

Sends a localized notification to the player.

**Parameters:**

* message (string) – Translation key.
* ... – Additional parameters for localization.

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Send a localized message including the player's name and score
local score = player:GetFrags()
player:notifyLocalized("greeting_key", player:Name(), score)
```
---

### CanEditVendor(vendor)

**Description:**

Determines whether the player can edit the given vendor.

**Parameters:**

* vendor (Entity) – Vendor entity to check.

**Realm:**

* Server

**Returns:**

* boolean – True if allowed to edit.

**Example:**

```lua
-- Determine if the player may modify the vendor
local result = player:CanEditVendor(vendor)
```
---

### isUser()

**Description:**

Convenience wrapper to check if the player is in the "user" group.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Whether usergroup is "user".

**Example:**

```lua
-- Check if the player belongs to the default user group
local result = player:isUser()
```
---

### isStaff()

**Description:**

Returns true if the player belongs to a staff group.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Result from the privilege check.

**Example:**

```lua
-- Verify staff permissions for administrative actions
local result = player:isStaff()
```
---

### isVIP()

**Description:**

Checks whether the player is in the VIP group.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – Result from privilege check.

**Example:**

```lua
-- Test if the player has VIP status
local result = player:isVIP()
```
---

### isStaffOnDuty()

**Description:**

Determines if the player is currently in the staff faction.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* boolean – True if staff faction is active.

**Example:**

```lua
-- Confirm the player is currently in a staff role
local result = player:isStaffOnDuty()
```
---

### isFaction(faction)

**Description:**

Checks if the player's character belongs to the given faction.

**Parameters:**

* faction (number) – Faction index to compare.

**Realm:**

* Shared

**Returns:**

* boolean – True if the factions match.

**Example:**

```lua
-- Compare the player's faction to a requirement
local result = player:isFaction(faction)
```
---

### isClass(class)

**Description:**

Returns true if the player's character is of the given class.

**Parameters:**

* class (number) – Class index to compare.

**Realm:**

* Shared

**Returns:**

* boolean – Whether the character matches the class.

**Example:**

```lua
-- Determine if the player's class matches
local result = player:isClass(class)
```
---

### hasWhitelist(faction)

**Description:**

Determines if the player has whitelist access for a faction.

**Parameters:**

* faction (number) – Faction index.

**Realm:**

* Shared

**Returns:**

* boolean – True if whitelisted.

**Example:**

```lua
-- Check for whitelist permission on a faction
local result = player:hasWhitelist(faction)
```
---

### getClass()

**Description:**

Retrieves the class index of the player's character.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number|None – Class index or None.

**Example:**

```lua
-- Retrieve the current class index
local result = player:getClass()
```
---

### hasClassWhitelist(class)

**Description:**

Checks if the player's character is whitelisted for a class.

**Parameters:**

* class (number) – Class index.

**Realm:**

* Shared

**Returns:**

* boolean – True if class whitelist exists.

**Example:**

```lua
-- Verify the player is approved for a specific class
local result = player:hasClassWhitelist(class)
```
---

### getClassData()

**Description:**

Returns the class table of the player's current class.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* table|None – Class definition table.

**Example:**

```lua
-- Access data table for the player's class
local result = player:getClassData()
```
---

### getDarkRPVar(var)

**Description:**

Compatibility helper for retrieving money with DarkRP-style calls.

**Parameters:**

* var (string) – Currently only supports "money".

**Realm:**

* Shared

**Returns:**

* number|None – Money amount or None.

**Example:**

```lua
-- Read money amount in a DarkRP-compatible way
local result = player:getDarkRPVar(var)
```
---

### getMoney()

**Description:**

Convenience function to get the character's money amount.

**Parameters:**

* None

**Realm:**

* Shared

**Returns:**

* number – Current funds or 0.

**Example:**

```lua
-- Fetch the character's stored funds
local result = player:getMoney()
```
---

### canAfford(amount)

**Description:**

Checks if the player has enough money for a purchase.

**Parameters:**

* amount (number) – Cost to test.

**Realm:**

* Shared

**Returns:**

* boolean – True if funds are sufficient.

**Example:**

```lua
-- Check if the player has enough money to buy something
local result = player:canAfford(amount)
```
---

### hasSkillLevel(skill, level)

**Description:**

Verifies the player's character meets an attribute level.

**Parameters:**

* skill (string) – Attribute ID.
* level (number) – Required level.

**Realm:**

* Shared

**Returns:**

* boolean – Whether the character satisfies the requirement.

**Example:**

```lua
-- Ensure the player meets a single skill requirement
local result = player:hasSkillLevel(skill, level)
```
---

### meetsRequiredSkills(requiredSkillLevels)

**Description:**

Checks a table of skill requirements against the player.

**Parameters:**

* requiredSkillLevels (table) – Mapping of attribute IDs to levels.

**Realm:**

* Shared

**Returns:**

* boolean – True if all requirements are met.

**Example:**

```lua
-- Validate multiple skill requirements at once
local result = player:meetsRequiredSkills(requiredSkillLevels)
```
---

### forceSequence(sequenceName, callback, time, noFreeze)

**Description:**

Plays an animation sequence and optionally freezes the player.

**Parameters:**

* sequenceName (string) – Sequence to play.
* callback (function|None) – Called when finished.
* time (number|None) – Duration override.
* noFreeze (boolean) – Don't freeze movement when true.

**Realm:**

* Shared

**Returns:**

* number|boolean – Duration or false on failure.

**Example:**

```lua
-- Play an animation while freezing the player
local result = player:forceSequence(sequenceName, callback, time, noFreeze)
```
---

### leaveSequence()

**Description:**

Stops any forced sequence and restores player movement.

**Parameters:**

* None

**Realm:**

* Shared
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Stop the player's forced animation sequence
local result = player:leaveSequence()
```
---

### restoreStamina(amount)

**Description:**

Increases the player's stamina value.

**Parameters:**

* amount (number) – Amount to restore.

**Realm:**

* Server
* Returns:
* None – This function does not return a value.

**Example:**

```lua
-- Give the player extra stamina points
local result = player:restoreStamina(amount)
```
---

### consumeStamina(amount)

**Description:**

Reduces the player's stamina value.

**Parameters:**

* amount (number) – Amount to subtract.

**Realm:**

* Server
* Returns:
* None – This function does not return a value.

**Example:**

```lua
-- Spend stamina as the player performs an action
local result = player:consumeStamina(amount)
```
---

### addMoney(amount)

**Description:**

Adds funds to the player's character, clamping to limits.

**Parameters:**

* amount (number) – Money to add.

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Reward the player and announce the payout
player:addMoney(100)
player:notify("You received $100 for completing the quest.")
```
---

### takeMoney(amount)

**Description:**

Removes money from the player's character.

**Parameters:**

* amount (number) – Amount to subtract.

**Realm:**

* Server
**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Remove money from the player's character
local result = player:takeMoney(amount)
```
---

### WhitelistAllClasses()

**Description:**

Grants whitelist access to every registered class.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Unlock every class for the player
player:WhitelistAllClasses()
```
---

### WhitelistAllFactions()

**Description:**

Whitelists the player for all factions.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:WhitelistAllFactions()
```
---

### WhitelistEverything()

**Description:**

Convenience method to whitelist all factions and classes.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
-- Give the player access to all content
player:WhitelistEverything()
```
---

### classWhitelist(class)

**Description:**

Adds a single class to the character's whitelist table.

**Parameters:**

* class (number) – Class index to whitelist.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:classWhitelist(CLASS_MEDIC)
```
---

### classUnWhitelist(class)

**Description:**

Removes a class from the character's whitelist table.

**Parameters:**

* class (number) – Class index to remove.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:classUnWhitelist(CLASS_MEDIC)
```
---

### setWhitelisted(faction, whitelisted)

**Description:**

Sets or clears whitelist permission for a faction.

**Parameters:**

* faction (number) – Faction index.
* whitelisted (boolean|None) – Enable when true, disable when false/nil.

**Realm:**

* Server

**Returns:**

* boolean – True if the faction exists.

**Example:**

```lua
player:setWhitelisted(FACTION_POLICE, true)
```
---

### loadLiliaData(callback)

**Description:**

Loads persistent Lilia data for the player from the database.

**Parameters:**

* callback (function|None) – Invoked with the loaded table.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:loadLiliaData(function(data) print(data) end)
```
---

### saveLiliaData()

**Description:**

Saves the player's Lilia data back to the database.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:saveLiliaData()
```
---

### setLiliaData(key, value, noNetworking)

**Description:**

Stores a value in the player's persistent data table.

**Parameters:**

* key (string) – Data key.
* value (any) – Value to store.
* noNetworking (boolean|None) – Skip network update when true.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setLiliaData("settings", {foo = true})
```
---

### setWaypoint(name, vector)

**Description:**

Sends a waypoint to the client at the specified position.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – World position.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setWaypoint("Objective", Vector(0, 0, 0))
```
---

### setWeighPoint(name, vector)

**Description:**

Alias of `setWaypoint()` for backwards compatibility.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – World position.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setWeighPoint("Target", Vector(100, 100, 0))
```
---

### setWaypointWithLogo(name, vector, logo)

**Description:**

Creates a waypoint using a custom logo material.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – World position.
* logo (string) – Material path for the icon.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setWaypointWithLogo("Objective", Vector(0,0,0), "path/to/icon.png")
```
---

### getLiliaData(key, default)

**Description:**

Retrieves a stored value from the player's data table.

**Parameters:**

* key (string) – Data key.
* default (any) – Returned if the key is nil.

**Realm:**

* Server

**Returns:**

* any – Stored value or default.

**Example:**

```lua
local settings = player:getLiliaData("settings", {})
```
---

### getAllLiliaData()

**Description:**

Returns the entire table of persistent data for the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* table – Player data table.

**Example:**

```lua
local data = player:getAllLiliaData()
```
---

### setRagdoll(entity)

**Description:**

Associates a ragdoll entity with the player for later retrieval.

**Parameters:**

* entity (Entity) – The ragdoll entity.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setRagdoll(ragdollEnt)
```
---

### NetworkAnimation(active, boneData)

**Description:**

Broadcasts animation bone data to all clients.

**Parameters:**

* active (boolean) – Enable or disable manipulation.
* boneData (table) – Map of bone names to angles.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:NetworkAnimation(true, data)
```
---

### setAction(text, time, callback)

**Description:**

Displays an action bar for a set duration and optionally runs a callback.

**Parameters:**

* text (string|None) – Text to display, or nil to clear.
* time (number|None) – How long to show it for.
* callback (function|None) – Executed when time elapses.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setAction("Lockpicking", 5)
```
---

### doStaredAction(entity, callback, time, onCancel, distance)

**Description:**

Runs an action only while the player stares at the entity.

**Parameters:**

* entity (Entity) – Target entity.
* callback (function) – Called when the timer finishes.
* time (number) – Duration in seconds.
* onCancel (function|None) – Called if gaze breaks.
* distance (number|None) – Max distance to maintain.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:doStaredAction(door, function() door:Open() end, 3)
```
---

### stopAction()

**Description:**

Cancels any running action bar on the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:stopAction()
```
---

### requestDropdown(title, subTitle, options, callback)

**Description:**

Prompts the client with a dropdown selection dialog.

**Parameters:**

* title (string) – Window title.
* subTitle (string) – Description text.
* options (table) – Table of options.
* callback (function) – Receives the chosen value.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:requestDropdown("Choose", "Pick one", {"A", "B"}, print)
```
---

### requestOptions(title, subTitle, options, limit, callback)

**Description:**

Asks the client to select one or more options from a list.

**Parameters:**

* title (string) – Window title.
* subTitle (string) – Description text.
* options (table) – Available options.
* limit (number) – Maximum selections allowed.
* callback (function) – Receives the chosen values.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:requestOptions("Permissions", "Select", {"A", "B"}, 2, print)
```
---

### requestString(title, subTitle, callback, default)

**Description:**

Requests a string from the client.

**Parameters:**

* title (string) – Prompt title.
* subTitle (string) – Prompt description.
* callback (function|None) – Called with the string.
* default (string|None) – Default value.

**Realm:**

* Server

**Returns:**

* deferred|None – Deferred object when no callback supplied.

**Example:**

```lua
player:requestString("Name", "Enter text", print)
```
---

### binaryQuestion(question, option1, option2, manualDismiss, callback)

**Description:**

Displays a yes/no style question to the player.

**Parameters:**

* question (string) – Main text.
* option1 (string) – Text for the first option.
* option2 (string) – Text for the second option.
* manualDismiss (boolean) – Require manual closing.
* callback (function) – Called with chosen value.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:binaryQuestion("Proceed?", "Yes", "No", false, print)
```
---

### getPlayTime()

**Description:**

Calculates how long the player has been on the server.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* number – Total seconds of playtime.

**Example:**

```lua
print(player:getPlayTime())
```
---

### createRagdoll(freeze, isDead)

**Description:**

Spawns a ragdoll copy of the player and optionally freezes it.

**Parameters:**

* freeze (boolean|None) – Disable physics when true.
* isDead (boolean|None) – Mark as a death ragdoll.

**Realm:**

* Server

**Returns:**

* Entity – The created ragdoll.

**Example:**

```lua
local rag = player:createRagdoll(true)
```
---

### setRagdolled(state, time, getUpGrace, getUpMessage)

**Description:**

Toggles the player's ragdoll state for a duration.

**Parameters:**

* state (boolean) – Enable or disable ragdoll.
* time (number|None) – Duration before standing up.
* getUpGrace (number|None) – Extra time to prevent early stand.
* getUpMessage (string|None) – Message while downed.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setRagdolled(true, 5)
```
---

### syncVars()

**Description:**

Sends all networked variables to the player.

**Parameters:**

* None

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:syncVars()
```
---

### setLocalVar(key, value)

**Description:**

Sets a networked local variable on the player.

**Parameters:**

* key (string) – Variable name.
* value (any) – Value to set.

**Realm:**

* Server

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
player:setLocalVar("health", 75)
```
---

### getPlayTime()

**Description:**

Returns playtime calculated client side when called on a client.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* number – Seconds of playtime.

**Example:**

```lua
print(LocalPlayer():getPlayTime())
```
---

### setWaypoint(name, vector, onReach)

**Description:**

Displays a waypoint on the HUD until the player reaches it.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – World position.
* onReach (function|None) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
LocalPlayer():setWaypoint("Home", Vector(0,0,0))
```
---

### setWeighPoint(name, vector, onReach)

**Description:**

Alias of the client version of `setWaypoint`.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – World position.
* onReach (function|None) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
LocalPlayer():setWeighPoint("Spot", Vector(10,10,0))
```
---

### setWaypointWithLogo(name, vector, logo, onReach)

**Description:**

Places a waypoint using a logo material on the client HUD.

**Parameters:**

* name (string) – Display label.
* vector (Vector) – Position to navigate to.
* logo (string) – Material path for the icon.
* onReach (function|None) – Called when reached.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
LocalPlayer():setWaypointWithLogo("Loot", Vector(1,1,1), "icon.png")
```
---

### getLiliaData(key, default)

**Description:**

Client side accessor for stored player data.

**Parameters:**

* key (string) – Data key.
* default (any) – Fallback value.

**Realm:**

* Client

**Returns:**

* any – Stored value or default.

**Example:**

```lua
local data = LocalPlayer():getLiliaData("settings")
```
---

### getAllLiliaData()

**Description:**

Returns the entire local data table for the player.

**Parameters:**

* None

**Realm:**

* Client

**Returns:**

* table – Local data table.

**Example:**

```lua
local data = LocalPlayer():getAllLiliaData()
```
---

### NetworkAnimation(active, boneData)

**Description:**

Applies or clears clientside bone angles based on animation data.

**Parameters:**

* active (boolean) – Enable or disable animation.
* boneData (table) – Bones and angles to apply.

**Realm:**

* Client

**Returns:**

* None – This function does not return a value.

**Example:**

```lua
LocalPlayer():NetworkAnimation(true, data)
```
---
