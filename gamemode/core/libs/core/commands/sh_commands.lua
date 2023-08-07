lia.command = lia.command or {}
lia.command.list = lia.command.list or {}

function lia.command.add(command, data)
	data.syntax = data.syntax or "[none]"
	if not data.onRun then return ErrorNoHalt("Command '" .. command .. "' does not have a callback, not adding!\n") end

	if not data.onCheckAccess then
		if data.adminOnly then
			data.onCheckAccess = function(client)
				return client:IsAdmin()
			end
		elseif data.superAdminOnly then
			data.onCheckAccess = function(client)
				return client:IsSuperAdmin()
			end
		elseif data.group then
			if istable(data.group) then
				data.onCheckAccess = function(client)
					for _, v in ipairs(data.group) do
						if client:IsUserGroup(v) then return true end
					end

					return false
				end
			else
				data.onCheckAccess = function(client)
					return client:IsUserGroup(data.group)
				end
			end
		end
	end

	local onCheckAccess = data.onCheckAccess

	if onCheckAccess then
		local onRun = data.onRun
		data._onRun = data.onRun

		data.onRun = function(client, arguments)
			if hook.Run("CanPlayerUseCommand", client, command) or onCheckAccess(client) then
				return onRun(client, arguments)
			else
				return "@noPerm"
			end
		end
	end

	local alias = data.alias

	if alias then
		if istable(alias) then
			for _, v in ipairs(alias) do
				lia.command.list[v:lower()] = data
			end
		elseif isstring(alias) then
			lia.command.list[alias:lower()] = data
		end
	end

	if command == command:lower() then
		lia.command.list[command] = data
	else
		data.realCommand = command
		lia.command.list[command:lower()] = data
	end
end

function lia.command.hasAccess(client, command)
	command = lia.command.list[command:lower()]

	if command then
		if command.onCheckAccess then
			return command.onCheckAccess(client)
		else
			return true
		end
	end

	return hook.Run("CanPlayerUseCommand", client, command) or false
end

function lia.command.extractArgs(text)
	local skip = 0
	local arguments = {}
	local curString = ""

	for i = 1, #text do
		if i <= skip then continue end
		local c = text:sub(i, i)

		if c == "\"" then
			local match = text:sub(i):match("%b" .. c .. c)

			if match then
				curString = ""
				skip = i + #match
				arguments[#arguments + 1] = match:sub(2, -2)
			else
				curString = curString .. c
			end
		elseif c == " " and curString ~= "" then
			arguments[#arguments + 1] = curString
			curString = ""
		else
			if c == " " and curString == "" then continue end
			curString = curString .. c
		end
	end

	if curString ~= "" then
		arguments[#arguments + 1] = curString
	end

	return arguments
end

lia.util.include("libs/core/commands/sv_commands.lua")