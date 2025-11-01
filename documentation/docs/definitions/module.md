# Module Definitions

Module definition system for the Lilia framework.

---

## Overview

The module system provides comprehensive functionality for defining modules within the Lilia framework. Modules represent self-contained systems that add specific functionality to the gamemode, each with unique properties, behaviors, and configuration options. The system supports both server-side logic for gameplay mechanics and client-side properties for user interface and experience. Modules are defined using the MODULE table structure, which includes properties for identification, metadata, dependencies, privileges, and configuration. The system includes callback methods that are automatically invoked during key module lifecycle events, enabling dynamic behavior and customization. Modules can have dependencies, privileges, network strings, and various configuration options, providing a flexible foundation for modular systems.

---

### Purpose:

**Example Usage**

```lua
-- Set the display name for the module
MODULE.name = "Inventory System"

```

---

### Purpose:

**Example Usage**

```lua
-- Set the module author
MODULE.author = "Samael"

```

---

### Purpose:

**Example Usage**

```lua
-- Set the Discord contact for support
MODULE.discord = "@liliaplayer"

```

---

### Purpose:

**Example Usage**

```lua
-- Set a detailed description of what the module does
MODULE.desc = "A comprehensive inventory management system"

```

---

### Purpose:

**Example Usage**

```lua
-- Set the module version number
MODULE.version = 1.0

```

---

### Purpose:

**Example Usage**

```lua
-- Set a unique identifier for version tracking
MODULE.versionID = "private_inventory"

```

---

### Purpose:

**Example Usage**

```lua
-- This is set automatically when the module is loaded from its folder name
-- Module in folder "inventory" will have uniqueID = "inventory"

```

---

### Purpose:

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

### Purpose:

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

### Purpose:

**Example Usage**

```lua
-- Define network strings for client-server communication
MODULE.NetworkStrings = {"liaInventoryOpen", "liaInventorySync"}

```

---

### Purpose:

**Example Usage**

```lua
-- Set required Workshop content (single ID or table of IDs)
MODULE.WorkshopContent = "1234567890"
MODULE.WorkshopContent = {"1234567890", "0987654321"}

```

---

### Purpose:

**Example Usage**

```lua
-- Define web-hosted sound files for the module
MODULE.WebSounds = {
["sounds/beep.wav"] = "https://example.com/sounds/beep.wav"
}

```

---

### Purpose:

**Example Usage**

```lua
-- Define web-hosted image files for the module
MODULE.WebImages = {
["icons/inventory.png"] = "https://example.com/icons/inventory.png"
}

```

---

### Purpose:

**Example Usage**

```lua
-- Enable or disable the module by default
MODULE.enabled = true

```

---

### Purpose:

---

### Purpose:

---

### Purpose:

---

### Purpose:

---

### Purpose:

**Example Usage**

```lua
-- Called after all module files are loaded
function MODULE:OnLoaded()
    print("Module loaded successfully!")
    end

```

---

