function MODULE:PostPlayerLoadout(client)
    local hasAlwaysSpawnAdminStick = client:hasPrivilege("alwaysSpawnAdminStick")
    local isStaffOnDuty = client:isStaffOnDuty()
    local shouldGiveAdminStick = hasAlwaysSpawnAdminStick or isStaffOnDuty
    lia.debug("[Permissions]", "Permission Check for function MODULE:PostPlayerLoadout admin stick", "hasPrivilege(alwaysSpawnAdminStick)=", tostring(hasAlwaysSpawnAdminStick), "isStaffOnDuty=", tostring(isStaffOnDuty), "finalResult=", tostring(shouldGiveAdminStick))
    if shouldGiveAdminStick then client:Give("lia_adminstick") end
end
