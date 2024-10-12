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
            for tool, _ in pairs(wep.Tool) do
                if not tool then continue end
                local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
                if not CAMI.GetPrivilege(privilege) then
                    local privilegeInfo = {
                        Name = privilege,
                        MinAccess = table.HasValue(self.DefaultUserTools, string.lower(tool)) and "user" or "admin",
                        Description = "Allows access to " .. tool:gsub("^%l", string.upper)
                    }

                    CAMI.RegisterPrivilege(privilegeInfo)
                end
            end
        end
    end
end

concommand.Add("lia", function(client, _, arguments)
    local command = arguments[1]
    table.remove(arguments, 1)
    lia.command.parse(client, nil, command or "", arguments)
end)

concommand.Add("list_entities", function(client)
    local entityCount = {}
    local totalEntities = 0
    if not IsValid(client) or client:IsSuperAdmin() then
        LiliaInformation("Entities on the server:")
        for _, entity in pairs(ents.GetAll()) do
            local className = entity:GetClass() or "Unknown"
            entityCount[className] = (entityCount[className] or 0) + 1
            totalEntities = totalEntities + 1
        end

        for className, count in pairs(entityCount) do
            LiliaInformation(string.format("Class: %s | Count: %d", className, count))
        end

        LiliaInformation("Total entities on the server: " .. totalEntities)
    else
        LiliaInformation("Nuh-uh!")
    end
end)

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