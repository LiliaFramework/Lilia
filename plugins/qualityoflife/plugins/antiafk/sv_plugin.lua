local PLUGIN = PLUGIN

function PLUGIN:CharacterLoaded(id)
	local character = lia.char.loaded[id]
	local client = character:getPlayer()

	if IsValid(client) then
		local uniqueID = "AntiAFK" .. client:SteamID64()

		timer.Create(uniqueID, lia.config.get("afkTime"), 0, function()
			if IsValid(client) and client:getChar() then
				self:Update(client)
			else
				timer.Remove(uniqueID)
			end
		end)
	end
end

function PLUGIN:GetAFK()
	local target = nil

	for _, v in ipairs(player.GetAll()) do
		if v.isAFK and (not target or target.isAFK > v.isAFK) and not v:IsAdmin() then
			target = v
			break
		end
	end

	if target and CurTime() - target.isAFK > 60 then return target end
end

function PLUGIN:KickAFK(target, byAdmin)
	if target then
		target:Kick("You were kicked for being AFK")

		if byAdmin then
			lia.util.notifyLocalized("%s has auto-kicked '%s' (AFK).", nil, byAdmin:Name(), target:Name())
		else
			lia.util.notifyLocalized("%s has been auto-kicked by the server (AFK)", nil, target:Name())
		end
	end
end

function PLUGIN:Update(client)
	local aimVector = client:GetAimVector()
	local posVector = client:GetPos()

	if client.liaLastAimVector ~= aimVector or client.liaLastPosition ~= posVector then
		client.liaLastAimVector = aimVector
		client.liaLastPosition = posVector
		client.isAFK = nil
		client:setNetVar("IsAFK", false)
	else
		client.isAFK = CurTime()
		client:setNetVar("IsAFK", true)
	end
end

timer.Create("AntiAFK", 60, 0, function()
	if player.GetCount() >= game.MaxPlayers() then
		PLUGIN:KickAFK(PLUGIN:GetAFK())
	end
end)