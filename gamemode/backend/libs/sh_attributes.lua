lia.attribs = lia.attribs or {}
lia.attribs.list = lia.attribs.list or {}

lia.char.registerVar("attribs", {
	field = "_attribs",
	default = {},
	isLocal = true,
	index = 4,
	onValidate = function(value, data, client)
		if value ~= nil then
			if istable(value) then
				local count = 0

				for k, v in pairs(value) do
					local max = lia.attribs.list[k] and lia.attribs.list[k].startingMax or nil
					if max and max < v then return false, lia.attribs.list[k].name .. " too high" end
					count = count + v
				end

				local points = hook.Run("GetStartAttribPoints", client, count) or lia.config.MaxAttributes
				if count > points then return false, "unknownError" end
			else
				return false, "unknownError"
			end
		end
	end,
	shouldDisplay = function(panel)
		return table.Count(lia.attribs.list) > 0
	end
})