local serverCommands = {"mp_show_voice_icons 0", "net_maxfilesize 64", "sv_kickerrornum 0", "sv_allowupload 0", "sv_allowdownload 0", "sv_allowcslua 0", "gmod_physiterations 4", "sbox_noclip 0", "sv_maxrate 30000", "sv_minrate 5000", "sv_maxcmdrate 66", "sv_maxupdaterate 66", "sv_mincmdrate 30"}
local clientCommands = {"gmod_mcore_test 1", "mem_max_heapsize_dedicated 131072", "mem_min_heapsize 131072", "threadpool_affinity 64", "mat_queue_mode 2", "mat_powersavingsmode 0", "r_queued_ropes 1", "r_threaded_particles 1", "cl_threaded_bone_setup 1", "cl_lagcompensation 1", "cl_timeout 3600", "cl_smoothtime 0.05", "cl_localnetworkbackdoor 1", "cl_cmdrate 66", "cl_updaterate 66", "cl_interp_ratio 2", "studio_queue_mode 1", "ai_expression_optimization 1", "filesystem_max_stdio_read 64", "in_usekeyboardsampletime 1", "r_radiosity 4", "rate 1048576", "mat_framebuffercopyoverlaysize 0", "mat_managedtextures 0", "fast_fogvolume 1", "filesystem_unbuffered_io 0"}
local serverHooks = {{"OnEntityCreated", "WidgetInit"}, {"Think", "DOFThink"}, {"Think", "CheckSchedules"}, {"PlayerTick", "TickWidgets"}, {"PlayerInitialSpawn", "PlayerAuthSpawn"}, {"LoadGModSave", "LoadGModSave"}, {"PlayerInitialSpawn", "HintSystem_PlayerInitialSpawn"}, {"PlayerSpawn", "HintSystem_PlayerSpawn"}}
local clientHooks = {{"HUDPaint", "DamageEffect"}, {"StartChat", "StartChatIndicator"}, {"FinishChat", "EndChatIndicator"}, {"PostDrawEffects", "RenderWidgets"}, {"PostDrawEffects", "RenderHalos"}, {"OnEntityCreated", "WidgetInit"}, {"GUIMousePressed", "SuperDOFMouseDown"}, {"GUIMouseReleased", "SuperDOFMouseUp"}, {"PreventScreenClicks", "SuperDOFPreventClicks"}, {"Think", "DOFThink"}, {"Think", "CheckSchedules"}, {"NeedsDepthPass", "NeedsDepthPass_Bokeh"}, {"RenderScene", "RenderSuperDoF"}, {"RenderScene", "RenderStereoscopy"}, {"PreRender", "PreRenderFrameBlend"}, {"PostRender", "RenderFrameBlend"}, {"RenderScreenspaceEffects", "RenderBokeh"}}
local function ExecuteCommands(isServer)
    if isServer then
        for i, cmd in ipairs(serverCommands) do
            timer.Simple(i * 0.1, function() game.ConsoleCommand(cmd .. "\n") end)
        end
    else
        for i, cmd in ipairs(clientCommands) do
            timer.Simple(i * 0.1, function()
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
            end)
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

function widgets.PlayerTick()
end

hook.Add("Initialize", "liaPerformanceInitialize", function()
    RemoveHooks(SERVER)
    ExecuteCommands(SERVER)
end)

if CLIENT then
    hook.Add("InitializedModules", "liaPerformanceInitializedModules", function() scripted_ents.GetStored("base_gmodentity").t.Think = nil end)
    local function DisableWidgetRendering()
        hook.Remove("PostDrawEffects", "RenderWidgets")
        if RenderWidgets then RenderWidgets = function() end end
    end

    DisableWidgetRendering()
    hook.Add("Initialize", "liaDisableWidgets", DisableWidgetRendering)
    timer.Create("liaRemoveWidgetHook", 0.1, 0, function() hook.Remove("PostDrawEffects", "RenderWidgets") end)
else
    hook.Add("PropBreak", "liaPerformancePropBreak", function(_, entity) if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end end)
end
