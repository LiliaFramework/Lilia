local MODULE = MODULE
function MODULE:PostPlayerLoadout(client)
    if client:hasPrivilege("Use Admin Stick") or client:isStaffOnDuty() then client:Give("adminstick") end
end
