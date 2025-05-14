---

Physical objects in the game world.

Entities are physical representations of objects in the game world. Lilia extends the functionality of entities to interface between Lilia's own classes and to reduce boilerplate code.

See the [Garry's Mod Wiki](https://wiki.garrysmod.com/page/Category:Entity) for all other methods that the `Entity` class has.

---

## **entityMeta:isProp**

**Description**

Checks if the entity is a physics prop.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is a physics prop, `false` otherwise.

**Example**

```lua
if entity:isProp() then
    print("Entity is a physics prop.")
else
    print("Entity is not a physics prop.")
end
```

---

## **entityMeta:isItem**

**Description**

Checks if the entity is an item entity.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is an item entity, `false` otherwise.

**Example**

```lua
if entity:isItem() then
    print("Entity is an item.")
end
```

---

## **entityMeta:isMoney**

**Description**

Checks if the entity is a money entity.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is a money entity, `false` otherwise.

**Example**

```lua
if entity:isMoney() then
    print("Entity is money.")
end
```

---

## **entityMeta:isSimfphysCar**

**Description**

Checks if the entity is a simfphys car.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is a simfphys car, `false` otherwise.

**Example**

```lua
if entity:isSimfphysCar() then
    print("Entity is a simfphys car.")
end
```

---

## **entityMeta:getEntItemDropPos**

**Description**

Retrieves the drop position for an item associated with the entity.

**Realm**

`Shared`

**Returns**

- **Vector**: The drop position for the item.

**Example**

```lua
local dropPos = entity:getEntItemDropPos()
print("Item drop position:", dropPos)
```

---

## **entityMeta:isNearEntity**

**Description**

Checks if there is an entity near the current entity within a specified radius.

**Realm**

`Shared`

**Parameters**

- **radius** (`float`): The radius within which to check for nearby entities.

**Returns**

- **Boolean**: `true` if there is an entity nearby, `false` otherwise.

**Example**

```lua
if entity:isNearEntity(150) then
    print("There is an entity nearby.")
else
    print("No entities within the specified radius.")
end
```

---

## **entityMeta:GetCreator**

**Description**

Retrieves the creator of the entity.

**Realm**

`Shared`

**Returns**

- **Player|nil**: The player who created the entity, or `nil` if no valid creator is found.

**Example**

```lua
local creator = entity:GetCreator()
if creator then
    print("Entity was created by:", creator:Nick())
end
```

---

## **entityMeta:SetCreator**

**Description**

Assigns a creator to the entity.

**Realm**

`Server`

**Parameters**

- **client** (`Player`): The player to assign as the creator of the entity.

**Example**

```lua
entity:SetCreator(player)
```

---

## **entityMeta:sendNetVar**

**Description**

Sends a networked variable.

**Realm**

`Server`~

**Internal:**  

This function is intended for internal use and should not be called directly.

**Parameters**

- **key** (`String`): Identifier of the networked variable.
- **receiver** (`Player|nil`): The players to send the networked variable to.

**Example**

```lua
entity:sendNetVar("health", player)
```

---

## **entityMeta:clearNetVars**

**Description**

Clears all of the networked variables.

**Realm**

`Server`

**Internal:**  

This function is intended for internal use and should not be called directly.

**Parameters**

- **receiver** (`Player|nil`): The players to clear the networked variables for.

**Example**

```lua
entity:clearNetVars(player)
```

---

## **entityMeta:setNetVar**

**Description**

Sets the value of a networked variable.

**Realm**

`Server`

**Parameters**

- **key** (`String`): Identifier of the networked variable.
- **value** (`any`): New value to assign to the networked variable.
- **receiver** (`Player|nil`): The players to send the networked variable to.

**Example**

```lua
entity:setNetVar("example", "Hello World!", player)
```

---

## **entityMeta:getNetVar**

**Description**

Retrieves a networked variable. If it is not set, it'll return the default that you've specified.

**Realm**

`Server`
`Client`

**Parameters**

- **key** (`String`): Identifier of the networked variable.
- **default** (`any`): The default value to return if the networked variable does not exist.

**Returns**

- **any**: The value associated with the key, or the default that was given if it doesn't exist.

**Example**

```lua
local example = entity:getNetVar("example", "Default Value")
print(example) -- Output: "Hello World!" or "Default Value"
```

---

## **entityMeta:checkDoorAccess**

**Description**

Checks if a player has access to a door.

**Realm**

`Shared`

**Parameters**

- **client** (`Player`): The player whose access is being checked.
- **access** (`number`, optional): The access level required (defaults to `DOOR_GUEST`).

**Returns**

- **Boolean**: `true` if the player has the required access, `false` otherwise.

**Example**

```lua
if entity:checkDoorAccess(player, DOOR_ADMIN) then
    print("Player has access to the door.")
else
    print("Player does not have access to the door.")
end
```

---

## **entityMeta:IsLiliaPersistent**

**Description**

Checks if the entity is persistent.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is persistent, `false` otherwise.

**Example**

```lua
if entity:IsLiliaPersistent() then
    print("Entity is persistent.")
else
    print("Entity is not persistent.")
end
```

---

## **entityMeta:keysOwn**

**Description**

Sets the owner of the entity. Assigns ownership of the entity to the specified player. It is intended for compatibility with DarkRP's vehicle ownership system.

**Realm**

`Shared`

**Parameters**

- **client** (`Player`): The player who will become the owner of the entity.

**Example**

```lua
entity:keysOwn(player)
```

---

## **entityMeta:keysLock**

**Description**

Locks the entity. Locks the entity if it is a vehicle. It is intended for compatibility with DarkRP's vehicle locking system.

**Realm**

`Shared`

**Example**

```lua
entity:keysLock()
```

---

## **entityMeta:keysUnLock**

**Description**

Unlocks the entity. Unlocks the entity if it is a vehicle. It is intended for compatibility with DarkRP's vehicle unlocking system.

**Realm**

`Shared`

**Example**

```lua
entity:keysUnLock()
```

---

## **entityMeta:getDoorOwner**

**Description**

Retrieves the owner of the entity. Returns the player who owns the entity if it is a vehicle. It is intended for compatibility with DarkRP's vehicle ownership system.

**Realm**

`Shared`

**Returns**

- **Player|nil**: The player who owns the entity, or `nil` if no owner is set.

**Example**

```lua
local owner = entity:getDoorOwner()
if owner then
    print("Door is owned by:", owner:Nick())
end
```

---

## **entityMeta:isLocked**

**Description**

Checks if the door is locked.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the door is locked, `false` otherwise.

**Example**

```lua
if entity:isLocked() then
    print("The door is locked.")
else
    print("The door is unlocked.")
end
```

---

## **entityMeta:isDoorLocked**

**Description**

Checks if the entity is locked (pertaining to doors).

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is locked, `false` otherwise.

**Example**

```lua
if entity:isDoorLocked() then
    print("Door is locked.")
else
    print("Door is unlocked.")
end
```

---

## **entityMeta:removeDoorAccessData**

**Description**

Removes all door access data. Clears all access data associated with the door and updates the clients.

**Realm**

`Server`

**Internal:**  

This function is intended for internal use and should not be called directly.

**Example**

```lua
entity:removeDoorAccessData()
```

---

## **entityMeta:setLocked**

**Description**

Sets the locked state of the door. Sets whether the door is locked or not.

**Realm**

`Server`

**Parameters**

- **state** (`Boolean`): The new locked state of the door (`true` for locked, `false` for unlocked).

**Example**

```lua
entity:setLocked(true)
```

---

## **entityMeta:isDoor**

**Description**

Checks if the entity is a door.

**Realm**

`Shared`

**Returns**

- **Boolean**: `true` if the entity is a door, `false` otherwise.

**Example (Server)**

```lua
if entity:isDoor() then
    print("Entity is a door.")
end
```

**Example (Client)**

```lua
if entity:isDoor() then
    print("Entity is a door.")
end
```

---

## **entityMeta:getDoorPartner**

**Description**

Retrieves the partner door entity associated with this entity.

**Realm**

`Shared`

**Returns**

- **Entity|nil**: The partner door entity, if any.

**Example (Server)**

```lua
local partner = entity:getDoorPartner()
if partner then
    print("Partner door found:", partner:GetName())
end
```

**Example (Client)**

```lua
local partner = entity:getDoorPartner()
if partner then
    print("Partner door found:", partner:GetName())
end
```

---