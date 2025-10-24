# Faction Library

Comprehensive faction (team) management and registration system for the Lilia framework.

---

## Overview

The faction library provides comprehensive functionality for managing factions (teams) in the Lilia framework.

It handles registration, loading, and management of faction data including models, colors, descriptions,

and team setup. The library operates on both server and client sides, with server handling faction

registration and client handling whitelist checks. It includes functionality for loading factions from

directories, managing faction models with bodygroup support, and providing utilities for faction

categorization and player management. The library ensures proper team setup and model precaching

for all registered factions, supporting both simple string models and complex model data with

bodygroup configurations.

---

### register

**Purpose**

Registers a new faction with the specified unique ID and data

**When Called**

During faction initialization, module loading, or when creating custom factions

**Parameters**

* `uniqueID` (*string*): Unique identifier for the faction
* `data` (*table*): Faction data containing name, desc, color, models, etc.
* `index` (*number*): The faction's team index
* `faction` (*table*): The complete faction data table

---

### cacheModels

**Purpose**

Precaches faction models to ensure they are loaded before use

**When Called**

Automatically called during faction registration, or manually when adding models

**Parameters**

* `models` (*table*): Table of model data (strings or tables with model paths)

---

### loadFromDir

**Purpose**

Loads all faction files from a specified directory

**When Called**

During gamemode initialization to load faction files from modules or custom directories

**Parameters**

* `directory` (*string*): Path to the directory containing faction files

---

### get

**Purpose**

Retrieves a faction by its identifier (index or uniqueID)

**When Called**

When you need to get faction data by either team index or unique ID

**Parameters**

* `identifier` (*number/string*): Either the faction's team index or unique ID
* `faction` (*table*): The faction data table, or nil if not found

---

### getIndex

**Purpose**

Gets the team index of a faction by its unique ID

**When Called**

When you need to convert a faction's unique ID to its team index

**Parameters**

* `uniqueID` (*string*): The faction's unique identifier
* `index` (*number*): The faction's team index, or nil if not found

---

### getClasses

**Purpose**

Gets all classes that belong to a specific faction

**When Called**

When you need to retrieve all classes associated with a faction

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `classes` (*table*): Table of class objects belonging to the faction
* `print("` (*unknown*): " .. class.name)

---

### getPlayers

**Purpose**

Gets all players currently in a specific faction

**When Called**

When you need to retrieve all players belonging to a faction

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `players` (*table*): Table of player entities in the faction
* `print("` (*" .. ply*): Name())

---

### getPlayerCount

**Purpose**

Gets the count of players currently in a specific faction

**When Called**

When you need to know how many players are in a faction without getting the actual player objects

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `count` (*number*): Number of players in the faction

---

### isFactionCategory

**Purpose**

Checks if a faction belongs to a specific category of factions

**When Called**

When you need to check if a faction is part of a group of related factions

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `categoryFactions` (*table*): Table of faction identifiers to check against
* `isCategory` (*boolean*): True if the faction is in the category, false otherwise

---

### jobGenerate

**Purpose**

Generates a faction/job with the specified parameters (legacy compatibility function)

**When Called**

For backward compatibility with older faction systems or when creating simple factions

**Parameters**

* `index` (*number*): The team index for the faction
* `name` (*string*): The faction's display name
* `color` (*Color*): The faction's team color
* `default` (*boolean*): Whether this is a default faction
* `models` (*table*): Optional table of models for the faction
* `faction` (*table*): The generated faction data table

---

### formatModelData

**Purpose**

Formats and processes model data for all factions, converting bodygroup strings to proper format

**When Called**

During faction initialization or when model data needs to be processed

---

### getCategories

**Purpose**

Gets all model categories for a specific faction

**When Called**

When you need to retrieve the model categories available for a faction

**Parameters**

* `teamName` (*string*): The faction's unique ID
* `categories` (*table*): Table of category names for the faction's models
* `print("` (*unknown*): " .. category)

---

### getModelsFromCategory

**Purpose**

Gets all models from a specific category within a faction

**When Called**

When you need to retrieve models from a specific category of a faction

**Parameters**

* `teamName` (*string*): The faction's unique ID
* `category` (*string*): The category name to get models from
* `models` (*table*): Table of models in the specified category
* `print("` (*" .. index .. "*): " .. tostring(model))

---

### getDefaultClass

**Purpose**

Gets the default class for a specific faction

**When Called**

When you need to find the default class that players spawn as in a faction

**Parameters**

* `id` (*string/number*): The faction's unique ID or team index
* `defaultClass` (*table*): The default class object, or nil if not found

---

### hasWhitelist

**Purpose**

Checks if a faction has whitelist restrictions (client-side implementation)

**When Called**

When checking if a player can access a faction based on whitelist status

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `hasWhitelist` (*boolean*): True if the faction has whitelist restrictions, false otherwise

---

### hasWhitelist

**Purpose**

Checks if a faction has whitelist restrictions (server-side implementation)

**When Called**

When checking if a faction has whitelist restrictions on the server

**Parameters**

* `faction` (*string/number*): The faction's unique ID or team index
* `hasWhitelist` (*boolean*): True if the faction has whitelist restrictions, false otherwise

---

