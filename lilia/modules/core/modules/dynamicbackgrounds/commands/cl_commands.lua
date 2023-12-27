--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "dynamicsceneadd",
    {
        privilege = "Add Map Scene",
        adminOnly = true,
        syntax = "[bool isPair]",
        onRun = function(client, arguments) end
    }
)

--------------------------------------------------------------------------------------------------------------------------
lia.command.add(
    "dynamicsceneremove",
    {
        privilege = "DeleteMap Scene",
        adminOnly = true,
        syntax = "[number radius]",
        onRun = function(client, arguments) end
    }
)
--------------------------------------------------------------------------------------------------------------------------
