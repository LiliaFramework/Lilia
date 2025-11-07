# Character Library

Comprehensive character creation, management, and persistence system for the Lilia framework.

---

Overview

The character library provides comprehensive functionality for managing player characters in the Lilia framework. It handles character creation, loading, saving, and management across both server and client sides. The library operates character data persistence, networking synchronization, and provides hooks for character variable changes. It includes functions for character validation, database operations, inventory management, and character lifecycle management. The library ensures proper character data integrity and provides a robust system for character-based gameplay mechanics including factions, attributes, money, and custom character variables.

---

### lia.char.getCharacter

#### 📋 Purpose
Retrieves a character by its ID, loading it if necessary

#### ⏰ When Called
When a character needs to be accessed by ID, either from server or client

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character |
| `client` | **Player** | The player requesting the character (optional) |
| `callback` | **function** | Function to call when character is loaded (optional) |

#### ↩️ Returns
* Character object if found/loaded, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get a character by ID
    local character = lia.char.getCharacter(123)
    if character then
        print("Character name:", character:getName())
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get character with callback for async loading
    lia.char.getCharacter(123, client, function(character)
        if character then
            character:setMoney(1000)
            print("Character loaded:", character:getName())
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Get multiple characters with validation and error handling
    local charIDs = {123, 456, 789}
    local loadedChars = {}
    for _, charID in ipairs(charIDs) do
        lia.char.getCharacter(charID, client, function(character)
            if character then
                loadedChars[charID] = character
                if table.Count(loadedChars) == #charIDs then
                    print("All characters loaded successfully")
                end
            else
                print("Failed to load character:", charID)
            end
        end)
    end

```

---

### lia.char.getAll

#### 📋 Purpose
Retrieves all currently loaded characters from all players

#### ⏰ When Called
When you need to iterate through all active characters on the server

#### ↩️ Returns
* Table with Player objects as keys and their Character objects as values

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all characters and count them
    local allChars = lia.char.getAll()
    print("Total active characters:", table.Count(allChars))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find characters by faction
    local allChars = lia.char.getAll()
    local citizenChars = {}
    for player, character in pairs(allChars) do
        if character:getFaction() == "Citizen" then
            citizenChars[player] = character
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Process all characters with validation and statistics
    local allChars = lia.char.getAll()
    local stats = {
        totalChars = 0,
        totalMoney = 0,
        factions  = {}
    }
    for player, character in pairs(allChars) do
        if IsValid(player) and character then
            stats.totalChars = stats.totalChars + 1
            stats.totalMoney = stats.totalMoney + character:getMoney()
            local faction = character:getFaction()
            stats.factions[faction] = (stats.factions[faction] or 0) + 1
        end
    end

```

---

### lia.char.isLoaded

#### 📋 Purpose
Checks if a character with the given ID is currently loaded in memory

#### ⏰ When Called
Before attempting to access a character to avoid unnecessary loading

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character to check |

#### ↩️ Returns
* Boolean - true if character is loaded, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if character is loaded
    if lia.char.isLoaded(123) then
        print("Character 123 is loaded")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Conditional character access
    local charID = 123
    if lia.char.isLoaded(charID) then
        local character = lia.char.getCharacter(charID)
        character:setMoney(5000)
    else
        print("Character not loaded, loading...")
        lia.char.getCharacter(charID, client, function(char)
            if char then char:setMoney(5000) end
        end)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character loading with status checking
    local charIDs = {123, 456, 789}
    local loadedChars = {}
    local unloadedChars = {}
    for _, charID in ipairs(charIDs) do
        if lia.char.isLoaded(charID) then
            loadedChars[charID] = lia.char.getCharacter(charID)
        else
            table.insert(unloadedChars, charID)
        end
    end
    print("Loaded:", table.Count(loadedChars), "Unloaded:", #unloadedChars)

```

---

### lia.char.addCharacter

#### 📋 Purpose
Adds a character to the loaded characters cache and triggers pending callbacks

#### ⏰ When Called
When a character is loaded from database or created, to make it available in memory

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique identifier of the character |
| `character` | **Character** | The character object to add to cache |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a character to cache
    local character = lia.char.new(charData, 123, client)
    lia.char.addCharacter(123, character)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add character and handle pending requests
    local charID = 123
    local character = lia.char.new(charData, charID, client)
    -- This will trigger any pending callbacks for this character ID
    lia.char.addCharacter(charID, character)
    -- Check if there were pending requests
    if lia.char.pendingRequests[charID] then
        print("Character had pending requests that were triggered")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character loading with callback management
    local characters = {}
    local charIDs = {123, 456, 789}
    for _, charID in ipairs(charIDs) do
        local charData = lia.char.getCharData(charID)
        if charData then
            local character = lia.char.new(charData, charID, client)
            characters[charID] = character
            lia.char.addCharacter(charID, character)
        end
    end
    print("Loaded", table.Count(characters), "characters into cache")

```

---

### lia.char.removeCharacter

#### 📋 Purpose
Removes a character from the loaded characters cache

#### ⏰ When Called
When a character needs to be unloaded from memory (cleanup, deletion, etc.)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique identifier of the character to remove |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Remove character from cache
    lia.char.removeCharacter(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Remove character with validation
    local charID = 123
    if lia.char.isLoaded(charID) then
        local character = lia.char.getCharacter(charID)
        if character then
            character:save() -- Save before removing
            lia.char.removeCharacter(charID)
            print("Character", charID, "removed from cache")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character cleanup with error handling
    local charIDs = {123, 456, 789}
    local removedCount = 0
    for _, charID in ipairs(charIDs) do
        if lia.char.isLoaded(charID) then
            local character = lia.char.getCharacter(charID)
            if character then
                -- Perform cleanup operations
                character:save()
                lia.inventory.cleanUpForCharacter(character)
                lia.char.removeCharacter(charID)
                removedCount = removedCount + 1
            end
        end
    end
    print("Removed", removedCount, "characters from cache")

```

---

### lia.char.new

#### 📋 Purpose
Creates a new character object from data with proper metatable and variable initialization

#### ⏰ When Called
When creating a new character instance from database data or character creation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **table** | Character data containing all character variables |
| `id` | **number** | The unique identifier for the character (optional) |
| `client` | **Player** | The player who owns this character (optional) |
| `steamID` | **string** | Steam ID of the character owner (optional, used when client is invalid) |

#### ↩️ Returns
* Character object with proper metatable and initialized variables

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a basic character
    local charData = {
        name    = "John Doe",
        desc    = "A citizen of the city",
        faction = "Citizen",
        model   = "models/player/Group01/male_01.mdl"
    }
    local character = lia.char.new(charData, 123, client)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create character with full data and validation
    local charData = {
        name    = "Jane Smith",
        desc    = "A skilled engineer",
        faction = "Engineer",
        model   = "models/player/Group01/female_01.mdl",
        money   = 1000,
        attribs = {strength = 5, intelligence = 8}
    }
    local character = lia.char.new(charData, 456, client)
    if character then
        character:setSkin(1)
        character:setBodygroups({[0] = 1, [1] = 2})
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create character from database with error handling
    local charID = 789
    local charData = lia.char.getCharData(charID)
    if charData then
        -- Validate required fields
        if not charData.name or not charData.faction then
            print("Invalid character data for ID:", charID)
            return
        end
        -- Create character with fallback SteamID
        local steamID = client and client:SteamID() or "STEAM_0:0:0"
        local character = lia.char.new(charData, charID, client, steamID)
        if character then
            -- Initialize additional data
            character.vars.inv = {}
            character.vars.loginTime = os.time()
            lia.char.addCharacter(charID, character)
        end
    end

```

---

### lia.char.hookVar

#### 📋 Purpose
Registers a hook function for a specific character variable

#### ⏰ When Called
When you need to add custom behavior when a character variable changes

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `varName` | **string** | The name of the character variable to hook |
| `hookName` | **string** | The name/identifier for this hook |
| `func` | **function** | The function to call when the variable changes |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Hook a variable change
    lia.char.hookVar("money", "onMoneyChange", function(character, oldValue, newValue)
        print("Money changed from", oldValue, "to", newValue)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Hook with validation and side effects
    lia.char.hookVar("faction", "onFactionChange", function(character, oldValue, newValue)
        local client = character:getPlayer()
        if IsValid(client) then
            -- Update player team
            client:SetTeam(lia.faction.indices[newValue].index)
            -- Notify player
            client:notify("Faction changed to: " .. newValue)
            -- Log the change
            lia.log.add("Faction change: " .. client:Name() .. " changed faction from " .. oldValue .. " to " .. newValue)
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Multiple hooks with complex logic
    local hooks = {
        money = function(character, oldValue, newValue)
            local client = character:getPlayer()
            if IsValid(client) then
                local difference = newValue - oldValue
                if difference > 0 then
                    client:notify("Gained $" .. difference)
                elseif difference < 0 then
                    client:notify("Lost $" .. math.abs(difference))
                end
                -- Update HUD if it exists
                if client.liaHUD then
                    client.liaHUD:updateMoney(newValue)
                end
            end
        end,
        health = function(character, oldValue, newValue)
            if newValue <= 0 and oldValue > 0 then
                hook.Run("OnCharacterDeath", character)
            elseif newValue > 0 and oldValue <= 0 then
                hook.Run("OnCharacterRevive", character)
            end
        end
    }
    for varName, hookFunc in pairs(hooks) do
        lia.char.hookVar(varName, "customHook_" .. varName, hookFunc)
    end

```

---

### lia.char.registerVar

#### 📋 Purpose
Registers a new character variable with validation, networking, and database persistence

#### ⏰ When Called
During gamemode initialization to define character variables and their behavior

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | The unique identifier for the character variable |
| `data` | **table** | Configuration table containing variable properties and callbacks |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic character variable
    lia.char.registerVar("level", {
        field     = "level",
        fieldType = "integer",
        default   = 1,
        index     = 5
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register variable with validation and custom behavior
    lia.char.registerVar("reputation", {
        field     = "reputation",
        fieldType = "integer",
        default   = 0,
        index     = 6,
        onValidate = function(value, data, client)
            if not isnumber(value) or value < -100 or value > 100 then
                return false, "invalid", "reputation"
            end
            return true
        end,
        onSet = function(character, value)
            local oldValue = character:getReputation()
            character.vars.reputation = value
            -- Notify player of reputation change
            local client = character:getPlayer()
            if IsValid(client) then
                client:notify("Reputation changed to: " .. value)
            end
            hook.Run("OnCharVarChanged", character, "reputation", oldValue, value)
        end
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Register complex variable with full feature set
    lia.char.registerVar("skills", {
        field     = "skills",
        fieldType = "text",
        default   = {},
        index     = 7,
        isLocal   = true,
        onValidate = function(value, data, client)
            if not istable(value) then return false, "invalid", "skills" end
            local totalPoints = 0
            for skillName, level in pairs(value) do
                if not isnumber(level) or level < 0 or level > 100 then
                    return false, "invalid", "skillLevel"
                end
                totalPoints = totalPoints + level
            end
            local maxPoints = hook.Run("GetMaxSkillPoints", client) or 500
            if totalPoints > maxPoints then
                return false, "tooManySkillPoints"
            end
            return true
        end,
        onSet = function(character, value)
            local oldValue = character:getSkills()
            character.vars.skills = value
            -- Recalculate derived stats
            local client = character:getPlayer()
            if IsValid(client) then
                hook.Run("OnSkillsChanged", character, oldValue, value)
            end
        end,
        onGet = function(character, default)
            return character.vars.skills or default or {}
        end,
        shouldDisplay = function()
            return lia.config.get("EnableSkills", true)
        end
    })

```

---

### lia.char.getCharData

#### 📋 Purpose
Retrieves character data from the database with automatic decoding

#### ⏰ When Called
When you need to access character data directly from the database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character |
| `key` | **string** | Specific data key to retrieve (optional) |

#### ↩️ Returns
* Table of character data or specific value if key provided

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all character data
    local charData = lia.char.getCharData(123)
    print("Character name:", charData.name)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get specific character data
    local charID = 123
    local characterName = lia.char.getCharData(charID, "name")
    local characterMoney = lia.char.getCharData(charID, "money")
    if characterName then
        print("Character", characterName, "has", characterMoney or 0, "money")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character data retrieval with validation
    local charIDs = {123, 456, 789}
    local charactersData = {}
    for _, charID in ipairs(charIDs) do
        local charData = lia.char.getCharData(charID)
        if charData and charData.name then
            charactersData[charID] = {
                name      = charData.name,
                faction   = charData.faction,
                money     = charData.money or 0,
                lastLogin = charData.lastJoinTime
            }
        end
    end
    print("Retrieved data for", table.Count(charactersData), "characters")

```

---

### lia.char.getCharDataRaw

#### 📋 Purpose
Retrieves raw character data from database without automatic processing

#### ⏰ When Called
When you need unprocessed character data or want to handle decoding manually

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character |
| `key` | **string** | Specific data key to retrieve (optional) |

#### ↩️ Returns
* Raw decoded data or specific value if key provided

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get raw character data
    local rawData = lia.char.getCharDataRaw(123)
    print("Raw data keys:", table.GetKeys(rawData))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get specific raw data with error handling
    local charID = 123
    local rawValue = lia.char.getCharDataRaw(charID, "customData")
    if rawValue ~= false then
        print("Custom data found:", rawValue)
    else
        print("No custom data found for character", charID)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Process multiple raw data entries
    local charID = 123
    local rawData = lia.char.getCharDataRaw(charID)
    local processedData = {}
    if rawData then
        for key, value in pairs(rawData) do
            -- Custom processing based on key type
            if key:find("^skill_") then
                processedData[key] = tonumber(value) or 0
            elseif key:find("^item_") then
                processedData[key] = istable(value) and value or {}
            else
                processedData[key] = value
            end
        end
        return processedData
    end

```

---

### lia.char.getOwnerByID

#### 📋 Purpose
Finds the player who owns a character with the given ID

#### ⏰ When Called
When you need to find which player is using a specific character

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `ID` | **number** | The unique identifier of the character |

#### ↩️ Returns
* Player object if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find character owner
    local owner = lia.char.getOwnerByID(123)
    if owner then
        print("Character 123 is owned by:", owner:Name())
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find owner and perform action
    local charID = 123
    local owner = lia.char.getOwnerByID(charID)
    if IsValid(owner) then
        local character = owner:getChar()
        if character and character:getID() == charID then
            owner:notify("Your character has been updated!")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch owner lookup with validation
    local charIDs = {123, 456, 789}
    local owners = {}
    for _, charID in ipairs(charIDs) do
        local owner = lia.char.getOwnerByID(charID)
        if IsValid(owner) then
            owners[charID] = {
                player    = owner,
                name      = owner:Name(),
                steamID   = owner:SteamID(),
                character = owner:getChar()
            }
        end
    end
    print("Found owners for", table.Count(owners), "characters")

```

---

### lia.char.getBySteamID

#### 📋 Purpose
Finds a character by the Steam ID of its owner

#### ⏰ When Called
When you need to find a character using the player's Steam ID

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `steamID` | **string** | Steam ID of the character owner (supports both formats) |

#### ↩️ Returns
* Character object if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find character by Steam ID
    local character = lia.char.getBySteamID("STEAM_0:1:123456")
    if character then
        print("Found character:", character:getName())
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find character with Steam ID conversion
    local steamID64 = "76561198000000000"
    local character = lia.char.getBySteamID(steamID64)
    if character then
        local owner = character:getPlayer()
        if IsValid(owner) then
            owner:notify("Character found and loaded")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character lookup by Steam IDs
    local steamIDs = {"STEAM_0:1:123456", "76561198000000000", "STEAM_0:0:789012"}
    local foundCharacters = {}
    for _, steamID in ipairs(steamIDs) do
        local character = lia.char.getBySteamID(steamID)
        if character then
            local owner = character:getPlayer()
            foundCharacters[steamID] = {
                character = character,
                owner     = owner,
                name      = character:getName(),
                faction   = character:getFaction()
            }
        end
    end
    print("Found", table.Count(foundCharacters), "characters")

```

---

### lia.char.getTeamColor

#### 📋 Purpose
Gets the team color for a player based on their character's class

#### ⏰ When Called
When you need to determine the appropriate color for a player's team/class

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to get the team color for |

#### ↩️ Returns
* Color object representing the team/class color

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get player team color
    local color = lia.char.getTeamColor(client)
    print("Team color:", color.r, color.g, color.b)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Use team color for UI elements
    local color = lia.char.getTeamColor(client)
    -- Set player name color in chat
    local nameColor = Color(color.r, color.g, color.b, 255)
    chat.AddText(nameColor, client:Name(), color_white, ": Hello!")

```

#### ⚙️ High Complexity
```lua
    -- High: Batch team color processing for UI
    local players = player.GetAll()
    local teamColors = {}
    for _, ply in ipairs(players) do
        if IsValid(ply) then
            local color = lia.char.getTeamColor(ply)
            local character = ply:getChar()
            teamColors[ply] = {
                color     = color,
                character = character,
                faction   = character and character:getFaction() or "Unknown",
                class     = character and character:getClass() or 0
            }
        end
    end
    -- Update scoreboard with team colors
    hook.Run("UpdateScoreboardColors", teamColors)

```

---

### lia.char.create

#### 📋 Purpose
Creates a new character in the database and initializes it with default inventory

#### ⏰ When Called
When a player creates a new character through character creation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `data` | **table** | Character data containing name, description, faction, model, etc. |
| `callback` | **function** | Function to call when character creation is complete |

#### ↩️ Returns
* nil (uses callback for result)

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Create a basic character
    local charData = {
        name    = "John Doe",
        desc    = "A citizen of the city",
        faction = "Citizen",
        model   = "models/player/Group01/male_01.mdl",
        steamID = client:SteamID()
    }
    lia.char.create(charData, function(charID)
        print("Character created with ID:", charID)
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Create character with validation and inventory
    local charData = {
        name    = "Jane Smith",
        desc    = "A skilled engineer",
        faction = "Engineer",
        model   = "models/player/Group01/female_01.mdl",
        steamID = client:SteamID(),
        money   = 1000,
        attribs = {strength = 5, intelligence = 8}
    }
    lia.char.create(charData, function(charID)
        if charID then
            local character = lia.char.getCharacter(charID)
            if character then
                -- Add starting items
                character:getInv(1):add("crowbar")
                character:getInv(1):add("flashlight")
                client:notify("Character created successfully!")
            end
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Create character with full validation and error handling
    local function createCharacterWithValidation(client, charData)
        -- Validate required fields
        if not charData.name or not charData.faction then
            client:notifyError("Missing required character data")
            return
        end
        -- Validate faction access
        if not client:hasWhitelist(charData.faction) then
            client:notifyError("You don't have access to this faction")
            return
        end
        -- Set default values
        charData.steamID = client:SteamID()
        charData.money = charData.money or lia.config.get("DefaultMoney", 1000)
        charData.createTime = os.date("%Y-%m-%d %H:%M:%S", os.time())
        lia.char.create(charData, function(charID)
            if charID then
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Initialize character-specific data
                    character:setData("lastLogin", os.time())
                    character:setData("creationIP", client:IPAddress())
                    -- Add to player's character list
                    client.liaCharList = client.liaCharList or {}
                    table.insert(client.liaCharList, charID)
                    -- Notify success
                    client:notify("Character '" .. charData.name .. "' created successfully!")
                    hook.Run("OnCharacterCreated", character, client)
                end
            else
                client:notifyError("Failed to create character")
            end
        end)
    end

```

---

### lia.char.restore

#### 📋 Purpose
Restores/loads all characters for a player from the database

#### ⏰ When Called
When a player connects and needs their characters loaded

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to restore characters for |
| `callback` | **function** | Function to call when restoration is complete |
| `id` | **number** | Specific character ID to restore (optional) |

#### ↩️ Returns
* nil (uses callback for result)

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Restore all characters for player
    lia.char.restore(client, function(characters)
        print("Restored", #characters, "characters for", client:Name())
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Restore with character validation
    lia.char.restore(client, function(characters)
        if #characters > 0 then
            client.liaCharList = characters
            -- Validate each character
            for _, charID in ipairs(characters) do
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Check if character is banned
                    if character:getBanned() > 0 then
                        print("Character", charID, "is banned")
                    end
                end
            end
            client:notify("Characters loaded successfully!")
        else
            client:notify("No characters found")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Restore with full error handling and statistics
    lia.char.restore(client, function(characters)
        local stats = {
            total   = #characters,
            loaded  = 0,
            banned  = 0,
            invalid = 0
        }
        client.liaCharList = characters
        for _, charID in ipairs(characters) do
            local character = lia.char.getCharacter(charID)
            if character then
                stats.loaded = stats.loaded + 1
                -- Check character status
                if character:getBanned() > 0 then
                    stats.banned = stats.banned + 1
                end
                -- Validate character data
                if not character:getName() or character:getName() == "" then
                    stats.invalid = stats.invalid + 1
                    print("Invalid character data for ID:", charID)
                end
            end
        end
        -- Log statistics
        lia.log.add("Character restoration: " ..
            client:Name() .. " - Total: " .. stats.total ..
            ", Loaded: " .. stats.loaded ..
            ", Banned: " .. stats.banned ..
            ", Invalid: " .. stats.invalid
        )
        hook.Run("OnCharactersRestored", client, characters, stats)
    end)

```

---

### lia.char.cleanUpForPlayer

#### 📋 Purpose
Cleans up all loaded characters for a player when they disconnect

#### ⏰ When Called
When a player disconnects to free up memory and save data

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to clean up characters for |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Clean up player characters
    lia.char.cleanUpForPlayer(client)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Clean up with logging
    lia.char.cleanUpForPlayer(client)
    local charCount = table.Count(client.liaCharList or {})
    if charCount > 0 then
        lia.log.add("Player disconnect: " ..
            client:Name() .. " disconnected with " .. charCount .. " characters loaded"
        )
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Clean up with statistics and validation
    local function cleanupPlayerCharacters(client)
        local charList = client.liaCharList or {}
        local stats = {
            total  = #charList,
            saved  = 0,
            errors = 0
        }
        for _, charID in ipairs(charList) do
            local character = lia.char.getCharacter(charID)
            if character then
                -- Save character data
                local success = character:save()
                if success then
                    stats.saved = stats.saved + 1
                else
                    stats.errors = stats.errors + 1
                    print("Failed to save character", charID, "for", client:Name())
                end
            end
        end
        -- Clean up
        lia.char.cleanUpForPlayer(client)
        -- Log statistics
        lia.log.add("Player cleanup: " ..
            client:Name() .. " - Characters: " .. stats.total ..
            ", Saved: " .. stats.saved ..
            ", Errors: " .. stats.errors
        )
    end

```

---

### lia.char.delete

#### 📋 Purpose
Permanently deletes a character from the database and all associated data

#### ⏰ When Called
When a character needs to be permanently removed (admin action, etc.)

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `id` | **number** | The unique identifier of the character to delete |
| `client` | **Player** | The player who owns the character (optional) |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Delete a character
    lia.char.delete(123)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Delete character with validation
    local charID = 123
    local character = lia.char.getCharacter(charID)
    if character then
        local owner = character:getPlayer()
        if IsValid(owner) then
            owner:notify("Your character '" .. character:getName() .. "' has been deleted")
        end
        lia.char.delete(charID, owner)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Delete character with full cleanup and logging
    local function deleteCharacterWithCleanup(charID, admin)
        local character = lia.char.getCharacter(charID)
        if not character then
            if admin then
                admin:notifyError("Character not found")
            end
            return
        end
        local owner = character:getPlayer()
        local charName = character:getName()
        -- Log deletion
        lia.log.add("Character deletion: " ..
            "Character '" .. charName .. "' (ID: " .. charID .. ") deleted by " ..
            (IsValid(admin) and admin:Name() or "System")
        )
        -- Notify owner if online
        if IsValid(owner) then
            owner:notify("Your character '" .. charName .. "' has been deleted")
        end
        -- Perform deletion
        lia.char.delete(charID, owner)
        -- Notify admin
        if IsValid(admin) then
            admin:notify("Character '" .. charName .. "' deleted successfully")
        end
        -- Run deletion hook
        hook.Run("OnCharacterDeleted", charID, charName, owner, admin)
    end

```

---

### lia.char.getCharBanned

#### 📋 Purpose
Checks if a character is banned and returns the ban timestamp

#### ⏰ When Called
When you need to check if a character is banned

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character |

#### ↩️ Returns
* Number representing ban timestamp (0 if not banned)

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if character is banned
    local banTime = lia.char.getCharBanned(123)
    if banTime > 0 then
        print("Character is banned since:", os.date("%Y-%m-%d", banTime))
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check ban status with validation
    local charID = 123
    local banTime = lia.char.getCharBanned(charID)
    if banTime > 0 then
        local character = lia.char.getCharacter(charID)
        if character then
            local owner = character:getPlayer()
            if IsValid(owner) then
                owner:notify("Your character is banned")
            end
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch ban checking with detailed information
    local function checkCharacterBans(charIDs)
        local banInfo = {}
        for _, charID in ipairs(charIDs) do
            local banTime = lia.char.getCharBanned(charID)
            if banTime > 0 then
                local character = lia.char.getCharacter(charID)
                banInfo[charID] = {
                    banned     = true,
                    banTime    = banTime,
                    banDate    = os.date("%Y-%m-%d %H:%M:%S", banTime),
                    character  = character,
                    owner      = character and character:getPlayer()
                }
            end
        end
        return banInfo
    end

```

---

### lia.char.setCharDatabase

#### 📋 Purpose
Sets character data in the database with proper type handling and networking

#### ⏰ When Called
When character data needs to be saved to the database

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character |
| `field` | **string** | The field name to set |
| `value` | **any** | The value to set for the field |

#### ↩️ Returns
* Boolean indicating success

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Set character data
    local success = lia.char.setCharDatabase(123, "money", 1000)
    if success then
        print("Character money updated")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Set character data with validation
    local charID = 123
    local newMoney = 5000
    local character = lia.char.getCharacter(charID)
    if character then
        local oldMoney = character:getMoney()
        local success = lia.char.setCharDatabase(charID, "money", newMoney)
        if success then
            character:setMoney(newMoney)
            print("Money changed from", oldMoney, "to", newMoney)
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character data updates with error handling
    local function updateCharacterData(charID, dataUpdates)
        local character = lia.char.getCharacter(charID)
        if not character then
            print("Character not found:", charID)
            return false
        end
        local results = {}
        local successCount = 0
        for field, value in pairs(dataUpdates) do
            local success = lia.char.setCharDatabase(charID, field, value)
            results[field] = success
            if success then
                successCount = successCount + 1
                -- Update loaded character if it exists
                if character["set" .. field:sub(1, 1):upper() .. field:sub(2)] then
                    character["set" .. field:sub(1, 1):upper() .. field:sub(2)](character, value)
                end
            else
                print("Failed to update field:", field)
            end
        end
        print("Updated", successCount, "out of", table.Count(dataUpdates), "fields")
        return successCount == table.Count(dataUpdates)
    end

```

---

### lia.char.unloadCharacter

#### 📋 Purpose
Unloads a character from memory, saving data and cleaning up resources

#### ⏰ When Called
When a character needs to be removed from memory to free up resources

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character to unload |

#### ↩️ Returns
* Boolean indicating success

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Unload a character
    local success = lia.char.unloadCharacter(123)
    if success then
        print("Character unloaded successfully")
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Unload character with validation
    local charID = 123
    local character = lia.char.getCharacter(charID)
    if character then
        local owner = character:getPlayer()
        if IsValid(owner) then
            owner:notify("Character is being unloaded")
        end
        local success = lia.char.unloadCharacter(charID)
        if success then
            print("Character", charID, "unloaded successfully")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Batch character unloading with statistics
    local function unloadCharacters(charIDs)
        local stats = {
            total    = #charIDs,
            unloaded = 0,
            errors   = 0,
            skipped  = 0
        }
        for _, charID in ipairs(charIDs) do
            if lia.char.isLoaded(charID) then
                local character = lia.char.getCharacter(charID)
                if character then
                    -- Check if character is in use
                    local owner = character:getPlayer()
                    if IsValid(owner) and owner:getChar() == character then
                        stats.skipped = stats.skipped + 1
                        print("Skipping active character:", charID)
                        continue
                    end
                    local success = lia.char.unloadCharacter(charID)
                    if success then
                        stats.unloaded = stats.unloaded + 1
                    else
                        stats.errors = stats.errors + 1
                    end
                end
            end
        end
        print("Unloaded", stats.unloaded, "characters, skipped", stats.skipped, "active characters")
        return stats
    end

```

---

### lia.char.unloadUnusedCharacters

#### 📋 Purpose
Unloads unused characters for a player, keeping only the active one

#### ⏰ When Called
When a player switches characters or to free up memory

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player to unload unused characters for |
| `activeCharID` | **number** | The ID of the character to keep loaded |

#### ↩️ Returns
* Number of characters unloaded

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Unload unused characters
    local unloadedCount = lia.char.unloadUnusedCharacters(client, 123)
    print("Unloaded", unloadedCount, "characters")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Unload with validation
    local activeCharID = client:getChar() and client:getChar():getID()
    if activeCharID then
        local unloadedCount = lia.char.unloadUnusedCharacters(client, activeCharID)
        if unloadedCount > 0 then
            client:notify("Unloaded " .. unloadedCount .. " unused characters")
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Unload with detailed logging and statistics
    local function unloadUnusedCharactersWithStats(client)
        local activeChar = client:getChar()
        local activeCharID = activeChar and activeChar:getID()
        if not activeCharID then
            print("No active character for", client:Name())
            return 0
        end
        local charList = client.liaCharList or {}
        local stats = {
            total    = #charList,
            active   = activeCharID,
            unloaded = 0,
            errors   = 0
        }
        -- Unload unused characters
        stats.unloaded = lia.char.unloadUnusedCharacters(client, activeCharID)
        -- Log statistics
        lia.log.add("Character unloading: " ..
            client:Name() .. " - Total: " .. stats.total ..
            ", Active: " .. stats.active ..
            ", Unloaded: " .. stats.unloaded
        )
        return stats.unloaded
    end

```

---

### lia.char.loadSingleCharacter

#### 📋 Purpose
Loads a single character from the database with inventory initialization

#### ⏰ When Called
When a specific character needs to be loaded on demand

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `charID` | **number** | The unique identifier of the character to load |
| `client` | **Player** | The player requesting the character (optional) |
| `callback` | **function** | Function to call when loading is complete |

#### ↩️ Returns
* nil (uses callback for result)

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load a single character
    lia.char.loadSingleCharacter(123, client, function(character)
        if character then
            print("Character loaded:", character:getName())
        end
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load character with validation
    local charID = 123
    lia.char.loadSingleCharacter(charID, client, function(character)
        if character then
            -- Validate character access
            if not client.liaCharList or not table.HasValue(client.liaCharList, charID) then
                print("Player doesn't have access to character", charID)
                return
            end
            -- Check if character is banned
            if character:getBanned() > 0 then
                client:notify("This character is banned")
                return
            end
            client:notify("Character loaded successfully")
        else
            client:notify("Failed to load character")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Load character with full error handling and statistics
    local function loadCharacterWithValidation(charID, client)
        if not charID or not isnumber(charID) then
            if client then
                client:notifyError("Invalid character ID")
            end
            return
        end
        -- Check if character is already loaded
        if lia.char.isLoaded(charID) then
            local character = lia.char.getCharacter(charID)
            if character then
                print("Character already loaded:", charID)
                return character
            end
        end
        -- Validate player access
        if client and (not client.liaCharList or not table.HasValue(client.liaCharList, charID)) then
            client:notifyError("You don't have access to this character")
            return
        end
        lia.char.loadSingleCharacter(charID, client, function(character)
            if character then
                -- Validate character data
                if not character:getName() or character:getName() == "" then
                    print("Invalid character data for ID:", charID)
                    return
                end
                -- Check ban status
                if character:getBanned() > 0 then
                    if client then
                        client:notify("This character is banned")
                    end
                    return
                end
                -- Log successful load
                lia.log.add("Character loaded: " ..
                    "Character '" .. character:getName() .. "' (ID: " .. charID .. ") loaded for " ..
                    (client and client:Name() or "System")
                )
                -- Run load hook
                hook.Run("OnCharacterLoaded", character, client)
                if client then
                    client:notify("Character '" .. character:getName() .. "' loaded successfully")
                end
            else
                if client then
                    client:notifyError("Failed to load character")
                end
                print("Failed to load character:", charID)
            end
        end)
    end

```

---

