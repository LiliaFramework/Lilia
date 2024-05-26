local characterMeta = lia.meta.character
function characterMeta:doesRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharRecognized", self, id) ~= false
end

function characterMeta:doesFakeRecognize(id)
    if not isnumber(id) and id.getID then id = id:getID() end
    return hook.Run("isCharFakeRecognized", self, id) ~= false
end
