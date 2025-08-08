local MODULE = MODULE
function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege(L("useAdminStick")) or client:isStaffOnDuty() then client:Give("adminstick") end
end