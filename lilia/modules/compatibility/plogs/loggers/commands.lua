plogs.Register("Commands", false)

if (SERVER) then
	concommand._Run = concommand._Run or concommand.Run
	function concommand.Run(client, cmd, arguments, arg_str)
		if IsValid(client) and client:IsPlayer() and (cmd ~= nil) and (plogs.cfg.CommandBlacklist[cmd] ~= true) then
			plogs.PlayerLog(client, "Commands", client:NameID() .. " has ran command '" .. cmd .. "' with arguments '" .. (arg_str or table.concat(arguments, " ")) .. "'", {
				["Name"]	= client:Name(),
				["SteamID"]	= client:SteamID(),
			})
		end
		return concommand._Run(client, cmd, arguments, arg_str)
	end
end