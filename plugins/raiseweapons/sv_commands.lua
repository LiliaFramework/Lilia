lia.command.add("toggleraise", {
	onRun = function(client, arguments)
		if ((client.liaNextToggle or 0) < CurTime()) then
			client:toggleWepRaised()
			client.liaNextToggle = CurTime() + lia.config.get("WeaponToggleDelay", 0.5)
		end
	end
})