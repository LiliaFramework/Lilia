# Character Meta

This page documents methods available on the `Character` meta table, representing player characters in the Lilia framework.

---

## Overview

The `Character` meta table exposes properties and behaviors for character entities, including identity (name, ID), attributes, inventory management, recognition systems, faction/class membership, and gameplay interactions. These methods are the foundation for character-centric logic such as attribute management, inventory access, recognition handling, faction checks, and networked state synchronization.

---


### eq

**Purpose**

Checks if this character is equal to another character by comparing their IDs.

**Parameters**

* `other` (*Character*): The other character to compare.

**Returns**

* `boolean`: `true` if characters have the same ID, `false` otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function areCharactersEqual(char1, char2)
    if char1:eq(char2) then
        print("Same character")
        return true
    else
        print("Different characters")
        return false
    end
end
```

---

### getID

**Purpose**

Returns the character's unique identifier.

**Parameters**

*None.*

**Returns**

* `id` (*number*): The character's unique ID.

**Realm**

Shared.

**Example Usage**

```lua
local function logCharacterAction(character, action)
    local charID = character:getID()
    print("[CHARACTER] " .. action .. " for character ID: " .. charID)
end

hook.Add("OnCharacterCreated", "LogCharacterCreation", function(character)
    logCharacterAction(character, "created")
end)
```

---

### getPlayer

**Purpose**

Returns the player entity associated with this character.

**Parameters**

*None.*

**Returns**

* `player` (*Player|nil*): The player entity if found, otherwise nil.

**Realm**

Shared.

**Example Usage**

```lua
local function checkCharacterOnline(character)
    local player = character:getPlayer()
    if IsValid(player) then
        print("Character " .. character:getID() .. " is online as " .. player:Name())
        return true
    else
        print("Character " .. character:getID() .. " is offline")
        return false
    end
end

hook.Add("Think", "CheckCharacterStatus", function()
    for _, char in pairs(lia.char.instances) do
        checkCharacterOnline(char)
    end
end)
```

---

### getDisplayedName

**Purpose**

Returns the name that should be displayed for this character, considering recognition settings.

**Parameters**

* `client` (*Player*): The client requesting the display name.

**Returns**

* `name` (*string*): The display name for the character.

**Realm**

Shared.

**Example Usage**

```lua
local function showCharacterInfo(client, character)
    local displayName = character:getDisplayedName(client)
    client:ChatPrint("You see: " .. displayName)
end

hook.Add("PlayerSay", "ShowCharacterInfo", function(ply, text)
    if text == "!who" then
        local target = ply:getTracedEntity()
        if IsValid(target) and target:IsPlayer() then
            local char = target:getChar()
            if char then
                showCharacterInfo(ply, char)
            end
        end
    end
end)
```

---

### hasMoney

**Purpose**

Checks if the character has at least the specified amount of money.

**Parameters**

* `amount` (*number*): The amount to check for.

**Returns**

* `hasMoney` (*boolean*): True if the character has enough money, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function canAffordItem(character, price)
    if character:hasMoney(price) then
        character:getPlayer():ChatPrint("You can afford this item!")
        return true
    else
        character:getPlayer():ChatPrint("You don't have enough money.")
        return false
    end
end

hook.Add("OnVendorItemPurchase", "CheckAffordability", function(vendor, item, character)
    local price = item:getPrice()
    canAffordItem(character, price)
end)
```

---

### hasFlags

**Purpose**

Checks if the character has any of the specified flags.

**Parameters**

* `flagStr` (*string*): String containing flags to check for.

**Returns**

* `hasFlags` (*boolean*): True if the character has any of the flags, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function checkAdminAccess(character)
    if character:hasFlags("a") then
        character:getPlayer():ChatPrint("You have admin access!")
        return true
    else
        character:getPlayer():ChatPrint("You need admin flags to access this.")
        return false
    end
end

concommand.Add("check_admin", function(ply)
    local char = ply:getChar()
    if char then
        checkAdminAccess(char)
    end
end)
```

---

### getItemWeapon

**Purpose**

Checks if the character has a weapon item equipped and returns whether it's valid.

**Parameters**

* `requireEquip` (*boolean|nil*): Whether to require the weapon to be equipped (default: true).

**Returns**

* `hasWeapon` (*boolean*): True if the character has a valid equipped weapon item.

**Realm**

Shared.

**Example Usage**

```lua
local function checkWeaponItem(character)
    local hasWeapon = character:getItemWeapon(true)
    if hasWeapon then
        character:getPlayer():ChatPrint("You have a valid weapon item equipped!")
    else
        character:getPlayer():ChatPrint("You need to equip a weapon item.")
    end
end

hook.Add("PlayerSpawn", "CheckWeaponItem", function(ply)
    local char = ply:getChar()
    if char then
        checkWeaponItem(char)
    end
end)
```

---

### getMaxStamina

**Purpose**

Returns the character's maximum stamina value.

**Parameters**

*None.*

**Returns**

* `maxStamina` (*number*): The character's maximum stamina.

**Realm**

Shared.

**Example Usage**

```lua
local function displayStaminaInfo(character)
    local maxStamina = character:getMaxStamina()
    local currentStamina = character:getStamina()
    local player = character:getPlayer()
    
    if IsValid(player) then
        player:ChatPrint("Stamina: " .. currentStamina .. "/" .. maxStamina)
    end
end

concommand.Add("stamina_info", function(ply)
    local char = ply:getChar()
    if char then
        displayStaminaInfo(char)
    end
end)
```

---

### getStamina

**Purpose**

Returns the character's current stamina value.

**Parameters**

*None.*

**Returns**

* `stamina` (*number*): The character's current stamina.

**Realm**

Shared.

**Example Usage**

```lua
local function checkStaminaForAction(character, requiredStamina)
    local currentStamina = character:getStamina()
    if currentStamina >= requiredStamina then
        character:getPlayer():ChatPrint("You have enough stamina for this action.")
        return true
    else
        character:getPlayer():ChatPrint("You're too tired for this action.")
        return false
    end
end

hook.Add("OnPlayerInteract", "CheckStamina", function(ply, entity)
    local char = ply:getChar()
    if char then
        checkStaminaForAction(char, 20)
    end
end)
```

---

### hasClassWhitelist

**Purpose**

Checks if the character has whitelist access to a specific class.

**Parameters**

* `class` (*string*): The class name to check.

**Returns**

* `hasWhitelist` (*boolean*): True if the character has whitelist access to the class.

**Realm**

Shared.

**Example Usage**

```lua
local function checkClassAccess(character, className)
    if character:hasClassWhitelist(className) then
        character:getPlayer():ChatPrint("You have access to the " .. className .. " class!")
        return true
    else
        character:getPlayer():ChatPrint("You don't have access to the " .. className .. " class.")
        return false
    end
end

concommand.Add("check_class", function(ply, cmd, args)
    local char = ply:getChar()
    local className = args[1]
    if char and className then
        checkClassAccess(char, className)
    end
end)
```

---

### isFaction

**Purpose**

Checks if the character belongs to a specific faction.

**Parameters**

* `faction` (*string*): The faction name to check.

**Returns**

* `isFaction` (*boolean*): True if the character belongs to the faction.

**Realm**

Shared.

**Example Usage**

```lua
local function checkFactionAccess(character, requiredFaction)
    if character:isFaction(requiredFaction) then
        character:getPlayer():ChatPrint("You belong to the " .. requiredFaction .. " faction!")
        return true
    else
        character:getPlayer():ChatPrint("You don't belong to the " .. requiredFaction .. " faction.")
        return false
    end
end

hook.Add("OnPlayerUse", "CheckFactionAccess", function(ply, entity)
    local char = ply:getChar()
    if char and entity:GetClass() == "func_door" then
        checkFactionAccess(char, "police")
    end
end)
```

---

### isClass

**Purpose**

Checks if the character belongs to a specific class.

**Parameters**

* `class` (*string*): The class name to check.

**Returns**

* `isClass` (*boolean*): True if the character belongs to the class.

**Realm**

Shared.

**Example Usage**

```lua
local function checkClassMembership(character, className)
    if character:isClass(className) then
        character:getPlayer():ChatPrint("You are a " .. className .. "!")
        return true
    else
        character:getPlayer():ChatPrint("You are not a " .. className .. ".")
        return false
    end
end

concommand.Add("my_class", function(ply)
    local char = ply:getChar()
    if char then
        local currentClass = char:getClass()
        if currentClass then
            checkClassMembership(char, currentClass)
        end
    end
end)
```

---

### getAttrib

**Purpose**

Returns the character's attribute value, including any boosts.

**Parameters**

* `key` (*string*): The attribute key to get.
* `default` (*number|nil*): Default value if attribute doesn't exist.

**Returns**

* `value` (*number*): The attribute value including boosts.

**Realm**

Shared.

**Example Usage**

```lua
local function displayAttribute(character, attributeName)
    local value = character:getAttrib(attributeName, 0)
    local player = character:getPlayer()
    
    if IsValid(player) then
        player:ChatPrint(attributeName .. ": " .. value)
    end
end

concommand.Add("check_attrib", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    if char and attribName then
        displayAttribute(char, attribName)
    end
end)
```

---

### getBoost

**Purpose**

Returns the boost data for a specific attribute.

**Parameters**

* `attribID` (*string*): The attribute ID to get boosts for.

**Returns**

* `boosts` (*table|nil*): Table of boosts for the attribute, or nil if none.

**Realm**

Shared.

**Example Usage**

```lua
local function displayAttributeBoosts(character, attributeName)
    local boosts = character:getBoost(attributeName)
    local player = character:getPlayer()
    
    if IsValid(player) then
        if boosts then
            player:ChatPrint("Boosts for " .. attributeName .. ":")
            for boostID, amount in pairs(boosts) do
                player:ChatPrint("  " .. boostID .. ": +" .. amount)
            end
        else
            player:ChatPrint("No boosts for " .. attributeName)
        end
    end
end

concommand.Add("check_boosts", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    if char and attribName then
        displayAttributeBoosts(char, attribName)
    end
end)
```

---

### getBoosts

**Purpose**

Returns all attribute boosts for the character.

**Parameters**

*None.*

**Returns**

* `boosts` (*table*): Table containing all attribute boosts.

**Realm**

Shared.

**Example Usage**

```lua
local function displayAllBoosts(character)
    local boosts = character:getBoosts()
    local player = character:getPlayer()
    
    if IsValid(player) then
        player:ChatPrint("All attribute boosts:")
        for attribID, attribBoosts in pairs(boosts) do
            player:ChatPrint(attribID .. ":")
            for boostID, amount in pairs(attribBoosts) do
                player:ChatPrint("  " .. boostID .. ": +" .. amount)
            end
        end
    end
end

concommand.Add("all_boosts", function(ply)
    local char = ply:getChar()
    if char then
        displayAllBoosts(char)
    end
end)
```

---

### doesRecognize

**Purpose**

Checks if the character recognizes another character by ID.

**Parameters**

* `id` (*number|Character*): The character ID or character object to check.

**Returns**

* `recognizes` (*boolean*): True if the character recognizes the other character.

**Realm**

Shared.

**Example Usage**

```lua
local function checkRecognition(character, targetCharacter)
    local targetID = targetCharacter:getID()
    if character:doesRecognize(targetID) then
        character:getPlayer():ChatPrint("You recognize this person!")
        return true
    else
        character:getPlayer():ChatPrint("You don't recognize this person.")
        return false
    end
end

hook.Add("PlayerSay", "CheckRecognition", function(ply, text)
    if text == "!recognize" then
        local target = ply:getTracedEntity()
        if IsValid(target) and target:IsPlayer() then
            local char = ply:getChar()
            local targetChar = target:getChar()
            if char and targetChar then
                checkRecognition(char, targetChar)
            end
        end
    end
end)
```

---

### doesFakeRecognize

**Purpose**

Checks if the character has fake recognition of another character by ID.

**Parameters**

* `id` (*number|Character*): The character ID or character object to check.

**Returns**

* `fakeRecognizes` (*boolean*): True if the character has fake recognition of the other character.

**Realm**

Shared.

**Example Usage**

```lua
local function checkFakeRecognition(character, targetCharacter)
    local targetID = targetCharacter:getID()
    if character:doesFakeRecognize(targetID) then
        character:getPlayer():ChatPrint("You have fake recognition of this person!")
        return true
    else
        character:getPlayer():ChatPrint("You don't have fake recognition of this person.")
        return false
    end
end

concommand.Add("check_fake_recognition", function(ply, cmd, args)
    local char = ply:getChar()
    local targetID = tonumber(args[1])
    if char and targetID then
        local targetChar = lia.char.getCharacter(targetID)
        if targetChar then
            checkFakeRecognition(char, targetChar)
        end
    end
end)
```

---

### setData

**Purpose**

Sets character data and handles networking and database persistence.

**Parameters**

* `k` (*string|table*): The key to set, or table of key-value pairs.
* `v` (*any*): The value to set (ignored if k is a table).
* `noReplication` (*boolean|nil*): Whether to skip network replication.
* `receiver` (*Player|nil*): Specific player to send data to.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setCharacterCustomData(character, key, value)
    character:setData(key, value)
    character:getPlayer():ChatPrint("Set " .. key .. " to " .. tostring(value))
end

concommand.Add("set_char_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    local value = args[2]
    if char and key and value then
        setCharacterCustomData(char, key, value)
    end
end)
```

---

### getData

**Purpose**

Gets character data by key, with optional default value.

**Parameters**

* `key` (*string|nil*): The key to get, or nil for all data.
* `default` (*any*): Default value if key doesn't exist.

**Returns**

* `value` (*any*): The data value or default.

**Realm**

Shared.

**Example Usage**

```lua
local function getCharacterCustomData(character, key)
    local value = character:getData(key, "not set")
    local player = character:getPlayer()
    
    if IsValid(player) then
        player:ChatPrint(key .. ": " .. tostring(value))
    end
end

concommand.Add("get_char_data", function(ply, cmd, args)
    local char = ply:getChar()
    local key = args[1]
    if char and key then
        getCharacterCustomData(char, key)
    end
end)
```

---

### isBanned

**Purpose**

Checks if the character is currently banned.

**Parameters**

*None.*

**Returns**

* `isBanned` (*boolean*): True if the character is banned, false otherwise.

**Realm**

Shared.

**Example Usage**

```lua
local function checkCharacterBanStatus(character)
    if character:isBanned() then
        character:getPlayer():ChatPrint("This character is banned!")
        return true
    else
        character:getPlayer():ChatPrint("This character is not banned.")
        return false
    end
end

concommand.Add("check_ban", function(ply)
    local char = ply:getChar()
    if char then
        checkCharacterBanStatus(char)
    end
end)
```

---

### recognize

**Purpose**

Makes the character recognize another character, optionally with a custom name.

**Parameters**

* `character` (*number|Character*): The character ID or character object to recognize.
* `name` (*string|nil*): Optional custom name for fake recognition.

**Returns**

* `success` (*boolean*): True if recognition was successful.

**Realm**

Server.

**Example Usage**

```lua
local function makeCharacterRecognize(character, targetCharacter, customName)
    if character:recognize(targetCharacter, customName) then
        character:getPlayer():ChatPrint("You now recognize this person!")
        if customName then
            character:getPlayer():ChatPrint("You know them as: " .. customName)
        end
    end
end

concommand.Add("recognize_player", function(ply, cmd, args)
    local char = ply:getChar()
    local targetID = tonumber(args[1])
    local customName = args[2]
    
    if char and targetID then
        local targetChar = lia.char.getCharacter(targetID)
        if targetChar then
            makeCharacterRecognize(char, targetChar, customName)
        end
    end
end)
```

---

### classWhitelist

**Purpose**

Adds a class to the character's whitelist.

**Parameters**

* `class` (*string*): The class name to whitelist.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function whitelistClassForCharacter(character, className)
    character:classWhitelist(className)
    character:getPlayer():ChatPrint("You now have access to the " .. className .. " class!")
end

concommand.Add("whitelist_class", function(ply, cmd, args)
    local char = ply:getChar()
    local className = args[1]
    if char and className then
        whitelistClassForCharacter(char, className)
    end
end)
```

---

### classUnWhitelist

**Purpose**

Removes a class from the character's whitelist.

**Parameters**

* `class` (*string*): The class name to remove from whitelist.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function unwhitelistClassForCharacter(character, className)
    character:classUnWhitelist(className)
    character:getPlayer():ChatPrint("You no longer have access to the " .. className .. " class.")
end

concommand.Add("unwhitelist_class", function(ply, cmd, args)
    local char = ply:getChar()
    local className = args[1]
    if char and className then
        unwhitelistClassForCharacter(char, className)
    end
end)
```

---

### joinClass

**Purpose**

Makes the character join a specific class.

**Parameters**

* `class` (*string*): The class name to join.
* `isForced` (*boolean|nil*): Whether to force the class change.

**Returns**

* `success` (*boolean*): True if the character successfully joined the class.

**Realm**

Server.

**Example Usage**

```lua
local function changeCharacterClass(character, className)
    if character:joinClass(className) then
        character:getPlayer():ChatPrint("You joined the " .. className .. " class!")
    else
        character:getPlayer():ChatPrint("Failed to join the " .. className .. " class.")
    end
end

concommand.Add("join_class", function(ply, cmd, args)
    local char = ply:getChar()
    local className = args[1]
    if char and className then
        changeCharacterClass(char, className)
    end
end)
```

---

### kickClass

**Purpose**

Removes the character from their current class and assigns a default class.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function removeCharacterFromClass(character)
    character:kickClass()
    character:getPlayer():ChatPrint("You have been removed from your class.")
end

concommand.Add("kick_class", function(ply)
    local char = ply:getChar()
    if char then
        removeCharacterFromClass(char)
    end
end)
```

---

### updateAttrib

**Purpose**

Updates a character's attribute by adding a value to the current level.

**Parameters**

* `key` (*string*): The attribute key to update.
* `value` (*number*): The value to add to the current attribute level.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function increaseCharacterAttribute(character, attributeName, amount)
    character:updateAttrib(attributeName, amount)
    local newValue = character:getAttrib(attributeName, 0)
    character:getPlayer():ChatPrint(attributeName .. " increased to " .. newValue)
end

concommand.Add("increase_attrib", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    local amount = tonumber(args[2])
    if char and attribName and amount then
        increaseCharacterAttribute(char, attribName, amount)
    end
end)
```

---

### setAttrib

**Purpose**

Sets a character's attribute to a specific value.

**Parameters**

* `key` (*string*): The attribute key to set.
* `value` (*number*): The value to set the attribute to.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setCharacterAttribute(character, attributeName, value)
    character:setAttrib(attributeName, value)
    character:getPlayer():ChatPrint(attributeName .. " set to " .. value)
end

concommand.Add("set_attrib", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    local value = tonumber(args[2])
    if char and attribName and value then
        setCharacterAttribute(char, attribName, value)
    end
end)
```

---

### addBoost

**Purpose**

Adds a boost to a character's attribute.

**Parameters**

* `boostID` (*string*): Unique identifier for the boost.
* `attribID` (*string*): The attribute to boost.
* `boostAmount` (*number*): The amount to boost the attribute by.

**Returns**

* `success` (*boolean*): True if the boost was added successfully.

**Realm**

Server.

**Example Usage**

```lua
local function addAttributeBoost(character, attributeName, boostID, amount)
    if character:addBoost(boostID, attributeName, amount) then
        character:getPlayer():ChatPrint("Added " .. amount .. " boost to " .. attributeName)
    else
        character:getPlayer():ChatPrint("Failed to add boost to " .. attributeName)
    end
end

concommand.Add("add_boost", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    local boostID = args[2]
    local amount = tonumber(args[3])
    if char and attribName and boostID and amount then
        addAttributeBoost(char, attribName, boostID, amount)
    end
end)
```

---

### removeBoost

**Purpose**

Removes a boost from a character's attribute.

**Parameters**

* `boostID` (*string*): The boost identifier to remove.
* `attribID` (*string*): The attribute to remove the boost from.

**Returns**

* `success` (*boolean*): True if the boost was removed successfully.

**Realm**

Server.

**Example Usage**

```lua
local function removeAttributeBoost(character, attributeName, boostID)
    if character:removeBoost(boostID, attributeName) then
        character:getPlayer():ChatPrint("Removed boost " .. boostID .. " from " .. attributeName)
    else
        character:getPlayer():ChatPrint("Failed to remove boost from " .. attributeName)
    end
end

concommand.Add("remove_boost", function(ply, cmd, args)
    local char = ply:getChar()
    local attribName = args[1]
    local boostID = args[2]
    if char and attribName and boostID then
        removeAttributeBoost(char, attribName, boostID)
    end
end)
```

---

### setFlags

**Purpose**

Sets the character's flags and handles networking and callbacks.

**Parameters**

* `flags` (*string*): The flags string to set.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setCharacterFlags(character, flags)
    character:setFlags(flags)
    character:getPlayer():ChatPrint("Flags set to: " .. flags)
end

concommand.Add("set_char_flags", function(ply, cmd, args)
    local char = ply:getChar()
    local flags = args[1]
    if char and flags then
        setCharacterFlags(char, flags)
    end
end)
```

---

### giveFlags

**Purpose**

Adds flags to the character's existing flags.

**Parameters**

* `flags` (*string*): The flags to add.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function giveCharacterFlags(character, flags)
    character:giveFlags(flags)
    character:getPlayer():ChatPrint("Added flags: " .. flags)
end

concommand.Add("give_char_flags", function(ply, cmd, args)
    local char = ply:getChar()
    local flags = args[1]
    if char and flags then
        giveCharacterFlags(char, flags)
    end
end)
```

---

### takeFlags

**Purpose**

Removes flags from the character's existing flags.

**Parameters**

* `flags` (*string*): The flags to remove.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function takeCharacterFlags(character, flags)
    character:takeFlags(flags)
    character:getPlayer():ChatPrint("Removed flags: " .. flags)
end

concommand.Add("take_char_flags", function(ply, cmd, args)
    local char = ply:getChar()
    local flags = args[1]
    if char and flags then
        takeCharacterFlags(char, flags)
    end
end)
```

---

### save

**Purpose**

Saves the character data to the database.

**Parameters**

* `callback` (*function|nil*): Optional callback function to call after saving.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function saveCharacterData(character)
    character:save(function()
        character:getPlayer():ChatPrint("Character data saved successfully!")
    end)
end

concommand.Add("save_char", function(ply)
    local char = ply:getChar()
    if char then
        saveCharacterData(char)
    end
end)
```

---

### sync

**Purpose**

Synchronizes character data with clients.

**Parameters**

* `receiver` (*Player|nil*): Specific player to sync with, or nil for all players.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function syncCharacterToPlayer(character, targetPlayer)
    character:sync(targetPlayer)
    targetPlayer:ChatPrint("Character data synchronized!")
end

concommand.Add("sync_char", function(ply, cmd, args)
    local char = ply:getChar()
    local targetID = tonumber(args[1])
    if char and targetID then
        local targetPlayer = player.GetByID(targetID)
        if IsValid(targetPlayer) then
            syncCharacterToPlayer(char, targetPlayer)
        end
    end
end)
```

---

### setup

**Purpose**

Sets up the character for the player, including model, team, and networking.

**Parameters**

* `noNetworking` (*boolean|nil*): Whether to skip networking setup.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function setupCharacterForPlayer(character)
    character:setup()
    character:getPlayer():ChatPrint("Character setup complete!")
end

hook.Add("PlayerSpawn", "SetupCharacter", function(ply)
    local char = ply:getChar()
    if char then
        setupCharacterForPlayer(char)
    end
end)
```

---

### kick

**Purpose**

Kicks the character from the server.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function kickCharacter(character)
    character:kick()
    print("Character " .. character:getID() .. " has been kicked.")
end

concommand.Add("kick_char", function(ply, cmd, args)
    local charID = tonumber(args[1])
    if charID then
        local char = lia.char.getCharacter(charID)
        if char then
            kickCharacter(char)
        end
    end
end)
```

---

### ban

**Purpose**

Bans the character for a specified duration.

**Parameters**

* `time` (*number|nil*): Ban duration in seconds, or nil for permanent ban.

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function banCharacter(character, duration, reason)
    character:ban(duration)
    print("Character " .. character:getID() .. " banned for " .. (duration or "permanent") .. " seconds. Reason: " .. (reason or "No reason"))
end

concommand.Add("ban_char", function(ply, cmd, args)
    local charID = tonumber(args[1])
    local duration = tonumber(args[2])
    local reason = args[3]
    if charID then
        local char = lia.char.getCharacter(charID)
        if char then
            banCharacter(char, duration, reason)
        end
    end
end)
```

---

### delete

**Purpose**

Deletes the character from the database.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function deleteCharacter(character)
    character:delete()
    print("Character " .. character:getID() .. " has been deleted.")
end

concommand.Add("delete_char", function(ply, cmd, args)
    local charID = tonumber(args[1])
    if charID then
        local char = lia.char.getCharacter(charID)
        if char then
            deleteCharacter(char)
        end
    end
end)
```

---

### destroy

**Purpose**

Destroys the character instance and removes it from memory.

**Parameters**

*None.*

**Returns**

*None.*

**Realm**

Server.

**Example Usage**

```lua
local function destroyCharacter(character)
    character:destroy()
    print("Character " .. character:getID() .. " has been destroyed.")
end

concommand.Add("destroy_char", function(ply, cmd, args)
    local charID = tonumber(args[1])
    if charID then
        local char = lia.char.getCharacter(charID)
        if char then
            destroyCharacter(char)
        end
    end
end)
```

---

### giveMoney

**Purpose**

Gives money to the character.

**Parameters**

* `amount` (*number*): The amount of money to give.

**Returns**

* `success` (*boolean*): True if the money was given successfully.

**Realm**

Server.

**Example Usage**

```lua
local function giveCharacterMoney(character, amount)
    if character:giveMoney(amount) then
        character:getPlayer():ChatPrint("You received " .. amount .. " money!")
    else
        character:getPlayer():ChatPrint("Failed to give money.")
    end
end

concommand.Add("give_money", function(ply, cmd, args)
    local char = ply:getChar()
    local amount = tonumber(args[1])
    if char and amount then
        giveCharacterMoney(char, amount)
    end
end)
```

---

### takeMoney

**Purpose**

Takes money from the character.

**Parameters**

* `amount` (*number*): The amount of money to take.

**Returns**

* `success` (*boolean*): True if the money was taken successfully.

**Realm**

Server.

**Example Usage**

```lua
local function takeCharacterMoney(character, amount)
    if character:takeMoney(amount) then
        character:getPlayer():ChatPrint("You lost " .. amount .. " money!")
    else
        character:getPlayer():ChatPrint("Failed to take money.")
    end
end

concommand.Add("take_money", function(ply, cmd, args)
    local char = ply:getChar()
    local amount = tonumber(args[1])
    if char and amount then
        takeCharacterMoney(char, amount)
    end
end)
```

---
