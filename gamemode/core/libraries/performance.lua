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
            mat_bumpmap = 0,
            rate = 1048576,
            cl_updaterate = 66,
            r_drawmodeldecals = 1,
            cl_cmdrate = 66,
            cl_interp = 0.01364,
            cl_interp_ratio = 2,
            r_shadows = 1,
            r_dynamic = 0,
            r_eyemove = 0,
            r_flex = 0,
            r_drawflecks = 0,
            r_drawdetailprops = 0,
            r_shadowrendertotexture = 0,
            r_shadowmaxrendered = 0,
            r_fastzreject = -1,
            cl_phys_props_enable = 0,
            cl_phys_props_max = 0,
            cl_threaded_bone_setup = 1,
            props_break_max_pieces = 0,
            r_lod = 0,
            cl_lagcompensation = 1,
            violence_agibs = 0,
            violence_hgibs = 0,
            cl_show_splashes = 0,
            cl_ejectbrass = 0,
            violence_ablood = 0,
            violence_hblood = 0,
            cl_detailfade = 800,
            cl_smooth = 0,
            cl_detaildist = 0,
            cl_drawmonitors = 0,
            r_spray_lifetime = 1,
            mat_antialias = 0,
            mat_envmapsize = 0,
            mat_envmaptgasize = 0,
            mat_hdr_level = 0,
            mat_motion_blur_enabled = 0,
            mat_reduceparticles = 1,
            mp_decals = 1,
            r_waterdrawreflection = 0,
            r_threaded_particles = 1,
            r_queued_ropes = 1,
            threadpool_affinity = 64,
            mat_queue_mode = 2,
            studio_queue_mode = 1,
            gmod_mcore_test = 1,
            mem_max_heapsize_dedicated = 131072,
            mem_min_heapsize = 131072,
            mat_powersavingsmode = 0,
            cl_timeout = 3600,
            cl_smoothtime = 0.05,
            cl_localnetworkbackdoor = 1,
            ai_expression_optimization = 1,
            filesystem_max_stdio_read = 64,
            in_usekeyboardsampletime = 1,
            r_radiosity = 4,
            mat_framebuffercopyoverlaysize = 0,
            mat_managedtextures = 0,
            fast_fogvolume = 1,
            filesystem_unbuffered_io = 0
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
