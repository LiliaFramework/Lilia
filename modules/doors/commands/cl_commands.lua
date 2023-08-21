--------------------------------------------------------------------------------------------------------
lia.command.add("doorsell", {
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorbuy", {
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetunownable", {
    adminOnly = true,
    syntax = "[string name]",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetownable", {
    adminOnly = true,
    syntax = "[string name]",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("dooraddfaction", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorremovefaction", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetdisabled", {
    adminOnly = true,
    syntax = "<bool disabled>",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsettitle", {
    syntax = "<string title>",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetparent", {
    adminOnly = true,
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetchild", {
    adminOnly = true,
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorremovechild", {
    adminOnly = true,
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsethidden", {
    adminOnly = true,
    syntax = "<bool hidden>",
    onRun = function(client, arguments) end
})

--------------------------------------------------------------------------------------------------------
lia.command.add("doorsetclass", {
    adminOnly = true,
    syntax = "[string faction]",
    onRun = function(client, arguments) end,
    alias = {"jobdoor"}
})
--------------------------------------------------------------------------------------------------------