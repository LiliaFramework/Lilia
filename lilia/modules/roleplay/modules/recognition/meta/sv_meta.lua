--------------------------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character
--------------------------------------------------------------------------------------------------------------------------
function charMeta:recognize(id, name)
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = charMeta:getCharsWeKnow()
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    local nameList = self:getRecognizedAs()
    if name ~= nil and string.len(name) > 0 then
        nameList[id] = name
    else
        nameList[id] = tostring(charMeta:getName())
        peopleWhoWeKnow[id] = true
    end

    charMeta:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)

    return true
end
--------------------------------------------------------------------------------------------------------------------------