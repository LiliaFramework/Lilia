﻿local playerMeta = FindMetaTable("Entity")
function playerMeta:getParts()
    return self:getNetVar("parts", {})
end

if SERVER then
    function playerMeta:syncParts()
        net.Start("liaPACSync")
        net.Send(self)
    end

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

    function playerMeta:removePart(partID)
        net.Start("liaPACPartRemove")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = nil
        self:setNetVar("parts", parts)
    end

    function playerMeta:resetParts()
        net.Start("liaPACPartReset")
        net.WriteEntity(self)
        net.Broadcast()
        self:setNetVar("parts", {})
    end

    hook.Add("PostPlayerInitialSpawn", "liaPAC", function(client) timer.Simple(1, function() client:syncParts() end) end)
    hook.Add("PlayerLoadout", "liaPAC", function(client) client:resetParts() end)
    game.ConsoleCommand("sv_pac_webcontent_limit 35840\n")
else
    local partData = {}
    hook.Add("AdjustPACPartData", "liaPAC", function(wearer, id, data)
        local item = lia.item.list[id]
        if item and isfunction(item.pacAdjust) then
            local result = item:pacAdjust(data, wearer)
            if result ~= nil then return result end
        end
    end)

    hook.Add("getAdjustedPartData", "liaPAC", function(wearer, id)
        if not partData[id] then return end
        local data = table.Copy(partData[id])
        return hook.Run("AdjustPACPartData", wearer, id, data) or data
    end)

    hook.Add("attachPart", "liaPAC", function(client, id)
        if not pac then return end
        local part = hook.Run("getAdjustedPartData", client, id)
        if not part then return end
        if not client.AttachPACPart then pac.SetupENT(client) end
        client:AttachPACPart(part, client)
        client.liaPACParts = client.liaPACParts or {}
        client.liaPACParts[id] = part
    end)

    hook.Add("removePart", "liaPAC", function(client, id)
        if not client.RemovePACPart or not client.liaPACParts then return end
        local part = client.liaPACParts[id]
        if part then
            client:RemovePACPart(part)
            client.liaPACParts[id] = nil
        end
    end)

    hook.Add("DrawPlayerRagdoll", "liaPAC", function(entity)
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

    hook.Add("OnEntityCreated", "liaPAC", function(entity)
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

    hook.Add("OnPlayerObserve", "liaPAC", function(client, state)
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

    hook.Add("PAC3RegisterEvents", "liaPAC", function()
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

    hook.Add("TryViewModel", "liaPAC", function(entity) return entity == pac.LocalPlayer:GetViewModel() and pac.LocalPlayer or entity end)
    hook.Add("InitializedModules", "liaPAC", function()
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
    desc = "pacFixCommandDesc",
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
    desc = "pacEnableCommandDesc",
    onRun = function(client)
        client:ConCommand("pac_enable 1")
        client:notifyLocalized("pacenable_success")
    end
})

lia.command.add("pacdisable", {
    adminOnly = false,
    desc = "pacDisableCommandDesc",
    onRun = function(client)
        client:ConCommand("pac_enable 0")
        client:notifyLocalized("pacdisable_message")
    end
})

lia.config.add("BlockPackURLoad", "blockPackUrlLoad", true, nil, {
    desc = "blockPackUrlLoadDesc",
    category = "categoryPAC3",
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.administrator.registerPrivilege({
    Name = "canUsePAC3",
    ID = "canUsePAC3",
    MinAccess = "admin",
    Category = "categoryPAC3"
})

lia.flag.add("P", "flagPac3")
