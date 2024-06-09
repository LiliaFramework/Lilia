--[[--
Faction setup hooks.

Factions have their own hooks that are called for various reasons, with the most common being to set up a character
once it's created and assigned to a certain faction. For example, giving a police faction character a weapon upon creation.
These hooks are used in faction tables that are created in `schema/factions/sfactionname.lua` and cannot be used like
regular gamemode hooks.
]]
-- @hooks Faction

--- Called when the default name for a character needs to be retrieved (i.e., upon initial creation).
-- @realm shared
-- @client client The client for whom the default name is being retrieved
-- @treturn string The default name for the newly created character
-- @usage function FACTION:GetDefaultName(client)
-- 	return "CT-" .. math.random(111111, 999999)
-- end
function GetDefaultName(client)
end

--- Called when the default description for a character needs to be retrieved.
-- This function allows factions to define custom default descriptions for characters.
-- @realm shared
-- @client client The client for whom the default description is being retrieved
-- @character faction The faction ID for which the default description is being retrieved
-- @treturn string The default description for the newly created character
-- @usage function FACTION:GetDefaultDesc(client, faction)
-- 	return "A police officer"
-- end
function GetDefaultDesc(client, faction)
end

--- Called when a character has been initially created and assigned to this faction.
-- @realm server
-- @client client The client that owns the character
-- @character character The character that has been created
-- @usage function FACTION:OnCharCreated(client, character)
-- 	local inventory = character:getInv()
-- 	inventory:add("fancy_suit")
-- end
function OnCharCreated(client, character)
end

--- Called when a character in this faction has spawned in the world.
-- @realm server
-- @client client The player that has just spawned
-- @usage function FACTION:OnSpawn(client)
-- 	client:chatNotify("You have spawned!")
-- end
function OnSpawn(client)
end

--- Called when a player's character has been transferred to this faction.
-- @realm server
-- @character character The character that was transferred
-- @usage function FACTION:OnTransferred(character)
-- 	local randomModelIndex = math.random(1, #self.models)
-- 	character:setModel(self.models[randomModelIndex])
-- end
function OnTransferred(character)
end