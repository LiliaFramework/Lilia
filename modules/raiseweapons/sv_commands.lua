lia.command.add("toggleraise", {
	adminOnly = false,
	privilege = "Basic User Permissions",
	onRun = function(client, arguments)
		if (client.liaNextToggle or 0) < CurTime() then
			client:toggleWepRaised()
			client.liaNextToggle = CurTime() + lia.config.WeaponToggleDelay
		end
	end
})