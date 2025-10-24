# Character Library

Comprehensive character creation, management, and persistence system for the Lilia framework.

---

## Overview

The character library provides comprehensive functionality for managing player characters

in the Lilia framework. It handles character creation, loading, saving, and management

across both server and client sides. The library operates character data persistence,

networking synchronization, and provides hooks for character variable changes. It includes

functions for character validation, database operations, inventory management, and

character lifecycle management. The library ensures proper character data integrity and

provides a robust system for character-based gameplay mechanics including factions,

attributes, money, and custom character variables.

---

### getCharacter

**Purpose**

Retrieves a character by its ID, loading it if necessary

**When Called**

When a character needs to be accessed by ID, either from server or client

**Parameters**

* `charID` (*number*): The unique identifier of the character
* `client` (*Player*): The player requesting the character (optional)
* `callback` (*function*): Function to call when character is loaded (optional)

---

### getAll

**Purpose**

Retrieves all currently loaded characters from all players

**When Called**

When you need to iterate through all active characters on the server

---

### isLoaded

**Purpose**

Checks if a character with the given ID is currently loaded in memory

**When Called**

Before attempting to access a character to avoid unnecessary loading

**Parameters**

* `charID` (*number*): The unique identifier of the character to check

---

### addCharacter

**Purpose**

Adds a character to the loaded characters cache and triggers pending callbacks

**When Called**

When a character is loaded from database or created, to make it available in memory

**Parameters**

* `id` (*number*): The unique identifier of the character
* `character` (*Character*): The character object to add to cache

---

### removeCharacter

**Purpose**

Removes a character from the loaded characters cache

**When Called**

When a character needs to be unloaded from memory (cleanup, deletion, etc.)

**Parameters**

* `id` (*number*): The unique identifier of the character to remove
* `character:save()` (*unknown*): - Save before removing

---

### new

**Purpose**

Creates a new character object from data with proper metatable and variable initialization

**When Called**

When creating a new character instance from database data or character creation

**Parameters**

* `data` (*table*): Character data containing all character variables
* `id` (*number*): The unique identifier for the character (optional)
* `client` (*Player*): The player who owns this character (optional)
* `steamID` (*string*): Steam ID of the character owner (optional, used when client is invalid)

---

### hookVar

**Purpose**

Registers a hook function for a specific character variable

**When Called**

When you need to add custom behavior when a character variable changes

**Parameters**

* `varName` (*string*): The name of the character variable to hook
* `hookName` (*string*): The name/identifier for this hook
* `func` (*function*): The function to call when the variable changes

---

### registerVar

**Purpose**

Registers a new character variable with validation, networking, and database persistence

**When Called**

During gamemode initialization to define character variables and their behavior

**Parameters**

* `key` (*string*): The unique identifier for the character variable
* `data` (*table*): Configuration table containing variable properties and callbacks

---

### getCharData

**Purpose**

Retrieves character data from the database with automatic decoding

**When Called**

When you need to access character data directly from the database

**Parameters**

* `charID` (*number*): The unique identifier of the character
* `key` (*string*): Specific data key to retrieve (optional)

---

### getCharDataRaw

**Purpose**

Retrieves raw character data from database without automatic processing

**When Called**

When you need unprocessed character data or want to handle decoding manually

**Parameters**

* `charID` (*number*): The unique identifier of the character
* `key` (*string*): Specific data key to retrieve (optional)

---

### getOwnerByID

**Purpose**

Finds the player who owns a character with the given ID

**When Called**

When you need to find which player is using a specific character

**Parameters**

* `ID` (*number*): The unique identifier of the character

---

### getBySteamID

**Purpose**

Finds a character by the Steam ID of its owner

**When Called**

When you need to find a character using the player's Steam ID

**Parameters**

* `steamID` (*string*): Steam ID of the character owner (supports both formats)

---

### getTeamColor

**Purpose**

Gets the team color for a player based on their character's class

**When Called**

When you need to determine the appropriate color for a player's team/class

**Parameters**

* `client` (*Player*): The player to get the team color for

---

### create

**Purpose**

Creates a new character in the database and initializes it with default inventory

**When Called**

When a player creates a new character through character creation

**Parameters**

* `data` (*table*): Character data containing name, description, faction, model, etc.
* `callback` (*function*): Function to call when character creation is complete

---

### restore

**Purpose**

Restores/loads all characters for a player from the database

**When Called**

When a player connects and needs their characters loaded

**Parameters**

* `client` (*Player*): The player to restore characters for
* `callback` (*function*): Function to call when restoration is complete
* `id` (*number*): Specific character ID to restore (optional)

---

### cleanUpForPlayer

**Purpose**

Cleans up all loaded characters for a player when they disconnect

**When Called**

When a player disconnects to free up memory and save data

**Parameters**

* `client` (*Player*): The player to clean up characters for

---

### delete

**Purpose**

Permanently deletes a character from the database and all associated data

**When Called**

When a character needs to be permanently removed (admin action, etc.)

**Parameters**

* `id` (*number*): The unique identifier of the character to delete
* `client` (*Player*): The player who owns the character (optional)

---

### getCharBanned

**Purpose**

Checks if a character is banned and returns the ban timestamp

**When Called**

When you need to check if a character is banned

**Parameters**

* `charID` (*number*): The unique identifier of the character

---

### setCharDatabase

**Purpose**

Sets character data in the database with proper type handling and networking

**When Called**

When character data needs to be saved to the database

**Parameters**

* `charID` (*number*): The unique identifier of the character
* `field` (*string*): The field name to set
* `value` (*any*): The value to set for the field

---

### unloadCharacter

**Purpose**

Unloads a character from memory, saving data and cleaning up resources

**When Called**

When a character needs to be removed from memory to free up resources

**Parameters**

* `charID` (*number*): The unique identifier of the character to unload

---

### unloadUnusedCharacters

**Purpose**

Unloads unused characters for a player, keeping only the active one

**When Called**

When a player switches characters or to free up memory

**Parameters**

* `client` (*Player*): The player to unload unused characters for
* `activeCharID` (*number*): The ID of the character to keep loaded

---

### loadSingleCharacter

**Purpose**

Loads a single character from the database with inventory initialization

**When Called**

When a specific character needs to be loaded on demand

**Parameters**

* `charID` (*number*): The unique identifier of the character to load
* `client` (*Player*): The player requesting the character (optional)
* `callback` (*function*): Function to call when loading is complete

---

