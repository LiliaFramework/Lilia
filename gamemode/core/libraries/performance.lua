local performanceConfig = {
    ["server"] = {
        ["convars"] = {
            net_maxfilesize = 64,
            sv_kickerrornum = 0,
            sv_allowupload = 0,
            sv_allowdownload = 0,
            sv_allowcslua = 0,
            gmod_physiterations = 4,
            sbox_noclip = 0,
            sv_maxrate = 30000,
            sv_minrate = 5000,
            sv_maxcmdrate = 66,
            sv_maxupdaterate = 66,
            sv_mincmdrate = 30
        },
        ["hooks"] = {
            OnEntityCreated = {"WidgetInit"},
            Think = {"DOFThink", "CheckSchedules"},
            PlayerTick = {"TickWidgets"},
            PlayerInitialSpawn = {"PlayerAuthSpawn", "HintSystem_PlayerInitialSpawn"},
            LoadGModSave = {"LoadGModSave"},
            PlayerSpawn = {"HintSystem_PlayerSpawn"}
        }
    },
    ["client"] = {
        ["convars"] = {
            -- Network & Rate Settings
            mat_bumpmap = 0, -- Disables bump mapping (texture detail that creates 3D surface effects)
            rate = 1048576, -- Sets network data rate to 1MB/s (maximum bandwidth)
            cl_updaterate = 66, -- Client updates per second from server (tick rate)
            r_drawmodeldecals = 1, -- Enables decals on models (bullet holes, blood splatters)
            cl_cmdrate = 66, -- Client commands sent to server per second
            cl_interp = 0.01364, -- Interpolation delay for smoothing network entities (~13.6ms)
            cl_interp_ratio = 2, -- Interpolation multiplier (2 ÷ 66 = ~30ms total interpolation)
            -- Rendering & Visual Quality
            r_shadows = 1, -- Enables basic shadow rendering
            r_dynamic = 0, -- Disables dynamic lighting from lights/flashlights
            r_eyemove = 0, -- Disables eye movement on player models
            r_flex = 0, -- Disables facial flex animations/expressions
            r_drawflecks = 0, -- Disables small particle effects (bullet impacts, debris)
            r_drawdetailprops = 0, -- Disables small detail props (grass, debris)
            r_shadowrendertotexture = 0, -- Disables high-quality shadow rendering
            r_shadowmaxrendered = 0, -- Limits maximum shadows rendered
            r_fastzreject = -1, -- Optimizes Z-buffer rejection for performance
            -- Level of Detail (LOD) & Optimization
            cl_phys_props_enable = 0, -- Disables client-side physics props
            cl_phys_props_max = 0, -- Sets maximum physics props to 0
            cl_threaded_bone_setup = 1, -- Enables multi-threaded bone animation calculations
            props_break_max_pieces = 0, -- Disables prop breaking into pieces
            r_lod = 0, -- Sets level of detail distance (0 = highest quality)
            cl_lagcompensation = 1, -- Enables lag compensation for better hit detection
            -- Violence & Effects
            violence_agibs = 0, -- Disables alien gibs (body parts)
            violence_hgibs = 0, -- Disables human gibs
            cl_show_splashes = 0, -- Disables water splash effects
            cl_ejectbrass = 0, -- Disables shell casing ejection from weapons
            violence_ablood = 0, -- Disables alien blood
            violence_hblood = 0, -- Disables human blood
            -- Detail & Distance
            cl_detailfade = 800, -- Distance at which details begin fading
            cl_smooth = 0, -- Disables entity smoothing for network interpolation
            cl_detaildist = 0, -- Distance at which detail props are visible
            cl_drawmonitors = 0, -- Disables rendering of in-game monitors/screens
            r_spray_lifetime = 1, -- Sets spray paint lifetime in seconds
            -- Material & Texture Settings
            mat_antialias = 0, -- Disables anti-aliasing
            mat_envmapsize = 0, -- Disables environment maps (reflections)
            mat_envmaptgasize = 0, -- Sets environment map texture size to 0
            mat_hdr_level = 0, -- Disables HDR (High Dynamic Range) lighting
            mat_motion_blur_enabled = 0, -- Disables motion blur effects
            mat_reduceparticles = 1, -- Reduces particle effects count
            mp_decals = 1, -- Limits multiplayer decals to 1
            r_waterdrawreflection = 0, -- Disables water reflections
            -- Multi-threading & Performance
            r_threaded_particles = 1, -- Enables multi-threaded particle rendering
            r_queued_ropes = 1, -- Enables queued rope rendering for performance
            threadpool_affinity = 64, -- Sets thread pool CPU affinity
            mat_queue_mode = 2, -- Enables multi-threaded material system
            studio_queue_mode = 1, -- Enables queued model rendering
            gmod_mcore_test = 1, -- Enables experimental multi-core support
            -- Memory & System
            mem_max_heapsize_dedicated = 131072, -- Sets dedicated server heap size to 128MB
            mem_min_heapsize = 131072, -- Sets minimum heap size to 128MB
            mat_powersavingsmode = 0, -- Disables power saving mode
            cl_timeout = 3600, -- Sets client timeout to 1 hour
            cl_smoothtime = 0.05, -- Sets smoothing interpolation time
            -- Advanced Optimizations
            cl_localnetworkbackdoor = 1, -- Enables local network optimization
            ai_expression_optimization = 1, -- Optimizes AI facial expressions
            filesystem_max_stdio_read = 64, -- Limits file system read operations
            in_usekeyboardsampletime = 1, -- Uses keyboard sample time for input
            r_radiosity = 4, -- Sets radiosity lighting quality
            mat_framebuffercopyoverlaysize = 0, -- Disables framebuffer overlay copying
            mat_managedtextures = 0, -- Disables managed texture system
            fast_fogvolume = 1, -- Enables fast fog volume rendering
            filesystem_unbuffered_io = 0 -- Uses buffered I/O for file operations
        },
        ["hooks"] = {
            RenderScreenspaceEffects = {"RenderBloom", "RenderBokeh", "RenderMaterialOverlay", "RenderSharpen", "RenderSobel", "RenderStereoscopy", "RenderSunbeams", "RenderTexturize", "RenderToyTown"},
            PreDrawHalos = {"PropertiesHover"},
            RenderScene = {"RenderSuperDoF", "RenderStereoscopy"},
            PreRender = {"PreRenderFlameBlend", "PreRenderFrameBlend"},
            PostRender = {"RenderFrameBlend"},
            PostDrawEffects = {"RenderWidgets", "RenderHalos"},
            GUIMousePressed = {"SuperDOFMouseDown", "SuperDOFMouseUp"},
            GUIMouseReleased = {"SuperDOFMouseUp"},
            PreventScreenClicks = {"SuperDOFPreventClicks"},
            Think = {"DOFThink", "CheckSchedules"},
            PlayerTick = {"TickWidgets"},
            PlayerBindPress = {"PlayerOptionInput"},
            NeedsDepthPass = {"NeedsDepthPassBokeh", "NeedsDepthPass_Bokeh"},
            OnGamemodeLoaded = {"CreateMenuBar"},
            HUDPaint = {"DamageEffect"},
            StartChat = {"StartChatIndicator"},
            FinishChat = {"EndChatIndicator"},
            OnEntityCreated = {"WidgetInit"}
        }
    }
}

if SERVER then
    hook.Add("PropBreak", "liaPerformancePropBreak", function(_, entity) if IsValid(entity) and IsValid(entity:GetPhysicsObject()) then constraint.RemoveAll(entity) end end)
else
    local memory = 768432
    local printMemory = false
    local function PrintMemory(message)
        if not printMemory then return end
        MsgC(Color(115, 148, 248), message .. "\n")
    end

    local function ClearLuaMemory()
        local mem = collectgarbage("count")
        PrintMemory("Active Lua Memory : " .. math.Round(mem / 1024) .. " MB.")
        if mem >= math.Clamp(memory, 262144, 978944) then
            collectgarbage("collect")
            local nmem = collectgarbage("count")
            PrintMemory("Removed " .. math.Round((mem - nmem) / 1024) .. " MB from active memory.")
        end
    end

    concommand.Add("luamemory", function()
        local LuaMem = collectgarbage("count")
        PrintMemory("Active Lua Memory : " .. math.Round(LuaMem / 1024) .. " MB.")
    end)

    timer.Create("lua_gc", 60, 0, ClearLuaMemory)
end

local function ApplyConvars()
    for name, value in pairs(SERVER and performanceConfig.server.convars or performanceConfig.client.convars) do
        RunConsoleCommand(name, value)
    end
end

local function RemoveBadHooks()
    local hooks = SERVER and performanceConfig.server.hooks or performanceConfig.client.hooks
    for hookName, hookList in pairs(hooks) do
        if isstring(hookName) and istable(hookList) then
            for _, id in ipairs(hookList) do
                if isstring(id) then hook.Remove(hookName, id) end
            end
        end
    end
end

hook.Add("InitializedModules", "liaPerformanceInitializedModules", function()
    local options = {
        shadows = "r_shadows",
        dynamicLighting = "r_dynamic",
        eyeMovement = "r_eyemove",
        facialExpressions = "r_flex",
        antiAliasing = "mat_antialias",
        hdrLighting = "mat_hdr_level",
        motionBlur = "mat_motion_blur_enabled",
        waterReflections = "r_waterdrawreflection",
        gameMonitors = "cl_drawmonitors",
        alienBlood = "violence_ablood",
        humanBlood = "violence_hblood",
        alienGibs = "violence_agibs",
        humanGibs = "violence_hgibs",
        waterSplashes = "cl_show_splashes",
        shellEjection = "cl_ejectbrass",
        modelDecals = "r_drawmodeldecals",
        multiplayerDecals = "mp_decals",
        detailFadeDistance = "cl_detailfade",
        detailDistance = "cl_detaildist",
        networkSmoothing = "cl_smooth",
        smoothingTime = "cl_smoothtime"
    }

    local voiceIconsValue = lia.config.get("voiceIcons", false)
    RunConsoleCommand("mp_show_voice_icons", voiceIconsValue and 1 or 0)
    if lia.config.get("mouthMoveAnimation", true) then
        hook.Add("MouthMoveAnimation", "Optimization", function() return nil end)
    else
        hook.Remove("MouthMoveAnimation", "Optimization")
    end

    if lia.config.get("grabEarAnimation", true) then
        hook.Add("GrabEarAnimation", "Optimization", function() return nil end)
    else
        hook.Remove("GrabEarAnimation", "Optimization")
    end

    ApplyConvars()
    RemoveBadHooks()
    if SERVER then
        for name, value in pairs(performanceConfig.server.convars) do
            RunConsoleCommand(name, value)
        end

        hook.Remove("Think", "CheckSchedules")
        hook.Remove("LoadGModSave", "LoadGModSave")
    else
        for optionName, convar in pairs(options) do
            local value = lia.config.get(optionName, nil)
            if value ~= nil then
                if isbool(value) then
                    RunConsoleCommand(convar, value and "1" or "0")
                else
                    RunConsoleCommand(convar, tostring(value))
                end
            end
        end
    end

    scripted_ents.GetStored("base_gmodentity").t.Think = nil
end)