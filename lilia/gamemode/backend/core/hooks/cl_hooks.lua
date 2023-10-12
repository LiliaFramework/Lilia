--------------------------------------------------------------------------------------------------------------------------
local data = {}
--------------------------------------------------------------------------------------------------------------------------
local owner, w, h, ceil, ft, clmp
--------------------------------------------------------------------------------------------------------------------------
ceil = math.ceil
--------------------------------------------------------------------------------------------------------------------------
clmp = math.Clamp
--------------------------------------------------------------------------------------------------------------------------
local flo = 0
--------------------------------------------------------------------------------------------------------------------------
local vec
--------------------------------------------------------------------------------------------------------------------------
local aprg, aprg2 = 0, 0
--------------------------------------------------------------------------------------------------------------------------
w, h = ScrW(), ScrH()
--------------------------------------------------------------------------------------------------------------------------
local offset1, offset2, offset3, alpha, y
--------------------------------------------------------------------------------------------------------------------------
function GM:InitializedExtrasClient()
	for k, v in pairs(lia.config.StartupConsoleCommand) do
		RunConsoleCommand(k, v)
	end

	for hookType, identifiers in pairs(lia.config.RemovableHooks) do
		for _, identifier in ipairs(identifiers) do
			hook.Remove(hookType, identifier)
		end
	end

	timer.Remove("HostnameThink")
	timer.Remove("CheckHookTimes")
	if ArcCW then
		RunConsoleCommand("arccw_crosshair", "1")
		RunConsoleCommand("arccw_shake", "0")
		RunConsoleCommand("arccw_vm_bob_sprint", "2.80")
		RunConsoleCommand("arccw_vm_sway_sprint", "1.85")
		RunConsoleCommand("arccw_vm_right", "1.16")
		RunConsoleCommand("arccw_vm_forward", "3.02")
		RunConsoleCommand("arccw_vm_up", "0")
		RunConsoleCommand("arccw_vm_lookxmult", "-2.46")
		RunConsoleCommand("arccw_vm_lookymult", "7")
		RunConsoleCommand("arccw_vm_accelmult", "0.85")
		RunConsoleCommand("arccw_crosshair_clr_a", "61")
		RunConsoleCommand("arccw_crosshair_clr_b", "255")
		RunConsoleCommand("arccw_crosshair_clr_g", "242")
		RunConsoleCommand("arccw_crosshair_clr_r", "0")
		RunConsoleCommand("arccw_crosshair_outline", "0")
		RunConsoleCommand("arccw_crosshair_shotgun", "1")
	end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:NetworkEntityCreated(entity)
	if entity == LocalPlayer() then return end
	if not entity:IsPlayer() then return end
	hook.Run("PlayerModelChanged", entity, entity:GetModel())
end

--------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------
function GM:DrawLiliaModelView(panel, ent)
	if IsValid(ent.weapon) then
		ent.weapon:DrawModel()
	end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:OnChatReceived()
	if system.IsWindows() and not system.HasFocus() then
		system.FlashWindow()
	end
end

--------------------------------------------------------------------------------------------------------------------------
function GM:HUDPaint()
	self:DeathHUDPaint()
	self:MiscHUDPaint()
	self:PointingHUDPaint()
end

--------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------
function GM:ClientInitializedConfig()
	hook.Run("LoadLiliaFonts", lia.config.Font, lia.config.GenericFont)
end

--------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------------------------------------------
function GM:DeathHUDPaint()
	owner = LocalPlayer()
	ft = FrameTime()
	if owner:getChar() then
		if owner:Alive() then
			if aprg ~= 0 then
				aprg2 = clmp(aprg2 - ft * 1.3, 0, 1)
				if aprg2 == 0 then
					aprg = clmp(aprg - ft * .7, 0, 1)
				end
			end
		else
			if aprg2 ~= 1 then
				aprg = clmp(aprg + ft * .5, 0, 1)
				if aprg == 1 then
					aprg2 = clmp(aprg2 + ft * .4, 0, 1)
				end
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

--------------------------------------------------------------------------------------------------------------------------
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

	if lia.config.BranchWarning and BRANCH ~= "x86-64" then
		draw.SimpleText("We recommend the use of the x86-64 Garry's Mod Branch for this server, consider swapping as soon as possible.", "liaSmallFont", ScrW() * .5, ScrH() * .97, Color(255, 255, 255, 10), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end

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

--------------------------------------------------------------------------------------------------------------------------
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
--------------------------------------------------------------------------------------------------------------------------