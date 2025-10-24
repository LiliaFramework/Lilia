# Panel Meta Table

This file extends the base Panel metatable in Garry's Mod with additional functionality

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

