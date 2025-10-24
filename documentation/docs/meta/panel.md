# Panel Meta

Panel management system for the Lilia framework.

---

## Overview

The panel meta table provides comprehensive functionality for managing VGUI panels, UI interactions, and panel operations in the Lilia framework. It handles panel event listening, inventory synchronization, UI updates, and panel-specific operations. The meta table operates primarily on the client side, with the server providing data that panels can listen to and display. It includes integration with the inventory system for inventory change notifications, character system for character data display, network system for data synchronization, and UI system for panel management. The meta table ensures proper panel event handling, inventory synchronization, UI updates, and comprehensive panel lifecycle management from creation to destruction.

---

### liaListenForInventoryChanges

**Purpose**

Sets up event listeners for inventory changes on a panel

**When Called**

When a UI panel needs to respond to inventory modifications, typically during panel initialization

**Parameters**

* `inventory` (*unknown*): The inventory object to listen for changes on

---

### liaDeleteInventoryHooks

**Purpose**

Removes inventory change event listeners from a panel

**When Called**

When a panel no longer needs to listen to inventory changes, during cleanup, or when switching inventories

---

### setScaledPos

**Purpose**

Sets the position of a panel with automatic screen scaling

**When Called**

When positioning UI elements that need to adapt to different screen resolutions

**Parameters**

* `x` (*unknown*): The horizontal position value to be scaled
* `y` (*unknown*): The vertical position value to be scaled

---

### setScaledSize

**Purpose**

Sets the size of a panel with automatic screen scaling

**When Called**

When sizing UI elements that need to adapt to different screen resolutions

**Parameters**

* `w` (*unknown*): The width value to be scaled
* `h` (*unknown*): The height value to be scaled

---

