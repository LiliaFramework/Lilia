local PLUGIN = PLUGIN

lia.command.add("classnameviewer", {
	adminOnly = true,
	onRun = function(ply)
		PLUGIN:OpenClassViewer(ply)
	end
})