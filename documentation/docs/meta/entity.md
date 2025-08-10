# Entity Meta

Entities in Garry's Mod may represent props, items, and interactive objects.

This reference describes utility functions added to entity metatables for easier classification and management.

---

## Overview

The entity-meta library extends Garry's Mod entities with helpers for detection, door access, persistence, and networked variables.
Using these functions ensures consistent behavior when handling game objects across Lilia.

> **Note**
> Every helper verifies that the entity is valid before proceeding. If the entity is invalid, the function returns a default value or performs no action.

---

### isProp

**Purpose**

Checks if the entity is a physics prop.

**Parameters**

* None

**Returns**

* `boolean`: `true` when the entity's class is `prop_physics`.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isProp() then
    ent:TakeDamage(50)
end
```

---

### isItem

**Purpose**

Checks if the entity is an item entity (`lia_item`).

**Parameters**

* None

**Returns**

* `boolean`: `true` if the entity represents an item.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isItem() then
    lia.item.pickup(client, ent)
end
```

---

### isMoney

**Purpose**

Checks if the entity is a money entity (`lia_money`).

**Parameters**

* None

**Returns**

* `boolean`: `true` if the entity represents money.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isMoney() then
    char:addMoney(ent:getAmount())
end
```

---

### isSimfphysCar

**Purpose**

Determines whether this entity is a simfphys or LVS vehicle.

**Parameters**

* None

**Returns**

* `boolean`: `true` if the entity's class or base matches known simfphys classes or it contains the `IsSimfphyscar`/`LVS` flag.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isSimfphysCar() then
    print("Simfphys vehicle detected")
end
```

---

### isLiliaPersistent

**Purpose**

Checks if the entity should persist across sessions in Lilia.

**Parameters**

* None

**Returns**

* `boolean`: `true` if `GetPersistent()` returns `true` or the entity has `IsLeonNPC` or `IsPersistent` flags.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isLiliaPersistent() then
    -- Entity will be saved between map resets
end
```

---

### checkDoorAccess

**Purpose**

Checks whether `client` has at least the given access level on the door. The hook `CanPlayerAccessDoor` is consulted first, then the door's `liaAccess` table.

**Parameters**

* `client` (`Player`): Player to check.
* `access` (`number`, optional): Access level to test, defaults to `DOOR_GUEST`.

**Returns**

* `boolean`: `true` if the player may access the door.

**Realm**

`Shared`

**Example Usage**

```lua
if not door:checkDoorAccess(client, DOOR_GUEST) then
    client:notifyLocalized("doorLocked")
end
```

---

### keysOwn

**Purpose**

If the entity is a vehicle, assigns ownership to the provided player using CPPI and sets the `owner` and `ownerName` network variables.

**Parameters**

* `client` (`Player`): New owner.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
car:keysOwn(client)
```

---

### keysLock

**Purpose**

If the entity is a vehicle, locks it by firing the `lock` input.

**Parameters**

* None

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
car:keysLock()
```

---

### keysUnLock

**Purpose**

If the entity is a vehicle, unlocks it by firing the `unlock` input.

**Parameters**

* None

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Shared`

**Example Usage**

```lua
car:keysUnLock()
```

---

### getDoorOwner

**Purpose**

Returns the result of `CPPIGetOwner()` when the entity is a vehicle that supports CPPI.

**Parameters**

* None

**Returns**

* `Player|nil`: The owner of the vehicle, or `nil` if unavailable.

**Realm**

`Shared`

**Example Usage**

```lua
local owner = car:getDoorOwner()
if owner then
    print("Owned by", owner:Name())
end
```

---

### isLocked

**Purpose**

Checks the `locked` network variable and returns its boolean state.

**Parameters**

* None

**Returns**

* `boolean`: `true` if the entity is locked.

**Realm**

`Shared`

**Example Usage**

```lua
if door:isLocked() then
    DrawLockedIcon(door)
end
```

---

### isDoorLocked

**Purpose**

Checks `GetInternalVariable("m_bLocked")` or the fallback `locked` field for door entities.

**Parameters**

* None

**Returns**

* `boolean`: `true` if the door reports itself as locked.

**Realm**

`Shared`

**Example Usage**

```lua
if door:isDoorLocked() then
    door:EmitSound("doors/door_locked2.wav")
end
```

---

### getEntItemDropPos

**Purpose**

Calculates a safe drop position in front of the entity's eyes.

**Parameters**

* `offset` (`number`, optional): Distance to trace forward. Defaults to `64` units.

**Returns**

* `Vector`, `Angle`: The drop position and surface normal angle. Returns `(0, 0, 0)` and `Angle(0, 0, 0)` if the entity is invalid.

**Realm**

`Shared`

**Example Usage**

```lua
local pos, ang = ent:getEntItemDropPos(16)
lia.item.spawn("item_water", pos, ang)
```

---

### isNearEntity

**Purpose**

Checks for another entity within a radius. If `otherEntity` is supplied, only that entity will satisfy the check; otherwise any entity of the same class will.

**Parameters**

* `radius` (`number`, optional): Search radius in units. Defaults to `96`.
* `otherEntity` (`Entity`, optional): Specific entity to look for.

**Returns**

* `boolean`: `true` if a matching entity is nearby. Always `true` when `otherEntity` is the entity itself.

**Realm**

`Shared`

**Example Usage**

```lua
if ent:isNearEntity(128, otherChest) then
    client:notifyLocalized("chestTooClose")
end
```

---

### GetCreator

**Purpose**

Returns the player stored in the `creator` network variable.

**Parameters**

* None

**Returns**

* `Player|nil`: Creator player if stored.

**Realm**

`Shared`

**Example Usage**

```lua
local creator = ent:GetCreator()
if IsValid(creator) then
    creator:notifyLocalized("propRemoved")
end
```

---

### SetCreator

**Purpose**

Stores the creator player in the entity's `creator` network variable for later retrieval.

**Parameters**

* `client` (`Player`): Creator of the entity.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:SetCreator(client)
```

---

### sendNetVar

**Purpose**

Serializes the value stored in `lia.net[self][key]` and sends it to a specific player or broadcasts it to all clients.

**Parameters**

* `key` (`string`): Identifier of the variable.
* `receiver` (`Player|nil`, optional): Player to send to. Broadcasts if omitted.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:sendNetVar("doorState")
```

---

### clearNetVars

**Purpose**

Removes all entries from `lia.net[self]` and sends an `nDel` message to clients to clear their copies.

**Parameters**

* `receiver` (`Player|nil`, optional): Receiver to notify. Broadcasts if omitted.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:clearNetVars(client)
```

---

### removeDoorAccessData

**Purpose**

Clears the door's access data, notifies each affected player, and resets `liaAccess` and `DTEntity(0)`.

**Parameters**

* None

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:removeDoorAccessData()
```

---

### setLocked

**Purpose**

Sets the networked `locked` state of the entity using `setNetVar`.

**Parameters**

* `state` (`boolean`): New locked state.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
door:setLocked(true)
```

---

### setKeysNonOwnable

**Purpose**

Marks the entity as non-ownable by setting the `noSell` network variable, preventing players from purchasing it.

**Parameters**

* `state` (`boolean`): Whether the entity should be non-ownable.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:setKeysNonOwnable(true)
```

---

### isDoor *(Server)*

**Purpose**

Checks if the entity's class name begins with one of the prefixes `prop_door`, `func_door`, `func_door_rotating`, or `door_`.

**Parameters**

* None

**Returns**

* `boolean`: `true` if the entity is recognized as a door.

**Realm**

`Server`

**Example Usage**

```lua
if ent:isDoor() then
    print("This is a door!")
end
```

---

### getDoorPartner *(Server)*

**Purpose**

Returns the door entity linked as this one's partner via `liaPartner`. This function simply returns the stored value and does not perform a search.

**Parameters**

* None

**Returns**

* `Entity|nil`: Partner door entity.

**Realm**

`Server`

**Example Usage**

```lua
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:setLocked(false)
end
```

---

### setNetVar

**Purpose**

Updates a networked variable and notifies recipients. Unsupported types are ignored via `checkBadType`. Triggers the `NetVarChanged` hook when the value changes.

**Parameters**

* `key` (`string`): Variable name.
* `value` (`any`): Value to store.
* `receiver` (`Player|nil`, optional): Player to send the update to. Broadcasts if omitted.

**Returns**

* `nil`: This function does not return a value.

**Realm**

`Server`

**Example Usage**

```lua
ent:setNetVar("locked", true)
```

---

### getNetVar *(Server)*

**Purpose**

Retrieves a stored networked variable from `lia.net[self]` or returns the provided default.

**Parameters**

* `key` (`string`): Variable name.
* `default` (`any`): Value returned if the variable is not set.

**Returns**

* `any`: Stored value or the provided default.

**Realm**

`Server`

**Example Usage**

```lua
local locked = ent:getNetVar("locked", false)
```

### isDoor *(Client)*

**Purpose**

Client-side check using `self:GetClass():find("door")` to see if the entity's class name contains "door".

**Parameters**

* None

**Returns**

* `boolean`: `true` if the class name contains "door".

**Realm**

`Client`

**Example Usage**

```lua
if ent:isDoor() then
    print("Door detected on client")
end
```

---

### getDoorPartner *(Client)*

**Purpose**

Returns `GetOwner()` or a cached `liaDoorOwner` if it is a valid door; otherwise searches for a `prop_door_rotating` owned by this entity and caches the result.

**Parameters**

* None

**Returns**

* `Entity|nil`: The partner door entity, if found.

**Realm**

`Client`

**Example Usage**

```lua
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:SetColor(Color(0, 255, 0))
end
```

---

### getNetVar *(Client)*

**Purpose**

Retrieves a networked variable for this entity from `lia.net[self:EntIndex()]` on the client.

**Parameters**

* `key` (`string`): Variable name.
* `default` (`any`): Value returned if the variable is not set.

**Returns**

* `any`: Stored value or the provided default.

**Realm**

`Client`

**Example Usage**

```lua
local locked = ent:getNetVar("locked", false)
```
