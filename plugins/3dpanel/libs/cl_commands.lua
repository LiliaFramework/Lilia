lia.command.add("paneladd", {
    adminOnly = true,
    syntax = "<string url> [number w] [number h] [number scale]",
    onRun = function(client, arguments) end
})

lia.command.add("panelremove", {
    adminOnly = true,
    syntax = "[number radius]",
    onRun = function(client, arguments) end
})