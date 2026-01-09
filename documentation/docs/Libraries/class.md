# Classes Library

Character class management and validation system for the Lilia framework.

---

Overview

The classes library provides comprehensive functionality for managing character classes in the Lilia framework. It handles registration, validation, and management of player classes within factions. The library operates on both server and client sides, allowing for dynamic class creation, whitelist management, and player class assignment validation. It includes functionality for loading classes from directories, checking class availability, retrieving class information, and managing class limits. The library ensures proper faction validation and provides hooks for custom class behavior and restrictions.

---

### lia.class.register

#### 📋 Purpose
Registers or updates a class definition within the global class list.

#### ⏰ When Called
Invoked during schema initialization or dynamic class creation to
ensure a class entry exists before use.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the class; must be consistent across loads. |
| `data` | **table** | Class metadata such as name, desc, faction, limit, OnCanBe, etc. |

#### ↩️ Returns
* table
The registered class table with applied defaults.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.class.register("soldier", {
        name = "Soldier",
        faction = FACTION_MILITARY,
        limit = 4
    })

```

---

### lia.class.loadFromDir

#### 📋 Purpose
Loads and registers all class definitions from a directory.

#### ⏰ When Called
Used during schema loading to automatically include class files in a
folder following the naming convention.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | Path to the directory containing class Lua files. |

#### ↩️ Returns
* nil
Operates for side effects of registering classes.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.class.loadFromDir("lilia/gamemode/classes")

```

---

### lia.class.canBe

#### 📋 Purpose
Determines whether a client can join a specific class.

#### ⏰ When Called
Checked before class selection to enforce faction, limits, whitelist,
and custom restrictions.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player attempting to join the class. |
| `class` | **number|string** | Class index or unique identifier. |

#### ↩️ Returns
* boolean|string
False and a reason string on failure; otherwise returns the
class's isDefault value.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local ok, reason = lia.class.canBe(ply, CLASS_CITIZEN)
    if ok then
        -- proceed with class change
    end

```

---

### lia.class.get

#### 📋 Purpose
Retrieves a class table by index or unique identifier.

#### ⏰ When Called
Used whenever class metadata is needed given a known identifier.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `identifier` | **number|string** | Class list index or unique identifier. |

#### ↩️ Returns
* table|nil
The class table if found; otherwise nil.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local classData = lia.class.get("soldier")

```

---

### lia.class.getPlayers

#### 📋 Purpose
Collects all players currently assigned to the given class.

#### ⏰ When Called
Used when enforcing limits or displaying membership lists.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **number|string** | Class list index or unique identifier. |

#### ↩️ Returns
* table
Array of player entities in the class.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    for _, ply in ipairs(lia.class.getPlayers("soldier")) do
        -- notify class members
    end

```

---

### lia.class.getPlayerCount

#### 📋 Purpose
Counts how many players are in the specified class.

#### ⏰ When Called
Used to check class limits or display class population.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **number|string** | Class list index or unique identifier. |

#### ↩️ Returns
* number
Current number of players in the class.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local count = lia.class.getPlayerCount(CLASS_ENGINEER)

```

---

### lia.class.retrieveClass

#### 📋 Purpose
Finds the class index by matching uniqueID or display name.

#### ⏰ When Called
Used to resolve user input to a class entry before further lookups.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **string** | Text to match against class uniqueID or name. |

#### ↩️ Returns
* number|nil
The class index if a match is found; otherwise nil.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local idx = lia.class.retrieveClass("Engineer")

```

---

### lia.class.hasWhitelist

#### 📋 Purpose
Checks whether a class uses whitelist access.

#### ⏰ When Called
Queried before allowing class selection or displaying class info.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `class` | **number|string** | Class list index or unique identifier. |

#### ↩️ Returns
* boolean
True if the class is whitelisted and not default; otherwise false.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    if lia.class.hasWhitelist(CLASS_PILOT) then
        -- restrict to whitelisted players
    end

```

---

### lia.class.retrieveJoinable

#### 📋 Purpose
Returns a list of classes the provided client is allowed to join.

#### ⏰ When Called
Used to build class selection menus and enforce availability.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Target player; defaults to LocalPlayer on the client. |

#### ↩️ Returns
* table
Array of class tables the client can currently join.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    local options = lia.class.retrieveJoinable(ply)

```

---

