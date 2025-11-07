# Flags Library

Character permission and access control system for the Lilia framework.

---

Overview

The flags library provides a comprehensive permission system for managing character abilities and access rights in the Lilia framework. It allows administrators to assign specific flags to characters that grant or restrict various gameplay features and tools. The library operates on both server and client sides, with the server handling flag assignment and callback execution during character spawning, while the client provides user interface elements for viewing and managing flags. Flags can have associated callbacks that execute when granted or removed, enabling dynamic behavior changes based on permission levels. The system includes built-in flags for common administrative tools like physgun, toolgun, and various spawn permissions. The library ensures proper flag validation and prevents duplicate flag assignments.

---

### lia.flag.add

#### 📋 Purpose
Adds a new flag to the flag system with optional description and callback function

#### ⏰ When Called
During module initialization or when registering new permission flags

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `flag` | **string** | Single character flag identifier (e.g., "C", "p", "t") |
| `desc` | **string, optional** | Localized description key for the flag |
| `callback` | **function, optional** | Function to execute when flag is granted/removed |

#### ↩️ Returns
* None

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add a basic flag with description
    lia.flag.add("A", "flagAdmin")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add flag with callback for weapon management
    lia.flag.add("w", "flagWeapon", function(client, isGiven)
    if isGiven then
        client:Give("weapon_pistol")
        else
            client:StripWeapon("weapon_pistol")
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Add flag with complex callback and validation
    lia.flag.add("M", "flagModerator", function(client, isGiven)
    if isGiven then
        client:SetNWBool("isModerator", true)
        client:ChatPrint("Moderator privileges granted!")
        -- Additional setup logic here
        else
            client:SetNWBool("isModerator", false)
            client:ChatPrint("Moderator privileges revoked!")
            -- Cleanup logic here
        end
    end)

```

---

### lia.flag.onSpawn

#### 📋 Purpose
Processes and executes callbacks for all flags assigned to a character when they spawn

#### ⏰ When Called
Automatically called when a character spawns on the server

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player whose character is spawning |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Called automatically when player spawns
    -- No direct usage needed - handled by framework

```

#### 📊 Medium Complexity
```lua
    -- Medium: Manual flag processing for specific cases
    local client = Player(1)
    if client and client:IsValid() then
        lia.flag.onSpawn(client)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Custom spawn handling with flag validation
    hook.Add("PlayerSpawn", "CustomFlagHandler", function(client)
    if client:getChar() then
        -- Custom pre-spawn logic
        lia.flag.onSpawn(client)
        -- Custom post-spawn logic
    end
    end)

```

---

