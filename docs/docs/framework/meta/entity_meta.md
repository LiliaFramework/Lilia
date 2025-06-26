## isProp

**Description:**
    Returns true if the entity is a physics prop.

---

### Parameters

---

### Returns

    * boolean – Whether the entity is a physics prop.

---

**Realm:**
    Shared

---

## isItem

**Description:**
    Checks if the entity is an item entity.

---

### Parameters

---

### Returns

    * boolean – True if the entity represents an item.

---

**Realm:**
    Shared

---

## isMoney

**Description:**
    Checks if the entity is a money entity.

---

### Parameters

---

### Returns

    * boolean – True if the entity represents money.

---

**Realm:**
    Shared

---

## isSimfphysCar

**Description:**
    Checks if the entity is a simfphys car.

---

### Parameters

---

### Returns

    * boolean – True if this is a simfphys vehicle.

---

**Realm:**
    Shared

---

## isLiliaPersistent

**Description:**
    Determines if the entity is persistent in Lilia.

---

### Parameters

---

### Returns

    * boolean – Whether the entity should persist.

---

**Realm:**
    Shared

---

## checkDoorAccess

**Description:**
    Checks if a player has the given door access level.

---

### Parameters

    * client (Player) – The player to check.
    * access (number, optional) – Door permission level.

---

### Returns

    * boolean – True if the player has access.

---

**Realm:**
    Shared

---

## keysOwn

**Description:**
    Assigns the entity to the specified player.

---

### Parameters

    * client (Player) – Player to set as owner.

---

### Returns

---

**Realm:**
    Shared

---

## keysLock

**Description:**
    Locks the entity if it is a vehicle.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## keysUnLock

**Description:**
    Unlocks the entity if it is a vehicle.

---

### Parameters

---

### Returns

---

**Realm:**
    Shared

---

## getDoorOwner

**Description:**
    Returns the player that owns this door if available.

---

### Parameters

---

### Returns

    * Player|nil – Door owner or nil.

---

**Realm:**
    Shared

---

## isLocked

**Description:**
    Returns the locked state stored in net variables.

---

### Parameters

---

### Returns

    * boolean – Whether the door is locked.

---

**Realm:**
    Shared

---

## isDoorLocked

**Description:**
    Checks the internal door locked state.

---

### Parameters

---

### Returns

    * boolean – True if the door is locked.

---

**Realm:**
    Shared

---

## getEntItemDropPos

**Description:**
    Calculates a drop position in front of the entity's eyes.

---

### Parameters

    * offset (number) – Distance from the player eye position.

---

### Returns

    * Vector – Drop position and angle.

---

**Realm:**
    Shared

---

## isNearEntity

**Description:**
    Checks for another entity of the same class nearby.

---

### Parameters

    * radius (number) – Sphere radius in units.
    * otherEntity (Entity, optional) – Specific entity to look for.

---

### Returns

    * boolean – True if another entity is within radius.

---

**Realm:**
    Shared

---

## GetCreator

**Description:**
    Returns the entity creator player.

---

### Parameters

---

### Returns

    * Player|nil – Creator player if stored.

---

**Realm:**
    Shared

---

## SetCreator

**Description:**
    Stores the creator player on the entity.

---

### Parameters

    * client (Player) – Creator of the entity.

---

### Returns

---

**Realm:**
    Server

---

## sendNetVar

**Description:**
    Sends a network variable to recipients.

---

### Parameters

    * key (string) – Identifier of the variable.
    * receiver (Player|nil) – Who to send to.

---

### Returns

---

**Realm:**
    Server

---

**Internal:**
    Used by the networking system.

---

## clearNetVars

**Description:**
    Clears all network variables on this entity.

---

### Parameters

    * receiver (Player|nil) – Receiver to notify.

---

### Returns

---

**Realm:**
    Server

---

## removeDoorAccessData

**Description:**
    Clears all stored door access information.

---

### Parameters

---

### Returns

---

**Realm:**
    Server

---

## setLocked

**Description:**
    Stores the door locked state in network variables.

---

### Parameters

    * state (boolean) – New locked state.

---

### Returns

---

**Realm:**
    Server

---

## isDoor

**Description:**
    Returns true if the entity's class indicates a door.

---

### Parameters

---

### Returns

    * boolean – Whether the entity is a door.

---

**Realm:**
    Server

---

## getDoorPartner

**Description:**
    Returns the partner door linked with this entity.

---

### Parameters

---

### Returns

    * Entity|nil – The partnered door.

---

**Realm:**
    Server

---

## setNetVar

**Description:**
    Updates a network variable and sends it to recipients.

---

### Parameters

    * key (string) – Variable name.
    * value (any) – Value to store.
    * receiver (Player|nil) – Who to send update to.

---

### Returns

---

**Realm:**
    Server

---

## getNetVar

**Description:**
    Retrieves a stored network variable or a default value.

---

### Parameters

    * key (string) – Variable name.
    * default (any) – Value returned if variable is nil.

---

### Returns

    * any – Stored value or default.

---

**Realm:**
    Server
Client

---

## isDoor

**Description:**
    Client-side door check using class name.

---

### Parameters

---

### Returns

    * boolean – True if entity class contains "door".

---

**Realm:**
    Client

---

## getDoorPartner

**Description:**
    Attempts to find the door partnered with this one.

---

### Parameters

---

### Returns

    * Entity|nil – The partner door entity.

---

**Realm:**
    Client

---

## getNetVar

**Description:**
    Retrieves a network variable for this entity on the client.

---

### Parameters

    * key (string) – Variable name.
    * default (any) – Default if not set.

---

### Returns

    * any – Stored value or default.

---

**Realm:**
    Client

---

