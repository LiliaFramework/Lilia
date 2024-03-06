
function MODULE:InitializedModules()
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

