--------------------------------------------------------------------------------------------------------
local character = lia.meta.character
--------------------------------------------------------------------------------------------------------
function character:recognize(id)
    local id = character:getID()
    if not isnumber(id) and id.getID then
        id = id:getID()
    end

    local recognized = self:getData("rgn", "")
    local peopleWhoWeKnow = character:GetCharsWeKnow()
    if recognized ~= "" and recognized:find("," .. id .. ",") and peopleWhoWeKnow[id] then return false end
    self:setData("rgn", recognized .. "," .. id .. ",")
    local nameList = self:GetRecognizedAs()
    if string.len(name) > 0 then
        nameList[id] = name
    else
        nameList[id] = tostring(character:GetName())
        peopleWhoWeKnow[id] = true
    end

    character:SetCharsWeKnow(peopleWhoWeKnow)
    self:SetRecognizedAs(nameList)

    return true
end
--------------------------------------------------------------------------------------------------------