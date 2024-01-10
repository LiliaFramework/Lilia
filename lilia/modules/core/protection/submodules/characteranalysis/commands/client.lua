--------------------
lia.command.add(
    "auditmoney",
    {
        privilege = "Audit Money",
        superAdminOnly = true,
        onRun = function() end
    }
)

--------------------
lia.command.add(
    "report",
    {
        privilege = "Check Player Reports",
        syntax = "<steamID64>",
        superAdminOnly = true,
        onRun = function() end
    }
)
--------------------
