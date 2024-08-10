-- @playermeta PAC3
local playerMeta = FindMetaTable("Entity")
--- Retrieves the PAC3 parts associated with the player.
-- This function returns a table of PAC3 parts that are currently associated with the player.
-- @realm shared
-- @treturn table A table containing the PAC3 parts.
function playerMeta:getParts()
    return self:getNetVar("parts", {})
end

if SERVER then
    --- Synchronizes the player's PAC3 parts with the client.
    -- This function sends a network message to the client to synchronize the player's PAC3 parts.
    -- @realm server
    function playerMeta:syncParts()
        net.Start("liaPACSync")
        net.Send(self)
    end

    --- Adds a PAC3 part to the player.
    -- This function adds a PAC3 part to the player's current parts and updates the client.
    -- @realm server
    -- @string partID The ID of the PAC3 part to add.
    function playerMeta:addPart(partID)
        if self:getParts()[partID] then return end
        net.Start("liaPACPartAdd")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = true
        self:setNetVar("parts", parts)
    end

    --- Removes a PAC3 part from the player.
    -- This function removes a PAC3 part from the player's current parts and updates the client.
    -- @realm server
    -- @string partID The ID of the PAC3 part to remove.
    function playerMeta:removePart(partID)
        net.Start("liaPACPartRemove")
        net.WriteEntity(self)
        net.WriteString(partID)
        net.Broadcast()
        local parts = self:getParts()
        parts[partID] = nil
        self:setNetVar("parts", parts)
    end

    --- Resets all PAC3 parts for the player.
    -- This function removes all PAC3 parts from the player and updates the client.
    -- @realm server
    function playerMeta:resetParts()
        net.Start("liaPACPartReset")
        net.WriteEntity(self)
        net.Broadcast()
        self:setNetVar("parts", {})
    end
end