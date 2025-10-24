# Keybind Library

Keyboard binding registration, storage, and execution system for the Lilia framework.

---

## Overview

The keybind library provides comprehensive functionality for managing keyboard bindings

in the Lilia framework. It handles registration, storage, and execution of custom keybinds

that can be triggered by players. The library supports both client-side and server-side

keybind execution, with automatic networking for server-only keybinds. It includes

persistent storage of keybind configurations, user interface for keybind management,

and validation to prevent key conflicts. The library operates on both client and server

sides, with the client handling input detection and UI, while the server processes

server-only keybind actions. It ensures proper key mapping, callback execution,

and provides a complete keybind management system for the gamemode.

---

### add

**Purpose**

Registers a new keybind with the keybind system, allowing players to bind custom actions to keyboard keys

**When Called**

During initialization of modules or when registering custom keybinds for gameplay features

**Parameters**

* `k` (*string|number*): Either the action name (string) or key code (number) depending on parameter format
* `d` (*table|string*): Either configuration table with keyBind, desc, onPress, etc. or action name (string)
* `desc` (*string, optional*): Description of the keybind action (used when d is action name)
* `cb` (*table, optional*): Callback table with onPress, onRelease, shouldRun, serverOnly functions (used when d is action name)

---

### get

**Purpose**

Retrieves the current key code bound to a specific keybind action

**When Called**

When checking what key is currently bound to an action, typically in UI or validation code

**Parameters**

* `a` (*string*): The action name to get the key for
* `df` (*number, optional*): Default key code to return if no key is bound

---

### save

**Purpose**

Saves all current keybind configurations to a JSON file for persistent storage

**When Called**

When keybind settings are changed by the player or during shutdown to preserve settings

---

### load

**Purpose**

Loads keybind configurations from a JSON file and applies them to the keybind system

**When Called**

During client initialization to restore previously saved keybind settings

---

