local serverCommands = {
    -- Disables the voice chat indicator, so players won't see a speaker icon next to player names when they use voice chat
    "mp_show_voice_icons 0",
    -- Sets the maximum file size (in MB) that can be sent over the network, helping to prevent excessively large files from being shared
    "net_maxfilesize 64",
    -- Prevents kicking players for Lua errors, ensuring that temporary script issues won't disrupt gameplay
    "sv_kickerrornum 0",
    -- Disables file uploads from clients to the server, improving security by preventing potential malicious files
    "sv_allowupload 0",
    -- Disables file downloads from the server to clients, ensuring only essential game data is shared
    "sv_allowdownload 0",
    -- Blocks client-side Lua execution for security, stopping players from running unauthorized scripts
    "sv_allowcslua 0",
    -- Reduces physics calculations per tick, which can improve server performance at the cost of slightly less accurate physics interactions
    "gmod_physiterations 2",
    -- Disables noclip mode in sandbox, preventing players from flying through the map unless explicitly allowed
    "sbox_noclip 0",
}

local clientCommands = {
    -- Disables the voice chat indicator for the client, hiding the speaker icon when someone uses voice chat
    "mp_show_voice_icons 0",
    -- Enables multi-core rendering, allowing the game to use more than one CPU core for rendering and improving frame rates
    "gmod_mcore_test 1",
    -- Sets the maximum memory heap size (in KB), helping the game allocate sufficient memory for optimal performance
    "mem_max_heapsize 131072",
    -- Sets the heap size for dedicated server memory, ensuring stable performance for clients connected to the server
    "mem_max_heapsize_dedicated 131072",
    -- Sets the minimum heap size (in KB) that the game can allocate for operations
    "mem_min_heapsize 131072",
    -- Adjusts CPU thread usage, potentially optimizing performance on systems with multiple cores
    "threadpool_affinity 64",
    -- Enables multi-threaded material rendering, speeding up graphical operations by distributing work across threads
    "mat_queue_mode 2",
    -- Turns off power-saving mode for rendering, ensuring maximum visual quality and performance
    "mat_powersavingsmode 0",
    -- Optimizes rope physics rendering by queuing operations for better performance
    "r_queued_ropes 1",
    -- Enables multi-threading for rendering entities in the game world, improving frame rates in populated areas
    "r_threaded_renderables 1",
    -- Enables multi-threaded particle rendering, making effects like smoke and explosions render more efficiently
    "r_threaded_particles 1",
    -- Allows the shadow manager to use multiple threads, enhancing shadow rendering speed and smoothness
    "r_threaded_client_shadow_manager 1",
    -- Improves performance by enabling multi-threading for the client-side leaf system (used for spatial partitioning in rendering)
    "cl_threaded_client_leaf_system 1",
    -- Speeds up animations by processing bone setup operations on multiple threads
    "cl_threaded_bone_setup 1",
    -- Forces models and materials to preload when the game starts, reducing stutter caused by on-demand loading
    "cl_forcepreload 1",
    -- Turns on lag compensation for smoother gameplay by accounting for network delays
    "cl_lagcompensation 1",
    -- Sets the timeout duration (in seconds) before the client is disconnected from the server due to inactivity
    "cl_timeout 3600",
    -- Reduces input lag by adjusting the time smoothing factor, improving response time for actions
    "cl_smoothtime 0.05",
    -- Optimizes local network communication for improved latency in LAN games
    "cl_localnetworkbackdoor 1",
    -- Adjusts the rate at which the client sends commands to the server, matching the server's tickrate
    "cl_cmdrate 66",
    -- Sets how often the client expects updates from the server, ensuring smooth gameplay at higher tick rates
    "cl_updaterate 66",
    -- Controls the interpolation factor for networked entity movement, balancing smoothness and responsiveness
    "cl_interp_ratio 2",
    -- Enhances model rendering performance by queuing studio model operations
    "studio_queue_mode 1",
    -- Optimizes AI expressions by simplifying or skipping unnecessary computations
    "ai_expression_optimization 1",
    -- Limits filesystem operations, reducing overhead when reading or writing files
    "filesystem_max_stdio_read 64",
    -- Improves input responsiveness by reducing keyboard sample time
    "in_usekeyboardsampletime 1",
    -- Enhances radiosity lighting quality for more realistic global illumination effects
    "r_radiosity 4",
    -- Sets the maximum amount of network data the client can send or receive per second
    "rate 1048576",
    -- Disables frame synchronization for materials, which can improve performance at the cost of visual smoothness
    "mat_frame_sync_enable 0",
    -- Adjusts the size of the frame buffer copy overlay, which can reduce memory usage
    "mat_framebuffercopyoverlaysize 0",
    -- Disables managed textures to optimize rendering performance on certain systems
    "mat_managedtextures 0",
    -- Enables faster rendering of fog effects, which can improve performance in maps with volumetric fog
    "fast_fogvolume 1",
    -- Adjusts when the game transitions between different levels of detail (LOD) for objects in the world
    "lod_TransitionDist 2000",
    -- Uses buffered I/O for file operations to improve performance on systems with slower storage
    "filesystem_unbuffered_io 0",
}

local serverHooks = {
    -- Prevents unnecessary widget setup when new entities spawn, reducing overhead
    {"OnEntityCreated", "WidgetInit"},
    -- Disables depth of field (DOF) effects, which can improve rendering performance
    {"Think", "DOFThink"},
    -- Stops schedule checking for AI and scripted entities, reducing server load
    {"Think", "CheckSchedules"},
    -- Prevents player widget updates, which are rarely used and can cause unnecessary overhead
    {"PlayerTick", "TickWidgets"},
    -- Skips player authentication checks on spawn, speeding up the process
    {"PlayerInitialSpawn", "PlayerAuthSpawn"},
    -- Disables loading saved games from the server, which can prevent compatibility issues
    {"LoadGModSave", "LoadGModSave"},
}

local clientHooks = {
    -- Removes the Damage Effect
    {"HUDPaint", "DamageEffect"},
    -- Removes the chat icon when a player starts typing in chat
    {"StartChat", "StartChatIndicator"},
    -- Removes the chat icon after the player finishes typing
    {"FinishChat", "EndChatIndicator"},
    -- Disables rendering of widgets during post-draw effects, which can improve performance
    {"PostDrawEffects", "RenderWidgets"},
    -- Prevents the game from rendering glowing outlines (halos) around objects, saving rendering resources
    {"PostDrawEffects", "RenderHalos"},
    -- Prevents widget initialization for newly created entities
    {"OnEntityCreated", "WidgetInit"},
    -- Disables SuperDOF interactions when the mouse button is pressed
    {"GUIMousePressed", "SuperDOFMouseDown"},
    -- Disables SuperDOF interactions when the mouse button is released
    {"GUIMouseReleased", "SuperDOFMouseUp"},
    -- Prevents clicks on the screen from triggering SuperDOF effects
    {"PreventScreenClicks", "SuperDOFPreventClicks"},
    -- Disables depth of field effects during the Think process
    {"Think", "DOFThink"},
    -- Stops unnecessary schedule checks for AI and scripted entities
    {"Think", "CheckSchedules"},
    -- Removes the depth pass required for rendering advanced Bokeh effects
    {"NeedsDepthPass", "NeedsDepthPass_Bokeh"},
    -- Disables rendering of SuperDOF effects in the scene
    {"RenderScene", "RenderSuperDoF"},
    -- Turns off stereoscopic rendering for VR or 3D effects
    {"RenderScene", "RenderStereoscopy"},
    -- Stops pre-render blending, which smooths transitions between frames but costs performance
    {"PreRender", "PreRenderFrameBlend"},
    -- Disables post-render blending, which smooths the final frame output at a performance cost
    {"PostRender", "RenderFrameBlend"},
    -- Prevents the game from rendering advanced Bokeh effects in screenspace, saving resources
    {"RenderScreenspaceEffects", "RenderBokeh"},
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

function MODULE:OnReloaded()
    RemoveHintTimers()
    RemoveHooks(SERVER)
    ExecuteCommands(SERVER)
end

function widgets.PlayerTick()
end
