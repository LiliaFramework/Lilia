MODULE.name = "F1 Menu"
MODULE.author = "Samael"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds a F1 Menu that allows to access several characters sub-menus."
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permission — Access Entity List",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permission — Teleport to Entity",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permission — Teleport to Entity (Entity Tab)",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permission — View Entity (Entity Tab)",
        MinAccess = "admin"
    },
    {
        Name = "Staff Permission — Access Module List",
        MinAccess = "user"
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
