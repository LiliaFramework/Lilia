local MODULE = MODULE

lia.command.add("classnameviewer", {
	adminOnly = true,
	onRun = function(ply)
		MODULE:OpenClassViewer(ply)
	end
})