lia.config.add("LoseItemsonDeathNPC", "Lose Items on NPC Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by NPCs",
    category = "Death",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathHuman", "Lose Items on Human Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by Humans",
    category = "Death",
    type = "Boolean"
})

lia.config.add("LoseItemsonDeathWorld", "Lose Items on World Death", false, nil, {
    desc = "Determine if items marked for loss are lost on death by World",
    category = "Death",
    type = "Boolean"
})

lia.config.add("DeathPopupEnabled", "Enable Death Popup", true, nil, {
    desc = "Enable or disable the death information popup",
    category = "Death",
    type = "Boolean"
})

lia.config.add("StaffHasGodMode", "Staff God Mode", true, nil, {
    desc = "Whether or not Staff On Duty has God Mode",
    category = "Staff",
    type = "Boolean"
})
