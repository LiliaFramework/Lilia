--[[
    Dialog Library

    Comprehensive NPC dialog management system for the Lilia framework.
]]
--[[
    Overview:
        The dialog library provides comprehensive functionality for managing NPC conversations and dialog systems in the Lilia framework. It handles NPC registration, conversation filtering, client synchronization, and provides both server-side data management and client-side UI interactions. The library supports complex conversation trees with conditional options, server-only callbacks, and dynamic NPC customization. It includes automatic data sanitization, conversation filtering based on player permissions, and seamless integration with the framework's networking system. The library ensures secure and efficient dialog handling across both server and client realms.
]]
lia.dialog = lia.dialog or {}
lia.dialog.stored = lia.dialog.stored or {}
lia.dialog.configurations = lia.dialog.configurations or {}
lia.dialog.clientHashes = lia.dialog.clientHashes or {}
--[[
    Purpose:
        Deeply compares two tables for equality. Used internally for dialog state management.

    Parameters:
        tbl1 (table) - The first table to compare.
        tbl2 (table) - The second table to compare.
        checked (table, optional) - Internal table to track seen tables and prevent infinite recursion.

    Returns:
        (boolean) - True if both tables (and all their contents) are equal, false otherwise.
]]
function lia.dialog.isTableEqual(tbl1, tbl2, checked)
    if tbl1 == tbl2 then return true end
    if not istable(tbl1) or not istable(tbl2) then return false end
    checked = checked or {}
    if checked[tbl1] or checked[tbl2] then return true end
    checked[tbl1] = true
    checked[tbl2] = true
    local keys1, keys2 = {}, {}
    for k in pairs(tbl1) do
        table.insert(keys1, k)
    end

    for k in pairs(tbl2) do
        table.insert(keys2, k)
    end

    if #keys1 ~= #keys2 then return false end
    table.sort(keys1)
    table.sort(keys2)
    for i = 1, #keys1 do
        if keys1[i] ~= keys2[i] then return false end
        local val1, val2 = tbl1[keys1[i]], tbl2[keys1[i]]
        if type(val1) ~= type(val2) then return false end
        if istable(val1) then
            if not lia.dialog.isTableEqual(val1, val2, checked) then return false end
        elseif val1 ~= val2 then
            return false
        end
    end
    return true
end

--[[
    Purpose:
        Registers or augments a dialog configuration module that can be exposed from the
        "Customize this NPC" entry.

    Parameters:
        uniqueID (string)
            Unique identifier for the configuration module.
        data (table)
            Table containing any combination of the following keys:
                - name (string): Friendly display name used in UI listings.
                - description (string): Optional helper text shown beneath the button.
                - order (number): Sort weight (lower values appear first).
                - shouldShow (function): Predicate run on both client/server
                  (signature: fun(ply, npc, npcID):boolean).
                - onOpen (function, client): Callback used to build/open the UI.
                  (signature: fun(npc:Entity, npcID:string|nil)).
                - onApply (function, server): Callback executed when players submit
                  data from the UI. (signature: fun(ply, npc, payloadTable)).
]]
function lia.dialog.registerConfiguration(uniqueID, data)
    if not isstring(uniqueID) then return end
    if not istable(data) then data = {} end
    local config = lia.dialog.configurations[uniqueID]
    if not config then
        config = {
            id = uniqueID
        }

        lia.dialog.configurations[uniqueID] = config
    end

    for key, value in pairs(data) do
        if key ~= "id" and value ~= nil then config[key] = value end
    end

    config.name = config.name or uniqueID
    config.order = config.order or 0
    return config
end

--[[
    Purpose:
        Retrieves a registered NPC configuration module by its unique identifier

    Parameters:
        uniqueID (string)
            The unique identifier of the configuration module to retrieve

    Returns:
        (table or nil)
            The configuration data table if found, nil otherwise
]]
function lia.dialog.getConfiguration(uniqueID)
    return lia.dialog.configurations[uniqueID]
end

if SERVER then
    --[[
    Purpose:
        Retrieves stored NPC dialog data for a specific NPC ID

    When Called:
        Used internally when accessing NPC conversation data from the server-side storage

    Parameters:
        npcID (string)
            The unique identifier of the NPC to retrieve data for

    Returns:
        (table or nil)
            The NPC dialog data table if found, nil otherwise

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get NPC data for interaction
        local npcData = lia.dialog.getNPCData("foodie_dealer")
        if npcData then
            print("Found NPC: " .. npcData.PrintName)
        end
        ```

    Medium Complexity:
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

    High Complexity:
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
    ]]
    function lia.dialog.getNPCData(npcID)
        if lia.dialog.stored[npcID] then return lia.dialog.stored[npcID] end
        return nil
    end

    --[[
    Purpose:
        Retrieves the original, unmodified NPC dialog data before any filtering or sanitization

    When Called:
        Used when opening dialogs to access the complete conversation data with all options and callbacks

    Parameters:
        npcID (string)
            The unique identifier of the NPC to retrieve original data for

    Returns:
        (table or nil)
            The original NPC dialog data table if found, nil otherwise

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get original NPC data for dialog processing
        local originalData = lia.dialog.getOriginalNPCData("shopkeeper")
        if originalData then
            -- Process complete conversation tree
        end
        ```

    Medium Complexity:
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

    High Complexity:
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
    ]]
    function lia.dialog.getOriginalNPCData(npcID)
        if lia.dialog.originalData and lia.dialog.originalData[npcID] then return lia.dialog.originalData[npcID] end
        return nil
    end

    local function deepCopy(value)
        if istable(value) then
            local copy = {}
            for k, v in pairs(value) do
                copy[k] = deepCopy(v)
            end
            return copy
        elseif isfunction(value) then
            return nil
        end
        return value
    end

    local function normalizeResponseValue(response)
        if response == nil then return nil end
        if istable(response) then
            local normalized = {}
            local function pushLine(line)
                if isstring(line) then
                    normalized[#normalized + 1] = line
                elseif line ~= nil then
                    normalized[#normalized + 1] = tostring(line)
                end
            end

            for _, line in ipairs(response) do
                pushLine(line)
            end

            if #normalized == 0 then
                for _, line in pairs(response) do
                    pushLine(line)
                end
            end

            if #normalized > 0 then return normalized end
            return nil
        end
        return tostring(response)
    end

    local function addResponseMetadata(entry, source)
        if not istable(entry) or not istable(source) then return end
        local response = source.Response
        if isfunction(response) then
            entry.hasResponse = true
            entry.Response = nil
            return
        end

        local normalized = normalizeResponseValue(response)
        if normalized then
            entry.Response = normalized
            entry.hasResponse = true
        end
    end

    local function sanitizeConversationTable(tbl)
        if not istable(tbl) then return tbl end
        local out = {}
        for label, info in pairs(tbl) do
            local entry = {}
            if istable(info) then
                for k, v in pairs(info) do
                    if k == "options" and istable(v) then
                        entry[k] = sanitizeConversationTable(v)
                    elseif k ~= "options" then
                        entry[k] = deepCopy(v)
                    end
                end

                if entry.serverOnly then entry.Callback = nil end
                entry.ShouldShow = nil
                addResponseMetadata(entry, info)
                if info.options and istable(info.options) and not entry.options then entry.options = sanitizeConversationTable(info.options) end
                out[label] = entry
            elseif not isfunction(info) then
                entry = info
                out[label] = entry
            end
        end
        return out
    end

    local function flattenGreetings(conversation)
        if not istable(conversation) then return conversation end
        local greetings = conversation["Greetings"]
        if istable(greetings) and istable(greetings.options) then return greetings.options end
        return conversation
    end

    local function filterConversationOptions(conversation, ply, npc)
        if not istable(conversation) then return conversation end
        conversation = flattenGreetings(conversation)
        local filtered = {}
        for label, info in pairs(conversation) do
            local shouldShow = true
            if istable(info) and info.ShouldShow then shouldShow = info.ShouldShow(ply, npc) end
            if shouldShow then
                local entry = {}
                for k, v in pairs(info) do
                    if k == "GetOptions" and isfunction(v) then
                        entry[k] = v
                    else
                        entry[k] = deepCopy(v)
                    end
                end

                entry.ShouldShow = nil
                addResponseMetadata(entry, info)
                if istable(entry.options) then entry.options = filterConversationOptions(entry.options, ply, npc) end
                filtered[label] = entry
            end
        end
        return filtered
    end

    --[[
    Purpose:
        Synchronizes dialog data to clients, filtering conversations based on player permissions and sanitizing sensitive information

    When Called:
        Called during player spawn and when new NPCs are registered to ensure clients have up-to-date dialog information

    Parameters:
        client (Player, optional)
            Specific client to sync to, or nil to sync to all clients

    Returns:
        None

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Sync all dialog data to all clients
        lia.dialog.syncToClients()
        ```

    Medium Complexity:
        ```lua
        -- Medium: Sync data to a specific player after login
        hook.Add("PlayerInitialSpawn", "SyncDialogData", function(ply)
            if not ply:IsBot() then
                lia.dialog.syncToClients(ply)
            end
        end)
        ```

    High Complexity:
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
    ]]
    local function getDataHash(data)
        if not istable(data) then return "" end
        local json = util.TableToJSON(data, false)
        return util.CRC(json or "")
    end

    function lia.dialog.syncToClients(client)
        local targetClients = client and {client} or player.GetAll()
        for _, ply in ipairs(targetClients) do
            local filteredData = {}
            for uniqueID, data in pairs(lia.dialog.stored) do
                local filteredNPCData = table.Copy(data)
                if filteredNPCData.Conversation then filteredNPCData.Conversation = filterConversationOptions(filteredNPCData.Conversation, ply, nil) end
                filteredData[uniqueID] = sanitizeConversationTable(filteredNPCData)
            end

            local dataHash = getDataHash(filteredData)
            local clientID = ply:SteamID64() or ply:SteamID()
            local lastHash = lia.dialog.clientHashes[clientID]
            if dataHash ~= lastHash then
                lia.dialog.clientHashes[clientID] = dataHash
                net.Start("liaDialogSync")
                net.WriteTable(filteredData)
                net.Send(ply)
            end
        end
    end

    function lia.dialog.syncDialogs()
        lia.dialog.syncToClients()
    end

    --[[
    Purpose:
        Registers a new NPC with conversation data in the dialog system

    When Called:
        Called during gamemode initialization or when adding new NPCs to register their conversation trees

    Parameters:
        uniqueID (string)
            Unique identifier for the NPC
        data (table)
            NPC data table with the following properties:
            - PrintName (string): Display name for the NPC
            - Greeting (string): Optional opening phrase displayed when dialog starts
            - text (string): Optional dialog text displayed above conversation options
            - description (string): Alternative to text field
            - dialog (string): Alternative to text field
            - Conversation (table): Dialog options and their configurations

    Returns:
        (boolean)
            True if registration successful, false otherwise

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Register a basic NPC
        local success = lia.dialog.registerNPC("shopkeeper", {
            PrintName = "Shopkeeper",
            Greeting = "Welcome to my shop! How can I help you today?",
            Conversation = {
                ["Trade"] = {Response = "Let me show you what I have for sale!"},
                ["Bye"] = {Response = "Come back anytime!"}
            }
        })
        ```

    Medium Complexity:
        ```lua
        -- Medium: Register NPC with conditional options
        local questNPC = {
            PrintName = "Quest Master",
            Greeting = "Greetings, adventurer! I have quests that will test your courage and skill.",
            Conversation = {
                ["Available Quests"] = {
                    ShouldShow = function(ply) return ply:GetLevel() >= 5 end,
                    Response = "Here are the quests available to you:",
                    options = {
                        ["Accept Quest"] = {
                            Response = "Quest accepted! Good luck on your adventure.",
                            serverOnly = true
                        }
                    }
                },
                ["Training"] = {
                    Response = "Let me teach you some skills!"
                }
            }
        }
        lia.dialog.registerNPC("quest_master", questNPC)
        ```

    High Complexity:
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
                                Response = "Welcome to the " .. factionName .. "! You are now a member.",
                                serverOnly = true
                            },
                            ["Faction Benefits"] = {
                                ShouldShow = function(ply) return ply:GetFaction() == factionName end,
                                Response = "As a member of " .. factionName .. ", you have access to special equipment and areas."
                            },
                            ["Leave Faction"] = {
                                ShouldShow = function(ply, npc)
                                    return ply:GetFaction() == factionName and npc:GetFactionRank() >= 3
                                end,
                                Response = "You have left the " .. factionName .. ".",
                                serverOnly = true
                            }
                        }
                    },
                    ["Quests"] = {
                        ShouldShow = function(ply) return ply:GetFaction() == factionName end,
                        options = factionData.quests
                    },
                    ["General Info"] = {
                        Response = "The " .. factionName .. " is dedicated to [faction purpose]. We value [faction values]."
                    }
                }
            }

            return lia.dialog.registerNPC(string.lower(factionName) .. "_rep", npcConfig)
        end

        -- Register multiple faction NPCs
        createFactionNPC("Warriors", {minLevel = 10, quests = warriorQuests})
        createFactionNPC("Mages", {minLevel = 8, quests = mageQuests})
        ```
    ]]
    function lia.dialog.registerNPC(uniqueID, data, shouldSync)
        if not uniqueID or not data then return false end
        if not data.Conversation then return false end
        local hasChanged
        local sanitizedData = table.Copy(data)
        if sanitizedData.Conversation then sanitizedData.Conversation = sanitizeConversationTable(sanitizedData.Conversation) end
        if not lia.dialog.stored[uniqueID] then
            hasChanged = true
        else
            hasChanged = not lia.dialog.isTableEqual(lia.dialog.stored[uniqueID], sanitizedData)
        end

        lia.dialog.originalData = lia.dialog.originalData or {}
        lia.dialog.originalData[uniqueID] = data
        lia.dialog.stored[uniqueID] = sanitizedData
        if shouldSync ~= false and hasChanged then lia.dialog.syncToClients() end
        return true
    end

    lia.dialog.registerNPC("tutorial_guide", {
        PrintName = "Tutorial Guide",
        Greeting = "Hello there! I'm here to help new players learn the ropes. What would you like to know?",
        Conversation = {
            ["I'm new here, can you help me?"] = {
                options = {
                    ["Tell me about factions"] = {
                        ShouldShow = function() return true end,
                        Response = "Factions are the main groups in this roleplay world. Every character belongs to one!",
                        options = {
                            ["What factions are available?"] = {
                                ShouldShow = function() return true end,
                                Response = "Citizens are usually the default - regular people living their lives. There might be police, medical, or other specialized factions.",
                                options = {
                                    ["How do I join a faction?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Open your character menu (usually F1) and select 'Create Character'. Choose your faction from the dropdown menu.",
                                    },
                                    ["Are there faction limits?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Some factions have player limits to maintain balance. Popular factions like police might be restricted.",
                                    }
                                }
                            },
                            ["What's the difference between factions and classes?"] = {
                                ShouldShow = function() return true end,
                                Response = "Factions are broad groups (like 'Police Department'), while classes are specialized roles within factions (like 'Detective' or 'SWAT').",
                                options = {
                                    ["Tell me more about classes"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Classes give you special equipment, abilities, or restrictions. For example, a SWAT class might have better armor and weapons but move slower.",
                                    },
                                    ["Can I have multiple classes?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Usually one class per character, but you can have multiple characters with different classes!",
                                    }
                                }
                            }
                        }
                    },
                    ["How do I get started with items?"] = {
                        ShouldShow = function() return true end,
                        Response = "Items are crucial! They include weapons, tools, food, and more.",
                        options = {
                            ["How do I open my inventory?"] = {
                                ShouldShow = function() return true end,
                                Response = "Press F2 or the inventory key to open your inventory. You can drag items, equip them, or use them from there.",
                            },
                            ["Where can I buy items?"] = {
                                ShouldShow = function() return true end,
                                Response = "Look for vendors (NPCs with shopping carts above their heads) or business owners. Some factions give starting items.",
                                options = {
                                    ["How does money work?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "You earn money through jobs, selling items, or roleplaying. Use /givemoney to give money to others, or drop it as an item.",
                                    },
                                    ["Can I trade items?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Yes! Drag items from your inventory to another player's inventory when they're nearby, or use the trade system if available.",
                                    }
                                }
                            }
                        }
                    },
                    ["What about roleplaying?"] = {
                        ShouldShow = function() return true end,
                        Response = "Roleplaying is the heart of this server! Stay in character, follow server rules, and have fun.",
                        options = {
                            ["How do I talk in character?"] = {
                                ShouldShow = function() return true end,
                                Response = "Use /say or just type normally for local chat. /yell for shouting, /whisper for quiet talking, /me for actions, /it for environmental descriptions.",
                            },
                            ["What are the basic rules?"] = {
                                ShouldShow = function() return true end,
                                Response = "No random deathmatching, respect other players' roleplay, follow faction rules, and don't metagame (using OOC info in IC situations).",
                                options = {
                                    ["What is metagaming?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Metagaming is using out-of-character knowledge in roleplay. For example, knowing someone's identity from their Steam name.",
                                    },
                                    ["How do I report rule breakers?"] = {
                                        ShouldShow = function() return true end,
                                        Response = "Contact admins using @ or the admin chat. For serious issues, use /report or find an admin in-game.",
                                    }
                                }
                            }
                        }
                    }
                }
            },
            ["I need help with something specific"] = {
                options = {
                    ["I'm stuck or bugged"] = {
                        ShouldShow = function() return true end,
                        Response = "Try relogging first. If that doesn't work, contact an admin with /admin or @. Include details about what happened.",
                    },
                    ["How do I change my character?"] = {
                        ShouldShow = function() return true end,
                        Response = "Press F1 to open the character menu, then select 'Load Character' to switch between your characters.",
                    },
                    ["I lost my items"] = {
                        ShouldShow = function() return true end,
                        Response = "Items save automatically. If you lost them due to a bug, contact an admin immediately with details about what you had.",
                    },
                    ["How do I get admin help?"] = {
                        ShouldShow = function() return true end,
                        Response = "Use @ message or /admin command to contact admins. Be patient - they help when available!",
                    }
                }
            },
            ["I'm ready to explore!"] = {
                ShouldShow = function() return true end,
                Response = "Great! Remember: stay in character, respect others, and have fun. The character menu (F1) and inventory (F2) are your best friends!",
                serverOnly = false
            },
            ["Goodbye"] = {
                Response = "Good luck out there! Feel free to come back if you have any more questions.",
                Callback = function() if IsValid(lia.dialog.vgui) then lia.dialog.vgui:Remove() end end,
                serverOnly = false
            }
        }
    })

    --[[
    Purpose:
        Opens a dialog interface for a player with a specific NPC, filtering conversation options based on player permissions

    When Called:
        Called when a player interacts with an NPC to start a conversation

    Parameters:
        client (Player)
            The player who is opening the dialog
        npc (Entity)
            The NPC entity being interacted with
        npcID (string)
            The unique identifier of the NPC type

    Returns:
        None

    Realm:
        Server

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Open dialog when player presses E on NPC
        hook.Add("PlayerUse", "OpenNPCDialog", function(ply, ent)
            if ent:GetClass() == "lia_npc" and ent.uniqueID then
                lia.dialog.openDialog(ply, ent, ent.uniqueID)
                return false -- Prevent default use
            end
        end)
        ```

    Medium Complexity:
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

    High Complexity:
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
    ]]
    function lia.dialog.openDialog(client, npc, npcID)
        local npcData = lia.dialog.getOriginalNPCData(npcID)
        if not npcData then
            client:notifyWarning("This NPC type is not registered. Please select a valid NPC type.")
            lia.dialog.syncToClients(client)
            timer.Simple(0.1, function()
                if not IsValid(client) or not IsValid(npc) then return end
                local npcOptions = {}
                for uniqueID, data in pairs(lia.dialog.stored) do
                    local displayName = data.PrintName or uniqueID
                    table.insert(npcOptions, {displayName, uniqueID})
                end

                if not table.IsEmpty(npcOptions) then
                    client.npcEntity = npc
                    net.Start("liaRequestNPCSelection")
                    net.WriteEntity(npc)
                    net.WriteTable(npcOptions)
                    net.Send(client)
                else
                    client:notifyError("No NPC types available! The server may still be loading modules. Please try again in a moment.")
                end
            end)
            return
        end

        local filteredData = table.Copy(npcData)
        if filteredData.Conversation then
            filteredData.Conversation = filterConversationOptions(filteredData.Conversation, client, npc)
            for _, entry in pairs(filteredData.Conversation) do
                if istable(entry) then
                    if isfunction(entry.GetOptions) then
                        local options = entry.GetOptions(client, npc)
                        if istable(options) and table.Count(options) > 0 then
                            local sanitizedOptions = {}
                            for optLabel, optInfo in pairs(options) do
                                if istable(optInfo) then
                                    local responseText = optInfo.Response
                                    if isfunction(responseText) then responseText = nil end
                                    sanitizedOptions[optLabel] = {
                                        serverOnly = optInfo.serverOnly or false,
                                        Response = responseText or "",
                                        vehicleID = optInfo.vehicleID,
                                        closeDialog = optInfo.closeDialog or false,
                                        keepOpen = optInfo.keepOpen,
                                    }
                                end
                            end

                            entry.options = sanitizedOptions
                        end

                        entry.GetOptions = nil
                    end
                end
            end
        end

        filteredData.UniqueID = npcID
        hook.Run("OnNPCTypeSet", client, npc, npcID, filteredData)
        if filteredData.Conversation then filteredData.Conversation = sanitizeConversationTable(filteredData.Conversation) end
        local function safeRemoveFunctions(tbl, depth)
            depth = depth or 0
            if depth > 10 then return tbl end
            if not istable(tbl) then return tbl end
            local cleaned = {}
            for k, v in pairs(tbl) do
                if not isfunction(v) then
                    if istable(v) then
                        if k == "options" then
                            cleaned[k] = v
                        else
                            cleaned[k] = safeRemoveFunctions(v, depth + 1)
                        end
                    else
                        cleaned[k] = v
                    end
                end
            end
            return cleaned
        end

        filteredData = safeRemoveFunctions(filteredData)
        net.Start("liaOpenNpcDialog")
        net.WriteEntity(npc)
        net.WriteBool(client:hasPrivilege("canManageProperties"))
        net.WriteTable(filteredData)
        net.Send(client)
    end
else
    --[[
    Purpose:
        Retrieves stored NPC dialog data for a specific NPC ID on the client side

    When Called:
        Used internally when accessing NPC conversation data from the client-side storage

    Parameters:
        npcID (string)
            The unique identifier of the NPC to retrieve data for

    Returns:
        (table or nil)
            The NPC dialog data table if found, nil otherwise

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Get NPC data for UI display
        local npcData = lia.dialog.getNPCData("shopkeeper")
        if npcData then
            -- Display NPC information in UI
        end
        ```

    Medium Complexity:
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

    High Complexity:
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
    ]]
    function lia.dialog.getNPCData(npcID)
        if lia.dialog.stored[npcID] then return lia.dialog.stored[npcID] end
        return nil
    end

    function lia.dialog.submitConfiguration(configID, npc, payload)
        if not isstring(configID) or configID == "" then return end
        if not IsValid(npc) then return end
        net.Start("liaNpcCustomize")
        net.WriteString(configID)
        net.WriteEntity(npc)
        net.WriteTable(payload or {})
        net.SendToServer()
    end

    --[[
    Purpose:
        Opens a comprehensive NPC customization interface allowing players with management privileges to modify NPC appearance, name, and animations

    When Called:
        Called when privileged players select the "Customize this NPC" option from an NPC dialog menu

    Parameters:
        npc (Entity)
            The NPC entity to customize

    Returns:
        None

    Realm:
        Client

    Example Usage:

    Low Complexity:
        ```lua
        -- Simple: Open customization for an NPC
        local npc = ents.Create("lia_npc")
        npc:Spawn()
        lia.dialog.openCustomizationUI(npc)
        ```

    Medium Complexity:
        ```lua
        -- Medium: Open customization with validation
        local function tryCustomizeNPC(npc)
            if not IsValid(npc) then
                LocalPlayer():notifyError("Invalid NPC entity")
                return false
            end

            if not LocalPlayer():hasPrivilege("canManageNPCs") then
                LocalPlayer():notifyError("You don't have permission to configure NPCs")
                return false
            end

            lia.dialog.openCustomizationUI(npc)
            return true
        end
        ```

    High Complexity:
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
    ]]
    function lia.dialog.openCustomizationUI(npc, configID)
        configID = configID or "appearance"
        if not IsValid(npc) then return end
        local frame = vgui.Create("liaFrame")
        frame:SetTitle("Customize NPC")
        frame:SetSize(800, 700)
        frame:Center()
        frame:MakePopup()
        frame:SetDraggable(true)
        frame:ShowCloseButton(true)
        local scroll = vgui.Create("liaScrollPanel", frame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 10, 10, 10)
        local existingData = {}
        if IsValid(npc) then
            existingData = {
                name = npc:getNetVar("NPCName", npc.NPCName or "NPC"),
                model = "models/Barney.mdl",
                skin = npc:GetSkin() or 0,
                bodygroups = {},
                animation = npc.customData and npc.customData.animation or "auto"
            }

            for i = 0, npc:GetNumBodyGroups() - 1 do
                existingData.bodygroups[i] = npc:GetBodygroup(i)
            end
        end

        local hasSkins = false
        if IsValid(npc) then
            local maxSkins = 0
            for i = 0, 31 do
                local oldSkin = npc:GetSkin()
                npc:SetSkin(i)
                if npc:GetSkin() == i then
                    maxSkins = i
                else
                    break
                end

                npc:SetSkin(oldSkin)
            end

            hasSkins = maxSkins > 0
        end

        local hasBodygroups = false
        if IsValid(npc) then
            for i = 0, npc:GetNumBodyGroups() - 1 do
                local bgCount = npc:GetBodygroupCount(i)
                if bgCount > 1 then
                    hasBodygroups = true
                    break
                end
            end
        end

        local bodygroupControls = {}
        local bodygroupScroll = nil
        local function onBodygroupValueChanged(bodygroupIndex, _, val)
            if IsValid(npc) then npc:SetBodygroup(bodygroupIndex, math.Round(val)) end
        end

        local function updateBodygroupControls()
            if not hasBodygroups or not IsValid(bodygroupScroll) then return end
            bodygroupScroll:Clear()
            bodygroupControls = {}
            if IsValid(npc) then
                for i = 0, npc:GetNumBodyGroups() - 1 do
                    local bgName = npc:GetBodygroupName(i)
                    local bgCount = npc:GetBodygroupCount(i)
                    if bgCount <= 1 then continue end
                    local bgPanel = vgui.Create("DPanel", bodygroupScroll)
                    bgPanel:Dock(TOP)
                    bgPanel:SetTall(40)
                    bgPanel.Paint = function() end
                    local bgLabel = vgui.Create("DLabel", bgPanel)
                    bgLabel:Dock(LEFT)
                    bgLabel:SetWide(120)
                    bgLabel:SetText(bgName .. ":")
                    bgLabel:SetContentAlignment(6)
                    local bgSlider = vgui.Create("DNumSlider", bgPanel)
                    bgSlider:Dock(FILL)
                    bgSlider:SetMin(0)
                    bgSlider:SetMax(bgCount - 1)
                    bgSlider:SetDecimals(0)
                    bgSlider:SetValue(existingData.bodygroups[i] or 0)
                    bgSlider.OnValueChanged = function(_, val) onBodygroupValueChanged(i, _, val) end
                    bodygroupControls[i] = bgSlider
                end
            end
        end

        local nameLabel = vgui.Create("DLabel", scroll)
        nameLabel:Dock(TOP)
        nameLabel:SetText("NPC Name:")
        nameLabel:SetTall(20)
        nameLabel:DockMargin(0, 5, 0, 5)
        local nameEntry = vgui.Create("liaEntry", scroll)
        nameEntry:Dock(TOP)
        nameEntry:SetTall(25)
        nameEntry:SetValue(existingData.name or "NPC")
        nameEntry:DockMargin(0, 0, 0, 10)
        local modelLabel = vgui.Create("DLabel", scroll)
        modelLabel:Dock(TOP)
        modelLabel:SetText("Model Path:")
        modelLabel:SetTall(20)
        modelLabel:DockMargin(0, 5, 0, 5)
        local modelEntry = vgui.Create("liaEntry", scroll)
        modelEntry:Dock(TOP)
        modelEntry:SetTall(25)
        modelEntry:SetValue(existingData.model or "models/Barney.mdl")
        modelEntry:DockMargin(0, 0, 0, 10)
        modelEntry.action = function(value)
            if IsValid(npc) and value and value ~= "" then
                npc:SetModel(value)
                updateBodygroupControls()
                LocalPlayer():notifySuccess("NPC model updated to: " .. value)
            end
        end

        local skinEntry = nil
        if hasSkins then
            local skinLabel = vgui.Create("DLabel", scroll)
            skinLabel:Dock(TOP)
            skinLabel:SetText("Skin ID:")
            skinLabel:SetTall(20)
            skinLabel:DockMargin(0, 5, 0, 5)
            skinEntry = vgui.Create("DNumSlider", scroll)
            skinEntry:Dock(TOP)
            skinEntry:SetTall(40)
            skinEntry:SetMin(0)
            skinEntry:SetMax(31)
            skinEntry:SetDecimals(0)
            skinEntry:SetValue(existingData.skin or 0)
            skinEntry:DockMargin(0, 0, 0, 10)
            skinEntry:SetText("Skin ID")
            skinEntry.OnValueChanged = function(_, val) if IsValid(npc) then npc:SetSkin(math.Round(val)) end end
        end

        if hasBodygroups then
            local bodygroupLabel = vgui.Create("DLabel", scroll)
            bodygroupLabel:Dock(TOP)
            bodygroupLabel:SetText("Bodygroups:")
            bodygroupLabel:SetTall(20)
            bodygroupLabel:DockMargin(0, 5, 0, 5)
            local bodygroupPanel = vgui.Create("DPanel", scroll)
            bodygroupPanel:Dock(TOP)
            bodygroupPanel:SetTall(150)
            bodygroupPanel.Paint = function() end
            bodygroupScroll = vgui.Create("liaScrollPanel", bodygroupPanel)
            bodygroupScroll:Dock(FILL)
            bodygroupScroll:DockMargin(5, 5, 5, 5)
            updateBodygroupControls()
        end

        local hasAnimations = false
        local availableAnimations = {}
        local selectedAnimation = "auto"
        if IsValid(npc) then
            availableAnimations = {}
            local sequences = npc:GetSequenceList()
            if not sequences or #sequences == 0 then
                local model = npc:GetModel()
                if model then
                    npc:SetModel(model)
                    sequences = npc:GetSequenceList()
                end
            end

            if sequences and #sequences > 0 then
                hasAnimations = true
                for k, v in ipairs(sequences) do
                    availableAnimations[k] = v
                end

                selectedAnimation = existingData.animation or "auto"
            end
        end

        local animationCombo = nil
        if hasAnimations then
            local animationLabel = vgui.Create("DLabel", scroll)
            animationLabel:Dock(TOP)
            animationLabel:SetText("Animation:")
            animationLabel:SetTall(20)
            animationLabel:DockMargin(0, 5, 0, 5)
            animationCombo = vgui.Create("liaComboBox", scroll)
            animationCombo:Dock(TOP)
            animationCombo:SetTall(25)
            animationCombo:DockMargin(0, 0, 0, 10)
            animationCombo:SetValue(selectedAnimation == "auto" and "Auto (idle animation)" or selectedAnimation)
            local selectedIndex = 0
            if selectedAnimation == "auto" then
                selectedIndex = 1
            else
                for i, animName in ipairs(availableAnimations) do
                    if animName == selectedAnimation then
                        selectedIndex = i + 1
                        break
                    end
                end
            end

            animationCombo:ChooseOption(selectedAnimation, selectedIndex)
            animationCombo:AddChoice("Auto (idle animation)", "auto", selectedAnimation == "auto")
            for _, animName in ipairs(availableAnimations) do
                animationCombo:AddChoice(animName, animName, animName == selectedAnimation)
            end

            animationCombo.OnSelect = function(_, _, value)
                selectedAnimation = value
                if IsValid(npc) and value ~= "auto" then
                    local sequenceIndex = npc:LookupSequence(value)
                    if sequenceIndex >= 0 then npc:ResetSequence(sequenceIndex) end
                elseif IsValid(npc) then
                    npc:setAnim()
                end
            end

            local refreshBtn = vgui.Create("liaButton", scroll)
            refreshBtn:Dock(TOP)
            refreshBtn:SetTall(25)
            refreshBtn:DockMargin(0, 5, 0, 10)
            refreshBtn:SetText("Refresh Animation List")
            refreshBtn.DoClick = function()
                if IsValid(npc) then
                    local sequences = npc:GetSequenceList()
                    if sequences and #sequences > 0 then
                        animationCombo:Clear()
                        animationCombo:AddChoice("Auto (idle animation)", "auto", selectedAnimation == "auto")
                        for _, animName in ipairs(sequences) do
                            animationCombo:AddChoice(animName, animName, animName == selectedAnimation)
                        end

                        LocalPlayer():notifySuccess("Animation list refreshed! Found " .. #sequences .. " animations.")
                    else
                        LocalPlayer():notifyError("No animations found for this model.")
                    end
                end
            end
        else
            local noAnimLabel = vgui.Create("DLabel", scroll)
            noAnimLabel:Dock(TOP)
            noAnimLabel:SetText("No animations found for this model.")
            noAnimLabel:SetTall(20)
            noAnimLabel:DockMargin(0, 5, 0, 5)
            noAnimLabel:SetTextColor(Color(255, 100, 100))
            local refreshAnimBtn = vgui.Create("liaButton", scroll)
            refreshAnimBtn:Dock(TOP)
            refreshAnimBtn:SetTall(25)
            refreshAnimBtn:DockMargin(0, 5, 0, 10)
            refreshAnimBtn:SetText("Try Refresh Animations")
            refreshAnimBtn.DoClick = function()
                if IsValid(npc) then
                    local sequences = npc:GetSequenceList()
                    if sequences and #sequences > 0 then
                        LocalPlayer():notifySuccess("Found " .. #sequences .. " animations! Please reopen the customization menu.")
                    else
                        LocalPlayer():notifyError("Still no animations found. The model might not have animations.")
                    end
                end
            end
        end

        local dialogTypeLabel = vgui.Create("DLabel", scroll)
        dialogTypeLabel:Dock(TOP)
        dialogTypeLabel:SetText("Dialog Type:")
        dialogTypeLabel:SetTall(20)
        dialogTypeLabel:DockMargin(0, 15, 0, 5)
        local currentType = npc:getNetVar("uniqueID", npc.uniqueID) or "none"
        local dialogTypeCombo = vgui.Create("liaComboBox", scroll)
        dialogTypeCombo:Dock(TOP)
        dialogTypeCombo:SetTall(30)
        dialogTypeCombo:DockMargin(0, 0, 0, 10)
        dialogTypeCombo:AddChoice("None (No Dialog)", "none", currentType == "none" or currentType == nil)
        for uniqueID, data in pairs(lia.dialog.stored) do
            local displayName = data.PrintName or uniqueID
            dialogTypeCombo:AddChoice(displayName, uniqueID, uniqueID == currentType)
        end

        dialogTypeCombo:FinishAddingOptions()
        dialogTypeCombo:PostInit()
        dialogTypeCombo.OnSelect = function(_, _, value) selectedDialogType = value end
        local applyBtn = vgui.Create("liaButton", scroll)
        applyBtn:Dock(TOP)
        applyBtn:SetTall(35)
        applyBtn:SetText("Apply Customizations")
        applyBtn:DockMargin(0, 5, 0, 10)
        applyBtn.DoClick = function()
            local nameValue = nameEntry:GetValue() or ""
            local customData = {
                name = string.Trim(nameValue),
                model = modelEntry:GetValue(),
                bodygroups = {}
            }

            if skinEntry and hasSkins then customData.skin = skinEntry:GetValue() end
            if hasBodygroups then
                for i, slider in pairs(bodygroupControls) do
                    if IsValid(slider) then customData.bodygroups[i] = slider:GetValue() end
                end
            end

            if hasAnimations and animationCombo then customData.animation = selectedAnimation end
            lia.dialog.submitConfiguration(configID, npc, customData)
            if selectedDialogType ~= currentType then
                lia.dialog.submitConfiguration("dialog_type", npc, {
                    dialogType = selectedDialogType
                })
            end

            frame:Close()
        end

        if lia.dialog.pendingOtherConfigs and #lia.dialog.pendingOtherConfigs > 0 then
            local otherConfigs = lia.dialog.pendingOtherConfigs
            local pendingNPC = lia.dialog.pendingNPC
            local pendingNPCID = lia.dialog.pendingNPCID
            lia.dialog.pendingOtherConfigs = nil
            lia.dialog.pendingNPC = nil
            lia.dialog.pendingNPCID = nil
            local separator = vgui.Create("DPanel", scroll)
            separator:Dock(TOP)
            separator:SetTall(1)
            separator:DockMargin(0, 10, 0, 10)
            separator.Paint = function(_, w, h) draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 100)) end
            local otherLabel = vgui.Create("DLabel", scroll)
            otherLabel:Dock(TOP)
            otherLabel:SetText("Other Configurations:")
            otherLabel:SetTall(20)
            otherLabel:SetTextColor(color_white)
            otherLabel:DockMargin(0, 5, 0, 5)
            for _, config in ipairs(otherConfigs) do
                if isfunction(config.onOpen) then
                    local configBtn = vgui.Create("liaButton", scroll)
                    configBtn:Dock(TOP)
                    configBtn:SetTall(30)
                    configBtn:SetText(config.name or config.id or "Configuration")
                    configBtn:DockMargin(0, 5, 0, 5)
                    configBtn.DoClick = function()
                        frame:Close()
                        config.onOpen(pendingNPC, pendingNPCID)
                    end
                end
            end
        end

        local cancelBtn = vgui.Create("liaButton", scroll)
        cancelBtn:Dock(TOP)
        cancelBtn:SetTall(30)
        cancelBtn:SetText("Cancel")
        cancelBtn:DockMargin(0, 5, 0, 10)
        cancelBtn.DoClick = function() frame:Close() end
    end
end

local function isConfigurationVisible(config, ply, npc, npcID)
    if not isfunction(config.shouldShow) then return true end
    local ok, result = pcall(config.shouldShow, ply, npc, npcID)
    if not ok then
        ErrorNoHalt(string.format("[Lilia] NPC configuration '%s' visibility check failed clientside: %s\n", config.id or "unknown", tostring(result)))
        return false
    end
    return result ~= false
end

--[[
    Purpose:
        Retrieves all available NPC configuration modules that are visible to the specified player

    Parameters:
        ply (Player)
            The player to check visibility for
        npc (Entity)
            The NPC entity being configured
        npcID (string)
            The unique identifier of the NPC type

    Returns:
        (table)
            Array of available configuration modules, sorted by order
]]
function lia.dialog.getAvailableConfigurations(ply, npc, npcID)
    local options = {}
    if not IsValid(ply) then return options end
    for _, config in pairs(lia.dialog.configurations) do
        if not isfunction(config.onOpen) then continue end
        if isConfigurationVisible(config, ply, npc, npcID) then options[#options + 1] = config end
    end

    table.sort(options, function(a, b)
        local aOrder = a.order or 0
        local bOrder = b.order or 0
        if aOrder == bOrder then return (a.name or a.id or "") < (b.name or b.id or "") end
        return aOrder < bOrder
    end)
    return options
end

--[[
    Purpose:
        Opens a configuration picker interface that displays all available NPC customization modules for privileged users
        Now directly opens the appearance menu and adds other configuration buttons at the bottom

    Parameters:
        npc (Entity)
            The NPC entity to configure
        npcID (string, optional)
            The unique identifier of the NPC type (defaults to npc.uniqueID)
]]
function lia.dialog.openConfigurationPicker(npc, npcID)
    npcID = npcID or (IsValid(npc) and npc.uniqueID)
    local ply = LocalPlayer()
    local configurations = lia.dialog.getAvailableConfigurations(ply, npc, npcID)
    if #configurations == 0 then
        LocalPlayer():notifyError("No NPC configurations are available.")
        return
    end

    local appearanceConfig = nil
    local otherConfigs = {}
    for _, config in ipairs(configurations) do
        if config.id == "appearance" then
            appearanceConfig = config
        else
            table.insert(otherConfigs, config)
        end
    end

    local primaryConfig = appearanceConfig or configurations[1]
    if primaryConfig and isfunction(primaryConfig.onOpen) then
        if IsValid(lia.dialog.vgui) then lia.dialog.vgui:Remove() end
        primaryConfig.onOpen(npc, npcID)
        if #otherConfigs > 0 then
            lia.dialog.pendingOtherConfigs = otherConfigs
            lia.dialog.pendingNPC = npc
            lia.dialog.pendingNPCID = npcID
        end
    end
end

local function canAccessNPCConfigurations(ply)
    if not IsValid(ply) then return false end
    if CLIENT and ply == LocalPlayer() and not ply.hasPrivilege then return true end
    if not ply.hasPrivilege then return false end
    local ok1, allowed1 = pcall(function() return ply:hasPrivilege("canManageNPCs") end)
    if ok1 and allowed1 == true then return true end
    local ok2, allowed2 = pcall(function() return ply:hasPrivilege("canManageProperties") end)
    if not ok2 then return CLIENT end
    return allowed2 == true
end

lia.dialog.registerConfiguration("appearance", {
    name = "Appearance",
    description = "Rename NPCs and adjust their models, skins, bodygroups, and animations.",
    order = 0,
    shouldShow = function(ply) return canAccessNPCConfigurations(ply) end
})

if SERVER then
    lia.dialog.registerConfiguration("appearance", {
        onApply = function(ply, npc, customData)
            if not IsValid(npc) then return end
            customData = istable(customData) and customData or {}
            if customData.name then
                local trimmedName = string.Trim(customData.name)
                if trimmedName ~= "" then
                    npc.NPCName = trimmedName
                else
                    npc.NPCName = "NPC"
                end
            end

            if customData.model and customData.model ~= "" then npc:SetModel(customData.model) end
            if customData.skin then npc:SetSkin(tonumber(customData.skin) or 0) end
            if customData.bodygroups and istable(customData.bodygroups) then
                for bodygroupIndex, value in pairs(customData.bodygroups) do
                    npc:SetBodygroup(tonumber(bodygroupIndex) or 0, tonumber(value) or 0)
                end
            end

            if customData.animation and customData.animation ~= "auto" then
                local sequenceIndex = npc:LookupSequence(customData.animation)
                if sequenceIndex >= 0 then
                    npc.customAnimation = customData.animation
                    npc:ResetSequence(sequenceIndex)
                end
            else
                npc.customAnimation = nil
            end

            local currentPos = npc:GetPos()
            local currentAng = npc:GetAngles()
            npc:SetMoveType(MOVETYPE_VPHYSICS)
            npc:SetSolid(SOLID_OBB)
            npc:PhysicsInit(SOLID_OBB)
            npc:SetCollisionGroup(COLLISION_GROUP_WORLD)
            npc:SetPos(currentPos)
            npc:SetAngles(currentAng)
            local physObj = npc:GetPhysicsObject()
            if IsValid(physObj) then
                physObj:EnableMotion(false)
                physObj:Sleep()
            end

            npc:setAnim()
            npc.customData = customData
            if not npc.NPCName or npc.NPCName == "" then npc.NPCName = "NPC" end
            npc:setNetVar("NPCName", npc.NPCName)
            hook.Run("UpdateEntityPersistence", npc)
            hook.Run("SaveData")
            ply:notifySuccess("NPC customized successfully!")
        end
    })
else
    lia.dialog.registerConfiguration("appearance", {
        onOpen = function(npc) lia.dialog.openCustomizationUI(npc, "appearance") end
    })

    properties.Add("liaConfigureNPC", {
        MenuLabel = L("configureNPC"),
        Order = 100,
        MenuIcon = "icon16/wrench.png",
        Filter = function(_, ent, ply)
            if not IsValid(ent) or ent:GetClass() ~= "lia_npc" then return false end
            return canAccessNPCConfigurations(ply)
        end,
        Action = function(_, ent) lia.dialog.openConfigurationPicker(ent) end
    })
end