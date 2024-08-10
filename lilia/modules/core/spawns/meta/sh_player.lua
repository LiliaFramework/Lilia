-- @playermeta Spawns
local playerMeta = FindMetaTable("Player")
--- Checks if the player has an active death timer.
-- This function checks whether the player's death timer is still active, meaning they cannot respawn yet.
-- @realm shared
-- @treturn boolean True if the death timer is active, false otherwise.
function playerMeta:HasDeathTimer()
    return self:GetNWInt("deathTime", os.time()) > os.time()
end

if SERVER then
    --- Sets the player's death timer.
    -- This function sets a death timer for the player, preventing them from respawning until the timer expires.
    -- @realm server
    function playerMeta:SetDeathTimer()
        self:SetNWInt("deathTime", os.time() + lia.config.SpawnTime)
    end
end