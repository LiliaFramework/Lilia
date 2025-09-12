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

---

## Definitions

# Attribute Fields

> This entry describes all configurable `ATTRIBUTE` fields in the codebase. Use these to control each attribute's display, limits, and behavior when applied to players. Unspecified fields fall back to sensible defaults.

---

## Overview

Each attribute is registered on the global `ATTRIBUTE` table. You can customize:

* **Display**: The `name` and `desc` that players see in-game.

* **Startup bonus**: Whether this attribute can receive points from the pool allocated during character creation.

* **Value limits**: The hard cap (`maxValue`) and the creation-time base cap (`startingMax`).

---

## Fields

### ATTRIBUTE.name

Human readable title shown in menus. When the attribute is loaded,

`lia.attribs.loadFromDir` automatically defaults this to the translated

string "Unknown" if no name is provided.

```lua
ATTRIBUTE.name = "Strength"
```

---

### ATTRIBUTE.desc

Concise description or lore text for the attribute. Defaults to the

translation "No Description" when omitted.

```lua
ATTRIBUTE.desc = "Determines physical power and carrying capacity."
```

---

### ATTRIBUTE.startingMax

Cap on the attribute's base value during character creation. The

configuration variable `MaxStartingAttributes` (default `30`) provides

the fallback value when this field is not defined.

```lua
ATTRIBUTE.startingMax = 15
```

---

### ATTRIBUTE.noStartBonus

If set to `true`, players cannot allocate any of their initial creation

bonus points to this attribute. The attribute can still increase later

through normal gameplay or boosts.

```lua
ATTRIBUTE.noStartBonus = false
```

---

### ATTRIBUTE.maxValue

Absolute ceiling an attribute can ever reach. Defaults to the

`MaxAttributePoints` configuration value (30) when unspecified.

```lua
ATTRIBUTE.maxValue = 50
```

---

### ATTRIBUTE.min

Minimum value used for display purposes in character information panels.

This field controls the lower bound shown in progress bars and other UI elements.

```lua
ATTRIBUTE.min = 0
```

---

### ATTRIBUTE.max

Maximum value used for display purposes in character information panels.

This field controls the upper bound shown in progress bars and other UI elements.

```lua
ATTRIBUTE.max = 100
```

---

## Hooks

### ATTRIBUTE:OnSetup

**Purpose**

Called whenever `lia.attribs.setup` initializes or refreshes this attribute for a player.

**Parameters**

* `client` (*Player*): The player that owns the attribute.
* `value` (*number*): Current attribute value including temporary boosts.

**Returns**

* `nil` (*nil*): This function does not return a value.

**Realm**

Server.

**Example Usage**

```lua
function ATTRIBUTE:OnSetup(client, value)
    -- Apply movement bonuses based on this attribute level.
    client:SetRunSpeed(lia.config.get("RunSpeed") + value * 5)
    client:SetJumpPower(client:GetJumpPower() + value * 2)

    -- Expand the character's carry weight by one kilogram per point.
    local char = client:getChar()
    if char then
        char:setData("maxCarry", 15 + value)
    end
end
```

---

## Example

```lua
-- agility.lua
ATTRIBUTE.name = "Agility"
ATTRIBUTE.desc = "Improves your reflexes and overall movement speed."
ATTRIBUTE.startingMax = 20
ATTRIBUTE.noStartBonus = false
ATTRIBUTE.maxValue = 50
ATTRIBUTE.min = 0
ATTRIBUTE.max = 100

function ATTRIBUTE:OnSetup(client, value)
    -- Apply movement bonuses based on this attribute level.
    client:SetRunSpeed(lia.config.get("RunSpeed") + value * 5)
    client:SetJumpPower(client:GetJumpPower() + value * 2)
end
```
```