# lia.playerinteract

The `lia.playerinteract` library provides a comprehensive system for managing player interactions with entities and personal actions. It handles the creation, categorization, and execution of interactive options that players can perform on other players, entities, or themselves.

## Overview

The player interaction system consists of two main types of interactions:

- **Interactions**: Actions performed on other players or entities (e.g., giving money, using items)
- **Actions**: Personal actions that players can perform on themselves (e.g., changing voice mode)

The system automatically categorizes interactions, provides range checking, and includes a sophisticated UI with collapsible categories.

## Core Functions

### `lia.playerinteract.isWithinRange(client, entity, customRange)`

Checks if a client is within interaction range of an entity.

**Parameters:**
- `client` (Player): The player attempting the interaction
- `entity` (Entity): The target entity
- `customRange` (number, optional): Custom range to check (default: 250)

**Returns:**
- `boolean`: True if within range, false otherwise

**Example:**
```lua
if lia.playerinteract.isWithinRange(player, target, 300) then
    -- Player is within 300 units of target
end
```

### `lia.playerinteract.getInteractions(client)`

Retrieves all available interactions for a client based on their current target entity.

**Parameters:**
- `client` (Player): The player (defaults to LocalPlayer() on client)

**Returns:**
- `table`: Table of available interactions

**Example:**
```lua
local interactions = lia.playerinteract.getInteractions(player)
for name, interaction in pairs(interactions) do
    print("Available interaction:", name)
end
```

### `lia.playerinteract.getActions(client)`

Retrieves all available personal actions for a client.

**Parameters:**
- `client` (Player): The player (defaults to LocalPlayer() on client)

**Returns:**
- `table`: Table of available actions

**Example:**
```lua
local actions = lia.playerinteract.getActions(player)
for name, action in pairs(actions) do
    print("Available action:", name)
end
```

### `lia.playerinteract.getCategorizedOptions(options)`

Organizes interaction options into categories for better UI presentation.

**Parameters:**
- `options` (table): Table of interaction options

**Returns:**
- `table`: Categorized options organized by category

## Server-Side Functions

### `lia.playerinteract.addInteraction(name, data)`

Registers a new interaction option that can be performed on entities or players.

**Parameters:**
- `name` (string): Unique identifier for the interaction
- `data` (table): Interaction configuration

**Data Structure:**
```lua
{
    type = "interaction", -- Automatically set
    range = 250, -- Interaction range (default: 250)
    category = "General", -- Category name (default: "Unsorted")
    categoryColor = Color(255, 255, 255, 255), -- Category color
    shouldShow = function(client, target) return true end, -- Visibility condition
    onRun = function(client, target) end, -- Interaction execution
    serverOnly = false -- Whether interaction runs server-side only
}
```

**Example:**
```lua
lia.playerinteract.addInteraction("giveMoney", {
    category = "Economy",
    categoryColor = Color(0, 255, 0, 255),
    shouldShow = function(client, target)
        return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0
    end,
    onRun = function(client, target)
        -- Handle money transfer
    end
})
```

### `lia.playerinteract.addAction(name, data)`

Registers a new personal action that players can perform on themselves.

**Parameters:**
- `name` (string): Unique identifier for the action
- `data` (table): Action configuration

**Data Structure:**
```lua
{
    type = "action", -- Automatically set
    range = 250, -- Range (default: 250)
    category = "General", -- Category name (default: "Unsorted")
    categoryColor = Color(255, 255, 255, 255), -- Category color
    shouldShow = function(client) return true end, -- Visibility condition
    onRun = function(client) end, -- Action execution
    serverOnly = false -- Whether action runs server-side only
}
```

**Example:**
```lua
lia.playerinteract.addAction("changeVoiceMode", {
    category = "Voice",
    categoryColor = Color(255, 255, 0, 255),
    shouldShow = function(client)
        return client:getChar() and client:Alive()
    end,
    onRun = function(client)
        client:setNetVar("VoiceType", "whispering")
    end
})
```

### `lia.playerinteract.syncToClients(client)`

Synchronizes interaction data to clients for proper client-side functionality.

**Parameters:**
- `client` (Player): The client to sync data to

**Note:** This function is automatically called when needed and handles networking of interaction data.

## Client-Side Functions

### `lia.playerinteract.openMenu(options, isInteraction, titleText, closeKey, netMsg)`

Opens the interaction/action menu with categorized options and collapsible sections.

**Parameters:**
- `options` (table): Available options to display
- `isInteraction` (boolean): Whether this is an interaction menu (true) or action menu (false)
- `titleText` (string): Menu title text
- `closeKey` (number): Key code to close the menu
- `netMsg` (string): Network message for server-side execution

**Features:**
- Automatic categorization of options
- Collapsible category sections
- Range checking for interactions
- Smooth animations and blur effects
- Responsive design with proper scaling

## Built-in Interactions

The library comes with several pre-configured interactions and actions:

### Interactions

#### `giveMoney`
- **Category**: Economy
- **Description**: Allows players to transfer money to other players
- **Requirements**: Player must have money, target must be valid player
- **Features**: Amount input dialog, anti-cheat protection, family sharing checks

### Actions

#### Voice Mode Changes
- **changeToWhisper**: Sets voice mode to whispering
- **changeToTalk**: Sets voice mode to talking  
- **changeToYell**: Sets voice mode to yelling
- **Category**: Voice
- **Requirements**: Player must have character and be alive

## Key Bindings

The library automatically sets up key bindings for easy access:

- **TAB**: Opens interaction menu for current target
- **G**: Opens personal actions menu

## Networking

The system uses Lilia's networking system to synchronize interaction data between server and clients:

- **liaPlayerInteractSync**: Syncs interaction definitions
- **liaPlayerInteractCategories**: Syncs category information
- **RunInteraction**: Executes server-side interactions

## Hooks

The library provides several hooks for customization:

- **InteractionMenuOpened(frame)**: Called when interaction menu is opened
- **InteractionMenuClosed()**: Called when interaction menu is closed

## Console Commands

### `printplayerinteract`
Prints the contents of `lia.playerinteract.stored` to console for debugging purposes.

**Usage:**
```
printplayerinteract
```

**Note:** Admin-only on server, available to all on client.

## Best Practices

1. **Categorization**: Always assign meaningful categories to interactions and actions
2. **Range Checking**: Use appropriate ranges for different types of interactions
3. **Validation**: Implement proper `shouldShow` functions to control visibility
4. **Server-Side Execution**: Use `serverOnly = true` for actions that require server validation
5. **Error Handling**: Implement proper error handling in `onRun` functions

## Example Implementation

```lua
-- Server-side: Add a custom interaction
lia.playerinteract.addInteraction("healPlayer", {
    category = "Medical",
    categoryColor = Color(0, 255, 0, 255),
    range = 150,
    shouldShow = function(client, target)
        return IsValid(target) and target:IsPlayer() and 
               client:getChar():hasMoney(50) and
               target:Health() < target:GetMaxHealth()
    end,
    onRun = function(client, target)
        if client:getChar():hasMoney(50) then
            client:getChar():takeMoney(50)
            target:SetHealth(math.min(target:Health() + 50, target:GetMaxHealth()))
            client:notify("Player healed for $50")
            target:notify("You have been healed")
        end
    end
})

-- Client-side: Custom hook usage
hook.Add("InteractionMenuOpened", "CustomInteractionMenu", function(frame)
    -- Customize the opened menu
    print("Interaction menu opened!")
end)
```

## Technical Details

- **Range Calculation**: Uses squared distance for performance optimization
- **UI Rendering**: Built with DFrame and custom painting for optimal performance
- **Category Management**: Automatic category creation and color assignment
- **Memory Management**: Proper cleanup of UI elements and timers
- **Network Optimization**: Efficient data synchronization using big table networking
