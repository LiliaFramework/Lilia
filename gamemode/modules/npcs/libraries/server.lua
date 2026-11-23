local function findOption(options, label, ply)
    if isfunction(options) then options = options(ply) end
    if not istable(options) then return nil end
    for k, v in pairs(options) do
        if k == label or lia.lang.resolve(k) == label then return v end
        if v.options then
            local found = findOption(v.options, label, ply)
            if found then return found end
        end
    end
    return nil
end

local function buildResponsePayload(response)
    if response == nil then return nil end
    if istable(response) then
        local payload = {}
        local function pushLine(line)
            if isstring(line) then
                payload[#payload + 1] = lia.lang.resolve(line)
            elseif line ~= nil then
                payload[#payload + 1] = tostring(line)
            end
        end

        for _, line in ipairs(response) do
            pushLine(line)
        end

        if #payload == 0 then
            for _, line in pairs(response) do
                pushLine(line)
            end
        end
        return #payload > 0 and payload or nil
    end
    return {lia.lang.resolve(tostring(response))}
end

local function dialogFactionMatches(ply, requirement)
    requirement = string.Trim(tostring(requirement or ""))
    if requirement == "" then return true end
    local char = ply:getChar()
    if not char then return false end
    return lia.dialog.factionMatchesRequirement(char:getFaction(), requirement)
end

local function isGeneratedCloseNode(node)
    if not istable(node) then return false end
    local nodeID = string.Trim(string.lower(tostring(node.dialogID or "")))
    return nodeID == "goodbye" or nodeID == "bye" or nodeID == "farewell" or nodeID == "close"
end

local function buildGeneratedNodeOptions(generatedDialog, nodeID)
    local options = {}
    for _, childNode in ipairs(lia.dialog.getGeneratedChildNodes(generatedDialog, nodeID) or {}) do
        options[#options + 1] = {
            label = childNode.playerText ~= "" and childNode.playerText or childNode.dialogID or childNode.id,
            nodeID = childNode.id,
            closeDialog = isGeneratedCloseNode(childNode)
        }
    end
    return options
end

local function applyGeneratedNodeEffects(ply, npc, node)
    if not IsValid(ply) or not istable(node) then return end
    local swepClass = string.Trim(tostring(node.swepClass or ""))
    if swepClass ~= "" and not ply:HasWeapon(swepClass) then ply:Give(swepClass) end
    local waypointValue = string.Trim(tostring(node.waypoint or ""))
    if waypointValue ~= "" then
        local waypointVector = lia.data.decodeVector(waypointValue)
        if isvector(waypointVector) then
            ply:setWaypoint(node.dialogID ~= "" and node.dialogID or "Dialog", waypointVector)
        elseif IsValid(npc) then
            ply:setWaypoint(waypointValue, npc:GetPos())
        end
    end
end

local function setupNPCType(client, npc)
    if not IsValid(npc) then return end
    local npcType = npc.uniqueID
    if not npcType then return end
    local existingCustomData = npc.customData
    local npcData = lia.dialog.getNPCData(npcType)
    if npcData and lia.dialog.isDialogCompatibleWithEntity(npc, npcData) then
        local currentPos = npc:GetPos()
        local currentAng = npc:GetAngles()
        npc:SetModel("models/Barney.mdl")
        if npcData.BodyGroups and istable(npcData.BodyGroups) then lia.util.applyBodygroups(npc, npcData.BodyGroups) end
        if npcData.Skin then npc:SetSkin(npcData.Skin) end
        npc.NPCName = npcData.PrintName or "NPC"
        npc:setNetVar("uniqueID", npcType)
        npc:setNetVar("NPCName", npc.NPCName)
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
        if existingCustomData then
            if existingCustomData.name and existingCustomData.name ~= "" then npc.NPCName = existingCustomData.name end
            if existingCustomData.model and existingCustomData.model ~= "" then npc:SetModel(existingCustomData.model) end
            if existingCustomData.skin then npc:SetSkin(tonumber(existingCustomData.skin) or 0) end
            if existingCustomData.bodygroups and istable(existingCustomData.bodygroups) then lia.util.applyBodygroups(npc, existingCustomData.bodygroups) end
            if existingCustomData.animation and existingCustomData.animation ~= "auto" then
                local sequenceIndex = npc:LookupSequence(existingCustomData.animation)
                if sequenceIndex >= 0 then
                    npc.customAnimation = existingCustomData.animation
                    npc:ResetSequence(sequenceIndex)
                end
            end

            npc.customData = existingCustomData
        end

        npc:setNetVar("NPCName", npc.NPCName)
        hook.Run("UpdateEntityPersistence", npc)
        hook.Run("OnDialogNPCTypeSet", client, npc)
    end
end

net.Receive("liaNpcDialogServerCallback", function(_, ply)
    local npc = net.ReadEntity()
    local label = net.ReadString()
    local npcData = lia.dialog.getOriginalNPCData(npc.uniqueID)
    local conversationTable = npcData and npcData.Conversation
    local option = findOption(conversationTable, label, ply)
    if not option and conversationTable then
        for _, entry in pairs(conversationTable) do
            if istable(entry) and isfunction(entry.GetOptions) then
                local dynamicOptions = entry.GetOptions(ply, npc)
                if istable(dynamicOptions) and dynamicOptions[label] then
                    option = dynamicOptions[label]
                    break
                end
            end
        end
    end

    if not IsValid(npc) or not option then return end
    if option.ShouldShow and not option.ShouldShow(ply, npc) then return end
    if option.Callback then option.Callback(ply, npc) end
end)

net.Receive("liaNpcDialogRequestResponse", function(_, ply)
    local npc = net.ReadEntity()
    local label = net.ReadString()
    if not IsValid(ply) or not IsValid(npc) or not npc.uniqueID then return end
    local npcData = lia.dialog.getOriginalNPCData(npc.uniqueID)
    local conversationTable = npcData and npcData.Conversation
    if not conversationTable then return end
    local option = findOption(conversationTable, label, ply)
    if not option then return end
    if option.ShouldShow and not option.ShouldShow(ply, npc) then return end
    if not option.Response then return end
    local payload
    if isfunction(option.Response) then
        local success, result = pcall(option.Response, ply, npc)
        if not success then
            ErrorNoHalt(string.format("[Lilia] Dialog response error for ('%s'): %s\n", label, tostring(result)))
            return
        end

        payload = result
    else
        payload = option.Response
    end

    if istable(payload) and #payload > 1 then
        local randomIndex = math.random(1, #payload)
        payload = payload[randomIndex]
    end

    payload = buildResponsePayload(payload)
    if not payload then return end
    net.Start("liaNpcDialogDeliverResponse")
    net.WriteEntity(npc)
    net.WriteTable(payload)
    net.Send(ply)
end)

net.Receive("liaNpcDialogNodeSelect", function(_, ply)
    local npc = net.ReadEntity()
    local selectedNodeID = net.ReadString()
    local currentNodeID = net.ReadString()
    if not IsValid(ply) or not IsValid(npc) or not npc.uniqueID then return end
    local npcData = lia.dialog.getOriginalNPCData(npc.uniqueID)
    local generatedDialog = npcData and npcData.GeneratedDialog
    if not istable(generatedDialog) then return end
    local selectedNode = lia.dialog.findGeneratedNode(generatedDialog, selectedNodeID)
    local currentNode = lia.dialog.findGeneratedNode(generatedDialog, currentNodeID)
    if not selectedNode then return end
    local allowed = false
    if currentNode then
        for _, childID in ipairs(currentNode.children or {}) do
            if childID == selectedNodeID then
                allowed = true
                break
            end
        end
    else
        local startNode = lia.dialog.getGeneratedStartNode(generatedDialog)
        if startNode and startNode.id == selectedNodeID then allowed = true end
    end

    if not allowed and currentNodeID ~= "" then return end
    local success = dialogFactionMatches(ply, selectedNode.factionRequirement)
    local responseText = success and selectedNode.npcText or (selectedNode.requirementMessage ~= "" and selectedNode.requirementMessage or "You do not meet the requirement for this dialog.")
    if success then applyGeneratedNodeEffects(ply, npc, selectedNode) end
    net.Start("liaNpcDialogNodeResult")
    net.WriteTable({
        success = success,
        selectedNodeID = selectedNodeID,
        currentNodeID = currentNodeID,
        npcText = responseText,
        soundPath = success and selectedNode.soundPath or "",
        closeDialog = success and isGeneratedCloseNode(selectedNode) or false,
        options = buildGeneratedNodeOptions(generatedDialog, success and selectedNodeID or currentNodeID)
    })

    net.Send(ply)
end)

net.Receive("liaNpcCustomize", function(_, ply)
    local configID = net.ReadString()
    local npc = net.ReadEntity()
    local payload = net.ReadTable() or {}
    if not isstring(configID) or configID == "" then return end
    if not IsValid(ply) or not IsValid(npc) then return end
    if not ply.hasPrivilege or not ply:hasPrivilege("canManageNPCs") then return end
    local config = lia.dialog.getConfiguration(configID)
    if not config or not isfunction(config.onApply) then return end
    if isfunction(config.shouldShow) then
        local ok, allowed = pcall(config.shouldShow, ply, npc, npc.uniqueID)
        if not ok then
            ErrorNoHalt(string.format("[Lilia] NPC configuration '%s' visibility check failed: %s\n", configID, tostring(allowed)))
            return
        end

        if allowed == false then return end
    end

    local success, err = pcall(config.onApply, ply, npc, payload)
    if not success then ErrorNoHalt(string.format("[Lilia] NPC configuration '%s' errored: %s\n", configID, tostring(err))) end
end)

net.Receive("liaRequestNPCSelection", function(_, client)
    local npcEntity = net.ReadEntity()
    local uniqueID = net.ReadString()
    if IsValid(npcEntity) and IsValid(client) then
        local character = client:getChar()
        if character then
            if lia.dialog.isGeneratedDialogSelection(uniqueID) then
                local hasManageNPCs = client:hasPrivilege("canManageNPCs")
                local hasManageProperties = client:hasPrivilege("canManageProperties")
                if not hasManageNPCs and not hasManageProperties then return end
                uniqueID = select(1, lia.dialog.ensureGeneratedDialogType(npcEntity, nil, npcEntity.NPCName))
                if not uniqueID then return end
            end

            npcEntity.uniqueID = uniqueID
            setupNPCType(client, npcEntity)
        end
    end
end)

function MODULE:PlayerLiliaDataLoaded(client)
    timer.Simple(2, function() if IsValid(client) then lia.dialog.syncToClients(client) end end)
end

function MODULE:TransformPersistentEntityLoadData(ent, savedData)
    if not lia.dialog.isDialogNPCEntity(ent) or not savedData or not istable(savedData.data) then return end
    local loadData = table.Copy(savedData)
    if savedData.data.uniqueID then loadData.uniqueID = savedData.data.uniqueID end
    if savedData.data.npcName then loadData.npcName = savedData.data.npcName end
    loadData.data = {
        customData = savedData.data.customData
    }
    return loadData
end

function MODULE:GetPersistentEntitySaveData(ent)
    if lia.dialog.isDialogNPCEntity(ent) then
        local saveData = {
            uniqueID = ent.uniqueID or "",
            npcName = ent.NPCName or ""
        }

        if ent.customData then saveData.customData = ent.customData end
        return saveData
    end
end

function MODULE:OnPersistentEntityLoaded(ent, data)
    if lia.dialog.isDialogNPCEntity(ent) and data and data.uniqueID and data.uniqueID ~= "" then
        ent.uniqueID = data.uniqueID
        ent.NPCName = data.npcName or "NPC"
        local npcData = lia.dialog.getNPCData(data.uniqueID)
        local hasCustomModel = data.data and data.data.customData and data.data.customData.model and data.data.customData.model ~= ""
        if npcData then
            if not hasCustomModel then ent:SetModel("models/Barney.mdl") end
            if npcData.BodyGroups and istable(npcData.BodyGroups) then lia.util.applyBodygroups(ent, npcData.BodyGroups) end
            if npcData.Skin then ent:SetSkin(npcData.Skin) end
        end

        if data.data and data.data.customData and istable(data.data.customData) then
            ent.customData = data.data.customData
            if data.data.customData.name and data.data.customData.name ~= "" then ent.NPCName = data.data.customData.name end
            if data.data.customData.model and data.data.customData.model ~= "" then ent:SetModel(data.data.customData.model) end
            if data.data.customData.skin then ent:SetSkin(tonumber(data.data.customData.skin) or 0) end
            if data.data.customData.bodygroups and istable(data.data.customData.bodygroups) then lia.util.applyBodygroups(ent, data.data.customData.bodygroups) end
        end

        if data.data and data.data.customData and data.data.customData.animation and data.data.customData.animation ~= "auto" then
            local sequenceIndex = ent:LookupSequence(data.data.customData.animation)
            if sequenceIndex >= 0 then
                ent.customAnimation = data.data.customData.animation
                ent:ResetSequence(sequenceIndex)
            else
                ent.customAnimation = nil
                data.data.customData.animation = "auto"
            end
        else
            ent.customAnimation = nil
        end

        ent:setNetVar("uniqueID", data.uniqueID)
        ent:setNetVar("NPCName", ent.NPCName)
        if not ent.NPCName or ent.NPCName == "" then ent.NPCName = ent:getNetVar("NPCName", "NPC") end
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent:SetSolid(SOLID_OBB)
        ent:PhysicsInit(SOLID_OBB)
        ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
        local physObj = ent:GetPhysicsObject()
        if IsValid(physObj) then
            physObj:EnableMotion(false)
            physObj:Sleep()
        end

        ent:setAnim()
    end
end

print("gay")
