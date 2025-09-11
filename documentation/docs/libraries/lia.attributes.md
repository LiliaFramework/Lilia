# Attributes Library

This page documents the functions for working with character attributes and their management.

---

## Overview

The attributes library (`lia.attribs`) provides a comprehensive system for managing character attributes, skill progression, and character development in the Lilia framework, serving as the core character advancement system that enables dynamic character growth and specialized abilities throughout gameplay. This library handles sophisticated attribute management with support for multiple attribute types, complex progression systems, and dynamic attribute calculations that create meaningful character development choices and specialized character builds. The system features advanced attribute definitions with support for custom attribute creation, attribute dependencies, and complex attribute interactions that enable rich character customization and progression mechanics. It includes comprehensive attribute loading with support for modular attribute definitions, automatic attribute discovery, and dynamic attribute registration that allows for flexible and extensible character development systems. The library provides robust attribute data management with support for persistent attribute storage, attribute synchronization across clients, and real-time attribute updates that maintain consistent character progression throughout the player's experience. Additional features include integration with the framework's character system for seamless attribute integration, performance optimization for complex attribute calculations, and comprehensive attribute validation that ensures balanced and fair character progression, making it essential for creating engaging character development systems that enhance roleplay depth and provide meaningful progression rewards for players.

---

### loadFromDir

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

### setup

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