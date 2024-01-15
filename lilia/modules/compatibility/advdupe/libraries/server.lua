function AdvDupeCompatibility:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local validEntity = IsValid(entity)
    if tool == "adv_duplicator" and IsValid(client) and (client:getChar():hasFlags("t") or client:isStaffOnDuty()) and CAMI.PlayerHasAccess(client, privilege, nil) then
        if table.HasValue(PermissionCore.DuplicatorBlackList, entity) and validEntity then return false end
        if toolobj.Entities then
            for _, v in pairs(toolobj.Entities) do
  

                if v.ModelScale > 10 then
                    client:notify("A model within this duplication exceeds the size limit!")
                    print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Nick() .. " (" .. client:SteamID() .. ")")

                    return false
                end

                v.ModelScale = 1
            end
        end

        return true
    end
end

function AdvDupeCompatibility:PlayerSpawnProp(client)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local usingToolgun = client:GetActiveWeapon():GetClass() == "gmod_tool"
    if usingToolgun and toolobj.Entities then return true end
end

function AdvDupeCompatibility:PlayerSpawnObject(client, _, _)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local usingToolgun = client:GetActiveWeapon():GetClass() == "gmod_tool"
    if usingToolgun and toolobj.Entities then return true end
end

function AdvDupeCompatibility:PlayerSpawnRagdoll(client)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local usingToolgun = client:GetActiveWeapon():GetClass() == "gmod_tool"
    if usingToolgun and toolobj.Entities then return true end
end