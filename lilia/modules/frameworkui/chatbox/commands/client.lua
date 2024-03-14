lia.command.add("banooc", {
    adminOnly = true,
    privilege = "Ban OOC",
    syntax = "<string target>",
    onRun = function() end
})

lia.command.add("unbanooc", {
    adminOnly = true,
    privilege = "Unban OOC",
    syntax = "<string target>",
    onRun = function() end
})

lia.command.add("blockooc", {
    superAdminOnly = true,
    privilege = "Block OOC",
    syntax = "<string target>",
    onRun = function() end
})

lia.command.add("refreshfonts", {
    superAdminOnly = true,
    privilege = "Refresh Fonts",
    syntax = "<No Input>",
    onRun = function() end
})

lia.command.add("clearchat", {
    superAdminOnly = true,
    privilege = "Clear Chat",
    onRun = function() end
})
