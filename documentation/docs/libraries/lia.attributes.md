# Attributes Library

This page documents the functions for working with character attributes.

---

## Overview

The attributes library loads attribute definitions from Lua files and provides helpers for initializing them on a character. Each attribute is defined on a global `ATTRIBUTE` table inside its own file. When
`lia.attribs.loadFromDir` is called, each file is included in the shared realm, the attribute's `name` and `desc` fields are
replaced with their translated versions (defaulting to `L("unknown")` and `L("noDesc")` when absent), and the definition is stored in `lia.attribs.list`
using the file name without extension as the key. Files beginning with `sh_` have the prefix removed and the remaining name
lowercased; other filenames are used as-is. If an attribute was already registered, its existing table is reused, allowing
definitions to be extended across multiple files or reloads. After each file is processed the temporary global `ATTRIBUTE` is
cleared. The loader is invoked automatically when a module is initialized, so most schemas simply place their attribute files in
`schema/attributes/`.

For details on each `ATTRIBUTE` field, see the [Attribute Fields documentation](../definitions/attribute.md).

### lia.attribs.list

Table of all registered attribute definitions. Keys are attribute IDs derived from the filenames passed to
`lia.attribs.loadFromDir`, and values are the attribute tables themselves. The table is populated when attributes are loaded and
used by other functions such as `lia.attribs.setup`.

### lia.attribs.loadFromDir

**Purpose**

Loads attribute definitions from each `.lua` file in the given directory, includes them in the shared realm, localizes their `name` and `desc` fields, and registers them in `lia.attribs.list`. Filenames supply the list key—if a file begins with `sh_`, the prefix is stripped and the remaining name lowercased; otherwise the filename without extension is used as-is. If the attribute was previously registered, the existing table is reused. Missing `name` or `desc` fields default to `L("unknown")` and `L("noDesc")`.

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

Initializes or refreshes attribute data for a player's character by looping through `lia.attribs.list`. For each attribute it retrieves the character's value (defaulting to 0) and, if the attribute defines `OnSetup`, calls it as `attribute:OnSetup(client, value)`. If the client has no character, the function returns without doing anything.

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
