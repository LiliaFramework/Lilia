# Flags Library

Character permission and access control system for the Lilia framework.

---

## Overview

The flags library provides a comprehensive permission system for managing character abilities

and access rights in the Lilia framework. It allows administrators to assign specific flags

to characters that grant or restrict various gameplay features and tools. The library operates

on both server and client sides, with the server handling flag assignment and callback execution

during character spawning, while the client provides user interface elements for viewing and

managing flags. Flags can have associated callbacks that execute when granted or removed,

enabling dynamic behavior changes based on permission levels. The system includes built-in

flags for common administrative tools like physgun, toolgun, and various spawn permissions.

The library ensures proper flag validation and prevents duplicate flag assignments.

---

### add

**Purpose**

Adds a new flag to the flag system with optional description and callback function

**When Called**

During module initialization or when registering new permission flags

**Parameters**

* `flag` (*string*): Single character flag identifier (e.g., "C", "p", "t")
* `desc` (*string, optional*): Localized description key for the flag
* `callback` (*function, optional*): Function to execute when flag is granted/removed

---

### onSpawn

**Purpose**

Processes and executes callbacks for all flags assigned to a character when they spawn

**When Called**

Automatically called when a character spawns on the server

**Parameters**

* `client` (*Player*): The player whose character is spawning

---

