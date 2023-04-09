PvsBuffer = PvsBuffer or {}
PvsBuffer.m_tblPlayers = PvsBuffer.m_tblPlayers or {}
PvsBuffer.m_intSpawnDelay = 8 --Delay initial pvs update by this amount on player spawn
PvsBuffer.m_intUpdateDistance = 5500 --Entities in this range are sent to the player, all others do not send
PvsBuffer.m_intUpdateRate = 1 --Entity transmit update rate
PvsBuffer.m_intUpdateAmount = 512

PvsBuffer.m_tblAlwaysSend = {
    ["player"] = true,
    ["func_lod"] = true,
    ["gmod_hands"] = true,
    ["worldspawn"] = true,
    ["player_manager"] = true,
    ["gmod_gamerules"] = true,
    ["bodyque"] = true,
    ["network"] = true,
    ["soundent"] = true,
    ["prop_door_rotating"] = true,
    ["phys_slideconstraint"] = true,
    ["phys_bone_follower"] = true,
    ["class C_BaseEntity"] = true,
    ["func_physbox"] = true,
    ["logic_auto"] = true,
    ["env_tonemap_controller"] = true,
    ["shadow_control"] = true,
    ["env_sun"] = true,
    ["lua_run"] = true,
    ["func_useableladder"] = true,
    ["info_ladder_dismount"] = true,
    ["func_illusionary"] = true,
    ["env_fog_controller"] = true,
    ["prop_vehicle_jeep"] = false,
}

function PvsBuffer:GetPlayerData(pPlayer)
    return self.m_tblPlayers[pPlayer:EntIndex()]
end

function PvsBuffer:RegisterPlayer(pPlayer)
    self.m_tblPlayers[pPlayer:EntIndex()] = {
        Player = pPlayer,
        Expanding = false,
        Expanded = false,
        EntBuffer = {},
    }

    self:PlayerUpdateTransmitStates(pPlayer)

    timer.Simple(self.m_intSpawnDelay, function()
        self:BeginExpand(pPlayer)
    end)
end

function PvsBuffer:RemovePlayer(pPlayer)
    self.m_tblPlayers[pPlayer:EntIndex()] = nil
end

function PvsBuffer:PlayerUpdateTransmitStates(pPlayer, intRange)
    if intRange then
        for _, v in pairs(ents.GetAll()) do
            if self.m_tblAlwaysSend[v:GetClass()] then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v.UpdateTransmitState and v:UpdateTransmitState() == TRANSMIT_ALWAYS then
                v:SetPreventTransmit(pPlayer, false)
                continue
            end

            if v:GetPos():Distance(pPlayer:GetPos()) > self.m_intUpdateDistance then
                v:SetPreventTransmit(pPlayer, true)
            else
                v:SetPreventTransmit(pPlayer, false)
            end
        end
    else
        for _, v in pairs(ents.GetAll()) do
            if self.m_tblAlwaysSend[v:GetClass()] then
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

function PvsBuffer:BeginExpand(pPlayer)
    local data = self:GetPlayerData(pPlayer)
    if not data then return end
    data.Expanding = true
    local timerID = "PvsBuffer:" .. pPlayer:EntIndex()
    local currentRange = 0

    timer.Create(timerID, self.m_intUpdateRate, 0, function()
        if not IsValid(pPlayer) then
            timer.Destroy(timerID)

            return
        end

        currentRange = math.min(self.m_intUpdateDistance, currentRange + self.m_intUpdateAmount)
        self:PlayerUpdateTransmitStates(pPlayer, currentRange)

        if currentRange == self.m_intUpdateDistance then
            timer.Destroy(timerID)
            data.Expanded = true
            data.Expanding = false
        end
    end)
end

function PvsBuffer:PlayerExpandedUpdate()
    for k, data in pairs(self.m_tblPlayers) do
        if not data or not data.Expanded then continue end

        if not IsValid(data.Player) then
            self.m_tblPlayers[k] = nil
            continue
        end

        self:PlayerUpdateTransmitStates(data.Player, self.m_intUpdateDistance)
    end
end

timer.Create("PvsBuffer:PlayerExpandedUpdate", 1, 0, function()
    PvsBuffer:PlayerExpandedUpdate()
end)

hook.Add("EntityRemoved", "PvsBuffer", function(eEnt)
    if not eEnt:IsPlayer() then return end
    PvsBuffer:RemovePlayer(eEnt)
end)

hook.Add("PlayerInitialSpawn", "PvsExpand", function(pPlayer)
    PvsBuffer:RegisterPlayer(pPlayer)
end)

hook.Add("InitPostEntity", "xxxx", function()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")
    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
    hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
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
end)