# Attributes Library

This page documents the functions for working with character attributes.

---

## Overview

The attributes library loads attribute definitions from Lua files, keeps track of

character values, and provides helper methods for modifying them. Each attribute

is defined on a global `ATTRIBUTE` table inside its own file. When

`lia.attribs.loadFromDir` is called the file is included **shared**, default

values are filled in and the definition is stored in `lia.attribs.list` using the

file name (without extension or the `sh_` prefix) as the key. The loader will be

invoked automatically when a module is initialized, so most schemas simply place

their attribute files in `schema/attributes/`.

---

### ATTRIBUTE table fields

Each attribute definition may specify any of the following keys on the global

`ATTRIBUTE` table:

| Field | Type | Purpose |
| --- | --- | --- |
| `name` | string | Display name shown in menus. |
| `desc` | string | Short description for tooltips. |
| `startingMax` | number | Creation-time cap before bonuses. |
| `noStartBonus` | boolean | Prevents allocating starting points. |
| `maxValue` | number | Absolute ceiling for this attribute. |

The optional function `ATTRIBUTE:OnSetup(client, value)` runs whenever

`lia.attribs.setup` processes that attribute. See the [Attribute Fields

documentation](../definitions/attribute.md) for detailed explanations.

---

### lia.attribs.loadFromDir

**Description:**

Loads attribute definitions from the given folder. Every Lua file in

the directory is included as **shared** so its contents run on both the

server and the client. Inside each file you create a global table named

`ATTRIBUTE` and populate it with your fields. After the file is included

the table is stored inside `lia.attribs.list` using the lowercase

filename (without extension) as the key.

**Parameters:**

* `directory` (`string`) – Path to the folder containing attribute Lua files.


**Realm:**

* Shared


**Returns:**

* None


**Example Usage:**

```lua
-- schema/attributes/sh_strength.lua
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

**Description:**

Initializes attribute data for a client's character. Each attribute in

lia.attribs.list is read from the character and, if the attribute has

an OnSetup callback, it is executed with the current value.

**Parameters:**

* `client` (`Player`) – The player whose character attributes should be set up.


**Realm:**

* Server


**Returns:**

* None


**Example Usage:**

```lua
-- After modifying a character attribute, run setup again so any
-- OnSetup hooks update the player's stats.
local char = client:getChar()
char:updateAttrib("strength", 5)
lia.attribs.setup(client)
```
