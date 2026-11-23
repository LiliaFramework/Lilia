MODULE.name = "Appearance"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Provides model, skin, and bodygroup customization through one appearance wardrobe entity."
MODULE.NetworkStrings = {
    "AppearanceMenuOpen",
    "AppearanceMenuSubmit",
    "AppearanceMenuClosed",
    "AppearanceMenuDismiss",
}
MODULE.Privileges = {
    ["manageBodygroups"] = {
        Name = "Manage Bodygroups",
        MinAccess = "admin",
        Category = "appearance",
    },
    ["changeBodygroups"] = {
        Name = "Change Bodygroups",
        Description = "Allows access to changing another player's skin and bodygroups.",
        MinAccess = "admin",
        Category = "appearance",
    },
}

function MODULE:ModuleLoaded()
    for id, data in pairs(self.Privileges or {}) do
        lia.admin.registerPrivilege({
            Name = data.Name or id,
            ID = id,
            MinAccess = data.MinAccess or "admin",
            Category = data.Category,
            Description = data.Description or data.Desc,
        })
    end
end
