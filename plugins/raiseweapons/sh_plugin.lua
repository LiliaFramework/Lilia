PLUGIN.name = "Raise Weapons"
PLUGIN.author = "Leonheart#7476/Cheesenot"
PLUGIN.desc = "Allows players to raise/lower weapons by holding R (reload)."

lia.config.add(
	"wepAlwaysRaised",
	false,
	"Whether or not weapons are always raised.",
	nil,
	{category = "server"}
)

lia.util.include("sh_player_extensions.lua")
lia.util.include("sv_hooks.lua")
lia.util.include("cl_hooks.lua")
lia.util.include("sh_hooks.lua")

lia.command.add("toggleraise", {
	onRun = function(client, arguments)
		if ((client.liaNextToggle or 0) < CurTime()) then
			client:toggleWepRaised()
			client.liaNextToggle = CurTime() + 0.5
		end
	end
})
