# Utility Library

Common operations and helper functions for the Lilia framework.

---

Overview

The utility library provides comprehensive functionality for common operations and helper functions used throughout the Lilia framework. It contains a wide range of utilities for player management, string processing, entity handling, UI operations, and general purpose calculations. The library is divided into server-side functions for game logic and data management, and client-side functions for user interface, visual effects, and player interaction. These utilities simplify complex operations, provide consistent behavior across the framework, and offer reusable components for modules and plugins. The library handles everything from player identification and spatial queries to advanced UI animations and text processing, ensuring robust and efficient operations across both server and client environments.

---

### lia.util.findPlayersInBox

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.getBySteamID

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayersInSphere

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayer

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayerItems

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayerItemsByClass

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayerEntities

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.stringMatches

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.getAdmins

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayerBySteamID64

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findPlayerBySteamID

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.canFit

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.playerInRadius

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.formatStringNamed

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.getMaterial

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findFaction

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.generateRandomName

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.sendTableUI

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.findEmptySpace

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.animateAppearance

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.clampMenuPosition

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawGradient

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.wrapText

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawBlur

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawBlackBlur

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawBlurAt

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.requestEntityInformation

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.createTableUI

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.openOptionsMenu

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawEntText

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

### lia.util.drawLookText

#### 📋 Purpose
Find all players within a specified 3D box area

#### ⏰ When Called
When you need to find players in a specific rectangular area for operations like area-of-effect abilities or zone management

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `mins` | **Vector** | The minimum corner coordinates of the box |
| `maxs` | **Vector** | The maximum corner coordinates of the box |

#### ↩️ Returns
* Table of player entities found within the box area

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Find players in a small area around a position
    local players = lia.util.findPlayersInBox(Vector(-100, -100, -50), Vector(100, 100, 50))

```

#### 📊 Medium Complexity
```lua
    -- Medium: Find players in a zone and notify them
    local zonePlayers = lia.util.findPlayersInBox(zoneMin, zoneMax)
    for _, player in ipairs(zonePlayers) do
        player:notify("You are in the danger zone!")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Create a dynamic zone system with multiple areas
    local zones = {
        {mins = Vector(0, 0, 0),     maxs = Vector(100, 100, 100), name = "Safe Zone"  },
        {mins = Vector(200, 200, 0), maxs = Vector(300, 300, 100), name = "Combat Zone"}
    }
    for _, zone in ipairs(zones) do
        local players = lia.util.findPlayersInBox(zone.mins, zone.maxs)
        for _, player in ipairs(players) do
            player:notify("Entered: " .. zone.name)
        end
    end

```

---

