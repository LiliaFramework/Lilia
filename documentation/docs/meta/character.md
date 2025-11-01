# Character Meta

Character management system for the Lilia framework.

---

Overview

The character meta table provides comprehensive functionality for managing character data, attributes, and operations in the Lilia framework. It handles character creation, data persistence, attribute management, recognition systems, and character-specific operations. The meta table operates on both server and client sides, with the server managing character storage and validation while the client provides character data access and display. It includes integration with the database system for character persistence, inventory management for character items, and faction/class systems for character roles. The meta table ensures proper character data synchronization, attribute calculations with boosts, recognition between characters, and comprehensive character lifecycle management from creation to deletion.

---

### tostring

**Purpose**

Converts the character object to a string representation

**When Called**

When displaying character information or debugging

**Returns**

* string - Formatted character string with ID

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get character string representation
local charString = character:tostring()
print(charString) -- Output: "character[123]"

```

**Medium Complexity:**
```lua
-- Medium: Use in debug messages
local char = player:getChar()
if char then
    print("Character: " .. char:tostring())
end

```

**High Complexity:**
```lua
-- High: Use in logging system
local char = player:getChar()
lia.log.add(player, "action", "Character " .. char:tostring() .. " performed action")

```

---

### eq

**Purpose**

Compares two character objects for equality based on their IDs

**When Called**

When checking if two character references point to the same character

**Parameters**

* `other` (*character*): The other character object to compare with

**Returns**

* boolean - True if both characters have the same ID, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Compare two character objects
local char1 = player1:getChar()
local char2 = player2:getChar()
if char1:eq(char2) then
    print("Same character")
end

```

**Medium Complexity:**
```lua
-- Medium: Use in conditional logic
local targetChar = target:getChar()
local myChar = player:getChar()
if myChar:eq(targetChar) then
    -- Handle self-targeting
end

```

**High Complexity:**
```lua
-- High: Use in character management system
for _, char in pairs(characterList) do
    if char:eq(selectedCharacter) then
        -- Process matching character
        break
    end
end

```

---

### getID

**Purpose**

Retrieves the unique ID of the character

**When Called**

When you need to identify a specific character instance

**Returns**

* number - The character's unique ID

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get character ID
local char = player:getChar()
local charID = char:getID()
print("Character ID: " .. charID)

```

**Medium Complexity:**
```lua
-- Medium: Use ID for database operations
local char = player:getChar()
local charID = char:getID()
lia.db.query("SELECT * FROM chardata WHERE charID = " .. charID)

```

**High Complexity:**
```lua
-- High: Use ID in networking
net.Start("liaCharInfo")
net.WriteUInt(char:getID(), 32)
net.Send(player)

```

---

### getPlayer

**Purpose**

Retrieves the player entity associated with this character

**When Called**

When you need to access the player who owns this character

**Returns**

* Player - The player entity, or nil if not found

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get the player from character
local char = player:getChar()
local owner = char:getPlayer()
if IsValid(owner) then
    print("Player: " .. owner:Name())
end

```

**Medium Complexity:**
```lua
-- Medium: Use player for operations
local char = character:getPlayer()
if IsValid(char) then
    char:SetPos(Vector(0, 0, 0))
end

```

**High Complexity:**
```lua
-- High: Use in networking and validation
local char = character:getPlayer()
if IsValid(char) then
    net.Start("liaCharSync")
    net.WriteEntity(char)
    net.Broadcast()
end

```

---

### getDisplayedName

**Purpose**

Gets the display name for a character based on recognition system

**When Called**

When displaying character names to other players

**Parameters**

* `client` (*Player*): The client who is viewing the character

**Returns**

* string - The name to display (real name, fake name, or "unknown")

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get display name for a player
local char = target:getChar()
local displayName = char:getDisplayedName(player)
print("You see: " .. displayName)

```

**Medium Complexity:**
```lua
-- Medium: Use in chat system
local char = speaker:getChar()
local displayName = char:getDisplayedName(listener)
chat.AddText(Color(255, 255, 255), displayName .. ": " .. message)

```

**High Complexity:**
```lua
-- High: Use in UI display system
local char = character:getDisplayedName(client)
local nameColor = char == "unknown" and Color(128, 128, 128) or Color(255, 255, 255)
draw.SimpleText(char, "DermaDefault", x, y, nameColor)

```

---

### hasMoney

**Purpose**

Checks if the character has enough money for a transaction

**When Called**

Before processing purchases, payments, or money transfers

**Parameters**

* `amount` (*number*): The amount of money to check for

**Returns**

* boolean - True if character has sufficient funds, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player can afford an item
local char = player:getChar()
if char:hasMoney(100) then
    print("Can afford item")
end

```

**Medium Complexity:**
```lua
-- Medium: Use in shop system
local char = buyer:getChar()
local itemPrice = 500
if char:hasMoney(itemPrice) then
    char:takeMoney(itemPrice)
    char:giveItem("item_id")
end

```

**High Complexity:**
```lua
-- High: Use in complex transaction system
local char = player:getChar()
local totalCost = calculateTotalCost(items)
if char:hasMoney(totalCost) then
    processTransaction(char, items, totalCost)
    else
        showInsufficientFundsError(char, totalCost)
    end

```

---

### hasFlags

**Purpose**

Checks if the character has any of the specified flags

**When Called**

When checking permissions or access rights for a character

**Parameters**

* `flagStr` (*string*): String containing flags to check for

**Returns**

* boolean - True if character has any of the specified flags, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check for admin flag
local char = player:getChar()
if char:hasFlags("a") then
    print("Player is admin")
end

```

**Medium Complexity:**
```lua
-- Medium: Check multiple flags
local char = player:getChar()
if char:hasFlags("ad") then
    -- Player has admin or donator flag
    grantSpecialAccess(char)
end

```

**High Complexity:**
```lua
-- High: Use in permission system
local char = player:getChar()
local requiredFlags = "adm"
if char:hasFlags(requiredFlags) then
    showAdminPanel(player)
    else
        showAccessDenied(player)
    end

```

---

### getItemWeapon

**Purpose**

Checks if the character has a weapon item equipped

**When Called**

When validating weapon usage or checking equipped items

**Parameters**

* `requireEquip` (*boolean*): Whether to check if item is equipped (default: true)

**Returns**

* boolean - True if character has the weapon item, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player has weapon
local char = player:getChar()
if char:getItemWeapon() then
    print("Player has weapon")
end

```

**Medium Complexity:**
```lua
-- Medium: Check weapon with equip requirement
local char = player:getChar()
if char:getItemWeapon(true) then
    -- Player has equipped weapon
    allowWeaponUse(char)
end

```

**High Complexity:**
```lua
-- High: Use in weapon validation system
local char = player:getChar()
local hasWeapon = char:getItemWeapon(requireEquip)
if hasWeapon then
    processWeaponAction(char, action)
    else
        showWeaponRequiredError(char)
    end

```

---

### getAttrib

**Purpose**

Gets the value of a character attribute including boosts

**When Called**

When checking character stats or calculating bonuses

**Parameters**

* `key` (*string*): The attribute key to retrieve
* `default` (*number*): Default value if attribute doesn't exist (default: 0)

**Returns**

* number - The attribute value with boosts applied

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get character strength
local char = player:getChar()
local strength = char:getAttrib("str")
print("Strength: " .. strength)

```

**Medium Complexity:**
```lua
-- Medium: Use in skill checks
local char = player:getChar()
local intelligence = char:getAttrib("int", 10)
if intelligence > 15 then
    grantSpecialAbility(char)
end

```

**High Complexity:**
```lua
-- High: Use in complex calculations
local char = player:getChar()
local baseStr = char:getAttrib("str")
local baseInt = char:getAttrib("int")
local totalBonus = baseStr + baseInt
calculateCombatEffectiveness(char, totalBonus)

```

---

### getBoost

**Purpose**

Gets the boost table for a specific attribute

**When Called**

When checking or modifying attribute boosts

**Parameters**

* `attribID` (*string*): The attribute ID to get boosts for

**Returns**

* table - Table containing boost values for the attribute

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
        Medium Complexity:

        High Complexity:

]]
```

---

### doesRecognize

**Purpose**

Checks if the character recognizes another character by ID

**When Called**

When determining if one character knows another character's identity

**Parameters**

* `id` (*number|character*): Character ID or character object to check recognition for

**Returns**

* boolean - True if character recognizes the other, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if player recognizes target
local char = player:getChar()
local targetChar = target:getChar()
if char:doesRecognize(targetChar) then
    print("Player recognizes target")
end

```

**Medium Complexity:**
```lua
-- Medium: Use in recognition system
local char = player:getChar()
local targetID = target:getChar():getID()
if char:doesRecognize(targetID) then
    showRealName(char, target)
    else
        showUnknownName(char, target)
    end

```

**High Complexity:**
```lua
-- High: Use in complex recognition logic
local char = player:getChar()
for _, otherChar in pairs(characterList) do
    if char:doesRecognize(otherChar) then
        addToKnownList(char, otherChar)
    end
end

```

---

### doesFakeRecognize

**Purpose**

Checks if the character has fake recognition of another character

**When Called**

When determining if character knows a fake name for another character

**Parameters**

* `id` (*number|character*): Character ID or character object to check fake recognition for

**Returns**

* boolean - True if character has fake recognition, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check fake recognition
local char = player:getChar()
local targetChar = target:getChar()
if char:doesFakeRecognize(targetChar) then
    print("Player knows fake name")
end

```

**Medium Complexity:**
```lua
-- Medium: Use in disguise system
local char = player:getChar()
local targetID = target:getChar():getID()
if char:doesFakeRecognize(targetID) then
    showFakeName(char, target)
    else
        showUnknownName(char, target)
    end

```

**High Complexity:**
```lua
-- High: Use in complex identity system
local char = player:getChar()
for _, otherChar in pairs(characterList) do
    if char:doesFakeRecognize(otherChar) then
        addToFakeKnownList(char, otherChar)
    end
end

```

---

### setData

**Purpose**

Sets character data and optionally syncs it to database and clients

**When Called**

When storing character-specific data that needs persistence

**Parameters**

* `k` (*string|table*): Key to set or table of key-value pairs
* `v` (*any*): Value to set (ignored if k is table)
* `noReplication` (*boolean*): Skip client replication (default: false)
* `receiver` (*Player*): Specific client to send to (default: character owner)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set single data value
local char = player:getChar()
char:setData("lastLogin", os.time())

```

**Medium Complexity:**
```lua

```

**Char Complexity:**
```lua
High Complexity:

```

**Char Complexity:**
```lua
]]
```

---

### getData

**Purpose**

Retrieves character data by key or returns all data

**When Called**

When accessing stored character-specific data

**Parameters**

* `key` (*string*): The data key to retrieve (optional)
* `default` (*any*): Default value if key doesn't exist (optional)

**Returns**

* any - The data value, all data table, or default value

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Get specific data
local char = player:getChar()
local level = char:getData("level", 1)
print("Level: " .. level)

```

**Medium Complexity:**
```lua
-- Medium: Get all character data
local char = player:getChar()
local allData = char:getData()
for key, value in pairs(allData) do
    print(key .. ": " .. tostring(value))
end

```

**High Complexity:**
```lua
-- High: Use in data processing system
local char = player:getChar()
local inventory = char:getData("inventory", {})
local position = char:getData("position", Vector(0, 0, 0))
processCharacterState(char, inventory, position)

```

---

### isBanned

**Purpose**

Checks if the character is currently banned

**When Called**

When validating character access or checking ban status

**Returns**

* boolean - True if character is banned, false otherwise

**Realm**

Shared

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Check if character is banned
local char = player:getChar()
if char:isBanned() then
    print("Character is banned")
end

```

**Medium Complexity:**
```lua
-- Medium: Use in login validation
local char = player:getChar()
if char:isBanned() then
    player:Kick("Your character is banned")
    return
end

```

**High Complexity:**
```lua
-- High: Use in ban management system
local char = player:getChar()
if char:isBanned() then
    local banTime = char:getBanned()
    local banReason = char:getData("banReason", "No reason provided")
    showBanMessage(player, banTime, banReason)
end

```

---

### recognize

**Purpose**

Makes the character recognize another character (with optional fake name)

**When Called**

When establishing recognition between characters

**Parameters**

* `character` (*number|character*): Character ID or character object to recognize
* `name` (*string*): Optional fake name to assign (default: nil)

**Returns**

* boolean - True if recognition was successful

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Recognize another character
local char = player:getChar()
local targetChar = target:getChar()
char:recognize(targetChar)

```

**Medium Complexity:**
```lua
-- Medium: Recognize with fake name
local char = player:getChar()
local targetID = target:getChar():getID()
char:recognize(targetID, "John Doe")

```

**High Complexity:**
```lua
-- High: Use in recognition system
local char = player:getChar()
for _, otherChar in pairs(characterList) do
    if shouldRecognize(char, otherChar) then
        char:recognize(otherChar, getFakeName(char, otherChar))
    end
end

```

---

### joinClass

**Purpose**

Makes the character join a specific class (faction job)

**When Called**

When changing character class or job within their faction

**Parameters**

* `class` (*string*): The class name to join
* `isForced` (*boolean*): Whether to force the class change (default: false)

**Returns**

* boolean - True if class change was successful, false otherwise

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Join a class
local char = player:getChar()
char:joinClass("citizen")

```

**Medium Complexity:**
```lua
-- Medium: Force class change
local char = player:getChar()
if char:joinClass("police", true) then
    print("Successfully joined police force")
end

```

**High Complexity:**
```lua
-- High: Use in class management system
local char = player:getChar()
local newClass = determineClass(char, player)
if char:joinClass(newClass) then
    updateCharacterUI(player)
    notifyClassChange(player, newClass)
    else
        showClassChangeError(player, newClass)
    end

```

---

### kickClass

**Purpose**

Removes the character from their current class and assigns default class

**When Called**

When removing character from their current job or class

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Kick from class
local char = player:getChar()
char:kickClass()

```

**Medium Complexity:**
```lua
-- Medium: Use in demotion system
local char = player:getChar()
if char:getClass() == "police" then
    char:kickClass()
    notifyDemotion(player)
end

```

**High Complexity:**
```lua
-- High: Use in class management system
local char = player:getChar()
local oldClass = char:getClass()
char:kickClass()
logClassChange(player, oldClass, "none")
updateCharacterPermissions(player)

```

---

### updateAttrib

**Purpose**

Updates a character attribute by adding to the current value

**When Called**

When modifying character stats through gameplay or admin actions

**Parameters**

* `key` (*string*): The attribute key to update
* `value` (*number*): The amount to add to the current attribute value

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Increase strength
local char = player:getChar()
char:updateAttrib("str", 1)

```

**Medium Complexity:**
```lua
-- Medium: Use in level up system
local char = player:getChar()
char:updateAttrib("int", 2)
char:updateAttrib("str", 1)
notifyStatIncrease(player, "int", 2)

```

**High Complexity:**
```lua
-- High: Use in complex attribute system
local char = player:getChar()
local statGains = calculateStatGains(char, experience)
for stat, gain in pairs(statGains) do
    char:updateAttrib(stat, gain)
    logStatChange(player, stat, gain)
end

```

---

### setAttrib

**Purpose**

Sets a character attribute to a specific value

**When Called**

When setting character stats to exact values

**Parameters**

* `key` (*string*): The attribute key to set
* `value` (*number*): The exact value to set the attribute to

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set strength to specific value
local char = player:getChar()
char:setAttrib("str", 10)

```

**Medium Complexity:**
```lua
-- Medium: Use in character creation
local char = player:getChar()
char:setAttrib("str", 5)
char:setAttrib("int", 8)
char:setAttrib("dex", 6)

```

**High Complexity:**
```lua
-- High: Use in admin system
local char = player:getChar()
local newStats = calculateNewStats(char, adminCommand)
for stat, value in pairs(newStats) do
    char:setAttrib(stat, value)
    logAdminAction(admin, "set " .. stat .. " to " .. value)
end

```

---

### addBoost

**Purpose**

Adds a temporary boost to a character attribute

**When Called**

When applying temporary stat bonuses from items, spells, or effects

**Parameters**

* `boostID` (*string*): Unique identifier for this boost
* `attribID` (*string*): The attribute to boost
* `boostAmount` (*number*): The amount to boost the attribute by

**Returns**

* boolean - True if boost was added successfully

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Add strength boost
local char = player:getChar()
char:addBoost("potion_str", "str", 5)

```

**Medium Complexity:**
```lua
-- Medium: Use in item system
local char = player:getChar()
local item = char:getItem("strength_potion")
if item then
    char:addBoost("item_" .. item:getID(), "str", item:getData("boostAmount", 3))
end

```

**High Complexity:**
```lua
-- High: Use in complex boost system
local char = player:getChar()
local boosts = calculateBoosts(char, equipment)
for boostID, boostData in pairs(boosts) do
    char:addBoost(boostID, boostData.attrib, boostData.amount)
end

```

---

### removeBoost

**Purpose**

Removes a temporary boost from a character attribute

**When Called**

When removing temporary stat bonuses from items, spells, or effects

**Parameters**

* `boostID` (*string*): Unique identifier for the boost to remove
* `attribID` (*string*): The attribute the boost was applied to

**Returns**

* boolean - True if boost was removed successfully

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove strength boost
local char = player:getChar()
char:removeBoost("potion_str", "str")

```

**Medium Complexity:**
```lua
-- Medium: Use in item removal
local char = player:getChar()
local item = char:getItem("strength_potion")
if item then
    char:removeBoost("item_" .. item:getID(), "str")
end

```

**High Complexity:**
```lua
-- High: Use in boost cleanup system
local char = player:getChar()
local expiredBoosts = getExpiredBoosts(char)
for boostID, attribID in pairs(expiredBoosts) do
    char:removeBoost(boostID, attribID)
end

```

---

### setFlags

**Purpose**

Sets the character flags to a specific string

**When Called**

When changing character permissions or access rights

**Parameters**

* `flags` (*string*): The flags string to set

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Set admin flags
local char = player:getChar()
char:setFlags("a")

```

**Medium Complexity:**
```lua
-- Medium: Use in permission system
local char = player:getChar()
char:setFlags("ad")
notifyPermissionChange(player, "admin and donator")

```

**High Complexity:**
```lua
-- High: Use in complex permission management
local char = player:getChar()
local newFlags = calculateFlags(char, role, level)
char:setFlags(newFlags)
updateCharacterPermissions(player)
logPermissionChange(admin, player, newFlags)

```

---

### giveFlags

**Purpose**

Adds flags to the character without removing existing ones

**When Called**

When granting additional permissions to a character

**Parameters**

* `flags` (*string*): The flags to add to the character

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Give donator flag
local char = player:getChar()
char:giveFlags("d")

```

**Medium Complexity:**
```lua
-- Medium: Use in reward system
local char = player:getChar()
char:giveFlags("v")
notifyReward(player, "VIP status granted")

```

**High Complexity:**
```lua
-- High: Use in complex permission system
local char = player:getChar()
local earnedFlags = calculateEarnedFlags(char, achievements)
char:giveFlags(earnedFlags)
updateCharacterUI(player)
logFlagGrant(admin, player, earnedFlags)

```

---

### takeFlags

**Purpose**

Removes flags from the character

**When Called**

When revoking permissions or access rights from a character

**Parameters**

* `flags` (*string*): The flags to remove from the character

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Remove admin flag
local char = player:getChar()
char:takeFlags("a")

```

**Medium Complexity:**
```lua
-- Medium: Use in demotion system
local char = player:getChar()
char:takeFlags("a")
notifyDemotion(player, "Admin status revoked")

```

**High Complexity:**
```lua
-- High: Use in complex permission system
local char = player:getChar()
local revokedFlags = calculateRevokedFlags(char, violations)
char:takeFlags(revokedFlags)
updateCharacterUI(player)
logFlagRevoke(admin, player, revokedFlags)

```

---

### save

**Purpose**

Saves the character data to the database

**When Called**

When persisting character changes to the database

**Parameters**

* `callback` (*function*): Optional callback function to execute after save

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Save character
local char = player:getChar()
char:save()

```

**Medium Complexity:**
```lua
-- Medium: Save with callback
local char = player:getChar()
char:save(function()
print("Character saved successfully")
end)

```

**High Complexity:**
```lua
-- High: Use in save system
local char = player:getChar()
char:save(function()
updateCharacterCache(char)
notifySaveComplete(player)
logCharacterSave(char)
end)

```

---

### sync

**Purpose**

Synchronizes character data with clients

**When Called**

When updating character information on client side

**Parameters**

* `receiver` (*Player*): Specific client to sync to (default: all players)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Sync to all players
local char = player:getChar()
char:sync()

```

**Medium Complexity:**
```lua
-- Medium: Sync to specific player
local char = player:getChar()
char:sync(targetPlayer)

```

**High Complexity:**
```lua
-- High: Use in sync system
local char = player:getChar()
char:sync(receiver)
updateCharacterUI(receiver)
logCharacterSync(char, receiver)

```

---

### setup

**Purpose**

Sets up the character for the player (model, team, inventory, etc.)

**When Called**

When loading a character for a player

**Parameters**

* `noNetworking` (*boolean*): Skip networking setup (default: false)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Setup character
local char = player:getChar()
char:setup()

```

**Medium Complexity:**
```lua
-- Medium: Setup without networking
local char = player:getChar()
char:setup(true)

```

**High Complexity:**
```lua
-- High: Use in character loading system
local char = player:getChar()
char:setup(noNetworking)
updateCharacterUI(player)
logCharacterLoad(char)

```

---

### kick

**Purpose**

Kicks the character from the server

**When Called**

When removing a character from the game

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Kick character
local char = player:getChar()
char:kick()

```

**Medium Complexity:**
```lua
-- Medium: Use in admin system
local char = target:getChar()
char:kick()
notifyKick(admin, target)

```

**High Complexity:**
```lua
-- High: Use in complex kick system
local char = player:getChar()
char:kick()
logCharacterKick(char, reason)
updateCharacterList()

```

---

### ban

**Purpose**

Bans the character for a specified time or permanently

**When Called**

When applying a ban to a character

**Parameters**

* `time` (*number*): Ban duration in seconds (nil for permanent ban)

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Ban character permanently
local char = player:getChar()
char:ban()

```

**Medium Complexity:**
```lua
-- Medium: Ban for specific time
local char = player:getChar()
char:ban(3600) -- 1 hour ban

```

**High Complexity:**
```lua
-- High: Use in ban system
local char = player:getChar()
char:ban(banTime)
logCharacterBan(char, banTime, reason)
notifyBan(admin, player, banTime)

```

---

### delete

**Purpose**

Deletes the character from the database

**When Called**

When permanently removing a character

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Delete character
local char = player:getChar()
char:delete()

```

**Medium Complexity:**
```lua
-- Medium: Use in admin system
local char = target:getChar()
char:delete()
notifyDeletion(admin, target)

```

**High Complexity:**
```lua
-- High: Use in complex deletion system
local char = player:getChar()
char:delete()
logCharacterDeletion(char, reason)
updateCharacterList()

```

---

### destroy

**Purpose**

Destroys the character object and removes it from memory

**When Called**

When cleaning up character data from memory

**Returns**

* None

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Destroy character
local char = player:getChar()
char:destroy()

```

**Medium Complexity:**
```lua
-- Medium: Use in cleanup system
local char = player:getChar()
char:destroy()
updateCharacterList()

```

**High Complexity:**
```lua
-- High: Use in complex cleanup system
local char = player:getChar()
char:destroy()
logCharacterDestroy(char)
updateCharacterCache()

```

---

### giveMoney

**Purpose**

Gives money to the character

**When Called**

When adding money to a character's account

**Parameters**

* `amount` (*number*): The amount of money to give

**Returns**

* boolean - True if money was given successfully

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Give money
local char = player:getChar()
char:giveMoney(100)

```

**Medium Complexity:**
```lua
-- Medium: Use in reward system
local char = player:getChar()
char:giveMoney(rewardAmount)
notifyReward(player, "You received $" .. rewardAmount)

```

**High Complexity:**
```lua
-- High: Use in complex economy system
local char = player:getChar()
char:giveMoney(amount)
logMoneyTransaction(char, amount, "reward")
updateEconomyStats()

```

---

### takeMoney

**Purpose**

Takes money from the character

**When Called**

When removing money from a character's account

**Parameters**

* `amount` (*number*): The amount of money to take

**Returns**

* boolean - True if money was taken successfully

**Realm**

Server

**Example Usage**

**Low Complexity:**
```lua
-- Simple: Take money
local char = player:getChar()
char:takeMoney(50)

```

**Medium Complexity:**
```lua
-- Medium: Use in payment system
local char = player:getChar()
char:takeMoney(itemPrice)
notifyPayment(player, "You paid $" .. itemPrice)

```

**High Complexity:**
```lua
-- High: Use in complex economy system
local char = player:getChar()
char:takeMoney(amount)
logMoneyTransaction(char, -amount, "purchase")
updateEconomyStats()

```

---

