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

function lia.dialog.getConfiguration(uniqueID)
    return lia.dialog.configurations[uniqueID]
end

if SERVER then
    function lia.dialog.getNPCData(npcID)
        if lia.dialog.stored[npcID] then return lia.dialog.stored[npcID] end
        return nil
    end

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
                model = npc:GetModel(),
                skin = npc:GetSkin(),
                bodygroups = {},
                animation = npc.customData and npc.customData.animation or "auto"
            }

            for i = 0, npc:GetNumBodyGroups() - 1 do
                existingData.bodygroups[i] = npc:GetBodygroup(i)
            end
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
            if IsValid(npc) then
                npc:SetBodygroup(bodygroupIndex, math.Round(val))
                existingData.bodygroups[bodygroupIndex] = math.Round(val)
            end
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
                local oldModel = npc:GetModel()
                if oldModel ~= value then
                    npc:SetModel(value)
                    existingData.bodygroups = {}
                    existingData.skin = 0
                    for i = 0, npc:GetNumBodyGroups() - 1 do
                        existingData.bodygroups[i] = npc:GetBodygroup(i)
                    end

                    updateBodygroupControls()
                    if hasSkin and skinSlider then
                        skinSlider:SetMax(math.max(0, npc:SkinCount() - 1))
                        skinSlider:SetValue(0)
                    end

                    LocalPlayer():notifySuccess("NPC model updated to: " .. value .. ". Bodygroups and skin have been reset.")
                end
            end
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

        local hasSkin = false
        local skinSlider = nil
        if IsValid(npc) then hasSkin = npc:SkinCount() > 1 end
        if hasSkin then
            local skinLabel = vgui.Create("DLabel", scroll)
            skinLabel:Dock(TOP)
            skinLabel:SetText("Skin:")
            skinLabel:SetTall(20)
            skinLabel:DockMargin(0, 5, 0, 5)
            skinSlider = vgui.Create("DNumSlider", scroll)
            skinSlider:Dock(TOP)
            skinSlider:SetTall(25)
            skinSlider:DockMargin(0, 0, 0, 10)
            skinSlider:SetMin(0)
            skinSlider:SetMax(math.max(0, npc:SkinCount() - 1))
            skinSlider:SetDecimals(0)
            skinSlider:SetValue(existingData.skin or 0)
            skinSlider.OnValueChanged = function(_, val)
                if IsValid(npc) then
                    npc:SetSkin(math.Round(val))
                    existingData.skin = math.Round(val)
                end
            end
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
        local selectedDialogType = currentType
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
            local modelValue = modelEntry:GetValue() or ""
            local customData = {
                name = string.Trim(nameValue),
                model = modelValue,
                skin = hasSkin and skinSlider and skinSlider:GetValue() or existingData.skin or 0,
                bodygroups = {}
            }

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
    lia.dialog.registerConfiguration("dialog_type", {
        onApply = function(ply, npc, customData)
            if not IsValid(npc) then return end
            customData = istable(customData) and customData or {}
            if customData.dialogType then
                npc.uniqueID = customData.dialogType
                hook.Run("UpdateEntityPersistence", npc)
                hook.Run("SaveData")
                ply:notifySuccess("NPC dialog type updated successfully!")
            end
        end
    })

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

            local modelChanged = false
            if customData.model and customData.model ~= "" then
                local oldModel = npc:GetModel()
                if oldModel ~= customData.model then modelChanged = true end
                npc:SetModel(customData.model)
            end

            if customData.bodygroups and istable(customData.bodygroups) then
                for bodygroupIndex, value in pairs(customData.bodygroups) do
                    npc:SetBodygroup(tonumber(bodygroupIndex) or 0, tonumber(value) or 0)
                end
            end

            if customData.skin ~= nil then npc:SetSkin(tonumber(customData.skin) or 0) end
            if modelChanged then
                npc.customAnimation = nil
                customData.animation = "auto"
                npc:SetSkin(0)
                customData.skin = 0
            end

            if customData.animation and customData.animation ~= "auto" then
                local sequenceIndex = npc:LookupSequence(customData.animation)
                if sequenceIndex >= 0 then
                    npc.customAnimation = customData.animation
                    npc:ResetSequence(sequenceIndex)
                else
                    npc.customAnimation = nil
                    customData.animation = "auto"
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
