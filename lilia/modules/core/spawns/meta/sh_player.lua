--- The Player Meta for the Spawns Module.
-- @playermeta Spawns
local playerMeta = FindMetaTable("Player")
--- Checks if the player is still within the spawn timer period after death.
-- This function checks if the current time is less than the death time, indicating that the spawn timer is still active.
-- @realm shared
-- @treturn boolean True if the death timer is active and within the spawn time, false otherwise.
function playerMeta:IsOnDeathTimer()
    local deathTimer = self:getNetVar("deathTime")
    return deathTimer and deathTimer > CurTime()
end

if SERVER then
    --- Sets the player's death timer to the current time plus the configured spawn time.
    -- This function records the time of death for the player, setting the death timer to expire after the spawn time.
    -- @realm server
    function playerMeta:SetDeathTimer()
        -- Set the death timer to the current time plus the configured spawn time
        self:setNetVar("deathTime", CurTime() + lia.config.SpawnTime)
    end
end