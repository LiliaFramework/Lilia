# Configuration Library

Comprehensive user-configurable settings management system for the Lilia framework.

---

## Overview

The configuration library provides comprehensive functionality for managing user-configurable settings

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

Adds a new configuration option to the system with specified properties and validation

**When Called**

During gamemode initialization, module loading, or when registering new config options

**Parameters**

* `key` (*string*): Unique identifier for the configuration option
* `name` (*string*): Display name for the configuration option
* `value` (*any*): Default value for the configuration option
* `callback` (*function, optional*): Function to call when the option value changes
* `data` (*table*): Configuration metadata including type, description, category, and constraints

---

### getOptions

**Purpose**

Retrieves the available options for a configuration setting, supporting both static and dynamic option lists

**When Called**

When building UI elements for configuration options, particularly dropdown menus and selection lists

**Parameters**

* `key` (*string*): The configuration key to get options for

---

### setDefault

**Purpose**

Updates the default value for an existing configuration option without changing the current value

**When Called**

During configuration updates, module reloads, or when default values need to be changed

**Parameters**

* `key` (*string*): The configuration key to update the default for
* `value` (*any*): The new default value to set

---

### forceSet

**Purpose**

Forces a configuration value to be set immediately without triggering networking or callbacks, with optional save control

**When Called**

During initialization, module loading, or when bypassing normal configuration update mechanisms

**Parameters**

* `key` (*string*): The configuration key to set
* `value` (*any*): The value to set
* `noSave` (*boolean, optional*): If true, prevents automatic saving of the configuration

---

### set

**Purpose**

Sets a configuration value with full networking, callback execution, and automatic saving on server

**When Called**

When users change configuration values through UI, commands, or programmatic updates

**Parameters**

* `key` (*string*): The configuration key to set
* `value` (*any*): The value to set

---

### get

**Purpose**

Retrieves the current value of a configuration option with fallback to default values

**When Called**

When reading configuration values for gameplay logic, UI updates, or module functionality

**Parameters**

* `key` (*string*): The configuration key to retrieve
* `default` (*any, optional*): Fallback value if configuration doesn't exist

---

### load

**Purpose**

Loads configuration values from the database on server or requests them from server on client

**When Called**

During gamemode initialization, after database connection, or when configuration needs to be refreshed

---

### getChangedValues

**Purpose**

Retrieves all configuration values that differ from their default values for efficient synchronization

**When Called**

Before sending configurations to clients or when preparing configuration data for export

---

### send

**Purpose**

Sends configuration data to clients with intelligent batching and rate limiting for large datasets

**When Called**

When a client connects, when configurations change, or when manually syncing configurations

**Parameters**

* `client` (*Player, optional*): Specific client to send to, or nil to send to all clients

---

### save

**Purpose**

Saves all changed configuration values to the database using transaction-based operations

**When Called**

When configuration values change, during server shutdown, or when manually saving configurations

---

### reset

**Purpose**

Resets all configuration values to their default values and synchronizes changes to clients

**When Called**

When resetting server configurations, during maintenance, or when reverting to defaults

---

