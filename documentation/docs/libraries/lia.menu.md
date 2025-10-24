# Menu Library

Interactive 3D context menu system for world and entity interactions in the Lilia framework.

---

## Overview

The menu library provides a comprehensive context menu system for the Lilia framework.

It enables the creation of interactive context menus that appear in 3D world space or

attached to entities, allowing players to interact with objects and perform actions

through a visual interface. The library handles menu positioning, animation, collision

detection, and user interaction. Menus automatically fade in when the player looks at

them and fade out when they look away, with smooth animations and proper range checking.

The system supports both world-positioned menus and entity-attached menus with automatic

screen space conversion and boundary clamping to ensure menus remain visible and accessible.

---

### add

**Purpose**

Creates and adds a new context menu to the menu system

**When Called**

When you need to display a context menu with options for player interaction

**Parameters**

* `opts` (*table*): Table of menu options where keys are display text and values are callback functions
* `pos` (*Vector|Entity, optional*): World position or entity to attach menu to. If entity, menu attaches to entity's local position
* `onRemove` (*function, optional*): Callback function called when menu is removed

---

### drawAll

**Purpose**

Renders all active context menus with animations and interaction detection

**When Called**

Called every frame from the HUD rendering system to draw all menus

---

### getActiveMenu

**Purpose**

Gets the currently active menu item that the player is hovering over

**When Called**

When checking for menu interaction, typically from input handling systems

---

### onButtonPressed

**Purpose**

Handles button press events for menu items and removes the menu

**When Called**

When a menu item is clicked or activated by player input

**Parameters**

* `id` (*number*): Index of the menu to remove from the menu list
* `cb` (*function, optional*): Callback function to execute when button is pressed

---

