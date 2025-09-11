# Player Interact Library

This page documents the functions for working with player interactions and interaction management.

---

## Overview

The playerinteract library (`lia.playerinteract`) provides a comprehensive system for managing player interactions, interaction menus, and interaction handling in the Lilia framework, enabling intuitive and context-aware player-object interactions throughout the game world. This library handles sophisticated interaction management with support for dynamic interaction detection, context-sensitive menus, and intelligent interaction prioritization based on player proximity, permissions, and object states. The system features advanced interaction registration with support for complex interaction hierarchies, conditional interactions, and custom interaction behaviors that can be defined for any game object or entity. It includes comprehensive menu management with support for dynamic menu generation, real-time option updates, and seamless integration with the framework's UI system for consistent user experience. The library provides robust interaction processing with validation systems, permission checking, and error handling to ensure smooth and secure interaction execution. Additional features include interaction analytics and logging, accessibility support for different input methods, and performance optimization for complex interaction scenarios, making it essential for creating immersive and responsive gameplay experiences that encourage player exploration and interaction with the game world.

---

### lia.playerinteract.isWithinRange

**Purpose**

Checks if a player is within interaction range.

**Parameters**

* `client` (*Player*): The client to check.
* `target` (*Entity*): The target entity.

**Returns**

* `isWithinRange` (*boolean*): True if within range.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if within interaction range
local function isWithinRange(client, target)
    return lia.playerinteract.isWithinRange(client, target)
end

-- Use in a function
local function checkInteractionRange(client, target)
    if lia.playerinteract.isWithinRange(client, target) then
        print("Player is within interaction range")
        return true
    else
        print("Player is not within interaction range")
        return false
    end
end
```

---

### lia.playerinteract.getInteractions

**Purpose**

Gets all interactions for a client.

**Parameters**

* `client` (*Player*): The client to get interactions for.

**Returns**

* `interactions` (*table*): Table of interactions.

**Realm**

Shared.

**Example Usage**

```lua
-- Get interactions for client
local function getInteractions(client)
    return lia.playerinteract.getInteractions(client)
end

-- Use in a function
local function showInteractions(client)
    local interactions = lia.playerinteract.getInteractions(client)
    print("Available interactions for " .. client:Name() .. ":")
    for _, interaction in ipairs(interactions) do
        print("- " .. interaction.name)
    end
end
```

---

### lia.playerinteract.getActions

**Purpose**

Gets all actions for a client.

**Parameters**

* `client` (*Player*): The client to get actions for.

**Returns**

* `actions` (*table*): Table of actions.

**Realm**

Shared.

**Example Usage**

```lua
-- Get actions for client
local function getActions(client)
    return lia.playerinteract.getActions(client)
end

-- Use in a function
local function showActions(client)
    local actions = lia.playerinteract.getActions(client)
    print("Available actions for " .. client:Name() .. ":")
    for _, action in ipairs(actions) do
        print("- " .. action.name)
    end
end
```

---

### lia.playerinteract.getCategorizedOptions

**Purpose**

Gets categorized interaction options for a client.

**Parameters**

* `client` (*Player*): The client to get options for.

**Returns**

* `options` (*table*): Table of categorized options.

**Realm**

Shared.

**Example Usage**

```lua
-- Get categorized options for client
local function getCategorizedOptions(client)
    return lia.playerinteract.getCategorizedOptions(client)
end

-- Use in a function
local function showCategorizedOptions(client)
    local options = lia.playerinteract.getCategorizedOptions(client)
    print("Categorized options for " .. client:Name() .. ":")
    for category, options in pairs(options) do
        print("- " .. category .. ": " .. #options .. " options")
    end
end
```

---

### lia.playerinteract.addInteraction

**Purpose**

Adds a new interaction.

**Parameters**

* `interactionData` (*table*): The interaction data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add interaction
local function addInteraction(interactionData)
    lia.playerinteract.addInteraction(interactionData)
end

-- Use in a function
local function createDoorInteraction()
    lia.playerinteract.addInteraction({
        name = "Open Door",
        callback = function(client, door)
            door:Fire("Open")
            client:notify("Door opened")
        end
    })
    print("Door interaction created")
end
```

---

### lia.playerinteract.addAction

**Purpose**

Adds a new action.

**Parameters**

* `actionData` (*table*): The action data table.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Add action
local function addAction(actionData)
    lia.playerinteract.addAction(actionData)
end

-- Use in a function
local function createUseAction()
    lia.playerinteract.addAction({
        name = "Use",
        callback = function(client, target)
            target:Use(client)
            client:notify("Used " .. target:GetClass())
        end
    })
    print("Use action created")
end
```

---

### lia.playerinteract.syncToClients

**Purpose**

Syncs interactions to all clients.

**Parameters**

*None*

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Sync interactions to clients
local function syncInteractions()
    lia.playerinteract.syncToClients()
end

-- Use in a function
local function syncAllInteractions()
    lia.playerinteract.syncToClients()
    print("Interactions synced to all clients")
end
```

---

### lia.playerinteract.openMenu

**Purpose**

Opens an interaction menu for a client.

**Parameters**

* `client` (*Player*): The client to open the menu for.
* `target` (*Entity*): The target entity.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Open interaction menu
local function openMenu(client, target)
    lia.playerinteract.openMenu(client, target)
end

-- Use in a function
local function openInteractionMenu(client, target)
    lia.playerinteract.openMenu(client, target)
    print("Interaction menu opened for " .. client:Name())
end
```