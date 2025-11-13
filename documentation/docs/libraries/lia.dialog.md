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

### lia.dialog.openCustomizationUI

#### 📋 Purpose
Opens a comprehensive NPC customization interface allowing players with management privileges to modify NPC appearance, name, and animations

#### ⏰ When Called
Called when privileged players select the "Customize this NPC" option from an NPC dialog menu

#### ⚙️ Parameters

| Parameter | Type | Description |
|-----------|------|-------------|
| `npc` | **Entity** | The NPC entity to customize |

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

