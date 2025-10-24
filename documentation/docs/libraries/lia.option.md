# Option Library

User-configurable settings management system for the Lilia framework.

---

## Overview

The option library provides comprehensive functionality for managing user-configurable settings

in the Lilia framework. It handles the creation, storage, retrieval, and persistence of various

types of options including boolean toggles, numeric sliders, color pickers, text inputs, and

dropdown selections. The library operates on both client and server sides, with automatic

persistence to JSON files and optional networking capabilities for server-side options. It

includes a complete user interface system for displaying and modifying options through the

configuration menu, with support for categories, visibility conditions, and real-time updates.

The library ensures that all user preferences are maintained across sessions and provides

hooks for modules to react to option changes.

---

### add

**Purpose**

Registers a new configurable option in the Lilia framework with automatic type detection and UI generation

**When Called**

During module initialization or when adding new user-configurable settings

**Parameters**

* `key` (*string*): Unique identifier for the option
* `name` (*string*): Display name for the option (can be localized)
* `desc` (*string*): Description text for the option (can be localized)
* `default` (*any*): Default value for the option
* `callback` (*function, optional*): Function called when option value changes (oldValue, newValue)
* `data` (*table*): Configuration data containing type, category, min/max values, etc.

---

### getOptions

**Purpose**

Retrieves the available options for a dropdown/selection type option, handling both static and dynamic option lists

**When Called**

When rendering dropdown options in the UI or when modules need to access option choices

**Parameters**

* `key` (*string*): The option key to get choices for

---

### set

**Purpose**

Sets the value of an option, triggers callbacks, saves to file, and optionally networks to clients

**When Called**

When user changes an option value through UI or when programmatically updating option values

**Parameters**

* `key` (*string*): The option key to set
* `value` (*any*): The new value to set for the option

---

### get

**Purpose**

Retrieves the current value of an option, falling back to default value or provided fallback if not set

**When Called**

When modules need to read option values for configuration or when UI needs to display current values

**Parameters**

* `key` (*string*): The option key to retrieve
* `default` (*any, optional*): Fallback value if option doesn't exist or has no value

---

### save

**Purpose**

Saves all current option values to a JSON file for persistence across sessions

**When Called**

Automatically called when options are changed, or manually when saving configuration

**Parameters**

* `lia.option.save()` (*unknown*): - Automatically called, but can be called manually

---

### load

**Purpose**

Loads saved option values from JSON file and initializes options with defaults if no saved data exists

**When Called**

During client initialization or when manually reloading option configuration

---

