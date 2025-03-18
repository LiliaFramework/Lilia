MODULE.RemoverBlockedEntities = {
    ["lia_bodygroupcloset"] = true,
    ["lia_vendor"] = true,
}

if CLIENT then
    lia.option.add("espActive", "ESP Active", "Enable ESP to highlight entities", false, nil, {
        category = "ESP"
    })

    lia.option.add("espPlayers", "ESP Players", "Enable ESP for players", false, nil, {
        category = "ESP"
    })

    lia.option.add("espItems", "ESP Items", "Enable ESP for items", false, nil, {
        category = "ESP"
    })

    lia.option.add("espProps", "ESP Props", "Enable ESP for props", false, nil, {
        category = "ESP"
    })

    lia.option.add("espEntities", "ESP Entities", "Enable ESP for entities", false, nil, {
        category = "ESP"
    })

    lia.option.add("espItemsColor", "ESP Items Color", "Sets the ESP color for items", {
        r = 0,
        g = 255,
        b = 0,
        a = 255,
    }, nil, {
        category = "ESP"
    })

    lia.option.add("espEntitiesColor", "ESP Entities Color", "Sets the ESP color for entities", {
        r = 255,
        g = 255,
        b = 0,
        a = 255,
    }, nil, {
        category = "ESP"
    })

    lia.option.add("espPropsColor", "ESP Props Color", "Sets the ESP color for props", {
        r = 255,
        g = 0,
        b = 0,
        a = 255,
    }, nil, {
        category = "ESP"
    })

    lia.option.add("espPlayersColor", "ESP Players Color", "Sets the ESP color for players", {
        r = 0,
        g = 0,
        b = 255,
        a = 255,
    }, nil, {
        category = "ESP"
    })
end

lia.config.add("SpawnMenuLimit", "Limit Spawn Menu Access", false, nil, {
    desc = "Determines if the spawn menu is limited to PET flag holders or staff",
    category = "Staff",
    type = "Boolean"
})