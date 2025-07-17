lia.config.add("SwitchCooldownOnAllEntities", "Apply cooldown on all entities", false, nil, {
    desc = "If true, character switch cooldowns gets applied by all types of damage.",
    category = "Character",
    type = "Boolean"
})

lia.config.add("OnDamageCharacterSwitchCooldownTimer", "Switch cooldown after damage", 15, nil, {
    desc = "Cooldown duration (in seconds) after taking damage to switch characters.",
    category = "Character",
    type = "Float",
    min = 0,
    max = 120
})

lia.config.add("CharacterSwitchCooldownTimer", "Character switch cooldown timer", 5, nil, {
    desc = "Cooldown duration (in seconds) for switching characters.",
    category = "Character",
    type = "Float",
    min = 0,
    max = 120
})

lia.config.add("ExplosionRagdoll", "Explosion Ragdoll on Hit", false, nil, {
    desc = "Determines whether being hit by an explosion results in ragdolling",
    category = "Quality of Life",
    type = "Boolean"
})

lia.config.add("CarRagdoll", "Car Ragdoll on Hit", false, nil, {
    desc = "Determines whether being hit by a car results in ragdolling",
    category = "Quality of Life",
    type = "Boolean"
})

lia.config.add("NPCsDropWeapons", "NPCs Drop Weapons on Death", false, nil, {
    desc = "Controls whether NPCs drop weapons upon death",
    category = "Quality of Life",
    type = "Boolean"
})

lia.config.add("TimeUntilDroppedSWEPRemoved", "Time Until Dropped SWEP Removed", 15, nil, {
    desc = "Specifies the duration (in seconds) until a dropped SWEP is removed",
    category = "Protection",
    type = "Float",
    min = 0,
    max = 300
})

lia.config.add("AltsDisabled", "Disable Alts", false, nil, {
    desc = "Whether or not alting is permitted",
    category = "Protection",
    type = "Boolean"
})

lia.config.add("ActsActive", "Enable Acts", false, nil, {
    desc = "Determines whether acts are active",
    category = "Protection",
    type = "Boolean"
})

lia.config.add("PassableOnFreeze", "Passable on Freeze", false, nil, {
    desc = "Makes it so that props frozen can be passed through when frozen",
    category = "Protection",
    type = "Boolean"
})

lia.config.add("PlayerSpawnVehicleDelay", "Player Spawn Vehicle Delay", 30, nil, {
    desc = "Delay for spawning a vehicle after the previous one",
    category = "Protection",
    type = "Float",
    min = 0,
    max = 300
})

lia.config.add("ToolInterval", "Tool Gun Usage Cooldown", 0, nil, {
    desc = "Tool Gun Usage Cooldown",
    category = "Protection",
    type = "Float",
    min = 0,
    max = 60
})

lia.config.add("DisableLuaRun", "Disable Lua Run Hooks", false, nil, {
    desc = "Whether or not Lilia should prevent lua_run hooks on maps",
    category = "Protection",
    type = "Boolean"
})

lia.config.add("EquipDelay", "Equip Delay", 0, nil, {
    desc = "Time delay between equipping items.",
    category = "Items",
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("UnequipDelay", "Unequip Delay", 0, nil, {
    desc = "Time delay between unequipping items.",
    category = "Items",
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("DropDelay", "Drop Delay", 0, nil, {
    desc = "Time delay between dropping items.",
    category = "Items",
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("TakeDelay", "Take Delay", 0, nil, {
    desc = "Time delay between taking items.",
    category = "Items",
    type = "Float",
    min = 0,
    max = 10
})

lia.config.add("ItemGiveSpeed", "Item Give Speed", 6, nil, {
    desc = "How fast transferring items between players via giveForward is.",
    category = "Items",
    type = "Int",
    min = 1,
    max = 60
})

lia.config.add("ItemGiveEnabled", "Is Item Giving Enabled", true, nil, {
    desc = "Determines if item giving via giveForward is enabled.",
    category = "Items",
    type = "Boolean"
})
