--------------------------------------------------------------------------------------------------------
local data = {}
--------------------------------------------------------------------------------------------------------
local owner, w, h, ceil, ft, clmp
--------------------------------------------------------------------------------------------------------
ceil = math.ceil
--------------------------------------------------------------------------------------------------------
clmp = math.Clamp
--------------------------------------------------------------------------------------------------------
local flo = 0
--------------------------------------------------------------------------------------------------------
local vec
--------------------------------------------------------------------------------------------------------
local lastcheck
--------------------------------------------------------------------------------------------------------
local aprg, aprg2 = 0, 0
--------------------------------------------------------------------------------------------------------
w, h = ScrW(), ScrH()
--------------------------------------------------------------------------------------------------------
local offset1, offset2, offset3, alpha, y

--------------------------------------------------------------------------------------------------------
lia.config.HackCommands = {"gear_printents", "gw_toggle", "gw_pos", "gearmenu", "gb_reload", "gb_toggle", "+gb", "-gb", "gb_menu", "gear2_menu", "ahack_menu", "sasha_menu", "showents", "showhxmenu", "SmegHack_Menu", "sCheat_menu", "lowkey_menu"} -- GEAR1 Commands -- GEAR2 Commands -- AHack Commands -- Sasha Commands -- Misc. Commands --smeg, prob doesnt work anymore (2015) --random ones found in uc
--------------------------------------------------------------------------------------------------------
lia.config.RemovableConsoleCommand = {
	["gmod_mcore_test"] = "1",
	["r_shadows"] = "0",
	["cl_detaildist"] = "0",
	["cl_threaded_client_leaf_system"] = "1",
	["cl_threaded_bone_setup"] = "2",
	["r_threaded_renderables"] = "1",
	["r_threaded_particles"] = "1",
	["r_queued_ropes"] = "1",
	["r_queued_decals"] = "1",
	["r_queued_post_processing"] = "1",
	["r_threaded_client_shadow_manager"] = "1",
	["studio_queue_mode"] = "1",
	["mat_queue_mode"] = "-2",
	["fps_max"] = "0",
	["fov_desired"] = "100",
	["mat_specular"] = "0",
	["r_drawmodeldecals"] = "0",
	["r_lod"] = "-1",
	["lia_cheapblur"] = "1",
}
--------------------------------------------------------------------------------------------------------
lia.config.RemovableHooks = {
	["StartChat"] = "StartChatIndicator",
	["FinishChat"] = "EndChatIndicator",
	["PostPlayerDraw"] = "DarkRP_ChatIndicator",
	["CreateClientsideRagdoll"] = "DarkRP_ChatIndicator",
	["player_disconnect"] = "DarkRP_ChatIndicator",
	["RenderScene"] = "RenderSuperDoF",
	["RenderScene"] = "RenderStereoscopy",
	["Think"] = "DOFThink",
	["GUIMouseReleased"] = "SuperDOFMouseUp",
	["GUIMousePressed"] = "SuperDOFMouseDown",
	["PreRender"] = "PreRenderFrameBlend",
	["PostRender"] = "RenderFrameBlend",
	["NeedsDepthPass"] = "NeedsDepthPass_Bokeh",
	["PreventScreenClicks"] = "SuperDOFPreventClicks",
	["RenderScreenspaceEffects"] = "RenderBokeh",
	["RenderScreenspaceEffects"] = "RenderBokeh",
	["PostDrawEffects"] = "RenderWidgets",
	["PlayerTick"] = "TickWidgets",
	["PlayerInitialSpawn"] = "PlayerAuthSpawn",
	["RenderScene"] = "RenderStereoscopy",
	["LoadGModSave"] = "LoadGModSave",
	["RenderScreenspaceEffects"] = "RenderColorModify",
	["RenderScreenspaceEffects"] = "RenderBloom",
	["RenderScreenspaceEffects"] = "RenderToyTown",
	["RenderScreenspaceEffects"] = "RenderTexturize",
	["RenderScreenspaceEffects"] = "RenderSunbeams",
	["RenderScreenspaceEffects"] = "RenderSobel",
	["RenderScreenspaceEffects"] = "RenderSharpen",
	["RenderScreenspaceEffects"] = "RenderMaterialOverlay",
	["RenderScreenspaceEffects"] = "RenderMotionBlur",
	["RenderScene"] = "RenderSuperDoF",
	["GUIMousePressed"] = "SuperDOFMouseDown",
	["GUIMouseReleased"] = "SuperDOFMouseUp",
	["PreventScreenClicks"] = "SuperDOFPreventClicks",
	["PostRender"] = "RenderFrameBlend",
	["PreRender"] = "PreRenderFrameBlend",
	["Think"] = "DOFThink",
	["RenderScreenspaceEffects"] = "RenderBokeh",
	["NeedsDepthPass"] = "NeedsDepthPass_Bokeh",
	["PostDrawEffects"] = "RenderWidgets",
	["PostDrawEffects"] = "RenderHalos",
}
-------------------------------------------------------------------------------------------------------
function GM:ClientThink()
	if not lastcheck then
		lastcheck = CurTime()
	end

	if CurTime() - lastcheck > 30 then
		local commands, _ = concommand.GetTable()
		for _, cmd in pairs(lia.config.HackCommands) do
			if commands[cmd] then
				net.Start("BanMeAmHack")
				net.SendToServer()
			end
		end

		lastcheck = CurTime()
	end
end
-------------------------------------------------------------------------------------------------------
function GM:InitializedExtrasClient()
	for k, v in pairs(lia.config.RemovableConsoleCommand) do
		RunConsoleCommand(k, v)
	end

	for k, v in pairs(lia.config.RemovableHooks) do
		hook.Remove(k, v)
	end

	timer.Remove("HostnameThink")
	timer.Remove("CheckHookTimes")
end
--------------------------------------------------------------------------------------------------------
function GM:NetworkEntityCreated(entity)
	if entity == LocalPlayer() then return end
	if not entity:IsPlayer() then return end
	hook.Run("PlayerModelChanged", entity, entity:GetModel())
end
--------------------------------------------------------------------------------------------------------
function GM:CharacterListLoaded()
	timer.Create(
		"liaWaitUntilPlayerValid",
		1,
		0,
		function()
			if not IsValid(LocalPlayer()) then return end
			timer.Remove("liaWaitUntilPlayerValid")
			hook.Run("LiliaLoaded")
		end
	)
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerBindPress(client, bind, pressed)
    bind = bind:lower()
    if (bind:find("use") or bind:find("attack")) and pressed then
        local menu, callback = lia.menu.getActiveMenu()
        if menu and lia.menu.onButtonPressed(menu, callback) then
            return true
        elseif bind:find("use") and pressed then
            local data = {}
            data.start = client:GetShootPos()
            data.endpos = data.start + client:GetAimVector() * 96
            data.filter = client
            local trace = util.TraceLine(data)
            local entity = trace.Entity
            if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then hook.Run("ItemShowEntityMenu", entity) end
        end
    elseif bind:find("jump") then
        lia.command.send("chargetup")
    elseif isInteracting and interactPressTime < CurTime() and selectedFunction ~= nil and bind == "+attack" then
        selectedFunction.callback(lia.playerInteract.currentEnt)
        lia.playerInteract.clear()
        return true
    end
end
--------------------------------------------------------------------------------------------------------
function GM:DrawLiliaModelView(panel, ent)
	if IsValid(ent.weapon) then
		ent.weapon:DrawModel()
	end
end
--------------------------------------------------------------------------------------------------------
function GM:OnChatReceived()
	if system.IsWindows() and not system.HasFocus() then
		system.FlashWindow()
	end
end
--------------------------------------------------------------------------------------------------------
function GM:HUDPaint()
	self:DeathHUDPaint()
	self:InteractionHUDPaint()
	self:MiscHUDPaint()
	self:PointingHUDPaint()
end
--------------------------------------------------------------------------------------------------------
function GM:PlayerButtonDown(client, button)
	if button == KEY_F2 and IsFirstTimePredicted() then
		local menu = DermaMenu()
		menu:AddOption(
			"Change voice mode to Whispering range.",
			function()
				netstream.Start("ChangeSpeakMode", "Whispering")
				client:ChatPrint("You have changed your voice mode to Whispering!")
			end
		)

		menu:AddOption(
			"Change voice mode to Talking range.",
			function()
				netstream.Start("ChangeSpeakMode", "Talking")
				client:ChatPrint("You have changed your voice mode to Talking!")
			end
		)

		menu:AddOption(
			"Change voice mode to Yelling range.",
			function()
				netstream.Start("ChangeSpeakMode", "Yelling")
				client:ChatPrint("You have changed your voice mode to Yelling!")
			end
		)

		menu:Open()
		menu:MakePopup()
		menu:Center()
	end
end
--------------------------------------------------------------------------------------------------------
function GM:ClientInitializedConfig()
	hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end
--------------------------------------------------------------------------------------------------------
function GM:ClientPostInit()
	lia.joinTime = RealTime() - 0.9716
	lia.faction.formatModelData()
	if system.IsWindows() and not system.HasFocus() then
		system.FlashWindow()
	end

	timer.Create(
		"FixShadows",
		10,
		0,
		function()
			for _, player in ipairs(player.GetAll()) do
				player:DrawShadow(false)
			end

			for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
				if IsValid(v) and v:isDoor() then
					v:DrawShadow(false)
				end
			end
		end
	)
end
--------------------------------------------------------------------------------------------------------
function GM:ClientKeyPress(entity, time)
    lia.playerInteract.interact(entity, time)
end
--------------------------------------------------------------------------------------------------------
function GM:ClientKeyRelease(client, key)
	if key == IN_USE and isInteracting then
		lia.playerInteract.clear()
	end
end
--------------------------------------------------------------------------------------------------------
function GM:InteractionHUDPaint()
    if not isInteracting and interfaceScale < 0 then return end
    local client = LocalPlayer()
    local target = lia.playerInteract.currentEnt
    if IsValid(target) and target:GetPos():DistToSqr(client:GetPos()) > 30000 then lia.playerInteract.clear() end
    local curTime = CurTime()
    local posX = ScrW() / 2
    local posY = ScrH() / 2
    interfaceScale = Lerp(FrameTime() * 8, interfaceScale, (isInteracting and interactPressTime < curTime) and 1 or -0.1)
    if isLoading() then
        local loadingMaxW = 128
        local progress = 1 - (interactPressTime - curTime)
        local curLoadingW = loadingMaxW * progress
        local loadingCentreX = ScrW() / 2
        local loadingCentreY = ScrH() / 2 + 86
        local loadingH = 10
        lia.util.drawBlurAt(loadingCentreX - (loadingMaxW / 2), loadingCentreY, loadingMaxW, loadingH)
        surface.SetDrawColor(Color(0, 0, 0, 150))
        surface.DrawRect(loadingCentreX - (loadingMaxW / 2), loadingCentreY, loadingMaxW, loadingH, 1)
        surface.SetDrawColor(255, 255, 255, 120)
        surface.DrawOutlinedRect(loadingCentreX - (loadingMaxW / 2) + 1, loadingCentreY + 1, loadingMaxW - 2, loadingH - 2)
        surface.SetDrawColor(color_white)
        surface.DrawRect(loadingCentreX - (curLoadingW / 2) + 2, loadingCentreY + 2, (loadingMaxW - 4) * progress, loadingH - 4, 1)
    end

    if interfaceScale < 0 then return end
    local pitchDifference = (cachedPitch - EyeAngles().p) * 6
    local funcCount = 0
    for _, funcData in SortedPairs(lia.playerInteract.funcs) do
        if not funcData.canSee(target) then continue end
        local name = funcData.name or L(funcData.nameLocalized)
        surface.SetFont("liaGenericLightFont")
        local textW, _ = surface.GetTextSize(name)
        local barW, barH = textW + 16, 32
        local yAlignment = barH * funcCount
        local barX, barY = posX - (barW / 2) * interfaceScale, posY - (barH / 2) + yAlignment * interfaceScale + pitchDifference
        local isSelected = math.abs(yAlignment + pitchDifference) < 32
        if isSelected and interfaceScale > 0.75 then
            lia.util.drawBlurAt(barX, barY, barW, barH)
            surface.SetDrawColor(55, 55, 55, 120)
            surface.DrawRect(barX, barY, barW, barH)
            surface.SetDrawColor(255, 255, 255, 120)
            surface.DrawOutlinedRect(barX + 1, barY + 1, barW - 2, barH - 2)
            selectedFunction = funcData
        end

        draw.SimpleText(name, "liaGenericLightFont", barX + (barW / 2) + 2, barY + (barH / 2.1) + 2, Color(0, 0, 0, interfaceScale * 128), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(name, "liaGenericLightFont", barX + (barW / 2), barY + (barH / 2.1), Color(255, 255, 255, interfaceScale * 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        funcCount = funcCount + 1
    end
end
--------------------------------------------------------------------------------------------------------
function GM:DeathHUDPaint()
    owner = LocalPlayer()
    ft = FrameTime()
    if owner:getChar() then
        if owner:Alive() then
            if aprg ~= 0 then
                aprg2 = clmp(aprg2 - ft * 1.3, 0, 1)
                if aprg2 == 0 then aprg = clmp(aprg - ft * .7, 0, 1) end
            end
        else
            if aprg2 ~= 1 then
                aprg = clmp(aprg + ft * .5, 0, 1)
                if aprg == 1 then aprg2 = clmp(aprg2 + ft * .4, 0, 1) end
            end
        end
    end

    if IsValid(lia.char.gui) and lia.gui.char:IsVisible() or not owner:getChar() then return end
    if aprg > 0.01 then
        surface.SetDrawColor(0, 0, 0, ceil((aprg ^ .5) * 255))
        surface.DrawRect(-1, -1, w + 2, h + 2)
        local tx, ty = lia.util.drawText(L"youreDead", w / 2, h / 2, ColorAlpha(color_white, aprg2 * 255), 1, 1, "liaDynFontMedium", aprg2 * 255)
    end
end
--------------------------------------------------------------------------------------------------------
function GM:MiscHUDPaint()
    local ply = LocalPlayer()
    local ourPos = ply:GetPos()
    local time = RealTime() * 5
    data.start = ply:EyePos()
    data.filter = ply
    lia.bar.drawAll()
    if lia.config.VersionEnabled and lia.config.version then
        local w, h = 45, 45
        surface.SetFont("liaSmallChatFont")
        surface.SetTextPos(5, ScrH() - 20, w, h)
        surface.DrawText("Server Current Version: " .. lia.config.version)
    end

    if lia.config.BranchWarning and BRANCH ~= "x86-64" then draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER) end
    for k, v in ipairs(player.GetAll()) do
        if v ~= ply and v:getNetVar("typing") and v:GetMoveType() == MOVETYPE_WALK then
            data.endpos = v:EyePos()
            if util.TraceLine(data).Entity ~= v then continue end
            local position = v:GetPos()
            alpha = (1 - (ourPos:DistToSqr(position) / 65536)) * 255
            if alpha <= 0 then continue end
            local screen = (position + (v:Crouching() and Vector(0, 0, 48) or Vector(0, 0, 80))):ToScreen()
            offset1 = math.sin(time + 2) * alpha
            offset2 = math.sin(time + 1) * alpha
            offset3 = math.sin(time) * alpha
            y = screen.y - 20
            lia.util.drawText("•", screen.x - 8, y, ColorAlpha(Color(250, 250, 250), offset1), 1, 1, "liaChatFont", offset1)
            lia.util.drawText("•", screen.x, y, ColorAlpha(Color(250, 250, 250), offset2), 1, 1, "liaChatFont", offset2)
            lia.util.drawText("•", screen.x + 8, y, ColorAlpha(Color(250, 250, 250), offset3), 1, 1, "liaChatFont", offset3)
        end
    end
end
--------------------------------------------------------------------------------------------------------
function GM:PointingHUDPaint()
	net.Receive(
		"Pointing",
		function(len)
			flo = net.ReadFloat()
			vec = net.ReadVector()
		end
	)

	if flo >= CurTime() then
		local toScream = vec:ToScreen()
		local distance = 40 / (LocalPlayer():GetPos():Distance(vec) / 300)
		surface.DrawCircle(toScream.x, toScream.y, distance, 0, 255, 0, 255)
	end
end
--------------------------------------------------------------------------------------------------------