# Player Interaction Library

Player-to-player and entity interaction management system for the Lilia framework.

---

## Overview

The player interaction library provides comprehensive functionality for managing player interactions

and actions within the Lilia framework. It handles the creation, registration, and execution of

various interaction types including player-to-player interactions, entity interactions, and

personal actions. The library operates on both server and client sides, with the server managing

interaction registration and validation, while the client handles UI display and user input.

It includes range checking, timed actions, and network synchronization

to ensure consistent interaction behavior across all clients. The library supports both immediate

and delayed actions with progress indicators, making it suitable for complex interaction systems

like money transfers, voice changes, and other gameplay mechanics.

---

### isWithinRange

**Purpose**

Checks if a client is within interaction range of an entity

**When Called**

Called when determining if an interaction should be available to a player

**Parameters**

* `client` (*Player*): The player attempting the interaction
* `entity` (*Entity*): The target entity to check distance against
* `customRange` (*number, optional*): Custom range override (defaults to 250 units)

---

### getInteractions

**Purpose**

Retrieves all available interactions for a client based on their traced entity

**When Called**

Called when opening interaction menu or checking available interactions

**Parameters**

* `client` (*Player, optional*): The player to get interactions for (defaults to LocalPlayer())

---

### getActions

**Purpose**

Retrieves all available personal actions for a client

**When Called**

Called when opening personal actions menu or checking available actions

**Parameters**

* `client` (*Player, optional*): The player to get actions for (defaults to LocalPlayer())

---

### getCategorizedOptions

**Purpose**

Prepares interaction/action options for UI display in a flat list

**When Called**

Called when preparing options for display in the interaction menu

**Parameters**

* `options` (*table*): Dictionary of options to prepare

---

### addInteraction

**Purpose**

Registers a new player-to-player or player-to-entity interaction

**When Called**

Called during module initialization or when registering custom interactions

**Parameters**

* `name` (*string*): Unique identifier for the interaction
* `data` (*table*): Interaction configuration table containing:
* `serverOnly` (*boolean, optional*): Whether interaction runs server-side only
* `shouldShow` (*function, optional*): Function to determine if interaction should be visible
* `onRun` (*function*): Function to execute when interaction is triggered
* `range` (*number, optional*): Interaction range in units (defaults to 250)
* `category` (*string, optional*): Category for UI organization
* `target` (*string, optional*): Target type - "player", "entity", or "any" (defaults to "player")
* `timeToComplete` (*number, optional*): Time in seconds for timed interactions
* `actionText` (*string, optional*): Text shown to performing player during timed action
* `targetActionText` (*string, optional*): Text shown to target player during timed action
* `categoryColor` (*Color, optional*): Color for category display

---

### addAction

**Purpose**

Registers a new personal action that doesn't require a target entity

**When Called**

Called during module initialization or when registering custom personal actions

**Parameters**

* `name` (*string*): Unique identifier for the action
* `data` (*table*): Action configuration table containing:
* `serverOnly` (*boolean, optional*): Whether action runs server-side only
* `shouldShow` (*function, optional*): Function to determine if action should be visible
* `onRun` (*function*): Function to execute when action is triggered
* `range` (*number, optional*): Action range in units (defaults to 250)
* `category` (*string, optional*): Category for UI organization
* `timeToComplete` (*number, optional*): Time in seconds for timed actions
* `actionText` (*string, optional*): Text shown to performing player during timed action
* `targetActionText` (*string, optional*): Text shown to target player during timed action
* `categoryColor` (*Color, optional*): Color for category display

---

### lia.syncInteractionsToClient

**Purpose**

Synchronizes interaction and action data from server to clients

**When Called**

Called when interactions/actions are added or when clients connect

**Parameters**

* `client` (*Player, optional*): Specific client to sync to (if nil, syncs to all players)

---

### syncToClients

**Purpose**

Synchronizes interaction and action data from server to clients

**When Called**

Called when interactions/actions are added or when clients connect

**Parameters**

* `client` (*Player, optional*): Specific client to sync to (if nil, syncs to all players)

---

### openMenu

**Purpose**

Opens the interaction/action menu UI with options in a flat list

**When Called**

Called when player presses interaction keybind or requests menu

**Parameters**

* `options` (*table*): Dictionary of available options to display
* `isInteraction` (*boolean*): Whether this is an interaction menu (true) or action menu (false)
* `titleText` (*string*): Title text to display at top of menu
* `closeKey` (*number*): Key code that closes the menu when released
* `netMsg` (*string*): Network message name for server-only interactions
* `preFiltered` (*boolean, optional*): Whether options are already filtered (defaults to false)
* `true` (*unknown*): - preFiltered

---

### lia.frame:OnRemove

**Purpose**

Opens the interaction/action menu UI with options in a flat list

**When Called**

Called when player presses interaction keybind or requests menu

**Parameters**

* `options` (*table*): Dictionary of available options to display
* `isInteraction` (*boolean*): Whether this is an interaction menu (true) or action menu (false)
* `titleText` (*string*): Title text to display at top of menu
* `closeKey` (*number*): Key code that closes the menu when released
* `netMsg` (*string*): Network message name for server-only interactions
* `preFiltered` (*boolean, optional*): Whether options are already filtered (defaults to false)
* `true` (*unknown*): - preFiltered

---

### lia.frame:Think

**Purpose**

Opens the interaction/action menu UI with options in a flat list

**When Called**

Called when player presses interaction keybind or requests menu

**Parameters**

* `options` (*table*): Dictionary of available options to display
* `isInteraction` (*boolean*): Whether this is an interaction menu (true) or action menu (false)
* `titleText` (*string*): Title text to display at top of menu
* `closeKey` (*number*): Key code that closes the menu when released
* `netMsg` (*string*): Network message name for server-only interactions
* `preFiltered` (*boolean, optional*): Whether options are already filtered (defaults to false)
* `true` (*unknown*): - preFiltered

---

