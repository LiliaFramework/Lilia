local entityMeta = FindMetaTable("Entity")
function entityMeta:isDoor()
    local class = self:GetClass():lower()
    local doorPrefixes = {"prop_door", "func_door", "func_door_rotating", "door_",}
    for _, prefix in ipairs(doorPrefixes) do
        if class:find(prefix) then return true end
    end
    return false
end

function entityMeta:getDoorPartner()
    return self.liaPartner
end

function entityMeta:AssignCreator(client)
    self:SetCreator(client)
end

function entityMeta:isLocked()
    if self:IsVehicle() then
        local datatable = self:GetSaveTable()
        if datatable then return datatable.VehicleLocked end
    else
        local datatable = self:GetSaveTable()
        if datatable then return datatable.m_bLocked end
    end
    return
end

--- Sends a networked variable.
-- @realm server
-- @internal
-- @string key Identifier of the networked variable
-- @tab[opt=nil] receiver The players to send the networked variable to
function entityMeta:sendNetVar(key, receiver)
    netstream.Start(receiver, "nVar", self:EntIndex(), key, lia.net[self] and lia.net[self][key])
end

--- Clears all of the networked variables.
-- @realm server
-- @internal
-- @tab[opt=nil] receiver The players to clear the networked variable for
function entityMeta:clearNetVars(receiver)
    lia.net[self] = nil
    netstream.Start(receiver, "nDel", self:EntIndex())
end

--- Sets the value of a networked variable.
-- @realm server
-- @string key Identifier of the networked variable
-- @param value New value to assign to the networked variable
-- @tab[opt=nil] receiver The players to send the networked variable to
-- @usage client:setNetVar("example", "Hello World!")
-- @see getNetVar
function entityMeta:setNetVar(key, value, receiver)
    if checkBadType(key, value) then return end
    lia.net[self] = lia.net[self] or {}
    if lia.net[self][key] ~= value then lia.net[self][key] = value end
    self:sendNetVar(key, receiver)
end

--- Entity networked variable functions
-- @classmod Entity
--- Retrieves a networked variable. If it is not set, it'll return the default that you've specified.
-- @realm shared
-- @string key Identifier of the networked variable
-- @param default Default value to return if the networked variable is not set
-- @return Value associated with the key, or the default that was given if it doesn't exist
-- @usage print(client:getNetVar("example"))
-- > Hello World!
-- @see setNetVar
function entityMeta:getNetVar(key, default)
    if lia.net[self] and lia.net[self][key] ~= nil then return lia.net[self][key] end
    return default
end

FindMetaTable("Player").getLocalVar = entityMeta.getNetVar
