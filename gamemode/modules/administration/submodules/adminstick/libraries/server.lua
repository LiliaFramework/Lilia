local MODULE = MODULE
function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege(L("Use Admin Stick")) or client:isStaffOnDuty() then client:Give("adminstick") end
end
