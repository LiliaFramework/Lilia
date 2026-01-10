# Entity Meta

Entity management system for the Lilia framework.

---

Overview

The entity meta table provides comprehensive functionality for extending Garry's Mod entities with Lilia-specific features and operations. It handles entity identification, sound management, door access control, vehicle ownership, network variable synchronization, and entity-specific operations. The meta table operates on both server and client sides, with the server managing entity data and validation while the client provides entity interaction and display. It includes integration with the door system for access control, vehicle system for ownership management, network system for data synchronization, and sound system for audio playback. The meta table ensures proper entity identification, access control validation, network data synchronization, and comprehensive entity interaction management for doors, vehicles, and other game objects.

---

### EmitSound

#### 📋 Purpose
Plays a sound from this entity, handling web sound URLs and fallbacks.

#### ⏰ When Called
Use whenever an entity needs to emit a sound that may be streamed.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `soundName` | **string** | File path or URL to play. |
| `soundLevel` | **number** | Sound level for attenuation. |
| `pitchPercent` | **number** | Pitch modifier. |
| `volume` | **number** | Volume from 0-100. |
| `channel` | **number** | Optional sound channel. |
| `flags` | **number** | Optional emit flags. |
| `dsp` | **number** | Optional DSP effect index. |

#### ↩️ Returns
* boolean
True when handled by websound logic; otherwise base emit result.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    ent:EmitSound("lilia/websounds/example.mp3", 75)

```

---

### isProp

#### 📋 Purpose
Indicates whether this entity is a physics prop.

#### ⏰ When Called
Use when filtering interactions to physical props only.

#### ↩️ Returns
* boolean
True if the entity class is prop_physics.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isProp() then handleProp(ent) end

```

---

### isItem

#### 📋 Purpose
Checks if the entity represents a Lilia item.

#### ⏰ When Called
Use when distinguishing item entities from other entities.

#### ↩️ Returns
* boolean
True if the entity class is lia_item.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isItem() then pickUpItem(ent) end

```

---

### isMoney

#### 📋 Purpose
Checks if the entity is a Lilia money pile.

#### ⏰ When Called
Use when processing currency pickups or interactions.

#### ↩️ Returns
* boolean
True if the entity class is lia_money.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isMoney() then ent:Remove() end

```

---

### isSimfphysCar

#### 📋 Purpose
Determines whether the entity belongs to supported vehicle classes.

#### ⏰ When Called
Use when applying logic specific to Simfphys/LVS vehicles.

#### ↩️ Returns
* boolean
True if the entity is a recognized vehicle type.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isSimfphysCar() then configureVehicle(ent) end

```

---

### checkDoorAccess

#### 📋 Purpose
Verifies whether a client has a specific level of access to a door.

#### ⏰ When Called
Use when opening menus or performing actions gated by door access.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player requesting access. |
| `access` | **number** | Required access level, defaults to DOOR_GUEST. |

#### ↩️ Returns
* boolean
True if the client meets the access requirement.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if door:checkDoorAccess(ply, DOOR_OWNER) then openDoor() end

```

---

### keysOwn

#### 📋 Purpose
Assigns vehicle ownership metadata to a player.

#### ⏰ When Called
Use when a player purchases or claims a vehicle entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player to set as owner. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    vehicle:keysOwn(ply)

```

---

### keysLock

#### 📋 Purpose
Locks a vehicle entity via its Fire interface.

#### ⏰ When Called
Use when a player locks their owned vehicle.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    vehicle:keysLock()

```

---

### keysUnLock

#### 📋 Purpose
Unlocks a vehicle entity via its Fire interface.

#### ⏰ When Called
Use when giving a player access back to their vehicle.

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    vehicle:keysUnLock()

```

---

### getDoorOwner

#### 📋 Purpose
Retrieves the owning player for a door or vehicle, if any.

#### ⏰ When Called
Use when displaying ownership information.

#### ↩️ Returns
* Player|nil
Owner entity or nil if unknown.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local owner = door:getDoorOwner()

```

---

### isLocked

#### 📋 Purpose
Returns whether the entity is flagged as locked through net vars.

#### ⏰ When Called
Use when deciding if interactions should be blocked.

#### ↩️ Returns
* boolean
True if the entity's locked net var is set.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if door:isLocked() then denyUse() end

```

---

### isDoorLocked

#### 📋 Purpose
Checks the underlying lock state of a door entity.

#### ⏰ When Called
Use when syncing lock visuals or handling use attempts.

#### ↩️ Returns
* boolean
True if the door reports itself as locked.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local locked = door:isDoorLocked()

```

---

### isFemale

#### 📋 Purpose
Infers whether the entity's model is tagged as female.

#### ⏰ When Called
Use for gender-specific animations or sounds.

#### ↩️ Returns
* boolean
True if GetModelGender returns "female".

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isFemale() then setFemaleVoice(ent) end

```

---

### getDoorPartner

#### 📋 Purpose
Finds the paired door entity associated with this door.

#### ⏰ When Called
Use when syncing double-door behavior or ownership.

#### ↩️ Returns
* Entity|nil
Partner door entity when found.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local partner = door:getDoorPartner()

```

---

### sendNetVar

#### 📋 Purpose
Sends a networked variable for this entity to one or more clients.

#### ⏰ When Called
Use immediately after changing lia.net values to sync them.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Net variable name to send. |
| `receiver` | **Player|nil** | Optional player to send to; broadcasts when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    ent:sendNetVar("locked", ply)

```

---

### clearNetVars

#### 📋 Purpose
Clears all stored net vars for this entity and notifies clients.

#### ⏰ When Called
Use when an entity is being removed or reset.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `receiver` | **Player|nil** | Optional target to notify; broadcasts when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    ent:clearNetVars()

```

---

### removeDoorAccessData

#### 📋 Purpose
Resets stored door access data and closes any open menus.

#### ⏰ When Called
Use when clearing door permissions or transferring ownership.

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    door:removeDoorAccessData()

```

---

### setLocked

#### 📋 Purpose
Sets the locked net var state for this entity.

#### ⏰ When Called
Use when toggling lock status server-side.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | **boolean** | Whether the entity should be considered locked. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    door:setLocked(true)

```

---

### setKeysNonOwnable

#### 📋 Purpose
Marks an entity as non-ownable for keys/door systems.

#### ⏰ When Called
Use when preventing selling or owning of a door/vehicle.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `state` | **boolean** | True to make the entity non-ownable. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    door:setKeysNonOwnable(true)

```

---

### setNetVar

#### 📋 Purpose
Stores a networked variable for this entity and notifies listeners.

#### ⏰ When Called
Use when updating shared entity state that clients need.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Net variable name. |
| `value` | **any** | Value to store and broadcast. |
| `receiver` | **Player|nil** | Optional player to send to; broadcasts when nil. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    ent:setNetVar("color", Color(255, 0, 0))

```

---

### setLocalVar

#### 📋 Purpose
Saves a local (server-only) variable on the entity.

#### ⏰ When Called
Use for transient server state that should not be networked.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Local variable name. |
| `value` | **any** | Value to store. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    ent:setLocalVar("cooldown", CurTime())

```

---

### getLocalVar

#### 📋 Purpose
Reads a server-side local variable stored on the entity.

#### ⏰ When Called
Use when retrieving transient server-only state.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Local variable name. |
| `default` | **any** | Value to return if unset. |

#### ↩️ Returns
* any
Stored local value or default.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    local cooldown = ent:getLocalVar("cooldown", 0)

```

---

### playFollowingSound

#### 📋 Purpose
Plays a web sound locally on the client, optionally following the entity.

#### ⏰ When Called
Use when the client must play a streamed sound attached to an entity.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `soundPath` | **string** | URL or path to the sound. |
| `volume` | **number** | Volume from 0-1. |
| `shouldFollow` | **boolean** | Whether the sound follows the entity. |
| `maxDistance` | **number** | Maximum audible distance. |
| `startDelay` | **number** | Delay before playback starts. |
| `minDistance` | **number** | Minimum distance for attenuation. |
| `pitch` | **number** | Playback rate multiplier. |
| `soundLevel` | **number** | Optional sound level for attenuation. |
| `dsp` | **number** | Optional DSP effect index. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    ent:playFollowingSound(url, 1, true, 1200)

```

---

### isDoor

#### 📋 Purpose
Determines whether this entity should be treated as a door.

#### ⏰ When Called
Use when applying door-specific logic on an entity.

#### ↩️ Returns
* boolean
True if the entity class matches common door types.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if ent:isDoor() then handleDoor(ent) end

```

---

### getNetVar

#### 📋 Purpose
Retrieves a networked variable stored on this entity.

#### ⏰ When Called
Use when reading shared entity state on either server or client.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `key` | **string** | Net variable name. |
| `default` | **any** | Fallback value if none is set. |

#### ↩️ Returns
* any
Stored net var or default.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local locked = ent:getNetVar("locked", false)

```

---

