local MODULE = MODULE
local CONFIG = CONFIG

function MODULE:GetPlayerData(pPlayer)
    return lia.config.tblPlayers[pPlayer:EntIndex()]
end

function MODULE:RegisterPlayer(pPlayer)
    lia.config.tblPlayers[pPlayer:EntIndex()] = {
        Player = pPlayer,
        Expanding = false,
        Expanded = false,
        EntBuffer = {},
    }

    self:PlayerUpdateTransmitStates(pPlayer)

    timer.Simple(lia.config.intSpawnDelay, function()
        self:BeginExpand(pPlayer)
    end)
end

function MODULE:RemovePlayer(pPlayer)
    lia.config.tblPlayers[pPlayer:EntIndex()] = nil
end

function MODULE:PlayerUpdateTransmitStates(pPlayer, intRange)
    if intRange then
        for _, v in pairs(ents.GetAll()) do
            if lia.config.tblAlwaysSend[v:GetClass()] then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v:GetPos():Distance(pPlayer:GetPos()) > lia.config.intUpdateDistance then
                v:SetPreventTransmit(pPlayer, true)
            else
                v:SetPreventTransmit(pPlayer, false)
            end
        end
    else
        for _, v in pairs(ents.GetAll()) do
            if lia.config.tblAlwaysSend[v:GetClass()] then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            v:SetPreventTransmit(pPlayer, true)
        end
    end
end

function MODULE:BeginExpand(pPlayer)
    local data = self:GetPlayerData(pPlayer)
    if not data then return end
    data.Expanding = true
    local timerID = "PVS:" .. pPlayer:EntIndex()
    local currentRange = 0

    timer.Create(timerID, lia.config.intUpdateRate, 0, function()
        if not IsValid(pPlayer) then
            timer.Destroy(timerID)

            return
        end

        currentRange = math.min(lia.config.intUpdateDistance, currentRange + lia.config.intUpdateAmount)
        self:PlayerUpdateTransmitStates(pPlayer, currentRange)

        if currentRange == lia.config.intUpdateDistance then
            timer.Destroy(timerID)
            data.Expanded = true
            data.Expanding = false
        end
    end)
end

function MODULE:PlayerExpandedUpdate()
    for k, data in pairs(lia.config.tblPlayers) do
        if not data or not data.Expanded then continue end

        if not IsValid(data.Player) then
            lia.config.tblPlayers[k] = nil
            continue
        end

        self:PlayerUpdateTransmitStates(data.Player, lia.config.intUpdateDistance)
    end
end

function MODULE:EntityRemoved(ent)
    if not ent:IsPlayer() then return end
    self:RemovePlayer(ent)
end

function MODULE:PlayerInitialSpawn(ply)
    self:RegisterPlayer(ply)
end

function MODULE:Initialize()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")
    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
    hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
    hook.Remove("RenderScene", "RenderSuperDoF")
    hook.Remove("RenderScene", "RenderStereoscopy")
    hook.Remove("Think", "DOFThink")
    hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
    hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
    hook.Remove("PreRender", "PreRenderFrameBlend")
    hook.Remove("PostRender", "RenderFrameBlend")
    hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
    hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
    hook.Remove("RenderScene", "RenderStereoscopy")
    hook.Remove("LoadGModSave", "LoadGModSave")
    hook.Remove("RenderScreenspaceEffects", "RenderColorModify")
    hook.Remove("RenderScreenspaceEffects", "RenderBloom")
    hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
    hook.Remove("RenderScreenspaceEffects", "RenderTexturize")
    hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
    hook.Remove("RenderScreenspaceEffects", "RenderSobel")
    hook.Remove("RenderScreenspaceEffects", "RenderSharpen")
    hook.Remove("RenderScreenspaceEffects", "RenderMaterialOverlay")
    hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
    hook.Remove("RenderScene", "RenderSuperDoF")
    hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
    hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
    hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    hook.Remove("PostRender", "RenderFrameBlend")
    hook.Remove("PreRender", "PreRenderFrameBlend")
    hook.Remove("Think", "DOFThink")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    hook.Remove("PostDrawEffects", "RenderHalos")
    timer.Remove("HostnameThink")
    timer.Remove("CheckHookTimes")
    RunConsoleCommand("gmod_mcore_test", "1")
    RunConsoleCommand("r_shadows", "0")
    RunConsoleCommand("cl_detaildist", "0")
    RunConsoleCommand("cl_threaded_client_leaf_system", "1")
    RunConsoleCommand("cl_threaded_bone_setup", "2")
    RunConsoleCommand("r_threaded_renderables", "1")
    RunConsoleCommand("r_threaded_particles", "1")
    RunConsoleCommand("r_queued_ropes", "1")
    RunConsoleCommand("r_queued_decals", "1")
    RunConsoleCommand("r_queued_post_processing", "1")
    RunConsoleCommand("r_threaded_client_shadow_manager", "1")
    RunConsoleCommand("studio_queue_mode", "1")
    RunConsoleCommand("mat_queue_mode", "-2")
    RunConsoleCommand("fps_max", "0")
    RunConsoleCommand("fov_desired", "100")
    RunConsoleCommand("mat_specular", "0")
    RunConsoleCommand("r_drawmodeldecals", "0")
    RunConsoleCommand("r_lod", "-1")
    RunConsoleCommand("lia_cheapblur", "1")
end

function MODULE:OnEntityCreated(entity)
    if lia.config.DrawEntityShadows then
        entity:DrawShadow(false)
    end
end

function MODULE:InitPostEntity()
    if lia.config.DrawEntityShadows then
        for _, entity in ipairs(ents.GetAll()) do
            entity:DrawShadow(false)
        end
    end
end

do
    local perfomancekillers = {
        ["class C_PhysPropClientside"] = true,
        ["class C_ClientRagdoll"] = true
    }

    timer.Create("CleanupGarbage", 60, 0, function()
        for _, v in ipairs(ents.GetAll()) do
            if perfomancekillers[v:GetClass()] then
                SafeRemoveEntity(v)
                RunConsoleCommand("r_cleardecals")
            end
        end
    end)

    timer.Create("MODULE:PlayerExpandedUpdate", 1, 0, function()
        MODULE:PlayerExpandedUpdate()
    end)
end