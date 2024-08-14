--- Checks if the player belongs to the "user" user group.
-- @realm shared
-- @treturn bool Whether the player belongs to the "user" user group.
function playerMeta:isUser()
    return self:IsUserGroup("user")
end

--- Checks if the player is a staff member.
-- @realm shared
-- @treturn bool Whether the player is a staff member.
function playerMeta:isStaff()
    return self:HasPrivilege("UserGroups - Staff Group")
end

--- Checks if the player is a VIP.
-- @realm shared
-- @treturn bool Whether the player is a VIP.
function playerMeta:isVIP()
    return self:HasPrivilege("UserGroups - VIP Group")
end

--- Checks if the staff member is currently on duty (FACTION_STAFF).
-- @realm shared
-- @treturn bool Whether the staff member is currently on duty.
function playerMeta:isStaffOnDuty()
    return self:Team() == FACTION_STAFF
end

playerMeta.IsUser = playerMeta.isUser
playerMeta.IsStaff = playerMeta.isStaff
playerMeta.IsVIP = playerMeta.isVIP
playerMeta.IsStaffOnDuty = playerMeta.isStaffOnDuty
