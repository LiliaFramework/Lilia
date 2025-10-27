# Module Definitions

Module definition system for the Lilia framework.

---

## Overview

The module system provides comprehensive functionality for defining modules within the Lilia framework. Modules represent self-contained systems that add specific functionality to the gamemode, each with unique properties, behaviors, and configuration options. The system supports both server-side logic for gameplay mechanics and client-side properties for user interface and experience. Modules are defined using the MODULE table structure, which includes properties for identification, metadata, dependencies, privileges, and configuration. The system includes callback methods that are automatically invoked during key module lifecycle events, enabling dynamic behavior and customization. Modules can have dependencies, privileges, network strings, and various configuration options, providing a flexible foundation for modular systems.

---

### name

**Purpose**

Sets the display name of the module

**Example Usage**

```lua
-- Set the display name for the module
MODULE.name = "Inventory System"

```

---

### author

**Purpose**

Sets the author of the module

**Example Usage**

```lua
-- Set the module author
MODULE.author = "Samael"

```

---

### discord

**Purpose**

Sets the Discord contact for the module author

**Example Usage**

```lua
-- Set the Discord contact for support
MODULE.discord = "@liliaplayer"

```

---

### desc

**Purpose**

Sets the description of the module

**Example Usage**

```lua
-- Set a detailed description of what the module does
MODULE.desc = "A comprehensive inventory management system"

```

---

### version

**Purpose**

Sets the version number of the module

**Example Usage**

```lua
-- Set the module version number
MODULE.version = 1.0

```

---

### versionID

**Purpose**

Sets the unique version identifier for the module

**Example Usage**

```lua
-- Set a unique identifier for version tracking
MODULE.versionID = "private_inventory"

```

---

### uniqueID

**Purpose**

Unique identifier for the module (INTERNAL - set automatically when loaded)

**When Called**

Set automatically during module loading

**Example Usage**

```lua
-- This is set automatically when the module is loaded from its folder name
-- Module in folder "inventory" will have uniqueID = "inventory"

```

---

### Privileges

**Purpose**

Sets the privileges required for this module

**Example Usage**

```lua
-- Define required privileges for module access
MODULE.Privileges = {
    {
        Name = "canManageInventory",
        Min = 1
    }
}

```

---

### Dependencies

**Purpose**

Sets the file dependencies for this module

**Example Usage**

```lua
-- Define required files for this module
MODULE.Dependencies = {
    {
        File = "gridinv.lua",
        Type = "shared"
    }
}

```

---

### NetworkStrings

**Purpose**

Sets the network strings used by this module

**Example Usage**

```lua
-- Define network strings for client-server communication
MODULE.NetworkStrings = {"liaInventoryOpen", "liaInventorySync"}

```

---

### WorkshopContent

**Purpose**

Sets the Workshop content IDs required by this module

**Example Usage**

```lua
-- Set required Workshop content (single ID or table of IDs)
MODULE.WorkshopContent = "1234567890"
MODULE.WorkshopContent = {"1234567890", "0987654321"}

```

---

### WebSounds

**Purpose**

Sets the web-hosted sound files used by this module

**Example Usage**

```lua
-- Define web-hosted sound files for the module
MODULE.WebSounds = {
    ["sounds/beep.wav"] = "https://example.com/sounds/beep.wav"
}

```

---

### WebImages

**Purpose**

Sets the web-hosted image files used by this module

**Example Usage**

```lua
-- Define web-hosted image files for the module
MODULE.WebImages = {
    ["icons/inventory.png"] = "https://example.com/icons/inventory.png"
}

```

---

### enabled

**Purpose**

Sets whether the module is enabled by default

**Example Usage**

```lua
-- Enable or disable the module by default
MODULE.enabled = true

```

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

**Example Usage**

```lua
-- Called after all module files are loaded
function MODULE:OnLoaded()
    print("Module loaded successfully!")
end

```

---

