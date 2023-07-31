AFKKick = AFKKick or {}
AFKKick.Config = AFKKick.Config or {}

function AFKKick.WarnPlayer(ply)
	net.Start("AFKWarning")
	net.WriteBool(true)
	net.Send(ply)
	ply.HasWarning = true
end

function AFKKick.RemoveWarning(ply)
	net.Start("AFKWarning")
	net.WriteBool(false)
	net.Send(ply)
	ply.HasWarning = false
end

function AFKKick.CharKick(ply)
	net.Start("AFKAnnounce")
	net.WriteString(ply:Nick())
	net.Broadcast()
	AFKKick.ResetAFKTime(ply)

	timer.Simple(1 + (ply:Ping() / 1000), function()
		ply:getChar():kick()
	end)
end

AFKKick.TimerInterval = 1

if CONFIG.AFKKickEnabled then
	timer.Create("AFKTimer", AFKKick.TimerInterval, 0, function()
		local plyCount = player.GetCount()
		local maxPlayers = game.MaxPlayers()

		for _, ply in ipairs(player.GetAll()) do
			if not ply:getChar() and plyCount < maxPlayers then continue end
			if AFKKick.Config.AllowedPlayers[ply:SteamID()] or ply:IsBot() then continue end
			ply.AFKTime = (ply.AFKTime or 0) + AFKKick.TimerInterval

			if ply.AFKTime >= AFKKick.Config.WarningTime and not ply.HasWarning then
				AFKKick.WarnPlayer(ply)
			end

			if ply.AFKTime >= AFKKick.Config.WarningTime + AFKKick.Config.KickTime then
				if plyCount >= maxPlayers then
					ply:Kick(AFKKick.Config.KickMessage)
				elseif ply:getChar() then
					AFKKick.CharKick(ply)
				end
			end
		end
	end)
end

function AFKKick.ResetAFKTime(ply)
	ply.AFKTime = 0

	if ply.HasWarning then
		AFKKick.RemoveWarning(ply)
	end
end

hook.Add("PlayerButtonDown", "AFKKick", AFKKick.ResetAFKTime)
hook.Add("PlayerButtonUp", "AFKKick", AFKKick.ResetAFKTime)
util.AddNetworkString("AFKWarning")
util.AddNetworkString("AFKAnnounce")