# Player Interaction Library

Player-to-player and entity interaction management system for the Lilia framework.

---

Overview

The player interaction library provides comprehensive functionality for managing player interactions and actions within the Lilia framework. It handles the creation, registration, and execution of various interaction types including player-to-player interactions, entity interactions, and personal actions. The library operates on both server and client sides, with the server managing interaction registration and validation, while the client handles UI display and user input. It includes range checking, timed actions, and network synchronization to ensure consistent interaction behavior across all clients. The library supports both immediate and delayed actions with progress indicators, making it suitable for complex interaction systems like money transfers, voice changes, and other gameplay mechanics.

---

### lia.playerinteract.isWithinRange

#### 📋 Purpose
Check if a client is within a usable range of an entity.

#### ⏰ When Called
Before running interaction logic or building interaction menus.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting the interaction. |
| `entity` | **Entity** | Target entity to test. |
| `customRange` | **number|nil** | Optional override distance in Hammer units (default 100). |

#### ↩️ Returns
* boolean
true if both are valid and distance is within range.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Validate a timed hack action before starting the progress bar.
    local function tryHackDoor(client, door)
        if not lia.playerinteract.isWithinRange(client, door, 96) then
            client:notifyLocalized("tooFar")
            return
        end
        client:setAction("@hackingDoor", 5, function()
            if IsValid(door) then door:Fire("Unlock") end
        end)
    end

```

---

### lia.playerinteract.getInteractions

#### 📋 Purpose
Collect interaction options for the entity the player is aiming at.

#### ⏰ When Called
When opening the interaction menu (TAB keybind) to populate entries.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Player to use for trace; defaults to LocalPlayer on client. |

#### ↩️ Returns
* table
Map of interaction name → data filtered for the target.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Server: send only valid interactions for the traced entity.
    net.Receive("liaRequestInteractOptions", function(_, ply)
        local interactions = lia.playerinteract.getInteractions(ply)
        local categorized = lia.playerinteract.getCategorizedOptions(interactions)
        lia.net.writeBigTable(ply, "liaInteractionOptions", categorized)
    end)

```

---

### lia.playerinteract.getActions

#### 📋 Purpose
Gather personal actions that do not require a target entity.

#### ⏰ When Called
When opening the personal actions menu (G keybind).

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Player to evaluate; defaults to LocalPlayer on client. |

#### ↩️ Returns
* table
Map of action name → data available for this player.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Filter actions for a character sheet panel.
    local actions = lia.playerinteract.getActions(ply)
    for name, data in pairs(actions) do
        if name:find("changeTo") then
            -- add a voice toggle button
        end
    end

```

---

### lia.playerinteract.getCategorizedOptions

#### 📋 Purpose
Transform option map into a categorized, ordered list for UI display.

#### ⏰ When Called
Before rendering interaction/action menus that use category headers.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | **table** | Map of name → option entry (expects `opt.category`). |

#### ↩️ Returns
* table
Array containing category rows followed by option entries.

#### 🌐 Realm
Shared

#### 💡 Example Usage

```lua
    -- Build an options array with headers for a custom menu.
    local options = lia.playerinteract.getCategorizedOptions(interactions)
    local panel = vgui.Create("liaOptionsPanel")
    panel:Populate(options)

```

---

### lia.playerinteract.addInteraction

#### 📋 Purpose
Register a targeted interaction and ensure timed actions wrap onRun.

#### ⏰ When Called
Server startup or dynamically when new context interactions are added.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Unique interaction key. |
| `data` | **table** | Fields: `onRun`, `shouldShow`, `range`, `target`, `category`, |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.playerinteract.addInteraction("zipTie", {
        target = "player",
        range = 96,
        category = "categoryRestraint",
        timeToComplete = 4,
        actionText = "@tying",
        targetActionText = "@beingTied",
        shouldShow = function(client, target)
            return target:IsPlayer() and not target:getNetVar("ziptied")
        end,
        onRun = function(client, target)
            target:setNetVar("ziptied", true)
        end
    })

```

---

### lia.playerinteract.addAction

#### 📋 Purpose
Register a self-action (no target) and auto-wrap timed executions.

#### ⏰ When Called
Server startup or dynamically to add personal actions/emotes.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Unique action key. |
| `data` | **table** | Fields similar to interactions but no target differentiation. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    lia.playerinteract.addAction("wave", {
        category = "categoryEmotes",
        timeToComplete = 1,
        actionText = "@gesturing",
        onRun = function(client)
            client:DoAnimation(ACT_GMOD_GESTURE_WAVE)
        end
    })

```

---

### lia.playerinteract.sync

#### 📋 Purpose
Push registered interactions/actions and categories to clients.

#### ⏰ When Called
After definitions change or when a player joins to keep menus current.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player|nil** | Send to one player if provided; otherwise broadcast in batches. |

#### ↩️ Returns
* nil

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.playerinteract.hasChanges() then
        lia.playerinteract.sync() -- broadcast updates
    end

```

---

### lia.playerinteract.hasChanges

#### 📋 Purpose
Determine if interaction/action definitions changed since last sync.

#### ⏰ When Called
Prior to syncing to avoid unnecessary network traffic.

#### ↩️ Returns
* boolean
true when counts differ from the last broadcast.

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    if lia.playerinteract.hasChanges() then
        lia.playerinteract.sync()
    end

```

---

### lia.playerinteract.openMenu

#### 📋 Purpose
Open the interaction or personal action menu on the client.

#### ⏰ When Called
After receiving options from the server or when keybind handlers fire.

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | **table** | Array of option entries plus category rows. |
| `isInteraction` | **boolean** | true for interaction mode; false for personal actions. |
| `titleText` | **string|nil** | Optional menu title override. |
| `closeKey` | **number|nil** | Optional key code to close the menu. |
| `netMsg` | **string|nil** | Net message name to send selections with. |
| `preFiltered` | **boolean|nil** | If true, options are already filtered for target/range visibility. |

#### ↩️ Returns
* Panel|nil
The created menu panel.

#### 🌐 Realm
Client

#### 💡 Example Usage

```lua
    net.Receive("liaSendInteractOptions", function()
        local data = lia.net.readBigTable()
        local categorized = lia.playerinteract.getCategorizedOptions(data)
        lia.playerinteract.openMenu(categorized, true, L("interactionMenu"))
    end)

```

---

