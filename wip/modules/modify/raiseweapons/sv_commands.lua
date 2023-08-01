lia.command.add("toggleraise", {
	onRun = function(client, arguments)
		if (client.liaNextToggle or 0) < CurTime() then
			client:toggleWepRaised()
			client.liaNextToggle = CurTime() + CONFIG.WeaponToggleDelay
		end
	end
})