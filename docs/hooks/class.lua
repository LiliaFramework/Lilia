--[[--
Class setup hooks.

As with `Faction`s, `Class`es get their own hooks for when players leave/join a class, etc. These hooks are only
valid in class tables that are created in `schema/classes/classname.lua`, and cannot be used like regular gamemode hooks.
]]
-- @hooks Class
--- Whether or not a player can switch to this class.
-- @realm shared
-- @player client Client that wants to switch to this class
-- @treturn bool True if the player is allowed to switch to this class
-- @usage function CLASS:onCanBe(client)
-- 	return client:IsAdmin() or client:getChar():hasFlags("Z")
-- end
function onCanBe(client)
end

--- Called when a character has left this class and has joined a different one.
-- @realm server
-- @param client Player who left this class
-- @usage function CLASS:onLeave(client)
-- 	local character = client:getChar()
-- 	character:setModel("models/player/alyx.mdl")
-- end
function onLeave(client)
end

--- Called when a character has joined this class.
-- @realm server
-- @param client Player who has joined this class
-- @usage function CLASS:onSet(client)
-- 	client:setModel("models/police.mdl")
-- end
function onSet(client)
end

--- Called when a character in this class has spawned in the world.
-- @realm server
-- @param client Player that has just spawned
-- @usage function CLASS:onSpawn(client)
-- 	client:SetMaxHealth(500)
-- 	client:SetHealth(500)
-- end
function onSpawn(client)
end