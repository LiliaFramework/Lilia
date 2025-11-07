# Attributes Library

Character attribute management system for the Lilia framework.

---

Overview

The attributes library provides functionality for managing character attributes in the Lilia framework. It handles loading attribute definitions from files, registering attributes in the system, and setting up attributes for characters during spawn. The library operates on both server and client sides, with the server managing attribute setup during character spawning and the client handling attribute-related UI elements. It includes automatic attribute loading from directories, localization support for attribute names and descriptions, and hooks for custom attribute behavior.

---

### lia.attribs.loadFromDir

#### 📋 Purpose
Loads attribute definitions from a specified directory and registers them in the attributes system

#### ⏰ When Called
During gamemode initialization or when loading attribute modules

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `directory` | **string** | The directory path to search for attribute files |

#### ↩️ Returns
* None (modifies lia.attribs.list)

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Load attributes from a single directory
    lia.attribs.loadFromDir("gamemode/attributes")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Load attributes with conditional directory checking
    local attrDir = "gamemode/attributes"
    if file.Exists(attrDir, "LUA") then
        lia.attribs.loadFromDir(attrDir)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Load attributes from multiple directories with error handling
    local attributeDirs = {"gamemode/attributes", "modules/attributes", "plugins/attributes"}
    for _, dir in ipairs(attributeDirs) do
        if file.Exists(dir, "LUA") then
            lia.attribs.loadFromDir(dir)
        else
            print("Warning: Attribute directory not found: " .. dir)
        end
    end

```

---

### lia.attribs.setup

#### 📋 Purpose
Sets up attributes for a client's character by calling OnSetup hooks for each registered attribute

#### ⏰ When Called
When a client spawns or when their character is created

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The client whose character attributes need to be set up |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Setup attributes for a client
    lia.attribs.setup(client)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Setup attributes with validation
    if IsValid(client) and client:IsPlayer() then
        lia.attribs.setup(client)
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Setup attributes with custom logic and error handling
    hook.Add("PlayerSpawn", "SetupAttributes", function(client)
        if not client:getChar() then return end
        timer.Simple(0.1, function()
            if IsValid(client) then
                lia.attribs.setup(client)
                print("Attributes set up for " .. client:Name())
            end
        end)
    end)

```

---

