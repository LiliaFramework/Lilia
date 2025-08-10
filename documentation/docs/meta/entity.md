# Entity Meta

Entities in Garry's Mod may represent props, items, and interactive objects.

This reference describes utility functions added to entity metatables for easier classification and management.

> **Note**
> Every helper verifies that the entity is valid before proceeding. If the entity is invalid, the function returns a default value or performs no action.

---

### isProp

**Purpose**
Checks if the entity is a physics prop.

**Parameters**
- None

**Returns**
- boolean - True if the entity is a physics prop, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isProp() then
print("This is a prop!")
end
```

---

### isItem

**Purpose**
Checks if the entity is an item entity.

**Parameters**
- None

**Returns**
- boolean - True if the entity is an item, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isItem() then
print("This is an item!")
end
```

---

### isMoney

**Purpose**
Checks if the entity is a money entity.

**Parameters**
- None

**Returns**
- boolean - True if the entity is money, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isMoney() then
print("This is money!")
end
```

---

### isSimfphysCar

**Purpose**
Checks if the entity is a simfphys or LVS vehicle.

**Parameters**
- None

**Returns**
- boolean - True if the entity is a simfphys or LVS vehicle, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isSimfphysCar() then
print("This is a simfphys/LVS car!")
end
```

---

### isLiliaPersistent

**Purpose**
Checks if the entity is persistent in the Lilia framework.

**Parameters**
- None

**Returns**
- boolean - True if the entity is persistent, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isLiliaPersistent() then
print("This entity is persistent!")
end
```

---

### checkDoorAccess

**Purpose**
Checks if the given client has the specified access level to the door entity.

**Parameters**
- client (Player) - The player to check access for.
- access (number) - The access level to check (optional, defaults to DOOR_GUEST).

**Returns**
- boolean - True if the client has access, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if door:checkDoorAccess(client, DOOR_OWNER) then
print("Client can access the door!")
end
```

---

### keysOwn

**Purpose**
Assigns ownership of the vehicle entity to the given client.

**Parameters**
- client (Player) - The player to set as the owner.

**Realm**
Shared.

**Example Usage**
```lua
vehicle:keysOwn(client)
```

---

### keysLock

**Purpose**
Locks the vehicle entity.

**Parameters**
- None

**Realm**
Shared.

**Example Usage**
```lua
vehicle:keysLock()
```

---

### keysUnLock

**Purpose**
Unlocks the vehicle entity.

**Parameters**
- None

**Realm**
Shared.

**Example Usage**
```lua
vehicle:keysUnLock()
```

---

### getDoorOwner

**Purpose**
Returns the owner of the vehicle entity if available.

**Parameters**
- None

**Returns**
- Player or nil - The owner of the vehicle, or nil if not available.

**Realm**
Shared.

**Example Usage**
```lua
local owner = vehicle:getDoorOwner()
if owner then print("Owner found!") end
```

---

### isLocked

**Purpose**
Checks if the entity is locked according to its networked variable.

**Parameters**
- None

**Returns**
- boolean - True if locked, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isLocked() then
print("Entity is locked!")
end
```

---

### isDoorLocked

**Purpose**
Checks if the door entity is locked according to its internal variable or fallback.

**Parameters**
- None

**Returns**
- boolean - True if locked, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if door:isDoorLocked() then
print("Door is locked!")
end
```

---

### getEntItemDropPos

**Purpose**
Calculates the position and angle where an item should be dropped from the entity.

**Parameters**
- offset (number) - The distance from the entity to drop the item (optional, defaults to 64).

**Returns**
- Vector, Angle - The position and angle for item drop.

**Realm**
Shared.

**Example Usage**
```lua
local pos, ang = entity:getEntItemDropPos(128)
```

---

### isNearEntity

**Purpose**
Checks if another entity is within a certain radius of this entity.

**Parameters**
- radius (number) - The radius to check within (optional, defaults to 96).
- otherEntity (Entity) - The entity to check proximity to.

**Returns**
- boolean - True if the other entity is near, false otherwise.

**Realm**
Shared.

**Example Usage**
```lua
if entity:isNearEntity(128, otherEntity) then
print("Other entity is nearby!")
end
```

---

### GetCreator

**Purpose**
Returns the creator of the entity from its networked variable.

**Parameters**
- None

**Returns**
- Player or nil - The creator of the entity, or nil if not set.

**Realm**
Shared.

**Example Usage**
```lua
local creator = entity:GetCreator()
if creator then print("Creator found!") end
```

---

### SetCreator

**Purpose**
Sets the creator of the entity in its networked variable.

**Parameters**
- client (Player) - The player to set as the creator.

**Realm**
Server.

**Example Usage**
```lua
entity:SetCreator(client)
```

---

### sendNetVar

**Purpose**
Sends a networked variable to a specific receiver or broadcasts it.

**Parameters**
- key (string) - The key of the variable to send.
- receiver (Player) - The player to send the variable to (optional).

**Realm**
Server.

**Example Usage**
```lua
entity:sendNetVar("locked", client)
```

---

### clearNetVars

**Purpose**
Clears all networked variables for the entity and notifies clients.

**Parameters**
- receiver (Player) - The player to send the clear notification to (optional).

**Realm**
Server.

**Example Usage**
```lua
entity:clearNetVars(client)
```

---

### removeDoorAccessData

**Purpose**
Removes all door access data for the entity and notifies clients.

**Parameters**
- None

**Realm**
Server.

**Example Usage**
```lua
door:removeDoorAccessData()
```

---

### setLocked

**Purpose**
Sets the locked state of the entity.

**Parameters**
- state (boolean) - The locked state to set.

**Realm**
Server.

**Example Usage**
```lua
entity:setLocked(true)
```

---

### setKeysNonOwnable

**Purpose**
Sets whether the entity is non-ownable.

**Parameters**
- state (boolean) - The non-ownable state to set.

**Realm**
Server.

**Example Usage**
```lua
entity:setKeysNonOwnable(true)
```

---

### isDoor

**Purpose**
Checks if the entity is a door.

**Parameters**
- None

**Returns**
- boolean - True if the entity is a door, false otherwise.

**Realm**
Server.

**Example Usage**
```lua
if entity:isDoor() then
print("This is a door!")
end
```

---

### getDoorPartner

**Purpose**
Returns the partner door entity if available.

**Parameters**
- None

**Returns**
- Entity or nil - The partner door entity, or nil if not set.

**Realm**
Server.

**Example Usage**
```lua
local partner = door:getDoorPartner()
if partner then print("Partner door found!") end
```

---

### setNetVar

**Purpose**
Sets a networked variable for the entity and notifies clients.

**Parameters**
- key (string) - The key of the variable.
- value (any) - The value to set.
- receiver (Player) - The player to send the update to (optional).

**Realm**
Server.

**Example Usage**
```lua
entity:setNetVar("locked", true)
```

---

### getNetVar

**Purpose**
Gets a networked variable for the entity.

**Parameters**
- key (string) - The key of the variable.
- default (any) - The default value to return if not set.

**Returns**
- any - The value of the networked variable, or the default if not set.

**Realm**
Server.

**Example Usage**
```lua
local locked = entity:getNetVar("locked", false)
```

---

### isDoor

**Purpose**
Checks if the entity is a door.

**Parameters**
- None

**Returns**
- boolean - True if the entity is a door, false otherwise.

**Realm**
Client.

**Example Usage**
```lua
if entity:isDoor() then
print("This is a door!")
end
```

---

### getDoorPartner

**Purpose**
Returns the partner door entity if available.

**Parameters**
- None

**Returns**
- Entity or nil - The partner door entity, or nil if not set.

**Realm**
Client.

**Example Usage**
```lua
local partner = door:getDoorPartner()
if partner then print("Partner door found!") end
```

---

### getNetVar

**Purpose**
Gets a networked variable for the entity.

**Parameters**
- key (string) - The key of the variable.
- default (any) - The default value to return if not set.

**Returns**
- any - The value of the networked variable, or the default if not set.

**Realm**
Client.

**Example Usage**
```lua
local locked = entity:getNetVar("locked", false)
```

---
