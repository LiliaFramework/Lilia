local serverCommands = {
    "net_maxfilesize 64", -- Sets the maximum network file size
    "sv_kickerrornum 0", -- Disables kicking players on error
    "sv_allowupload 0", -- Disables uploading of files by clients
    "sv_allowdownload 0", -- Disables downloading of files by clients
    "sv_allowcslua 0", -- Disables client-side Lua execution
    "gmod_physiterations 2", -- Sets the number of physics iterations
    "sbox_noclip 0", -- Disables noclip for sandbox mode
}

local clientCommands = {
    "gmod_mcore_test 1", -- Enables multi-core testing
    "mem_max_heapsize 131072", -- Sets maximum heap size
    "mem_max_heapsize_dedicated 131072", -- Sets max heap size for dedicated servers
    "mem_min_heapsize 131072", -- Sets minimum heap size
    "threadpool_affinity 64", -- Sets thread pool affinity
    "mat_queue_mode 2", -- Sets material queue mode to multi-threaded
    "mat_powersavingsmode 0", -- Disables power saving mode for materials
    "r_queued_ropes 1", -- Enables queued ropes rendering
    "r_threaded_renderables 1", -- Enables threaded renderables
    "r_threaded_particles 1", -- Enables threaded particles
    "r_threaded_client_shadow_manager 1", -- Enables threaded client shadow manager
    "cl_threaded_client_leaf_system 1", -- Enables threaded client leaf system
    "cl_threaded_bone_setup 1", -- Enables threaded bone setup
    "cl_forcepreload 1", -- Forces preloading of models and materials
    "cl_lagcompensation 1", -- Enables client-side lag compensation
    "cl_timeout 3600", -- Sets client timeout to 3600 seconds
    "cl_smoothtime 0.05", -- Sets client smooth time
    "cl_localnetworkbackdoor 1", -- Enables local network backdoor
    "cl_cmdrate 66", -- Sets client command rate
    "cl_updaterate 66", -- Sets client update rate
    "cl_interp_ratio 2", -- Sets client interpolation ratio
    "studio_queue_mode 1", -- Sets studio queue mode for models
    "ai_expression_optimization 1", -- Optimizes AI expressions
    "filesystem_max_stdio_read 64", -- Sets max filesystem stdio reads
    "in_usekeyboardsampletime 1", -- Sets sample time for keyboard input
    "r_radiosity 4", -- Sets radiosity quality
    "rate 1048576", -- Sets network data rate
    "mat_frame_sync_enable 0", -- Disables frame synchronization for materials
    "mat_framebuffercopyoverlaysize 0", -- Sets frame buffer copy overlay size
    "mat_managedtextures 0", -- Disables managed textures
    "fast_fogvolume 1", -- Enables fast fog volume rendering
    "lod_TransitionDist 2000", -- Sets level of detail transition distance
    "filesystem_unbuffered_io 0", -- Disables unbuffered I/O for filesystem
}

local serverHooks = {
    {
        "OnEntityCreated", -- Removes widget initialization when an entity is created
        "WidgetInit"
    },
    {
        "Think", -- Removes depth of field thinking
        "DOFThink"
    },
    {
        "Think", -- Removes schedule checking in the think hook
        "CheckSchedules"
    },
    {
        "PlayerTick", -- Removes widget ticking for players
        "TickWidgets"
    },
    {
        "PlayerInitialSpawn", -- Removes player authentication on spawn
        "PlayerAuthSpawn"
    },
    {
        "LoadGModSave", -- Removes loading of Garry's Mod save files
        "LoadGModSave"
    }
}

local clientHooks = {
    {
        "StartChat", -- Removes chat indicator on chat start
        "StartChatIndicator"
    },
    {
        "FinishChat", -- Removes chat indicator on chat finish
        "EndChatIndicator"
    },
    {
        "PostDrawEffects", -- Removes rendering of widgets after drawing effects
        "RenderWidgets"
    },
    {
        "PostDrawEffects", -- Removes halo rendering after drawing effects
        "RenderHalos"
    },
    {
        "OnEntityCreated", -- Removes widget initialization when an entity is created
        "WidgetInit"
    },
    {
        "GUIMousePressed", -- Removes SuperDOF mouse down functionality
        "SuperDOFMouseDown"
    },
    {
        "GUIMouseReleased", -- Removes SuperDOF mouse up functionality
        "SuperDOFMouseUp"
    },
    {
        "PreventScreenClicks", -- Prevents screen clicks for SuperDOF
        "SuperDOFPreventClicks"
    },
    {
        "Think", -- Removes depth of field thinking
        "DOFThink"
    },
    {
        "Think", -- Removes schedule checking in the think hook
        "CheckSchedules"
    },
    {
        "NeedsDepthPass", -- Removes depth pass for Bokeh effect
        "NeedsDepthPass_Bokeh"
    },
    {
        "RenderScene", -- Removes SuperDOF scene rendering
        "RenderSuperDoF"
    },
    {
        "RenderScene", -- Removes stereoscopy scene rendering
        "RenderStereoscopy"
    },
    {
        "PreRender", -- Removes frame blending before rendering
        "PreRenderFrameBlend"
    },
    {
        "PostRender", -- Removes frame blending after rendering
        "RenderFrameBlend"
    },
    {
        "RenderScreenspaceEffects", -- Removes Bokeh effects in screenspace
        "RenderBokeh"
    }
}

local function ExecuteCommands(IsServer)
    if IsServer then
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

local function RemoveHooks(IsServer)
    if IsServer then
        for _, hookData in ipairs(serverHooks) do
            hook.Remove(hookData[1], hookData[2])
        end
    else
        for _, hookData in ipairs(clientHooks) do
            hook.Remove(hookData[1], hookData[2])
        end
    end
end

local function RemoveHintTimers()
    local hintTimers = {"HintSystem_OpeningMenu", "HintSystem_Annoy1", "HintSystem_Annoy2"}
    for _, timerName in ipairs(hintTimers) do
        if timer.Exists(timerName) then timer.Remove(timerName) end
    end
end

function MODULE:Initialize()
    RemoveHintTimers()
    ExecuteCommands(SERVER)
end

function GM:OnReloaded()
    RemoveHintTimers()
    RemoveHooks(SERVER)
    ExecuteCommands(SERVER)
end