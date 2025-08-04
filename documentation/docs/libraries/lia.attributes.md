# Attributes Library

This page documents the functions for working with character attributes.

---

## Overview

The attributes library loads attribute definitions from Lua files, keeps track of character values, and provides helper methods for modifying them. Each attribute is defined on a global `ATTRIBUTE` table inside its own file. When `lia.attribs.loadFromDir` is called the file is included **shared**, default values are filled in, and the definition is stored in `lia.attribs.list` using the file name (without extension or the `sh_` prefix) as the key. The loader is invoked automatically when a module is initialized, so most schemas simply place their attribute files in `schema/attributes/`.

For details on each `ATTRIBUTE` field, see the [Attribute Fields documentation](../definitions/attribute.md).

### lia.attribs.loadFromDir

**Purpose**

Loads attribute definitions from every Lua file in the given directory and registers them in `lia.attribs.list`.

**Parameters**

* `directory` (*string*): Path to the folder containing attribute Lua files.

**Realm**

`Shared`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- schema/attributes/strength.lua
ATTRIBUTE.name = "Strength"
ATTRIBUTE.desc = "Determines melee damage."
ATTRIBUTE.startingMax = 20
ATTRIBUTE.maxValue = 50

function ATTRIBUTE:OnSetup(client, value)
    client:SetMaxHealth(100 + value)
end

-- Load all attribute files once at startup
lia.attribs.loadFromDir("schema/attributes")
```

---

### lia.attribs.setup

**Purpose**

Initializes and refreshes attribute data for a player's character, invoking any `OnSetup` callbacks defined by individual attributes.

**Parameters**

* `client` (*Player*): The player whose character attributes should be set up.

**Realm**

`Server`

**Returns**

* *nil*: This function does not return a value.

**Example Usage**

```lua
-- After modifying a character attribute, run setup again so any
-- OnSetup hooks update the player's stats.
local char = client:getChar()
char:updateAttrib("strength", 5)
lia.attribs.setup(client)
```

---
