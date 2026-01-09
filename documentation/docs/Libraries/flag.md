# Flags Library

Character permission and access control system for the Lilia framework.

---

Overview

The flags library provides a comprehensive permission system for managing character abilities and access rights in the Lilia framework. It allows administrators to assign specific flags to characters that grant or restrict various gameplay features and tools. The library operates on both server and client sides, with the server handling flag assignment and callback execution during character spawning, while the client provides user interface elements for viewing and managing flags. Flags can have associated callbacks that execute when granted or removed, enabling dynamic behavior changes based on permission levels. The system includes built-in flags for common administrative tools like physgun, toolgun, and various spawn permissions. The library ensures proper flag validation and prevents duplicate flag assignments.

---

### lia.flag.add

#### 📋 Purpose
Register a flag with description and optional grant/remove callback.

#### ⏰ When Called
During framework setup to define permission flags.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flag` | **string** | Single-character flag id. |
| `Single` | **unknown** | character flag id. |
| `Single` | **unknown** | character flag id. |
| `desc` | **string** | Localization key or plain description. |
| `callback` | **function|nil** | function(client, isGiven) for grant/remove side effects. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.flag.add("B", "flagBuildMenu", function(client, isGiven)
        if isGiven then
            client:Give("weapon_physgun")
        else
            client:StripWeapon("weapon_physgun")
        end
    end)

```

---

### lia.flag.onSpawn

#### 📋 Purpose
Execute flag callbacks for a player on spawn, ensuring each flag runs once.

#### ⏰ When Called
Automatically when characters spawn; can be hooked for reapplication.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose flags should be processed. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerSpawn", "ApplyFlagWeapons", lia.flag.onSpawn)

```

---

