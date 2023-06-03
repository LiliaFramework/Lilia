lia.command.add("setpropdesc", {
	syntax = "<string description>",
	onRun = function(client, arguments)
		local objdesc = arguments[1]
		local ent = client:GetEyeTrace().Entity

		if not arguments[1] then
			ent:setNetVar("exDesc", "")
		end

		if IsValid(ent) then
			ent:setNetVar("exDesc", objdesc)
		end
	end
})