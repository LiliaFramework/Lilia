---
-- Called when the default name for a character needs to be retrieved (i.e upon initial creation).
--
-- @param client Client to get the default name for
-- @treturn string Defines the default name for the newly created character
--
function FACTION:getDefaultName(client)
    return "CT-" .. math.random(111111, 999999) -- This will set their name as CT-XXXXXX where as those 6 numerals are random generated 
end

---
-- Called when the default description for a character needs to be retrieved.
-- This function allows factions to define custom default descriptions for characters.
--
-- @param client The client for whom the default description is being retrieved
-- @param faction The faction ID for which the default description is being retrieved
-- @treturn string The default description for the newly created character
--
function FACTION:getDefaultDesc(client, faction)
    return "A police"
end

---
-- Called when a character has been initally created and assigned to this faction.
--
-- @param client Client that owns the character
-- @param character Character that has been created
--
function FACTION:onCharCreated(client, character)
    local inventory = character:getInv()
    inventory:add("fancy_suit") -- Adds a Fancy Suit Item
end

---
-- Called when a character in this faction has spawned in the world.
--
-- @param client Player that has just spawned
--
function FACTION:onSpawn(client)
    client:ChatPrint("You have Spawned!") -- Notifies a client that he has spawned.
end

---
-- Called when a player's character has been transferred to this faction.
--
-- @param character Character that was transferred
--
function FACTION:onTransferred(character)
    local randomModelIndex = math.random(1, #self.models)
    character:setModel(self.models[randomModelIndex]) -- Retrieves a random model from the table and sets it as the character's model
end