
function lia.flag.add(flag, desc, callback)
	lia.flag.list[flag] = {
		desc = desc,
		callback = callback
	}
end

if SERVER then
	function lia.flag.onSpawn(client)
		if client:getChar() then
			local flags = client:getChar():getFlags()

			for i = 1, #flags do
				local flag = flags:sub(i, i)
				local info = lia.flag.list[flag]

				if info and info.callback then
					info.callback(client, true)
				end
			end
		end
	end
end

do
	local character = lia.meta.character

	if SERVER then
		function character:setFlags(flags)
			self:setData("f", flags)
		end

		function character:giveFlags(flags)
			local addedFlags = ""

			for i = 1, #flags do
				local flag = flags:sub(i, i)
				local info = lia.flag.list[flag]

				if info then
					if not character:hasFlags(flag) then
						addedFlags = addedFlags .. flag
					end

					if info.callback then
						info.callback(self:getPlayer(), true)
					end
				end
			end

			if addedFlags ~= "" then
				self:setFlags(self:getFlags() .. addedFlags)
			end
		end

		function character:takeFlags(flags)
			local oldFlags = self:getFlags()
			local newFlags = oldFlags

			for i = 1, #flags do
				local flag = flags:sub(i, i)
				local info = lia.flag.list[flag]

				if info and info.callback then
					info.callback(self:getPlayer(), false)
				end

				newFlags = newFlags:gsub(flag, "")
			end

			if newFlags ~= oldFlags then
				self:setFlags(newFlags)
			end
		end
	end

	function character:getFlags()
		return self:getData("f", "")
	end

	function character:hasFlags(flags)
		for i = 1, #flags do
			if self:getFlags():find(flags:sub(i, i), 1, true) then return true end
		end

		return hook.Run("CharacterFlagCheck", self, flags) or false
	end
end

