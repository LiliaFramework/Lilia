lia.config.add("DisplayStaffCommands", "Display Staff Commands", true, nil, {
    desc = "Controls whether notifications and commands for staff are displayed.",
    category = "Staff",
    type = "Boolean"
})

lia.config.add("AdminOnlyNotification", "Admin Only Notifications", true, nil, {
    desc = "Restricts certain notifications to admins with specific permissions or those on duty.",
    category = "Staff",
    type = "Boolean"
})

lia.config.add("SAMEnforceStaff", "Enforce Staff Rank To SAM", true, nil, {
    desc = "Determines whether staff enforcement for SAM commands is enabled",
    category = "Staff",
    
    
    type = "Boolean"
})
