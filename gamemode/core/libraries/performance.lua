if SERVER then
    local serverCommands = {"mp_show_voice_icons 0", "net_maxfilesize 64", "sv_kickerrornum 0", "sv_allowupload 0", "sv_allowdownload 0", "sv_allowcslua 0", "gmod_physiterations 4", "sbox_noclip 0", "sv_maxrate 30000", "sv_minrate 5000", "sv_maxcmdrate 66", "sv_maxupdaterate 66", "sv_mincmdrate 30"}
    local serverHooks = {{"OnEntityCreated", "WidgetInit"}, {"Think", "DOFThink"}, {"Think", "CheckSchedules"}, {"PlayerTick", "TickWidgets"}, {"PlayerInitialSpawn", "PlayerAuthSpawn"}, {"LoadGModSave", "LoadGModSave"}, {"PlayerInitialSpawn", "HintSystem_PlayerInitialSpawn"}, {"PlayerSpawn", "HintSystem_PlayerSpawn"}}
    local function ExecuteCommands()
        for _, cmd in ipairs(serverCommands) do
            local parts = string.Split(cmd, " ")
            RunConsoleCommand(parts[1], unpack(parts, 2))
        end
    end

    local function RemoveHooks()
        for _, h in ipairs(serverHooks) do
            hook.Remove(h[1], h[2])
        end
    end

    function widgets.PlayerTick()
    end

    hook.Add("Initialize", "liaPerformanceInitialize", function()
        RemoveHooks()
        ExecuteCommands()
    end)

    hook.Add("OnReloaded", "liaPerformanceReloaded", function()
        RemoveHooks()
        ExecuteCommands()
    end)

    hook.Add("PropBreak", "liaPerformancePropBreak", function(_, entity) if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end end)
else
    local changes = {
        async_mode = 0,
        snd_mix_async = 1,
        mat_queue_mode = 2,
        gmod_mcore_test = 1,
        spawnicon_queue = 1,
        studio_queue_mode = 1,
        snd_async_fullyasync = 1,
        mod_load_mesh_async = 1,
        mod_load_anims_async = 1,
        mod_load_vcollide_async = 1,
        cl_threaded_bone_setup = 1,
        cl_threaded_client_leaf_system = 1,
        r_fastzreject = 1,
        r_queued_ropes = 1,
        r_queued_decals = 1,
        r_threaded_particles = 1,
        r_threaded_renderables = 1,
        r_queued_post_processing = 1,
        r_threaded_client_shadow_manager = 1,
        r_dynamic = 0,
        r_dynamiclighting = 0,
        mat_reduceparticles = 1,
        r_decals = 25,
        prop_active_gib_limit = 0,
        net_queued_packet_thread = 1,
        net_splitpacket_maxrate = 2097152,
        net_udp_recvbuf = 131072,
        net_maxroutable = 1260,
        net_maxfragments = 1792,
        net_compresspackets = 1,
        net_compresspackets_minsize = 25000,
    }

    local function removeHooks()
        hook.Remove("Think", "DOFThink")
        hook.Remove("RenderScene", "RenderSuperDoF")
        hook.Remove("PostRender", "RenderFrameBlend")
        hook.Remove("PreRender", "PreRenderFrameBlend")
        hook.Remove("PostDrawEffects", "RenderWidgets")
        hook.Remove("RenderScene", "RenderStereoscopy")
        hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
        hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
        hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
        hook.Remove("RenderScreenspaceEffects", "RenderBloom")
        hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
        hook.Remove("RenderScreenspaceEffects", "RenderToyTown")
        hook.Remove("RenderScreenspaceEffects", "RenderSunbeams")
        hook.Remove("RenderScreenspaceEffects", "RenderMotionBlur")
        hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    end

    local function runCommands()
        for cvar, value in pairs(changes) do
            RunConsoleCommand(cvar, value)
        end
    end

    local function disableWidgets()
        hook.Remove("PlayerTick", "TickWidgets")
    end

    local function enableEnhancements()
        removeHooks()
        runCommands()
        disableWidgets()
    end

    hook.Add("InitPostEntity", "liaPerformanceClientEnhancements", function() enableEnhancements() end)
end
