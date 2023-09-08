--------------------------------------------------------------------------------------------------------
local flo = 0
local vec
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
			if IsValid(entity) and (entity:GetClass() == "lia_item" or entity.hasMenu == true) then
				hook.Run("ItemShowEntityMenu", entity)
			end
		end
	elseif bind:find("jump") then
		lia.command.send("chargetup")
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