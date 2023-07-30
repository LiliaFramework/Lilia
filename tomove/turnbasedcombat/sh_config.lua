MODULE.IgnoredNPCs = {
    ["npc_turret_floor"] = true,
    ["npc_rollermine"] = true,
    ["npc_manhack"] = true,
    ["npc_clawscanner"] = true,
    ["npc_cscanner"] = true,
    ["npc_crow"] = true,
    ["npc_pigeon"] = true,
    ["npc_seagull"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_combine_camera"] = true,
    ["npc_stalker"] = true,
    ["npc_helicopter"] = true,
    ["worldspawn"] = true,
    ["env_fire"] = true,
}

lia.config.add("Turn Based Combat On/Off", false, "Weather or not Turn based combat is on globally or not", nil, {
    category = "Turn Based Combat System"
})

lia.config.add("radius", 500, "The radius in which other NPCs/Players will join the combat incounter.", nil, {
    data = {
        min = 100,
        max = 2000
    },
    category = "Turn Based Combat System"
})

lia.config.add("movementradius", 30, "How far the player can travel from their turn starting location before losing AP, This acts as a multiplyer for distance", nil, {
    data = {
        min = 10,
        max = 2000
    },
    category = "Turn Based Combat System"
})

lia.config.add("warmuptimer", 5, "The amount of time before the combat actually begins.", nil, {
    data = {
        min = 1,
        max = 60
    },
    category = "Turn Based Combat System"
})

lia.config.add("playeractionpoints", 3, "Amount of actions a player can take in there turn", nil, {
    data = {
        min = 1,
        max = 100
    },
    category = "Turn Based Combat System"
})

lia.config.add("playertimeammount", 10, "The amount of time the player has before there turn it up.", nil, {
    data = {
        min = 1,
        max = 60
    },
    category = "Turn Based Combat System"
})

lia.config.add("npctimeammount", 5, "The amount of time an NPC has in combat.", nil, {
    data = {
        min = 1,
        max = 60
    },
    category = "Turn Based Combat System"
})