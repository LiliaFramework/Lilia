---
title: **Character Object Documentation**
description: Comprehensive documentation for the Character object in the Lilia game framework.
---

# **Character Object**

Characters are a fundamental object type in Lilia. They are distinct from players, where players are the representation of a person's existence in the server that owns a character, and their character is their currently selected persona. All the characters that a player owns will be loaded into memory once they connect to the server. Characters are saved during a regular interval (`lia.config.CharacterDataSaveInterval`), and during specific events (e.g., when the owning player switches away from one character to another).

They contain all information that is not persistent with the player; names, descriptions, model, currency, etc. For the most part, you'll want to keep all information stored on the character since it will probably be different or change if the player switches to another character. An easy way to do this is to use `lia.char.registerVar` to easily create accessor functions for variables that automatically save to the character object.

---

## **characterMeta:tostring**

**Description**

Provides a human-readable string representation of the character.

**Realm**

`Shared`

**Returns**

- **String**: A string in the format `"character[ID]"`, where `ID` is the character's unique identifier.

**Example**

```lua
print(lia.char.loaded[1])
-- Output: "character[1]"
```

---

## **characterMeta:eq**

**Description**

Compares this character with another character for equality based on their unique IDs.

**Realm**

`Shared`

**Parameters**

- **other** (`Character`): The other character to compare against.

**Returns**

- **Boolean**: `true` if both characters have the same ID; otherwise, `false`.

**Example**

```lua
local char1 = lia.char.loaded[1]
local char2 = lia.char.loaded[2]
print(char1 == char2)
-- Output: false
```

---

## **characterMeta:getID**

**Description**

Retrieves the unique database ID of this character.

**Realm**

`Shared`

**Returns**

- **Integer**: The unique identifier of the character.

**Example**

```lua
local charID = character:getID()
print(charID)
-- Output: 1
```

---

## **characterMeta:getPlayer**

**Description**

Obtains the player object that currently owns this character.

**Realm**

`Shared`

**Returns**

- **Player|nil**: The player who owns this character, or `nil` if no valid player is found.

**Example**

```lua
local owner = character:getPlayer()
if owner then
    print("Character is owned by:", owner:Nick())
end
```

---

## **characterMeta:hasMoney**

**Description**

Checks whether the character possesses at least a specified amount of in-game currency.

**Realm**

`Shared`

**Parameters**

- **amount** (`float`): The minimum amount of currency to check for. Must be a non-negative number.

**Returns**

- **Boolean**: `true` if the character's current money is equal to or exceeds the specified amount; otherwise, `false`.

**Example**

```lua
local hasEnoughMoney = character:hasMoney(100)
if hasEnoughMoney then
    print("Character has sufficient funds.")
else
    print("Character lacks sufficient funds.")
end
```

---

## **characterMeta:getFlags**

**Description**

Retrieves all flags associated with this character.

**Realm**

`Shared`

**Returns**

- **String**: A concatenated string of all flags the character possesses. Each character in the string represents an individual flag.

**Example**

```lua
local flags = character:getFlags()
for i = 1, #flags do
    local flag = flags:sub(i, i)
    print("Flag:", flag)
end
```

---

## **characterMeta:hasFlags**

**Description**

Determines if the character has one or more specified flags.

**Realm**

`Shared`

**Parameters**

- **flags** (`String`): A string containing one or more flags to check.

**Returns**

- **Boolean**: `true` if the character has at least one of the specified flags; otherwise, `false`.

**Example**

```lua
if character:hasFlags("admin") then
    print("Character has admin privileges.")
end
```

---

## **characterMeta:getItemWeapon**

**Description**

Retrieves the currently equipped weapon of the character along with its corresponding inventory item.

**Realm**

`Shared`

**Returns**

- **Entity|false**: The equipped weapon entity if a weapon is equipped; otherwise, `false`.
- **Item|false**: The corresponding item from the character's inventory if found; otherwise, `false`.

**Example**

```lua
local weapon, item = character:getItemWeapon()
if weapon then
    print("Equipped weapon:", weapon:GetClass())
else
    print("No weapon equipped.")
end
```

---

## **characterMeta:setFlags**

**Description**

Sets the complete set of flags accessible by this character, replacing any existing flags.

**Note:** This method overwrites all existing flags and does not append to them.

**Realm**

`Server`

**Parameters**

- **flags** (`String`): A string containing one or more flags to assign to the character.

**Example**

```lua
character:setFlags("petr")
-- This sets the character's flags to 'p', 'e', 't', 'r'
```

---

## **characterMeta:giveFlags**

**Description**

Adds one or more flags to the character's existing set of accessible flags without removing existing ones.

**Realm**

`Server`

**Parameters**

- **flags** (`String`): A string containing one or more flags to add.

**Example**

```lua
character:giveFlags("pet")
-- Adds 'p', 'e', and 't' flags to the character
```

---

## **characterMeta:takeFlags**

**Description**

Removes one or more flags from the character's set of accessible flags.

**Realm**

`Server`

**Parameters**

- **flags** (`String`): A string containing one or more flags to remove.

**Example**

```lua
-- For a character with "pet" flags
character:takeFlags("p")
-- The character now only has 'e' and 't' flags
```

---

## **characterMeta:save**

**Description**

Persists the character's current state and data to the database.

**Realm**

`Server`

**Parameters**

- **callback** (`function`, optional): An optional callback function to execute after the save operation completes successfully.

**Example**

```lua
character:save(function()
    print("Character saved successfully!")
end)
```

---

## **characterMeta:sync**

**Description**

Synchronizes the character's data with clients, making them aware of the character's current state.

This method handles different synchronization scenarios:
- If `receiver` is `nil`, the character's data is synced to all connected players.
- If `receiver` is the owner of the character, full character data is sent.
- If `receiver` is not the owner, only limited data is sent to prevent unauthorized access.

**Realm**

`Server`

**Internal:**  

This function is intended for internal use and should not be called directly.

**Parameters**

- **receiver** (`Player|nil`): The specific player to send the character data to. If `nil`, data is sent to all players.

**Example**

```lua
character:sync()
-- Syncs character data to all players
```

---

## **characterMeta:setup**

**Description**

Configures the character's appearance and synchronizes this information with the owning player. This includes setting the player's model, faction, body groups, and skin. Optionally, it can prevent networking to other clients.

**Realm**

`Server`

**Internal:**  

This function is intended for internal use and should not be called directly.

**Parameters**

- **noNetworking** (`Boolean`, optional): If set to `true`, the character's information will not be synchronized with other players.

**Example**

```lua
character:setup()
-- Sets up the character and syncs data with the owning player
```

---

## **characterMeta:kick**

**Description**

Forces the player to exit their current character and redirects them to the character selection menu. This is typically used when a character is banned or deleted.

**Realm**

`Server`

**Example**

```lua
character:kick()
```

---

## **characterMeta:ban**

**Description**

Bans the character, preventing it from being used for a specified duration or permanently if no duration is provided. This action also forces the player out of the character.

**Realm**

`Server`

**Parameters**

- **time** (`float`, optional): The duration of the ban in seconds. If omitted or `nil`, the ban is permanent.

**Example**

```lua
character:ban(3600) -- Bans the character for 1 hour
character:ban() -- Permanently bans the character
```

---

## **characterMeta:delete**

**Description**

Removes the character from the database and memory, effectively deleting it permanently.

**Realm**

`Server`

**Example**

```lua
character:delete()
```

---

## **characterMeta:destroy**

**Description**

Destroys the character instance, removing it from memory and ensuring it is no longer tracked by the server. This does not delete the character from the database.

**Realm**

`Server`

**Example**

```lua
character:destroy()
```

---

## **characterMeta:giveMoney**

**Description**

Adds or subtracts money from the character's wallet. This function adds money to the wallet and optionally handles overflow by dropping excess money on the ground.

**Realm**

`Server`

**Parameters**

- **amount** (`float`): The amount of money to add or subtract.

**Returns**

- **Boolean**: Always returns `true` to indicate the operation was processed.

**Example**

```lua
character:giveMoney(500) -- Adds 500 to the character's wallet
```

---

## **characterMeta:takeMoney**

**Description**

Specifically removes money from the character's wallet. This function ensures that only positive values are used to subtract from the wallet.

**Realm**

`Server`

**Parameters**

- **amount** (`float`): The amount of money to remove. Must be a positive number.

**Returns**

- **Boolean**: Always returns `true` to indicate the operation was processed.

**Example**

```lua
character:takeMoney(100) -- Removes 100 from the character's wallet
```

---

## **characterMeta:doesRecognize**

**Description**

Determines if this character recognizes another character based on their unique ID.

**Realm**

`Shared`

**Parameters**

- **id** (`number` | `Character`): The unique ID of the character to check recognition for. This can be either a numeric ID or a `Character` object.

**Returns**

- **Boolean**: `true` if the character recognizes the specified character; otherwise, `false`.

**Example**

```lua
local otherCharacter = lia.char.loaded[2]
if character:doesRecognize(otherCharacter) then
    print("Character recognizes the other character.")
else
    print("Character does not recognize the other character.")
end
```

---

## **characterMeta:doesFakeRecognize**

**Description**

Determines if this character recognizes another character by a fake name based on their unique ID.

**Realm**

`Shared`

**Parameters**

- **id** (`number` | `Character`): The unique ID of the character to check fake recognition for. This can be either a numeric ID or a `Character` object.

**Returns**

- **Boolean**: `true` if the character recognizes the specified character by a fake name; otherwise, `false`.

**Example**

```lua
local otherCharacter = lia.char.loaded[3]
if character:doesFakeRecognize(otherCharacter) then
    print("Character recognizes the other character by a fake name.")
else
    print("Character does not recognize the other character by a fake name.")
end
```

---

## **characterMeta:recognize**

**Description**

Allows the character to recognize another character, optionally under a specified fake name.

**Realm**

`Server`

**Parameters**

- **character** (`Character` | `number`): The character to be recognized, either as a `Character` object or by their unique ID number.
- **name** (`string`, optional): The fake name under which the character is recognized. If `nil`, the character is recognized by their actual ID.

**Returns**

- **Boolean**: `true` if the recognition was successful.

**Example**

```lua
local targetCharacter = lia.char.loaded[4]
character:recognize(targetCharacter, "Shadow")
-- This sets the character to recognize targetCharacter by the fake name "Shadow"
```

---

## **characterMeta:hasClassWhitelist**

**Description**

Checks if the character has whitelisted access to a specific class.

**Realm**

`Shared`

**Parameters**

- **class** (`number`): The class ID to check for whitelisting.

**Returns**

- **Boolean**: `true` if the character has whitelist access to the specified class; otherwise, `false`.

**Example**

```lua
local classID = 5
if character:hasClassWhitelist(classID) then
    print("Character has whitelist access to class:", classID)
end
```

---

## **characterMeta:isFaction**

**Description**

Determines if the character belongs to a specified faction.

**Realm**

`Shared`

**Parameters**

- **faction** (`string`): The name of the faction to check against.

**Returns**

- **Boolean**: `true` if the character belongs to the specified faction; otherwise, `false`.

**Example**

```lua
if character:isFaction("Police") then
    print("Character is a member of the Police faction.")
end
```

---

## **characterMeta:isClass**

**Description**

Determines if the character belongs to a specified class.

**Realm**

`Shared`

**Parameters**

- **class** (`string`): The name of the class to check against.

**Returns**

- **Boolean**: `true` if the character belongs to the specified class; otherwise, `false`.

**Example**

```lua
if character:isClass("Medic") then
    print("Character is a Medic.")
end
```

---

## **characterMeta:WhitelistAllClasses**

**Description**

Grants the character whitelist access to all available classes.

**Realm**

`Shared`

**Example**

```lua
character:WhitelistAllClasses()
-- Character now has whitelist access to every class
```

---

## **characterMeta:WhitelistAllFactions**

**Description**

Grants the character whitelist access to all available factions.

**Realm**

`Shared`

**Example**

```lua
character:WhitelistAllFactions()
-- Character now has whitelist access to every faction
```

---

## **characterMeta:WhitelistEverything**

**Description**

Grants the character whitelist access to all classes and factions.

**Realm**

`Shared`

**Example**

```lua
character:WhitelistEverything()
-- Character now has whitelist access to every class and faction
```

---

## **characterMeta:classWhitelist**

**Description**

Adds a specific class to the character's whitelist, granting access to that class.

**Realm**

`Shared`

**Parameters**

- **class** (`number`): The class ID to whitelist for the character.

**Example**

```lua
local classID = 7
character:classWhitelist(classID)
-- Character now has whitelist access to class 7
```

---

## **characterMeta:classUnWhitelist**

**Description**

Removes a specific class from the character's whitelist, revoking access to that class.

**Realm**

`Shared`

**Parameters**

- **class** (`number`): The class ID to remove from the character's whitelist.

**Example**

```lua
local classID = 7
character:classUnWhitelist(classID)
-- Character no longer has whitelist access to class 7
```

---

## **characterMeta:joinClass**

**Description**

Assigns the character to a specified class. Optionally forces the assignment even if conditions are not met.

**Realm**

`Shared`

**Parameters**

- **class** (`string`): The name of the class to join.
- **isForced** (`boolean`, optional): If set to `true`, the character is forced to join the class regardless of any restrictions. Defaults to `false`.

**Returns**

- **Boolean**: `true` if the character successfully joined the class; otherwise, `false`.

**Example**

```lua
local success = character:joinClass("Sniper", true)
if success then
    print("Character successfully joined the Sniper class.")
else
    print("Character failed to join the Sniper class.")
end
```

---

## **characterMeta:kickClass**

**Description**

Removes the character from their current class and assigns them to the default class of their faction.

**Realm**

`Shared`

**Example**

```lua
character:kickClass()
-- Character is now assigned to their faction's default class
```

---

## **characterMeta:getMaxStamina**

**Description**

Retrieves the maximum stamina value for the character. This value can be modified by hooks or defaults to a module-defined value.

**Realm**

`Shared`

**Returns**

- **Integer**: The maximum stamina value for the character.

**Example**

```lua
local maxStamina = character:getMaxStamina()
print("Character's maximum stamina:", maxStamina)
```

---

## **characterMeta:getStamina**

**Description**

Retrieves the current stamina value of the character. This value can be a local variable or default to a module-defined value.

**Realm**

`Shared`

**Returns**

- **Integer**: The current stamina value of the character.

**Example**

```lua
local currentStamina = character:getStamina()
print("Character's current stamina:", currentStamina)
```

---

## **characterMeta:getAttrib**

**Description**

Retrieves the value of a specific attribute for the character, including any applied boosts.

**Realm**

`Shared`

**Parameters**

- **key** (`string`): The key of the attribute to retrieve.
- **default** (`number`, optional): The default value to return if the attribute is not found. Defaults to `0`.

**Returns**

- **Number**: The value of the specified attribute, including applied boosts.

**Example**

```lua
local strength = character:getAttrib("strength", 10)
print("Character's strength:", strength)
```

---

## **characterMeta:getBoost**

**Description**

Retrieves the boost value for a specific attribute of the character.

**Realm**

`Shared`

**Parameters**

- **attribID** (`number`): The ID of the attribute to retrieve the boost for.

**Returns**

- **Number | nil**: The boost value for the specified attribute, or `nil` if no boost is found.

**Example**

```lua
local strengthBoost = character:getBoost("strength")
if strengthBoost then
    print("Character has a strength boost of:", strengthBoost)
else
    print("Character has no strength boost.")
end
```

---

## **characterMeta:getBoosts**

**Description**

Retrieves all boosts applied to the character's attributes.

**Realm**

`Shared`

**Returns**

- **Table**: A table containing all boosts applied to the character's attributes.

**Example**

```lua
local allBoosts = character:getBoosts()
for attribID, boosts in pairs(allBoosts) do
    for boostID, amount in pairs(boosts) do
        print("Attribute:", attribID, "Boost ID:", boostID, "Amount:", amount)
    end
end
```

---

## **characterMeta:updateAttrib**

**Description**

Updates the value of a character's attribute by adding a specified amount to it. Ensures that the attribute does not exceed its maximum allowed value.

**Realm**

`Server`

**Parameters**

- **key** (`string`): The key of the attribute to update.
- **value** (`number`): The amount to add to the attribute.

**Example**

```lua
character:updateAttrib("agility", 5)
-- Increases the character's agility by 5
```

---

## **characterMeta:setAttrib**

**Description**

Sets the value of a character's attribute to a specified value.

**Realm**

`Server`

**Parameters**

- **key** (`string`): The key of the attribute to set.
- **value** (`number`): The value to set for the attribute.

**Example**

```lua
character:setAttrib("intelligence", 15)
-- Sets the character's intelligence attribute to 15
```

---

## **characterMeta:addBoost**

**Description**

Adds a boost to a specific attribute of the character.

**Realm**

`Server`

**Parameters**

- **boostID** (`string`): The ID of the boost to add.
- **attribID** (`string`): The ID of the attribute to which the boost should be applied.
- **boostAmount** (`number`): The amount of the boost to add to the attribute.

**Returns**

- **Boolean**: `true` if the boost was successfully added.

**Example**

```lua
character:addBoost("buff_001", "strength", 10)
-- Adds a boost of +10 to the character's strength attribute
```

---

## **characterMeta:removeBoost**

**Description**

Removes a boost from a specific attribute of the character.

**Realm**

`Server`

**Parameters**

- **boostID** (`string`): The ID of the boost to remove.
- **attribID** (`string`): The ID of the attribute from which the boost should be removed.

**Example**

```lua
character:removeBoost("buff_001", "strength")
-- Removes the boost "buff_001" from the character's strength attribute
```

---