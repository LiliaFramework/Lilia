local playerMeta = FindMetaTable("Entity")
--[[
    Entity:getParts()

    Description:
        Retrieves the PAC3 parts currently equipped on this player.

    Parameters:
        None

    Realm:
        Shared

    Returns:
        parts (table) – Table of equipped part IDs.
]]
function playerMeta:getParts()
    return self:getNetVar("parts", {})
end

if SERVER then
    --[[
        Entity:syncParts()

        Description:
            Sends the player's equipped PAC3 parts to the client.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None
    ]]
    function playerMeta:syncParts()
        net.Start("liaPACSync")
        net.Send(self)
    end

    --[[
        Entity:addPart(partID)

        Description:
            Adds a PAC3 part to the player and broadcasts the change.

        Parameters:
            partID (string) – Identifier of the part to add.

        Realm:
            Server

        Returns:
            None
    ]]
    function playerMeta:addPart(partID)
        if self:getParts()[partID] then return end
        net.Start("liaPACPartAdd")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = true
        self:setNetVar("parts", parts)
    end

    --[[
        Entity:removePart(partID)

        Description:
            Removes a PAC3 part from the player and broadcasts the change.

        Parameters:
            partID (string) – Identifier of the part to remove.

        Realm:
            Server

        Returns:
            None
    ]]
    function playerMeta:removePart(partID)
        net.Start("liaPACPartRemove")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = nil
        self:setNetVar("parts", parts)
    end

    --[[
        Entity:resetParts()

        Description:
            Clears all PAC3 parts from the player and notifies clients.

        Parameters:
            None

        Realm:
            Server

        Returns:
            None
    ]]
    function playerMeta:resetParts()
        net.Start("liaPACPartReset")
        net.WriteEntity(self)
        net.Broadcast()
        self:setNetVar("parts", {})
    end

    hook.Add("PostPlayerInitialSpawn", "PAC_PostPlayerInitialSpawn", function(client) timer.Simple(1, function() client:syncParts() end) end)
    hook.Add("PlayerLoadout", "PAC_PlayerLoadout", function(client) client:resetParts() end)
    hook.Add("ModuleLoaded", "PAC_ModuleLoaded", function() game.ConsoleCommand("sv_pac_webcontent_limit 35840\n") end)
else
    local partData = {}
    hook.Add("AdjustPACPartData", "PAC_AdjustPACPartData", function(wearer, id, data)
        local item = lia.item.list[id]
        if item and isfunction(item.pacAdjust) then
            local result = item:pacAdjust(data, wearer)
            if result ~= nil then return result end
        end
    end)

    hook.Add("getAdjustedPartData", "PAC_getAdjustedPartData", function(wearer, id)
        if not partData[id] then return end
        local data = table.Copy(partData[id])
        return hook.Run("AdjustPACPartData", wearer, id, data) or data
    end)

    hook.Add("attachPart", "PAC_attachPart", function(client, id)
        if not pac then return end
        local part = hook.Run("getAdjustedPartData", client, id)
        if not part then return end
        if not client.AttachPACPart then pac.SetupENT(client) end
        client:AttachPACPart(part, client)
        client.liaPACParts = client.liaPACParts or {}
        client.liaPACParts[id] = part
    end)

    hook.Add("removePart", "PAC_removePart", function(client, id)
        if not client.RemovePACPart or not client.liaPACParts then return end
        local part = client.liaPACParts[id]
        if part then
            client:RemovePACPart(part)
            client.liaPACParts[id] = nil
        end
    end)

    hook.Add("DrawPlayerRagdoll", "PAC_DrawPlayerRagdoll", function(entity)
        local client = entity.objCache
        if IsValid(client) and not entity.overridePAC3 then
            if client.pac_outfits then
                for _, part in pairs(client.pac_outfits) do
                    if IsValid(part.last_owner) then
                        hook.Run("OnPAC3PartTransfered", part)
                        part:SetOwner(entity)
                        part.last_owner = entity
                    end
                end
            end

            client.pac_playerspawn = pac.RealTime
            entity.overridePAC3 = true
        end
    end)

    hook.Add("OnEntityCreated", "PAC_OnEntityCreated", function(entity)
        local class = entity:GetClass()
        timer.Simple(0, function()
            if class == "prop_ragdoll" and entity:getNetVar("player") then
                entity.RenderOverride = function()
                    entity.objCache = entity:getNetVar("player")
                    entity:DrawModel()
                    hook.Run("DrawPlayerRagdoll", entity)
                end
            end

            if class:find("HL2MPRagdoll") then
                for _, v in player.Iterator() do
                    if v:GetRagdollEntity() == entity then entity.objCache = v end
                end

                entity.RenderOverride = function()
                    entity:DrawModel()
                    hook.Run("DrawPlayerRagdoll", entity)
                end
            end
        end)
    end)

    hook.Add("OnPlayerObserve", "PAC_OnPlayerObserve", function(client, state)
        local curParts = client:getParts()
        if curParts then client:resetParts() end
        if not state then
            local character = client:getChar()
            local inventory = character:getInv()
            for _, v in pairs(inventory:getItems()) do
                if v:getData("equip", false) and v.pacData then client:addPart(v.uniqueID) end
            end
        end
    end)

    hook.Add("PAC3RegisterEvents", "PAC_PAC3RegisterEvents", function()
        local events = {
            {
                name = "weapon_raised",
                args = {},
                available = function() return playerMeta.isWepRaised ~= nil end,
                func = function(_, _, entity)
                    entity = hook.Run("TryViewModel", entity)
                    return entity.isWepRaised and entity:isWepRaised() or false
                end
            }
        }

        for _, v in ipairs(events) do
            local eventObject = pac.CreateEvent(v.name, v.args)
            eventObject.Think = v.func
            function eventObject:IsAvailable()
                return v.available()
            end

            pac.RegisterEvent(eventObject)
        end
    end)

    hook.Add("TryViewModel", "PAC_TryViewModel", function(entity) return entity == pac.LocalPlayer:GetViewModel() and pac.LocalPlayer or entity end)
    hook.Add("InitializedModules", "PAC_InitializedModules", function()
        hook.Remove("HUDPaint", "pac_in_editor")
        timer.Simple(1, function() hook.Run("setupPACDataFromItems") end)
        if lia.config.get("BlockPackURLoad") then concommand.Remove("pac_load_url") end
    end)
end

net.Receive("liaPACSync", function()
    for _, client in player.Iterator() do
        for id in pairs(client:getParts()) do
            hook.Run("attachPart", client, id)
        end
    end
end)

net.Receive("liaPACPartAdd", function()
    local client = net.ReadEntity()
    local id = net.ReadString()
    if not IsValid(client) then return end
    hook.Run("attachPart", client, id)
end)

net.Receive("liaPACPartRemove", function()
    local client = net.ReadEntity()
    local id = net.ReadString()
    if not IsValid(client) then return end
    hook.Run("removePart", client, id)
end)

net.Receive("liaPACPartReset", function()
    local client = net.ReadEntity()
    if not IsValid(client) or not client.RemovePACPart then return end
    if client.liaPACParts then
        for _, part in pairs(client.liaPACParts) do
            client:RemovePACPart(part)
        end

        client.liaPACParts = nil
    end
end)

lia.command.add("fixpac", {
    adminOnly = false,
    desc = L("pacFixCommandDesc"),
    onRun = function(client)
        timer.Simple(0, function() if IsValid(client) then client:ConCommand("pac_clear_parts") end end)
        timer.Simple(0.5, function()
            if IsValid(client) then
                client:ConCommand("pac_urlobj_clear_cache")
                client:ConCommand("pac_urltex_clear_cache")
            end
        end)

        timer.Simple(1, function() if IsValid(client) then client:ConCommand("pac_restart") end end)
        timer.Simple(1.5, function() if IsValid(client) then client:notifyLocalized("fixpac_success") end end)
    end
})

lia.command.add("pacenable", {
    adminOnly = false,
    desc = L("pacEnableCommandDesc"),
    onRun = function(client)
        client:ConCommand("pac_enable 1")
        client:notifyLocalized("pacenable_success")
    end
})

lia.command.add("pacdisable", {
    adminOnly = false,
    desc = L("pacDisableCommandDesc"),
    onRun = function(client)
        client:ConCommand("pac_enable 0")
        client:notifyLocalized("pacdisable_message")
    end
})

lia.config.add("BlockPackURLoad", "Block Pack URL Load", true, nil, {
    desc = "Determines whether loading PAC3 packs from a URL should be blocked.",
    category = "PAC3",
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

CAMI.RegisterPrivilege({
    Name = "Staff Permissions - Can Use PAC3",
    MinAccess = "admin",
    Description = "Allows access to PAC3"
})

lia.flag.add("P", "Access to PAC3.")
