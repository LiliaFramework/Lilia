function MODULE:PostPlayerLoadout(client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local hasUsePositionTool = client:hasPrivilege("usePositionTool")
    local hasDebugMode = client:hasPrivilege("developmentHUD") or client:hasPrivilege("staffHUD")
    local isStaffOnDuty = client:isStaffOnDuty()
    local shouldGiveAdminStick = hasAlwaysSpawnAdminStick or hasUsePositionTool or hasDebugMode or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for function MODULE:PostPlayerLoadout unified admin stick", "hasPrivilege(usePositionTool)=", tostring(hasUsePositionTool), "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "hasDebugMode=", tostring(hasDebugMode), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(shouldGiveAdminStick))
    if shouldGiveAdminStick then client:Give("lia_adminstick") end
end
