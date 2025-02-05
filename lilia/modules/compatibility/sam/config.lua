lia.config.add("DisplayStaffCommands", L("DisplayStaffCommands"), true, nil, {
    desc = L("DisplayStaffCommandsDesc"),
    category = L("StaffCategory"),
    type = "Boolean"
})

lia.config.add("AdminOnlyNotification", L("AdminOnlyNotification"), true, nil, {
    desc = L("AdminOnlyNotificationDesc"),
    category = L("StaffCategory"),
    type = "Boolean"
})

lia.config.add("SAMEnforceStaff", L("SAMEnforceStaff"), true, nil, {
    desc = L("SAMEnforceStaffDesc"),
    category = L("StaffCategory"),
    noNetworking = false,
    schemaOnly = false,
    type = "Boolean"
})
