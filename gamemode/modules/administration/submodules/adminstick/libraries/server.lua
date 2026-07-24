function MODULE:PostPlayerLoadout(client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local hasUsePositionTool = client:hasPrivilege("usePositionTool")
    local hasDebugMode = client:hasPrivilege("developmentHUD") or client:hasPrivilege("staffHUD")
    local isStaffOnDuty = client:isStaffOnDuty()
    local shouldGiveAdminStick = hasAlwaysSpawnAdminStick or hasUsePositionTool or hasDebugMode or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for function MODULE:PostPlayerLoadout unified admin stick", "hasPrivilege(usePositionTool)=", tostring(hasUsePositionTool), "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "hasDebugMode=", tostring(hasDebugMode), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(shouldGiveAdminStick))
    if shouldGiveAdminStick then client:Give("lia_adminstick") end
end

local function canManageAdminStickPlayer(client)
    if not IsValid(client) then return false end
    return client:hasPrivilege("manageWhitelists") or client:hasPrivilege("manageTransfers")
end

local function buildAdminStickPlayerState(target)
    local state = {
        faction = target:Team(),
        whitelists = {}
    }

    local character = target:getChar()
    if character then state.faction = character:getFaction() end
    local playerData = target:getLiliaData("whitelists", {})
    local schemaKey = SCHEMA and SCHEMA.folder or engine.ActiveGamemode()
    local whitelists = istable(playerData) and playerData[schemaKey] or nil
    if istable(whitelists) then
        for uniqueID, allowed in pairs(whitelists) do
            if allowed then state.whitelists[uniqueID] = true end
        end
    end
    return state
end

net.Receive("liaAdminStickRequestPlayerState", function(_, client)
    if not canManageAdminStickPlayer(client) then return end
    local target = net.ReadEntity()
    if not (IsValid(target) and target:IsPlayer()) then return end
    net.Start("liaAdminStickPlayerState")
    net.WriteEntity(target)
    net.WriteTable(buildAdminStickPlayerState(target))
    net.Send(client)
end)
