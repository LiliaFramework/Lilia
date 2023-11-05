--------------------------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character
--------------------------------------------------------------------------------------------------------------------------
function charMeta:recognize(id, name)
    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = self:getCharsWeKnow()
    local nameList = self:getRecognizedAs()
    if not isnumber(id) and id.getID then id = id:getID() end
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    nameList[id] = name
    peopleWhoWeKnow[id] = true
    self:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)
    return true
end
--------------------------------------------------------------------------------------------------------------------------