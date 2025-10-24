# Character Meta

Character management system for the Lilia framework.

---

## Overview

The character meta table provides comprehensive functionality for managing character data, attributes, and operations in the Lilia framework. It handles character creation, data persistence, attribute management, recognition systems, and character-specific operations. The meta table operates on both server and client sides, with the server managing character storage and validation while the client provides character data access and display. It includes integration with the database system for character persistence, inventory management for character items, and faction/class systems for character roles. The meta table ensures proper character data synchronization, attribute calculations with boosts, recognition between characters, and comprehensive character lifecycle management from creation to deletion.

---

### tostring

**Purpose**

Converts the character object to a string representation

**When Called**

When displaying character information or debugging

**Parameters**

* `print(charString)` (*- Output*): "character[123]"

---

### eq

**Purpose**

Compares two character objects for equality based on their IDs

**When Called**

When checking if two character references point to the same character

---

### getID

**Purpose**

Retrieves the unique ID of the character

**When Called**

When you need to identify a specific character instance

---

### getPlayer

**Purpose**

Retrieves the player entity associated with this character

**When Called**

When you need to access the player who owns this character

---

### getDisplayedName

**Purpose**

Gets the display name for a character based on recognition system

**When Called**

When displaying character names to other players

---

### hasMoney

**Purpose**

Checks if the character has enough money for a transaction

**When Called**

Before processing purchases, payments, or money transfers

---

### hasFlags

**Purpose**

Checks if the character has any of the specified flags

**When Called**

When checking permissions or access rights for a character

---

### getItemWeapon

**Purpose**

Checks if the character has a weapon item equipped

**When Called**

When validating weapon usage or checking equipped items

---

### getAttrib

**Purpose**

Gets the value of a character attribute including boosts

**When Called**

When checking character stats or calculating bonuses

---

### getBoost

**Purpose**

Gets the boost table for a specific attribute

**When Called**

When checking or modifying attribute boosts

---

### doesRecognize

**Purpose**

Checks if the character recognizes another character by ID

**When Called**

When determining if one character knows another character's identity

---

### doesFakeRecognize

**Purpose**

Checks if the character has fake recognition of another character

**When Called**

When determining if character knows a fake name for another character

---

### setData

**Purpose**

Sets character data and optionally syncs it to database and clients

**When Called**

When storing character-specific data that needs persistence

---

### getData

**Purpose**

Retrieves character data by key or returns all data

**When Called**

When accessing stored character-specific data

---

### isBanned

**Purpose**

Checks if the character is currently banned

**When Called**

When validating character access or checking ban status

---

### recognize

**Purpose**

Makes the character recognize another character (with optional fake name)

**When Called**

When establishing recognition between characters

---

### joinClass

**Purpose**

Makes the character join a specific class (faction job)

**When Called**

When changing character class or job within their faction

---

### kickClass

**Purpose**

Removes the character from their current class and assigns default class

**When Called**

When removing character from their current job or class

---

### updateAttrib

**Purpose**

Updates a character attribute by adding to the current value

**When Called**

When modifying character stats through gameplay or admin actions

---

### setAttrib

**Purpose**

Sets a character attribute to a specific value

**When Called**

When setting character stats to exact values

---

### addBoost

**Purpose**

Adds a temporary boost to a character attribute

**When Called**

When applying temporary stat bonuses from items, spells, or effects

---

### removeBoost

**Purpose**

Removes a temporary boost from a character attribute

**When Called**

When removing temporary stat bonuses from items, spells, or effects

---

### setFlags

**Purpose**

Sets the character flags to a specific string

**When Called**

When changing character permissions or access rights

---

### giveFlags

**Purpose**

Adds flags to the character without removing existing ones

**When Called**

When granting additional permissions to a character

---

### takeFlags

**Purpose**

Removes flags from the character

**When Called**

When revoking permissions or access rights from a character

---

### save

**Purpose**

Saves the character data to the database

**When Called**

When persisting character changes to the database

---

### sync

**Purpose**

Synchronizes character data with clients

**When Called**

When updating character information on client side

---

### setup

**Purpose**

Sets up the character for the player (model, team, inventory, etc.)

**When Called**

When loading a character for a player

---

### kick

**Purpose**

Kicks the character from the server

**When Called**

When removing a character from the game

---

### ban

**Purpose**

Bans the character for a specified time or permanently

**When Called**

When applying a ban to a character

**Parameters**

* `char:ban(3600)` (*unknown*): - 1 hour ban

---

### delete

**Purpose**

Deletes the character from the database

**When Called**

When permanently removing a character

---

### destroy

**Purpose**

Destroys the character object and removes it from memory

**When Called**

When cleaning up character data from memory

---

### giveMoney

**Purpose**

Gives money to the character

**When Called**

When adding money to a character's account

---

### takeMoney

**Purpose**

Takes money from the character

**When Called**

When removing money from a character's account

**Parameters**

* `logMoneyTransaction(char,` (*unknown*): amount, "purchase")

---

