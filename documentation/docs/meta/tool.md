# Tool Gun Meta

Tool gun management system for the Lilia framework.

---

## Overview

The tool gun meta table provides comprehensive functionality for managing tool gun instances, tool operations, and tool-specific functionality in the Lilia framework. It handles tool creation, configuration, object management, and tool-specific operations. The meta table operates on both server and client sides, with the server managing tool validation and data while the client provides tool interaction and display. It includes integration with the Garry's Mod tool system for tool functionality, object system for tool objects, network system for tool synchronization, and permission system for tool access control. The meta table ensures proper tool instance management, object handling, tool synchronization, and comprehensive tool lifecycle management from creation to destruction.

---

### create

**Purpose**

Creates a new instance of the tool gun object with default properties

**When Called**

When initializing a new tool gun instance for a specific tool mode

---

### createConVars

**Purpose**

Creates console variables (ConVars) for the tool gun based on the current mode

**When Called**

During tool initialization to set up configurable options for the tool

---

### updateData

**Purpose**

Updates the tool's data and state information (placeholder for custom implementation)

**When Called**

During tool operation to refresh data or synchronize with server/client state

---

### updateData

**Purpose**

Updates the tool's data and state information (placeholder for custom implementation)

**When Called**

During tool operation to refresh data or synchronize with server/client state

---

### updateData

**Purpose**

Updates the tool's data and state information (placeholder for custom implementation)

**When Called**

During tool operation to refresh data or synchronize with server/client state

---

### freezeMovement

**Purpose**

Freezes player movement during tool operation (placeholder for custom implementation)

**When Called**

When the tool needs to restrict player movement for precise operations

---

### freezeMovement

**Purpose**

Freezes player movement during tool operation (placeholder for custom implementation)

**When Called**

When the tool needs to restrict player movement for precise operations

---

### unfreezeMovement

**Purpose**

Freezes player movement during tool operation (placeholder for custom implementation)

**When Called**

When the tool needs to restrict player movement for precise operations

---

### freezeMovement

**Purpose**

Freezes player movement during tool operation (placeholder for custom implementation)

**When Called**

When the tool needs to restrict player movement for precise operations

---

### drawHUD

**Purpose**

Draws HUD elements for the tool gun interface (placeholder for custom implementation)

**When Called**

Every frame when the tool gun is active and HUD should be displayed

**Parameters**

* `surface.DrawRect(scrW/2` (*unknown*): 50, scrH - 80, progress * 100, 10)

---

### drawHUD

**Purpose**

Draws HUD elements for the tool gun interface (placeholder for custom implementation)

**When Called**

Every frame when the tool gun is active and HUD should be displayed

**Parameters**

* `surface.DrawRect(scrW/2` (*unknown*): 50, scrH - 80, progress * 100, 10)

---

### drawHUD

**Purpose**

Draws HUD elements for the tool gun interface (placeholder for custom implementation)

**When Called**

Every frame when the tool gun is active and HUD should be displayed

**Parameters**

* `surface.DrawRect(scrW/2` (*unknown*): 50, scrH - 80, progress * 100, 10)

---

### drawHUD

**Purpose**

Draws HUD elements for the tool gun interface (placeholder for custom implementation)

**When Called**

Every frame when the tool gun is active and HUD should be displayed

**Parameters**

* `surface.DrawRect(scrW/2` (*unknown*): 50, scrH - 80, progress * 100, 10)

---

### getServerInfo

**Purpose**

Retrieves server-side ConVar information for the current tool mode

**When Called**

When the tool needs to access server configuration values

---

### buildConVarList

**Purpose**

Builds a formatted list of ConVars for the current tool mode

**When Called**

When the tool needs to provide a list of available ConVars for UI or configuration

---

### getClientInfo

**Purpose**

Retrieves client-side ConVar information for the current tool mode

**When Called**

When the tool needs to access client configuration values from the owner

---

### getClientNumber

**Purpose**

Retrieves client-side ConVar information as a number for the current tool mode

**When Called**

When the tool needs numeric client configuration values with fallback defaults

---

### allowed

**Purpose**

Checks if the tool is allowed to be used based on server configuration

**When Called**

Before performing tool operations to verify permissions

---

### init

**Purpose**

Initializes the tool gun instance (placeholder for custom implementation)

**When Called**

When the tool gun is first created or deployed

---

### init

**Purpose**

Initializes the tool gun instance (placeholder for custom implementation)

**When Called**

When the tool gun is first created or deployed

---

### init

**Purpose**

Initializes the tool gun instance (placeholder for custom implementation)

**When Called**

When the tool gun is first created or deployed

---

### getMode

**Purpose**

Retrieves the current tool mode identifier

**When Called**

When other methods need to know which tool mode is active

---

### getSWEP

**Purpose**

Retrieves the SWEP (Scripted Weapon) instance associated with this tool

**When Called**

When the tool needs to access the underlying weapon entity

---

### GetOwner

**Purpose**

Retrieves the player who owns/holds this tool gun

**When Called**

When the tool needs to access the owning player for permissions, communication, or data

---

### getWeapon

**Purpose**

Retrieves the weapon entity associated with this tool gun

**When Called**

When the tool needs to access the weapon entity for physics or rendering operations

---

### leftClick

**Purpose**

Handles left mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player left-clicks while holding the tool gun

---

### leftClick

**Purpose**

Handles left mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player left-clicks while holding the tool gun

---

### leftClick

**Purpose**

Handles left mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player left-clicks while holding the tool gun

---

### leftClick

**Purpose**

Handles left mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player left-clicks while holding the tool gun

---

### rightClick

**Purpose**

Handles right mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player right-clicks while holding the tool gun

---

### rightClick

**Purpose**

Handles right mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player right-clicks while holding the tool gun

---

### rightClick

**Purpose**

Handles right mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player right-clicks while holding the tool gun

---

### rightClick

**Purpose**

Handles right mouse button click interactions (placeholder for custom implementation)

**When Called**

When the player right-clicks while holding the tool gun

---

### reload

**Purpose**

Handles reload key press to clear/reset tool objects and state

**When Called**

When the player presses the reload key (default R) while holding the tool gun

---

### reload

**Purpose**

Handles reload key press to clear/reset tool objects and state

**When Called**

When the player presses the reload key (default R) while holding the tool gun

---

### reload

**Purpose**

Handles reload key press to clear/reset tool objects and state

**When Called**

When the player presses the reload key (default R) while holding the tool gun

---

### reload

**Purpose**

Handles reload key press to clear/reset tool objects and state

**When Called**

When the player presses the reload key (default R) while holding the tool gun

---

### deploy

**Purpose**

Handles tool deployment when the weapon is drawn/equipped

**When Called**

When the player switches to or initially equips the tool gun

---

### deploy

**Purpose**

Handles tool deployment when the weapon is drawn/equipped

**When Called**

When the player switches to or initially equips the tool gun

---

### deploy

**Purpose**

Handles tool deployment when the weapon is drawn/equipped

**When Called**

When the player switches to or initially equips the tool gun

---

### deploy

**Purpose**

Handles tool deployment when the weapon is drawn/equipped

**When Called**

When the player switches to or initially equips the tool gun

---

### holster

**Purpose**

Handles tool holstering when the weapon is put away/switched from

**When Called**

When the player switches away from the tool gun or puts it away

**Parameters**

* `net.WriteBool(true)` (*unknown*): - Successfully holstered

---

### holster

**Purpose**

Handles tool holstering when the weapon is put away/switched from

**When Called**

When the player switches away from the tool gun or puts it away

**Parameters**

* `net.WriteBool(true)` (*unknown*): - Successfully holstered

---

### holster

**Purpose**

Handles tool holstering when the weapon is put away/switched from

**When Called**

When the player switches away from the tool gun or puts it away

**Parameters**

* `net.WriteBool(true)` (*unknown*): - Successfully holstered

---

### holster

**Purpose**

Handles tool holstering when the weapon is put away/switched from

**When Called**

When the player switches away from the tool gun or puts it away

**Parameters**

* `net.WriteBool(true)` (*unknown*): - Successfully holstered

---

### think

**Purpose**

Main think function called every frame while the tool is active (placeholder for custom implementation)

**When Called**

Every frame/tick while the tool gun is deployed and active

---

### think

**Purpose**

Main think function called every frame while the tool is active (placeholder for custom implementation)

**When Called**

Every frame/tick while the tool gun is deployed and active

---

### think

**Purpose**

Main think function called every frame while the tool is active (placeholder for custom implementation)

**When Called**

Every frame/tick while the tool gun is deployed and active

---

### think

**Purpose**

Main think function called every frame while the tool is active (placeholder for custom implementation)

**When Called**

Every frame/tick while the tool gun is deployed and active

---

### checkObjects

**Purpose**

Validates and cleans up invalid objects in the tool's object list

**When Called**

Periodically during tool operation to maintain object integrity

---

### checkObjects

**Purpose**

Validates and cleans up invalid objects in the tool's object list

**When Called**

Periodically during tool operation to maintain object integrity

---

### checkObjects

**Purpose**

Validates and cleans up invalid objects in the tool's object list

**When Called**

Periodically during tool operation to maintain object integrity

---

### checkObjects

**Purpose**

Validates and cleans up invalid objects in the tool's object list

**When Called**

Periodically during tool operation to maintain object integrity

---

### clearObjects

**Purpose**

Completely clears all objects from the tool's object list and performs cleanup

**When Called**

When explicitly clearing all tool objects or during error recovery

---

### clearObjects

**Purpose**

Completely clears all objects from the tool's object list and performs cleanup

**When Called**

When explicitly clearing all tool objects or during error recovery

---

### clearObjects

**Purpose**

Completely clears all objects from the tool's object list and performs cleanup

**When Called**

When explicitly clearing all tool objects or during error recovery

---

### releaseGhostEntity

**Purpose**

Safely removes and cleans up the ghost entity used for preview/placement

**When Called**

When switching tools, holstering, or when the ghost entity is no longer needed

---

### releaseGhostEntity

**Purpose**

Safely removes and cleans up the ghost entity used for preview/placement

**When Called**

When switching tools, holstering, or when the ghost entity is no longer needed

---

### releaseGhostEntity

**Purpose**

Safely removes and cleans up the ghost entity used for preview/placement

**When Called**

When switching tools, holstering, or when the ghost entity is no longer needed

---

