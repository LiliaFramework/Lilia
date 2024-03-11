--[[--
Faction setup hooks.

Factions get their own hooks that are called for various reasons, but the most common one is to set up a character
once it's created and assigned to a certain faction. For example, giving a police faction character a weapon on creation.
These hooks are used in faction tables that are created in `schema/factions/sfactionname.lua` and cannot be used like
regular gamemode hooks.
]]
-- @hooks Faction

--- Called when the default name for a character needs to be retrieved (i.e upon initial creation).
-- @realm shared
-- @player client Client to get the default name for
-- @treturn string Defines the default name for the newly created character
-- @usage function FACTION:getDefaultName(client)
-- return "CT-" .. math.random(111111, 999999) -- This will set their name as CT-XXXXXX where as those 6 numerals are random generated 
-- end
function getDefaultName(client)
end

-- - Called when the default description for a character needs to be retrieved.
--  This function allows factions to define custom default descriptions for characters.
--  @param client The client for whom the default description is being retrieved
--  @param faction The faction ID for which the default description is being retrieved
--  @return string The default description for the newly created character
--  @realm shared
--  @usage function getDefaultDesc(client, faction)   
--  return "A police"
--  end
function getDefaultDesc(client, faction)
end

--- Called when a character has been initally created and assigned to this faction.
-- @realm server
-- @player client Client that owns the character
-- @char character Character that has been created
-- @usage function FACTION:onCharCreated(client, character)
-- local inventory = character:getInv()
-- inventory:add("fancy_suit") -- Adds a Fancy Suit Item
-- end
function onCharCreated(client, character)
end

--- Called when a character in this faction has spawned in the world.
-- @realm server
-- @player client Player that has just spawned
-- @usage function FACTION:onSpawn(client)
-- client:ChatPrint("You have Spawned!") -- Notifies a client that he has spawned.
-- end
function onSpawn(client)
end

--- Called when a player's character has been transferred to this faction.
-- @realm server
-- @char character Character that was transferred
-- @usage function FACTION:onTransferred(target)
--local character = target:getChar()
--local randomModelIndex = math.random(1, #self.models)
--character:setModel(self.models[randomModelIndex]) -- Retrieves a random model from the table and sets it as the character's model
-- end
function onTransferred(character)
end