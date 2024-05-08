local GM = GM or GAMEMODE
function GM:CanTool(client, _, tool)
    local privilege = "Staff Permissions - Access Tool " .. tool:gsub("^%l", string.upper)
    local toolobj = client:GetActiveWeapon():GetToolObject()
    local entity = client:GetTracedEntity()
    local validEntity = IsValid(entity)
    local isUser = client:IsUserGroup("user")
    if not client.ToolInterval then client.ToolInterval = CurTime() end
    if CurTime() < client.ToolInterval then
        client:notify("Tool on Cooldown!")
        return false
    end

    if validEntity then
        local entClass = entity:GetClass()
        local clientOwned = entity:GetCreator() == client
        local basePermission = (client:getChar():hasFlags("t") and isUser and clientOwned) or (client:isStaffOnDuty() and CAMI.PlayerHasAccess(client, privilege, nil)) or client:IsSuperAdmin()
        if tool == "remover" then
            if table.HasValue(PermissionCore.RemoverBlockedEntities, entClass) then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove Blocked Entities", nil)
            elseif entity:IsWorld() then
                return CAMI.PlayerHasAccess(client, "Staff Permissions - Can Remove World Entities", nil)
            end
            return basePermission
        end

        if tool == "inflator" then return basePermission end
        if tool == "nocollide" then return basePermission end
        if tool == "colour" then return basePermission end
        if tool == "material" or tool == "submaterial" then
            if entClass == "prop_vehicle_jeep" or (tool:GetClientInfo("override") and string.lower(tool:GetClientInfo("override")) == "pp/copy") then return false end
            return basePermission
        end

        if (tool == "permaall" or tool == "permaprops" or tool == "blacklistandremove") and (string.StartsWith(entClass, "lia_") or table.HasValue(PermissionCore.CanNotPermaProp, entClass) or entity.IsLeonNPC) then return false end
        if (tool == "adv_duplicator" or tool == "advdupe2" or tool == "duplicator" or tool == "blacklistandremove") and (table.HasValue(PermissionCore.DuplicatorBlackList, entity) or entity.NoDuplicate) then return false end
        if tool == "weld" and entClass == "sent_ball" then return false end
    end

    if tool == "duplicator" and client.CurrentDupe and client.CurrentDupe.Entities then
        for _, v in pairs(client.CurrentDupe.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "advdupe2" and client.AdvDupe2 and client.AdvDupe2.Entities then
        for _, v in pairs(client.AdvDupe2.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "adv_duplicator" and toolobj.Entities then
        for _, v in pairs(toolobj.Entities) do
            if v.ModelScale and v.ModelScale > 10 then
                client:notify("A model within this duplication exceeds the size limit!")
                print("[Server Warning] Potential server crash using dupes attempt by player: " .. client:Name() .. " (" .. client:SteamID() .. ")")
                return false
            end

            v.ModelScale = 1
        end
    end

    if tool == "button" and not table.HasValue(PermissionCore.ButtonList, client:GetInfo("button_model")) then
        client:ConCommand("button_model models/maxofs2d/button_05.mdl")
        client:ConCommand("button_model")
        return false
    end

    client.ToolInterval = CurTime() + PermissionCore.ToolInterval
    return (client:isStaffOnDuty() or client:getChar():hasFlags("t")) and CAMI.PlayerHasAccess(client, privilege, nil)
end
