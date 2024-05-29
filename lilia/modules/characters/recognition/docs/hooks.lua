--- Hook Documentation for Recognition Module.
-- @hooksmodule Recognition

--- Checks if a character is recognized.
-- @realm shared
--- @character character The character to check.
--- @int id Identifier for the character.
function isCharRecognized(character, id)

end
--- Checks if a character is fake recognized.
-- @realm shared
--- @character character The character to check.
--- @int id Identifier for the character.
function isCharFakeRecognized(character, id)
end

--- Checks if a fake name exists in the given character name list.
--- @realm shared
--- @string name The name to check.
--- @tab nameList A list of character names.
--- @treturn True if the name exists in the list, false otherwise.
function isFakeNameExistant(name, nameList)
end

--- Called when a character is recognized.
-- @realm shared
--- @client client The client whose character is recognized.
--- @int id Identifier for the recognized character.
function OnCharRecognized(client, id)
end

--- Initiates character recognition process.
-- @realm shared
--- @int level The recognition level.
--- @string name The name of the character to be recognized.
function CharRecognize(level, name)
end

--- Retrieves the displayed description of an entity.
-- This hook is used to get the description that should be displayed for an entity, either on the HUD or in another context.
-- @realm shared
-- @entity entity The entity whose description is being retrieved.
-- @bool isHUD Whether the description is being displayed on the HUD.
-- @treturn string The description to be displayed.
function GetDisplayedDescription(entity, isHUD)
end

--- Retrieves the displayed name of a client.
-- This hook is used to get the name that should be displayed for a client in a specific chat type.
-- @realm shared
-- @client client The client whose displayed name is being retrieved.
-- @string chatType The type of chat where the name will be displayed.
-- @treturn string The name to be displayed.
function GetDisplayedName(client, chatType)
end

--- Determines if a chat type is recognized.
-- This hook is used to check if a specific chat type is recognized within the system.
-- @realm shared
-- @string chatType The chat type being checked for recognition.
-- @treturn boolean True if the chat type is recognized, false otherwise.
function isRecognizedChatType(chatType)
end
