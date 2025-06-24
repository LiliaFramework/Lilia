local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

--[[
    entityMeta:isProp()

    Description:
        Returns true if the entity is a physics prop.

    Realm:
        Shared

    Returns:
        boolean – Whether the entity is a physics prop.
]]
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

--[[
    entityMeta:isItem()

    Description:
        Checks if the entity is an item entity.

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents an item.
]]
function entityMeta:isItem()
    return self:GetClass() == "lia_item"
end

--[[
    entityMeta:isMoney()

    Description:
        Checks if the entity is a money entity.

    Realm:
        Shared

    Returns:
        boolean – True if the entity represents money.
]]
function entityMeta:isMoney()
    return self:GetClass() == "lia_money"
end

--[[
    entityMeta:isSimfphysCar()

    Description:
        Checks if the entity is a simfphys car.

    Realm:
        Shared

    Returns:
        boolean – True if this is a simfphys vehicle.
]]
function entityMeta:isSimfphysCar()
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

--[[
    entityMeta:isLiliaPersistent()

    Description:
        Determines if the entity is persistent in Lilia.

    Realm:
        Shared

    Returns:
        boolean – Whether the entity should persist.
]]
function entityMeta:isLiliaPersistent()
    return self.IsLeonNPC or self.IsPersistent
end

--[[
    entityMeta:checkDoorAccess(client, access)

    Description:
        Checks if a player has the given door access level.

    Parameters:
        client (Player) – The player to check.
        access (number, optional) – Door permission level.

    Realm:
        Shared

    Returns:
        boolean – True if the player has access.
]]
function entityMeta:checkDoorAccess(client, access)
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    local parent = self.liaParent
    if IsValid(parent) then return parent:checkDoorAccess(client, access) end
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

--[[
    entityMeta:keysOwn(client)

    Description:
        Assigns the entity to the specified player.

    Parameters:
        client (Player) – Player to set as owner.

    Realm:
        Shared
]]
function entityMeta:keysOwn(client)
    if self:IsVehicle() then
        self:CPPISetOwner(client)
        self:setNetVar("owner", client:getChar():getID())
        self.ownerID = client:getChar():getID()
        self:setNetVar("ownerName", client:getChar():getName())
    end
end

--[[
    entityMeta:keysLock()

    Description:
        Locks the entity if it is a vehicle.

    Realm:
        Shared
]]
function entityMeta:keysLock()
    if self:IsVehicle() then self:Fire("lock") end
end

--[[
    entityMeta:keysUnLock()

    Description:
        Unlocks the entity if it is a vehicle.

    Realm:
        Shared
]]
function entityMeta:keysUnLock()
    if self:IsVehicle() then self:Fire("unlock") end
end

--[[
    entityMeta:getDoorOwner()

    Description:
        Returns the player that owns this door if available.

    Realm:
        Shared

    Returns:
        Player|nil – Door owner or nil.
]]
function entityMeta:getDoorOwner()
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

--[[
    entityMeta:isLocked()

    Description:
        Returns the locked state stored in net variables.

    Realm:
        Shared

    Returns:
        boolean – Whether the door is locked.
]]
function entityMeta:isLocked()
    return self:getNetVar("locked", false)
end

--[[
    entityMeta:isDoorLocked()

    Description:
        Checks the internal door locked state.

    Realm:
        Shared

    Returns:
        boolean – True if the door is locked.
]]
function entityMeta:isDoorLocked()
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

--[[
    entityMeta:getEntItemDropPos(offset)

    Description:
        Calculates a drop position in front of the entity's eyes.

    Parameters:
        offset (number) – Distance from the player eye position.

    Realm:
        Shared

    Returns:
        Vector – Drop position and angle.
]]
function entityMeta:getEntItemDropPos(offset)
    if not offset then offset = 64 end
    local trResult = util.TraceLine({
        start = self:EyePos(),
        endpos = self:EyePos() + self:GetAimVector() * offset,
        mask = MASK_SHOT,
        filter = {self}
    })
    return trResult.HitPos + trResult.HitNormal * 5, trResult.HitNormal:Angle()
end

--[[
    entityMeta:isNearEntity(radius, otherEntity)

    Description:
        Checks for another entity of the same class nearby.

    Parameters:
        radius (number) – Sphere radius in units.
        otherEntity (Entity, optional) – Specific entity to look for.

    Realm:
        Shared

    Returns:
        boolean – True if another entity is within radius.
]]
function entityMeta:isNearEntity(radius, otherEntity)
    if otherEntity == self then return true end
    if not radius then radius = 96 end
    for _, v in ipairs(ents.FindInSphere(self:GetPos(), radius)) do
        if v == self then continue end
        if IsValid(otherEntity) and v == otherEntity or v:GetClass() == self:GetClass() then return true end
    end
    return false
end

--[[
    entityMeta:GetCreator()

    Description:
        Returns the entity creator player.

    Realm:
        Shared

    Returns:
        Player|nil – Creator player if stored.
]]
function entityMeta:GetCreator()
    return self:getNetVar("creator", nil)
end

if SERVER then
    --[[
        entityMeta:SetCreator(client)

        Description:
            Stores the creator player on the entity.

        Parameters:
            client (Player) – Creator of the entity.

        Realm:
            Server
    ]]
    function entityMeta:SetCreator(client)
        self:setNetVar("creator", client)
    end

    --[[
        entityMeta:sendNetVar(key, receiver)

        Description:
            Sends a network variable to recipients.

        Parameters:
            key (string) – Identifier of the variable.
            receiver (Player|nil) – Who to send to.

        Realm:
            Server

        Internal:
            Used by the networking system.
    ]]
    function entityMeta:sendNetVar(key, receiver)
        netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
    end

    --[[
        entityMeta:clearNetVars(receiver)

        Description:
            Clears all network variables on this entity.

        Parameters:
            receiver (Player|nil) – Receiver to notify.

        Realm:
            Server
    ]]
    function entityMeta:clearNetVars(receiver)
        lia.net[self] = nil
        netstream.Start(receiver, "nDel", self:EntIndex())
    end

    --[[
        entityMeta:removeDoorAccessData()

        Description:
            Clears all stored door access information.

        Realm:
            Server
    ]]
    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                netstream.Start(k, "doorMenu")
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    --[[
        entityMeta:setLocked(state)

        Description:
            Stores the door locked state in network variables.

        Parameters:
            state (boolean) – New locked state.

        Realm:
            Server
    ]]
    function entityMeta:setLocked(state)
        self:setNetVar("locked", state)
    end

    --[[
        entityMeta:isDoor()

        Description:
            Returns true if the entity's class indicates a door.

        Realm:
            Server

        Returns:
            boolean – Whether the entity is a door.
    ]]
    function entityMeta:isDoor()
        if not IsValid(self) then return end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    --[[
        entityMeta:getDoorPartner()

        Description:
            Returns the partner door linked with this entity.

        Realm:
            Server

        Returns:
            Entity|nil – The partnered door.
    ]]
    function entityMeta:getDoorPartner()
        return self.liaPartner
    end

    --[[
        entityMeta:setNetVar(key, value, receiver)

        Description:
            Updates a network variable and sends it to recipients.

        Parameters:
            key (string) – Variable name.
            value (any) – Value to store.
            receiver (Player|nil) – Who to send update to.

        Realm:
            Server
    ]]
    function entityMeta:setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        if lia.net[self][key] ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
    end

    --[[
        entityMeta:getNetVar(key, default)

        Description:
            Retrieves a stored network variable or a default value.

        Parameters:
            key (string) – Variable name.
            default (any) – Value returned if variable is nil.

        Realm:
            Server
            Client

        Returns:
            any – Stored value or default.
    ]]
    function entityMeta:getNetVar(key, default)
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
else
    --[[
        entityMeta:isDoor()

        Description:
            Client-side door check using class name.

        Realm:
            Client

        Returns:
            boolean – True if entity class contains "door".
    ]]
    function entityMeta:isDoor()
        return self:GetClass():find("door")
    end

    --[[
        entityMeta:getDoorPartner()

        Description:
            Attempts to find the door partnered with this one.

        Realm:
            Client

        Returns:
            Entity|nil – The partner door entity.
    ]]
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

    --[[
        entityMeta:getNetVar(key, default)

        Description:
            Retrieves a network variable for this entity on the client.

        Parameters:
            key (string) – Variable name.
            default (any) – Default if not set.

        Realm:
            Client

        Returns:
            any – Stored value or default.
    ]]
    function entityMeta:getNetVar(key, default)
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end
