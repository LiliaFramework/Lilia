# Classes Library

Character class management and validation system for the Lilia framework.

---

## Overview

The classes library provides comprehensive functionality for managing character classes

in the Lilia framework. It handles registration, validation, and management of player

classes within factions. The library operates on both server and client sides, allowing

for dynamic class creation, whitelist management, and player class assignment validation.

It includes functionality for loading classes from directories, checking class availability,

retrieving class information, and managing class limits. The library ensures proper

faction validation and provides hooks for custom class behavior and restrictions.

---

### register

**Purpose**

Registers a new character class with the specified unique ID and data

**When Called**

During gamemode initialization or when dynamically creating classes

**Parameters**

* `uniqueID` (*string*): Unique identifier for the class
* `data` (*table*): Table containing class properties (name, desc, limit, faction, etc.)

---

### loadFromDir

**Purpose**

Loads character classes from a directory containing class definition files

**When Called**

During gamemode initialization to load classes from files

**Parameters**

* `directory` (*string*): Path to directory containing class files

---

### canBe

**Purpose**

Checks if a client can join a specific character class

**When Called**

When a player attempts to join a class or when checking class availability

**Parameters**

* `client` (*Player*): The player attempting to join the class
* `class` (*number*): The class index to check

---

### get

**Purpose**

Retrieves a character class by its identifier (index or uniqueID)

**When Called**

When needing to access class information or properties

**Parameters**

* `identifier` (*number/string*): Class index or uniqueID to retrieve

---

### getPlayers

**Purpose**

Gets all players currently using a specific character class

**When Called**

When needing to find players in a particular class or check class population

**Parameters**

* `class` (*number*): The class index to get players for

---

### getPlayerCount

**Purpose**

Gets the count of players currently using a specific character class

**When Called**

When needing to check class population without retrieving player objects

**Parameters**

* `class` (*number*): The class index to count players for

---

### retrieveClass

**Purpose**

Finds a class by matching its uniqueID or name with a search string

**When Called**

When needing to find a class by name or partial identifier

**Parameters**

* `class` (*string*): String to match against class uniqueID or name

---

### hasWhitelist

**Purpose**

Checks if a character class has whitelist restrictions

**When Called**

When checking if a class requires special permissions or whitelist access

**Parameters**

* `class` (*number*): The class index to check for whitelist

---

### retrieveJoinable

**Purpose**

Retrieves all classes that a specific client can join

**When Called**

When displaying available classes to a player or checking joinable options

**Parameters**

* `client` (*Player*): The player to check joinable classes for (optional, defaults to LocalPlayer on client)

---

