function MODULE:PostPlayerLoadout(client)
    if client:HasPrivilege("Staff Permissions - Use Admin Stick") or client:isStaffOnDuty() then client:Give("adminstick") end
end