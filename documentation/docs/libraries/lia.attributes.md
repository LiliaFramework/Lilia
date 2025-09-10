# Attributes Library

This page documents the functions for working with character attributes and their management.

---

## Overview

The attributes library (`lia.attribs`) provides a system for managing character attributes in the Lilia framework. It handles loading attribute definitions from files, setting up attributes for characters, and managing attribute data throughout the character's lifecycle.

---

### lia.attribs.loadFromDir

**Purpose**

Loads attribute definitions from a directory containing attribute files.

**Parameters**

* `directory` (*string*): The directory path to load attribute files from.

**Returns**

*None*

**Realm**

Shared.

**Example Usage**

```lua
-- Load attributes from a directory
lia.attribs.loadFromDir("gamemode/attributes")

-- Load from a custom attributes folder
lia.attribs.loadFromDir("addons/myaddon/attributes")

-- Load from schema attributes
lia.attribs.loadFromDir("schema/attributes")
```

---

### lia.attribs.setup

**Purpose**

Sets up attributes for a client character, calling OnSetup callbacks for each attribute.

**Parameters**

* `client` (*Player*): The client to set up attributes for.

**Returns**

*None*

**Realm**

Server.

**Example Usage**

```lua
-- Set up attributes for a character
lia.attribs.setup(client)

-- Set up attributes when character spawns
hook.Add("PlayerSpawn", "SetupAttributes", function(ply)
    local char = ply:getChar()
    if char then
        lia.attribs.setup(ply)
    end
end)

-- Set up attributes after character creation
hook.Add("OnCharCreated", "SetupNewCharAttributes", function(char)
    local client = char:getPlayer()
    if IsValid(client) then
        lia.attribs.setup(client)
    end
end)
```