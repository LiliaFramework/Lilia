# Character Meta

Documentation extracted from code comments.

---

### tostring

**Purpose**

Returns a string representation of the character, including its ID.

**Parameters**

* None

**Returns**

* string - The string representation of the character.

**Realm**

Shared.

**Example Usage**

```lua
print(character:tostring()) -- Output: "Character[1]"
```

---

### eq

**Purpose**

Checks if this character is equal to another character by comparing their IDs.

**Parameters**

* other (Character) - The character to compare with.

**Returns**

* boolean - True if the characters have the same ID, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:eq(otherCharacter) then
print("Characters are the same.")
end
```

---

### getID

**Purpose**

Returns the unique ID of this character.

**Parameters**

* None

**Returns**

* number - The character's ID.

**Realm**

Shared.

**Example Usage**

```lua
local id = character:getID()
print("Character ID:", id)
```

---

### getPlayer

**Purpose**

Returns the player entity associated with this character.

**Parameters**

* None

**Returns**

* Player or nil - The player entity, or nil if not found.

**Realm**

Shared.

**Example Usage**

```lua
local ply = character:getPlayer()
if ply then print("Player found!") end
```

---

### getDisplayedName

**Purpose**

Returns the name to display for this character to the given client, taking into account recognition and fake names.
If character recognition is enabled, the function checks if the client recognizes this character, and returns the appropriate name.
If not recognized, it may return a fake name if one is set and recognized, otherwise returns "unknown".
If recognition is disabled, always returns the character's real name.

**Parameters**

* client (Player) - The player to check recognition against.

**Returns**

* string - The name to display for this character to the given client.

**Realm**

Shared.

**Example Usage**

```lua
-- Get the display name for a character as seen by a client
local displayName = character:getDisplayedName(client)
print("You see this character as: " .. displayName)
```

---

### hasMoney

**Purpose**

Checks if the character has at least the specified amount of money.

**Parameters**

* amount (number) - The amount to check.

**Returns**

* boolean - True if the character has at least the specified amount, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:hasMoney(100) then
print("Character has enough money.")
end
```

---

### hasFlags

**Purpose**

Checks if the character has any of the specified flags. This function checks both character flags and player flags, returning true if the flag is found in either.

**Parameters**

* flagStr (string) - A string of flag characters to check.

**Returns**

* boolean - True if the character or player has at least one of the specified flags, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:hasFlags("a") then
print("Character has flag 'a'.")
end
```

---

### getItemWeapon

**Purpose**

Checks if the character's currently equipped weapon matches an item in their inventory.

**Parameters**

* requireEquip (boolean) - Whether the item must be equipped (default: true).

**Returns**

* boolean - True if the weapon is found and equipped (if required), false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:getItemWeapon() then
print("Character's weapon matches an inventory item.")
end
```

---

### getMaxStamina

**Purpose**

Returns the maximum stamina value for this character, possibly modified by hooks.

**Parameters**

* None

**Returns**

* number - The maximum stamina value.

**Realm**

Shared.

**Example Usage**

```lua
local maxStamina = character:getMaxStamina()
print("Max stamina:", maxStamina)
```

---

### getStamina

**Purpose**

Returns the current stamina value for this character.

**Parameters**

* None

**Returns**

* number - The current stamina value.

**Realm**

Shared.

**Example Usage**

```lua
local stamina = character:getStamina()
print("Current stamina:", stamina)
```

---

### hasClassWhitelist

**Purpose**

Checks if the character has a whitelist for the specified class.

**Parameters**

* class (string or number) - The class to check.

**Returns**

* boolean - True if the character is whitelisted for the class, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:hasClassWhitelist("medic") then
print("Character is whitelisted for medic class.")
end
```

---

### isFaction

**Purpose**

Checks if the character belongs to the specified faction.

**Parameters**

* faction (number) - The faction index to check.

**Returns**

* boolean - True if the character is in the faction, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:isFaction(2) then
print("Character is in faction 2.")
end
```

---

### isClass

**Purpose**

Checks if the character is in the specified class.

**Parameters**

* class (number) - The class index to check.

**Returns**

* boolean - True if the character is in the class, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:isClass(1) then
print("Character is in class 1.")
end
```

---

### getAttrib

**Purpose**

Returns the value of the specified attribute for this character, including any boosts.

**Parameters**

* key (string) - The attribute key.
* default (number) - The default value if the attribute is not set.

**Returns**

* number - The attribute value including boosts.

**Realm**

Shared.

**Example Usage**

```lua
local strength = character:getAttrib("str", 0)
print("Strength:", strength)
```

---

### getBoost

**Purpose**

Returns the boost table for the specified attribute.

**Parameters**

* attribID (string) - The attribute key.

**Returns**

* table or nil - The boost table for the attribute, or nil if none.

**Realm**

Shared.

**Example Usage**

```lua
local boost = character:getBoost("str")
if boost then print("Strength is boosted!") end
```

---

### getBoosts

**Purpose**

Returns the table of all attribute boosts for this character.

**Parameters**

* None

**Returns**

* table - The boosts table.

**Realm**

Shared.

**Example Usage**

```lua
local boosts = character:getBoosts()
PrintTable(boosts)
```

---

### doesRecognize

**Purpose**

Checks if this character recognizes another character by ID.

**Parameters**

* id (number or Character) - The character ID or character object.

**Returns**

* boolean - True if recognized, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:doesRecognize(otherChar) then
print("Character recognizes the other character.")
end
```

---

### doesFakeRecognize

**Purpose**

Checks if this character fake-recognizes another character by ID.

**Parameters**

* id (number or Character) - The character ID or character object.

**Returns**

* boolean - True if fake-recognized, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:doesFakeRecognize(otherChar) then
print("Character fake-recognizes the other character.")
end
```

---

### setData

**Purpose**

Sets custom data for this character, optionally replicating to clients and saving to the database.

**Parameters**

* k (string or table) - The key or table of key-value pairs to set.
* v (any) - The value to set (if k is a string).
* noReplication (boolean) - If true, do not replicate to clients.
* receiver (Player) - The player to send the data to (optional).

**Returns**

* nil

**Realm**

Shared (writes to database on server).

**Example Usage**

```lua
character:setData("customKey", 123)
character:setData({foo = "bar", baz = 42})
```

---

### getData

**Purpose**

Gets custom data for this character.

**Parameters**

* key (string) - The key to retrieve (optional).
* default (any) - The default value if the key is not set.

**Returns**

* any - The value for the key, or the entire dataVars table if no key is given.

**Realm**

Shared.

**Example Usage**

```lua
local value = character:getData("customKey", 0)
local allData = character:getData()
```

---

### isBanned

**Purpose**

Checks if the character is currently banned.

**Parameters**

* None

**Returns**

* boolean - True if banned, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
if character:isBanned() then
print("Character is banned.")
end
```

---

### recognize

**Purpose**

Adds a character to this character's recognition list, or sets a fake name for them.

**Parameters**

* character (number or Character) - The character or character ID to recognize.
* name (string or nil) - The fake name to assign, or nil to just recognize.

**Returns**

* boolean - Always true.

**Realm**

Server.

**Example Usage**

```lua
character:recognize(otherChar)
character:recognize(otherChar, "Alias Name")
```

---

### WhitelistAllClasses

**Purpose**

Whitelists this character for all available classes.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:WhitelistAllClasses()
```

---

### WhitelistAllFactions

**Purpose**

Whitelists this character for all available factions.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:WhitelistAllFactions()
```

---

### WhitelistEverything

**Purpose**

Whitelists this character for all factions and classes.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:WhitelistEverything()
```

---

### classWhitelist

**Purpose**

Adds a class to this character's whitelist.

**Parameters**

* class (string or number) - The class to whitelist.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:classWhitelist("medic")
```

---

### classUnWhitelist

**Purpose**

Removes a class from this character's whitelist.

**Parameters**

* class (string or number) - The class to remove from the whitelist.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:classUnWhitelist("medic")
```

---

### joinClass

**Purpose**

Attempts to set the character's class to the specified class.

**Parameters**

* class (number) - The class index to join.
* isForced (boolean) - If true, force the join regardless of requirements.

**Returns**

* boolean - True if the class was joined, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
character:joinClass(2)
```

---

### kickClass

**Purpose**

Removes the character from their current class and assigns a default class if available.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:kickClass()
```

---

### updateAttrib

**Purpose**

Increases the value of the specified attribute for this character, up to the maximum allowed.

**Parameters**

* key (string) - The attribute key.
* value (number) - The amount to add.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:updateAttrib("str", 1)
```

---

### setAttrib

**Purpose**

Sets the value of the specified attribute for this character.

**Parameters**

* key (string) - The attribute key.
* value (number) - The value to set.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:setAttrib("str", 10)
```

---

### addBoost

**Purpose**

Adds a boost to the specified attribute for this character.

**Parameters**

* boostID (string) - The unique ID for the boost.
* attribID (string) - The attribute key.
* boostAmount (number) - The amount of the boost.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:addBoost("buff1", "str", 5)
```

---

### removeBoost

**Purpose**

Removes a boost from the specified attribute for this character.

**Parameters**

* boostID (string) - The unique ID for the boost.
* attribID (string) - The attribute key.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:removeBoost("buff1", "str")
```

---

### setFlags

**Purpose**

Sets the character's flags to the specified string, updating callbacks as needed.

**Parameters**

* flags (string) - The new flags string.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:setFlags("ab")
```

---

### giveFlags

**Purpose**

Adds the specified flags to the character, calling any associated callbacks.

**Parameters**

* flags (string) - The flags to add.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:giveFlags("c")
```

---

### takeFlags

**Purpose**

Removes the specified flags from the character, calling any associated callbacks.

**Parameters**

* flags (string) - The flags to remove.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:takeFlags("a")
```

---

### save

**Purpose**

Saves the character's data to the database.

**Parameters**

* callback (function) - Optional callback to call after saving.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:save(function() print("Character saved!") end)
```

---

### sync

**Purpose**

Synchronizes the character's data with the specified receiver, or all players if none specified.

**Parameters**

* receiver (Player) - The player to sync to (optional).

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:sync()
character:sync(specificPlayer)
```

---

### setup

**Purpose**

Sets up the player entity to match this character's data (model, team, bodygroups, etc).

**Parameters**

* noNetworking (boolean) - If true, do not sync inventory and character data to clients.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:setup()
```

---

### kick

**Purpose**

Kicks the player from their character, killing them silently and notifying the client.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:kick()
```

---

### ban

**Purpose**

Bans the character for a specified time or permanently.

**Parameters**

* time (number or nil) - The ban duration in seconds, or nil for permanent ban.

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:ban(3600) -- Ban for 1 hour
character:ban()     -- Permanent ban
```

---

### delete

**Purpose**

Deletes this character from the database and notifies the player.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:delete()
```

---

### destroy

**Purpose**

Removes this character from the loaded character table.

**Parameters**

* None

**Returns**

* nil

**Realm**

Server.

**Example Usage**

```lua
character:destroy()
```

---

### giveMoney

**Purpose**

Gives the specified amount of money to the character's player.

**Parameters**

* amount (number) - The amount to give.

**Returns**

* boolean - True if successful, false otherwise.

**Realm**

Server.

**Example Usage**

```lua
character:giveMoney(100)
```

---

### takeMoney

**Purpose**

Takes the specified amount of money from the character's player.

**Parameters**

* amount (number) - The amount to take.

**Returns**

* boolean - Always true.

**Realm**

Server.

**Example Usage**

```lua
character:takeMoney(50)
```

---
