# Entity Meta

Entities in Garry's Mod may represent props, items, and interactive objects. This reference describes utility functions added to entity metatables for easier classification and management.

---

## Overview

The entity meta library extends Garry's Mod entities with helpers for detection, network-safe data, and item information. Using these functions ensures consistent behavior when handling game objects across Lilia.

---

### isProp

**Purpose**
Returns true if the entity is a physics prop.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: Whether the entity is a physics prop.

**Example**

```lua
-- Apply physics damage only if this is a prop
if ent:isProp() then
    ent:TakeDamage(50)
end
```

---

### isItem

**Purpose**
Checks if the entity is an item entity.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: True if the entity represents an item.

**Example**

```lua
-- Attempt to pick up the entity as an item
if ent:isItem() then
    lia.item.pickup(client, ent)
end
```

---

### isMoney

**Purpose**
Checks if the entity is a money entity.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: True if the entity represents money.

**Example**

```lua
-- Collect money dropped on the ground
if ent:isMoney() then
    char:addMoney(ent:getAmount())
end
```

---

### isSimfphysCar

**Purpose**
Returns true if this entity is recognized as a simfphys or LVS vehicle.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: True if this is a simfphys vehicle.

**Example**

```lua
if ent:isSimfphysCar() then
    print("Simfphys vehicle detected")
end
```

---

### isLiliaPersistent

**Purpose**
Determines if the entity is persistent in Lilia.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: Whether the entity should persist.

**Example**

```lua
-- Save this entity across map resets if persistent
if ent:isLiliaPersistent() then
    lia.persist.saveEntity(ent)
end
```

---

### checkDoorAccess

**Purpose**
Checks if a player has the given door access level. Defaults to `DOOR_GUEST` when no access level is provided.

**Parameters**

- `client` (`Player`): The player to check.
- `access` (`number, optional`) – Door permission level. Defaults to DOOR_GUEST.

**Realm**
`Shared`

**Returns**

- boolean: True if the player has access.

**Example**

```lua
-- Block a player from opening the door without access
if not door:checkDoorAccess(client, DOOR_ACCESS_OPEN) then
    client:notifyLocalized("doorLocked")
end
```

---

### keysOwn

**Purpose**
Assigns vehicle ownership to the given player using CPPI and network variables.

**Parameters**

- `client` (`Player`): Player to set as owner.

**Realm**
`Shared`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Assign ownership when a player buys the vehicle
car:keysOwn(client)
```

---

### keysLock

**Purpose**
Triggers the `lock` input on the entity if it is a vehicle.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Lock the vehicle after the driver exits
car:keysLock()
```

---

### keysUnLock

**Purpose**
Triggers the `unlock` input on the entity if it is a vehicle.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Unlock the vehicle when the owner presses a key
car:keysUnLock()
```

---

### getDoorOwner

**Purpose**
Returns the CPPI owner of this vehicle if one is assigned.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- Player|None: Door owner or None.

**Example**

```lua
-- Print the name of the door owner when inspecting
local owner = car:getDoorOwner()
if owner then
    print("Owned by", owner:Name())
end
```

---

### isLocked

**Purpose**
Reads the locked state previously set with `setLocked`.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: Whether the door is locked.

**Example**

```lua
-- Display a lock icon if the door is networked as locked
if door:isLocked() then
    DrawLockedIcon(door)
end
```

---

### isDoorLocked

**Purpose**
Checks the door's internal lock flag (m_bLocked).

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- boolean: True if the door is locked.

**Example**

```lua
-- Play a sound when trying to open a locked door server-side
if door:isDoorLocked() then
    door:EmitSound("doors/door_locked2.wav")
end
```

---

### getEntItemDropPos

**Purpose**
Calculates a drop position in front of the entity's eyes, using a trace to ensure the point is unobstructed.

**Parameters**

- `offset` (`number`): How far forward to trace from the eye position. Defaults to 64.

**Realm**
`Shared`

**Returns**

- Vector, Angle: Drop position and eye angle.

**Example**

```lua
-- Spawn an item drop in front of the entity's eyes
local pos, ang = ent:getEntItemDropPos(16)
lia.item.spawn("item_water", pos, ang)
```

---

### isNearEntity

**Purpose**
Checks if another entity of the same class is within the given radius. Optionally matches against a specific entity.

**Parameters**

- `radius` (`number`): Sphere radius in units. Defaults to 96.
- `otherEntity` (`Entity, optional`) – Specific entity to look for.

**Realm**
`Shared`

**Returns**

- boolean: True if another entity is within radius.

**Example**

```lua
-- Prevent building too close to another chest
if ent:isNearEntity(128, otherChest) then
    client:notifyLocalized("chestTooClose")
end
```

---

### GetCreator

**Purpose**
Returns the entity creator player.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- Player|None: Creator player if stored.

**Example**

```lua
-- Credit the creator when the entity is removed
local creator = ent:GetCreator()
if IsValid(creator) then
    creator:notifyLocalized("propRemoved")
end
```

---

### SetCreator

**Purpose**
Stores the creator player on the entity.

**Parameters**

- `client` (`Player`): Creator of the entity.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Record the spawner for cleanup tracking
ent:SetCreator(client)
```

---

### sendNetVar

**Purpose**
Sends the specified network variable to clients. This is usually called from `setNetVar`.

**Parameters**

- `key` (`string`): Identifier of the variable.
- `receiver` (`Player|None, optional`) – Player to send to. Broadcasts if omitted.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
ent:sendNetVar("doorState")
```

---

### clearNetVars

**Purpose**
Clears all network variables on this entity and tells clients to remove them.

**Parameters**

- `receiver` (`Player|None, optional`): Receiver to notify. Broadcasts if omitted.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
ent:clearNetVars(client)
```

---

### removeDoorAccessData

**Purpose**
Clears the door's saved access table and informs all clients.

**Parameters**

- None

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Wipe door permissions during cleanup
ent:removeDoorAccessData()
```

---

### setLocked

**Purpose**
Stores the locked state in a network variable so clients know if the door is secured.

**Parameters**

- `state` (`boolean`): New locked state.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
-- Toggle the door lock and play a latch sound for everyone
door:setLocked(true)
door:EmitSound("doors/door_latch3.wav")
```

---

### isDoor

**Purpose**
Checks the entity's class for common door prefixes to determine if it is a door.

**Parameters**

- None

**Realm**
`Server`

**Returns**

- boolean: Whether the entity is a door.

**Example**

```lua
-- Check if the entity behaves like a door
local result = ent:isDoor()
```

---

### getDoorPartner

**Purpose**
Returns the door entity linked as this one's partner via `liaPartner`.

**Parameters**

- None

**Realm**
`Server`

**Returns**

- Entity|None: The partnered door.

**Example**

```lua
-- Unlock both doors when opening a double-door setup
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:setLocked(false)
end
```

---

### setNetVar

**Purpose**
Updates a network variable and sends it to recipients. This will trigger the **NetVarChanged** hook on both server and client.

**Parameters**

- `key` (`string`): Variable name.
- `value` (`any`) – Value to store.
- `receiver` (`Player|None, optional`) – Who to send update to. Broadcasts if omitted.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
ent:setNetVar("locked", true)
```

---

### getNetVar

**Purpose**
Retrieves a stored network variable or a default value.

**Parameters**

- `key` (`string`): Variable name.
- `default` (`any`) – Value returned if variable is nil.

**Realm**
`Server`

**Returns**

- nil

**Example**


---
- Client


Returns:
- any: Stored value or default.
Example Usage:
```lua
-- Retrieve the stored variable or fallback to the default
local result = ent:getNetVar(key, default)
```

---

### isDoor

**Purpose**
Client-side door check using class name.

**Parameters**

- None

**Realm**
`Client`

**Returns**

- boolean: True if entity class contains "door".

**Example**

```lua
-- Determine if this entity's class name contains "door"
local result = ent:isDoor()
```

---

### getDoorPartner

**Purpose**
Attempts to locate the door partnered with this one by checking its owner or linked prop.

**Parameters**

- None

**Realm**
`Client`

**Returns**

- Entity|None: The partner door entity.

**Example**

```lua
-- Highlight the partner door of the one being looked at
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:SetColor(Color(0, 255, 0))
end
```

---

### getNetVar

**Purpose**
Retrieves a network variable for this entity on the client.

**Parameters**

- `key` (`string`): Variable name.
- `default` (`any`) – Default if not set.

**Realm**
`Client`

**Returns**

- any: Stored value or default.

**Example**

```lua
-- Access a synced variable on the client side
local result = ent:getNetVar(key, default)
```

---

### getParts

**Purpose**
Retrieves the table of PAC3 part identifiers applied to this entity.

**Parameters**

- None

**Realm**
`Shared`

**Returns**

- table: The currently applied part IDs.

**Example**

```lua
function ENTITY:getParts()
    -- returns table
end
```
```lua
-- Print all equipped PAC3 parts for a player
for id in pairs(client:getParts()) do
    print(id)
end
```

---

### syncParts

**Purpose**
Broadcasts the entity's PAC3 part list to synchronize with clients.

**Parameters**

- None

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
function ENTITY:syncParts()
end
```
```lua
-- Resend parts when a player respawns
client:syncParts()
```

---

### addPart

**Purpose**
Attaches a PAC3 part to this entity and networks the change.

**Parameters**

- `partID` (`string`): Identifier for the PAC3 outfit to add.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
function ENTITY:addPart(partID)
end
```
```lua
-- Give the player a custom hat part
client:addPart("hat01")
```

---

### removePart

**Purpose**
Detaches a PAC3 part from this entity and updates clients.

**Parameters**

- `partID` (`string`): Identifier of the PAC3 outfit to remove.

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
function ENTITY:removePart(partID)
end
```
```lua
-- Remove the previously equipped hat part
client:removePart("hat01")
```

---

### resetParts

**Purpose**
Clears all PAC3 parts from this entity and notifies clients.

**Parameters**

- None

**Realm**
`Server`

**Returns**

- None: This function does not return a value.

**Example**

```lua
function ENTITY:resetParts()
end
```
```lua
-- Remove all PAC3 outfits from the player
client:resetParts()
```

---
