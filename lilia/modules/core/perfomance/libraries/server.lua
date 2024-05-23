function MODULE:ServerSidePlayerInitialSpawn()
    local music = ents.FindByName("music")
    local playerCount = #player.Iterator()
    if #music > 0 then
        music[1]:SetKeyValue("RefireTime", 99999999)
        music[1]:Fire("Disable")
        music[1]:Fire("Kill")
    end

    if playerCount >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        for _, car in pairs(ents.GetAll()) do
            if car:IsVehicle() then car:Remove() end
        end

        print("Cars deleted. Player count reached the limit. Please disable MODULE.PlayerCountCarLimitEnabled if you don't want this. ")
    end
end

function MODULE:PlayerSpawnVehicle(client)
    local playerCount = #player.Iterator()
    if playerCount >= self.PlayerCountCarLimit and self.PlayerCountCarLimitEnabled then
        client:notify("You can't spawn this as the playerlimit to spawn car has been hit!")
        return false
    end
end

function MODULE:PropBreak(_, entity)
    if entity:IsValid() and entity:GetPhysicsObject():IsValid() then constraint.RemoveAll(entity) end
end

function MODULE:PreGamemodeLoaded()
    function widgets.PlayerTick()
    end

    hook.Remove("PlayerTick", "TickWidgets")
end

function MODULE:EntityRemoved(entity)
    if entity:IsRagdoll() and not entity:getNetVar("player", nil) and self.RagdollCleaningTimer > 0 then
        timer.Simple(self.RagdollCleaningTimer, function()
            if not IsValid(entity) then return end
            entity:SetSaveValue("m_bFadingOut", true)
            timer.Simple(3, function()
                if not IsValid(entity) then return end
                entity:Remove()
            end)
        end)
    end
end

function MODULE:Initialize()
    hook.Remove("StartChat", "StartChatIndicator")
    hook.Remove("FinishChat", "EndChatIndicator")
    hook.Remove("PostPlayerDraw", "DarkRP_ChatIndicator")
    hook.Remove("CreateClientsideRagdoll", "DarkRP_ChatIndicator")
    hook.Remove("player_disconnect", "DarkRP_ChatIndicator")
    hook.Remove("PostDrawEffects", "RenderWidgets")
    hook.Remove("PostDrawEffects", "RenderHalos")
    hook.Remove("PlayerTick", "TickWidgets")
    hook.Remove("OnEntityCreated", "WidgetInit")
    hook.Remove("PlayerInitialSpawn", "PlayerAuthSpawn")
    hook.Remove("LoadGModSave", "LoadGModSave")
    hook.Remove("GUIMousePressed", "SuperDOFMouseDown")
    hook.Remove("GUIMouseReleased", "SuperDOFMouseUp")
    hook.Remove("PreventScreenClicks", "SuperDOFPreventClicks")
    hook.Remove("Think", "DOFThink")
    hook.Remove("Think", "CheckSchedules")
    hook.Remove("NeedsDepthPass", "NeedsDepthPass_Bokeh")
    hook.Remove("RenderScene", "RenderSuperDoF")
    hook.Remove("RenderScene", "RenderStereoscopy")
    hook.Remove("PreRender", "PreRenderFrameBlend")
    hook.Remove("PostRender", "RenderFrameBlend")
    hook.Remove("RenderScreenspaceEffects", "RenderBokeh")
    RunConsoleCommand("mem_max_heapsize", "131072")
    RunConsoleCommand("mem_max_heapsize_dedicated", "131072")
    RunConsoleCommand("mem_min_heapsize", "131072")
    RunConsoleCommand("threadpool_affinity", "64")
    RunConsoleCommand("decalfrequency", "10")
    RunConsoleCommand("gmod_physiterations", "2")
    RunConsoleCommand("sv_minrate", "1048576")
    timer.Remove("CheckHookTimes")
    timer.Remove("HostnameThink")
end
