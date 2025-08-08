local defaultUserTools = {
    remover = true,
}

function MODULE:InitializedModules()
    if properties.List then
        for name, prop in pairs(properties.List) do
            if name ~= "persist" and name ~= "drive" and name ~= "bonemanipulate" then
                lia.administrator.registerPrivilege({
                    Name = L("accessPropertyPrivilege", prop.MenuLabel),
                    MinAccess = "admin",
                    Category = "categoryStaffManagement"
                })
            end
        end
    end

    for _, wep in ipairs(weapons.GetList()) do
        if wep.ClassName == "gmod_tool" and wep.Tool then
            for tool in pairs(wep.Tool) do
                lia.administrator.registerPrivilege({
                    Name = L("accessToolPrivilege", tool:gsub("^%l", string.upper)),
                    MinAccess = defaultUserTools[string.lower(tool)] and "user" or "admin",
                    Category = "categoryStaffTools"
                })
            end
        end
    end
end

lia.flag.add("p", "flagPhysgun", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "flagToolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

lia.flag.add("C", "flagSpawnVehicles")
lia.flag.add("z", "flagSpawnSweps")
lia.flag.add("E", "flagSpawnSents")
lia.flag.add("L", "flagSpawnEffects")
lia.flag.add("r", "flagSpawnRagdolls")
lia.flag.add("e", "flagSpawnProps")
lia.flag.add("n", "flagSpawnNpcs")
lia.flag.add("V", "flagFactionRoster")
lia.flag.add("K", "flagFactionKick")