lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}

function lia.attribs.loadFromDir(directory)
	for _, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
		local niceName = v:sub(4, -5)

		ATTRIBUTE = lia.attribs.list[niceName] or {}
			if (PLUGIN) then
				ATTRIBUTE.plugin = PLUGIN.uniqueID
			end

			lia.util.include(directory.."/"..v)

			ATTRIBUTE.name = ATTRIBUTE.name or "Unknown"
			ATTRIBUTE.desc = ATTRIBUTE.desc or "No description availalble."

			lia.attribs.list[niceName] = ATTRIBUTE
		ATTRIBUTE = nil
	end
end

function lia.attribs.setup(client)
	local character = client:getChar()

	if (character) then
		for k, v in pairs(lia.attribs.list) do
			if (v.onSetup) then
				v:onSetup(client, character:getAttrib(k, 0))
			end
		end
	end
end

-- Add updating of attributes to the character metatable.
do
	local charMeta = lia.meta.character

	if (SERVER) then
		function charMeta:updateAttrib(key, value)
			local attribute = lia.attribs.list[key]
			local client = self:getPlayer()

			if (attribute) then
				local attrib = self:getAttribs()

				attrib[key] = math.min((attrib[key] or 0) + value, attribute.maxValue or lia.config.get("maxAttribs", 30))

				if (IsValid(client)) then
					netstream.Start(client, "attrib", self:getID(), key, attrib[key])

					if (attribute.setup) then
						attribute.setup(attrib[key])
					end
				end
			end

			hook.Run("OnCharAttribUpdated", client, self, key, value)
		end

		function charMeta:setAttrib(key, value)
			local attribute = lia.attribs.list[key]

			if (attribute) then
				local attrib = self:getAttribs()
				local client = self:getPlayer()

				attrib[key] = value

				if (IsValid(client)) then
					netstream.Start(client, "attrib", self:getID(), key, attrib[key])

					if (attribute.setup) then
						attribute.setup(attrib[key])
					end
				end
			end

			hook.Run("OnCharAttribUpdated", client, self, key, value)
		end

		function charMeta:addBoost(boostID, attribID, boostAmount)
			local boosts = self:getVar("boosts", {})

			boosts[attribID] = boosts[attribID] or {}
			boosts[attribID][boostID] = boostAmount

			hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, boostAmount)

			return self:setVar("boosts", boosts, nil, self:getPlayer())
		end

		function charMeta:removeBoost(boostID, attribID)
			local boosts = self:getVar("boosts", {})

			boosts[attribID] = boosts[attribID] or {}
			boosts[attribID][boostID] = nil

			hook.Run("OnCharAttribBoosted", self:getPlayer(), self, attribID, boostID, true)

			return self:setVar("boosts", boosts, nil, self:getPlayer())
		end
	else
		netstream.Hook("attrib", function(id, key, value)
			local character = lia.char.loaded[id]

			if (character) then
				character:getAttribs()[key] = value
			end
		end)
	end

	function charMeta:getBoost(attribID)
		local boosts = self:getBoosts()

		return boosts[attribID]
	end

	function charMeta:getBoosts()
		return self:getVar("boosts", {})
	end

	function charMeta:getAttrib(key, default)
		local att = self:getAttribs()[key] or default or 0
		local boosts = self:getBoosts()[key]

		if (boosts) then
			for _, v in pairs(boosts) do
				att = att + v
			end
		end

		return att
	end
end

hook.Add("DoPluginIncludes", "liaAttribsLib", function(path)
	lia.attribs.loadFromDir(path.."/attributes")
end)
