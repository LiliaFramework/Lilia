
local character = lia.meta.character

function character:recognize(id, name)
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = character:getCharsWeKnow()
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    local nameList = self:getRecognizedAs()
    if string.len(name) > 0 then
        nameList[id] = name
    else
        nameList[id] = tostring(character:getName())
        peopleWhoWeKnow[id] = true
    end

    character:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)

    return true
end
