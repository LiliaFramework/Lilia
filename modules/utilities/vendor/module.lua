MODULE.name = "Vendors"
MODULE.author = "76561198312513285"
MODULE.discord = "@liliaplayer"
MODULE.version = "Stock"
MODULE.desc = "Adds NPC vendors that can sell things."
MODULE.CAMIPrivileges = {
	{
		Name = "Staff Permissions - Can Edit Vendors",
		MinAccess = "admin",
		Description = "Allows access to edit vendors.",
	},
}

lia.config.add( "vendorDefaultMoney", "Default Vendor wMoney", 500, nil, {
	desc = "Sets the default amount of money a vendor starts with",
	category = "Vendors",
	type = "Int",
	min = 0,
	max = 100000
} )
