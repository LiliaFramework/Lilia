local GM = GM or GAMEMODE
function GM:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    if CurTime() < (client.ToolInterval or 0) then
        client:notify("Tool on Cooldown!")
        return false
    end

    if client:getChar():hasFlags("t") or client:isStaffOnDuty() or CAMI.PlayerHasAccess(client, privilege, nil) then
        if tool == "permaall" and IsValid(entity) and string.StartWith(entity:GetClass(), "lia_") then return false end
        if tool == "material" and validEntity and (entity:GetClass() == "prop_vehicle_jeep" or string.lower(tool:GetClientInfo("override")) == "pp/copy") then return false end
        if tool == "weld" and validEntity and entity:GetClass() == "sent_ball" then return false end
        if tool == "duplicator" then
            if (table.HasValue(PermissionCore.DuplicatorBlackList, entity) or entity.NoDuplicate) and validEntity then return false end
            if client.CurrentDupe and client.CurrentDupe.Entities then
                for _, v in pairs(client.CurrentDupe.Entities) do
                    if v.ModelScale > 10 then
                        client:notify("A model within this duplication exceeds the size limit!")
                        print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Nick() .. " (" .. client:SteamID() .. ")")
                        return false
                    end

                    v.ModelScale = 1
                end
            end
        end

        if tool == "remover" and validEntity then
            if table.HasValue(PermissionCore.RemoverBlockedEntities, entity:GetClass()) then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove Blocked Entities", nil)
            elseif entity:IsWorld() then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove World Entities", nil)
            end
            return true
        end

        if tool == "button" and not table.HasValue(PermissionCore.ButtonList, client:GetInfo("button_model")) then
            client:ConCommand("button_model models/maxofs2d/button_05.mdl")
            client:ConCommand("button_model")
            return false
        end

        client.ToolInterval = CurTime() + PermissionCore.ToolInterval
        return true
    end
    return false
end
