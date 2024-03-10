-- @functions Class
--- Whether or not a player can switch to this class.
-- @realm shared
-- @player client Client that wants to switch to this class
-- @treturn bool True if the player is allowed to switch to this class
-- @usage function CLASS:onCanBe(client)
--return client:IsAdmin() or client:getChar():hasFlags("Z") -- Only admins or people with the Z flag are allowed in this class!
--end
function onCanBe(client)
end

--- Called when a character has left this class and has joined a different one. You can get the class the character has
-- has joined by calling `character:GetClass()`.
-- @realm server
-- @player client Player who left this class
-- @usage function CLASS:onSpawn(client)
--local character = client:getChar()
--character:SetMode("models/player/alyx.mdl")
--end
function onLeave(client)
end

--- Called when a character has joined this class.
-- @realm server
-- @player client Player who has joined this class
-- @usage function CLASS:OnSet(client)
-- 	client:SetModel("models/police.mdl")
-- end
function onSet(client)
end

--- Called when a character in this class has spawned in the world.
-- @realm server
-- @player client Player that has just spawned
-- @usage function CLASS:onSpawn(client)
--client:SetMaxHealth(500) -- Sets your Max Health to 500
--client:SetHealth(500) -- Subsequently sets your Health to 500
--end
function onSpawn(client)
end