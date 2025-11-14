# Dialog Library

Comprehensive NPC dialog management system for the Lilia framework.

---

Overview

The dialog library provides comprehensive functionality for managing NPC conversations and dialog systems in the Lilia framework. It handles NPC registration, conversation filtering, client synchronization, and provides both server-side data management and client-side UI interactions. The library supports complex conversation trees with conditional options, server-only callbacks, and dynamic NPC customization. It includes automatic data sanitization, conversation filtering based on player permissions, and seamless integration with the framework's networking system. The library ensures secure and efficient dialog handling across both server and client realms.

---

### lia.dialog.getNPCData

#### 📋 Purpose
Retrieves stored NPC dialog data for a specific NPC ID

#### ⏰ When Called
Used internally when accessing NPC conversation data from the server-side storage

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC to retrieve data for |

#### ↩️ Returns
* (table or nil)
The NPC dialog data table if found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get NPC data for interaction
    local npcData = lia.dialog.getNPCData("foodie_dealer")
    if npcData then
        print("Found NPC: " .. npcData.PrintName)
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check if NPC has specific conversation options
    local npcData = lia.dialog.getNPCData("merchant")
    if npcData and npcData.Conversation then
        local hasTradeOption = npcData.Conversation["Trade"] ~= nil
        if hasTradeOption then
            -- Handle trade logic
        end
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Validate and process NPC conversation data
    local function validateNPCConversation(npcID)
        local npcData = lia.dialog.getNPCData(npcID)
        if not npcData then return false, "NPC not found" end
        if not npcData.Conversation then return false, "No conversation data" end
        local optionCount = 0
        for optionName, optionData in pairs(npcData.Conversation) do
            if type(optionData) == "table" and optionData.Callback then
                optionCount = optionCount + 1
            end
        end
        return optionCount > 0, "NPC has " .. optionCount .. " valid options"
    end

```

---

### lia.dialog.getOriginalNPCData

#### 📋 Purpose
Retrieves the original, unmodified NPC dialog data before any filtering or sanitization

#### ⏰ When Called
Used when opening dialogs to access the complete conversation data with all options and callbacks

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC to retrieve original data for |

#### ↩️ Returns
* (table or nil)
The original NPC dialog data table if found, nil otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get original NPC data for dialog processing
    local originalData = lia.dialog.getOriginalNPCData("shopkeeper")
    if originalData then
        -- Process complete conversation tree
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Compare filtered vs original conversation options
    local originalData = lia.dialog.getOriginalNPCData("quest_giver")
    local filteredData = lia.dialog.getNPCData("quest_giver")
    if originalData and filteredData then
        local originalCount = table.Count(originalData.Conversation or {})
        local filteredCount = table.Count(filteredData.Conversation or {})
        print("Options: " .. filteredCount .. "/" .. originalCount .. " available")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Analyze conversation structure for quest dependencies
    local function analyzeQuestConversations(npcID)
        local originalData = lia.dialog.getOriginalNPCData(npcID)
        if not originalData or not originalData.Conversation then return {} end
        local questOptions = {}
        for optionName, optionData in pairs(originalData.Conversation) do
            if type(optionData) == "table" then
                -- Check for quest-related callbacks or nested options
                if optionData.Callback and string.find(optionName, "quest") then
                    questOptions[optionName] = true
                end
                if optionData.options then
                    for subOption, subData in pairs(optionData.options) do
                        if subData.Callback and string.find(subOption, "quest") then
                            questOptions[subOption] = true
                        end
                    end
                end
            end
        end
        return questOptions
    end

```

---

### lia.dialog.syncToClients

#### 📋 Purpose
Synchronizes dialog data to clients, filtering conversations based on player permissions and sanitizing sensitive information

#### ⏰ When Called
Called during player spawn and when new NPCs are registered to ensure clients have up-to-date dialog information

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player, optional** | Specific client to sync to, or nil to sync to all clients |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Sync all dialog data to all clients
    lia.dialog.syncToClients()

```

#### 📊 Medium Complexity
```lua
    -- Medium: Sync data to a specific player after login
    hook.Add("PlayerInitialSpawn", "SyncDialogData", function(ply)
        if not ply:IsBot() then
            lia.dialog.syncToClients(ply)
        end
    end)

```

#### ⚙️ High Complexity
```lua
    -- High: Selective sync after NPC registration with performance monitoring
    local function registerAndSyncNPC(npcID, npcData)
        local startTime = SysTime()
        -- Register the NPC
        local success = lia.dialog.registerNPC(npcID, npcData)
        if not success then return false end
        -- Sync to all clients
        lia.dialog.syncToClients()
        -- Log performance and notify admins
        local syncTime = SysTime() - startTime
        print("NPC '" .. npcID .. "' registered and synced in " .. string.format("%.3f", syncTime) .. " seconds")
        -- Notify admins of new NPC availability
        for _, ply in ipairs(player.GetAll()) do
            if ply:IsAdmin() then
                ply:ChatPrint("New NPC '" .. (npcData.PrintName or npcID) .. "' is now available!")
            end
        end
        return true
    end

```

---

### lia.dialog.syncDialogs

#### 📋 Purpose
Batch sync function for synchronizing dialog data to clients without specifying individual clients

#### ⏰ When Called
Used as a convenience method when you need to sync dialog data to all clients without parameters

#### ⚙️ Parameters
None

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
-- Simple: Sync all dialog data to all clients
lia.dialog.syncDialogs()
```

#### 📊 Medium Complexity
```lua
-- Medium: Sync after registering multiple NPCs
local npcs = {"shopkeeper", "guard", "merchant"}
for _, npcID in ipairs(npcs) do
    lia.dialog.registerNPC(npcID, getNPCData(npcID))
end
lia.dialog.syncDialogs() -- Sync all at once instead of after each registration
```

---

### lia.dialog.registerNPC

#### 📋 Purpose
Registers a new NPC with conversation data in the dialog system

#### ⏰ When Called
Called during gamemode initialization or when adding new NPCs to register their conversation trees

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the NPC |
| `data` | **table** | NPC data table containing Conversation and other properties |
| `shouldSync` | **boolean** | Whether to sync dialog data to clients immediately (default: true) |

#### ↩️ Returns
* (boolean)
True if registration successful, false otherwise

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Register a basic NPC
    local success = lia.dialog.registerNPC("shopkeeper", {
        PrintName = "Shopkeeper",
        Greeting = "Welcome to my shop! How can I help you today?",
        Conversation = {
            ["Trade"] = {Callback = function(ply) openShop(ply) end},
            ["Bye"] = {Callback = function(ply) closeDialog(ply) end}
        }
    })

```

#### 📊 Medium Complexity
```lua
    -- Medium: Register NPC with conditional options
    local questNPC = {
        PrintName = "Quest Master",
        Greeting = "Greetings, adventurer! I have quests that will test your courage and skill.",
        Conversation = {
            ["Available Quests"] = {
                ShouldShow = function(ply) return ply:GetLevel() >= 5 end,
                Callback = function(ply) showQuests(ply) end,
                options = {
                    ["Accept Quest"] = {
                        Callback = function(ply) acceptQuest(ply, "main") end,
                        serverOnly = true
                    }
                }
            },
            ["Training"] = {
                Callback = function(ply) openTraining(ply) end
            }
        }
    }
    lia.dialog.registerNPC("quest_master", questNPC)

```

#### ⚙️ High Complexity
```lua
    -- High: Register faction-based NPC with complex conversation tree
    local function createFactionNPC(factionName, factionData)
        local npcConfig = {
            PrintName = factionName .. " Representative",
            Greeting = "Welcome to the " .. factionName .. " recruitment office. How may I assist you?",
            Conversation = {
                ["Greetings"] = {
                    options = {
                        ["Join " .. factionName] = {
                            ShouldShow = function(ply)
                                return not ply:GetFaction() and ply:GetLevel() >= factionData.minLevel
                            end,
                            Callback = function(ply) joinFaction(ply, factionName) end,
                            serverOnly = true
                        },
                        ["Faction Benefits"] = {
                            ShouldShow = function(ply) return ply:GetFaction() == factionName end,
                            Callback = function(ply) showBenefits(ply) end
                        },
                        ["Leave Faction"] = {
                            ShouldShow = function(ply, npc)
                                return ply:GetFaction() == factionName and npc:GetFactionRank() >= 3
                            end,
                            Callback = function(ply) leaveFaction(ply) end,
                            serverOnly = true
                        }
                    }
                },
                ["Quests"] = {
                    ShouldShow = function(ply) return ply:GetFaction() == factionName end,
                    options = factionData.quests
                },
                ["General Info"] = {
                    Callback = function(ply) showFactionInfo(ply, factionName) end
                }
            }
        }
        return lia.dialog.registerNPC(string.lower(factionName) .. "_rep", npcConfig)
    end
    -- Register multiple faction NPCs
    createFactionNPC("Warriors", {minLevel = 10, quests = warriorQuests})
    createFactionNPC("Mages", {minLevel = 8, quests = mageQuests})

```

---

### lia.dialog.getConfiguration

#### 📋 Purpose
Retrieves a registered NPC configuration module by its unique identifier

#### ⏰ When Called
Used when accessing configuration data for a specific NPC customization module

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | The unique identifier of the configuration module to retrieve |

#### ↩️ Returns
* (table or nil)
The configuration data table if found, nil otherwise

#### 🌐 Realm
Shared

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
-- Simple: Get configuration data for validation
local config = lia.dialog.getConfiguration("appearance")
if config then
    print("Configuration found: " .. (config.name or "unnamed"))
end
```

#### 📊 Medium Complexity
```lua
-- Medium: Check if a configuration is available before opening
local function isConfigurationAvailable(configID)
    local config = lia.dialog.getConfiguration(configID)
    return config and config.onOpen ~= nil
end

if isConfigurationAvailable("custom_module") then
    -- Open the configuration UI
end
```

---

### lia.dialog.openDialog

#### 📋 Purpose
Opens a dialog interface for a player with a specific NPC, filtering conversation options based on player permissions

#### ⏰ When Called
Called when a player interacts with an NPC to start a conversation

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `client` | **Player** | The player who is opening the dialog |
| `npc` | **Entity** | The NPC entity being interacted with |
| `npcID` | **string** | The unique identifier of the NPC type |

#### ↩️ Returns
* None

#### 🌐 Realm
Server

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open dialog when player presses E on NPC
    hook.Add("PlayerUse", "OpenNPCDialog", function(ply, ent)
        if ent:GetClass() == "lia_npc" and ent.uniqueID then
            lia.dialog.openDialog(ply, ent, ent.uniqueID)
            return false -- Prevent default use
        end
    end)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open dialog with distance and visibility checks
    local function tryOpenDialog(ply, npc)
        if not IsValid(npc) or npc:GetClass() ~= "lia_npc" then return false end
        if ply:GetPos():Distance(npc:GetPos()) > 150 then
            ply:ChatPrint("You're too far away!")
            return false
        end
        if not npc.uniqueID then
            ply:ChatPrint("This NPC is not configured for dialog.")
            return false
        end
        lia.dialog.openDialog(ply, npc, npc.uniqueID)
        return true
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Advanced dialog opening with faction restrictions and cooldowns
    local dialogCooldowns = {} -- Track player dialog cooldowns
    local function canOpenDialog(ply, npc, npcID)
        -- Check cooldown
        local cooldownKey = ply:SteamID() .. "_" .. npcID
        if dialogCooldowns[cooldownKey] and dialogCooldowns[cooldownKey] > CurTime() then
            ply:ChatPrint("You must wait before speaking to this NPC again.")
            return false
        end
        -- Check faction restrictions
        local npcData = lia.dialog.getOriginalNPCData(npcID)
        if npcData and npcData.factionRestriction then
            if ply:getChar():getFaction() ~= npcData.factionRestriction then
                ply:ChatPrint("This NPC won't speak to members of your faction.")
                return false
            end
        end
        -- Check quest prerequisites
        if npcData and npcData.requiredQuest then
            if not ply:HasCompletedQuest(npcData.requiredQuest) then
                ply:ChatPrint("This NPC has nothing to say to you yet.")
                return false
            end
        end
        return true
    end
    local function openDialogWithChecks(ply, npc, npcID)
        if not canOpenDialog(ply, npc, npcID) then return end
        -- Set cooldown
        local cooldownKey = ply:SteamID() .. "_" .. npcID
        dialogCooldowns[cooldownKey] = CurTime() + 30 -- 30 second cooldown
        -- Log interaction
        print(ply:Nick() .. " opened dialog with " .. npcID)
        -- Open the dialog
        lia.dialog.openDialog(ply, npc, npcID)
        -- Award achievement/progress if applicable
        ply:AddNPCInteraction(npcID)
    end

```

---

### lia.dialog.getNPCData

#### 📋 Purpose
Retrieves stored NPC dialog data for a specific NPC ID on the client side

#### ⏰ When Called
Used internally when accessing NPC conversation data from the client-side storage

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npcID` | **string** | The unique identifier of the NPC to retrieve data for |

#### ↩️ Returns
* (table or nil)
The NPC dialog data table if found, nil otherwise

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Get NPC data for UI display
    local npcData = lia.dialog.getNPCData("shopkeeper")
    if npcData then
        -- Display NPC information in UI
    end

```

#### 📊 Medium Complexity
```lua
    -- Medium: Check conversation options before opening dialog
    local npcData = lia.dialog.getNPCData("quest_giver")
    if npcData and npcData.Conversation then
        local optionCount = 0
        for optionName, optionData in pairs(npcData.Conversation) do
            if istable(optionData) then
                optionCount = optionCount + 1
            end
        end
        print("NPC has " .. optionCount .. " conversation options available")
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Build dynamic UI based on NPC conversation structure
    local function createConversationUI(npcID)
        local npcData = lia.dialog.getNPCData(npcID)
        if not npcData or not npcData.Conversation then return end
        local frame = vgui.Create("DFrame")
        frame:SetTitle(npcData.PrintName or "NPC Dialog")
        frame:SetSize(400, 500)
        frame:Center()
        frame:MakePopup()
        local scroll = vgui.Create("DScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 10, 10, 10)
        local yPos = 0
        for optionName, optionData in pairs(npcData.Conversation) do
            if istable(optionData) then
                local button = vgui.Create("DButton", scroll)
                button:SetText(optionName)
                button:SetPos(0, yPos)
                button:SetSize(380, 30)
                button.DoClick = function()
                    -- Handle conversation option selection
                    if optionData.Callback then
                        -- Note: Client-side callbacks are limited
                        -- Server communication required for most actions
                    end
                    frame:Close()
                end
                yPos = yPos + 35
                -- Add sub-options if they exist
                if optionData.options then
                    for subOption, subData in pairs(optionData.options) do
                        local subButton = vgui.Create("DButton", scroll)
                        subButton:SetText("  ? " .. subOption)
                        subButton:SetPos(20, yPos)
                        subButton:SetSize(360, 25)
                        -- Handle sub-option logic
                        yPos = yPos + 30
                    end
                end
            end
        end
        return frame
    end

```

---

### NPC Configuration Modules

The dialog library now exposes a lightweight registry that allows you to bolt your own configuration interfaces onto the properties menu for NPCs. Each configuration is defined once and automatically becomes available when accessing the properties menu on NPCs with configuration options.

**Permission Requirements**: Access to NPC configuration features requires the `canManageNPCs` permission, which is defined in the administration module and requires admin-level access by default.

**Access Method**: NPC configuration is now accessed via the properties menu (hold C or use spawn menu Properties) instead of dialog options, providing a more intuitive workflow for administrators.

#### lia.dialog.registerConfiguration

##### 📋 Purpose
Registers or augments a configuration module that can provide a client UI and a trusted server-side callback for NPC customization flows.

##### ⏰ When Called
During shared initialization (both realms) when defining new customization modules.

##### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `uniqueID` | **string** | Unique identifier for the configuration module |
| `data` | **table** | Configuration data; see supported keys below |

Supported keys in `data`:

| Key | Realm | Description |
|-----|-------|-------------|
| `name` | Server | Friendly display name shown in UI listings |
| `description` | Server | Optional helper text shown beneath the button |
| `Callback(ply, npc, payload)` | Server | Trustworthy callback invoked with the payload you sent |
| `onOpen(npc)` | Client | Build or open your UI; call `lia.dialog.submitConfiguration` when done |

The `Configuration` table within `registerNPC` defines the server-side configuration, while `registerConfiguration` with the same ID defines the client-side UI.

##### 💡 Example: Black Market configuration (Real Implementation)

Here's the actual Black Market configuration module from the MetroRP gamemode, which demonstrates the preferred `Configuration` table format within `registerNPC`:

```lua
if SERVER then
    lia.dialog.registerNPC("blackmarket", {
        PrintName = "Drug Dealer NPC",
        Conversation = {
            -- ... conversation options ...
        },
        Configuration = {
            name = "Black Market Settings",
            description = "Configure the contraband pool, prices, and cooldowns for the Black Market NPC.",
            Callback = function(ply, npc, payload)
                if not istable(payload) then return end

                -- Update timing settings
                if payload.importTime and isnumber(payload.importTime) then
                    lia.blackmarket.ImportTime = math.max(0, payload.importTime)
                end

                if payload.despawnTime and isnumber(payload.despawnTime) then
                    lia.blackmarket.DespawnTime = math.max(60, payload.despawnTime)
                end

                if payload.cooldown and isnumber(payload.cooldown) then
                    lia.blackmarket.ImportingCooldown = math.max(0, payload.cooldown)
                end

                if payload.locationChangeTime and isnumber(payload.locationChangeTime) then
                    lia.blackmarket.locationChangeTime = math.max(1, payload.locationChangeTime)
                    -- Restart the teleport timer with new interval
                    timer.Remove("blackmarket_teleport_timer")
                    timer.Create("blackmarket_teleport_timer", lia.blackmarket.locationChangeTime * 60, 0, function()
                        -- Teleport logic for Black Market NPCs
                    end)
                end

                -- Update random position setting
                if payload.randomPosition ~= nil then
                    lia.blackmarket.randomPosition = payload.randomPosition == true
                end

                ply:notifySuccess("Black Market settings saved successfully!")
            end
        }
    })
else
    lia.dialog.registerConfiguration("blackmarket", {
        onOpen = function(npc)
            local frame = vgui.Create("liaFrame")
            frame:SetTitle("Black Market Configuration")
            frame:SetSize(500, 600)
            frame:Center()
            frame:MakePopup()

            local scroll = vgui.Create("liaScrollPanel", frame)
            scroll:Dock(FILL)

            -- Import Time slider
            local importTimeSlider = vgui.Create("DNumSlider", scroll)
            importTimeSlider:Dock(TOP)
            importTimeSlider:SetText("Import Time (seconds)")
            importTimeSlider:SetMin(0)
            importTimeSlider:SetMax(3600)
            importTimeSlider:SetValue(lia.blackmarket.ImportTime or 0)

            -- Despawn Time slider
            local despawnTimeSlider = vgui.Create("DNumSlider", scroll)
            despawnTimeSlider:Dock(TOP)
            despawnTimeSlider:SetText("Package Despawn Time (seconds)")
            despawnTimeSlider:SetMin(60)
            despawnTimeSlider:SetMax(7200)
            despawnTimeSlider:SetValue(lia.blackmarket.DespawnTime or 1800)

            -- Cooldown slider
            local cooldownSlider = vgui.Create("DNumSlider", scroll)
            cooldownSlider:Dock(TOP)
            cooldownSlider:SetText("Import Cooldown (seconds)")
            cooldownSlider:SetMin(0)
            cooldownSlider:SetMax(3600)
            cooldownSlider:SetValue(lia.blackmarket.ImportingCooldown or 600)

            -- Location Change Time slider
            local locationChangeSlider = vgui.Create("DNumSlider", scroll)
            locationChangeSlider:Dock(TOP)
            locationChangeSlider:SetText("NPC Location Change (minutes)")
            locationChangeSlider:SetMin(1)
            locationChangeSlider:SetMax(120)
            locationChangeSlider:SetValue(lia.blackmarket.locationChangeTime or 5)

            -- Random Position checkbox
            local randomPosCheckbox = vgui.Create("DCheckBoxLabel", scroll)
            randomPosCheckbox:Dock(TOP)
            randomPosCheckbox:SetText("Use random drop locations (instead of player position)")
            randomPosCheckbox:SetValue(lia.blackmarket.randomPosition == true)

            -- Save Button
            local saveBtn = vgui.Create("liaButton", scroll)
            saveBtn:Dock(TOP)
            saveBtn:SetText("Save Settings")
            saveBtn.DoClick = function()
                lia.dialog.submitConfiguration("blackmarket", npc, {
                    importTime = importTimeSlider:GetValue(),
                    despawnTime = despawnTimeSlider:GetValue(),
                    cooldown = cooldownSlider:GetValue(),
                    locationChangeTime = locationChangeSlider:GetValue(),
                    randomPosition = randomPosCheckbox:GetChecked()
                })
                frame:Close()
            end
        end
    })
end
```

This example shows how to create a full-featured configuration UI using the `Configuration` table format within `registerNPC` for server-side handling, paired with `registerConfiguration` for client-side UI. Access to NPC configuration requires the `canManageNPCs` permission defined in the administration module.

#### Built-in Configuration Modules

The dialog library includes a built-in "appearance" configuration module that provides comprehensive NPC customization capabilities.

##### Appearance Configuration (`"appearance"`)

The appearance configuration allows privileged users to customize various visual aspects of NPCs through the properties menu.

**Features:**
- **NPC Name**: Change the display name of the NPC
- **Model**: Change the 3D model used by the NPC
- **Skin**: Select different skin variants (if available)
- **Bodygroups**: Customize individual body parts/groups
- **Animations**: Set idle animations and preview them

**Permission Requirements**: Requires `canManageProperties` permission for access.

**Access Method**: Available through the properties menu (hold C or use spawn menu Properties) on any NPC entity.

**Example Usage:**
```lua
-- The appearance configuration is automatically available for all NPCs
-- Access it via the properties menu when you have canManageProperties permission

-- You can also open it programmatically:
lia.dialog.openCustomizationUI(npc, "appearance")
```

**Technical Details:**
- Server-side handler: `lia.dialog.registerConfiguration("appearance", {onApply = function(ply, npc, customData)...})`
- Client-side UI: `lia.dialog.registerConfiguration("appearance", {onOpen = function(npc) lia.dialog.openCustomizationUI(npc, "appearance") end})`
- Data is persisted via `hook.Run("UpdateEntityPersistence", npc)` and saved to disk

### lia.dialog.openConfigurationPicker

#### 📋 Purpose
Opens a configuration picker interface that displays all available NPC customization modules for privileged users

#### ⏰ When Called
Automatically invoked when accessing the properties menu on NPCs with configuration options, or can be called manually

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **Entity** | The NPC entity to configure |
| `npcID` | **string, optional** | The unique identifier of the NPC type (defaults to npc.uniqueID) |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
-- Simple: Open configuration picker for an NPC
local npc = ents.Create("lia_npc")
npc:Spawn()
lia.dialog.openConfigurationPicker(npc)
```

#### 📊 Medium Complexity
```lua
-- Medium: Open picker with custom NPC ID
local npc = ents.GetByIndex(123)
if IsValid(npc) then
    lia.dialog.openConfigurationPicker(npc, "custom_guard")
end
```

#### ⚙️ High Complexity
```lua
-- High: Advanced picker with validation and logging
local function openValidatedConfigPicker(npc, npcID)
    if not IsValid(npc) then
        LocalPlayer():notifyError("Invalid NPC entity")
        return false
    end

    if not LocalPlayer():hasPrivilege("canManageNPCs") then
        LocalPlayer():notifyError("You don't have permission to configure NPCs")
        return false
    end

    -- Check if any configurations are available
    local availableConfigs = lia.dialog.getAvailableConfigurations(LocalPlayer(), npc, npcID)
    if #availableConfigs == 0 then
        LocalPlayer():notifyError("No configuration options available for this NPC")
        return false
    end

    -- Log the configuration attempt
    print(string.format("Player %s opening config picker for NPC: %s",
        LocalPlayer():Nick(), npcID or npc.uniqueID or "unknown"))

    -- Open the picker
    lia.dialog.openConfigurationPicker(npc, npcID)
    return true
end
```

### lia.dialog.submitConfiguration

#### 📋 Purpose
Helper function that serializes payload data and dispatches it to the server-side handler for the specified configuration module

#### ⏰ When Called
Called from client-side configuration UIs when players submit their customization data

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `configID` | **string** | The unique identifier of the configuration module |
| `npc` | **Entity** | The NPC entity being configured |
| `payload` | **table** | The data payload to send to the server-side handler |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
-- Simple: Submit basic configuration data
lia.dialog.submitConfiguration("appearance", npc, {
    name = "Guard Captain",
    model = "models/player/police.mdl"
})
```

#### 📊 Medium Complexity
```lua
-- Medium: Submit configuration with validation
local function submitVendorConfig(npc, configData)
    if not configData.items or #configData.items == 0 then
        LocalPlayer():notifyError("Must select at least one item")
        return
    end

    lia.dialog.submitConfiguration("vendor_setup", npc, configData)
end
```

#### ⚙️ High Complexity
```lua
-- High: Submit complex configuration with error handling and logging
local function submitAdvancedConfig(npc, configID, payload)
    -- Validate payload structure
    if not istable(payload) then
        LocalPlayer():notifyError("Invalid configuration data")
        return false
    end

    -- Log the configuration attempt
    print(string.format("Player %s submitting %s config for NPC %s",
        LocalPlayer():Nick(), configID, npc:GetClass()))

    -- Add metadata
    payload.timestamp = os.time()
    payload.playerID = LocalPlayer():SteamID()

    -- Submit the configuration
    lia.dialog.submitConfiguration(configID, npc, payload)

    -- Show success feedback
    LocalPlayer():notifySuccess("Configuration submitted successfully!")
    return true
end
```

---

### lia.dialog.openCustomizationUI

#### 📋 Purpose
Opens a comprehensive NPC customization interface allowing players with management privileges to modify NPC appearance, name, and animations. The menu now submits through the `appearance` configuration module so it can live alongside any additional custom registries you create.

#### ⏰ When Called
Called when privileged players select the "Customize this NPC" option from an NPC dialog menu

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **Entity** | The NPC entity to customize |
| `configID` | **string** _(optional)_ | Defaults to `"appearance"`; override if re-using the UI for another configuration module |

#### ↩️ Returns
* None

#### 🌐 Realm
Client

#### 💡 Example Usage

#### 🔰 Low Complexity
```lua
    -- Simple: Open customization for an NPC
    local npc = ents.Create("lia_npc")
    npc:Spawn()
    lia.dialog.openCustomizationUI(npc)

```

#### 📊 Medium Complexity
```lua
    -- Medium: Open customization with validation
    local function tryCustomizeNPC(npc)
        if not IsValid(npc) then
            LocalPlayer():notifyError("Invalid NPC entity")
            return false
        end
        if not LocalPlayer():hasPrivilege("canManageProperties") then
            LocalPlayer():notifyError("You don't have permission to customize NPCs")
            return false
        end
        lia.dialog.openCustomizationUI(npc)
        return true
    end

```

#### ⚙️ High Complexity
```lua
    -- High: Advanced NPC customization with logging and rollback
    local customizationHistory = {} -- Track changes for potential rollback
    local function customizeNPCWithHistory(npc)
        if not IsValid(npc) then return false end
        -- Store original state
        local originalState = {
            name = npc:getNetVar("NPCName", npc.NPCName),
            model = npc:GetModel(),
            skin = npc:GetSkin(),
            bodygroups = {},
            animation = npc.customData and npc.customData.animation
        }
        for i = 0, npc:GetNumBodyGroups() - 1 do
            originalState.bodygroups[i] = npc:GetBodygroup(i)
        end
        customizationHistory[npc:EntIndex()] = originalState
        -- Log customization attempt
        print(LocalPlayer():Nick() .. " opened customization for NPC: " .. (originalState.name or "Unknown"))
        -- Override the apply function to add logging
        local originalApply = lia.dialog.openCustomizationUI
        lia.dialog.openCustomizationUI = function(targetNPC)
            originalApply(targetNPC)
            -- Find the apply button and add logging
            timer.Simple(0.1, function()
                if not IsValid(targetNPC) then return end
                local frame = vgui.GetHoveredPanel()
                if IsValid(frame) and frame:GetTitle() == "Customize NPC" then
                    -- This is a simplified example - actual implementation would need
                    -- to hook into the apply button's DoClick event
                    print("NPC customization applied by " .. LocalPlayer():Nick())
                end
            end)
        end
        lia.dialog.openCustomizationUI(npc)
        return true
    end

```

---

