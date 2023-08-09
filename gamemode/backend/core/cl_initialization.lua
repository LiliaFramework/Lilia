--------------------------------------------------------------------------------------------------------
function GM:Initialize()
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
end
--------------------------------------------------------------------------------------------------------
function GM:InitPostEntity()
    lia.joinTime = RealTime() - 0.9716
    lia.faction.formatModelData()
	if system.IsWindows() and not system.HasFocus() then
        system.FlashWindow()
    end
end
--------------------------------------------------------------------------------------------------------
function GM:InitializedConfig()
    hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    if hook.Run("ShouldCreateLoadingScreen") ~= false then hook.Run("CreateLoadingScreen") end
    print("LOADED CONFIG!")
end
--------------------------------------------------------------------------------------------------------
function GM:LiliaLoaded()
    local namecache = {}
    for _, MODULE in pairs(lia.module.list) do
        local authorID = (tonumber(MODULE.author) and tostring(MODULE.author)) or (string.match(MODULE.author, "STEAM_") and util.SteamIDTo64(MODULE.author)) or nil
        if authorID then
            if namecache[authorID] ~= nil then
                MODULE.author = namecache[authorID]
            else
                steamworks.RequestPlayerInfo(
                    authorID,
                    function(newName)
                        namecache[authorID] = newName
                        MODULE.author = newName or MODULE.author
                    end
                )
            end
        end
    end

    lia.module.namecache = namecache
end
--------------------------------------------------------------------------------------------------------
timer.Remove("HintSystem_OpeningMenu")
timer.Remove("HintSystem_Annoy1")
timer.Remove("HintSystem_Annoy2")
--------------------------------------------------------------------------------------------------------
CreateConVar("cl_weaponcolor", "0.30 1.80 2.10", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")
--------------------------------------------------------------------------------------------------------
local useCheapBlur = CreateClientConVar("lia_cheapblur", 0, true):GetBool()
--------------------------------------------------------------------------------------------------------
cvars.AddChangeCallback("lia_cheapblur", function(name, old, new)
    useCheapBlur = (tonumber(new) or 0) > 0
end)
--------------------------------------------------------------------------------------------------------