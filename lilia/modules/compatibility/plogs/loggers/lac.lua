plogs.Register("LAC", true, Color(204,0,153))

plogs.AddHook("LAC.OnDetect", function(client, _, reason)
	plogs.PlayerLog(client, "LAC", client:NameID() .. " has been detected for " .. reason, {
		["Name"] 	= client:Name(),
		["SteamID"]	= client:SteamID()
	})
end)