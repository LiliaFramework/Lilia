# Module Properties and Methods

Module definition system for the Lilia framework.

---

## Overview

The module system provides comprehensive functionality for defining modules

within the Lilia framework. Modules represent self-contained systems that

add specific functionality to the gamemode, each with unique properties,

behaviors, and configuration options. The system supports both server-side

logic for gameplay mechanics and client-side properties for user interface

and experience.



Modules are defined using the MODULE table structure, which includes properties

for identification, metadata, dependencies, privileges, and configuration.

The system includes callback methods that are automatically invoked during

key module lifecycle events, enabling dynamic behavior and customization.

Modules can have dependencies, privileges, network strings, and various

configuration options, providing a flexible foundation for modular systems.

---

### name

**Purpose**

Sets the display name of the module

---

### author

**Purpose**

Sets the author of the module

---

### discord

**Purpose**

Sets the Discord contact for the module author

---

### desc

**Purpose**

Sets the description of the module

---

### version

**Purpose**

Sets the version number of the module

---

### versionID

**Purpose**

Sets the unique version identifier for the module

---

### uniqueID

**Purpose**

Unique identifier for the module (INTERNAL - set automatically when loaded)

**When Called**

Set automatically during module loading

---

### Privileges

**Purpose**

Sets the privileges required for this module

---

### Dependencies

**Purpose**

Sets the file dependencies for this module

---

### NetworkStrings

**Purpose**

Sets the network strings used by this module

---

### WorkshopContent

**Purpose**

Sets the Workshop content IDs required by this module

---

### WebSounds

**Purpose**

Sets the web-hosted sound files used by this module

---

### WebImages

**Purpose**

Sets the web-hosted image files used by this module

---

### enabled

**Purpose**

Sets whether the module is enabled by default

---

### folder

**Purpose**

Sets the folder path for the module

---

### path

**Purpose**

Sets the file path for the module

---

### variable

**Purpose**

Sets the variable name for the module

---

### loading

**Purpose**

Sets whether the module is currently loading

---

### OnLoaded

**Purpose**

Called when the module is fully loaded

---

