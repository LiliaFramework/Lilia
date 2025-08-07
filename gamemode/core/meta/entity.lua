local playerMeta = FindMetaTable("Player")
local entityMeta = FindMetaTable("Entity")
local validClasses = {
    ["lvs_base"] = true,
    ["gmod_sent_vehicle_fphysics_base"] = true,
    ["gmod_sent_vehicle_fphysics_wheel"] = true,
    ["prop_vehicle_prisoner_pod"] = true,
}

--[[
    isProp

    Purpose:
        Checks if the entity is a physics prop.

    Returns:
        boolean - True if the entity is a physics prop, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isProp() then
            print("This is a prop!")
        end
]]
function entityMeta:isProp()
    return self:GetClass() == "prop_physics"
end

--[[
    isItem

    Purpose:
        Checks if the entity is an item entity.

    Returns:
        boolean - True if the entity is an item, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isItem() then
            print("This is an item!")
        end
]]
function entityMeta:isItem()
    return self:GetClass() == "lia_item"
end

--[[
    isMoney

    Purpose:
        Checks if the entity is a money entity.

    Returns:
        boolean - True if the entity is money, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isMoney() then
            print("This is money!")
        end
]]
function entityMeta:isMoney()
    return self:GetClass() == "lia_money"
end

--[[
    isSimfphysCar

    Purpose:
        Checks if the entity is a simfphys or LVS vehicle.

    Returns:
        boolean - True if the entity is a simfphys or LVS vehicle, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isSimfphysCar() then
            print("This is a simfphys/LVS car!")
        end
]]
function entityMeta:isSimfphysCar()
    return validClasses[self:GetClass()] or self.IsSimfphyscar or self.LVS or validClasses[self.Base]
end

--[[
    isLiliaPersistent

    Purpose:
        Checks if the entity is persistent in the Lilia framework.

    Returns:
        boolean - True if the entity is persistent, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isLiliaPersistent() then
            print("This entity is persistent!")
        end
]]
function entityMeta:isLiliaPersistent()
    if self.GetPersistent and self:GetPersistent() then return true end
    return self.IsLeonNPC or self.IsPersistent
end

--[[
    checkDoorAccess

    Purpose:
        Checks if the given client has the specified access level to the door entity.

    Parameters:
        client (Player) - The player to check access for.
        access (number) - The access level to check (optional, defaults to DOOR_GUEST).

    Returns:
        boolean - True if the client has access, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if door:checkDoorAccess(client, DOOR_OWNER) then
            print("Client can access the door!")
        end
]]
function entityMeta:checkDoorAccess(client, access)
    if not self:isDoor() then return false end
    access = access or DOOR_GUEST
    if hook.Run("CanPlayerAccessDoor", client, self, access) then return true end
    if self.liaAccess and (self.liaAccess[client] or 0) >= access then return true end
    return false
end

--[[
    keysOwn

    Purpose:
        Assigns ownership of the vehicle entity to the given client.

    Parameters:
        client (Player) - The player to set as the owner.

    Realm:
        Shared.

    Example Usage:
        vehicle:keysOwn(client)
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
    keysLock

    Purpose:
        Locks the vehicle entity.

    Realm:
        Shared.

    Example Usage:
        vehicle:keysLock()
]]
function entityMeta:keysLock()
    if self:IsVehicle() then self:Fire("lock") end
end

--[[
    keysUnLock

    Purpose:
        Unlocks the vehicle entity.

    Realm:
        Shared.

    Example Usage:
        vehicle:keysUnLock()
]]
function entityMeta:keysUnLock()
    if self:IsVehicle() then self:Fire("unlock") end
end

--[[
    getDoorOwner

    Purpose:
        Returns the owner of the vehicle entity if available.

    Returns:
        Player or nil - The owner of the vehicle, or nil if not available.

    Realm:
        Shared.

    Example Usage:
        local owner = vehicle:getDoorOwner()
        if owner then print("Owner found!") end
]]
function entityMeta:getDoorOwner()
    if self:IsVehicle() and self.CPPIGetOwner then return self:CPPIGetOwner() end
end

--[[
    isLocked

    Purpose:
        Checks if the entity is locked according to its networked variable.

    Returns:
        boolean - True if locked, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isLocked() then
            print("Entity is locked!")
        end
]]
function entityMeta:isLocked()
    return self:getNetVar("locked", false)
end

--[[
    isDoorLocked

    Purpose:
        Checks if the door entity is locked according to its internal variable or fallback.

    Returns:
        boolean - True if locked, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if door:isDoorLocked() then
            print("Door is locked!")
        end
]]
function entityMeta:isDoorLocked()
    return self:GetInternalVariable("m_bLocked") or self.locked or false
end

--[[
    getEntItemDropPos

    Purpose:
        Calculates the position and angle where an item should be dropped from the entity.

    Parameters:
        offset (number) - The distance from the entity to drop the item (optional, defaults to 64).

    Returns:
        Vector, Angle - The position and angle for item drop.

    Realm:
        Shared.

    Example Usage:
        local pos, ang = entity:getEntItemDropPos(128)
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
    isNearEntity

    Purpose:
        Checks if another entity is within a certain radius of this entity.

    Parameters:
        radius (number) - The radius to check within (optional, defaults to 96).
        otherEntity (Entity) - The entity to check proximity to.

    Returns:
        boolean - True if the other entity is near, false otherwise.

    Realm:
        Shared.

    Example Usage:
        if entity:isNearEntity(128, otherEntity) then
            print("Other entity is nearby!")
        end
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
    GetCreator

    Purpose:
        Returns the creator of the entity from its networked variable.

    Returns:
        Player or nil - The creator of the entity, or nil if not set.

    Realm:
        Shared.

    Example Usage:
        local creator = entity:GetCreator()
        if creator then print("Creator found!") end
]]
function entityMeta:GetCreator()
    return self:getNetVar("creator", nil)
end

if SERVER then
    --[[
        SetCreator

        Purpose:
            Sets the creator of the entity in its networked variable.

        Parameters:
            client (Player) - The player to set as the creator.

        Realm:
            Server.

        Example Usage:
            entity:SetCreator(client)
    ]]
    function entityMeta:SetCreator(client)
        self:setNetVar("creator", client)
    end

    --[[
        sendNetVar

        Purpose:
            Sends a networked variable to a specific receiver or broadcasts it.

        Parameters:
            key (string) - The key of the variable to send.
            receiver (Player) - The player to send the variable to (optional).

        Realm:
            Server.

        Example Usage:
            entity:sendNetVar("locked", client)
    ]]
    function entityMeta:sendNetVar(key, receiver)
        net.Start("nVar")
        net.WriteUInt(self:EntIndex(), 16)
        net.WriteString(key)
        net.WriteType(lia.net[self] and lia.net[self][key])
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
        clearNetVars

        Purpose:
            Clears all networked variables for the entity and notifies clients.

        Parameters:
            receiver (Player) - The player to send the clear notification to (optional).

        Realm:
            Server.

        Example Usage:
            entity:clearNetVars(client)
    ]]
    function entityMeta:clearNetVars(receiver)
        lia.net[self] = nil
        net.Start("nDel")
        net.WriteUInt(self:EntIndex(), 16)
        if receiver then
            net.Send(receiver)
        else
            net.Broadcast()
        end
    end

    --[[
        removeDoorAccessData

        Purpose:
            Removes all door access data for the entity and notifies clients.

        Realm:
            Server.

        Example Usage:
            door:removeDoorAccessData()
    ]]
    function entityMeta:removeDoorAccessData()
        if IsValid(self) then
            for k, _ in pairs(self.liaAccess or {}) do
                net.Start("doorMenu")
                net.Send(k)
            end

            self.liaAccess = {}
            self:SetDTEntity(0, nil)
        end
    end

    --[[
        setLocked

        Purpose:
            Sets the locked state of the entity.

        Parameters:
            state (boolean) - The locked state to set.

        Realm:
            Server.

        Example Usage:
            entity:setLocked(true)
    ]]
    function entityMeta:setLocked(state)
        self:setNetVar("locked", state)
    end

    --[[
        setKeysNonOwnable

        Purpose:
            Sets whether the entity is non-ownable.

        Parameters:
            state (boolean) - The non-ownable state to set.

        Realm:
            Server.

        Example Usage:
            entity:setKeysNonOwnable(true)
    ]]
    function entityMeta:setKeysNonOwnable(state)
        self:setNetVar("noSell", state)
    end

    --[[
        isDoor

        Purpose:
            Checks if the entity is a door.

        Returns:
            boolean - True if the entity is a door, false otherwise.

        Realm:
            Server.

        Example Usage:
            if entity:isDoor() then
                print("This is a door!")
            end
    ]]
    function entityMeta:isDoor()
        if not IsValid(self) then return end
        local class = self:GetClass():lower()
        local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_"}
        for _, prefix in ipairs(doorPrefixes) do
            if class:find(prefix) then return true end
        end
        return false
    end

    --[[
        getDoorPartner

        Purpose:
            Returns the partner door entity if available.

        Returns:
            Entity or nil - The partner door entity, or nil if not set.

        Realm:
            Server.

        Example Usage:
            local partner = door:getDoorPartner()
            if partner then print("Partner door found!") end
    ]]
    function entityMeta:getDoorPartner()
        return self.liaPartner
    end

    --[[
        setNetVar

        Purpose:
            Sets a networked variable for the entity and notifies clients.

        Parameters:
            key (string) - The key of the variable.
            value (any) - The value to set.
            receiver (Player) - The player to send the update to (optional).

        Realm:
            Server.

        Example Usage:
            entity:setNetVar("locked", true)
    ]]
    function entityMeta:setNetVar(key, value, receiver)
        if checkBadType(key, value) then return end
        lia.net[self] = lia.net[self] or {}
        local oldValue = lia.net[self][key]
        if oldValue ~= value then lia.net[self][key] = value end
        self:sendNetVar(key, receiver)
        hook.Run("NetVarChanged", self, key, oldValue, value)
    end

    --[[
        getNetVar

        Purpose:
            Gets a networked variable for the entity.

        Parameters:
            key (string) - The key of the variable.
            default (any) - The default value to return if not set.

        Returns:
            any - The value of the networked variable, or the default if not set.

        Realm:
            Server.

        Example Usage:
            local locked = entity:getNetVar("locked", false)
    ]]
    function entityMeta:getNetVar(key, default)
        if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
else
    --[[
        isDoor

        Purpose:
            Checks if the entity is a door.

        Returns:
            boolean - True if the entity is a door, false otherwise.

        Realm:
            Client.

        Example Usage:
            if entity:isDoor() then
                print("This is a door!")
            end
    ]]
    function entityMeta:isDoor()
        return self:GetClass():find("door")
    end

    --[[
        getDoorPartner

        Purpose:
            Returns the partner door entity if available.

        Returns:
            Entity or nil - The partner door entity, or nil if not set.

        Realm:
            Client.

        Example Usage:
            local partner = door:getDoorPartner()
            if partner then print("Partner door found!") end
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
        getNetVar

        Purpose:
            Gets a networked variable for the entity.

        Parameters:
            key (string) - The key of the variable.
            default (any) - The default value to return if not set.

        Returns:
            any - The value of the networked variable, or the default if not set.

        Realm:
            Client.

        Example Usage:
            local locked = entity:getNetVar("locked", false)
    ]]
    function entityMeta:getNetVar(key, default)
        local index = self:EntIndex()
        if lia.net[index] and lia.net[index][key] ~= nil then return lia.net[index][key] end
        return default
    end

    playerMeta.getLocalVar = entityMeta.getNetVar
end
