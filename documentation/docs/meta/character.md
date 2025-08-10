# Character Meta

Character objects returned by `player:getChar()` persist inventory, stats, and money.

This reference outlines helper functions for managing those records.

---

## Overview

The character-meta library contains information about a player's current game state.

It provides shortcuts for fetching stored values, verifying permissions, and linking a character back to its player.

Characters are separate from players and hold names, models, money, and other data that persists across sessions.

---

### tostring

**Purpose**

Returns a printable identifier for this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Format `"character[id]"`.

**Example Usage**

```lua
-- Print a readable identifier when saving debug logs
print("Active char: " .. char:tostring())
```

---

### eq

**Purpose**

Compares this character's ID with another object's ID.

The argument can be a `Character` instance or any object providing a `getID` method.

**Parameters**

* `other` (`Character`): Character or object to compare.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if both share the same ID.

**Example Usage**

```lua
-- Unlock the door only for its controlling character
local owner = door:getNetVar("ownChar")

if owner and char:eq(owner) then
    door:Fire("unlock", "", 0)
end
```

---

### getID

**Purpose**

Returns the unique database ID for this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Character identifier.

**Example Usage**

```lua
-- Store the character ID for later reference
local id = char:getID()

session.lastCharID = id
```

---

### getPlayer

**Purpose**

Returns the player entity currently controlling this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `Player|nil`: Owning player or `nil`.

**Example Usage**

```lua
-- Notify the controlling player that the character loaded
local ply = char:getPlayer()

if IsValid(ply) then
    ply:ChatPrint("Character ready")
end
```

---

### getDisplayedName

**Purpose**

Returns the character's name as it should be shown to the given player.

**Parameters**

* `client` (`Player`): Player requesting the name.

**Realm**

`Shared`

**Returns**

* `string`: Localized or recognized character name.

**Example Usage**

```lua
-- Announce the character's name to a viewer
client:ChatPrint(string.format("You see %s", char:getDisplayedName(client)))
```

---

### hasMoney

**Purpose**

Checks if the character has at least the given amount of money.

**Parameters**

* `amount` (`number`): Amount to check for.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the character's funds are sufficient.

**Example Usage**

```lua
-- Verify the character can pay for an item before buying
if char:hasMoney(item.price) then
    char:takeMoney(item.price)
end
```

---

### getFlags

**Purpose**

Retrieves the string of permission flags for this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `string`: Concatenated flag characters.

**Example Usage**

```lua
-- Look for the admin flag on this character
if char:getFlags():find("A") then
    print("Admin privileges detected")
end
```

---

### hasFlags

**Purpose**

Checks if the character possesses any of the specified flags.

**Parameters**

* `flags` (`string`): String of flag characters to check.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if at least one flag is present.

**Example Usage**

```lua
-- Allow special command if any required flag is present
if char:hasFlags("abc") then
    performSpecialAction()
end
```

---

### getItemWeapon

**Purpose**

Returns **true** only when the player's active weapon matches an item in their inventory and that item is equipped.

The argument defaults to `true` and the method currently only checks for equipped items.

**Parameters**

* `requireEquip` (`boolean`): Only match equipped items if `true`.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the active weapon corresponds to an item.

**Example Usage**

```lua
-- Check if we're using an inventory weapon
if char:getItemWeapon(true) then
    print("Item weapon equipped")
end
```

---

### getMaxStamina

**Purpose**

Returns the maximum stamina value for this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Maximum stamina points.

**Example Usage**

```lua
-- Calculate the proportion of stamina remaining
local pct = char:getStamina() / char:getMaxStamina()
```

---

### getStamina

**Purpose**

Retrieves the character's current stamina value.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `number`: Current stamina.

**Example Usage**

```lua
-- Display current stamina in the HUD
local stamina = char:getStamina()

drawStaminaBar(stamina)
```

---

### hasClassWhitelist

**Purpose**

Checks if the character has whitelisted the given class.

**Parameters**

* `class` (`number`): Class index.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the class is whitelisted.

**Example Usage**

```lua
-- Decide if the player may choose the medic class
if char:hasClassWhitelist(CLASS_MEDIC) then
    print("You may become a medic")
end
```

---

### isFaction

**Purpose**

Returns `true` if the character's faction matches.

**Parameters**

* `faction` (`number`): Faction index.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether the faction matches.

**Example Usage**

```lua
-- Restrict access to citizens only
if char:isFaction(FACTION_CITIZEN) then
    door:keysOwn(char:getPlayer())
end
```

---

### isClass

**Purpose**

Returns `true` if the character's class equals the specified class.

**Parameters**

* `class` (`number`): Class index.

**Realm**

`Shared`

**Returns**

* `boolean`: Whether the classes match.

**Example Usage**

```lua
-- Provide a bonus if the character is currently an engineer
if char:isClass(CLASS_ENGINEER) then
    char:restoreStamina(10)
end
```

---

### getAttrib

**Purpose**

Retrieves the value of an attribute including boosts.

**Parameters**

* `key` (`string`): Attribute identifier.

* `default` (`number`): Default value when attribute is missing.

**Realm**

`Shared`

**Returns**

* `number`: Final attribute value.

**Example Usage**

```lua
-- Calculate damage using the strength attribute
local strength = char:getAttrib("str", 0)

local dmg = baseDamage + strength * 0.5
```

---

### getBoost

**Purpose**

Returns the boost table for the given attribute.

**Parameters**

* `attribID` (`string`): Attribute identifier.

**Realm**

`Shared`

**Returns**

* `table|nil`: Table of boosts or `nil`.

**Example Usage**

```lua
-- Inspect active boosts on agility
PrintTable(char:getBoost("agi"))
```

---

### getBoosts

**Purpose**

Retrieves all attribute boosts for this character.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `table`: Mapping of attribute IDs to boost tables.

**Example Usage**

```lua
-- Print all attribute boosts for debugging
for id, data in pairs(char:getBoosts()) do
    print(id, data)
end
```

---

### doesRecognize

**Purpose**

Determines if this character recognizes another character.

**Parameters**

* `id` (`number|Character`): Character ID or object to check.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if recognized.

**Example Usage**

```lua
-- Reveal names in chat only if recognized
if char:doesRecognize(targetChar) then
    print("Known: " .. targetChar:getName())
end
```

---

### doesFakeRecognize

**Purpose**

Checks if the character has a fake recognition entry for another.

**Parameters**

* `id` (`number|Character`): Character identifier.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if fake recognized.

**Example Usage**

```lua
-- See if recognition was forced by a disguise item
if char:doesFakeRecognize(targetChar) then
    print("Recognition is fake")
end
```

---

### setData

**Purpose**

Sets custom data on this character, optionally syncing it to clients and saving it in the database.

**Parameters**

* `k` (`string|table`): Key to set or table of key-value pairs.
* `v` (`any`): Value to store when `k` is a string.
* `noReplication` (`boolean`): If `true`, do not network the change.
* `receiver` (`Player|nil`): Specific player to receive the update.

**Realm**

`Shared`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Store character-specific state and sync it to the owner
char:setData("mission", {step = 2}, false)
```

---

### getData

**Purpose**

Fetches custom data stored on the character.

**Parameters**

* `key` (`string|nil`): Data key to retrieve. Omitting returns all entries.
* `default` (`any`): Fallback value when the key is missing.

**Realm**

`Shared`

**Returns**

* `any`: Stored value, entire data table, or the provided default.

**Example Usage**

```lua
-- Read a saved mission step
local mission = char:getData("mission", {})
```

---

### isBanned

**Purpose**

Checks whether this character is currently banned.

**Parameters**

* None

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if the character is banned or permanently banned.

**Example Usage**

```lua
if char:isBanned() then
    print("Access denied")
end
```

---

### recognize

**Purpose**

Adds another character to this one's recognition list.

When a custom `name` is provided that alias will be shown whenever the character is recognized.

**Parameters**

* `character` (`number|Character`): Character to recognize or its ID.

* `name` (`string|nil`): Optional fake name to store.

**Realm**

`Server`

**Returns**

* `boolean`: Always `true` once processed.

**Example Usage**

```lua
-- Remember the rival using a codename and by ID
char:recognize(rivalChar:getID(), "Mysterious Stranger")
```

---

### WhitelistAllClasses

**Purpose**

Grants class whitelist access for every class defined by the schema.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Allow this character to choose any class
char:WhitelistAllClasses()
```

---

### WhitelistAllFactions

**Purpose**

Marks the character as whitelisted for every faction.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Grant access to all factions for testing
char:WhitelistAllFactions()
```

---

### WhitelistEverything

**Purpose**

Convenience wrapper that whitelists the character for all factions and classes.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Unlock every faction and class
char:WhitelistEverything()
```

---

### classWhitelist

**Purpose**

Adds the specified class to this character's whitelist.

**Parameters**

* `class` (`number`): Class index to whitelist.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Permit switching to the engineer class
char:classWhitelist(CLASS_ENGINEER)
```

---

### classUnWhitelist

**Purpose**

Removes the specified class from the character's whitelist.

**Parameters**

* `class` (`number`): Class index to remove.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Revoke access to the medic class
char:classUnWhitelist(CLASS_MEDIC)
```

---

### joinClass

**Purpose**

Attempts to set the character's current class.

When `isForced` is `true` the normal eligibility checks are skipped.

**Parameters**

* `class` (`number`): Class index to join.

* `isForced` (`boolean`): Bypass restrictions when `true`.

**Realm**

`Server`

**Returns**

* `boolean`: `true` on success, `false` otherwise.

**Example Usage**

```lua
-- Force the character into the soldier class
char:joinClass(CLASS_SOLDIER, true)
```

---

### kickClass

**Purpose**

Removes the character from their current class, reverting to the default for their faction.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Reset the character's class after leaving the group
char:kickClass()
```

---

### updateAttrib

**Purpose**

Increases an attribute by the specified value, clamped to the maximum allowed.

**Parameters**

* `key` (`string`): Attribute identifier.

* `value` (`number`): Amount to add.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Award experience toward agility
char:updateAttrib("agi", 5)
```

---

### setAttrib

**Purpose**

Directly sets an attribute to the given value.

**Parameters**

* `key` (`string`): Attribute identifier.

* `value` (`number`): New level for the attribute.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Reset strength after an event
char:setAttrib("str", 10)
```

---

### addBoost

**Purpose**

Applies a temporary boost to one of the character's attributes.

**Parameters**

* `boostID` (`string`): Unique identifier for the boost.

* `attribID` (`string`): Attribute to modify.

* `boostAmount` (`number`): Amount of the boost.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Grant a strength bonus while an item is equipped
char:addBoost("powerGloves", "str", 2)
```

---

### removeBoost

**Purpose**

Removes a previously applied attribute boost.

**Parameters**

* `boostID` (`string`): Identifier used when the boost was added.

* `attribID` (`string`): Attribute affected by the boost.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Clear the item bonus when unequipped
char:removeBoost("powerGloves", "str")
```

---

### setFlags

**Purpose**

Replaces the character's flag string with the provided value.

**Parameters**

* `flags` (`string`): New flag characters to assign.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Reset all flags before assigning new ones
char:setFlags("")
```

---

### giveFlags

**Purpose**

Adds the specified flag characters to the character.

**Parameters**

* `flags` (`string`): Flags to grant.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Grant temporary admin powers
char:giveFlags("A")
```

---

### takeFlags

**Purpose**

Removes the given flag characters from the character.

**Parameters**

* `flags` (`string`): Flags to revoke.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Strip special permissions when demoted
char:takeFlags("A")
```

---

### save

**Purpose**

Persists the character's current data to the database.

**Parameters**

* `callback` (`function|nil`): Optional function run after saving completes.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Save and then notify when finished
char:save(function()
    print("character saved")
end)
```

---

### sync

**Purpose**

Sends the character's networkable variables to a specific player.

Passing `nil` broadcasts the data to everyone.

When the receiver is the character's own player, only local variables intended for them are included.

**Parameters**

* `receiver` (`Player|nil`): Player to receive the data or `nil` for broadcast.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Send updates only to one player
char:sync(targetPlayer)
```

---

### setup

**Purpose**

Sets up the player entity to use this character's model, faction, and inventory data.

Use `noNetworking` to skip network updates during initialization.

**Parameters**

* `noNetworking` (`boolean`): Skip networking inventories and vars when `true`.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Fully prepare the character after selection
char:setup()
```

---

### kick

**Purpose**

Forcibly disconnects the player from their character.

The player is killed silently and immediately respawns with no character loaded.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Eject the player from their character
char:kick() -- they will respawn without a character
```

---

### ban

**Purpose**

Marks the character as banned for the given duration, saves the state, and immediately kicks the controlling player.

This also triggers the `OnCharPermakilled` hook.

**Parameters**

* `time` (`number|nil`): Ban length in seconds or `nil` for permanent.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Ban the character for one hour
char:ban(3600)
```

---

### delete

**Purpose**

Completely removes the character from the database along with any inventories it owns.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Permanently remove this character
char:delete()
```

---

### destroy

**Purpose**

Removes the character from the server's loaded cache without touching any saved data.

Useful after deleting a character or when cleaning up disconnected players.

**Parameters**

* None

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Clean up a removed character instance
char:destroy()
```

---

### giveMoney

**Purpose**

Adds the specified amount to the character's wallet by calling the owning player's `addMoney` method.

**Parameters**

* `amount` (`number`): Amount to add to the wallet.

**Realm**

`Server`

**Returns**

* `boolean`: `false` if the owner is missing, otherwise `true`.

**Example Usage**

```lua
-- Pay the character for completing a mission
local reward = 250

char:giveMoney(reward)
```

---

### takeMoney

**Purpose**

Subtracts the specified amount of money from the character.

Internally this calls `giveMoney` with a negative value and logs the deduction.

**Parameters**

* `amount` (`number`): Amount to remove.

**Realm**

`Server`

**Returns**

* `boolean`: Always `true` when the deduction occurs.

**Example Usage**

```lua
-- Deduct a fine from the character
local fine = 50

char:takeMoney(fine)
```

---

### getName

**Purpose**

Returns the character's stored name or a default value.

**Parameters**

* `default` (`any`): Value to return if the name is unset.

**Realm**

`Shared`

**Returns**

* `string`: Character name or the provided default.

**Example Usage**

```lua
print("Character name:", char:getName("Unknown"))
```

---

### setName

**Purpose**

Updates the character's name and replicates the change to players.

**Parameters**

* `value` (`string`): New name for the character.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setName("Alyx Vance")
```

---

### getDesc

**Purpose**

Fetches the character's description text or returns the given default.

**Parameters**

* `default` (`any`): Value to return if no description exists.

**Realm**

`Shared`

**Returns**

* `string`: Description or fallback value.

**Example Usage**

```lua
local about = char:getDesc("No bio")
```

---

### setDesc

**Purpose**

Assigns a new description for the character.

**Parameters**

* `value` (`string`): Description text.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setDesc("Hardened wasteland survivor")
```

---

### getModel

**Purpose**

Retrieves the model path assigned to the character.

**Parameters**

* `default` (`any`): Value returned when no model is stored.

**Realm**

`Shared`

**Returns**

* `string`: Model path or the fallback value.

**Example Usage**

```lua
local mdl = char:getModel("models/error.mdl")
```

---

### setModel

**Purpose**

Sets the character's player model and broadcasts the update.

**Parameters**

* `value` (`string`): Model file path.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setModel("models/alyx.mdl")
```

---

### getSkin

**Purpose**

Gets the current skin index applied to the character's model.

**Parameters**

* `default` (`any`): Fallback value when no skin is stored.

**Realm**

`Shared`

**Returns**

* `number`: Skin index or the provided default.

**Example Usage**

```lua
local skin = char:getSkin(0)
```

---

### setSkin

**Purpose**

Updates the character's skin and applies it to the player.

**Parameters**

* `value` (`number`): Skin index.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setSkin(1)
```

---

### getBodygroups

**Purpose**

Returns the bodygroup settings applied to the character's model.

**Parameters**

* `default` (`any`): Value returned when no bodygroups are stored.

**Realm**

`Shared`

**Returns**

* `table`: Table of bodygroup indices to values.

**Example Usage**

```lua
local groups = char:getBodygroups({})
```

---

### setBodygroups

**Purpose**

Sets bodygroup values for the character's model and applies them.

**Parameters**

* `value` (`table`): Table mapping indices to bodygroup values.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setBodygroups({ [1] = 2 })
```

---

### getClass

**Purpose**

Returns the class index currently assigned or the supplied default.

**Parameters**

* `default` (`any`): Value used when the class is unset.

**Realm**

`Shared`

**Returns**

* `number`: Class index.

**Example Usage**

```lua
if char:getClass() == CLASS_ENGINEER then
    print("Engineer present")
end
```

---

### setClass

**Purpose**

Stores a new class index for the character.

**Parameters**

* `value` (`number`): Class identifier.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setClass(CLASS_ENGINEER)
```

---

### getFaction

**Purpose**

Gets the faction index of the character or a fallback value.

**Parameters**

* `default` (`any`): Value to return when unset.

**Realm**

`Shared`

**Returns**

* `number`: Faction index.

**Example Usage**

```lua
print("Faction:", char:getFaction())
```

---

### setFaction

**Purpose**

Sets the character's faction team.

**Parameters**

* `value` (`number`): Faction identifier.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setFaction(FACTION_CITIZEN)
```

---

### getMoney

**Purpose**

Retrieves the amount of currency this character holds.

**Parameters**

* `default` (`any`): Value to return when no money value is stored.

**Realm**

`Shared`

**Returns**

* `number`: Amount of money or default value.

**Example Usage**

```lua
local cash = char:getMoney(0)
```

---

### setMoney

**Purpose**

Overwrites the character's stored money total.

**Parameters**

* `value` (`number`): Amount of currency.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setMoney(1000)
```

---

### getLoginTime

**Purpose**

Retrieves the timestamp of when the player logged into this character.
This value is local to the character's owner and is not broadcast to other players.

**Parameters**

* `default` (`number`): Value returned if no time is stored. Defaults to `0`.

**Realm**

`Shared`

**Returns**

* `number`: Unix timestamp or the provided fallback.

**Example Usage**

```lua
local logged = char:getLoginTime(0)
```

---

### setLoginTime

**Purpose**

Stores the timestamp for when the player logged into this character.
The stored time is kept local to the owner and not sent to other players.

**Parameters**

* `value` (`number`): Unix timestamp to store. Defaults to `0`.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setLoginTime(os.time())
```

---

### getPlayTime

**Purpose**

Gets the total accumulated playtime in seconds for this character.
This value is maintained locally for the owning player only.

**Parameters**

* `default` (`number`): Value returned when no playtime is recorded. Defaults to `0`.

**Realm**

`Shared`

**Returns**

* `number`: Seconds of playtime or the provided default.

**Example Usage**

```lua
local seconds = char:getPlayTime(0)
```

---

### setPlayTime

**Purpose**

Sets the total accumulated playtime for this character.
The updated value remains local to the owning player.

**Parameters**

* `value` (`number`): Time in seconds.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setPlayTime(3600)
```

---

### getVar

**Purpose**

Fetches a temporary variable from the character.

**Parameters**

* `key` (`string`): Variable key.

* `default` (`any`): Value returned if the variable is absent.

**Realm**

`Shared`

**Returns**

* `any`: Variable value or default.

**Example Usage**

```lua
local mood = char:getVar("mood", "neutral")
```

---

### setVar

**Purpose**

Stores a temporary variable on the character.

**Parameters**

* `key` (`string`): Variable name.

* `value` (`any`): Data to store.

* `noReplication` (`boolean`): If `true`, skip networking the change.

* `receiver` (`Player`): Specific target for the update.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
-- Store a temporary value and send it only to the owner
char:setVar("mood", "happy", nil, char:getPlayer())
```

---

### getInv

**Purpose**

Retrieves the character's inventory instance.

**Parameters**

* `index` (`number`): Optional inventory slot index.

**Realm**

`Shared`

**Returns**

* `table`: Inventory object or list of inventories.

**Example Usage**

```lua
local inv = char:getInv()
```

---

### setInv

**Purpose**

Directly sets the character's inventory table.

**Parameters**

* `value` (`table`): Inventory data.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setInv({})
```

---

### getAttribs

**Purpose**

Returns the table of raw attribute values for the character.

**Parameters**

* `default` (`any`): Fallback value when no attributes are stored.

**Realm**

`Shared`

**Returns**

* `table`: Attribute values table.

**Example Usage**

```lua
local stats = char:getAttribs()
```

---

### setAttribs

**Purpose**

Overwrites the character's attribute table.

**Parameters**

* `value` (`table`): Table of attribute levels.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setAttribs({ strength = 10 })
```

---

### getFakeName

**Purpose**

Retrieves the table of fake names this character assigns to other characters.

**Parameters**

* `default` (`any`): Value returned when no data exists.

**Realm**

`Shared`

**Returns**

* `table`: Mapping of character IDs to fake names.

**Example Usage**

```lua
local aliases = char:getFakeName()
```

---

### setFakeName

**Purpose**

Assigns a table of fake names used when this character recognizes others.

**Parameters**

* `value` (`table`): Table mapping character IDs to fake names.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setFakeName({ [123] = "Masked Stranger" })
```

---

### getRecognition

**Purpose**

Returns the raw recognition string listing known character IDs.

**Parameters**

* `default` (`any`): Value returned when no recognition data exists.

**Realm**

`Shared`

**Returns**

* `string`: Stored recognition data or the provided default.

**Example Usage**

```lua
local list = char:getRecognition("")
```

---

### setRecognition

**Purpose**

Sets the recognition list for this character.

**Parameters**

* `value` (`string`): Comma-delimited character IDs or empty to clear.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setRecognition("1,2,3,")
```

---

### getLastPos

**Purpose**

Gets the saved respawn position table for the character.

**Parameters**

* `default` (`any`): Fallback value when no position is stored.

**Realm**

`Shared`

**Returns**

* `table`: Position data table or the provided default.

**Example Usage**

```lua
local info = char:getLastPos()
```

---

### setLastPos

**Purpose**

Stores a respawn position for the character.

**Parameters**

* `value` (`table`): Position table or `nil` to clear.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setLastPos(nil)
```

---

### getAmmo

**Purpose**

Retrieves the stored ammunition counts for this character.

**Parameters**

* `default` (`any`): Value returned when no ammo data exists.

**Realm**

`Shared`

**Returns**

* `table`: Mapping of ammo types to quantities.

**Example Usage**

```lua
local ammo = char:getAmmo({})
```

---

### setAmmo

**Purpose**

Stores ammunition counts for the character.

**Parameters**

* `value` (`table`): Table mapping ammo types to amounts.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setAmmo({ pistol = 24 })
```

---

### getClasswhitelists

**Purpose**

Returns the list of class whitelists granted to this character.

**Parameters**

* `default` (`any`): Value returned when no whitelist data exists.

**Realm**

`Shared`

**Returns**

* `table`: Table of class identifiers set to `true`.

**Example Usage**

```lua
local classes = char:getClasswhitelists({})
```

---

### setClasswhitelists

**Purpose**

Overwrites the character's class whitelist table.

**Parameters**

* `value` (`table`): Table of class identifiers to enable.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setClasswhitelists({ medic = true })
```

---

### getMarkedForDeath

**Purpose**

Checks whether this character is flagged for permadeath.

**Parameters**

* `default` (`any`): Value returned if the flag is unset.

**Realm**

`Shared`

**Returns**

* `boolean`: `true` if marked for death, otherwise the default.

**Example Usage**

```lua
if char:getMarkedForDeath(false) then
    print("Character will be removed on death")
end
```

---

### setMarkedForDeath

**Purpose**

Marks or unmarks the character for permadeath.

**Parameters**

* `value` (`boolean`): `true` to mark, `false` to clear.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setMarkedForDeath(true)
```

---

### getBanned

**Purpose**

Retrieves the ban status timestamp for this character.

**Parameters**

* `default` (`any`): Value returned when no ban data exists.

**Realm**

`Shared`

**Returns**

* `number`: `-1` for permanent ban, a Unix timestamp, or the default.

**Example Usage**

```lua
local bannedUntil = char:getBanned(0)
```

---

### setBanned

**Purpose**

Sets the ban status for this character.

**Parameters**

* `value` (`number`): `-1` for permanent ban or future Unix timestamp.

**Realm**

`Server`

**Returns**

* `nil`: This function does not return a value.

**Example Usage**

```lua
char:setBanned(-1)
```

---
