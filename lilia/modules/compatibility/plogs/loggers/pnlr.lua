plogs.Register("NLR", true, Color(255,100,0))

plogs.AddHook("NLR", "PlayerEnteredNlrZone", function(_, client)
	plogs.PlayerLog(client, "NLR", client:NameID() .. " entered an NLR zone", {
		["Name"]	= client:Name(),
		["SteamID"] = client:SteamID(),
	})
end)

plogs.AddHook("NLR", "PlayerExitedNlrZone", function(_, client)
	plogs.PlayerLog(client, "NLR", client:NameID() .. " left an NLR zone", {
		["Name"]	= client:Name(),
		["SteamID"] = client:SteamID(),
	})
end)
