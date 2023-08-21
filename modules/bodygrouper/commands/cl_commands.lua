--------------------------------------------------------------------------------------------------------
local MODULE = MODULE

--------------------------------------------------------------------------------------------------------
lia.command.add("viewBodygroups", {
    adminOnly = true,
    privilege = "Characters - Change Bodygroups",
    syntax = "[string name]",
    onCheckAccess = function(client)
        return MODULE:CanChangeBodygroup(client)
    end,
    onRun = function(client, args) end
})
--------------------------------------------------------------------------------------------------------