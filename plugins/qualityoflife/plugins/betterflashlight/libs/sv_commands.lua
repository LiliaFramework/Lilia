lia.command.add("flashlightdebugon", {
	adminOnly = true,
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local ent = trace.Entity

		if ent and ent:IsValid() and ent:IsPlayer() then
			ent:SetNWBool("customFlashlight", true)
			client:notify("attempted to force flashlight on")
		end
	end
})

lia.command.add("flashlightdebugoff", {
	adminOnly = true,
	onRun = function(client, arguments)
		local trace = client:GetEyeTraceNoCursor()
		local ent = trace.Entity

		if ent and ent:IsValid() and ent:IsPlayer() then
			ent:SetNWBool("customFlashlight", false)
			client:notify("attempted to force flashlight off")
		end
	end
})