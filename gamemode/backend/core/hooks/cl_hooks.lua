--------------------------------------------------------------------------------------------------------
function GM:NetworkEntityCreated(entity)
	if entity == LocalPlayer() then return end
	if not entity:IsPlayer() then return end
	hook.Run("PlayerModelChanged", entity, entity:GetModel())
end
--------------------------------------------------------------------------------------------------------
function GM:CharacterListLoaded()
	timer.Create("liaWaitUntilPlayerValid", 1, 0, function()
		if not IsValid(LocalPlayer()) then return end
		timer.Remove("liaWaitUntilPlayerValid")
		hook.Run("LiliaLoaded")
	end)
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
function GM:DrawCharInfo(client, character, info)
	if client:Team() == FACTION_STAFF then
		local UserGroup = client:GetUserGroup()
		local StaffTitleInfo = lia.config.StaffTitles[UserGroup]

		if StaffTitleInfo then
			local title, color = StaffTitleInfo[1], StaffTitleInfo[2]

			info[#info + 1] = {title, color}
		end
	end
end
--------------------------------------------------------------------------------------------------------
timer.Create('FixShadows', 10, 0, function() -- same
	for _, player in ipairs( player.GetAll() ) do
		player:DrawShadow(false)
	end

	for _, v in ipairs( ents.FindByClass('prop_door_rotating') ) do
		if IsValid(v) && v:IsDoor() then
			v:DrawShadow(false)
		end
	end
end)
--------------------------------------------------------------------------------------------------------