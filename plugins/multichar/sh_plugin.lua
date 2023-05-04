PLUGIN.name = "Multiple Characters"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Allows players to have multiple characters."

liaMultiChar = PLUGIN

if (SERVER) then
	function PLUGIN:syncCharList(client)
		if (not client.liaCharList) then return end
		net.Start("liaCharList")
			net.WriteUInt(#client.liaCharList, 32)
			for i = 1, #client.liaCharList do
				net.WriteUInt(client.liaCharList[i], 32)
			end
		net.Send(client)
	end

	function PLUGIN:CanPlayerCreateCharacter(client)
		local count = #client.liaCharList
		local maxChars = hook.Run("GetMaxPlayerCharacter", client)
			or lia.config.get("maxChars", 5)
		if (count >= maxChars) then
			return false
		end
	end
else
	--- Requests to change to the character corresponding to the ID.
	-- @param id A numeric character ID
	-- @return A promise that resolves after the character has been chosen
	function PLUGIN:chooseCharacter(id)
		assert(isnumber(id), "id must be a number")
		local d = deferred.new()
		net.Receive("liaCharChoose", function()
			local message = net.ReadString()
			if (message == "") then
				d:resolve()
				hook.Run("CharacterLoaded", lia.char.loaded[id])
			else
				d:reject(message)
			end
		end)
		net.Start("liaCharChoose")
			net.WriteUInt(id, 32)
		net.SendToServer()
		return d
	end

	--- Requests a character to be created with the given data.
	-- @param data A table with character variable names as keys and values
	-- @return A promise that is resolves to the created character's ID
	function PLUGIN:createCharacter(data)
		assert(istable(data), "data must be a table")
		local d = deferred.new()

		-- Quick client-side validation before sending.
		local payload = {}
		for key, charVar in pairs(lia.char.vars) do
			if (charVar.noDisplay) then continue end

			local value = data[key]
			if (isfunction(charVar.onValidate)) then
				local results = {charVar.onValidate(value, data, LocalPlayer())}
				if (results[1] == false) then
					return d:reject(L(unpack(results, 2)))
				end
			end
			payload[key] = value
		end

		-- Resolve promise after character is created.
		net.Receive("liaCharCreate", function()
			local id = net.ReadUInt(32)
			local reason = net.ReadString()
			if (id > 0) then
				d:resolve(id)
			else
				d:reject(reason)
			end
		end)

		-- Request a character to be created with the given data.
		net.Start("liaCharCreate")
			net.WriteUInt(table.Count(payload), 32)
			for key, value in pairs(payload) do
				net.WriteString(key)
				net.WriteType(value)
			end
		net.SendToServer()
		return d
	end

	--- Requests for a character to be deleted
	-- @param id The numeric ID of the desired character
	function PLUGIN:deleteCharacter(id)
		assert(isnumber(id), "id must be a number")
		net.Start("liaCharDelete")
			net.WriteUInt(id, 32)
		net.SendToServer()
	end
end

lia.util.include("sv_hooks.lua")
lia.util.include("cl_networking.lua")
lia.util.include("sv_networking.lua")
