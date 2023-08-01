local MODULE = MODULE

function MODULE.WarnPlayer(ply)
	net.Start("AFKWarning")
	net.WriteBool(true)
	net.Send(ply)
	ply.HasWarning = true
end

function MODULE.RemoveWarning(ply)
	net.Start("AFKWarning")
	net.WriteBool(false)
	net.Send(ply)
	ply.HasWarning = false
end

function MODULE.CharKick(ply)
	net.Start("AFKAnnounce")
	net.WriteString(ply:Nick())
	net.Broadcast()
	MODULE.ResetAFKTime(ply)

	timer.Simple(1 + (ply:Ping() / 1000), function()
		ply:getChar():kick()
	end)
end

MODULE.TimerInterval = 1

if CONFIG.MODULEEnabled then
	timer.Create("AFKTimer", MODULE.TimerInterval, 0, function()
		local plyCount = player.GetCount()
		local maxPlayers = game.MaxPlayers()

		for _, ply in ipairs(player.GetAll()) do
			if not ply:getChar() and plyCount < maxPlayers then continue end
			if CONFIG.AllowedPlayers[ply:SteamID()] or ply:IsBot() then continue end
			ply.AFKTime = (ply.AFKTime or 0) + MODULE.TimerInterval

			if ply.AFKTime >= CONFIG.WarningTime and not ply.HasWarning then
				MODULE.WarnPlayer(ply)
			end

			if ply.AFKTime >= CONFIG.WarningTime + CONFIG.KickTime then
				if plyCount >= maxPlayers then
					ply:Kick(CONFIG.KickMessage)
				elseif ply:getChar() then
					MODULE.CharKick(ply)
				end
			end
		end
	end)
end

function MODULE.ResetAFKTime(ply)
	ply.AFKTime = 0

	if ply.HasWarning then
		MODULE.RemoveWarning(ply)
	end
end

hook.Add("PlayerButtonDown", "MODULE", MODULE.ResetAFKTime)
hook.Add("PlayerButtonUp", "MODULE", MODULE.ResetAFKTime)
util.AddNetworkString("AFKWarning")
util.AddNetworkString("AFKAnnounce")