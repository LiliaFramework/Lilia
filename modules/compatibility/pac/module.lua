MODULE.partData = {}
MODULE.name = "PAC3"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "1.0"
MODULE.desc = "Adds PAC Compatibility"
MODULE.enabled = pac ~= nil
MODULE.CAMIPrivileges = {
    {
        Name = "Staff Permissions - Can Use PAC3",
        MinAccess = "admin",
        Description = "Allows access to PAC3.",
    }
}

lia.config.add("BlockPackURLoad", "Block Pack URL Load", true, nil, {
    desc = "Determines whether loading PAC3 packs from a URL should be blocked.",
    category = "PAC3",
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})
