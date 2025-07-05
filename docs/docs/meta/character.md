# Character Meta

Character objects returned by `player:getChar()` persist inventory, stats, and money. This reference outlines helper functions for managing those records.

---

## Overview

The character meta library contains information about a player's current game state. It provides shortcuts for fetching stored values, verifying permissions, and linking a character back to its player. Characters are separate from players and hold names, models, money, and other data that persists across sessions.

### tostring

**Description:**

Returns a printable identifier for this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* string – Format "character[id]".


**Example Usage:**

```lua
-- Print a readable identifier when saving debug logs
print("Active char: " .. char:tostring())
```

---


### eq

**Description:**

Compares this character's ID with another object's ID. The argument can be a

`Character` instance or any object providing a `getID` method.

**Parameters:**

* `other` (`Character`) – Character or object to compare.


**Realm:**

* Shared


**Returns:**

* boolean – True if both share the same ID.


**Example Usage:**

```lua
-- Unlock the door only for its controlling character
local owner = door:getNetVar("ownChar")
if owner and char:eq(owner) then
    door:Fire("unlock", "", 0)
end
```

---

### getID

**Description:**

Returns the unique database ID for this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* number – Character identifier.


**Example Usage:**

```lua
-- Store the character ID for later reference
local id = char:getID()
session.lastCharID = id
```

---

### getPlayer

**Description:**

Returns the player entity currently controlling this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* Player|None – Owning player or None.


**Example Usage:**

```lua
-- Notify the controlling player that the character loaded
local ply = char:getPlayer()
if IsValid(ply) then
    ply:ChatPrint(L("charReady"))
end
```

---

### getDisplayedName

**Description:**

Returns the character's name as it should be shown to the given player.

**Parameters:**

* `client` (`Player`) – Player requesting the name.


**Realm:**

* Shared


**Returns:**

* string – Localized or recognized character name.


**Example Usage:**

```lua
-- Announce the character's name to a viewer
client:ChatPrint(string.format(L("youSee"), char:getDisplayedName(client)))
```

---

### hasMoney

**Description:**

Checks if the character has at least the given amount of money.

**Parameters:**

* `amount` (`number`) – Amount to check for.


**Realm:**

* Shared


**Returns:**

* boolean – True if the character's funds are sufficient.


**Example Usage:**

```lua
-- Verify the character can pay for an item before buying
if char:hasMoney(item.price) then
    char:takeMoney(item.price)
end
```

---

### getFlags

**Description:**

Retrieves the string of permission flags for this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* string – Concatenated flag characters.


**Example Usage:**

```lua
-- Look for the admin flag on this character
if char:getFlags():find("A") then
    print("Admin privileges detected")
end
```

---

### hasFlags

**Description:**

Checks if the character possesses any of the specified flags.

**Parameters:**

* `flags` (`string`) – String of flag characters to check.


**Realm:**

* Shared


**Returns:**

* boolean – True if at least one flag is present.


**Example Usage:**

```lua
-- Allow special command if any required flag is present
if char:hasFlags("abc") then
    performSpecialAction()
end
```

---

### getItemWeapon

**Description:**

Returns **true** only when the player's active weapon matches an item in their

inventory and that item is equipped. The argument defaults to `true` and the

method currently only checks for equipped items.

**Parameters:**

* `requireEquip` (`boolean`) – Only match equipped items if true.


**Realm:**

* Shared


**Returns:**

* boolean – True if the active weapon corresponds to an item.


**Example Usage:**

```lua
-- Check if we're using an inventory weapon
if char:getItemWeapon(true) then
    print("Item weapon equipped")
end
```

---

### getMaxStamina

**Description:**

Returns the maximum stamina value for this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* number – Maximum stamina points.


**Example Usage:**

```lua
-- Calculate the proportion of stamina remaining
local pct = char:getStamina() / char:getMaxStamina()
```

---

### getStamina

**Description:**

Retrieves the character's current stamina value.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* number – Current stamina.


**Example Usage:**

```lua
-- Display current stamina in the HUD
local stamina = char:getStamina()
drawStaminaBar(stamina)
```

---

### hasClassWhitelist

**Description:**

Checks if the character has whitelisted the given class.

**Parameters:**

* `class` (`number`) – Class index.


**Realm:**

* Shared


**Returns:**

* boolean – True if the class is whitelisted.


**Example Usage:**

```lua
-- Decide if the player may choose the medic class
if char:hasClassWhitelist(CLASS_MEDIC) then
    print("You may become a medic")
end
```

---

### isFaction

**Description:**

Returns true if the character's faction matches.

**Parameters:**

* `faction` (`number`) – Faction index.


**Realm:**

* Shared


**Returns:**

* boolean – Whether the faction matches.


**Example Usage:**

```lua
-- Restrict access to citizens only
if char:isFaction(FACTION_CITIZEN) then
    door:keysOwn(char:getPlayer())
end
```

---

### isClass

**Description:**

Returns true if the character's class equals the specified class.

**Parameters:**

* `class` (`number`) – Class index.


**Realm:**

* Shared


**Returns:**

* boolean – Whether the classes match.


**Example Usage:**

```lua
-- Provide a bonus if the character is currently an engineer
if char:isClass(CLASS_ENGINEER) then
    char:restoreStamina(10)
end
```

---

### getAttrib

**Description:**

Retrieves the value of an attribute including boosts.

**Parameters:**

* `key` (`string`) – Attribute identifier.


* `default` (`number`) – Default value when attribute is missing.


**Realm:**

* Shared


**Returns:**

* number – Final attribute value.


**Example Usage:**

```lua
-- Calculate damage using the strength attribute
local strength = char:getAttrib("str", 0)
dmg = baseDamage + strength * 0.5
```

---

### getBoost

**Description:**

Returns the boost table for the given attribute.

**Parameters:**

* `attribID` (`string`) – Attribute identifier.


**Realm:**

* Shared


**Returns:**

* table|None – Table of boosts or None.


**Example Usage:**

```lua
-- Inspect active boosts on agility
PrintTable(char:getBoost("agi"))
```

---

### getBoosts

**Description:**

Retrieves all attribute boosts for this character.

**Parameters:**

* None


**Realm:**

* Shared


**Returns:**

* table – Mapping of attribute IDs to boost tables.


**Example Usage:**

```lua
-- Print all attribute boosts for debugging
for id, data in pairs(char:getBoosts()) do
    print(id, data)
end
```

---

### doesRecognize

**Description:**

Determines if this character recognizes another character.

**Parameters:**

* `id` (`number|Character`) – Character ID or object to check.


**Realm:**

* Shared


**Returns:**

* boolean – True if recognized.


**Example Usage:**

```lua
-- Reveal names in chat only if recognized
if char:doesRecognize(targetChar) then
    print("Known: " .. targetChar:getName())
end
```

---

### doesFakeRecognize

**Description:**

Checks if the character has a fake recognition entry for another.

**Parameters:**

* `id` (`number|Character`) – Character identifier.


**Realm:**

* Shared


**Returns:**

* boolean – True if fake recognized.


**Example Usage:**

```lua
-- See if recognition was forced by a disguise item
if char:doesFakeRecognize(targetChar) then
    print("Recognition is fake")
end
```

---

### recognize

**Description:**

Adds another character to this one's recognition list. When a custom `name` is

provided that alias will be shown whenever the character is recognized.

**Parameters:**

* `character` (`number|Character`) – Character to recognize or its ID.


* `name` (`string|nil`) – Optional fake name to store.


**Realm:**

* Server


**Returns:**

* boolean – Always true once processed.


**Example Usage:**

```lua
-- Remember the rival using a codename and by ID
char:recognize(rivalChar:getID(), "Mysterious Stranger")
```

---

### WhitelistAllClasses

**Description:**

Grants class whitelist access for every class defined by the schema.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Allow this character to choose any class
char:WhitelistAllClasses()
```

---

### WhitelistAllFactions

**Description:**

Marks the character as whitelisted for every faction.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Grant access to all factions for testing
char:WhitelistAllFactions()
```

---

### WhitelistEverything

**Description:**

Convenience wrapper that whitelists the character for all factions and classes.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Unlock every faction and class
char:WhitelistEverything()
```

---

### classWhitelist

**Description:**

Adds the specified class to this character's whitelist.

**Parameters:**

* `class` (`number`) – Class index to whitelist.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Permit switching to the engineer class
char:classWhitelist(CLASS_ENGINEER)
```

---

### classUnWhitelist

**Description:**

Removes the specified class from the character's whitelist.

**Parameters:**

* `class` (`number`) – Class index to remove.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Revoke access to the medic class
char:classUnWhitelist(CLASS_MEDIC)
```

---

### joinClass

**Description:**

Attempts to set the character's current class. When `isForced` is true the normal eligibility checks are skipped.

**Parameters:**

* `class` (`number`) – Class index to join.


* `isForced` (`boolean`) – Bypass restrictions when true.


**Realm:**

* Server


**Returns:**

* boolean – True on success, false otherwise.


**Example Usage:**

```lua
-- Force the character into the soldier class
char:joinClass(CLASS_SOLDIER, true)
```

---

### kickClass

**Description:**

Removes the character from their current class, reverting to the default for their faction.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Reset the character's class after leaving the group
char:kickClass()
```

---

### updateAttrib

**Description:**

Increases an attribute by the specified value, clamped to the maximum allowed.

**Parameters:**

* `key` (`string`) – Attribute identifier.


* `value` (`number`) – Amount to add.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Award experience toward agility
char:updateAttrib("agi", 5)
```

---

### setAttrib

**Description:**

Directly sets an attribute to the given value.

**Parameters:**

* `key` (`string`) – Attribute identifier.


* `value` (`number`) – New level for the attribute.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Reset strength after an event
char:setAttrib("str", 10)
```

---

### addBoost

**Description:**

Applies a temporary boost to one of the character's attributes.

**Parameters:**

* `boostID` (`string`) – Unique identifier for the boost.


* `attribID` (`string`) – Attribute to modify.


* `boostAmount` (`number`) – Amount of the boost.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Grant a strength bonus while an item is equipped
char:addBoost("powerGloves", "str", 2)
```

---

### removeBoost

**Description:**

Removes a previously applied attribute boost.

**Parameters:**

* `boostID` (`string`) – Identifier used when the boost was added.


* `attribID` (`string`) – Attribute affected by the boost.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Clear the item bonus when unequipped
char:removeBoost("powerGloves", "str")
```

---

### setFlags

**Description:**

Replaces the character's flag string with the provided value.

**Parameters:**

* `flags` (`string`) – New flag characters to assign.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Reset all flags before assigning new ones
char:setFlags("")
```

---

### giveFlags

**Description:**

Adds the specified flag characters to the character.

**Parameters:**

* `flags` (`string`) – Flags to grant.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Grant temporary admin powers
char:giveFlags("A")
```

---

### takeFlags

**Description:**

Removes the given flag characters from the character.

**Parameters:**

* `flags` (`string`) – Flags to revoke.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Strip special permissions when demoted
char:takeFlags("A")
```

---

### save

**Description:**

Persists the character's current data to the database.

**Parameters:**

* `callback` (`function|nil`) – Optional function run after saving completes.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Save and then notify when finished
char:save(function() print("character saved") end)
```

---

### sync

**Description:**

Sends the character's networkable variables to a specific player. Passing

`nil` broadcasts the data to everyone. When the receiver is the character's own

player, only local variables intended for them are included.

**Parameters:**

* `receiver` (`Player|nil`) – Player to receive the data or nil for broadcast.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Send updates only to one player
char:sync(targetPlayer)
```

---

### setup

**Description:**

Sets up the player entity to use this character's model, faction, and inventory

data. Use `noNetworking` to skip network updates during initialization.

**Parameters:**

* `noNetworking` (`boolean`) – Skip networking inventories and vars when true.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Fully prepare the character after selection
char:setup()
```

---

### kick

**Description:**

Forcibly disconnects the player from their character. The player is killed

silently and immediately respawns with no character loaded.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Eject the player from their character
char:kick() -- they will respawn without a character
```

---

### ban

**Description:**

Marks the character as banned for the given duration, saves the state, and

immediately kicks the controlling player. This also triggers the

`OnCharPermakilled` hook.

**Parameters:**

* `time` (`number|nil`) – Ban length in seconds or nil for permanent.


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Ban the character for one hour
char:ban(3600)
```

---


### delete

**Description:**

Completely removes the character from the database along with any inventories

it owns.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Permanently remove this character
char:delete()
```

---

### destroy

**Description:**

Removes the character from the server's loaded cache without touching any saved

data. Useful after deleting a character or when cleaning up disconnected

players.

**Parameters:**

* None


**Realm:**

* Server


**Returns:**

* None – This function does not return a value.


**Example Usage:**

```lua
-- Clean up a removed character instance
char:destroy()
```

---

### giveMoney

**Description:**

Adds the specified amount to the character's wallet by calling the owning

player's `addMoney` method.

**Parameters:**

* `amount` (`number`) – Amount to add to the wallet.


**Realm:**

* Server


**Returns:**

* boolean – False if the owner is missing, otherwise true.


**Example Usage:**

```lua
-- Pay the character for completing a mission
local reward = 250
char:giveMoney(reward)
```

---

### takeMoney

**Description:**

Subtracts the specified amount of money from the character. Internally this

calls `giveMoney` with a negative value and logs the deduction.

**Parameters:**

* `amount` (`number`) – Amount to remove.


**Realm:**

* Server


**Returns:**

* boolean – Always true when the deduction occurs.


**Example Usage:**

```lua
-- Deduct a fine from the character
local fine = 50
char:takeMoney(fine)
```

---

### getName

**Description:**

Returns the character's stored name or a default value.

**Parameters:**

* `default` (`any`) – Value to return if the name is unset.


**Realm:**

* Shared


**Returns:**

* string – Character name or the provided default.


**Example Usage:**

```lua
print("Character name:", char:getName("Unknown"))
```

---

### setName

**Description:**

Updates the character's name and replicates the change to players.

**Parameters:**

* `value` (`string`) – New name for the character.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setName("Alyx Vance")
```

---

### getDesc

**Description:**

Fetches the character's description text or returns the given default.

**Parameters:**

* `default` (`any`) – Value to return if no description exists.


**Realm:**

* Shared


**Returns:**

* string – Description or fallback value.


**Example Usage:**

```lua
local about = char:getDesc("No bio")
```

---

### setDesc

**Description:**

Assigns a new description for the character.

**Parameters:**

* `value` (`string`) – Description text.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setDesc("Hardened wasteland survivor")
```

---

### getModel

**Description:**

Retrieves the model path assigned to the character.

**Parameters:**

* `default` (`any`) – Value returned when no model is stored.


**Realm:**

* Shared


**Returns:**

* string – Model path or the fallback value.


**Example Usage:**

```lua
local mdl = char:getModel("models/error.mdl")
```

---

### setModel

**Description:**

Sets the character's player model and broadcasts the update.

**Parameters:**

* `value` (`string`) – Model file path.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setModel("models/alyx.mdl")
```

---

### getClass

**Description:**

Returns the class index currently assigned or the supplied default.

**Parameters:**

* `default` (`any`) – Value used when the class is unset.


**Realm:**

* Shared


**Returns:**

* number – Class index.


**Example Usage:**

```lua
if char:getClass() == CLASS_ENGINEER then
    print("Engineer present")
end
```

---

### setClass

**Description:**

Stores a new class index for the character.

**Parameters:**

* `value` (`number`) – Class identifier.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setClass(CLASS_ENGINEER)
```

---

### getFaction

**Description:**

Gets the faction index of the character or a fallback value.

**Parameters:**

* `default` (`any`) – Value to return when unset.


**Realm:**

* Shared


**Returns:**

* number – Faction index.


**Example Usage:**

```lua
print("Faction:", char:getFaction())
```

---

### setFaction

**Description:**

Sets the character's faction team.

**Parameters:**

* `value` (`number`) – Faction identifier.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setFaction(FACTION_CITIZEN)
```

---

### getMoney

**Description:**

Retrieves the amount of currency this character holds.

**Parameters:**

* `default` (`any`) – Value to return when no money value is stored.


**Realm:**

* Shared


**Returns:**

* number – Amount of money or default value.


**Example Usage:**

```lua
local cash = char:getMoney(0)
```

---

### setMoney

**Description:**

Overwrites the character's stored money total.

**Parameters:**

* `value` (`number`) – Amount of currency.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setMoney(1000)
```

---

### getData

**Description:**

Returns arbitrary data previously stored on the character.

**Parameters:**

* `key` (`string`) – Data key.


* `default` (`any`) – Value to return if the entry is missing.


**Realm:**

* Shared


**Returns:**

* any – Stored value or default.


**Example Usage:**

```lua
local rank = char:getData("rank", "rookie")
```

---

### setData

**Description:**

Writes a data entry on the character and optionally syncs it.

**Parameters:**

* `key` (`string`) – Data key to modify.


* `value` (`any`) – New value to store.


* `noReplication` (`boolean`) – Suppress network updates.


* `receiver` (`Player`) – Optional specific client to send the update to.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setData("rank", "veteran")
```

---

### getVar

**Description:**

Fetches a temporary variable from the character.

**Parameters:**

* `key` (`string`) – Variable key.


* `default` (`any`) – Value returned if the variable is absent.


**Realm:**

* Shared


**Returns:**

* any – Variable value or default.


**Example Usage:**

```lua
local mood = char:getVar("mood", "neutral")
```

---

### setVar

**Description:**

Stores a temporary variable on the character.

**Parameters:**

* `key` (`string`) – Variable name.


* `value` (`any`) – Data to store.


* `noReplication` (`boolean`) – If true, skip networking the change.


* `receiver` (`Player`) – Specific target for the update.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- Store a temporary value and send it only to the owner
char:setVar("mood", "happy", nil, char:getPlayer())
```

---

### getInv

**Description:**

Retrieves the character's inventory instance.

**Parameters:**

* `index` (`number`) – Optional inventory slot index.


**Realm:**

* Shared


**Returns:**

* table – Inventory object or list of inventories.


**Example Usage:**

```lua
local inv = char:getInv()
```

---

### setInv

**Description:**

Directly sets the character's inventory table.

**Parameters:**

* `value` (`table`) – Inventory data.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setInv({})
```

---

### getAttribs

**Description:**

Returns the table of raw attribute values for the character.

**Parameters:**

* `default` (`any`) – Fallback value when no attributes are stored.


**Realm:**

* Shared


**Returns:**

* table – Attribute values table.


**Example Usage:**

```lua
local stats = char:getAttribs()
```

---

### setAttribs

**Description:**

Overwrites the character's attribute table.

**Parameters:**

* `value` (`table`) – Table of attribute levels.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setAttribs({ strength = 10 })
```

---

### getRecognizedAs

**Description:**

Gets the mapping of disguised names this character uses to recognize others.

**Parameters:**

* `default` (`any`) – Value to return when no data is stored.


**Realm:**

* Shared


**Returns:**

* table – Table of ID to alias mappings.


**Example Usage:**

```lua
local aliases = char:getRecognizedAs()
```

---

### setRecognizedAs

**Description:**

Updates the table of fake recognition names for this character.

**Parameters:**

* `value` (`table`) – Table of ID to alias mappings.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
char:setRecognizedAs({ [123] = "Masked Stranger" })
```
