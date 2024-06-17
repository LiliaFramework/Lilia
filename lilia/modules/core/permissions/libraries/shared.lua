function MODULE:InitializedModules()
    if properties.List then
        for name, _ in pairs(properties.List) do
            if (name == "persist") or (name == "drive") or (name == "bonemanipulate") then continue end
            local privilege = "Staff Permissions - Access Property " .. name:gsub("^%l", string.upper)
            if not CAMI.GetPrivilege(privilege) then
                local privilegeInfo = {
                    Name = privilege,
                    MinAccess = "admin",
                    Description = "Allows access to Entity Property " .. name:gsub("^%l", string.upper)
                }

                CAMI.RegisterPrivilege(privilegeInfo)
            end
        end
    end

    for _, wep in pairs(weapons.GetList()) do
        if wep.ClassName == "gmod_tool" then
            for ToolName, _ in pairs(wep.Tool) do
                if not ToolName then continue end
                local privilege = "Staff Permissions - Access Tool " .. ToolName:gsub("^%l", string.upper)
                if not CAMI.GetPrivilege(privilege) then
                    local privilegeInfo = {
                        Name = privilege,
                        MinAccess = "admin",
                        Description = "Allows access to " .. ToolName:gsub("^%l", string.upper)
                    }

                    CAMI.RegisterPrivilege(privilegeInfo)
                end
            end
        end
    end
end

lia.flag.add("p", "Access to the physgun.", function(client, isGiven)
    if isGiven then
        client:Give("weapon_physgun")
        client:SelectWeapon("weapon_physgun")
    else
        client:StripWeapon("weapon_physgun")
    end
end)

lia.flag.add("t", "Access to the toolgun", function(client, isGiven)
    if isGiven then
        client:Give("gmod_tool")
        client:SelectWeapon("gmod_tool")
    else
        client:StripWeapon("gmod_tool")
    end
end)

lia.flag.add("C", "Access to spawn vehicles.")
lia.flag.add("z", "Access to spawn SWEPS.")
lia.flag.add("E", "Access to spawn SENTs.")
lia.flag.add("L", "Access to spawn Effects.")
lia.flag.add("r", "Access to spawn ragdolls.")
lia.flag.add("e", "Access to spawn props.")
lia.flag.add("n", "Access to spawn NPCs.")
