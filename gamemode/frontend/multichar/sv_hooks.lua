hook.Add("PlayerLiliaDataLoaded", "MultiCharPlayerLiliaDataLoaded", function(client)
	lia.char.restore(client, function(charList)
		if not IsValid(client) then return end
		MsgN("Loaded (" .. table.concat(charList, ", ") .. ") for " .. client:Name())

		for k, v in ipairs(charList) do
			if lia.char.loaded[v] then
				lia.char.loaded[v]:sync(client)
			end
		end

		for k, v in ipairs(player.GetAll()) do
			if v:getChar() then
				v:getChar():sync(client)
			end
		end

		client.liaCharList = charList
		hook.Run("MultiCharSyncCharList", client)
		client.liaLoaded = true
	end)
end)

hook.Add("PostPlayerInitialSpawn", "MultiCharPostPlayerInitialSpawn", function(client)
	client:SetNoDraw(true)
	client:SetNotSolid(true)
	client:Lock()

	timer.Simple(1, function()
		if not IsValid(client) then return end
		client:KillSilent()
		client:StripAmmo()
	end)
end)

hook.Add("CanPlayerUseChar", "MultiCharCanPlayerUseChar", function(client, character, oldCharacter)
	if client:getChar() and client:getChar():getID() == character:getID() then return false, "@usingChar" end
end)

hook.Add("PlayerLoadedChar", "MultiCharPlayerLoadedChar", function(client, character, oldCharacter)
	client:Spawn()
end)

hook.Add("OnCharCreated", "MultiCharOnCharCreated", function(client, character)
	local id = character:getID()
	MsgN("Created character '" .. id .. "' for " .. client:steamName() .. ".")
end)

hook.Add("MultiCharSyncCharList", "MultiCharSyncCharList", function(client)
	if not client.liaCharList then return end
	net.Start("liaCharList")
	net.WriteUInt(#client.liaCharList, 32)

	for i = 1, #client.liaCharList do
		net.WriteUInt(client.liaCharList[i], 32)
	end

	net.Send(client)
end)

hook.Add("CanPlayerCreateCharacter", "MultiCharCanPlayerCreateCharacter", function(client)
	local count = #client.liaCharList
	local maxChars = hook.Run("GetMaxPlayerCharacter", client) or lia.config.MaxChars
	if count >= maxChars then return false end
end)