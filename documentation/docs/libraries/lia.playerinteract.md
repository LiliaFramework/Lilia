# Player Interact Library

This page documents the functions for working with player interactions and interaction management.

---

## Overview

The playerinteract library (`lia.playerinteract`) provides a comprehensive system for managing player interactions, interaction menus, and interaction handling in the Lilia framework, enabling intuitive and context-aware player-object interactions throughout the game world. This library handles sophisticated interaction management with support for dynamic interaction detection, context-sensitive menus, and intelligent interaction prioritization based on player proximity, permissions, and object states. The system features advanced interaction registration with support for complex interaction hierarchies, conditional interactions, and custom interaction behaviors that can be defined for any game object or entity. It includes comprehensive menu management with support for dynamic menu generation, real-time option updates, and seamless integration with the framework's UI system for consistent user experience. The library provides robust interaction processing with validation systems, permission checking, and error handling to ensure smooth and secure interaction execution. Additional features include interaction analytics and logging, accessibility support for different input methods, and performance optimization for complex interaction scenarios, making it essential for creating immersive and responsive gameplay experiences that encourage player exploration and interaction with the game world.

---

### isWithinRange

**Purpose**

Checks if a player is within interaction range of an entity.

**Parameters**

* `client` (*Player*): The client to check.
* `entity` (*Entity*): The target entity.
* `customRange` (*number*, optional): Custom interaction range (default: 250).

**Returns**

* `isWithinRange` (*boolean*): True if within range.

**Realm**

Shared.

**Example Usage**

```lua
-- Check if within interaction range
local function isWithinRange(client, entity)
    return lia.playerinteract.isWithinRange(client, entity)
end

-- Use in a function
local function checkInteractionRange(client, entity)
    if lia.playerinteract.isWithinRange(client, entity) then
        print("Player is within interaction range")
        return true
    else
        print("Player is not within interaction range")
        return false
    end
end

-- Use in a function
local function checkCustomRange(client, entity, range)
    if lia.playerinteract.isWithinRange(client, entity, range) then
        print("Player is within custom range of " .. range .. " units")
        return true
    else
        print("Player is not within custom range")
        return false
    end
end
```

---

### getInteractions

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

### getActions

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

### getCategorizedOptions

**Purpose**

Organizes interaction options into categories for display in menus.

**Parameters**

* `options` (*table*): Table of interaction options to categorize.

**Returns**

* `categorized` (*table*): Table of options organized by category.

**Realm**

Shared.

**Example Usage**

```lua
-- Get categorized options
local function getCategorizedOptions(options)
    return lia.playerinteract.getCategorizedOptions(options)
end

-- Use in a function
local function showCategorizedOptions(options)
    local categorized = lia.playerinteract.getCategorizedOptions(options)
    print("Categorized options:")
    for category, categoryOptions in pairs(categorized) do
        print("- " .. category .. ": " .. #categoryOptions .. " options")
        for name, option in pairs(categoryOptions) do
            print("  * " .. name)
        end
    end
end

-- Use in a function
local function organizeMenuOptions(options)
    local categorized = lia.playerinteract.getCategorizedOptions(options)
    return categorized
end
```

---

### addInteraction

**Purpose**

Adds a new interaction that can be triggered by players interacting with entities.

**Parameters**

* `name` (*string*): The unique name for the interaction.
* `data` (*table*): The interaction configuration data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add interaction
local function addInteraction(name, data)
    lia.playerinteract.addInteraction(name, data)
end

-- Use in a function
local function createDoorInteraction()
    lia.playerinteract.addInteraction("door_open", {
        name = "Open Door",
        range = 100,
        category = "Doors",
        target = "entity",
        shouldShow = function(client, door)
            return IsValid(door) and door:GetClass() == "func_door"
        end,
        onRun = function(client, door)
            door:Fire("Open")
            client:notify("Door opened")
        end
    })
    print("Door interaction created")
end

-- Use in a function
local function createPickupInteraction()
    lia.playerinteract.addInteraction("item_pickup", {
        name = "Pick Up",
        range = 50,
        category = "Items",
        target = "entity",
        shouldShow = function(client, item)
            return IsValid(item) and item:isItem()
        end,
        onRun = function(client, item)
            item:remove()
            client:notify("Item picked up")
        end
    })
    print("Pickup interaction created")
end
```

---

### addAction

**Purpose**

Adds a new action that can be triggered by players through the action menu.

**Parameters**

* `name` (*string*): The unique name for the action.
* `data` (*table*): The action configuration data.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Add action
local function addAction(name, data)
    lia.playerinteract.addAction(name, data)
end

-- Use in a function
local function createUseAction()
    lia.playerinteract.addAction("item_use", {
        name = "Use Item",
        category = "Items",
        shouldShow = function(client)
            local char = client:getChar()
            return char and char:getInventory():hasItems()
        end,
        onRun = function(client)
            -- Show item selection menu or use default item
            client:notify("Item used")
        end
    })
    print("Use action created")
end

-- Use in a function
local function createVoiceAction()
    lia.playerinteract.addAction("voice_settings", {
        name = "Voice Settings",
        category = "Communication",
        shouldShow = function(client)
            return client:getChar() and client:Alive()
        end,
        onRun = function(client)
            -- Open voice settings menu
            client:notify("Voice settings opened")
        end
    })
    print("Voice action created")
end
```

---

### syncToClients

**Purpose**

Syncs interaction data to a specific client or all clients.

**Parameters**

* `client` (*Player*, optional): The client to sync to. If not provided, syncs to all clients.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Sync interactions to all clients
local function syncInteractionsToAll()
    lia.playerinteract.syncToClients()
    print("Interactions synced to all clients")
end

-- Use in a function
local function syncInteractionsToClient(client)
    lia.playerinteract.syncToClients(client)
    print("Interactions synced to " .. client:Name())
end

-- Use in a function
local function syncOnModuleLoad()
    lia.playerinteract.syncToClients()
    print("Interactions synced after module load")
end
```

---

### openMenu

**Purpose**

Opens an interaction menu displaying available interactions and actions for the player.

**Parameters**

* `options` (*table*): Table of interaction options to display.
* `isInteraction` (*boolean*): Whether this is an interaction menu (true) or action menu (false).
* `titleText` (*string*, optional): Title text for the menu.
* `closeKey` (*number*, optional): Key code to close the menu (default: KEY_TAB for interactions, KEY_G for actions).
* `netMsg` (*string*, optional): Network message to send for server-side interactions.
* `preFiltered` (*boolean*, optional): Whether options are already filtered.

**Returns**

*None*

**Realm**

Client.

**Example Usage**

```lua
-- Open interaction menu
local function openInteractionMenu(options, targetEntity)
    lia.playerinteract.openMenu(options, true, "Interact with " .. targetEntity:GetClass())
end

-- Use in a function
local function openActionMenu(options)
    lia.playerinteract.openMenu(options, false, "Actions", KEY_G, "liaRequestInteractOptions")
end

-- Use in a function
local function openCustomMenu(options, title)
    lia.playerinteract.openMenu(options, false, title, KEY_ESCAPE)
    print("Custom menu opened")
end

-- Use in a function
local function openFilteredMenu(options)
    lia.playerinteract.openMenu(options, true, "Filtered Interactions", KEY_TAB, nil, true)
    print("Filtered interaction menu opened")
end
```