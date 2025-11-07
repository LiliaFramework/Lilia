# Player Interaction Library

Player-to-player and entity interaction management system for the Lilia framework.

---

Overview

The player interaction library provides comprehensive functionality for managing player interactions and actions within the Lilia framework. It handles the creation, registration, and execution of various interaction types including player-to-player interactions, entity interactions, and personal actions. The library operates on both server and client sides, with the server managing interaction registration and validation, while the client handles UI display and user input. It includes range checking, timed actions, and network synchronization to ensure consistent interaction behavior across all clients. The library supports both immediate and delayed actions with progress indicators, making it suitable for complex interaction systems like money transfers, voice changes, and other gameplay mechanics.

---

### lia.playerinteract.isWithinRange

#### 📋 Purpose
Checks if a client is within interaction range of an entity

#### ⏰ When Called
Called when determining if an interaction should be available to a player

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player attempting the interaction |
| `entity` | **Entity** | The target entity to check distance against |
| `customRange` | **number, optional** | Custom range override (defaults to 250 units) |

#### ↩️ Returns
* boolean - true if within range, false otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Check if player is within default range of an entity
    if lia.playerinteract.isWithinRange(client, targetEntity) then
        -- Player is within 250 units
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check with custom range for specific interaction
    local customRange = 100
    if lia.playerinteract.isWithinRange(client, targetEntity, customRange) then
        -- Player is within 100 units for close-range interaction
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Dynamic range checking with validation
    local interactionRange = interactionData.range or 250
    if IsValid(client) and IsValid(targetEntity) and
        lia.playerinteract.isWithinRange(client, targetEntity, interactionRange) then
        -- Player is within specified range for this interaction type
        return true
    end

```

---

### lia.playerinteract.getInteractions

#### 📋 Purpose
Retrieves all available interactions for a client based on their traced entity

#### ⏰ When Called
Called when opening interaction menu or checking available interactions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | The player to get interactions for (defaults to LocalPlayer()) |

#### ↩️ Returns
* table - Dictionary of available interactions indexed by interaction name

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all available interactions for local player
    local interactions = lia.playerinteract.getInteractions()
    for name, interaction in pairs(interactions) do
        print("Available interaction:", name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get interactions for specific player with validation
    local client = LocalPlayer()
    if IsValid(client) then
        local interactions = lia.playerinteract.getInteractions(client)
        local interactionCount = table.Count(interactions)
        if interactionCount > 0 then
            -- Player has interactions available
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Filter interactions by category and validate conditions
    local interactions = lia.playerinteract.getInteractions()
    local filteredInteractions = {}
    for name, interaction in pairs(interactions) do
        if interaction.category == "Voice" and
            (not interaction.shouldShow or interaction.shouldShow(LocalPlayer())) then
            filteredInteractions[name] = interaction
        end
    end

```

---

### lia.playerinteract.getActions

#### 📋 Purpose
Retrieves all available personal actions for a client

#### ⏰ When Called
Called when opening personal actions menu or checking available actions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | The player to get actions for (defaults to LocalPlayer()) |

#### ↩️ Returns
* table - Dictionary of available actions indexed by action name

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get all available personal actions
    local actions = lia.playerinteract.getActions()
    for name, action in pairs(actions) do
        print("Available action:", name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Get actions with character validation
    local client = LocalPlayer()
    if IsValid(client) and client:getChar() then
        local actions = lia.playerinteract.getActions(client)
        local actionCount = table.Count(actions)
        if actionCount > 0 then
            -- Player has actions available
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Filter actions by category and execute specific ones
    local actions = lia.playerinteract.getActions()
    local voiceActions = {}
    for name, action in pairs(actions) do
        if action.category == L("categoryVoice") and
            (not action.shouldShow or action.shouldShow(LocalPlayer())) then
            voiceActions[name] = action
        end
    end

```

---

### lia.playerinteract.getCategorizedOptions

#### 📋 Purpose
Prepares interaction/action options for UI display in a flat list

#### ⏰ When Called
Called when preparing options for display in the interaction menu

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | **table** | Dictionary of options to prepare |

#### ↩️ Returns
* table - Array of options for flat display

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get options for display
    local interactions = lia.playerinteract.getInteractions()
    local optionsList = lia.playerinteract.getCategorizedOptions(interactions)
    for _, option in pairs(optionsList) do
        print("Option:", option.name)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Process options for custom display
    local actions = lia.playerinteract.getActions()
    local optionsList = lia.playerinteract.getCategorizedOptions(actions)
    local count = #optionsList
    if count > 0 then
        -- Options are ready for display
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Filter and process options
    local interactions = lia.playerinteract.getInteractions()
    local optionsList = lia.playerinteract.getCategorizedOptions(interactions)
    local filteredOptions = {}
    for _, option in pairs(optionsList) do
        if option.opt.category == "Voice" then
            table.insert(filteredOptions, option)
        end
    end

```

---

### lia.playerinteract.addInteraction

#### 📋 Purpose
Registers a new player-to-player or player-to-entity interaction

#### ⏰ When Called
Called during module initialization or when registering custom interactions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Unique identifier for the interaction |
| `data` | **table** | Interaction configuration table containing: |
| `serverOnly` | **boolean, optional** | Whether interaction runs server-side only |
| `shouldShow` | **function, optional** | Function to determine if interaction should be visible |
| `onRun` | **function** | Function to execute when interaction is triggered |
| `range` | **number, optional** | Interaction range in units (defaults to 250) |
| `category` | **string, optional** | Category for UI organization |
| `target` | **string, optional** | Target type - "player", "entity", or "any" (defaults to "player") |
| `timeToComplete` | **number, optional** | Time in seconds for timed interactions |
| `actionText` | **string, optional** | Text shown to performing player during timed action |
| `targetActionText` | **string, optional** | Text shown to target player during timed action |
| `categoryColor` | **Color, optional** | Color for category display |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic player interaction
    lia.playerinteract.addInteraction("giveMoney", {
        shouldShow = function(client, target)
            return IsValid(target) and target:IsPlayer() and client:getChar():getMoney() > 0
        end,
        onRun = function(client, target)
            -- Give money logic here
        end
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add timed interaction with progress indicators
    lia.playerinteract.addInteraction("healPlayer", {
        category = "Medical",
        range = 100,
        timeToComplete = 5,
        actionText = "Healing player...",
        targetActionText = "Being healed...",
        shouldShow = function(client, target)
            return IsValid(target) and target:IsPlayer() and target:Health() < target:GetMaxHealth()
        end,
        onRun = function(client, target)
            target:SetHealth(target:GetMaxHealth())
            client:notify("Player healed successfully!")
        end
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Complex interaction with validation and server-side processing
    lia.playerinteract.addInteraction("arrestPlayer", {
        serverOnly = true,
        category = "Law Enforcement",
        range = 150,
        timeToComplete = 3,
        actionText = "Arresting suspect...",
        targetActionText = "Being arrested...",
        shouldShow = function(client, target)
            if not IsValid(target) or not target:IsPlayer() then return false end
            if not client:getChar() or not target:getChar() then return false end
            return client:getChar():getFaction() == FACTION_POLICE and
                target:getChar():getFaction() ~= FACTION_POLICE
        end,
        onRun = function(client, target)
            -- Complex arrest logic with validation
            if lia.config.get("DisableCheaterActions", true) and client:getNetVar("cheater", false) then
                lia.log.add(client, "cheaterAction", "Attempted arrest while flagged as cheater")
                client:notifyWarningLocalized("maybeYouShouldntHaveCheated")
                return
            end
            target:getChar():setData("arrested", true)
            target:StripWeapons()
            client:notify("Suspect arrested!")
            target:notify("You have been arrested!")
        end
    })

```

---

### lia.playerinteract.addAction

#### 📋 Purpose
Registers a new personal action that doesn't require a target entity

#### ⏰ When Called
Called during module initialization or when registering custom personal actions

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `name` | **string** | Unique identifier for the action |
| `data` | **table** | Action configuration table containing: |
| `serverOnly` | **boolean, optional** | Whether action runs server-side only |
| `shouldShow` | **function, optional** | Function to determine if action should be visible |
| `onRun` | **function** | Function to execute when action is triggered |
| `range` | **number, optional** | Action range in units (defaults to 250) |
| `category` | **string, optional** | Category for UI organization |
| `timeToComplete` | **number, optional** | Time in seconds for timed actions |
| `actionText` | **string, optional** | Text shown to performing player during timed action |
| `targetActionText` | **string, optional** | Text shown to target player during timed action |
| `categoryColor` | **Color, optional** | Color for category display |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Add basic personal action
    lia.playerinteract.addAction("changeToWhisper", {
        category = L("categoryVoice"),
        shouldShow = function(client)
            return client:getChar() and client:Alive() and
                client:getNetVar("VoiceType") ~= L("whispering")
        end,
        onRun = function(client)
            client:setNetVar("VoiceType", L("whispering"))
            client:notifyInfoLocalized("voiceModeSet", L("whispering"))
        end
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Add timed personal action with progress indicator
    lia.playerinteract.addAction("meditate", {
        category = "Personal",
        timeToComplete = 10,
        actionText = "Meditating...",
        shouldShow = function(client)
            return client:getChar() and client:Alive() and
                not client:getNetVar("meditating", false)
        end,
        onRun = function(client)
            client:setNetVar("meditating", true)
            client:SetHealth(math.min(client:Health() + 25, client:GetMaxHealth()))
            client:notify("Meditation complete! Health restored.")
            timer.Simple(1, function()
                if IsValid(client) then
                    client:setNetVar("meditating", false)
                end
            end)
        end
    })

```

#### ⚙️ High Complexity
```lua
    -- High: Complex personal action with multiple conditions and effects
    lia.playerinteract.addAction("emergencyCall", {
        serverOnly = true,
        category = "Emergency",
        timeToComplete = 5,
        actionText = "Calling emergency services...",
        shouldShow = function(client)
            if not client:getChar() or not client:Alive() then return false end
            local char = client:getChar()
            if char:getFaction() == FACTION_POLICE or char:getFaction() == FACTION_MEDIC then
                return false -- Emergency services don't need to call themselves
            end
            return not client:getNetVar("emergencyCooldown", false)
        end,
        onRun = function(client)
            -- Set cooldown to prevent spam
            client:setNetVar("emergencyCooldown", true)
            timer.Simple(300, function() -- 5 minute cooldown
                if IsValid(client) then
                    client:setNetVar("emergencyCooldown", false)
                end
            end)
            -- Notify emergency services
            local emergencyMsg = string.format(
                "Emergency call from %s at %s",
                client:getChar():getDisplayedName(),
                client:GetPos()
            )
            for _, ply in player.Iterator() do
                if ply:getChar() and ply:getChar():getFaction() == FACTION_POLICE then
                    ply:notify(emergencyMsg)
                end
            end
            client:notify("Emergency services have been notified!")
        end
    })

```

---

### lia.playerinteract.sync

#### 📋 Purpose
Synchronizes interaction and action data from server to clients

#### ⏰ When Called
Called when interactions/actions are added or when clients connect

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | Specific client to sync to (if nil, syncs to all players) |

#### ↩️ Returns
* void

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Sync all interactions to all clients
    lia.playerinteract.sync ()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Sync to specific client after they connect
    hook.Add("PlayerInitialSpawn", "SyncInteractions", function(client)
        timer.Simple(2, function() -- Wait for client to fully load
            if IsValid(client) then
                lia.playerinteract.sync (client)
            end
        end)
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Conditional sync with validation and error handling
    function syncInteractionsToClient(client)
        if not IsValid(client) then return end
        -- Check if client is ready
        if not client:IsConnected() or not client:getChar() then
            timer.Simple(1, function()
                syncInteractionsToClient(client)
            end)
            return
        end
        -- Sync with custom filtering
        local filteredData = {}
        for name, data in pairs(lia.playerinteract.stored) do
            -- Only sync non-admin interactions to regular players
            if not data.adminOnly or client:IsAdmin() then
                filteredData[name] = {
                    type = data.type,
                    serverOnly = data.serverOnly and true or false,
                    name = name,
                    range = data.range,
                    category = data.category or L("categoryUnsorted"),
                    target = data.target,
                    timeToComplete = data.timeToComplete,
                    actionText = data.actionText,
                    targetActionText = data.targetActionText
                }
            end
        end
        lia.net.writeBigTable(client, "liaPlayerInteractSync", filteredData)
        lia.net.writeBigTable(client, "liaPlayerInteractCategories", lia.playerinteract.categories)
    end

```

---

### lia.playerinteract.hasChanges

#### 📋 Purpose
Checks if player interaction data has changed since the last sync operation

#### ⏰ When Called
Called during hot reload to determine if interaction data needs to be re-synced

#### ↩️ Returns
* boolean
true if interactions or categories have changed since last sync, false otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

```lua
    -- Check if interaction data needs syncing
    if lia.playerinteract.hasChanges() then
        lia.playerinteract.sync()
    end

```

---

### lia.playerinteract.openMenu

#### 📋 Purpose
Opens the interaction/action menu UI by delegating to lia.derma.optionsMenu

#### ⏰ When Called
Called when player presses interaction keybind or requests menu

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `options` | **table** | Dictionary of available options to display |
| `isInteraction` | **boolean** | Whether this is an interaction menu (true) or action menu (false) |
| `titleText` | **string** | Title text to display at top of menu |
| `closeKey` | **number** | Key code that closes the menu when released |
| `netMsg` | **string** | Network message name for server-only interactions |
| `preFiltered` | **boolean, optional** | Whether options are already filtered (defaults to false) |

#### ↩️ Returns
* Panel - The created menu frame (returns from lia.derma.optionsMenu)

#### 🌐 Realm
Client
Note: This function is now a thin wrapper around lia.derma.optionsMenu for backwards compatibility.

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open basic interaction menu
    local interactions = lia.playerinteract.getInteractions()
    lia.playerinteract.openMenu(interactions, true, "Interactions", KEY_TAB, "liaRequestInteractOptions")

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open action menu with custom title and key
    local actions = lia.playerinteract.getActions()
    lia.playerinteract.openMenu(actions, false, "Personal Actions", KEY_G, "liaRequestInteractOptions")

```

#### ⚙️ High Complexity
```lua
    -- High: Custom menu with pre-filtered options and validation
    local client = LocalPlayer()
    if not IsValid(client) then return end
    local interactions = lia.playerinteract.getInteractions(client)
    local filteredInteractions = {}
    -- Filter interactions based on custom criteria
    for name, interaction in pairs(interactions) do
        if interaction.category == "Voice" and
            (not interaction.shouldShow or interaction.shouldShow(client)) then
            filteredInteractions[name] = interaction
        end
    end
    if table.Count(filteredInteractions) > 0 then
        lia.playerinteract.openMenu(
            filteredInteractions,
            true,
            "Voice Interactions",
            KEY_TAB,
            "liaRequestInteractOptions",
            true -- preFiltered
        )
    else
        client:notify("No voice interactions available!")
    end

```

---

