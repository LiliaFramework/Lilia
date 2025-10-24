# Modularity Library

Module loading, initialization, and lifecycle management system for the Lilia framework.

---

## Overview

The modularity library provides comprehensive functionality for managing modules in the Lilia framework.

It handles loading, initialization, and management of modules including schemas, preload modules,

and regular modules. The library operates on both server and client sides, managing module dependencies,

permissions, and lifecycle events. It includes functionality for loading modules from directories,

handling module-specific data storage, and ensuring proper initialization order. The library also

manages submodules, handles module validation, and provides hooks for module lifecycle events.

It ensures that all modules are properly loaded and initialized before gameplay begins.

---

### load

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Parameters**

* `uniqueID` (*string*): Unique identifier for the module
* `path` (*string*): File system path to the module directory
* `variable` (*string, optional*): Global variable name to use (defaults to "MODULE")
* `skipSubmodules` (*boolean, optional*): Whether to skip loading submodules

---

### lia.MODULE:IsValid

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Parameters**

* `uniqueID` (*string*): Unique identifier for the module
* `path` (*string*): File system path to the module directory
* `variable` (*string, optional*): Global variable name to use (defaults to "MODULE")
* `skipSubmodules` (*boolean, optional*): Whether to skip loading submodules

---

### lia.MODULE:setData

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Parameters**

* `uniqueID` (*string*): Unique identifier for the module
* `path` (*string*): File system path to the module directory
* `variable` (*string, optional*): Global variable name to use (defaults to "MODULE")
* `skipSubmodules` (*boolean, optional*): Whether to skip loading submodules

---

### lia.MODULE:getData

**Purpose**

Loads a module from the specified path with the given unique identifier

**When Called**

Called during module initialization, when loading modules from directories, or when manually loading specific modules

**Parameters**

* `uniqueID` (*string*): Unique identifier for the module
* `path` (*string*): File system path to the module directory
* `variable` (*string, optional*): Global variable name to use (defaults to "MODULE")
* `skipSubmodules` (*boolean, optional*): Whether to skip loading submodules

---

### initialize

**Purpose**

Initializes the entire module system, loading schemas, preload modules, and regular modules in proper order

**When Called**

Called during gamemode initialization to set up the complete module ecosystem

---

### loadFromDir

**Purpose**

Loads all modules from a specified directory

**When Called**

Called during module initialization to load multiple modules from a directory, or when manually loading modules from a specific folder

**Parameters**

* `directory` (*string*): Path to the directory containing modules
* `group` (*string*): Type of module group ("module", "schema", etc.)
* `skip` (*table, optional*): Table of module IDs to skip loading

---

### get

**Purpose**

Retrieves a loaded module by its unique identifier

**When Called**

Called when you need to access a specific module's data or functions, or to check if a module is loaded

**Parameters**

* `identifier` (*string*): Unique identifier of the module to retrieve

---

