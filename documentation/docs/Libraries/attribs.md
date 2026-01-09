# Attributes Library

Character attribute management system for the Lilia framework.

---

Overview

The attributes library provides functionality for managing character attributes in the Lilia framework. It handles loading attribute definitions from files, registering attributes in the system, and setting up attributes for characters during spawn. The library operates on both server and client sides, with the server managing attribute setup during character spawning and the client handling attribute-related UI elements. It includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior.

---

### lia.attribs.loadFromDir

#### 📋 Purpose
Discover and include attribute definitions from a directory.

#### ⏰ When Called
During schema/gamemode startup to load all attribute files.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | Path containing attribute Lua files. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Load default and custom attributes.
    lia.attribs.loadFromDir(lia.plugin.getDir() .. "/attribs")
    lia.attribs.loadFromDir("schema/attribs")

```

---

### lia.attribs.register

#### 📋 Purpose
Register or update an attribute definition in the global list.

#### ⏰ When Called
After loading an attribute file or when hot-reloading attributes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Attribute key. |
| `data` | **table** | Fields like name, desc, OnSetup, setup, etc. |

#### ↩️ Returns
* table
The stored attribute table.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    lia.attribs.register("strength", {
        name = "Strength",
        desc = "Improves melee damage and carry weight.",
        OnSetup = function(client, value)
            client:SetJumpPower(160 + value * 0.5)
        end
    })

```

---

### lia.attribs.setup

#### 📋 Purpose
Run attribute setup logic for a character on the server.

#### ⏰ When Called
On player spawn/character load to reapply attribute effects.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | Player whose character attributes are being applied. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    hook.Add("PlayerLoadedChar", "ApplyAttributeBonuses", function(ply)
        lia.attribs.setup(ply)
    end)

```

---

