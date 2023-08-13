--------------------------------------------------------------------------------------------------------
DeriveGamemode("sandbox")
--------------------------------------------------------------------------------------------------------
PluginsLoaded = false
--------------------------------------------------------------------------------------------------------
GM.Name = "Lilia 2.0"
GM.Author = "Chessnut, Black Tea and Leonheart#7476"
GM.Website = "https://discord.gg/RTcVq92HsH"
GM.version = "1.0"

--------------------------------------------------------------------------------------------------------
function GM:Initialize()
    lia.module.initialize()
    lia.config.load()

    if CLIENT then
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
end

--------------------------------------------------------------------------------------------------------
function GM:OnReloaded()
    if CLIENT then
        hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
    else
        for _, client in ipairs(player.GetAll()) do
            hook.Run("CreateSalaryTimer", client)
        end
    end

    if not PluginsLoaded then
        lia.module.initialize()
        lia.config.load()
        PluginsLoaded = true
    end

    lia.faction.formatModelData()
end

--------------------------------------------------------------------------------------------------------
if SERVER and game.IsDedicated() then
    concommand.Remove("gm_save")

    concommand.Add("gm_save", function(client, command, arguments)
        print("COMMAND DISABLED")
    end)
end
--------------------------------------------------------------------------------------------------------