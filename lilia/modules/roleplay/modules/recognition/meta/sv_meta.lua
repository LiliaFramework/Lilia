--------------------------------------------------------------------------------------------------------------------------
local charMeta = lia.meta.character
--------------------------------------------------------------------------------------------------------------------------
function charMeta:recognize(id, name)
    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = self:getCharsWeKnow()
    local nameList = self:getRecognizedAs()
    local character = lia.char.loaded[id]
    if not isnumber(id) and id.getID then id = id:getID() end
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    if name ~= nil and string.len(name) > 0 then
        nameList[id] = name
    else
        nameList[id] = tostring(character:getName())
        peopleWhoWeKnow[id] = true
    end

    self:setCharsWeKnow(peopleWhoWeKnow)
    self:setRecognizedAs(nameList)
    return true
end
--------------------------------------------------------------------------------------------------------------------------