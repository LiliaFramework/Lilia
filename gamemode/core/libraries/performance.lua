function widgets.PlayerTick()
end

if SERVER then
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("LoadGModSave", "LoadGModSave")
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
    local interp = 0.01364
    local cmdlist = {
        mat_bumpmap = {0, function() return GetConVar("mat_bumpmap"):GetInt() end},
        rate = {100000, function() return GetConVar("rate"):GetInt() end},
        cl_updaterate = {30, function() return GetConVar("cl_updaterate"):GetInt() end},
        cl_cmdrate = {30, function() return GetConVar("cl_cmdrate"):GetInt() end},
        cl_interp = {interp, function() return GetConVar("cl_interp"):GetFloat() end},
        cl_interpolate = {0, function() return GetConVar("cl_interpolate"):GetInt() end},
        cl_interp_ratio = {0, function() return GetConVar("cl_interp_ratio"):GetInt() end},
        r_shadows = {1, function() return GetConVar("r_shadows"):GetInt() end},
        r_dynamic = {0, function() return GetConVar("r_dynamic"):GetInt() end},
        r_eyegloss = {0, function() return GetConVar("r_eyegloss"):GetInt() end},
        r_eyemove = {0, function() return GetConVar("r_eyemove"):GetInt() end},
        r_flex = {0, function() return GetConVar("r_flex"):GetInt() end},
        r_drawtracers = {0, function() return GetConVar("r_drawtracers"):GetInt() end},
        r_drawflecks = {0, function() return GetConVar("r_drawflecks"):GetInt() end},
        r_drawdetailprops = {0, function() return GetConVar("r_drawdetailprops"):GetInt() end},
        r_shadowrendertotexture = {0, function() return GetConVar("r_shadowrendertotexture"):GetInt() end},
        r_shadowmaxrendered = {0, function() return GetConVar("r_shadowmaxrendered"):GetInt() end},
        r_drawmodeldecals = {0, function() return GetConVar("r_drawmodeldecals"):GetInt() end},
        cl_phys_props_enable = {0, function() return GetConVar("cl_phys_props_enable"):GetInt() end},
        cl_phys_props_max = {0, function() return GetConVar("cl_phys_props_max"):GetInt() end},
        cl_threaded_bone_setup = {1, function() return GetConVar("cl_threaded_bone_setup"):GetInt() end},
        cl_threaded_client_leaf_system = {1, function() return GetConVar("cl_threaded_client_leaf_system"):GetInt() end},
        props_break_max_pieces = {0, function() return GetConVar("props_break_max_pieces"):GetInt() end},
        r_propsmaxdist = {0, function() return GetConVar("r_propsmaxdist"):GetInt() end},
        violence_agibs = {0, function() return GetConVar("violence_agibs"):GetInt() end},
        violence_hgibs = {0, function() return GetConVar("violence_hgibs"):GetInt() end},
        mat_shadowstate = {0, function() return GetConVar("mat_shadowstate"):GetInt() end},
        cl_show_splashes = {0, function() return GetConVar("cl_show_splashes"):GetInt() end},
        cl_ejectbrass = {0, function() return GetConVar("cl_ejectbrass"):GetInt() end},
        cl_detailfade = {800, function() return GetConVar("cl_detailfade"):GetInt() end},
        cl_smooth = {0, function() return GetConVar("cl_smooth"):GetInt() end},
        r_fastzreject = {-1, function() return GetConVar("r_fastzreject"):GetInt() end},
        r_decal_cullsize = {1, function() return GetConVar("r_decal_cullsize"):GetInt() end},
        r_lod = {0, function() return GetConVar("r_lod"):GetInt() end},
        cl_lagcompensation = {1, function() return GetConVar("cl_lagcompensation"):GetInt() end},
        r_spray_lifetime = {1, function() return GetConVar("r_spray_lifetime"):GetInt() end},
        mat_antialias = {0, function() return GetConVar("mat_antialias"):GetInt() end},
        cl_detaildist = {0, function() return GetConVar("cl_detaildist"):GetInt() end},
        cl_drawmonitors = {0, function() return GetConVar("cl_drawmonitors"):GetInt() end},
        mat_envmapsize = {0, function() return GetConVar("mat_envmapsize"):GetInt() end},
        mat_envmaptgasize = {0, function() return GetConVar("mat_envmaptgasize"):GetInt() end},
        mat_hdr_level = {0, function() return GetConVar("mat_hdr_level"):GetInt() end},
        mat_max_worldmesh_vertices = {512, function() return GetConVar("mat_max_worldmesh_vertices"):GetFloat() end},
        mat_motion_blur_enabled = {0, function() return GetConVar("mat_motion_blur_enabled"):GetInt() end},
        mat_parallaxmap = {0, function() return GetConVar("mat_parallaxmap"):GetInt() end},
        mat_picmip = {2, function() return GetConVar("mat_picmip"):GetInt() end},
        mat_reduceparticles = {1, function() return GetConVar("mat_reduceparticles"):GetInt() end},
        mp_decals = {1, function() return GetConVar("mp_decals"):GetInt() end},
        r_waterdrawreflection = {0, function() return GetConVar("r_waterdrawreflection"):GetInt() end},
        violence_ablood = {0, function() return GetConVar("violence_ablood"):GetInt() end},
        violence_hblood = {0, function() return GetConVar("violence_hblood"):GetInt() end},
        r_threaded_client_shadow_manager = {1, function() return GetConVar("r_threaded_client_shadow_manager"):GetInt() end},
        r_threaded_particles = {1, function() return GetConVar("r_threaded_particles"):GetInt() end},
        r_threaded_renderables = {1, function() return GetConVar("r_threaded_renderables"):GetInt() end},
        r_queued_decals = {1, function() return GetConVar("r_queued_decals"):GetInt() end},
        r_queued_ropes = {1, function() return GetConVar("r_queued_ropes"):GetInt() end},
        r_queued_post_processing = {1, function() return GetConVar("r_queued_post_processing"):GetInt() end},
        threadpool_affinity = {4, function() return GetConVar("threadpool_affinity"):GetInt() end},
        mat_queue_mode = {0, function() return GetConVar("mat_queue_mode"):GetInt() end},
        studio_queue_mode = {1, function() return GetConVar("studio_queue_mode"):GetInt() end},
        gmod_mcore_test = {1, function() return GetConVar("gmod_mcore_test"):GetInt() end}
    }

    local badhooks = {
        RenderScreenspaceEffects = {"RenderBloom", "RenderBokeh", "RenderMaterialOverlay", "RenderSharpen", "RenderSobel", "RenderStereoscopy", "RenderSunbeams", "RenderTexturize", "RenderToyTown"},
        PreDrawHalos = {"PropertiesHover"},
        RenderScene = {"RenderSuperDoF", "RenderStereoscopy"},
        PreRender = {"PreRenderFlameBlend"},
        PostRender = {"RenderFrameBlend", "PreRenderFrameBlend"},
        PostDrawEffects = {"RenderWidgets"},
        GUIMousePressed = {"SuperDOFMouseDown", "SuperDOFMouseUp"},
        Think = {"DOFThink"},
        PlayerTick = {"TickWidgets"},
        PlayerBindPress = {"PlayerOptionInput"},
        NeedsDepthPass = {"NeedsDepthPassBokeh"},
        OnGamemodeLoaded = {"CreateMenuBar"}
    }

    local function ApplyConvars()
        for name, data in pairs(cmdlist) do
            local convar = GetConVar(name)
            if convar then RunConsoleCommand(name, data[1]) end
        end
    end

    local function RemoveBadHooks()
        for h, rem in pairs(badhooks) do
            for _, id in ipairs(rem) do
                hook.Remove(h, id)
            end
        end
    end

    hook.Add("InitializedModules", "liaPerformanceInitializedModules", function()
        scripted_ents.GetStored("base_gmodentity").t.Think = nil
        ApplyConvars()
        RemoveBadHooks()
    end)
end

hook.Add("MouthMoveAnimation", "Optimization", function() return nil end)
hook.Add("GrabEarAnimation", "Optimization", function() return nil end)
