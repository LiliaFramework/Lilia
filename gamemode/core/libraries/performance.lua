local serverCommands = {"mp_show_voice_icons 0", "net_maxfilesize 64", "sv_kickerrornum 0", "sv_allowupload 0", "sv_allowdownload 0", "sv_allowcslua 0", "gmod_physiterations 4", "sbox_noclip 0", "sv_maxrate 30000", "sv_minrate 5000", "sv_maxcmdrate 66", "sv_maxupdaterate 66", "sv_mincmdrate 30"}
local clientCommands = {"gmod_mcore_test 1", "mem_max_heapsize_dedicated 131072", "mem_min_heapsize 131072", "threadpool_affinity 64", "mat_queue_mode 2", "mat_powersavingsmode 0", "r_queued_ropes 1", "r_threaded_particles 1", "cl_threaded_bone_setup 1", "cl_lagcompensation 1", "cl_timeout 3600", "cl_smoothtime 0.05", "cl_localnetworkbackdoor 1", "cl_cmdrate 66", "cl_updaterate 66", "cl_interp_ratio 2", "studio_queue_mode 1", "ai_expression_optimization 1", "filesystem_max_stdio_read 64", "in_usekeyboardsampletime 1", "r_radiosity 4", "rate 1048576", "mat_framebuffercopyoverlaysize 0", "mat_managedtextures 0", "fast_fogvolume 1", "filesystem_unbuffered_io 0"}
local serverHooks = {{"OnEntityCreated", "WidgetInit"}, {"Think", "DOFThink"}, {"Think", "CheckSchedules"}, {"PlayerTick", "TickWidgets"}, {"PlayerInitialSpawn", "PlayerAuthSpawn"}, {"LoadGModSave", "LoadGModSave"}, {"PlayerInitialSpawn", "HintSystem_PlayerInitialSpawn"}, {"PlayerSpawn", "HintSystem_PlayerSpawn"}}
local clientHooks = {{"HUDPaint", "DamageEffect"}, {"StartChat", "StartChatIndicator"}, {"FinishChat", "EndChatIndicator"}, {"PostDrawEffects", "RenderWidgets"}, {"PostDrawEffects", "RenderHalos"}, {"OnEntityCreated", "WidgetInit"}, {"GUIMousePressed", "SuperDOFMouseDown"}, {"GUIMouseReleased", "SuperDOFMouseUp"}, {"PreventScreenClicks", "SuperDOFPreventClicks"}, {"Think", "DOFThink"}, {"Think", "CheckSchedules"}, {"NeedsDepthPass", "NeedsDepthPass_Bokeh"}, {"RenderScene", "RenderSuperDoF"}, {"RenderScene", "RenderStereoscopy"}, {"PreRender", "PreRenderFrameBlend"}, {"PostRender", "RenderFrameBlend"}, {"RenderScreenspaceEffects", "RenderBokeh"}}
local spawn_delay = 8
local update_rate = 1
local update_amount = 512
local always_send = {
    player = true,
    func_lod = true,
    gmod_hands = true,
    worldspawn = true,
    player_manager = true,
    gmod_gamerules = true,
    bodyque = true,
    network = true,
    soundent = true,
    prop_door_rotating = true,
    phys_slideconstraint = true,
    phys_bone_follower = true,
    ["class C_BaseEntity"] = true,
    func_physbox = true,
    logic_auto = true,
    env_tonemap_controller = true,
    shadow_control = true,
    env_sun = true,
    lua_run = true,
    func_useableladder = true,
    info_ladder_dismount = true,
    func_illusionary = true,
    env_fog_controller = true,
    prop_vehicle_jeep = false
}

local function ExecuteCommands(isServer)
    if isServer then
        for _, cmd in ipairs(serverCommands) do
            game.ConsoleCommand(cmd .. "\n")
        end
    else
        for _, cmd in ipairs(clientCommands) do
            local command, args = cmd:match("^(%S+)%s+(.*)$")
            if command then
                if args then
                    local argList = {}
                    for arg in string.gmatch(args, "%S+") do
                        table.insert(argList, arg)
                    end

                    RunConsoleCommand(command, unpack(argList))
                else
                    RunConsoleCommand(command)
                end
            end
        end
    end
end

local function RemoveHooks(isServer)
    if isServer then
        for _, h in ipairs(serverHooks) do
            hook.Remove(h[1], h[2])
        end
    else
        for _, h in ipairs(clientHooks) do
            hook.Remove(h[1], h[2])
        end
    end
end

hook.Add("Initialize", "liaPerformanceInitialize", function() ExecuteCommands(SERVER) end)
hook.Add("OnReloaded", "liaPerformanceReloaded", function()
    RemoveHooks(SERVER)
    ExecuteCommands(SERVER)
end)

if CLIENT then
    hook.Add("InitializedModules", "liaPerformanceInitializedModules", function() scripted_ents.GetStored("base_gmodentity").t.Think = nil end)
else
    local players_data = {}
    local function get_player_data(p)
        return players_data[p:EntIndex()]
    end

    local function update_transmit_states(pPlayer, range)
        local range_sqr = range and range * range
        for _, ent in ents.Iterator() do
            local cls = ent:GetClass()
            if always_send[cls] or ent.UpdateTransmitState and ent:UpdateTransmitState() == TRANSMIT_ALWAYS then
                ent:SetPreventTransmit(pPlayer, false)
            elseif range_sqr then
                ent:SetPreventTransmit(pPlayer, ent:GetPos():DistToSqr(pPlayer:GetPos()) > range_sqr)
            else
                ent:SetPreventTransmit(pPlayer, true)
            end
        end
    end

    local function begin_expand(pPlayer)
        local data = get_player_data(pPlayer)
        if not data then return end
        data.expanding = true
        local timer_id = "PVSExpand" .. pPlayer:EntIndex()
        local current_range = 0
        timer.Create(timer_id, update_rate, 0, function()
            if not IsValid(pPlayer) then
                timer.Remove(timer_id)
                return
            end

            current_range = math.min(lia.config.get("MaxViewDistance", 5000), current_range + update_amount)
            update_transmit_states(pPlayer, current_range)
            if current_range == lia.config.get("MaxViewDistance", 5000) then
                timer.Remove(timer_id)
                data.expanded = true
                data.expanding = false
            end
        end)
    end

    local function remove_player(pPlayer)
        players_data[pPlayer:EntIndex()] = nil
    end

    local function expanded_update()
        for idx, data in pairs(players_data) do
            if data.expanded then
                local ply = data.player
                if IsValid(ply) then
                    update_transmit_states(ply, lia.config.get("MaxViewDistance", 5000))
                else
                    players_data[idx] = nil
                end
            end
        end
    end

    timer.Create("PVSExpandedUpdate", 1, 0, expanded_update)
    hook.Add("PlayerInitialSpawn", "liaPerformancePlayerInitialSpawn", function(pPlayer)
        players_data[pPlayer:EntIndex()] = {
            player = pPlayer,
            expanded = false,
            expanding = false
        }

        update_transmit_states(pPlayer)
        timer.Simple(spawn_delay, function() if IsValid(pPlayer) then begin_expand(pPlayer) end end)
    end)

    hook.Add("PropBreak", "liaPerformancePropBreak", function(_, entity) if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end end)
    hook.Add("EntityRemoved", "liaPerformanceEntityRemoved", function(ent) if ent:IsPlayer() then remove_player(ent) end end)
end

function widgets.PlayerTick()
end
