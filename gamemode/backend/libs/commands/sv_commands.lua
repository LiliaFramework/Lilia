--------------------------------------------------------------------------------------------------------
function lia.command.findPlayer(client, name)
	if isstring(name) then
		if name == "^" then
			return client
		elseif name == "@" then
			local trace = client:GetEyeTrace().Entity

			if IsValid(trace) and trace:IsPlayer() then
				return trace
			else
				client:notifyLocalized("lookToUseAt")

				return
			end
		end

		local target = lia.util.findPlayer(name) or NULL

		if IsValid(target) then
			return target
		else
			client:notifyLocalized("plyNoExist")
		end
	else
		client:notifyLocalized("mustProvideString")
	end
end

--------------------------------------------------------------------------------------------------------
function lia.command.findFaction(client, name)
	if lia.faction.teams[name] then return lia.faction.teams[name] end

	for _, v in ipairs(lia.faction.indices) do
		if lia.util.stringMatches(L(v.name, client), name) then return v end
	end

	client:notifyLocalized("invalidFaction")
end

--------------------------------------------------------------------------------------------------------
function lia.command.run(client, command, arguments)
	command = lia.command.list[command:lower()]

	if command then
		local results = {command.onRun(client, arguments or {})}

		local result = results[1]

		if isstring(result) then
			if IsValid(client) then
				if result:sub(1, 1) == "@" then
					client:notifyLocalized(result:sub(2), unpack(results, 2))
				else
					client:notify(result)
				end
			else
				print(result)
			end
		end
	end
end

--------------------------------------------------------------------------------------------------------
function lia.command.parse(client, text, realCommand, arguments)
	if realCommand or text:utf8sub(1, 1) == "/" then
		local match = realCommand or text:lower():match("/" .. "([_%w]+)")

		if not match then
			local post = string.Explode(" ", text)
			local len = string.len(post[1])
			match = post[1]:utf8sub(2, len)
		end

		match = match:lower()
		local command = lia.command.list[match]

		if command then
			if not arguments then
				arguments = lia.command.extractArgs(text:sub(#match + 3))
			end

			lia.command.run(client, match, arguments)
			if not realCommand then end
		else
			if IsValid(client) then
				client:notifyLocalized("cmdNoExist")
			else
				print("Sorry, that command does not exist.")
			end
		end

		return true
	end

	return false
end

--------------------------------------------------------------------------------------------------------
concommand.Add("lia", function(client, _, arguments)
	local command = arguments[1]
	table.remove(arguments, 1)
	lia.command.parse(client, nil, command or "", arguments)
end)
--------------------------------------------------------------------------------------------------------