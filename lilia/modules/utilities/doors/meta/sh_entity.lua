--- The Entity Meta for the Doors Module.
-- @entitymeta Doors
local entityMeta = FindMetaTable("Entity")
--- Checks if a player has access to a door.
-- This function checks if a player has the required access level to interact with a door.
-- @realm shared
-- @client client The player whose access is being checked.
-- @number access The access level required (defaults to DOOR_GUEST).
-- @treturn boolean True if the player has the required access, false otherwise.
function entityMeta:checkDoorAccess(client, access)
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    local parent = self.liaParent
    if IsValid(parent) then return parent:checkDoorAccess(client, access) end
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

--- Checks if the door is locked.
-- This function checks whether the door entity is currently locked.
-- @realm shared
-- @treturn boolean True if the door is locked, false otherwise.
function entityMeta:IsLocked()
    return self.isLocked
end

--- Checks if the entity is locked (pertaining to doors).
-- @realm shared
-- @treturn bool True if the entity is locked, false otherwise.
function entityMeta:isDoorLocked()
    return sself:GetInternalVariable("m_bLocked") or self.locked or false
end

if SERVER then
    --- Removes all door access data.
    -- This function clears all access data associated with the door and updates the clients.
    -- @realm server
    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                netstream.Start(k, "doorMenu")
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    --- Sets the locked state of the door.
    -- This function sets whether the door is locked or not.
    -- @realm server
    -- @bool state The new locked state of the door (true for locked, false for unlocked).
    function entityMeta:SetLocked(state)
        self.isLocked = state
    end

    --- Checks if the entity is a door.
    -- @realm server
    -- @internal
    -- @treturn bool True if the entity is a door, false otherwise.
    function entityMeta:isDoor()
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    --- Retrieves the partner entity of the door.
    -- @realm server
    -- @treturn Entity The partner entity of the door, if any.
    function entityMeta:getDoorPartner()
        return self.liaPartner
    end
else
    --- Checks if the entity is a door.
    -- @realm client
    -- @treturn bool True if the entity is a door, false otherwise.
    function entityMeta:isDoor()
        return self:GetClass():find("door")
    end

    --- Retrieves the partner door entity associated with this entity.
    -- @realm client
    -- @treturn Entity The partner door entity, if any.
    function entityMeta:getDoorPartner()
        local owner = self:GetOwner() or self.liaDoorOwner
        if IsValid(owner) and owner:isDoor() then return owner end
        for _, v in ipairs(ents.FindByClass("prop_door_rotating")) do
            if v:GetOwner() == self then
                self.liaDoorOwner = v
                return v
            end
        end
    end
end

entityMeta.IsLocked = entityMeta.isLocked
entityMeta.IsDoor = entityMeta.isDoor
entityMeta.GetDoorPartner = entityMeta.getDoorPartner
entityMeta.IsDoorLocked = entityMeta.isDoorLocked
