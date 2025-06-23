# lia.character

---

                           ⚠️ WARNING: Use With Caution! ⚠️

This library is highly sensitive and should only be used by experienced developers or individuals 
who fully understand its functions.

Misuse of these functions can easily corrupt character data and cause irreversible damage. 
Proceed responsibly and double-check all operations before executing them.

---

### **lia.char.new**

**Description:**  
Creates a new empty `Character` object. If you are looking to create a usable character, see `lia.char.create`.

**Realm:**  
`Shared`

**Parameters:**  

- `data` (`table`): Character variables to assign.
- `id` (`integer`, optional): Unique ID of the character.
- `client` (`Player`): Player that will own the character.
- `steamID` (`string`, optional): SteamID64 of the player that will own the character. Defaults to `client:SteamID64()` if not provided.

**Example Usage:**
```lua
local character = lia.char.new({
    name = "Alice",
    desc = "A brave adventurer.",
    model = "models/player/male_01.mdl"
}, 1, playerInstance)
```

---

### **lia.char.hookVar**

**Description:**  
Adds a hook function to be called when a character variable is modified.

**Realm:**  
`Shared`

**Parameters:**  

- `varName` (`string`): The name of the character variable.
- `hookName` (`string`): The name of the hook.
- `func` (`function`): The function to be called when the character variable is modified.

**Example Usage:**
```lua
lia.char.hookVar("money", "OnMoneyChange", function(character, oldValue, newValue)
    character.player:ChatPrint("Your money changed from " .. oldValue .. " to " .. newValue)
end)
```

---

### **lia.char.registerVar**

**Description:**  
Registers a new character variable with specified data and associated hooks. This function is used to define a new character variable in the system, setting up how it interacts with the database, how it is networked, and how it can be accessed or modified within the game.

**Realm:**  
`Shared`

**Parameters:**  

- `key` (`string`): The key identifier for the character variable. This is used as the variable's name.
- `data` (`table`): A table containing the data and configuration for the character variable.

**Example Usage:**
```lua
lia.char.registerVar("strength", {
    field = "_strength",
    default = 10,
    onValidate = function(value, data, client)
        return value >= 0, "Strength cannot be negative."
    end,
    onSet = function(character, value)
        -- Custom behavior when strength is set
    end
})
```

---

### **lia.char.getCharData**

**Description:**  
Loads data for a character from the database.

**Realm:**  
`Shared`

**Parameters:**  

- `charID` (`integer`): The ID of the character to load data for.
- `key` (`string`, optional): Key to retrieve a specific value from the character's data.

**Returns:**  
If `key` is provided, returns the value associated with that key in the character's data. Otherwise, returns the entire data table.

**Example Usage:**
```lua
local money = lia.char.getCharData(123, "money")
local allData = lia.char.getCharData(123)
```

---

### **lia.char.getCharDataRaw**

**Description:**  
Loads raw data for a character from the database.

**Realm:**  
`Shared`

**Parameters:**  

- `charID` (`integer`): The ID of the character to load data for.
- `key` (`string`, optional): The specific key to retrieve from the character's data.

**Returns:**  
- If `key` is provided, returns the value associated with that key in the character's data.
- If `key` is not provided, returns the entire data table for the character.
- Returns `false` if the character data could not be found.

**Example Usage:**
```lua
local rawData = lia.char.getCharDataRaw(123)
local specificData = lia.char.getCharDataRaw(123, "inventory")
```

---

### **lia.char.getByID**

**Description:**  
Retrieves the client associated with a character by their character ID.

**Realm:**  
`Shared`

**Parameters:**  

- `ID` (`number`): The ID of the character to find the associated client.

**Returns:**  
`Player|nil` - The client associated with the character, or `nil` if no client is found.

**Example Usage:**
```lua
local client = lia.char.getByID(123)
if IsValid(client) then
    print(client:Nick() .. " is the player associated with the character ID.")
else
    print("No client found for that character ID.")
end
```

---

### **lia.char.getBySteamID**

**Description:**  
Retrieves the character associated with a player's SteamID or SteamID64.

**Realm:**  
`Shared`

**Parameters:**  

- `steamID` (`string`): The SteamID or SteamID64 of the player to find the associated character.

**Returns:**  
`table|nil` - The character associated with the SteamID, or `nil` if no character is found.

**Example Usage:**
```lua
local character = lia.char.getBySteamID("STEAM_0:1:12345678")
if character then
    print("Character found: " .. character:getName())
else
    print("No character found for the given SteamID.")
end
```

---

### **lia.char.getAll**

**Description:**  
Retrieves the SteamIDs of all connected players.

**Realm:**  
`Shared`

**Returns:**  
`table` - Table containing SteamIDs of all connected players.

**Example Usage:**
```lua
local allCharacters = lia.char.getAll()
for client, character in pairs(allCharacters) do
    print(client:Nick() .. " has character " .. character:getName())
end
```

---

### **lia.char.GetTeamColor**

**Description:**  
Gets the color associated with a player's team or class.

**Realm:**  
`Client`

**Parameters:**  

- `client` (`Player`): The player whose color to retrieve.

**Returns:**  
`Color` - The color associated with the player's team or class.

**Example Usage:**
```lua
local color = lia.char.GetTeamColor(playerInstance)
playerInstance:SetPlayerColor(Vector(color.r/255, color.g/255, color.b/255))
```

---

### **lia.char.create**

**Description:**  
Creates a character object with its assigned properties and saves it to the database.

**Realm:**  
`Server`

**Parameters:**  

- `data` (`table`): Properties to assign to this character. If fields are missing from the table, it will use the default value for that property.
- `callback` (`function`): Function to call after the character saves.

**Example Usage:**
```lua
lia.char.create({
    name = "Bob",
    desc = "A skilled trader.",
    steamID = "STEAM_0:1:87654321"
}, function(charID)
    print("Character created with ID:", charID)
end)
```

---

### **lia.char.restore**

**Description:**  
Loads all of a player's characters into memory.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`): Player to load the characters for.
- `callback` (`function`, optional): Function to call when the characters have been loaded.
- `id` (`integer`, optional): The ID of a specific character to load instead of all of the player's characters.

**Example Usage:**
```lua
lia.char.restore(playerInstance, function(characters)
    print("Characters loaded:", characters)
end)
```

---

### **lia.char.cleanUpForPlayer**

**Description:**  
Cleans up a player's characters, removing them from memory and database.

**Realm:**  
`Server`

**Parameters:**  

- `client` (`Player`): The player whose characters to clean up.

**Example Usage:**
```lua
lia.char.cleanUpForPlayer(playerInstance)
```

---

### **lia.char.delete**

**Description:**  
Deletes a character from memory and database.

**Realm:**  
`Server`

**Parameters:**  

- `id` (`integer`): The ID of the character to delete.
- `client` (`Player`): The player associated with the character.

**Example Usage:**
```lua
lia.char.delete(123, playerInstance)
```

---

### **lia.char.setCharData**

**Description:**  
Sets data for a character in the database and in memory.

**Realm:**  
`Server`

**Parameters:**  

- `charID` (`integer`): The ID of the character to set data for.
- `key` (`string`): The key of the data to set.
- `val` (`any`): The value to set for the specified key.

**Returns:**  
`boolean` - `True` if the data was successfully set, `false` otherwise.

**Example Usage:**
```lua
local success = lia.char.setCharData(123, "health", 100)
if success then
    print("Health updated successfully.")
else
    print("Failed to update health.")
end
```

---

### **lia.char.setCharName**

**Description:**  
Sets the name for a character in the database and in memory.

**Realm:**  
`Server`

**Parameters:**  

- `charID` (`integer`): The ID of the character to set the name for.
- `name` (`string`): The new name to set for the character.

**Returns:**  
`boolean` - `True` if the name was successfully set, `false` otherwise.

**Example Usage:**
```lua
local success = lia.char.setCharName(123, "Charlie")
if success then
    print("Character name updated successfully.")
else
    print("Failed to update character name.")
end
```

---

### **lia.char.setCharModel**

**Description:**  
Sets the model and bodygroups for a character in the database and in memory.

**Realm:**  
`Server`

**Parameters:**  

- `charID` (`integer`): The ID of the character to set the model for.
- `model` (`string`): The model path to set for the character.
- `bg` (`table`): A table containing bodygroup IDs and values.

**Returns:**  
`boolean` - `True` if the model and bodygroups were successfully set, `false` otherwise.

**Example Usage:**
```lua
lia.char.setCharModel(123, "models/player/male_02.mdl", {
    {id = 1, value = 2},
    {id = 2, value = 1}
})
```
---

### **Default Variables**

---
**name**

**Description:**  
The name of the character.

**Default:** `"John Doe"`

**Field:** `_name`

**Validation:**  
Ensures the name is a non-empty string and, if configured, unique.

**Adjustment:**  
Trims the name to a maximum of 70 characters or overrides it based on hooks.

**Example Usage:**
```lua
local character = lia.char.new({ name = "Alice" }, 1, playerInstance)
print(character:getName()) -- Outputs: Alice
```

---

**desc**

**Description:**  
The description of the character.

**Default:** `"Please enter your description with a minimum of X characters!"`  
*(X is defined by `lia.config.MinDescLen`)*

**Field:** `_desc`

**Validation:**  
Ensures the description meets the minimum length requirement.

**Adjustment:**  
Trims the description or overrides it based on hooks.

**Example Usage:**
```lua
local character = lia.char.new({ desc = "A brave warrior." }, 1, playerInstance)
print(character:getDesc()) -- Outputs: A brave warrior.
```

---

**model**

**Description:**  
The model of the character.

**Default:** `"models/error.mdl"`

**Field:** `_model`

**Validation:**  
Ensures the model exists within the character's faction.

**Adjustment:**  
Sets the model and applies bodygroups based on faction.

**Display:**  
Provides a UI panel with model selection for the character.

**Example Usage:**
```lua
local character = lia.char.new({ model = "models/player/male_01.mdl" }, 1, playerInstance)
print(character:getModel()) -- Outputs: models/player/male_01.mdl
```

---

**class**

**Description:**  
The class of the character.

**Default:** `{}`

**Example Usage:**
```lua
local character = lia.char.new({ class = "Warrior" }, 1, playerInstance)
print(character:getClass()) -- Outputs: Warrior
```

---

**faction**

**Description:**  
The faction of the character.

**Default:** `"Citizen"`

**Field:** `_faction`

**Validation:**  
Ensures the faction exists and the client has access to it.

**Adjustment:**  
Sets the faction's unique ID based on the selected faction.

**Example Usage:**
```lua
local success = lia.char.setFaction(123, "Police")
if success then
    print("Faction updated successfully.")
else
    print("Failed to update faction.")
end
```

---

**money**

**Description:**  
The money the character possesses.

**Default:** `0`

**Field:** `_money`

**Example Usage:**
```lua
local character = lia.char.new({ money = 500 }, 1, playerInstance)
print(character:getMoney()) -- Outputs: 500
```

---

**data**

**Description:**  
Additional data associated with the character.

**Default:** `{}`

**Field:** `_data`

**Example Usage:**
```lua
local character = lia.char.new({ data = { reputation = 10 } }, 1, playerInstance)
print(character:getData("reputation")) -- Outputs: 10
```

---

**var**

**Description:**  
Custom variables associated with the character.

**Default:** `{}`

**Example Usage:**
```lua
local character = lia.char.new({ var = { customKey = "customValue" } }, 1, playerInstance)
print(character:getVar("customKey")) -- Outputs: customValue
```

---

**inv**

**Description:**  
Represents the character's inventory, containing all items the character possesses.

**Default:** `{}`

**Field:** `_inv`

**Example Usage:**
```lua
character:getInv()
```

---

**attribs**

**Description:**  
Holds the character's attributes, such as strength, agility, intelligence, etc.

**Default:** `{}`

**Field:** `_attribs`

**Validation:**  
Ensures that each attribute does not exceed its maximum allowed value and that the total attribute points do not surpass the permitted maximum.

**Example Usage:**
```lua
local strength = character:getAttrib("strength")
character:setAttrib("agility", 5)
```

---

**RecognizedAs**

**Description:**  
A list of entities or roles that recognize this character as another, allowing for disguised or alternate identities.

**Default:** `{}`

**Field:** `recognized_as`

**Example Usage:**
```lua
character:setRecognizedAs("UndercoverAgent")
local recognitions = character:getRecognizedAs()
```

---