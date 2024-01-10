lia.command.add(
    "logs",
    {
        adminOnly = false,
        privilege = "Default User Commands",
        onRun = function(client) client:ConCommand("mlogs") end
    }
)
