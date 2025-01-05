--- The Character Meta for the Recognition Module.
-- @charactermeta Recognition
local characterMeta = lia.meta.character
--- Checks if this character recognizes another character.
-- This function determines if the character recognizes another character by checking if they are recognized via a specific ID.
-- @realm shared
-- @int id The ID of the character to check recognition for. Can be a number or a character object.
-- @treturn boolean True if the character is recognized, false otherwise.
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

--- Checks if this character recognizes another character by a fake name.
-- This function determines if the character recognizes another character by a fake name via a specific ID.
-- @realm shared
-- @int id The ID of the character to check fake recognition for. Can be a number or a character object.
-- @treturn boolean True if the character is recognized by a fake name, false otherwise.
function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharFakeRecognized", self, id) ~= false
end

if SERVER then
    --- Recognizes another character.
    -- This function allows the character to recognize another character, optionally under a specified fake name.
    -- @realm server
    -- @character character The character to be recognized.
    -- @string name The fake name under which the character is recognized. If nil, recognizes the character by their actual ID.
    -- @treturn boolean True if the recognition was successful.
    function characterMeta:recognize(character, name)
        local id
        if isnumber(character) then
            id = character
        elseif character and character.getID then
            id = character:getID()
        else
            error("Invalid 'character' argument: must be a character object or an ID number.")
        end

        local recognized = self:getData("rgn", "")
        local nameList = self:getRecognizedAs()
        if name ~= nil then
            nameList[id] = name
            self:setRecognizedAs(nameList)
        else
            self:setData("rgn", recognized .. "," .. id .. ",")
        end
        return true
    end
end
