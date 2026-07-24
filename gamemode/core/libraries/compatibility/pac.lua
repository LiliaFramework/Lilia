--[[
    Hooks:
        AdjustPACPartData(wearer, id, data)

    Purpose:
        Allows plugins or modules to modify a PAC part data table before it is attached to a wearer.

    Category:
        Compatibility

    Parameters:
        wearer (Player)
            The player who will receive the PAC part.

        id (string)
            The PAC part identifier being adjusted.

        data (table)
            The mutable PAC part data table.

    Returns:
        table|nil
            Return a replacement PAC part data table to override the adjusted result. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("AdjustPACPartData", "liaExampleAdjustPACPartData", function(wearer, id, data)
            data.selfillum = 1
            return data
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        GetAdjustedPartData(wearer, id)

    Purpose:
        Allows plugins or modules to provide the final PAC part data table used for attachment.

    Category:
        Compatibility

    Parameters:
        wearer (Player)
            The player who will receive the PAC part.

        id (string)
            The PAC part identifier being resolved.

    Returns:
        table|nil
            Return a PAC part data table to override the attachment payload. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("GetAdjustedPartData", "liaExampleGetAdjustedPartData", function(wearer, id)
            if id == "visor" then
                return {
                    classname = "model",
                    model = "models/props_junk/TrafficCone001a.mdl"
                }
            end
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        AttachPart(client, id)

    Purpose:
        Runs when a tracked PAC part should be attached to a player clientside.

    Category:
        Compatibility

    Parameters:
        client (Player)
            The player receiving the PAC part.

        id (string)
            The PAC part identifier being attached.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("AttachPart", "liaExampleAttachPart", function(client, id)
            print("Attaching PAC part", id, "to", client)
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        RemovePart(client, id)

    Purpose:
        Runs when a tracked PAC part should be detached from a player clientside.

    Category:
        Compatibility

    Parameters:
        client (Player)
            The player losing the PAC part.

        id (string)
            The PAC part identifier being removed.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("RemovePart", "liaExampleRemovePart", function(client, id)
            print("Removing PAC part", id, "from", client)
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        DrawPlayerRagdoll(entity)

    Purpose:
        Runs during ragdoll rendering so PAC outfits can be transferred from players to their ragdolls.

    Category:
        Compatibility

    Parameters:
        entity (Entity)
            The ragdoll entity being drawn.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("DrawPlayerRagdoll", "liaExampleDrawPlayerRagdoll", function(entity)
            entity:SetRenderMode(RENDERMODE_NORMAL)
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        OnPAC3PartTransfered(part)

    Purpose:
        Runs before an active PAC part is transferred from a player to that player's ragdoll.

    Category:
        Compatibility

    Parameters:
        part (table)
            The PAC part object being transferred.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnPAC3PartTransfered", "liaExampleOnPAC3PartTransfered", function(part)
            print("Transferred PAC part", part.ClassName or "unknown")
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        OnPlayerObserve(client, state)

    Purpose:
        Runs when a player enters or leaves observer mode so PAC parts can be reset or rebuilt.

    Category:
        Compatibility

    Parameters:
        client (Player)
            The player whose observer state changed.

        state (boolean)
            Whether the player entered observer mode.

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("OnPlayerObserve", "liaExampleOnPlayerObservePAC", function(client, state)
            print("Observer state changed", state)
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        TryViewModel(entity)

    Purpose:
        Allows plugins or modules to replace the entity used by PAC event checks that inspect the local view model.

    Category:
        Compatibility

    Parameters:
        entity (Entity)
            The entity being evaluated for PAC event processing.

    Returns:
        Entity|nil
            Return an entity to override the PAC event target. Returning nil allows the default behavior to continue.

    Example Usage:
        ```lua
        hook.Add("TryViewModel", "liaExampleTryViewModel", function(entity)
            return entity
        end)
        ```

    Realm:
        Client
]]
--[[
    Hooks:
        SetupPACDataFromItems()

    Purpose:
        Runs after modules initialize so PAC item definitions can register their attachment data.

    Category:
        Compatibility

    Parameters:
        None

    Returns:
        nil

    Example Usage:
        ```lua
        hook.Add("SetupPACDataFromItems", "liaExampleSetupPACDataFromItems", function()
            print("PAC item data setup requested")
        end)
        ```

    Realm:
        Client
]]
if SERVER then
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

    hook.Add("GetAdjustedPartData", "liaPAC", function(wearer, id)
        if not partData[id] then return end
        local data = table.Copy(partData[id])
        return hook.Run("AdjustPACPartData", wearer, id, data) or data
    end)

    hook.Add("AttachPart", "liaPAC", function(client, id)
        if not pac then return end
        local part = hook.Run("GetAdjustedPartData", client, id)
        if not part then return end
        if not client.AttachPACPart then pac.SetupENT(client) end
        client:AttachPACPart(part, client)
        client.liaPACParts = client.liaPACParts or {}
        client.liaPACParts[id] = part
    end)

    hook.Add("RemovePart", "liaPAC", function(client, id)
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
            if class == "prop_ragdoll" then
                local foundPlayer
                for _, ply in player.Iterator() do
                    if ply:GetRagdollEntity() == entity then
                        foundPlayer = ply
                        break
                    end
                end

                if IsValid(foundPlayer) then
                    entity.objCache = foundPlayer
                    entity.RenderOverride = function()
                        entity:DrawModel()
                        hook.Run("DrawPlayerRagdoll", entity)
                    end
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
            --[[
                Realm:
                    Shared
            ]]
            function eventObject:IsAvailable()
                return v.available()
            end

            pac.RegisterEvent(eventObject)
        end
    end)

    hook.Add("TryViewModel", "liaPAC", function(entity) return entity == pac.LocalPlayer:GetViewModel() and pac.LocalPlayer or entity end)
    hook.Add("InitializedModules", "liaPAC", function()
        hook.Remove("HUDPaint", "pac_in_editor")
        timer.Simple(1, function() hook.Run("SetupPACDataFromItems") end)
        if lia.config.get("BlockPackURLoad") then concommand.Remove("pac_load_url") end
    end)
end

lia.command.add("fixpac", {
    adminOnly = false,
    desc = "@pacFixCommandDesc",
    onRun = function(client)
        timer.Simple(0, function() if IsValid(client) then client:ConCommand("pac_clear_parts") end end)
        timer.Simple(0.5, function()
            if IsValid(client) then
                client:ConCommand("pac_urlobj_clear_cache")
                client:ConCommand("pac_urltex_clear_cache")
            end
        end)

        timer.Simple(1, function() if IsValid(client) then client:ConCommand("pac_restart") end end)
        timer.Simple(1.5, function() if IsValid(client) then client:notifySuccessLocalized("fixpac_success") end end)
    end
})

lia.command.add("pacenable", {
    adminOnly = false,
    desc = "@pacEnableCommandDesc",
    onRun = function(client)
        client:ConCommand("pac_enable 1")
        client:notifySuccessLocalized("pacenable_success")
    end
})

lia.command.add("pacdisable", {
    adminOnly = false,
    desc = "@pacDisableCommandDesc",
    onRun = function(client)
        client:ConCommand("pac_enable 0")
        client:notifyInfoLocalized("pacdisable_message")
    end
})

lia.config.add("BlockPackURLoad", "@blockPackUrlLoad", true, nil, {
    desc = "@blockPackUrlLoadDesc",
    category = "@core",
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})

lia.admin.registerPrivilege({
    Name = "@canUsePAC3",
    ID = "canUsePAC3",
    MinAccess = "admin",
    Category = "@compatibility"
})

hook.Add("PrePACEditorOpen", "RestrictPAC3Editor", function(ply) if not LocalPlayer():getChar():hasFlags("P") or not LocalPlayer():hasPrivilege("canUsePAC3") then return false end end)
hook.Add("pac_CanWearParts", "RestrictPAC3Wearing", function(ply) if not LocalPlayer():getChar():hasFlags("P") or not LocalPlayer():hasPrivilege("canUsePAC3") then return false end end)
lia.flag.add("P", "@flagPac3")
