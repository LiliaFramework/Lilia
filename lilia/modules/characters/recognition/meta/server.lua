local characterMeta = lia.meta.character
function characterMeta:recognize(character, name)
    local id = character:getID()
    if not isnumber(id) and id.getID then id = id:getID() end
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
