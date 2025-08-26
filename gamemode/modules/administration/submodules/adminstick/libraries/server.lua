local MODULE = MODULE
function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege("alwaysSpawnAdminStick") or client:isStaffOnDuty() then client:Give("adminstick") end
end
