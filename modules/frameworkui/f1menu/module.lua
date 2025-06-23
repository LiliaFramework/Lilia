MODULE.name = "F1 Menu"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a F1 Menu that allows to access several characters sub-menus."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permission — Access Entity List",
        MinAccess = "admin",
        Description = "Allows access to the scoreboard’s admin options."
    },
    {
        Name = "Staff Permission — Teleport to Entity",
        MinAccess = "admin",
        Description = "Allows teleporting to any entity."
    },
    {
        Name = "Staff Permission — Teleport to Entity (Entity Tab)",
        MinAccess = "admin",
        Description = "Allows teleporting to entities from the Entity tab."
    },
    {
        Name = "Staff Permission — View Entity (Entity Tab)",
        MinAccess = "admin",
        Description = "Allows viewing detailed entity information from the Entity tab."
    },
    {
        Name = "Staff Permission — Access Module List",
        MinAccess = "user",
        Description = "Allows access to the module management panel."
    }
}

function MODULE:InitializedModules()
    local function getMenuTabNames()
        local defs = {}
        hook.Run("CreateMenuButtons", defs)
        local tabs = {}
        for k in pairs(defs) do
            tabs[#tabs + 1] = k
        end
        return tabs
    end

    lia.config.add("DefaultMenuTab", "Default Menu Tab", L("status"), nil, {
        desc = "Specifies which tab is opened by default when the menu is shown.",
        category = "Menu",
        type = "Table",
        options = CLIENT and getMenuTabNames() or {L("status")}
    })
end
