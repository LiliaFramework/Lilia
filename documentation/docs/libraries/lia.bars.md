# Bars Library

Dynamic progress bar creation and management system for the Lilia framework.

---

## Overview

The bars library provides a comprehensive system for creating and managing dynamic progress bars

in the Lilia framework. It handles the creation, rendering, and lifecycle management of various

types of bars including health, armor, and custom progress indicators. The library operates

primarily on the client side, providing smooth animated transitions between bar values and

intelligent visibility management based on value changes and user preferences. It includes

built-in health and armor bars, custom action progress displays, and a flexible system for

adding custom bars with priority-based ordering. The library ensures consistent visual

presentation across all bar types while providing hooks for customization and integration

with other framework components.

---

### get

**Purpose**

Retrieves a bar object by its identifier from the bars list

**When Called**

When you need to access or modify an existing bar's properties

---

### add

**Purpose**

Adds a new progress bar to the bars system with specified properties

**When Called**

When creating custom bars or adding new progress indicators to the HUD

---

### remove

**Purpose**

Removes a bar from the bars system by its identifier

**When Called**

When you need to remove a specific bar from the HUD or clean up bars

---

### drawBar

**Purpose**

Draws a single progress bar at specified coordinates with given properties

**When Called**

Internally by the bars system or when manually drawing custom bars

---

### drawAction

**Purpose**

Draws a temporary action progress bar with text overlay for timed actions

**When Called**

When displaying progress for actions like reloading, healing, or other timed activities

---

### drawAll

**Purpose**

Renders all registered bars in priority order with smooth animations and visibility management

**When Called**

Automatically called during HUDPaintBackground hook, or manually for custom rendering

---

