lia.char = lia.char or {}
lia.char.loaded = lia.char.loaded or {}
lia.char.vars = lia.char.vars or {}
lia.char.names = lia.char.names or {}

lia.util.include("lilia/gamemode/core/meta/sh_character.lua")
lia.util.include("character/cl_networking.lua")
lia.util.include("character/sv_character.lua")

if (SERVER) then
	if (not lia.db) then
		include("sv_database.lua")
	end

	-- Fetches all the character names and stores
	-- them into a table so they only have to be fetched once
	if (#lia.char.names < 1) then
		lia.db.query("SELECT _id, _name FROM lia_characters", function(data)
			if (data and #data > 0) then
				for k, v in pairs(data) do
					lia.char.names[v._id] = v._name
				end
			end
		end)
	end

	-- Returns the character names
	netstream.Hook("liaCharFetchNames", function(client)
		netstream.Start(client, "liaCharFetchNames", lia.char.names)
	end)

	-- Removes name from table upon character deletion
	hook.Add("liaCharDeleted", "liaCharRemoveName", function(client, character)
		lia.char.names[character:getID()] = nil

		netstream.Start(client, "liaCharFetchNames", lia.char.names)
	end)

	-- Removes name from table upon character deletion
	hook.Add("OnCharCreated", "liaCharAddName", function(client, character, data)
		lia.char.names[character:getID()] = data.name

		netstream.Start(client, "liaCharFetchNames", lia.char.names)
	end)
end

if (CLIENT) then
	-- Fetch existing character names
	netstream.Hook("liaCharFetchNames", function(data)
		lia.char.names = data
	end)

	if (#lia.char.names < 1) then
		netstream.Start("liaCharFetchNames")
	end
end

function lia.char.new(data, id, client, steamID)
	local character = setmetatable({vars = {}}, lia.meta.character)
		for k, v in pairs(lia.char.vars) do
			local value = data[k]
			if (value == nil) then
				value = v.default
				if (istable(value)) then
					value = table.Copy(value)
				end
			end
			character.vars[k] = value
		end

		character.id = id or 0
		character.player = client

		if (IsValid(client) or steamID) then
			character.steamID = IsValid(client)
				and client:SteamID64()
				or steamID
		end
	return character
end

lia.char.varHooks = lia.char.varHooks or {}
function lia.char.hookVar(varName, hookName, func)
	lia.char.varHooks[varName] = lia.char.varHooks[varName] or {}

	lia.char.varHooks[varName][hookName] = func
end

-- Registration of default variables go here.
do
	lia.char.registerVar("name", {
		field = "_name",
		default = "John Doe",
		index = 1,
		onValidate = function(value, data, client)
			local name, override =
				hook.Run("GetDefaultCharName", client, data.faction, data)
			if (isstring(name) and override) then
				return true
			end
			if (not isstring(value) or not value:find("%S")) then
				return false, "invalid", "name"
			end

			local allowExistNames = lia.config.get("allowExistNames", true)

			-- Fetch existing character names
			if (CLIENT and #lia.char.names < 1 and not allowExistNames) then
				netstream.Start("liaCharFetchNames")

				netstream.Hook("liaCharFetchNames", function(data)
					lia.char.names = data
				end)
			end

			-- Check whether the chosen character name already exists
			if (not lia.config.get("allowExistNames", true)) then
				for k, v in pairs(lia.char.names) do
					if (v == value) then
						return false, "A character with this name already exists."
					end
				end
			end

			return true
		end,
		onAdjust = function(client, data, value, newData)
			local name, override =
				hook.Run("GetDefaultCharName", client, data.faction, data)
			if (isstring(name) and override) then
				newData.name = name
			else
				newData.name = string.Trim(value):sub(1, 70)
			end
		end,
		onPostSetup = function(panel, faction, payload)
			local name, disabled = hook.Run(
				"GetDefaultCharName",
				LocalPlayer(),
				faction
			)

			if (name) then
				panel:SetText(name)
				payload.name = name
			end

			if (disabled) then
				panel:SetDisabled(true)
				panel:SetEditable(false)
			end
		end
	})

	lia.char.registerVar("desc", {
		field = "_desc",
		default = "",
		index = 2,
		onValidate = function(value, data)
			if (noDesc) then return true end

			local minLength = lia.config.get("minDescLen", 16)

			if (not value or #value:gsub("%s", "") < minLength) then
				return false, "descMinLen", minLength
			end
		end
	})

	local gradient = lia.util.getMaterial("vgui/gradient-d")

	lia.char.registerVar("model", {
		field = "_model",
		default = "models/error.mdl",
		onSet = function(character, value)
			local oldVar = character:getModel()
			local client = character:getPlayer()

			if (IsValid(client) and client:getChar() == character) then
				client:SetModel(value)
			end

			character.vars.model = value
			netstream.Start(
				nil, "charSet",
				"model", character.vars.model,
				character:getID()
			)
			hook.Run("OnCharVarChanged", character, "model", oldVar, value)
		end,
		onGet = function(character, default)
			return character.vars.model or default
		end,
		index = 3,
		onDisplay = function(panel, y)
			local scroll = panel:Add("DScrollPanel")
			scroll:SetSize(panel:GetWide(), 260)
			scroll:SetPos(0, y)

			local layout = scroll:Add("DIconLayout")
			layout:Dock(FILL)
			layout:SetSpaceX(1)
			layout:SetSpaceY(1)

			local faction = lia.faction.indices[panel.faction]

			if (faction) then
				for k, v in SortedPairs(faction.models) do
					local icon = layout:Add("SpawnIcon")
					icon:SetSize(64, 128)
					icon:InvalidateLayout(true)
					icon.DoClick = function(this)
						panel.payload.model = k
					end
					icon.PaintOver = function(this, w, h)
						if (panel.payload.model == k) then
							local color = lia.config.get("color", color_white)

							surface.SetDrawColor(color.r, color.g, color.b, 200)

							for i = 1, 3 do
								local i2 = i * 2

								surface.DrawOutlinedRect(i, i, w - i2, h - i2)
							end

							surface.SetDrawColor(color.r, color.g, color.b, 75)
							surface.SetMaterial(gradient)
							surface.DrawTexturedRect(0, 0, w, h)
						end
					end

					if (isstring(v)) then
						icon:SetModel(v)
					else
						icon:SetModel(v[1], v[2] or 0, v[3])
					end
				end
			end

			return scroll
		end,
		onValidate = function(value, data)
			local faction = lia.faction.indices[data.faction]

			if (faction) then
				if (not data.model or not faction.models[data.model]) then
					return false, "needModel"
				end
			else
				return false, "needModel"
			end
		end,
		onAdjust = function(client, data, value, newData)
			local faction = lia.faction.indices[data.faction]

			if (faction) then
				local model = faction.models[value]

				if (isstring(model)) then
					newData.model = model
				elseif (istable(model)) then
					newData.model = model[1]
					newData.data = newData.data or {}
					newData.data.skin = model[2] or 0

					local groups = {}
					if isstring(model[3]) then
						local i = 0
						for value in model[3]:gmatch("%d") do
							groups[i] = tonumber(value)
							i = i + 1
						end
					elseif istable(model[3]) then
						for k, v in pairs(model[3]) do
							groups[tonumber(k)] = tonumber(v)
						end
					end
					newData.data.groups = groups
				end
			end
		end
	})

	lia.char.registerVar("class", {
		noDisplay = true,
	})

	lia.char.registerVar("faction", {
		field = "_faction",
		default = "Citizen",
		onSet = function(character, value)
			local oldVar = character:getFaction()
			local faction = lia.faction.indices[value]
			assert(faction, tostring(value).." is an invalid faction index")

			local client = character:getPlayer()
			client:SetTeam(value)

			character.vars.faction = faction.uniqueID
			netstream.Start(
				nil, "charSet",
				"faction", character.vars.faction,
				character:getID()
			)
			hook.Run("OnCharVarChanged", character, "faction", oldVar, value)

			return true -- Compatability with old version.
		end,
		onGet = function(character, default)
			local faction = lia.faction.teams[character.vars.faction]
			return faction and faction.index or default or 0
		end,
		onValidate = function(value, data, client)
			if (not lia.faction.indices[value]) then
				return false, "invalid", "faction"
			end
			if (not client:hasWhitelist(value)) then
				return false, "illegalAccess"
			end
			return true
		end,
		onAdjust = function(client, data, value, newData)
			newData.faction = lia.faction.indices[value].uniqueID
		end
	})

	lia.char.registerVar("money", {
		field = "_money",
		default = 0,
		isLocal = true,
		noDisplay = true
	})

	lia.char.registerVar("data", {
		default = {},
		isLocal = true,
		noDisplay = true,
		field = "_data",
		onSet = function(character, key, value, noReplication, receiver)
			local data = character:getData()
			local client = character:getPlayer()

			data[key] = value

			if (not noReplication and IsValid(client)) then
				netstream.Start(
					receiver or client,
					"charData",
					character:getID(),
					key, value
				)
			end

			character.vars.data = data
		end,
		onGet = function(character, key, default)
			local data = character.vars.data or {}

			if (key) then
				if (not data) then
					return default
				end

				local value = data[key]

				return value == nil and default or value
			else
				return default or data
			end
		end
	})

	lia.char.registerVar("var", {
		default = {},
		noDisplay = true,
		onSet = function(character, key, value, noReplication, receiver)
			local data = character:getVar()
			local client = character:getPlayer()

			data[key] = value

			if (not noReplication and IsValid(client)) then
				local id

				if (
					client:getChar() and
					client:getChar():getID() == character:getID()
				) then
					id = client:getChar():getID()
				else
					id = character:getID()
				end

				netstream.Start(receiver or client, "charVar", key, value, id)
			end

			character.vars.vars = data
		end,
		onGet = function(character, key, default)
			character.vars.vars = character.vars.vars or {}
			local data = character.vars.vars or {}

			if (key) then
				if (not data) then
					return default
				end

				local value = data[key]

				return value == nil and default or value
			else
				return default or data
			end
		end
	})
end

-- Additions to the player metatable here.
do
	local playerMeta = FindMetaTable("Player")
	playerMeta.steamName = playerMeta.steamName or playerMeta.Name
	playerMeta.SteamName = playerMeta.steamName

	function playerMeta:getChar()
		return lia.char.loaded[self.getNetVar(self, "char")]
	end

	function playerMeta:Name()
		local character = self.getChar(self)

		return character
			and character.getName(character)
			or self.steamName(self)
	end

	playerMeta.Nick = playerMeta.Name
	playerMeta.GetName = playerMeta.Name
end
