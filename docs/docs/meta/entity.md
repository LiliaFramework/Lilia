# Entity Meta


Entities in Garry's Mod may represent props, items, and interactive objects. This reference describes utility functions added to entity metatables for easier classification and management.


---


## Overview


The entity meta library extends Garry's Mod entities with helpers for detection, network-safe data, and item information. Using these functions ensures consistent behavior when handling game objects across Lilia.



---


### isProp()


**Description:**


Returns true if the entity is a physics prop.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – Whether the entity is a physics prop.


**Example Usage:**


```lua
-- Apply physics damage only if this is a prop
if ent:isProp() then
    ent:TakeDamage(50)
end
```

---


### isItem()


**Description:**


Checks if the entity is an item entity.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – True if the entity represents an item.


**Example Usage:**


```lua
-- Attempt to pick up the entity as an item
if ent:isItem() then
    lia.item.pickup(client, ent)
end
```

---


### isMoney()


**Description:**


Checks if the entity is a money entity.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – True if the entity represents money.


**Example Usage:**


```lua
-- Collect money dropped on the ground
if ent:isMoney() then
    char:addMoney(ent:getAmount())
end
```

---


### isSimfphysCar()


**Description:**


Checks if the entity is a simfphys car.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – True if this is a simfphys vehicle.


**Example Usage:**


```lua
-- Show a custom HUD when entering a simfphys vehicle
if ent:isSimfphysCar() then
    OpenCarHUD(ent)
end
```

---


### isLiliaPersistent()


**Description:**


Determines if the entity is persistent in Lilia.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – Whether the entity should persist.


**Example Usage:**


```lua
-- Save this entity across map resets if persistent
if ent:isLiliaPersistent() then
    lia.persist.saveEntity(ent)
end
```

---


### checkDoorAccess(client, access)


**Description:**


Checks if a player has the given door access level.


**Parameters:**


* client (Player) – The player to check.


* access (number, optional) – Door permission level.


**Realm:**


* Shared


**Returns:**


* boolean – True if the player has access.


**Example Usage:**


```lua
-- Block a player from opening the door without access
if not door:checkDoorAccess(client, DOOR_ACCESS_OPEN) then
    client:notify("The door is locked.")
end
```

---


### keysOwn(client)


**Description:**


Assigns the entity to the specified player.


**Parameters:**


* client (Player) – Player to set as owner.


**Realm:**


* Shared


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Assign ownership when a player buys the door
door:keysOwn(buyer)
```

---


### keysLock()


**Description:**


Locks the entity if it is a vehicle.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Lock the vehicle after the driver exits
car:keysLock()
```

---


### keysUnLock()


**Description:**


Unlocks the entity if it is a vehicle.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Unlock the vehicle when the owner presses a key
car:keysUnLock()
```

---


### getDoorOwner()


**Description:**


Returns the player that owns this door if available.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* Player|None – Door owner or None.


**Example Usage:**


```lua
-- Print the name of the door owner when inspecting
local owner = door:getDoorOwner()
if owner then
    print("Owned by", owner:Name())
end
```

---


### isLocked()


**Description:**


Returns the locked state stored in net variables.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – Whether the door is locked.


**Example Usage:**


```lua
-- Display a lock icon if the door is networked as locked
if door:isLocked() then
    DrawLockedIcon(door)
end
```

---


### isDoorLocked()


**Description:**


Checks the internal door locked state.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* boolean – True if the door is locked.


**Example Usage:**


```lua
-- Play a sound when trying to open a locked door server-side
if door:isDoorLocked() then
    door:EmitSound("doors/door_locked2.wav")
end
```

---


### getEntItemDropPos(offset)


**Description:**


Calculates a drop position in front of the entity's eyes.


**Parameters:**


* offset (number) – Distance from the player eye position.


**Realm:**


* Shared


**Returns:**


* Vector – Drop position and angle.


**Example Usage:**


```lua
-- Spawn an item drop in front of the entity's eyes
local pos, ang = ent:getEntItemDropPos(16)
lia.item.spawn("item_water", pos, ang)
```

---


### isNearEntity(radius, otherEntity)


**Description:**


Checks for another entity of the same class nearby.


**Parameters:**


* radius (number) – Sphere radius in units.


* otherEntity (Entity, optional) – Specific entity to look for.


**Realm:**


* Shared


**Returns:**


* boolean – True if another entity is within radius.


**Example Usage:**


```lua
-- Prevent building too close to another chest
if ent:isNearEntity(128, otherChest) then
    client:notify("Too close to another chest!")
end
```

---


### GetCreator()


**Description:**


Returns the entity creator player.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* Player|None – Creator player if stored.


**Example Usage:**


```lua
-- Credit the creator when the entity is removed
local creator = ent:GetCreator()
if IsValid(creator) then
    creator:notify("Your prop was removed.")
end
```

---


### SetCreator(client)


**Description:**


Stores the creator player on the entity.


**Parameters:**


* client (Player) – Creator of the entity.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
    -- Record the spawner for cleanup tracking
    ent:SetCreator(client)
```

---


### sendNetVar(key, receiver)


**Description:**


Sends a network variable to recipients.


**Parameters:**


* key (string) – Identifier of the variable.


* receiver (Player|None) – Who to send to.


**Realm:**


* Server


    Internal:

        Used by the networking system.


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Broadcast the "doorState" variable to every connected player
for _, ply in player.Iterator() do
    ent:sendNetVar("doorState", ply)
end
```

---


### clearNetVars(receiver)


**Description:**


Clears all network variables on this entity.


**Parameters:**


* receiver (Player|None) – Receiver to notify.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Force reinitialization by clearing all variables for this receiver
ent:clearNetVars(client)
ent:sendNetVar("initialized", client)
```

---


### removeDoorAccessData()


**Description:**


Clears all stored door access information.


**Parameters:**


* None


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Wipe door permissions during cleanup
local result = ent:removeDoorAccessData()
```

---


### setLocked(state)


**Description:**


Stores the door locked state in network variables.


**Parameters:**


* state (boolean) – New locked state.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Toggle the door lock and play a latch sound for everyone
door:setLocked(true)
door:EmitSound("doors/door_latch3.wav")
```

---


### isDoor()


**Description:**


Returns true if the entity's class indicates a door.


**Parameters:**


* None


**Realm:**


* Server


**Returns:**


* boolean – Whether the entity is a door.


**Example Usage:**


```lua
-- Check if the entity behaves like a door
local result = ent:isDoor()
```

---


### getDoorPartner()


**Description:**


Returns the partner door linked with this entity.


**Parameters:**


* None


**Realm:**


* Server


**Returns:**


* Entity|None – The partnered door.


**Example Usage:**


```lua
-- Unlock both doors when opening a double-door setup
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:setLocked(false)
end
```

---


### setNetVar(key, value, receiver)


**Description:**


Updates a network variable and sends it to recipients.


**Parameters:**


* key (string) – Variable name.


* value (any) – Value to store.


* receiver (Player|None) – Who to send update to.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Store a variable and sync it to players
local result = ent:setNetVar(key, value, receiver)
```

---


### getNetVar(key, default)


**Description:**


Retrieves a stored network variable or a default value.


**Parameters:**


* key (string) – Variable name.


* default (any) – Value returned if variable is nil.


**Realm:**


* Server


* Client


**Returns:**


* any – Stored value or default.


**Example Usage:**


```lua
-- Retrieve the stored variable or fallback to the default
local result = ent:getNetVar(key, default)
```

---


### isDoor()


**Description:**


Client-side door check using class name.


**Parameters:**


* None


**Realm:**


* Client


**Returns:**


* boolean – True if entity class contains "door".


**Example Usage:**


```lua
-- Determine if this entity's class name contains "door"
local result = ent:isDoor()
```

---


### getDoorPartner()


**Description:**


Attempts to find the door partnered with this one.


**Parameters:**


* None


**Realm:**


* Client


**Returns:**


* Entity|None – The partner door entity.


**Example Usage:**


```lua
-- Highlight the partner door of the one being looked at
local partner = ent:getDoorPartner()
if IsValid(partner) then
    partner:SetColor(Color(0, 255, 0))
end
```

---


### getNetVar(key, default)


**Description:**


Retrieves a network variable for this entity on the client.


**Parameters:**


* key (string) – Variable name.


* default (any) – Default if not set.


**Realm:**


* Client


**Returns:**


* any – Stored value or default.


**Example Usage:**


```lua
-- Access a synced variable on the client side
local result = ent:getNetVar(key, default)
```


---


### getParts()


```lua
function ENTITY:getParts()
    -- returns table
end
```


**Description:**


Retrieves the table of PAC3 part identifiers applied to this entity.


**Parameters:**


* None


**Realm:**


* Shared


**Returns:**


* table – The currently applied part IDs.


**Example Usage:**


```lua
-- Print all equipped PAC3 parts for a player
for id in pairs(client:getParts()) do
    print(id)
end
```


---


### syncParts()


```lua
function ENTITY:syncParts()
end
```


**Description:**


Broadcasts the entity's PAC3 part list to synchronize with clients.


**Parameters:**


* None


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Resend parts when a player respawns
client:syncParts()
```


---


### addPart(partID)


```lua
function ENTITY:addPart(partID)
end
```


**Description:**


Attaches a PAC3 part to this entity and networks the change.


**Parameters:**


* partID (string) – Identifier for the PAC3 outfit to add.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Give the player a custom hat part
client:addPart("hat01")
```


---


### removePart(partID)


```lua
function ENTITY:removePart(partID)
end
```


**Description:**


Detaches a PAC3 part from this entity and updates clients.


**Parameters:**


* partID (string) – Identifier of the PAC3 outfit to remove.


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Remove the previously equipped hat part
client:removePart("hat01")
```


---


### resetParts()


```lua
function ENTITY:resetParts()
end
```


**Description:**


Clears all PAC3 parts from this entity and notifies clients.


**Parameters:**


* None


**Realm:**


* Server


**Returns:**


* None – This function does not return a value.


**Example Usage:**


```lua
-- Remove all PAC3 outfits from the player
client:resetParts()
```
