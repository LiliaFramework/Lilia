--[[
    Folder: Developer - Libraries
    File: lia.view.md
]]
--[[
    View

    Clientside view helpers for world-space model previews, preview camera control, and temporary entity hiding.
]]
--[[
    Overview:
        The view library centralizes world-space preview behavior under `lia.view`. It can start and stop a preview session for a panel owner, spawn and manage a clientside model, rotate that model, expose the active preview entity, and temporarily hide players or entities while the preview is active.
]]
--[[
    Hooks:
        SetupPlayerModel(Entity entity, Character|nil character)

    Purpose:
        Allows code to configure a clientside player preview model after it is spawned but before character-specific appearance tweaks are applied.

    Category:
        Main Menu

    Parameters:
        entity (Entity)
            The clientside model entity being prepared for preview.

        character (Character|nil)
            An optional loaded character when the preview is built from character selection data.

    Example Usage:
        ```lua
        hook.Add("SetupPlayerModel", "liaExampleSetupPlayerModel", function(entity, character)
            entity:SetCycle(0)
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
--[[
    Hooks:
        ModifyCharacterModel(Entity entity, table|Character|nil contextOrCharacter)

    Purpose:
        Allows code to adjust a preview model after its base model, skin, and bodygroups have been applied for character creation or character selection scenes.

    Category:
        Main Menu

    Parameters:
        entity (Entity)
            The clientside model entity being displayed.

        contextOrCharacter (table|Character|nil)
            Either the creation context table, the loaded character being previewed, or nil when no extra context is supplied.

    Example Usage:
        ```lua
        hook.Add("ModifyCharacterModel", "liaExampleModifyCharacterModel", function(entity, contextOrCharacter)
            entity:SetAngles(Angle(0, 180, 0))
        end)
        ```

    Returns:
        nil

    Realm:
        Client
]]
lia.view = lia.view or {}
local function getPreviewAngle(client)
    local eyeAngles = IsValid(client) and client:EyeAngles() or angle_zero
    return Angle(0, eyeAngles.y + 180, 0)
end

local function getGroundPosition(pos, filter)
    if not isvector(pos) then return pos end
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 64),
        endpos = pos + Vector(0, 0, -16384),
        mask = MASK_SOLID,
        filter = filter
    })

    if tr.Hit and tr.HitWorld and not tr.HitSky then return tr.HitPos + Vector(0, 0, 2) end
    return pos
end

local function getPreviewPosition(client)
    if not IsValid(client) then return Vector() end
    local forward = client:EyeAngles():Forward()
    forward.z = 0
    if forward:LengthSqr() <= 0 then
        forward = Vector(1, 0, 0)
    else
        forward:Normalize()
    end

    local eyePos = client:EyePos()
    local hull = util.TraceHull({
        start = eyePos,
        endpos = eyePos + forward * 96,
        mins = Vector(-16, -16, 0),
        maxs = Vector(16, 16, 72),
        filter = client,
        mask = MASK_SOLID
    })

    local basePos = hull.Hit and (hull.HitPos - forward * 28) or client:GetPos() + forward * 85
    return getGroundPosition(basePos, client)
end

local function applyIdleSequence(ent)
    if not IsValid(ent) then return end
    local seq = ent:LookupSequence("idle_all_01")
    if seq > 0 then
        ent:ResetSequence(seq)
        ent:SetCycle(0)
        return
    end

    seq = ent:SelectWeightedSequence(ACT_IDLE)
    if seq <= 0 then seq = ent:LookupSequence("idle_unarmed") end
    if seq > 0 then
        ent:ResetSequence(seq)
        ent:SetCycle(0)
        return
    end

    for _, name in ipairs(ent:GetSequenceList()) do
        local lowered = name:lower()
        if lowered ~= "idlenoise" and (lowered:find("idle") or lowered:find("fly")) then
            ent:ResetSequence(name)
            ent:SetCycle(0)
            return
        end
    end
end

--[[
    Function: lia.view.shouldHidePlayer

    Purpose:
        Checks whether a player should be skipped while the active preview is hiding selected players.

    Parameters:
        player (Player)
            The player being considered for drawing.

    Example Usage:
        ```lua
        local previewOwner = lia.view.activeOwner
        if IsValid(previewOwner) and lia.view.shouldHidePlayer(LocalPlayer()) then
            chat.AddText(Color(255, 200, 0), "The active preview is hiding the local player.")
        end
        ```

    Returns:
        boolean
            True when the player is part of the active preview's hidden player set.

    Realm:
        Client
]]
function lia.view.shouldHidePlayer(player)
    local owner = lia.view.activeOwner
    local data = IsValid(owner) and owner._liaViewPreview
    return data and istable(data.hiddenPlayers) and data.hiddenPlayers[player] or false
end

--[[
    Function: lia.view.close

    Purpose:
        Stops a preview session, removes its clientside model, restores hidden entities, and unregisters preview hooks.

    Parameters:
        owner (Panel)
            The panel or owner object that started the preview session.

    Example Usage:
        ```lua
        local panel = vgui.Create("EditablePanel")
        lia.view.begin(panel, {hideEntities = {LocalPlayer()}})
        lia.view.close(panel)
        ```

    Realm:
        Client
]]
function lia.view.close(owner)
    if not owner then return end
    local data = owner._liaViewPreview
    if not data then return end
    hook.Remove("CalcView", data.calcViewHook)
    hook.Remove("PostDrawOpaqueRenderables", data.renderHook)
    hook.Remove("PrePlayerDraw", data.prePlayerDrawHook)
    hook.Remove("ShouldDrawLocalPlayer", data.shouldDrawLocalPlayerHook)
    if IsValid(data.entity) then data.entity:Remove() end
    if istable(data.hiddenEntities) then
        for ent, noDraw in pairs(data.hiddenEntities) do
            if IsValid(ent) then ent:SetNoDraw(noDraw) end
        end
    end

    if istable(data.hiddenPlayerState) then
        for player, state in pairs(data.hiddenPlayerState) do
            if IsValid(player) then
                player:SetNoDraw(state.noDraw == true)
                if state.hadEffect then
                    player:AddEffects(EF_NODRAW)
                else
                    player:RemoveEffects(EF_NODRAW)
                end
            end
        end
    end

    if lia.view.activeOwner == owner then lia.view.activeOwner = nil end
    owner._liaViewPreview = nil
end

--[[
    Function: lia.view.begin

    Purpose:
        Starts a world-space preview session for an owner and configures temporary draw suppression for the supplied entities.

    Parameters:
        owner (Panel)
            The panel or owner object that controls the preview lifecycle.
        config (table)
            Preview configuration such as hidden entities, camera offsets, preview position, and context data.

    Example Usage:
        ```lua
        local panel = vgui.Create("EditablePanel")
        lia.view.begin(panel, {
            hideEntities = {LocalPlayer()},
            position = LocalPlayer():GetPos() + Vector(64, 0, 8),
            angle = Angle(0, LocalPlayer():EyeAngles().y + 180, 0)
        })
        ```

    Realm:
        Client
]]
function lia.view.begin(owner, config)
    if not IsValid(owner) then return end
    if IsValid(lia.view.activeOwner) and lia.view.activeOwner ~= owner then lia.view.close(lia.view.activeOwner) end
    lia.view.close(owner)
    local data = {
        config = config or {},
        calcViewHook = "liaViewCalcView" .. tostring(owner),
        renderHook = "liaViewRender" .. tostring(owner),
        prePlayerDrawHook = "liaViewPrePlayerDraw" .. tostring(owner),
        shouldDrawLocalPlayerHook = "liaViewShouldDrawLocalPlayer" .. tostring(owner)
    }

    owner._liaViewPreview = data
    lia.view.activeOwner = owner
    data.hiddenEntities = {}
    data.hiddenPlayers = {}
    data.hiddenPlayerState = {}
    local processedEntities = {}
    local hiddenTargets = istable(data.config.hideEntities) and data.config.hideEntities or {}
    for _, ent in ipairs(hiddenTargets) do
        if processedEntities[ent] then continue end
        processedEntities[ent] = true
        if not IsValid(ent) or ent == data.entity then continue end
        if ent:IsPlayer() then
            data.hiddenPlayers[ent] = true
            data.hiddenPlayerState[ent] = {
                noDraw = ent:GetNoDraw(),
                hadEffect = ent:IsEffectActive(EF_NODRAW)
            }

            ent:SetNoDraw(true)
            ent:AddEffects(EF_NODRAW)
        elseif data.hiddenEntities[ent] == nil then
            data.hiddenEntities[ent] = ent:GetNoDraw()
            ent:SetNoDraw(true)
        end
    end

    hook.Add("PrePlayerDraw", data.prePlayerDrawHook, function(player)
        local previewData = IsValid(owner) and owner._liaViewPreview
        if not previewData then return end
        if istable(previewData.hiddenPlayers) and previewData.hiddenPlayers[player] then return true end
        if istable(previewData.hiddenEntities) and previewData.hiddenEntities[player] ~= nil then return true end
    end)

    hook.Add("ShouldDrawLocalPlayer", data.shouldDrawLocalPlayerHook, function(player)
        local previewData = IsValid(owner) and owner._liaViewPreview
        if not previewData or not istable(previewData.hiddenPlayers) then return end
        local client = IsValid(player) and player or LocalPlayer()
        if previewData.hiddenPlayers[client] then return false end
    end)

    hook.Add("CalcView", data.calcViewHook, function(_, _, _, fov)
        if not IsValid(owner) then
            lia.view.close(owner)
            return
        end

        local previewData = owner._liaViewPreview
        local ent = previewData and previewData.entity
        if not IsValid(ent) then return end
        local center = ent:GetPos() + Vector(0, 0, previewData.config.heightOffset or 60)
        local desired = center + ent:GetAngles():Forward() * (previewData.config.distance or 70)
        if not previewData.currentCamPos then
            previewData.currentCamPos = desired
        else
            previewData.currentCamPos = LerpVector(FrameTime() * 5, previewData.currentCamPos, desired)
        end

        local target = center - ent:GetAngles():Right() * (previewData.config.sideOffset or 40)
        return {
            origin = previewData.currentCamPos,
            angles = (target - previewData.currentCamPos):Angle(),
            fov = fov,
            drawviewer = true
        }
    end)

    hook.Add("PostDrawOpaqueRenderables", data.renderHook, function()
        if not IsValid(owner) then
            lia.view.close(owner)
            return
        end

        local previewData = owner._liaViewPreview
        local ent = previewData and previewData.entity
        if not IsValid(ent) then return end
        ent:FrameAdvance()
        render.SuppressEngineLighting(true)
        render.ResetModelLighting(1, 1, 1)
        for i = 0, 6 do
            render.SetModelLighting(i, 1, 1, 1)
        end

        ent:DrawModel()
        render.SuppressEngineLighting(false)
        render.ResetModelLighting(1, 1, 1)
        for i = 0, 6 do
            render.SetModelLighting(i, 0, 0, 0)
        end
    end)
end

--[[
    Function: lia.view.setModel

    Purpose:
        Creates or replaces the clientside preview model for an owner and applies the supplied appearance options.

    Parameters:
        owner (Panel)
            The panel or owner object that owns the preview session.
        modelPath (string)
            The model path to preview.
        options (table)
            Appearance and context options such as skin, bodygroups, angle, position, and hidden entities.

    Example Usage:
        ```lua
        local panel = vgui.Create("EditablePanel")
        lia.view.setModel(panel, LocalPlayer():GetModel(), {
            position = LocalPlayer():GetPos() + Vector(64, 0, 8),
            bodygroups = {[1] = 0}
        })
        lia.view.rotate(panel, 30)
        ```

    Realm:
        Client
]]
function lia.view.setModel(owner, modelPath, options)
    if not IsValid(owner) then return end
    local data = owner._liaViewPreview
    if not data then
        lia.view.begin(owner, options)
        data = owner._liaViewPreview
    elseif options then
        data.config = options
    end

    if IsValid(data.entity) then data.entity:Remove() end
    data.entity = ClientsideModel(modelPath or "models/error.mdl", RENDERGROUP_OPAQUE)
    if not IsValid(data.entity) then return end
    local client = LocalPlayer()
    local config = data.config or {}
    data.entity:SetPos(config.position or getPreviewPosition(client))
    data.entity:SetAngles(config.angle or getPreviewAngle(client))
    data.entity:SetSkin(config.skin or 0)
    if istable(config.bodygroups) then lia.util.applyBodygroups(data.entity, config.bodygroups) end
    hook.Run("SetupPlayerModel", data.entity)
    hook.Run("ModifyCharacterModel", data.entity, config.context)
    applyIdleSequence(data.entity)
    data.currentCamPos = nil
end

--[[
    Function: lia.view.getEntity

    Purpose:
        Returns the current clientside preview entity for an owner.

    Parameters:
        owner (Panel)
            The panel or owner object that owns the preview session.

    Example Usage:
        ```lua
        local panel = vgui.Create("EditablePanel")
        local previewEntity = lia.view.getEntity(panel)
        if IsValid(previewEntity) then
            previewEntity:SetSkin(1)
            previewEntity:SetCycle(0)
        end
        ```

    Returns:
        Entity|nil
            The active clientside preview model, or nil when no preview is active.

    Realm:
        Client
]]
function lia.view.getEntity(owner)
    local data = IsValid(owner) and owner._liaViewPreview
    return data and data.entity or nil
end

--[[
    Function: lia.view.rotate

    Purpose:
        Rotates the current preview entity around its yaw axis.

    Parameters:
        owner (Panel)
            The panel or owner object that owns the preview session.
        deltaYaw (number)
            The yaw delta to apply in degrees.

    Example Usage:
        ```lua
        local panel = vgui.Create("EditablePanel")
        lia.view.rotate(panel, 15)
        lia.view.rotate(panel, 15)
        ```

    Realm:
        Client
]]
function lia.view.rotate(owner, deltaYaw)
    local ent = lia.view.getEntity(owner)
    if not IsValid(ent) then return end
    local ang = ent:GetAngles()
    ang.y = ang.y + deltaYaw
    ent:SetAngles(ang)
end
