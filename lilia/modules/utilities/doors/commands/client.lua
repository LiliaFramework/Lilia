lia.command.add("doorsell", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("admindoorsell", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doortogglelock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorbuy", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("doortoggleownable", {
    adminOnly = true,
    syntax = "[string name]",
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("dooraddfaction", {
    adminOnly = true,
    syntax = "[string faction]",
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorremovefaction", {
    adminOnly = true,
    syntax = "[string faction]",
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorinfo", {
    adminOnly = false,
    onRun = function() end
})

lia.command.add("doorsetdisabled", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorforcelock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorforceunlock", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorresetdata", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("disablealldoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("enablealldoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorsetenabled", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorsethidden", {
    adminOnly = true,
    privilege = "Manage Doors",
    syntax = "<bool hidden>",
    onRun = function() end
})

lia.command.add("doorsettitle", {
    adminOnly = true,
    syntax = "<string title>",
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorsetparent", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorsetchild", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorremovechild", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})

lia.command.add("doorsetclass", {
    adminOnly = true,
    syntax = "[string class]",
    privilege = "Manage Doors",
    onRun = function() end,
    alias = {"jobdoor"}
})

lia.command.add("savedoors", {
    adminOnly = true,
    privilege = "Manage Doors",
    onRun = function() end
})