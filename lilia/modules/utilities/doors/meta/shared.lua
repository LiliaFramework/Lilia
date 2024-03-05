local entityMeta = FindMetaTable("Entity")
function entityMeta:checkDoorAccess(client, access)
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    local parent = self.liaParent
    if IsValid(parent) then return parent:checkDoorAccess(client, access) end
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end
