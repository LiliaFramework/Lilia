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
    self:setData("rgn", recognized .. "," .. id .. ",")
    local nameList = self:getRecognizedAs()
    nameList[id] = name
    peopleWhoWeKnow[id] = true
    character:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)

    return true
end
--------------------------------------------------------------------------------------------------------------------------