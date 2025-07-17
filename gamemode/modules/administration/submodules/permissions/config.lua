lia.config.add("SpawnMenuLimit", "Limit Spawn Menu Access", false, nil, {
    desc = "Determines if the spawn menu is limited to PET flag holders or staff",
    category = "Staff",
    type = "Boolean"
})

lia.option.add("espActive", "ESP Active", "Enable ESP to highlight entities", false, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espPlayers", "ESP Players", "Enable ESP for players", false, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espItems", "ESP Items", "Enable ESP for items", false, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espProps", "ESP Props", "Enable ESP for props", false, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espEntities", "ESP Entities", "Enable ESP for entities", false, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espItemsColor", "ESP Items Color", "Sets the ESP color for items", {
    r = 0,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espEntitiesColor", "ESP Entities Color", "Sets the ESP color for entities", {
    r = 255,
    g = 255,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espPropsColor", "ESP Props Color", "Sets the ESP color for props", {
    r = 255,
    g = 0,
    b = 0,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("espPlayersColor", "ESP Players Color", "Sets the ESP color for players", {
    r = 0,
    g = 0,
    b = 255,
    a = 255
}, nil, {
    category = "ESP",
    visible = function()
        local ply = LocalPlayer()
        if not IsValid(ply) then return false end
        return ply:isStaffOnDuty() or ply:hasPrivilege("Staff Permissions - No Clip Outside Staff Character")
    end
})

lia.option.add("BarsAlwaysVisible", "Bars Always Visible", "Make all bars always visible", false, nil, {
    category = "General"
})

lia.option.add("descriptionWidth", "Description Width", "Adjust the description width on the HUD", 0.5, nil, {
    category = "HUD",
    min = 0.1,
    max = 1,
    decimals = 2
})

lia.option.add("thirdPersonEnabled", "Third Person Enabled", "Toggle third-person view.", false, function(_, newValue) hook.Run("thirdPersonToggled", newValue) end, {
    category = "Third Person",
})

lia.option.add("thirdPersonClassicMode", "Third Person Classic Mode", "Enable classic third-person view mode.", false, nil, {
    category = "Third Person",
})

lia.option.add("thirdPersonHeight", "Third Person Height", "Adjust the vertical height of the third-person camera.", 10, nil, {
    category = "Third Person",
    min = 0,
    max = lia.config.get("MaxThirdPersonHeight", 30),
})

lia.option.add("thirdPersonHorizontal", "Third Person Horizontal", "Adjust the horizontal offset of the third-person camera.", 10, nil, {
    category = "Third Person",
    min = 0,
    max = lia.config.get("MaxThirdPersonHorizontal", 30),
})

lia.option.add("thirdPersonDistance", "Third Person Distance", "Adjust the camera distance in third-person view.", 50, nil, {
    category = "Third Person",
    min = 0,
    max = lia.config.get("MaxThirdPersonDistance", 100),
})

lia.option.add("ChatShowTime", "Show Chat Timestamp", "Should chat show timestamp", false, nil, {
    category = "Chat",
    type = "Boolean"
})

lia.option.add("voiceRange", "Voice Range", "Display a circle showing your current voice range", false, nil, {
    category = "HUD",
    type = "Boolean"
})
