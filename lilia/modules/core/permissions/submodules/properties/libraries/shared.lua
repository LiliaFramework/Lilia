---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------
function PropertiesCore:InitializedModules()
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
end
---------------------------------------------------------------------------[[//////////////////]]---------------------------------------------------------------------------