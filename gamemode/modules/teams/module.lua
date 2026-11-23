MODULE.name = "Teams"
MODULE.author = "Samael"
MODULE.discord = "liliaplayer"
MODULE.desc = "Manages teams and factions with whitelist support and admin controls."
MODULE.NetworkStrings = {"liaFactionMembers", "liaFactionMemberDetails", "liaKickCharacterToBase", "liaRequestFactionMembers", "liaRequestFactionMemberDetails", "liaSaveFactionNote"}
MODULE.Privileges = {
    ["canManageFactions"] = {
        Name = "Can Manage Factions",
        MinAccess = "admin",
        Category = "Faction Management",
    },
    ["manageWhitelists"] = {
        Name = "Manage Whitelists",
        MinAccess = "admin",
        Category = "Faction Management",
    },
}
