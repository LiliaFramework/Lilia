--- The Player Meta for the Spawns Module.
-- @playermeta Spawns
local playerMeta = FindMetaTable("Player")
--- Checks if the player has an active death timer.
-- This function restores a certain amount of stamina to the player, clamping the value between 0 and the character's maximum stamina.
-- If stamina is restored above a certain threshold, it may trigger the removal of a breathless state.
-- @realm shared
-- @treturn boolean True if the death timer is active, false otherwise.
function playerMeta:HasDeathTimer()
    return self:GetNWInt("deathTime", os.time()) > os.time()
end

if SERVER then
    --- Sets the player's death timer.
    -- This function decreases the player's stamina by a specified amount, clamping the value between 0 and the character's maximum stamina.
    -- If stamina is depleted, it may trigger a breathless state.
    -- @realm server
    function playerMeta:SetDeathTimer()
        self:SetNWInt("deathTime", os.time() + lia.config.SpawnTime)
    end
end