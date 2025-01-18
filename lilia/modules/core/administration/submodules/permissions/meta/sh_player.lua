local playerMeta = FindMetaTable("Player")
function playerMeta:isUser()
  return self:IsUserGroup("user")
end

function playerMeta:isStaff()
  return self:hasPrivilege("UserGroups - Staff Group")
end

function playerMeta:isVIP()
  return self:hasPrivilege("UserGroups - VIP Group")
end

function playerMeta:isStaffOnDuty()
  return self:Team() == FACTION_STAFF
end
