# Entity

This page documents the functions and methods in the meta table.

---

### EmitSound

**Purpose**

Emits a sound from the entity, with support for web sounds and URL-based audio

**When Called**

When an entity needs to play a sound effect or audio

**Parameters**

* `soundName` (*string*): The sound file path, URL, or websound identifier
* `soundLevel` (*number, optional*): Sound level/distance (default: 100)
* `pitchPercent` (*number, optional*): Pitch adjustment percentage
* `volume` (*number, optional*): Volume level (default: 100)
* `channel` (*number, optional*): Sound channel
* `flags` (*number, optional*): Sound flags
* `dsp` (*number, optional*): DSP effect

---

### isProp

**Purpose**

Checks if the entity is a physics prop

**When Called**

When you need to determine if an entity is a prop_physics object

---

### isItem

**Purpose**

Checks if the entity is a Lilia item entity

**When Called**

When you need to determine if an entity is a lia_item object

---

### isMoney

**Purpose**

Checks if the entity is a Lilia money entity

**When Called**

When you need to determine if an entity is a lia_money object

---

### isSimfphysCar

**Purpose**

Checks if the entity is a Simfphys vehicle or LVS vehicle

**When Called**

When you need to determine if an entity is a vehicle from Simfphys or LVS

---

### checkDoorAccess

**Purpose**

Checks if a client has access to a door with the specified access level

**When Called**

When you need to verify if a player can access a door

**Parameters**

* `client` (*Player*): The player to check access for
* `access` (*number, optional*): The required access level (default: DOOR_GUEST)

---

### keysOwn

**Purpose**

Sets a client as the owner of a vehicle and updates ownership data

**When Called**

When a player becomes the owner of a vehicle

**Parameters**

* `client` (*Player*): The player to set as the owner

---

### keysLock

**Purpose**

Locks a vehicle if it is a valid vehicle entity

**When Called**

When a player wants to lock their vehicle

---

### keysUnLock

**Purpose**

Unlocks a vehicle if it is a valid vehicle entity

**When Called**

When a player wants to unlock their vehicle

---

### getDoorOwner

**Purpose**

Gets the owner of a door entity

**When Called**

When you need to retrieve the owner of a door

---

### isLocked

**Purpose**

Checks if the entity is locked using network variables

**When Called**

When you need to check if an entity is in a locked state

---

### isDoorLocked

**Purpose**

Checks if a door entity is locked using internal variables or custom properties

**When Called**

When you need to check if a door is in a locked state

---

### getEntItemDropPos

**Purpose**

Calculates the position and angle for dropping items from an entity

**When Called**

When an entity needs to drop an item at a specific location

**Parameters**

* `offset` (*number, optional*): Distance to trace forward from entity (default: 64)

---

### isFemale

**Purpose**

Checks if the entity's model represents a female character

**When Called**

When you need to determine the gender of a character entity

---

### isNearEntity

**Purpose**

Checks if the entity is near another entity within a specified radius

**When Called**

When you need to check proximity between entities

**Parameters**

* `radius` (*number, optional*): Search radius in units (default: 96)
* `otherEntity` (*Entity, optional*): Specific entity to check for proximity

---

### getDoorPartner

**Purpose**

Gets the partner door entity for double doors

**When Called**

When you need to find the paired door in a double door setup

---

### sendNetVar

**Purpose**

Sends a network variable to clients via network message

**When Called**

When you need to synchronize entity data with clients

**Parameters**

* `key` (*string*): The network variable key to send
* `receiver` (*Player, optional*): Specific player to send to, or nil for all players

---

### clearNetVars

**Purpose**

Clears all network variables for the entity and notifies clients

**When Called**

When you need to remove all network data from an entity

**Parameters**

* `receiver` (*Player, optional*): Specific player to notify, or nil for all players

---

### removeDoorAccessData

**Purpose**

Removes all door access data and notifies clients to close door menus

**When Called**

When you need to clear all door access permissions and close related UIs

---

### setLocked

**Purpose**

Sets the locked state of an entity using network variables

**When Called**

When you need to lock or unlock an entity

**Parameters**

* `state` (*boolean*): True to lock, false to unlock

---

### setKeysNonOwnable

**Purpose**

Sets whether a vehicle can be owned or sold

**When Called**

When you need to make a vehicle non-ownable or ownable

**Parameters**

* `state` (*boolean*): True to make non-ownable, false to make ownable

---

### isDoor

**Purpose**

Checks if the entity is a door by examining its class name

**When Called**

When you need to determine if an entity is a door

---

### setNetVar

**Purpose**

Sets a network variable for the entity and synchronizes it with clients

**When Called**

When you need to store and sync data on an entity

**Parameters**

* `key` (*string*): The network variable key
* `value` (*any*): The value to store
* `receiver` (*Player, optional*): Specific player to send to, or nil for all players

---

### getNetVar

**Purpose**

Gets a network variable from the entity (server-side)

**When Called**

When you need to retrieve synchronized data from an entity on the server

**Parameters**

* `key` (*string*): The network variable key to retrieve
* `default` (*any, optional*): Default value if the key doesn't exist

---

### isDoor

**Purpose**

Checks if the entity is a door by examining its class name (client-side)

**When Called**

When you need to determine if an entity is a door on the client

---

### getNetVar

**Purpose**

Gets a network variable from the entity (client-side)

**When Called**

When you need to retrieve synchronized data from an entity on the client

**Parameters**

* `key` (*string*): The network variable key to retrieve
* `default` (*any, optional*): Default value if the key doesn't exist

---

### playFollowingSound

**Purpose**

Plays a sound that follows the entity with 3D positioning and distance attenuation

**When Called**

When you need to play a sound that moves with an entity

**Parameters**

* `soundPath` (*string*): Path to the sound file or URL
* `volume` (*number, optional*): Volume level (0-1, default: 1)
* `shouldFollow` (*boolean, optional*): Whether sound should follow entity (default: true)
* `maxDistance` (*number, optional*): Maximum audible distance (default: 1200)
* `startDelay` (*number, optional*): Delay before playing (default: 0)
* `minDistance` (*number, optional*): Minimum distance for full volume (default: 0)
* `pitch` (*number, optional*): Pitch multiplier (default: 1)
* `_` (*any, optional*): Unused parameter
* `dsp` (*number, optional*): DSP effect ID (default: 0)

---

