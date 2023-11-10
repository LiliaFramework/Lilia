--------------------------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character
--------------------------------------------------------------------------------------------------------------------------
function charMeta:recognize(character, name)
    local id = character:getID()
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = character:getCharsWeKnow()
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    local nameList = self:getRecognizedAs()
    if name ~= nil then
        nameList[id] = name
    else
        peopleWhoWeKnow[id] = true
    end

    character:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)

    return true
end
--------------------------------------------------------------------------------------------------------------------------