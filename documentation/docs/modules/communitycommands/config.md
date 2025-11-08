# Configuration

Configuration options for the Community Commands module.

---

Overview

The Community Commands module provides configurable URL links that can be accessed through commands, allowing players to quickly access external resources like rules, Discord, Steam content, and community groups.

---

### URLs

#### 📋 Description
Defines URL links accessible through community commands. Each URL entry specifies the link name, URL address, and whether it should open in-game or externally.

#### ⚙️ Type
Table

#### 💾 Default Value
```lua
{
    ["Rules"] = {
        URL = "https://example.com/rules",
        shouldOpenIngame = true
    },
    ["Discord"] = {
        URL = "https://discord.gg/2QyjggCUx4",
        shouldOpenIngame = false
    },
    ["Content"] = {
        URL = "https://steamcommunity.com/sharedfiles/managecollection/?id=3367324267",
        shouldOpenIngame = false
    },
    ["SteamGroup"] = {
        URL = "https://steamcommunity.com/groups/partumverse",
        shouldOpenIngame = false
    }
}
```

#### 📊 Structure
A table mapping link names (keys) to URL configuration tables (values). Each URL configuration contains:
- `URL` (string) - The web address to open
- `shouldOpenIngame` (boolean) - Whether to open the URL in the in-game browser (true) or external browser (false)

#### 🌐 Realm
Server

