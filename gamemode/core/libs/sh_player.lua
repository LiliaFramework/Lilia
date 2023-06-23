local playerMeta = FindMetaTable("Player")

lia.util.include("lilia/gamemode/core/meta/sh_player.lua")
-- liaData information for the player.
do
	if (SERVER) then
		function playerMeta:getLiliaData(key, default)
			if (key == true) then
				return self.liaData
			end

			local data = self.liaData and self.liaData[key]

			if (data == nil) then
				return default
			else
				return data
			end
		end
	else
		function playerMeta:getLiliaData(key, default)
			local data = lia.localData and lia.localData[key]

			if (data == nil) then
				return default
			else
				return data
			end
		end

		netstream.Hook("liaDataSync", function(data, first, last)
			lia.localData = data
			lia.firstJoin = first
			lia.lastJoin = last
		end)

		netstream.Hook("liaData", function(key, value)
			lia.localData = lia.localData or {}
			lia.localData[key] = value
		end)
	end
end

-- Whitelist networking information here.
do
	function playerMeta:hasWhitelist(faction)
		local data = lia.faction.indices[faction]

		if (data) then
			if (data.isDefault) then
				return true
			end

			local liaData = self:getLiliaData("whitelists", {})

			return liaData[SCHEMA.folder] and liaData[SCHEMA.folder][data.uniqueID] == true or false
		end

		return false
	end

	function playerMeta:getItems()
		local char = self:getChar()

		if (char) then
			local inv = char:getInv()

			if (inv) then
				return inv:getItems()
			end
		end
	end

	function playerMeta:getClass()
		local char = self:getChar()

		if (char) then
			return char:getClass()
		end
	end

	function playerMeta:getClassData()
		local char = self:getChar()

		if (char) then
			local class = char:getClass()

			if (class) then
				local classData = lia.class.list[class]

				return classData
			end
		end
	end
end