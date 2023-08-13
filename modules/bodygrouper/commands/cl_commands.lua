lia.command.add("viewBodygroups", {
    syntax = "[string name]",
    onCheckAccess = function(client)
        return MODULE:CanChangeBodygroup(client)
    end,
    onRun = function(client, args) end
})