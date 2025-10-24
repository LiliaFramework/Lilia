# DarkRP Compatibility Library

The DarkRP compatibility library provides essential functions for maintaining compatibility

---

### isEmpty

**Purpose**

Checks if a given position is empty and suitable for spawning entities or players

**When Called**

Called when checking spawn positions, entity placement, or any position validation

**Parameters**

* `position` (*Vector*): The world position to check
* `entitiesToIgnore` (*table, optional*): Table of entities to ignore during the check

---

### findEmptyPos

**Purpose**

Finds the nearest empty position to a starting position within specified parameters

**When Called**

Called when spawning entities or players and the initial position is occupied

**Parameters**

* `startPos` (*Vector*): The starting position to search from
* `entitiesToIgnore` (*table, optional*): Table of entities to ignore during the search
* `maxDistance` (*number*): Maximum distance to search from the starting position
* `searchStep` (*number*): Step size for the search radius
* `checkArea` (*Vector*): Additional area to check around each position

---

### notify

**Purpose**

Sends a localized notification to a client (DarkRP compatibility function)

**When Called**

Called when sending notifications to players in DarkRP-compatible systems

**Parameters**

* `client` (*Player*): The player to send the notification to
* `_` (*any*): Unused parameter (DarkRP compatibility)
* `_` (*any*): Unused parameter (DarkRP compatibility)
* `message` (*string*): The localized message key to send

---

### textWrap

**Purpose**

Wraps text to fit within a specified maximum line width using font metrics

**When Called**

Called when displaying text in UI elements that need to fit within width constraints

**Parameters**

* `text` (*string*): The text to wrap
* `fontName` (*string*): The font name to use for width calculations
* `maxLineWidth` (*number*): The maximum width in pixels for each line

---

### formatMoney

**Purpose**

Formats a numeric amount as currency using the Lilia currency system

**When Called**

Called when displaying money amounts in UI or chat messages

**Parameters**

* `amount` (*number*): The numeric amount to format
* `print(formatted)` (*unknown*): - "$1,000"

---

### createEntity

**Purpose**

Creates a DarkRP-compatible entity item in the Lilia item system

**When Called**

Called when registering DarkRP entities for compatibility with existing addons

**Parameters**

* `name` (*string*): The display name of the entity
* `data` (*table*): Table containing entity configuration data
* `cmd` (*string, optional*): Command name for the entity
* `model` (*string, optional*): Model path for the entity
* `desc` (*string, optional*): Description of the entity
* `category` (*string, optional*): Category for the entity
* `ent` (*string, optional*): Entity class name
* `price` (*number, optional*): Price of the entity

---

### createCategory

**Purpose**

Creates a DarkRP-compatible category (placeholder function for compatibility)

**When Called**

Called by DarkRP addons that expect a createCategory function to exist

---

### lia.DarkRP.removeChatCommand

**Purpose**

Creates a DarkRP-compatible category (placeholder function for compatibility)

**When Called**

Called by DarkRP addons that expect a createCategory function to exist

---

### lia.DarkRP.defineChatCommand

**Purpose**

Creates a DarkRP-compatible category (placeholder function for compatibility)

**When Called**

Called by DarkRP addons that expect a createCategory function to exist

---

### lia.DarkRP.definePrivilegedChatCommand

**Purpose**

Creates a DarkRP-compatible category (placeholder function for compatibility)

**When Called**

Called by DarkRP addons that expect a createCategory function to exist

---

