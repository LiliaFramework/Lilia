--[[
    Folder: Developer - Libraries
    File: lia.dialog.md
]]
--[[
    Dialog

    Dialog helpers for Lilia NPC conversations, generated dialog trees, NPC configuration menus, and client synchronization.
]]
--[[
    Overview:
        The dialog library centralizes NPC dialog registration, generated dialog tree storage, faction-gated dialog nodes, NPC customization workflows, and clientside dialog configuration interfaces under `lia.dialog`.
]]
--[[
    Hooks:
        OnNPCTypeSet(Player client, Entity npc, string npcID, table data)

    Purpose:
        Runs after a server resolves an NPC dialog type and before the sanitized dialog payload is sent to the client.

    Category:
        Dialog

    Parameters:
        client (Player)
            The player opening the NPC dialog.

        npc (Entity)
            The dialog NPC being opened.

        npcID (string)
            The unique dialog type identifier assigned to the NPC.

        data (table)
            The filtered and sanitized dialog data being sent to the client.

    Example Usage:
        ```lua
        hook.Add("OnNPCTypeSet", "liaExampleOnNPCTypeSet", function(client, npc, npcID, data)
            if not IsValid(client) then return end
            print(string.format("[MyModule] handled OnNPCTypeSet for %s", client:Name()))
        end)
        ```

    Realm:
        Server
]]
lia.dialog = lia.dialog or {}
lia.dialog.stored = lia.dialog.stored or {}
lia.dialog.configurations = lia.dialog.configurations or {}
lia.dialog.clientHashes = lia.dialog.clientHashes or {}
--[[
    Purpose:
        Recursively compares two tables for matching keys and values while preventing infinite loops from cyclic references.

    Parameters:
        tbl1 (table)
            The first table to compare.

        tbl2 (table)
            The second table to compare.

        checked (table|nil)
            Internal table used to track tables that have already been compared.

    Returns:
        boolean
            True when both tables contain equivalent values, otherwise false.

    Example Usage:
        ```lua
        local same = lia.dialog.isTableEqual(firstTable, secondTable)
        ```

    Realm:
        Shared
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
        Registers or updates an NPC configuration entry used by the NPC configuration picker.

    Parameters:
        uniqueID (string)
            Unique identifier for the configuration entry.

        data (table)
            Configuration metadata such as name, description, order, visibility checks, and open/apply callbacks.

    Returns:
        table|nil
            The registered configuration table, or nil if the identifier is invalid.

    Example Usage:
        ```lua
        lia.dialog.registerConfiguration("appearance", {
            name = "@npcConfigAppearanceName",
            order = 0
        })
        ```

    Realm:
        Shared
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
        Returns a registered NPC configuration by unique identifier.

    Parameters:
        uniqueID (string)
            The unique configuration identifier to fetch.

    Returns:
        table|nil
            The configuration table when registered, otherwise nil.

    Example Usage:
        ```lua
        local config = lia.dialog.getConfiguration("appearance")
        ```

    Realm:
        Shared
]]
function lia.dialog.getConfiguration(uniqueID)
    return lia.dialog.configurations[uniqueID]
end

--[[
    Purpose:
        Resolves a dialog type value to its stored unique identifier, accepting either an identifier or a localized display name.

    Parameters:
        value (string)
            The dialog identifier, localized display name, empty value, or `none` marker to resolve.

    Returns:
        string
            The matching stored dialog identifier when found, otherwise the original value.

    Example Usage:
        ```lua
        local uniqueID = lia.dialog.resolveDialogTypeIdentifier(selection)
        ```

    Realm:
        Shared
]]
function lia.dialog.resolveDialogTypeIdentifier(value)
    if not isstring(value) or value == "" or value == "none" then return value end
    if lia.dialog.stored and lia.dialog.stored[value] then return value end
    for uniqueID, data in pairs(lia.dialog.stored or {}) do
        local displayName = lia.lang.resolveToken(data.PrintName or uniqueID)
        if displayName == value then return uniqueID end
    end
    return value
end

lia.dialog.generatedDialogSelectionID = "__lia_custom_dialog__"
lia.dialog.generatedDialogSelectionName = "Custom Dialog"
--[[
    Purpose:
        Checks whether a value represents the special custom dialog selection entry.

    Parameters:
        value (any)
            The value to compare against the generated dialog selection identifier.

    Returns:
        boolean
            True when the value matches the custom dialog selection identifier, otherwise false.

    Example Usage:
        ```lua
        if lia.dialog.isGeneratedDialogSelection(dialogType) then return end
        ```

    Realm:
        Shared
]]
function lia.dialog.isGeneratedDialogSelection(value)
    return string.Trim(tostring(value or "")) == lia.dialog.generatedDialogSelectionID
end

--[[
    Purpose:
        Checks whether an entity or class name represents a Lilia dialog NPC entity.

    Parameters:
        npcOrClass (Entity|string)
            The entity instance or class name to inspect.

    Returns:
        boolean
            True when the entity or class is `lia_npc`, otherwise false.

    Example Usage:
        ```lua
        if lia.dialog.isDialogNPCEntity(ent) then return true end
        ```

    Realm:
        Shared
]]
function lia.dialog.isDialogNPCEntity(npcOrClass)
    local className = npcOrClass
    if IsEntity(npcOrClass) then
        if not IsValid(npcOrClass) then return false end
        className = npcOrClass:GetClass()
    end
    return className == "lia_npc"
end

--[[
    Purpose:
        Checks whether a valid NPC is currently assigned to a generated dialog tree.

    Parameters:
        npc (Entity)
            The NPC entity to inspect.

    Returns:
        boolean
            True when the NPC's dialog data contains `GeneratedDialog`, otherwise false.

    Example Usage:
        ```lua
        local usesGenerated = lia.dialog.entityUsesGeneratedDialog(npc)
        ```

    Realm:
        Shared
]]
function lia.dialog.entityUsesGeneratedDialog(npc)
    if not IsValid(npc) then return false end
    local uniqueID = npc.uniqueID or npc:getNetVar("uniqueID", "")
    if uniqueID == "" then return false end
    local npcData = lia.dialog.getNPCData(uniqueID)
    return lia.dialog.isGeneratedDialogData(npcData)
end

--[[
    Purpose:
        Checks whether dialog data contains a generated node-based dialog tree.

    Parameters:
        data (table)
            The dialog data table to inspect.

    Returns:
        boolean
            True when the table has a `GeneratedDialog` table, otherwise false.

    Example Usage:
        ```lua
        if lia.dialog.isGeneratedDialogData(data) then return end
        ```

    Realm:
        Shared
]]
function lia.dialog.isGeneratedDialogData(data)
    return istable(data) and istable(data.GeneratedDialog)
end

--[[
    Purpose:
        Checks whether dialog data contains a standard conversation table.

    Parameters:
        data (table)
            The dialog data table to inspect.

    Returns:
        boolean
            True when the table has a `Conversation` table, otherwise false.

    Example Usage:
        ```lua
        if lia.dialog.isConversationDialogData(data) then return end
        ```

    Realm:
        Shared
]]
function lia.dialog.isConversationDialogData(data)
    return istable(data) and istable(data.Conversation)
end

--[[
    Purpose:
        Checks whether dialog data can be used by a valid dialog NPC entity.

    Parameters:
        npc (Entity)
            The NPC entity being configured or opened.

        data (table)
            The dialog data to validate.

    Returns:
        boolean
            True when the entity is a dialog NPC and the data is either conversation or generated dialog data.

    Example Usage:
        ```lua
        if lia.dialog.isDialogCompatibleWithEntity(npc, data) then return end
        ```

    Realm:
        Shared
]]
function lia.dialog.isDialogCompatibleWithEntity(npc, data)
    if not IsValid(npc) or not lia.dialog.isDialogNPCEntity(npc) then return false end
    return lia.dialog.isGeneratedDialogData(data) or lia.dialog.isConversationDialogData(data)
end

--[[
    Purpose:
        Builds the list of dialog type choices available for a dialog NPC.

    Parameters:
        npc (Entity)
            The NPC entity to validate options against.

    Returns:
        table
            A sorted list of `{displayName, uniqueID}` choices, followed by the custom dialog option.

    Example Usage:
        ```lua
        local options = lia.dialog.getCompatibleDialogOptions(npc)
        ```

    Realm:
        Shared
]]
function lia.dialog.getCompatibleDialogOptions(npc)
    local options = {}
    for uniqueID, data in pairs(lia.dialog.stored or {}) do
        if lia.dialog.isConversationDialogData(data) and lia.dialog.isDialogCompatibleWithEntity(npc, data) then options[#options + 1] = {lia.lang.resolveToken(data.PrintName or uniqueID), uniqueID} end
    end

    table.sort(options, function(a, b) return a[1] < b[1] end)
    options[#options + 1] = {lia.dialog.generatedDialogSelectionName, lia.dialog.generatedDialogSelectionID}
    return options
end

local function trimToString(value)
    return string.Trim(tostring(value or ""))
end

local function parseFactionRequirementTokens(requirement)
    local trimmed = trimToString(requirement)
    if trimmed == "" then return {} end
    local tokens, seen = {}, {}
    for token in string.gmatch(trimmed, "([^,]+)") do
        token = trimToString(token)
        local normalized = string.lower(token)
        if token ~= "" and not seen[normalized] then
            seen[normalized] = true
            tokens[#tokens + 1] = token
        end
    end
    return tokens
end

local function serializeFactionRequirementTokens(tokens)
    local normalized = {}
    for _, token in ipairs(tokens or {}) do
        token = trimToString(token)
        if token ~= "" then normalized[#normalized + 1] = token end
    end
    return table.concat(normalized, ", ")
end

local function getFactionByRequirementToken(token)
    token = trimToString(token)
    if token == "" or not lia.faction then return nil end
    local direct = lia.faction.get and lia.faction.get(token) or nil
    if direct then return direct end
    local tokenLower = string.lower(token)
    for _, faction in pairs(lia.faction.teams or {}) do
        if string.lower(tostring(faction.uniqueID or "")) == tokenLower or string.lower(tostring(faction.name or "")) == tokenLower or tonumber(token) == faction.index then return faction end
    end
end

local function getFactionRequirementDisplay(requirement)
    local labels = {}
    for _, token in ipairs(parseFactionRequirementTokens(requirement)) do
        local faction = getFactionByRequirementToken(token)
        labels[#labels + 1] = faction and trimToString(faction.name) ~= "" and faction.name or token
    end
    return #labels > 0 and table.concat(labels, ", ") or "Any faction"
end

local function factionMatchesRequirement(currentFactionIndex, requirement)
    local currentFaction = lia.faction and lia.faction.indices and lia.faction.indices[currentFactionIndex] or nil
    if not currentFaction then return false end
    local tokens = parseFactionRequirementTokens(requirement)
    if #tokens == 0 then return true end
    for _, token in ipairs(tokens) do
        local normalizedToken = string.lower(token)
        if normalizedToken == string.lower(tostring(currentFaction.uniqueID or "")) or normalizedToken == string.lower(tostring(currentFaction.name or "")) or tonumber(token) == currentFactionIndex then return true end
    end
    return false
end

--[[
    Purpose:
        Parses a comma-separated faction requirement string into unique trimmed tokens.

    Parameters:
        requirement (string)
            The faction requirement string to parse.

    Returns:
        table
            A sequential table of unique faction tokens.

    Example Usage:
        ```lua
        local tokens = lia.dialog.parseFactionRequirementTokens("citizen, police")
        ```

    Realm:
        Shared
]]
lia.dialog.parseFactionRequirementTokens = parseFactionRequirementTokens
--[[
    Purpose:
        Serializes faction requirement tokens into the comma-separated format used by generated dialog nodes.

    Parameters:
        tokens (table)
            Sequential faction identifiers or names to serialize.

    Returns:
        string
            The normalized comma-separated faction requirement string.

    Example Usage:
        ```lua
        local requirement = lia.dialog.serializeFactionRequirementTokens({"citizen", "police"})
        ```

    Realm:
        Shared
]]
lia.dialog.serializeFactionRequirementTokens = serializeFactionRequirementTokens
--[[
    Purpose:
        Builds a readable label for a generated dialog node's faction requirement.

    Parameters:
        requirement (string)
            The comma-separated faction requirement string to display.

    Returns:
        string
            Faction names when resolved, raw tokens when unresolved, or `Any faction` when no requirement is set.

    Example Usage:
        ```lua
        local label = lia.dialog.getFactionRequirementDisplay(node.factionRequirement)
        ```

    Realm:
        Shared
]]
lia.dialog.getFactionRequirementDisplay = getFactionRequirementDisplay
--[[
    Purpose:
        Checks whether a faction index satisfies a generated dialog node's faction requirement.

    Parameters:
        currentFactionIndex (number)
            The player's current faction index.

        requirement (string)
            The comma-separated faction requirement string to check.

    Returns:
        boolean
            True when the requirement is empty or includes the current faction by index, unique ID, or name.

    Example Usage:
        ```lua
        if lia.dialog.factionMatchesRequirement(client:Team(), node.factionRequirement) then return end
        ```

    Realm:
        Shared
]]
lia.dialog.factionMatchesRequirement = factionMatchesRequirement
local function findGeneratedNode(generatedDialog, nodeID)
    if not istable(generatedDialog) or not istable(generatedDialog.nodes) then return nil end
    for _, node in ipairs(generatedDialog.nodes) do
        if istable(node) and node.id == nodeID then return node end
    end
end

local function getGeneratedStartNode(generatedDialog)
    if not istable(generatedDialog) then return nil end
    local entryNodeID = generatedDialog.entryNodeID
    if entryNodeID and entryNodeID ~= "" then
        local entryNode = findGeneratedNode(generatedDialog, entryNodeID)
        if entryNode then return entryNode end
    end

    if istable(generatedDialog.nodes) then return generatedDialog.nodes[1] end
end

local function getGeneratedChildNodes(generatedDialog, nodeID)
    local parentNode = findGeneratedNode(generatedDialog, nodeID)
    local children = {}
    if not istable(parentNode) or not istable(parentNode.children) then return children end
    for _, childID in ipairs(parentNode.children) do
        local childNode = findGeneratedNode(generatedDialog, childID)
        if childNode then children[#children + 1] = childNode end
    end

    table.sort(children, function(a, b)
        local aLabel = trimToString(a.dialogID)
        local bLabel = trimToString(b.dialogID)
        if aLabel == "" then aLabel = trimToString(a.playerText) end
        if bLabel == "" then bLabel = trimToString(b.playerText) end
        return aLabel < bLabel
    end)
    return children
end

--[[
    Purpose:
        Finds a node inside a generated dialog tree by node identifier.

    Parameters:
        generatedDialog (table)
            Generated dialog tree containing a `nodes` table.

        nodeID (string)
            The node identifier to find.

    Returns:
        table|nil
            The matching generated dialog node, or nil when not found.

    Example Usage:
        ```lua
        local node = lia.dialog.findGeneratedNode(generatedDialog, nodeID)
        ```

    Realm:
        Shared
]]
lia.dialog.findGeneratedNode = findGeneratedNode
--[[
    Purpose:
        Returns the configured start node for a generated dialog tree.

    Parameters:
        generatedDialog (table)
            Generated dialog tree containing `entryNodeID` and `nodes`.

    Returns:
        table|nil
            The entry node when found, otherwise the first node or nil.

    Example Usage:
        ```lua
        local startNode = lia.dialog.getGeneratedStartNode(generatedDialog)
        ```

    Realm:
        Shared
]]
lia.dialog.getGeneratedStartNode = getGeneratedStartNode
--[[
    Purpose:
        Returns the child nodes linked from a generated dialog node.

    Parameters:
        generatedDialog (table)
            Generated dialog tree containing the parent and child nodes.

        nodeID (string)
            The parent node identifier.

    Returns:
        table
            A sorted list of child node tables.

    Example Usage:
        ```lua
        local children = lia.dialog.getGeneratedChildNodes(generatedDialog, node.id)
        ```

    Realm:
        Shared
]]
lia.dialog.getGeneratedChildNodes = getGeneratedChildNodes
local function sanitizeGeneratedNode(rawNode, index)
    rawNode = istable(rawNode) and rawNode or {}
    local nodeID = trimToString(rawNode.id)
    if nodeID == "" then nodeID = "node_" .. tostring(index or 1) end
    local children = {}
    for _, childID in ipairs(rawNode.children or {}) do
        childID = trimToString(childID)
        if childID ~= "" and not table.HasValue(children, childID) then children[#children + 1] = childID end
    end
    return {
        id = nodeID,
        dialogID = trimToString(rawNode.dialogID),
        npcText = trimToString(rawNode.npcText),
        playerText = trimToString(rawNode.playerText),
        waypoint = trimToString(rawNode.waypoint),
        swepClass = trimToString(rawNode.swepClass),
        factionRequirement = trimToString(rawNode.factionRequirement),
        soundPath = trimToString(rawNode.soundPath),
        requirementMessage = trimToString(rawNode.requirementMessage),
        children = children,
        position = {
            x = math.Round(tonumber(rawNode.position and rawNode.position.x) or 40),
            y = math.Round(tonumber(rawNode.position and rawNode.position.y) or 40)
        }
    }
end

local function sanitizeGeneratedDialogPayload(dialogTypeID, payload)
    payload = istable(payload) and payload or {}
    local generatedDialog = istable(payload.generatedDialog) and payload.generatedDialog or payload
    local nodes = {}
    local seenIDs = {}
    for index, rawNode in ipairs(generatedDialog.nodes or {}) do
        local node = sanitizeGeneratedNode(rawNode, index)
        if not seenIDs[node.id] then
            seenIDs[node.id] = true
            nodes[#nodes + 1] = node
        end
    end

    if #nodes == 0 then
        nodes[1] = sanitizeGeneratedNode({
            id = "node_1",
            dialogID = "start",
            npcText = "",
            playerText = "",
            children = {},
            position = {
                x = 40,
                y = 40
            }
        }, 1)
    end

    local validNodeIDs = {}
    for _, node in ipairs(nodes) do
        validNodeIDs[node.id] = true
    end

    for _, node in ipairs(nodes) do
        local filteredChildren = {}
        for _, childID in ipairs(node.children or {}) do
            if validNodeIDs[childID] and childID ~= node.id and not table.HasValue(filteredChildren, childID) then filteredChildren[#filteredChildren + 1] = childID end
        end

        node.children = filteredChildren
    end

    local entryNodeID = trimToString(generatedDialog.entryNodeID)
    if entryNodeID == "" or not validNodeIDs[entryNodeID] then entryNodeID = nodes[1].id end
    local printName = trimToString(payload.printName)
    if printName == "" then printName = dialogTypeID end
    local startNode = findGeneratedNode({
        nodes = nodes
    }, entryNodeID) or nodes[1]

    if trimToString(startNode.dialogID) == "" then startNode.dialogID = startNode.id end
    for _, node in ipairs(nodes) do
        if trimToString(node.dialogID) == "" then node.dialogID = node.id end
    end
    return {
        PrintName = printName ~= "" and printName or dialogTypeID,
        Greeting = startNode and startNode.npcText or "",
        GeneratedDialog = {
            typeID = dialogTypeID,
            entryNodeID = entryNodeID,
            nodes = nodes
        }
    }
end

local function getGeneratedDialogTypeID(npc, preferredTypeID)
    local explicitTypeID = trimToString(preferredTypeID)
    if explicitTypeID ~= "" and not lia.dialog.isGeneratedDialogSelection(explicitTypeID) then return explicitTypeID end
    if IsValid(npc) then
        local currentTypeID = trimToString(npc:getNetVar("uniqueID", npc.uniqueID))
        if currentTypeID ~= "" then
            local currentData = lia.dialog.getNPCData and lia.dialog.getNPCData(currentTypeID) or nil
            if lia.dialog.isGeneratedDialogData(currentData) then return currentTypeID end
        end
        return "custom_dialog_" .. tostring(npc:EntIndex())
    end
    return explicitTypeID
end

local function createDefaultGeneratedDialogPayload(dialogTypeID, printName)
    return sanitizeGeneratedDialogPayload(dialogTypeID, {
        printName = trimToString(printName) ~= "" and printName or lia.dialog.generatedDialogSelectionName,
        generatedDialog = {
            typeID = dialogTypeID,
            entryNodeID = "node_1",
            nodes = {
                {
                    id = "node_1",
                    dialogID = "start",
                    npcText = "",
                    playerText = "",
                    children = {},
                    position = {
                        x = 60,
                        y = 60
                    }
                }
            }
        }
    })
end

--[[
    Purpose:
        Resolves the generated dialog type identifier to use for an NPC.

    Parameters:
        npc (Entity)
            The NPC entity being edited, when available.

        preferredTypeID (string|nil)
            Preferred dialog type identifier to use when it is not the custom dialog selection marker.

    Returns:
        string
            A valid generated dialog type identifier, an existing generated type, or an entity-based custom identifier.

    Example Usage:
        ```lua
        local dialogTypeID = lia.dialog.getGeneratedDialogTypeID(npc, preferredTypeID)
        ```

    Realm:
        Shared
]]
lia.dialog.getGeneratedDialogTypeID = getGeneratedDialogTypeID
if SERVER then
    --[[
    Purpose:
        Returns the registered server-side dialog data for an NPC dialog type.

    Parameters:
        npcID (string)
            The dialog type identifier to fetch.

    Returns:
        table|nil
            The registered dialog data when available, otherwise nil.

    Example Usage:
        ```lua
        local data = lia.dialog.getNPCData(npcID)
        ```

    Realm:
        Server
]]
    function lia.dialog.getNPCData(npcID)
        if lia.dialog.stored[npcID] then return lia.dialog.stored[npcID] end
        return nil
    end

    --[[
    Purpose:
        Returns the original server-side NPC dialog data before client sanitization.

    Parameters:
        npcID (string)
            The dialog type identifier to fetch.

    Returns:
        table|nil
            The original registered data table when available, otherwise nil.

    Example Usage:
        ```lua
        local originalData = lia.dialog.getOriginalNPCData(npcID)
        ```

    Realm:
        Server
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

    --[[
    Purpose:
        Persists generated dialog trees to Lilia data storage.

    Parameters:
        None.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.saveGeneratedDialogs()
        ```

    Realm:
        Server
]]
    function lia.dialog.saveGeneratedDialogs()
        local savedDialogs = {}
        for uniqueID, data in pairs(lia.dialog.originalData or {}) do
            if istable(data) and istable(data.GeneratedDialog) then
                savedDialogs[uniqueID] = {
                    printName = data.PrintName or uniqueID,
                    generatedDialog = deepCopy(data.GeneratedDialog)
                }
            end
        end

        lia.data.set("generated_dialog_trees", savedDialogs)
    end

    --[[
    Purpose:
        Loads generated dialog trees from Lilia data storage and registers them without immediately syncing.

    Parameters:
        None.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.loadGeneratedDialogs()
        ```

    Realm:
        Server
]]
    function lia.dialog.loadGeneratedDialogs()
        local storedDialogs = lia.data.get("generated_dialog_trees", {})
        if not istable(storedDialogs) then return end
        for uniqueID, payload in pairs(storedDialogs) do
            uniqueID = trimToString(uniqueID)
            if uniqueID == "" then continue end
            local sanitized = sanitizeGeneratedDialogPayload(uniqueID, payload)
            lia.dialog.registerNPC(uniqueID, sanitized, false)
        end
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

    local function resolveDialogValue(value)
        if istable(value) then
            local resolved = {}
            for k, v in pairs(value) do
                resolved[k] = resolveDialogValue(v)
            end
            return resolved
        end
        return lia.lang.resolveToken(value)
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
            local resolvedLabel = lia.lang.resolveToken(label)
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
                entry.Response = resolveDialogValue(entry.Response)
                if info.options and istable(info.options) and not entry.options then entry.options = sanitizeConversationTable(info.options) end
                out[resolvedLabel] = entry
            elseif not isfunction(info) then
                out[resolvedLabel] = resolveDialogValue(info)
            end
        end
        return out
    end

    local function resolveDialogData(data)
        if not istable(data) then return data end
        data.PrintName = lia.lang.resolveToken(data.PrintName)
        data.Greeting = resolveDialogValue(data.Greeting)
        if istable(data.Conversation) then data.Conversation = sanitizeConversationTable(data.Conversation) end
        return data
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

    --[[
    Purpose:
        Synchronizes sanitized dialog data to one client or all clients when their dialog data hash changes.

    Parameters:
        client (Player|nil)
            Optional target player. When nil, all players receive updated data if needed.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.syncToClients(client)
        ```

    Realm:
        Server
]]
    function lia.dialog.syncToClients(client)
        local targetClients = client and {client} or player.GetAll()
        for _, ply in ipairs(targetClients) do
            local filteredData = {}
            for uniqueID, data in pairs(lia.dialog.stored) do
                local filteredNPCData = table.Copy(data)
                if filteredNPCData.Conversation then filteredNPCData.Conversation = filterConversationOptions(filteredNPCData.Conversation, ply, nil) end
                filteredData[uniqueID] = resolveDialogData(filteredNPCData)
            end

            local dataHash = getDataHash(filteredData)
            local clientID = ply:SteamID64() or ply:SteamID()
            local lastHash = lia.dialog.clientHashes[clientID]
            if dataHash ~= lastHash then
                lia.dialog.clientHashes[clientID] = dataHash
                lia.net.writeBigTable(ply, "liaDialogSync", filteredData)
            end
        end
    end

    --[[
    Purpose:
        Synchronizes dialog data to all connected clients.

    Parameters:
        None.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.syncDialogs()
        ```

    Realm:
        Server
]]
    function lia.dialog.syncDialogs()
        lia.dialog.syncToClients()
    end

    --[[
    Purpose:
        Registers an NPC dialog type with conversation data or generated dialog data.

    Parameters:
        uniqueID (string)
            Unique dialog type identifier.

        data (table)
            Dialog data containing either `Conversation` or `GeneratedDialog`.

        shouldSync (boolean|nil)
            Set to false to skip immediate synchronization after registration.

    Returns:
        boolean
            True when registration succeeds, otherwise false.

    Example Usage:
        ```lua
        lia.dialog.registerNPC("example_npc", dialogData)
        ```

    Realm:
        Server
]]
    function lia.dialog.registerNPC(uniqueID, data, shouldSync)
        if not uniqueID or not data then return false end
        if not data.Conversation and not data.GeneratedDialog then return false end
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

    local function ensureGeneratedDialogType(npc, preferredTypeID, preferredPrintName)
        local dialogTypeID = getGeneratedDialogTypeID(npc, preferredTypeID)
        if dialogTypeID == "" then return nil end
        local existingData = lia.dialog.getNPCData(dialogTypeID)
        if lia.dialog.isGeneratedDialogData(existingData) then return dialogTypeID, existingData, false end
        local generatedDialogData = createDefaultGeneratedDialogPayload(dialogTypeID, preferredPrintName)
        if not lia.dialog.registerNPC(dialogTypeID, generatedDialogData, false) then return nil end
        lia.dialog.saveGeneratedDialogs()
        lia.dialog.syncToClients()
        return dialogTypeID, generatedDialogData, true
    end

    --[[
    Purpose:
        Ensures an NPC has a generated dialog type registered, creating a default generated dialog tree when needed.

    Parameters:
        npc (Entity)
            The NPC entity being configured.

        preferredTypeID (string|nil)
            Preferred generated dialog type identifier.

        preferredPrintName (string|nil)
            Optional display name for newly created generated dialog data.

    Returns:
        string|nil, table|nil, boolean|nil
            The dialog type ID, the generated dialog data, and whether a new type was created. Returns nil if a type cannot be resolved or registered.

    Example Usage:
        ```lua
        local dialogTypeID, data, created = lia.dialog.ensureGeneratedDialogType(npc, preferredTypeID, printName)
        ```

    Realm:
        Server
]]
    lia.dialog.ensureGeneratedDialogType = ensureGeneratedDialogType
    --[[
    Purpose:
        Validates, filters, sanitizes, and opens an NPC dialog for a player.

    Parameters:
        client (Player)
            The player opening the dialog.

        npc (Entity)
            The NPC entity being opened.

        npcID (string)
            The dialog type identifier assigned to the NPC.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.openDialog(client, npc, npcID)
        ```

    Realm:
        Server
]]
    function lia.dialog.openDialog(client, npc, npcID)
        local npcData = lia.dialog.getOriginalNPCData(npcID)
        if not npcData then
            client:notifyWarningLocalized("npcTypeNotRegistered")
            lia.dialog.syncToClients(client)
            timer.Simple(0.1, function()
                if not IsValid(client) or not IsValid(npc) then return end
                local npcOptions = lia.dialog.getCompatibleDialogOptions(npc)
                if not table.IsEmpty(npcOptions) then
                    client.npcEntity = npc
                    net.Start("liaRequestNPCSelection")
                    net.WriteEntity(npc)
                    net.WriteTable(npcOptions)
                    net.Send(client)
                else
                    client:notifyErrorLocalized("noNPCTypesAvailable")
                end
            end)
            return
        end

        if not lia.dialog.isDialogCompatibleWithEntity(npc, npcData) then
            client:notifyError("This entity cannot use the selected dialog type.")
            return
        end

        local filteredData = table.Copy(npcData)
        if lia.dialog.isGeneratedDialogData(filteredData) then
            filteredData.Conversation = nil
        else
            filteredData.GeneratedDialog = nil
        end

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
        filteredData = resolveDialogData(filteredData)
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
        local canManageProperties = client:hasPrivilege("canManageProperties")
        lia.debug("[Permissions]", "Permission Check for dialog liaOpenNpcDialog payload", "hasPrivilege(canManageProperties)=", tostring(canManageProperties), "finalResult=", tostring(canManageProperties))
        net.WriteBool(canManageProperties)
        net.WriteTable(filteredData)
        net.Send(client)
    end
else
    --[[
    Purpose:
        Returns the clientside synchronized dialog data for an NPC dialog type.

    Parameters:
        npcID (string)
            The dialog type identifier to fetch.

    Returns:
        table|nil
            The synchronized dialog data when available, otherwise nil.

    Example Usage:
        ```lua
        local data = lia.dialog.getNPCData(npcID)
        ```

    Realm:
        Client
]]
    function lia.dialog.getNPCData(npcID)
        if lia.dialog.stored[npcID] then return lia.dialog.stored[npcID] end
        return nil
    end

    --[[
    Purpose:
        Submits an NPC configuration payload from the client to the server.

    Parameters:
        configID (string)
            The configuration identifier to apply.

        npc (Entity)
            The NPC entity being configured.

        payload (table|nil)
            Configuration data to send to the server.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.submitConfiguration("appearance", npc, customData)
        ```

    Realm:
        Client
]]
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
        Opens the NPC customization interface for appearance, animation, and dialog type selection.

    Parameters:
        npc (Entity)
            The NPC entity to customize.

        configID (string|nil)
            Configuration identifier to submit when applying changes. Defaults to `appearance`.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.openCustomizationUI(npc, "appearance")
        ```

    Realm:
        Client
]]
    function lia.dialog.openCustomizationUI(npc, configID)
        configID = configID or "appearance"
        if not IsValid(npc) then return end
        local frame = vgui.Create("liaFrame")
        frame:SetTitle(L("customizeNPC"))
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
        nameLabel:SetText(L("npcNameLabel"))
        nameLabel:SetTall(20)
        nameLabel:DockMargin(0, 5, 0, 5)
        local nameEntry = vgui.Create("liaEntry", scroll)
        nameEntry:Dock(TOP)
        nameEntry:SetTall(25)
        nameEntry:SetValue(existingData.name or "NPC")
        nameEntry:DockMargin(0, 0, 0, 10)
        local modelLabel = vgui.Create("DLabel", scroll)
        modelLabel:Dock(TOP)
        modelLabel:SetText(L("modelPathLabel"))
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

                    LocalPlayer():notifySuccessLocalized("npcModelUpdated", value)
                end
            end
        end

        if hasBodygroups then
            local bodygroupLabel = vgui.Create("DLabel", scroll)
            bodygroupLabel:Dock(TOP)
            bodygroupLabel:SetText(L("bodygroups") .. ":")
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
            skinLabel:SetText(L("skin") .. ":")
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
            animationLabel:SetText(L("animation") .. ":")
            animationLabel:SetTall(20)
            animationLabel:DockMargin(0, 5, 0, 5)
            animationCombo = vgui.Create("liaComboBox", scroll)
            animationCombo:Dock(TOP)
            animationCombo:SetTall(25)
            animationCombo:DockMargin(0, 0, 0, 10)
            animationCombo:SetValue(selectedAnimation == "auto" and L("npcAnimationAuto") or selectedAnimation)
            animationCombo:AddChoice(L("npcAnimationAuto"), "auto")
            for _, animName in ipairs(availableAnimations) do
                animationCombo:AddChoice(animName, animName)
            end

            animationCombo:ChooseOptionData(selectedAnimation)
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
            refreshBtn:SetText(L("refreshAnimationList"))
            refreshBtn.DoClick = function()
                if IsValid(npc) then
                    local sequences = npc:GetSequenceList()
                    if sequences and #sequences > 0 then
                        animationCombo:Clear()
                        animationCombo:AddChoice(L("npcAnimationAuto"), "auto")
                        for _, animName in ipairs(sequences) do
                            animationCombo:AddChoice(animName, animName)
                        end

                        animationCombo:ChooseOptionData(selectedAnimation)
                        LocalPlayer():notifySuccessLocalized("animationListRefreshed", #sequences)
                    else
                        LocalPlayer():notifyErrorLocalized("noAnimationsFoundForModel")
                    end
                end
            end
        else
            local noAnimLabel = vgui.Create("DLabel", scroll)
            noAnimLabel:Dock(TOP)
            noAnimLabel:SetText(L("noAnimationsFoundForModel"))
            noAnimLabel:SetTall(20)
            noAnimLabel:DockMargin(0, 5, 0, 5)
            noAnimLabel:SetTextColor(Color(255, 100, 100))
            local refreshAnimBtn = vgui.Create("liaButton", scroll)
            refreshAnimBtn:Dock(TOP)
            refreshAnimBtn:SetTall(25)
            refreshAnimBtn:DockMargin(0, 5, 0, 10)
            refreshAnimBtn:SetText(L("tryRefreshAnimations"))
            refreshAnimBtn.DoClick = function()
                if IsValid(npc) then
                    local sequences = npc:GetSequenceList()
                    if sequences and #sequences > 0 then
                        LocalPlayer():notifySuccessLocalized("animationsFoundReopenMenu", #sequences)
                    else
                        LocalPlayer():notifyErrorLocalized("stillNoAnimationsFound")
                    end
                end
            end
        end

        local canConfigureDialogType = lia.dialog.isDialogNPCEntity(npc)
        local currentType = npc:getNetVar("uniqueID", npc.uniqueID) or "none"
        local currentUsesGeneratedDialog = canConfigureDialogType and lia.dialog.entityUsesGeneratedDialog(npc) or false
        local selectedDialogType = currentUsesGeneratedDialog and lia.dialog.generatedDialogSelectionID or currentType
        local dialogTypeCombo = nil
        if canConfigureDialogType then
            local dialogTypeLabel = vgui.Create("DLabel", scroll)
            dialogTypeLabel:Dock(TOP)
            dialogTypeLabel:SetText(L("dialogTypeLabel"))
            dialogTypeLabel:SetTall(20)
            dialogTypeLabel:DockMargin(0, 15, 0, 5)
            dialogTypeCombo = vgui.Create("liaComboBox", scroll)
            dialogTypeCombo:Dock(TOP)
            dialogTypeCombo:SetTall(30)
            dialogTypeCombo:DockMargin(0, 0, 0, 10)
            dialogTypeCombo:AddChoice(L("noneNoDialog"), "none")
            for _, option in ipairs(lia.dialog.getCompatibleDialogOptions(npc)) do
                dialogTypeCombo:AddChoice(option[1], option[2])
            end

            dialogTypeCombo:ChooseOptionData(selectedDialogType or "none")
            dialogTypeCombo:FinishAddingOptions()
            dialogTypeCombo:PostInit()
            dialogTypeCombo.OnSelect = function(_, _, value) selectedDialogType = value end
            local customDialogBtn = vgui.Create("liaButton", scroll)
            customDialogBtn:Dock(TOP)
            customDialogBtn:SetTall(35)
            customDialogBtn:SetText("Create / Edit Custom Dialog")
            customDialogBtn:DockMargin(0, 0, 0, 10)
            customDialogBtn.DoClick = function()
                frame:Close()
                lia.dialog.openNodeEditor(npc)
            end
        end

        local isCarDealerNPC = canConfigureDialogType and (currentType == "cardealer" or (IsValid(npc) and npc.uniqueID == "cardealer"))
        if isCarDealerNPC and lia.cardealer and isfunction(lia.cardealer.openCategoryConfigUI) then
            local categoriesBtn = vgui.Create("liaButton", scroll)
            categoriesBtn:Dock(TOP)
            categoriesBtn:SetTall(35)
            categoriesBtn:SetText("Car Dealer Categories")
            categoriesBtn:DockMargin(0, 0, 0, 10)
            categoriesBtn.DoClick = function()
                frame:Close()
                lia.cardealer.openCategoryConfigUI(npc)
            end
        end

        local applyBtn = vgui.Create("liaButton", scroll)
        applyBtn:Dock(TOP)
        applyBtn:SetTall(35)
        applyBtn:SetText(L("applyCustomizations"))
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
            if canConfigureDialogType and IsValid(dialogTypeCombo) then
                local resolvedSelectedDialogType = selectedDialogType or dialogTypeCombo:GetValue() or "none"
                local currentSelectionType = currentUsesGeneratedDialog and lia.dialog.generatedDialogSelectionID or currentType
                if resolvedSelectedDialogType ~= currentSelectionType then
                    lia.dialog.submitConfiguration("dialog_type", npc, {
                        dialogType = resolvedSelectedDialogType
                    })
                end
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
            otherLabel:SetText(L("otherConfigurations"))
            otherLabel:SetTall(20)
            otherLabel:SetTextColor(color_white)
            otherLabel:DockMargin(0, 5, 0, 5)
            for _, config in ipairs(otherConfigs) do
                if isfunction(config.onOpen) then
                    local configBtn = vgui.Create("liaButton", scroll)
                    configBtn:Dock(TOP)
                    configBtn:SetTall(30)
                    configBtn:SetText(lia.lang.resolveToken(config.name or config.id) or L("configuration"))
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
        cancelBtn:SetText(L("cancel"))
        cancelBtn:DockMargin(0, 5, 0, 10)
        cancelBtn.DoClick = function() frame:Close() end
    end

    local function cloneGeneratedDialogForEditor(sourceData, fallbackTypeID)
        local source = istable(sourceData) and istable(sourceData.GeneratedDialog) and sourceData.GeneratedDialog or {}
        local copy = {
            typeID = trimToString(source.typeID),
            entryNodeID = trimToString(source.entryNodeID),
            nodes = {}
        }

        if copy.typeID == "" then copy.typeID = fallbackTypeID end
        for index, node in ipairs(source.nodes or {}) do
            copy.nodes[index] = {
                id = trimToString(node.id),
                dialogID = trimToString(node.dialogID),
                npcText = trimToString(node.npcText),
                playerText = trimToString(node.playerText),
                waypoint = trimToString(node.waypoint),
                swepClass = trimToString(node.swepClass),
                factionRequirement = trimToString(node.factionRequirement),
                soundPath = trimToString(node.soundPath),
                requirementMessage = trimToString(node.requirementMessage),
                children = table.Copy(node.children or {}),
                position = {
                    x = tonumber(node.position and node.position.x) or 40 + (index - 1) * 40,
                    y = tonumber(node.position and node.position.y) or 40 + (index - 1) * 30
                }
            }

            if copy.nodes[index].id == "" then copy.nodes[index].id = "node_" .. index end
        end

        if #copy.nodes == 0 then
            copy.nodes[1] = {
                id = "node_1",
                dialogID = "start",
                npcText = "",
                playerText = "",
                waypoint = "",
                swepClass = "",
                factionRequirement = "",
                soundPath = "",
                requirementMessage = "",
                children = {},
                position = {
                    x = 60,
                    y = 60
                }
            }

            copy.entryNodeID = "node_1"
        elseif copy.entryNodeID == "" then
            copy.entryNodeID = copy.nodes[1].id
        end
        return copy
    end

    --[[
    Purpose:
        Opens the clientside generated dialog node editor for an NPC.

    Parameters:
        npc (Entity)
            The NPC entity whose generated dialog tree should be edited.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.openNodeEditor(npc)
        ```

    Realm:
        Client
]]
    function lia.dialog.openNodeEditor(npc)
        if not IsValid(npc) then return end
        local currentTypeID = trimToString(npc:getNetVar("uniqueID", npc.uniqueID))
        local fallbackTypeID = getGeneratedDialogTypeID(npc, currentTypeID)
        local existingData = lia.dialog.getNPCData(fallbackTypeID)
        local editorData = cloneGeneratedDialogForEditor(existingData, fallbackTypeID)
        local editorPrintName = trimToString(existingData and existingData.PrintName or fallbackTypeID)
        local frame = vgui.Create("liaFrame")
        frame:SetTitle("Dialog NPC Generator")
        frame:SetSize(math.min(ScrW() - 60, 1680), math.min(ScrH() - 60, 940))
        frame:Center()
        frame:MakePopup()
        frame:ShowCloseButton(true)
        local frameW = frame:GetWide()
        local entryHeight = 50
        local buttonHeight = 38
        local toolbar = frame:Add("DPanel")
        toolbar:Dock(TOP)
        toolbar:SetTall(entryHeight * 2 + 42)
        toolbar:DockMargin(10, 10, 10, 0)
        toolbar:SetPaintBackground(false)
        local typeEntry = vgui.Create("liaEntry", toolbar)
        typeEntry:Dock(TOP)
        typeEntry:SetTitle("Dialog Type ID")
        typeEntry:SetPlaceholder("example_npc_dialog")
        typeEntry:SetValue(editorData.typeID)
        typeEntry:SetTall(entryHeight)
        typeEntry:DockMargin(0, 0, 0, 8)
        local printNameEntry = vgui.Create("liaEntry", toolbar)
        printNameEntry:Dock(TOP)
        printNameEntry:SetTitle("Display Name")
        printNameEntry:SetPlaceholder("Example NPC Dialog")
        printNameEntry:SetValue(editorPrintName ~= "" and editorPrintName or editorData.typeID)
        printNameEntry:SetTall(entryHeight)
        printNameEntry:DockMargin(0, 0, 0, 8)
        local helpLabel = vgui.Create("DLabel", toolbar)
        helpLabel:Dock(TOP)
        helpLabel:SetTall(18)
        helpLabel:SetText("Add nodes, connect them, pick a start node, then save.")
        helpLabel:SetTextColor(lia.color.theme.text or color_white)
        local actionBar = frame:Add("DPanel")
        actionBar:Dock(TOP)
        actionBar:SetTall(buttonHeight)
        actionBar:DockMargin(10, 8, 10, 0)
        actionBar:SetPaintBackground(false)
        local body = frame:Add("DPanel")
        body:Dock(FILL)
        body:DockMargin(10, 10, 10, 10)
        body:SetPaintBackground(false)
        local canvas = body:Add("DPanel")
        canvas:Dock(FILL)
        canvas.nodes = {}
        canvas:DockMargin(0, 0, 10, 0)
        local sidebar = body:Add("DPanel")
        sidebar:Dock(RIGHT)
        sidebar:SetWide(math.Clamp(math.floor(frameW * 0.28), 420, 520))
        sidebar:SetPaintBackground(false)
        local inspector = sidebar:Add("liaScrollPanel")
        inspector:Dock(FILL)
        inspector:DockMargin(0, 0, 0, 0)
        canvas.Paint = function(panel, w, h)
            lia.derma.rect(0, 0, w, h):Rad(12):Color(Color(22, 24, 30, 245)):Shape(lia.derma.SHAPE_IOS):Draw()
            surface.SetDrawColor(55, 60, 72, 150)
            for x = 0, w, 48 do
                surface.DrawLine(x, 0, x, h)
            end

            for y = 0, h, 48 do
                surface.DrawLine(0, y, w, y)
            end

            surface.SetDrawColor(116, 185, 255, 170)
            for _, node in ipairs(editorData.nodes) do
                local startPanel = panel.nodes[node.id]
                if not IsValid(startPanel) then continue end
                for _, childID in ipairs(node.children or {}) do
                    local endPanel = panel.nodes[childID]
                    if IsValid(endPanel) then
                        local startX = startPanel.x + startPanel:GetWide()
                        local startY = startPanel.y + startPanel:GetTall() * 0.5
                        local endX = endPanel.x
                        local endY = endPanel.y + endPanel:GetTall() * 0.5
                        surface.DrawLine(startX, startY, endX, endY)
                    end
                end
            end
        end

        local selectedNodeID
        local pendingConnectionID
        local fieldEntries = {}
        local linkedChildrenPanel
        local factionSummaryLabel
        local nodeCounter = #editorData.nodes
        local refreshCanvas
        local refreshInspector
        local function getNodeByID(nodeID)
            return findGeneratedNode(editorData, nodeID)
        end

        local function syncTypeID()
            editorData.typeID = trimToString(typeEntry:GetValue())
            editorPrintName = trimToString(printNameEntry:GetValue())
            if editorPrintName == "" then editorPrintName = editorData.typeID end
        end

        local function createField(parent, title, key, placeholder)
            local entry = vgui.Create("liaEntry", parent)
            entry:Dock(TOP)
            entry:SetTall(entryHeight)
            entry:SetTitle(title)
            entry:SetPlaceholder(placeholder or "")
            entry:DockMargin(0, 0, 0, 8)
            fieldEntries[key] = entry
            return entry
        end

        local function openFactionSelector(node)
            if not istable(node) then return end
            local selector = vgui.Create("liaFrame")
            selector:SetTitle("Allowed Factions")
            selector:SetSize(math.min(ScrW() - 120, 420), math.min(ScrH() - 120, 560))
            selector:Center()
            selector:MakePopup()
            selector:ShowCloseButton(true)
            local selectedTokens = {}
            for _, token in ipairs(parseFactionRequirementTokens(node.factionRequirement)) do
                selectedTokens[string.lower(token)] = token
            end

            local info = selector:Add("DLabel")
            info:Dock(TOP)
            info:SetTall(38)
            info:SetWrap(true)
            info:SetAutoStretchVertical(true)
            info:SetText("Tick the factions that are allowed to use this reply. Leave all unchecked to allow every faction.")
            info:SetTextColor(lia.color.theme.text or color_white)
            info:DockMargin(10, 10, 10, 8)
            local list = selector:Add("liaScrollPanel")
            list:Dock(FILL)
            list:DockMargin(10, 0, 10, 10)
            local factions = {}
            for _, faction in pairs(lia.faction.teams or {}) do
                factions[#factions + 1] = faction
            end

            table.sort(factions, function(a, b) return string.lower(tostring(a.name or a.uniqueID or "")) < string.lower(tostring(b.name or b.uniqueID or "")) end)
            for _, faction in ipairs(factions) do
                local row = list:Add("DPanel")
                row:Dock(TOP)
                row:SetTall(42)
                row:DockMargin(0, 0, 0, 8)
                row.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(35, 38, 48, 240)):Shape(lia.derma.SHAPE_IOS):Draw() end
                local text = vgui.Create("DLabel", row)
                text:Dock(FILL)
                text:DockMargin(12, 0, 0, 0)
                text:SetText(string.format("%s (%s)", faction.name or faction.uniqueID, faction.uniqueID or faction.index))
                text:SetTextColor(color_white)
                local checkbox = row:Add("liaCheckbox")
                checkbox:Dock(RIGHT)
                checkbox:SetWide(72)
                checkbox:DockMargin(8, 8, 8, 8)
                checkbox:SetChecked(selectedTokens[string.lower(tostring(faction.uniqueID or ""))] ~= nil)
                checkbox.OnChange = function(_, checked)
                    local uniqueID = trimToString(faction.uniqueID)
                    local normalized = string.lower(uniqueID)
                    if checked then
                        selectedTokens[normalized] = uniqueID
                    else
                        selectedTokens[normalized] = nil
                    end

                    local ordered = {}
                    for _, sortedFaction in ipairs(factions) do
                        local key = string.lower(trimToString(sortedFaction.uniqueID))
                        if selectedTokens[key] then ordered[#ordered + 1] = selectedTokens[key] end
                    end

                    node.factionRequirement = serializeFactionRequirementTokens(ordered)
                    if IsValid(factionSummaryLabel) then factionSummaryLabel:SetText("Allowed Factions: " .. getFactionRequirementDisplay(node.factionRequirement)) end
                end

                row.DoClick = function() checkbox:SetChecked(not checkbox:GetChecked()) end
            end

            local actions = selector:Add("DPanel")
            actions:Dock(BOTTOM)
            actions:SetTall(42)
            actions:DockMargin(10, 0, 10, 10)
            actions:SetPaintBackground(false)
            local clearButton = actions:Add("liaButton")
            clearButton:Dock(LEFT)
            clearButton:SetWide(120)
            clearButton:SetText("Clear All")
            clearButton.DoClick = function()
                node.factionRequirement = ""
                selector:Close()
                refreshInspector()
            end

            local doneButton = actions:Add("liaButton")
            doneButton:Dock(RIGHT)
            doneButton:SetWide(120)
            doneButton:SetText("Done")
            doneButton.DoClick = function()
                selector:Close()
                refreshInspector()
            end
        end

        local function buildGeneratedDialogData()
            syncTypeID()
            local dialogTypeID = trimToString(editorData.typeID)
            if dialogTypeID == "" then dialogTypeID = "example_dialog" end
            return dialogTypeID
        end

        refreshInspector = function()
            if not IsValid(inspector) then return end
            inspector:Clear()
            fieldEntries = {}
            factionSummaryLabel = nil
            local summary = vgui.Create("DLabel", inspector)
            summary:Dock(TOP)
            summary:SetWrap(true)
            summary:SetAutoStretchVertical(true)
            summary:SetTextColor(lia.color.theme.text or color_white)
            summary:SetText("Selected node fields stay minimal: core text, optional waypoint, SWEP, faction requirement, sound, and requirement fail message.")
            summary:SetTall(48)
            summary:DockMargin(0, 0, 0, 12)
            if not selectedNodeID then
                local emptyLabel = vgui.Create("DLabel", inspector)
                emptyLabel:Dock(TOP)
                emptyLabel:SetTall(24)
                emptyLabel:SetText("Select a node to edit it.")
                emptyLabel:SetTextColor(Color(190, 190, 190))
                return
            end

            local node = getNodeByID(selectedNodeID)
            if not node then return end
            local stateLabel = vgui.Create("DLabel", inspector)
            stateLabel:Dock(TOP)
            stateLabel:SetTall(24)
            stateLabel:SetText((editorData.entryNodeID == node.id and "Start Node" or "Dialog Node") .. "  |  Internal ID: " .. node.id)
            stateLabel:SetTextColor(Color(150, 210, 255))
            stateLabel:DockMargin(0, 0, 0, 8)
            createField(inspector, "Dialog ID", "dialogID", "start")
            createField(inspector, "NPC Text / Dialog Text", "npcText", "NPC line shown when this node is reached")
            createField(inspector, "Player Response Text", "playerText", "Button text the player clicks")
            createField(inspector, "Set Waypoint", "waypoint", "Waypoint name or Vector(x, y, z) from printpos")
            createField(inspector, "Give Weapon (SWEP)", "swepClass", "weapon_pistol")
            createField(inspector, "Sound Path", "soundPath", "vo/npc/example.wav")
            createField(inspector, "Requirement Dialog Message", "requirementMessage", "You are not allowed to access this dialog.")
            for key, entry in pairs(fieldEntries) do
                entry:SetValue(node[key] or "")
                entry.OnTextChanged = function(_, value)
                    node[key] = trimToString(value)
                    refreshCanvas()
                end
            end

            local factionButton = vgui.Create("liaButton", inspector)
            factionButton:Dock(TOP)
            factionButton:SetTall(34)
            factionButton:SetText("Select Factions")
            factionButton:DockMargin(0, 0, 0, 6)
            factionButton.DoClick = function() openFactionSelector(node) end
            factionSummaryLabel = vgui.Create("DLabel", inspector)
            factionSummaryLabel:Dock(TOP)
            factionSummaryLabel:SetWrap(true)
            factionSummaryLabel:SetAutoStretchVertical(true)
            factionSummaryLabel:SetText("Allowed Factions: " .. getFactionRequirementDisplay(node.factionRequirement))
            factionSummaryLabel:SetTextColor(Color(190, 190, 190))
            factionSummaryLabel:DockMargin(0, 0, 0, 8)
            local startButton = vgui.Create("liaButton", inspector)
            startButton:Dock(TOP)
            startButton:SetTall(34)
            startButton:SetText("Set As Start Node")
            startButton:DockMargin(0, 4, 0, 8)
            startButton.DoClick = function()
                editorData.entryNodeID = node.id
                refreshCanvas()
                refreshInspector()
            end

            local linkedLabel = vgui.Create("DLabel", inspector)
            linkedLabel:Dock(TOP)
            linkedLabel:SetTall(22)
            linkedLabel:SetText("Connected Child Nodes")
            linkedLabel:SetTextColor(lia.color.theme.text or color_white)
            linkedLabel:DockMargin(0, 8, 0, 6)
            linkedChildrenPanel = vgui.Create("DPanel", inspector)
            linkedChildrenPanel:Dock(TOP)
            linkedChildrenPanel:SetPaintBackground(false)
            linkedChildrenPanel.PerformLayout = function(panel) panel:SizeToChildren(false, true) end
            for _, childID in ipairs(node.children or {}) do
                local childNode = getNodeByID(childID)
                local row = vgui.Create("DPanel", linkedChildrenPanel)
                row:Dock(TOP)
                row:SetTall(32)
                row:DockMargin(0, 0, 0, 6)
                row.Paint = function(_, w, h) lia.derma.rect(0, 0, w, h):Rad(8):Color(Color(35, 38, 48, 240)):Shape(lia.derma.SHAPE_IOS):Draw() end
                local label = vgui.Create("DLabel", row)
                label:Dock(FILL)
                label:DockMargin(10, 0, 0, 0)
                label:SetText((childNode and childNode.dialogID or childID) .. " -> " .. (childNode and childNode.playerText or ""))
                label:SetTextColor(color_white)
                local removeButton = vgui.Create("liaButton", row)
                removeButton:Dock(RIGHT)
                removeButton:SetWide(78)
                removeButton:SetText("Remove")
                removeButton.DoClick = function()
                    for index = #node.children, 1, -1 do
                        if node.children[index] == childID then table.remove(node.children, index) end
                    end

                    refreshCanvas()
                    refreshInspector()
                end
            end
        end

        typeEntry.OnTextChanged = function() syncTypeID() end
        printNameEntry.OnTextChanged = function() syncTypeID() end
        refreshCanvas = function()
            canvas:Clear()
            canvas.nodes = {}
            for _, node in ipairs(editorData.nodes) do
                local nodePanel = vgui.Create("DButton", canvas)
                nodePanel:SetText("")
                nodePanel:SetSize(250, 118)
                nodePanel:SetPos(node.position.x, node.position.y)
                nodePanel.x = node.position.x
                nodePanel.y = node.position.y
                nodePanel.dragging = false
                nodePanel.Paint = function(panel, w, h)
                    local isSelected = selectedNodeID == node.id
                    local isStart = editorData.entryNodeID == node.id
                    local bgColor = isSelected and Color(52, 92, 140, 245) or Color(33, 36, 44, 245)
                    lia.derma.rect(0, 0, w, h):Rad(10):Color(bgColor):Shape(lia.derma.SHAPE_IOS):Draw()
                    if isStart then lia.derma.rect(0, 0, w, 6):Radii(10, 10, 0, 0):Color(Color(116, 185, 255)):Draw() end
                    draw.SimpleText(node.dialogID ~= "" and node.dialogID or node.id, "LiliaFont.20b", 12, 16, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(node.playerText ~= "" and node.playerText or "Player response text", "LiliaFont.18", 12, 44, Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    draw.SimpleText(node.npcText ~= "" and node.npcText or "NPC text", "LiliaFont.16", 12, 72, Color(175, 190, 210), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end

                local connectButton = vgui.Create("liaButton", nodePanel)
                connectButton:SetText(utf8.char(8594))
                connectButton:SetSize(26, 26)
                connectButton:SetPos(nodePanel:GetWide() - 34, math.floor(nodePanel:GetTall() * 0.5) - 13)
                connectButton.DoClick = function()
                    selectedNodeID = node.id
                    pendingConnectionID = pendingConnectionID == node.id and nil or node.id
                    refreshCanvas()
                    refreshInspector()
                end

                connectButton.Paint = function(panel, w, h)
                    local active = pendingConnectionID == node.id
                    lia.derma.rect(0, 0, w, h):Rad(13):Color(active and Color(116, 185, 255) or Color(50, 59, 73, 240)):Shape(lia.derma.SHAPE_IOS):Draw()
                    draw.SimpleText(utf8.char(8594), "LiliaFont.20b", w * 0.5, h * 0.5 - 1, active and Color(12, 28, 35) or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                nodePanel.OnMousePressed = function(panel, mouseCode)
                    if mouseCode ~= MOUSE_LEFT then return end
                    selectedNodeID = node.id
                    if pendingConnectionID and pendingConnectionID ~= node.id then
                        local sourceNode = getNodeByID(pendingConnectionID)
                        if sourceNode and not table.HasValue(sourceNode.children, node.id) then sourceNode.children[#sourceNode.children + 1] = node.id end
                        pendingConnectionID = nil
                        refreshCanvas()
                        refreshInspector()
                        return
                    end

                    panel.dragging = true
                    local localX, localY = panel:CursorPos()
                    panel.dragOffsetX = localX
                    panel.dragOffsetY = localY
                    refreshInspector()
                end

                nodePanel.OnMouseReleased = function(panel) panel.dragging = false end
                nodePanel.Think = function(panel)
                    if not panel.dragging then return end
                    if not input.IsMouseDown(MOUSE_LEFT) then
                        panel.dragging = false
                        return
                    end

                    local mouseX, mouseY = canvas:CursorPos()
                    local newX = math.Clamp(mouseX - (panel.dragOffsetX or 0), 0, math.max(canvas:GetWide() - panel:GetWide(), 0))
                    local newY = math.Clamp(mouseY - (panel.dragOffsetY or 0), 0, math.max(canvas:GetTall() - panel:GetTall(), 0))
                    panel:SetPos(newX, newY)
                    panel.x = newX
                    panel.y = newY
                    node.position.x = newX
                    node.position.y = newY
                end

                nodePanel.DoClick = function()
                    selectedNodeID = node.id
                    refreshCanvas()
                    refreshInspector()
                end

                canvas.nodes[node.id] = nodePanel
            end

            canvas:InvalidateLayout(true)
            canvas:InvalidateParent(true)
        end

        local function makeActionButton(text, onClick)
            local button = vgui.Create("liaButton", actionBar)
            button:Dock(LEFT)
            button:SetWide(132)
            button:DockMargin(0, 0, 8, 0)
            button:SetText(text)
            button.DoClick = onClick
            return button
        end

        makeActionButton("Add Node", function()
            nodeCounter = nodeCounter + 1
            local newNode = {
                id = "node_" .. nodeCounter,
                dialogID = "dialog_" .. nodeCounter,
                npcText = "",
                playerText = "",
                waypoint = "",
                swepClass = "",
                factionRequirement = "",
                soundPath = "",
                requirementMessage = "",
                children = {},
                position = {
                    x = 40 + (#editorData.nodes % 5) * 30,
                    y = 40 + (#editorData.nodes % 5) * 30
                }
            }

            editorData.nodes[#editorData.nodes + 1] = newNode
            selectedNodeID = newNode.id
            if not editorData.entryNodeID or editorData.entryNodeID == "" then editorData.entryNodeID = newNode.id end
            refreshCanvas()
            refreshInspector()
        end)

        makeActionButton("Create Example", function()
            editorData.typeID = "example_guard_dialog"
            typeEntry:SetValue(editorData.typeID)
            editorPrintName = "Example Guard Dialog"
            printNameEntry:SetValue(editorPrintName)
            editorData.entryNodeID = "node_1"
            editorData.nodes = {
                {
                    id = "node_1",
                    dialogID = "start",
                    npcText = "Halt. State your business.",
                    playerText = "Start conversation",
                    waypoint = "",
                    swepClass = "",
                    factionRequirement = "",
                    soundPath = "",
                    requirementMessage = "",
                    children = {"node_2", "node_3", "node_4"},
                    position = {
                        x = 72,
                        y = 90
                    }
                },
                {
                    id = "node_2",
                    dialogID = "citizen_path",
                    npcText = "You may pass. Stay out of trouble.",
                    playerText = "I'm just passing through.",
                    waypoint = "Gate",
                    swepClass = "",
                    factionRequirement = "citizen",
                    soundPath = "",
                    requirementMessage = "This guard does not trust your faction.",
                    children = {},
                    position = {
                        x = 360,
                        y = 70
                    }
                },
                {
                    id = "node_3",
                    dialogID = "armory_path",
                    npcText = "Take this and report to the wall.",
                    playerText = "Do you have a weapon for me?",
                    waypoint = "Vector(0, 0, 0)",
                    swepClass = "weapon_pistol",
                    factionRequirement = "guard",
                    soundPath = "buttons/button14.wav",
                    requirementMessage = "Only guards can receive armory equipment.",
                    children = {},
                    position = {
                        x = 360,
                        y = 230
                    }
                },
                {
                    id = "node_4",
                    dialogID = "goodbye",
                    npcText = "Move along, then.",
                    playerText = "Never mind. Goodbye.",
                    waypoint = "",
                    swepClass = "",
                    factionRequirement = "",
                    soundPath = "",
                    requirementMessage = "",
                    children = {},
                    position = {
                        x = 360,
                        y = 390
                    }
                }
            }

            nodeCounter = 4
            selectedNodeID = "node_1"
            pendingConnectionID = nil
            refreshCanvas()
            refreshInspector()
        end)

        makeActionButton("Delete Node", function()
            if not selectedNodeID then return end
            for index = #editorData.nodes, 1, -1 do
                if editorData.nodes[index].id == selectedNodeID then
                    table.remove(editorData.nodes, index)
                    break
                end
            end

            for _, node in ipairs(editorData.nodes) do
                for index = #node.children, 1, -1 do
                    if node.children[index] == selectedNodeID then table.remove(node.children, index) end
                end
            end

            if editorData.entryNodeID == selectedNodeID then editorData.entryNodeID = editorData.nodes[1] and editorData.nodes[1].id or "" end
            pendingConnectionID = nil
            selectedNodeID = editorData.nodes[1] and editorData.nodes[1].id or nil
            refreshCanvas()
            refreshInspector()
        end)

        makeActionButton("Save Dialog", function()
            local dialogTypeID = buildGeneratedDialogData()
            if dialogTypeID == "" then
                LocalPlayer():notifyError("Dialog Type ID is required.")
                return
            end

            if #editorData.nodes == 0 then
                LocalPlayer():notifyError("Create at least one node before saving.")
                return
            end

            lia.dialog.submitConfiguration("dialog_editor", npc, {
                dialogTypeID = dialogTypeID,
                printName = editorPrintName,
                generatedDialog = editorData
            })

            frame:Close()
        end)

        selectedNodeID = editorData.entryNodeID
        refreshCanvas()
        refreshInspector()
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
        Returns NPC configuration entries visible to a player for the selected NPC.

    Parameters:
        ply (Player)
            The player viewing the configuration menu.

        npc (Entity)
            The NPC entity being configured.

        npcID (string|nil)
            Optional dialog type identifier associated with the NPC.

    Returns:
        table
            A sorted list of visible configuration tables.

    Example Usage:
        ```lua
        local configurations = lia.dialog.getAvailableConfigurations(LocalPlayer(), npc, npcID)
        ```

    Realm:
        Client
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
        Opens the best available NPC configuration UI and queues secondary configuration buttons when needed.

    Parameters:
        npc (Entity)
            The NPC entity being configured.

        npcID (string|nil)
            Optional dialog type identifier associated with the NPC.

    Returns:
        nil
            This function does not return a value.

    Example Usage:
        ```lua
        lia.dialog.openConfigurationPicker(npc)
        ```

    Realm:
        Client
]]
function lia.dialog.openConfigurationPicker(npc, npcID)
    npcID = npcID or (IsValid(npc) and npc.uniqueID)
    local ply = LocalPlayer()
    local configurations = lia.dialog.getAvailableConfigurations(ply, npc, npcID)
    if #configurations == 0 then
        LocalPlayer():notifyErrorLocalized("noNPCConfigurationsAvailable")
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
        if #otherConfigs > 0 then
            lia.dialog.pendingOtherConfigs = otherConfigs
            lia.dialog.pendingNPC = npc
            lia.dialog.pendingNPCID = npcID
        end

        primaryConfig.onOpen(npc, npcID)
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
    name = "@npcConfigAppearanceName",
    description = "@npcConfigAppearanceDesc",
    order = 0,
    shouldShow = function(ply) return canAccessNPCConfigurations(ply) end
})

if SERVER then
    lia.dialog.registerConfiguration("dialog_type", {
        onApply = function(ply, npc, customData)
            if not IsValid(npc) then return end
            customData = istable(customData) and customData or {}
            if customData.dialogType then
                local requestedType = trimToString(customData.dialogType)
                local resolvedType = lia.dialog.isGeneratedDialogSelection(requestedType) and requestedType or lia.dialog.resolveDialogTypeIdentifier(requestedType)
                if lia.dialog.isGeneratedDialogSelection(resolvedType) then
                    local generatedTypeID, generatedData = ensureGeneratedDialogType(npc, nil, npc.NPCName)
                    if not generatedTypeID or not generatedData then
                        ply:notifyError("Failed to create a custom dialog type for this NPC.")
                        return
                    end

                    resolvedType = generatedTypeID
                end

                local dialogType = resolvedType == "none" and "" or resolvedType
                local npcData = dialogType ~= "" and lia.dialog.getNPCData(dialogType) or nil
                if dialogType ~= "" and not lia.dialog.isDialogCompatibleWithEntity(npc, npcData) then
                    ply:notifyError("That dialog type is not compatible with this entity.")
                    return
                end

                npc.uniqueID = dialogType
                npc:setNetVar("uniqueID", dialogType)
                if dialogType == "" then
                    npc.NPCName = L("unconfiguredNPC")
                    npc:setNetVar("NPCName", npc.NPCName)
                    hook.Run("UpdateEntityPersistence", npc)
                    hook.Run("SaveData")
                    ply:notifySuccessLocalized("npcDialogTypeUpdated")
                    return
                end

                if npcData and npcData.PrintName then
                    npc.NPCName = npcData.PrintName
                    npc:setNetVar("NPCName", npc.NPCName)
                end

                hook.Run("UpdateEntityPersistence", npc)
                hook.Run("SaveData")
                ply:notifySuccessLocalized("npcDialogTypeUpdated")
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
                    npc.NPCName = L("npc")
                end
            end

            local modelChanged = false
            if customData.model and customData.model ~= "" then
                local oldModel = npc:GetModel()
                if oldModel ~= customData.model then modelChanged = true end
                npc:SetModel(customData.model)
            end

            if customData.bodygroups and istable(customData.bodygroups) then lia.util.applyBodygroups(npc, customData.bodygroups) end
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
            if not npc.NPCName or npc.NPCName == "" then npc.NPCName = L("npc") end
            npc:setNetVar("NPCName", npc.NPCName)
            hook.Run("UpdateEntityPersistence", npc)
            hook.Run("SaveData")
            ply:notifySuccessLocalized("npcCustomizedSuccessfully")
        end
    })

    lia.dialog.registerConfiguration("dialog_editor", {
        shouldShow = function(ply, npc) return canAccessNPCConfigurations(ply) and lia.dialog.entityUsesGeneratedDialog(npc) end,
        onApply = function(ply, npc, customData)
            if not IsValid(npc) then return end
            if not lia.dialog.isDialogNPCEntity(npc) then
                ply:notifyError("This editor can only be used on dialog NPCs.")
                return
            end

            customData = istable(customData) and customData or {}
            local dialogTypeID = getGeneratedDialogTypeID(npc, customData.dialogTypeID)
            if dialogTypeID == "" then
                ply:notifyError("Dialog Type ID is required.")
                return
            end

            local generatedDialogData = sanitizeGeneratedDialogPayload(dialogTypeID, customData)
            if not lia.dialog.registerNPC(dialogTypeID, generatedDialogData, false) then
                ply:notifyError("Failed to save dialog tree.")
                return
            end

            npc.uniqueID = dialogTypeID
            npc:setNetVar("uniqueID", dialogTypeID)
            if not trimToString(npc.NPCName) or trimToString(npc.NPCName) == "" then
                npc.NPCName = generatedDialogData.PrintName
                npc:setNetVar("NPCName", npc.NPCName)
            end

            lia.dialog.saveGeneratedDialogs()
            hook.Run("UpdateEntityPersistence", npc)
            hook.Run("SaveData")
            lia.dialog.syncToClients()
            ply:notifySuccess("Dialog tree saved.")
        end
    })

    hook.Add("LoadData", "liaDialogLoadGeneratedTrees", function() lia.dialog.loadGeneratedDialogs() end)
else
    lia.dialog.registerConfiguration("appearance", {
        onOpen = function(npc) lia.dialog.openCustomizationUI(npc, "appearance") end
    })

    lia.dialog.registerConfiguration("dialog_editor", {
        name = "Dialog Node Editor",
        description = "Build a simple node-based dialog tree.",
        order = 10,
        shouldShow = function(ply, npc) return canAccessNPCConfigurations(ply) and lia.dialog.entityUsesGeneratedDialog(npc) end,
        onOpen = function(npc) lia.dialog.openNodeEditor(npc) end
    })

    properties.Add("liaConfigureNPC", {
        MenuLabel = L("configureNPC"),
        Order = 100,
        MenuIcon = "icon16/wrench.png",
        Filter = function(_, ent, ply)
            if not IsValid(ent) or not lia.dialog.isDialogNPCEntity(ent) then return false end
            return lia.admin.canUseDebugProperties(ply) and canAccessNPCConfigurations(ply)
        end,
        Action = function(_, ent) lia.dialog.openConfigurationPicker(ent) end
    })
end
